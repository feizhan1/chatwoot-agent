---

### SOP_1: Missing Order Number Handling

# Current Task: User inquires about an order issue, but no valid order number is detected in the context

## Execution Steps (STRICT sequential order)

**Step 1: Random Response Script**

* Action: Randomly select one of the following responses:

1. "Could you please provide your order number?"
2. "Please provide your order number."
3. "What is your order number?"

---

### SOP_2: Order Status / Logistics Tracking Query

# Current Task: Handle queries such as "where is my order/package"

## Execution Steps (STRICT sequential order)

**Step 1: Extract and Validate Order Number**

* IF no order number -> Execute **SOP_1** and end.
* IF order number exists -> Call `query-order-info-tool`.

**Step 2: STRICT Status Routing**

* IF status is [Unpaid]:
* Reply: "Your order has not been paid yet. We will process the order once payment is completed."

* IF status is [Paid / Awaiting]:
* <current_system_time> is the current time.
* IF order creation time [createdOn] compared with current time <current_system_time> was created within the last 3 days: Reply: "Your payment is being processed. Please allow 2-3 business days for confirmation."
* IF order creation time [createdOn] compared with current time <current_system_time> was created more than 3 days ago: Reply: "Your payment is being processed. Thank you for your patience, your dedicated account manager will handle this for you." **And MUST call `need-human-help-tool`.**

* IF status is [In Process]:
* Reply: "Your order is being processed. The estimated shipping timeframe is 3-7 days."

* IF status is [Shipped]:
* Action: MUST call `query-logistics-or-shipping-tracking-info-tool` to obtain the latest status.
* IF no tracking information available: Reply: "Your order has been shipped. Tracking information may take 2-3 days to update."
* IF tracking information available: Reply: "Your order was shipped on {ShipDate}.\nTracking Number: {TrackingNumber}.\nLatest Tracking Status: {trackingInfo}.\nTrack here: [https://www.17track.net/en](https://www.17track.net/en)"

---

### SOP_3: Order Details & Specific Field Query

# Current Task: Handle inquiries about "order details / total amount / shipping method / what items are included"

## Execution Steps (STRICT sequential order)

**Step 1: Unified Response with General Link**

* Action: Reply directly: "You can view all your order details here: [https://www.tvcmall.com/user/orders?status=V3All](https://www.tvcmall.com/user/orders?status=V3All)"
* Restriction: ABSOLUTELY DO NOT list item details or output specific field values in the conversation.

---

### SOP_4: Cancel Order

# Current Task: Handle "cancel order" requests

## Execution Steps (STRICT sequential order)

**Step 1: Extract Order Number and Query Status**

* IF no order number -> Execute **SOP_1** and end.
* IF order number exists -> Call `query-order-info-tool`.

**Step 2: STRICT Status Routing**

* IF status is [Unpaid]:
* Reply: "You can cancel the order directly from your account." (Restriction: DO NOT call the handoff tool)

* IF status is [Paid / Awaiting / Processing]:
* Reply: "Please let us know the reason for canceling the order, and your dedicated account manager will handle this for you." **And MUST call `need-human-help-tool`.**

* IF status is [Shipped]:
* Reply: "The order has been shipped and cannot be canceled. If you do not want the item, please refuse the package and return it. Your dedicated account manager will handle this for you." **And MUST call `need-human-help-tool`.**

---

### SOP_5: Modify Order / Merge Orders

# Current Task: Handle requests to "change address / add products / change quantity / merge orders"

## Execution Steps (STRICT sequential order)

**Step 1: Extract Order Number and Query Status**

* IF no order number -> Execute **SOP_1** and end.
* IF order number exists -> Call `query-order-info-tool`.

**Step 2: STRICT Status Routing**

* IF status is [Unpaid]:
* Reply: "The order has not been shipped yet. You can update the order information directly from your account." (Restriction: DO NOT call the handoff tool)

* IF status is [Paid / Awaiting / Processing / Shipped]:
* Reply: "Please let us know the specific information you need to update." **And MUST call `need-human-help-tool`.**

---

### SOP_6: Order Exceptions & Complaint Handling (Payment Errors / Returns & Refunds)

# Current Task: Handle payment errors (Payment Error) or refund/return requests

## Execution Steps (STRICT sequential order)

