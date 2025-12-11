from fastapi import APIRouter

from app.core.supabase_client import get_supabase_client

router = APIRouter()


@router.get("/doctors")
async def list_doctors(available_only: bool = True):
    supabase = get_supabase_client()
    query = supabase.table("psychologists").select("*").order("created_at", desc=True)
    if available_only:
        query = query.eq("is_available", True)
    resp = query.execute()
    return {"items": resp.data, "count": len(resp.data)}
