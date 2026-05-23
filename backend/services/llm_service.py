import httpx
import json
from utils.prompt_templates import INTENT_PROMPT   # Make sure this import is correct

OLLAMA_MODEL = "qwen2.5:1.5b"

async def classify_intent(message: str, history: list = None) -> dict:
    if history is None:
        history = []

    history_str = "\n".join([
        f"{msg.get('role', 'user')}: {msg.get('content', '')}" 
        for msg in history[-5:]
    ]) if history else "No previous conversation."

    prompt = INTENT_PROMPT.format(history=history_str, message=message)

    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(
                "http://localhost:11434/api/chat",
                json={
                    "model": OLLAMA_MODEL,
                    "messages": [{"role": "user", "content": prompt}],
                    "format": "json",
                    "stream": False,
                    "options": {"temperature": 0.1}
                }
            )
            
            response.raise_for_status()
            data = response.json()

            content = data.get("message", {}).get("content", "").strip()
            if not content:
                return {"intent": "unknown", "confidence": 0.5}

            try:
                return json.loads(content)
            except:
                return {"intent": "unknown", "confidence": 0.5}

    except Exception as e:
        print(f"[Ollama Error] {e}")
        return {"intent": "unknown", "confidence": 0.5}