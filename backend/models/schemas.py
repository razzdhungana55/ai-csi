from pydantic import BaseModel
from typing import List, Dict, Any, Optional

class ChatRequest(BaseModel):
    message: str
    conversation_id: Optional[str] = "default"
    history: Optional[List[Dict[str, str]]] = []

class ToolCall(BaseModel):
    intent: str
    confidence: float

class Hotel(BaseModel):
    name: str
    price: str
    rating: float
    location: str

class ResponseData(BaseModel):
    hotels: Optional[List[Hotel]] = None
    # Add other data types as needed (flights, order_info, etc.)

class ChatResponse(BaseModel):
    intent: str
    ui_type: str  # e.g., "hotel_page", "tracking_page", "message_only"
    message: str
    data: Optional[ResponseData] = None