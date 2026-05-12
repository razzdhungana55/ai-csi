from collections import defaultdict

class ConversationMemory:
    def __init__(self):
        self.store = defaultdict(list)
    
    def add_turn(self, conv_id: str, user_msg: str, assistant_resp: dict):
        self.store[conv_id].append({
            "user": user_msg,
            "assistant": assistant_resp.get("message")
        })
        # Keep last 5 turns
        if len(self.store[conv_id]) > 5:
            self.store[conv_id] = self.store[conv_id][-5:]
    
    def get_history(self, conv_id: str):
        return self.store[conv_id]