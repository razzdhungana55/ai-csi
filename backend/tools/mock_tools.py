from models.schemas import Hotel, ResponseData

def tracking_tool(order_id: str = None):
    return {
        "status": "In Transit",
        "location": "Dubai Hub",
        "estimated_delivery": "May 15, 2026"
    }

def refund_tool():
    return {"message": "Refund request received. Processing within 3-5 business days."}

def complaint_tool():
    return {"message": "We have escalated your complaint to the support team."}

def escalation_tool():
    return {"message": "Connecting you to a human agent..."}

def hotel_tool(query: str = "Dubai"):
    return ResponseData(
        hotels=[
            Hotel(name="Hayat Regency", price="$220", rating=4.8, location=query),
            Hotel(name="Marriot", price="$180", rating=4.5, location=query),
        ]
    )

def flight_tool(query: str = None):
    return {"flights": ["EK123 - Dubai to London", "QR456 - Doha to Paris"]}