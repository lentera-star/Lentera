import json
from pathlib import Path
from uuid import uuid4

from fastapi import APIRouter, UploadFile, File, Form, HTTPException, status
from pydantic import ValidationError

from app.core.supabase_client import get_supabase_client
from app.models.mood import MoodCreate

router = APIRouter()


@router.get("/mood")
async def list_mood_entries(user_id: str | None = None, date: str | None = None):
    supabase = get_supabase_client()
    query = supabase.table("mood_entries").select("*").order("created_at", desc=True)
    if user_id:
        query = query.eq("user_id", user_id)
    if date:
        # naive day filter using prefix match on ISO date (YYYY-MM-DD)
        query = query.like("created_at", f"{date}%")
    resp = query.execute()
    return {"items": resp.data, "count": len(resp.data)}


@router.post("/mood")
async def create_mood_entry(
    json_data: str = Form(...),
    audio_file: UploadFile | None = File(default=None),
):
    try:
        payload_dict = json.loads(json_data)
        mood = MoodCreate.model_validate(payload_dict)
    except (json.JSONDecodeError, ValidationError) as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid json_data payload",
        ) from exc

    supabase = get_supabase_client()

    audio_path = None
    if audio_file:
        try:
            file_bytes = await audio_file.read()
            suffix = Path(audio_file.filename or "").suffix or ".wav"
            object_path = f"{mood.user_id}/{uuid4()}{suffix}"
            supabase.storage.from_("mood-audio").upload(
                path=object_path,
                file=file_bytes,
                file_options={"content-type": audio_file.content_type or "application/octet-stream"},
            )
            audio_path = supabase.storage.from_("mood-audio").get_public_url(object_path)
        except Exception as exc:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to upload audio",
            ) from exc

    record = {
        "user_id": mood.user_id,
        "mood_score": mood.mood_score,
        "journal_text": mood.journal_text,
        "audio_path": audio_path,
        "transcription": None,
    }

    resp = supabase.table("mood_entries").insert(record).execute()
    inserted = resp.data[0] if resp.data else record
    return {"message": "mood entry created", "item": inserted, "has_audio": audio_file is not None}