**Step 1: Identify the Specific Exception Scenario and Reply**

* IF scenario is [Payment Error]:
* Reply: "Please provide your order number and a screenshot of the payment page so we can assist you further. Your dedicated account manager will handle this for you." **And MUST call `need-human-help-tool`.**

* IF scenario is [Refund / Return]:
* Reply: "Please provide your order number along with photos or videos showing the issue. We will review and respond within 1-3 business days." **And MUST call `need-human-help-tool`.**

---

### SOP_7: Logistics Human Intervention Scenarios (Shipping Rate Negotiation / No Logistics / Logistics Exceptions)

# Current Task: Handle air/sea freight negotiation, no available shipping methods, customs clearance exceptions, or non-receipt of goods

## Execution Steps (STRICT sequential order)

**Step 1: Unified Human Intervention Response**

* Action: Reply directly: "Please provide your order number, and your dedicated account manager will assist you." **And MUST call `need-human-help-tool`.**
* Restriction: ABSOLUTELY DO NOT guess shipping costs or explain customs clearance reasons.

---

### SOP_8: General Order Shipping Cost / Transit Time Query (Non-Specific Order)

# Current Task: User asks general questions about platform shipping costs, transit times, and supported shipping methods

## Execution Steps (STRICT sequential order)

**Step 1: Guide to Checkout Page**

* Action: Reply directly: "For shipping costs and transit times for your order, please check the order checkout page."

---

### SOP_9: Order Shipping Delay / Transit Delay (Urging & Complaints)

# Current Task: Handle urging requests such as "still haven't received / severely delayed / not shipped"

## Execution Steps (STRICT sequential order)

**Step 1: Extract Order Number and Query Status**

* IF no order number -> Execute **SOP_1** and end.
* IF order number exists -> Call `query-order-info-tool`.

**Step 2: STRICT Status and Time-Based Routing**

* IF status is [Unpaid]:
* Reply: "The order has not been shipped yet. Order processing will begin after payment is completed."

* IF status is [Paid / Awaiting]:
* Reply: "Your payment is being processed. Please allow 2-3 business days for confirmation."

* IF status is [In Process]:
* Logic: Calculate the current processing duration of the order.
* IF processing time < 7 days: Reply: "Your order is being processed. The estimated shipping timeframe is 3-7 days."
* IF processing time ≥ 7 days: Reply: "Your order is being processed. If the processing time is too long, we recommend contacting your dedicated account manager via email." **And MUST call `need-human-help-tool`.**

* IF status is [Shipped]:
* Action: MUST call `query-logistics-or-shipping-tracking-info-tool`.
* Logic: Compare the current time with the estimated transit time (`shippingDeliveryCycle`).
* IF within the maximum estimated logistics time: Reply: "Your order was shipped on {ShipDate}.\nTracking Number: {TrackingNumber}.\nLatest Tracking Status: {trackingInfo}.\nEstimated Transit Time: {shippingDeliveryCycle}.\nTrack here: [https://www.17track.net/en](https://www.17track.net/en)"
* IF exceeded the maximum estimated logistics time: Reply: "Your order is in transit. If the transit time is too long, we recommend contacting your dedicated account manager via email." **And MUST call `need-human-help-tool`.**

---

### SOP_10: Pre-Sale General Order Consultation

# Current Task: Answer policy questions about supported currencies, payment methods, duties, etc.

## Execution Steps (STRICT sequential order)

**Step 1: Search Knowledge Base**

* Action: Call the knowledge base tool (RAG) to query relevant policies.

**Step 2: Generate Response**

* Restriction: Only generate **one concise answer** addressing the user's specific question. DO NOT provide lengthy explanations.

---

### SOP_11: Not Logged In Security Prompt (Non-WhatsApp)

# Current Task: User is not logged in and inquires about any order-related data (excluding WhatsApp channel)

## Execution Steps (STRICT sequential order)

**Step 1: Verify Login Status and Channel**

* IF `<session_metadata>.Login Status` == `This user is not logged in.` **AND** `<session_metadata>.Channel` != `channel:TwilioSms`:
  * Reply directly: "To protect your account security, please log in to your account to view order details."
  * **DO NOT** call any tools
  * End task

* IF `<session_metadata>.Channel` == `channel:TwilioSms`:
  * This SOP does not apply; return to the regular routing flow
