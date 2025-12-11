from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field

from app.core.supabase_client import get_supabase_client

router = APIRouter()


class BookingCreate(BaseModel):
    user_id: str
    psychologist_id: str
    session_time: str  # ISO datetime string
    status: str = Field(default="pending")


@router.post("/booking/create")
async def create_booking(payload: BookingCreate):
    supabase = get_supabase_client()
    record = payload.model_dump()
    resp = supabase.table("bookings").insert(record).execute()
    if not resp.data:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to create booking")
    return {"message": "booking created", "item": resp.data[0]}


@router.get("/booking")
async def list_bookings(user_id: str | None = None):
    supabase = get_supabase_client()
    query = supabase.table("bookings").select("*").order("created_at", desc=True)
    if user_id:
        query = query.eq("user_id", user_id)
    resp = query.execute()
    return {"items": resp.data, "count": len(resp.data)}
