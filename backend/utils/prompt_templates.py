INTENT_PROMPT = """
You are an intent classifier for a customer support assistant.
Available intents: order_tracking, refund_request, complaint, escalation, hotel_search, flight_search, greeting, unknown.

Conversation history:
{history}

User message: {message}

Respond ONLY with valid JSON (no extra text):
{{
  "intent": "one_of_the_above",
  "confidence": 0.95
}}
"""