from pydantic import BaseModel, Field, field_validator


class MoodCreate(BaseModel):
    user_id: str
    mood_score: int = Field(..., ge=1, le=5)
    journal_text: str | None = None

    @field_validator("user_id")
    @classmethod
    def user_id_not_empty(cls, v: str) -> str:
        if not v:
            raise ValueError("user_id is required")
        return v
