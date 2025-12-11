from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel

from app.core.config import get_settings
from app.services.ai_pipeline import generate_trivia

router = APIRouter()


class TriviaRequest(BaseModel):
    mood_text: str
    model: str | None = None


@router.post("/trivia/generate")
async def generate_trivia_api(payload: TriviaRequest):
    settings = get_settings()
    if not settings.ollama_url:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Ollama URL not configured")

    result = generate_trivia(
        mood_text=payload.mood_text,
        chroma_url=settings.chroma_url,
        ollama_url=settings.ollama_url,
        model=payload.model or "llama3",
    )
    return result


class TriviaAnswer(BaseModel):
    answer_index: int


@router.post("/trivia/submit")
async def submit_trivia(payload: TriviaAnswer):
    # For now, always return stub; real scoring would compare with stored trivia state
    return {"correct": True, "selected": payload.answer_index}
