from fastapi import FastAPI

from app.api.v1 import mood, doctors, booking, trivia

app = FastAPI(title="LENTERA Backend")


@app.get("/", tags=["health"])
async def root():
    return {"message": "Hello from LENTERA backend"}


@app.get("/health", tags=["health"])
async def health():
    return {"status": "ok"}


app.include_router(mood.router, prefix="/api/v1", tags=["mood"])
app.include_router(doctors.router, prefix="/api/v1", tags=["doctors"])
app.include_router(booking.router, prefix="/api/v1", tags=["booking"])
app.include_router(trivia.router, prefix="/api/v1", tags=["trivia"])
