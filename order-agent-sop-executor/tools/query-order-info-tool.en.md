Retrieve detailed information for a specific order, including order status, product list, amount, payment information, etc.

The "status" field indicates the order status:

- Pending payment

- ReadyForShipment

- Shipped

If status is "Shipped", it is recommended to call the "query-logistics-or-shipping-tracking-info-tool" to obtain tracking information.

Use cases:

- User asks: "What is my order status?"

- User asks: "When will my order be shipped?"

- User wants to view order details and processing status

Return value (JSON):
{
  "orderId": "string - Order number",
  "discountedAmount": "number - Order amount",
  "status": "string - Order status (Pending payment/ReadyForShipment/Shipped/Completed)",
  "createdOn": "string - Order creation time (ISO 8601)",
  "paymentOn": "string - Payment time (ISO 8601)",
  "shippingDeliveryCycle": "string - Shipping cycle",
  "items": [
    {
      "sku": "string - SKU code",
      "productTitle": "string - Product name",
      "quantity": "number - Order quantity",
      "unitPrice": "number - Unit price",
      "thumbnail": "string - Thumbnail URL (optional)",
      "url": "string - TVCMALL product page URL",
      "supplyChainInfo": {
        "stockQuantity": "number - Stock quantity (in preparation, optional)",
        "shippedQuantity": "number - Shipped quantity",
        "shortageQuantity": "number - Shortage quantity (optional)",
        "shortageNote": "string - Shortage note (optional)",
        "estimatedArrivalTime": "string - Estimated arrival time (optional)"
      }
    }
  ],
  "shippingPackages": [
    {
      "orderId": "string - Order number",
      "trackingNumber": "string - Tracking number",
      "courierNumber": "string - Courier company code"
    }
  ]
}
