from fastapi import FastAPI
from .routers import health

app = FastAPI(title="HTX Agri API")

@app.get("/")
async def root():
    return {"message": "HTX Agri API is running"}

# Gắn router health
app.include_router(health.router)