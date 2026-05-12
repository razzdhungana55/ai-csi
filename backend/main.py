from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes.chat import router

app = FastAPI(title="AI Customer Support Assistant")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For Flutter dev
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)
@app.get("/")
def home():
    return {"message": "AI Customer Support Backend Running"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)