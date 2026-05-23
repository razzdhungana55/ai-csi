from fastapi import APIRouter
from models.schemas import ChatRequest, ChatResponse
from services.llm_service import classify_intent
from services.memory_service import ConversationMemory
from tools.mock_tools import *

router = APIRouter()
memory = ConversationMemory()


@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    # 1. Classify intent
    intent_data = await classify_intent(request.message, request.history)
    intent = intent_data.get("intent", "unknown")
    
    # 2. Execute tool
    tool_result = None
    ui_type = "message_only"
    message = "How can I help you today?"
    
    if intent == "hotel_search":
        tool_result = hotel_tool(request.message)
        ui_type = "hotel_page"
        message = f"Found hotels in {request.message}"
    elif intent == "flight_search":
        tool_result = flight_tool()
        ui_type = "flight_page"
        message = "Available flights:"
    elif intent == "order_tracking":
        tool_result = tracking_tool()
        ui_type = "tracking_page"
        message = "Order status retrieved."
    # ... add other intents similarly
    
    response = ChatResponse(
        intent=intent,
        ui_type=ui_type,
        message=message,
        data=tool_result if isinstance(tool_result, ResponseData) else None
    )
    
    # 3. Update memory
    memory.add_turn(request.conversation_id, request.message, response.dict())
    
    return response