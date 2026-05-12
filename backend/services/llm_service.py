import httpx
import json
from utils.prompt_templates import INTENT_PROMPT

OLLAMA_URL = "http://localhost:11434/api/chat"

async def classify_intent(message: str, history: list) -> dict:
    history_str = "\n".join([f"{m['role']}: {m['content']}" for m in history[-4:]])
    
    prompt = INTENT_PROMPT.format(history=history_str, message=message)
    
    async with httpx.AsyncClient() as client:
        response = await client.post(
            OLLAMA_URL,
            json={
                "model": "llama3.2",  # or mistral, gemma2, etc.
                "messages": [{"role": "user", "content": prompt}],
                "format": "json",      # Ollama structured output
                "stream": False,
                "options": {"temperature": 0.1}
            },
            timeout=60.0
        )
        data = response.json()
        content = data["message"]["content"]
        return json.loads(content)