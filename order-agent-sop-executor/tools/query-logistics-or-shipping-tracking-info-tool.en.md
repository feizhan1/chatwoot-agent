Query logistics/courier tracking information for a specific order, including courier company, tracking number, and shipment trajectory.

Important Note: Only use this tool for orders with status "Shipped". Use this tool when users ask about courier/delivery/logistics/tracking related questions.

Usage Scenarios:
- User asks: "When will my order arrive?"
- User asks: "Track my package" or "Where is my order?"
- User wants to know delivery status and location
- Order status is "Shipped" and user needs logistics details

Returns logistics information array (one order may have multiple packages):
[
  {
    "message": "string - Response message (e.g., 'ok')",
    "nu": "string - Tracking number",
    "ischeck": "string - Delivery confirmation status: 0=Not signed, 1=Signed",
    "com": "string - Courier company code",
    "state": "string - Shipping status: 0=In transit, 1=Picked up, 2=Problem, 3=Signed, 4=Return signed, 5=Out for delivery, 6=Returned, 7=Transferred",
    "data": [
      {
        "time": "string - Tracking timestamp (YYYY-MM-DD HH:mm:ss)",
        "context": "string - Tracking description"
      }
    ],
    "arrivalTime": "string - Estimated arrival time (optional)"
  }
]
