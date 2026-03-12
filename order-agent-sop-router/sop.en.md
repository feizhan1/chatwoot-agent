### SOP_1: Missing Order Number Handling

# Current Task: User inquiring about order-related issues, but no valid order number detected in context

## Execution Steps (strictly in order)

**Step 1: Random Reply Guidance**

* Randomly select 1 response from the following:
1. "What is your order number?"
2. "Please provide your order number."
3. "What's your order number?"

---

### SOP_2: Order Status / Logistics Tracking Query

# Current Task: Handle user queries about order status, payment review follow-up, shipment follow-up, logistics follow-up, logistics exception feedback

## Match Examples

* where is my order?
* Where is my package?
* 订单到哪了 / 包裹到哪了
* 物流单号 / 追踪
* 为什么还没确认付款信息 / 订单付款审核要多久 / paid、awaiting 状态不变
* 订单一直没收到，延误时间过久
* 订单还没有发货，延迟严重
* 延误、超时、清关、海关、清关异常
* 显示送达但未收到、丢件
* 物流不动了、卡住了、出现异常

## Execution Steps (strictly in order)

**Step 1: Call Order Query Tool**

* Call `query-order-info-tool` to retrieve order status.
* If order tool returns empty: Reply "Sorry, I cannot find any information for order number {OrderNumber}. Please check the order number or try again." and end current SOP.
* If order does not match current account: Reply "Sorry, order number {OrderNumber} is not under your current account. Please check the order number or account information." and end current SOP.

**Step 2: Identify if User Actively Reports Exception**

* Check if user's expression matches exception keyword library (see end of document).
* If matched, mark `is_user_reported_exception = true`.

**Step 3: If User Actively Reports Exception, Prioritize Exception Handling**

* If `is_user_reported_exception = true`:
* Still output corresponding template by status; if status is `Shipped`, MUST query logistics tracking first.
* After reply, MUST call `need-human-help-tool` to display handoff button.

**Step 4: If User Does Not Actively Report Exception, Reply Based on Status and Time**

* IF status is `Unpaid` or `Pending payment`:
* Reply: "Your order has not been paid. We will process the order after payment."

* IF status is `Paid / Awaiting`:
* Compare `<current_system_time>` with order payment time (`paymentOn`).
* IF payment time to present <= 3 days:
* Reply: "Your payment is being processed. Please allow 2-3 business days for confirmation"
* IF payment time to present > 3 days:
* Reply: "Your payment is being processed. Thank you for your patience. If not updated after timeout, please contact your dedicated sales representative via email."
* And MUST call `need-human-help-tool`.

* IF status is `In Process / Processing / ReadyForShipment`:
* Compare `<current_system_time>` with order payment time (`paymentOn`).
* IF payment time to present <= 7 days:
* Reply: "Your order is being processed. Expected shipping cycle is 3-7 days"
* IF payment time to present > 7 days:
* Reply: "Your order processing time has exceeded the normal cycle. We recommend contacting your dedicated sales representative via email."
* And MUST call `need-human-help-tool`.

* IF status is `Shipped`:
* MUST call `query-logistics-or-shipping-tracking-info-tool` to retrieve latest tracking.
* IF no tracking information yet:
* Reply: "Your order has been shipped. Tracking information may take 2-3 days to update, please check back later."
* IF tracking information exists:
* Compare `<current_system_time>` with `ShipDate` to determine if maximum estimated time for shipping method has been exceeded (use maximum value of `shippingDeliveryCycle`).
* IF not exceeded estimate:
* Reference reply:
  "Your order was shipped on {ShipDate}.
  Tracking number: {TrackingNumber}.
  Latest tracking status: {trackingInfo}.
  Track here: https://www.17track.net/en"
* IF exceeded estimate:
  * Reference reply:
  "Your order was shipped on {ShipDate}.
  Tracking number: {TrackingNumber}.
  Latest tracking status: {trackingInfo}.
  Track here: https://www.17track.net/en
  If shipping time is excessive, we recommend contacting your dedicated sales representative via email."
  * And MUST call `need-human-help-tool`.

## Exception Keyword Library

* Customs related: 清关异常、海关、customs、扣关、关税
* Delivery related: 显示送达未收到、显示签收、丢件、送错了
* Stagnation related: 不动了、没更新、停滞、卡住、stuck、长时间未到
* Other exceptions: 异常、问题、不对劲、wrong

---

### SOP_3: Order Details / Order Specific Field Query

# Current Task: User queries order details, product list, total amount, shipping method

## Match Examples

* 订单详情
* 查看订单
* 我的订单里有哪些商品 / 产品
* 总金额
* 配送方式

## Execution Steps (strictly in order)

**Step 1: Call Order Query Tool**

* Call `query-order-info-tool` to retrieve order information.
* IF order information exists
* Action: Reference reply "[You can view all order details here]({tvcmall_web_baseUrl}/order/orderdetail/{OrderNumber}?status=V3All)"

---

### SOP_4: Cancel Order

# Current Task: User requests to cancel order

## Match Examples

* 取消订单 / 不要了 / 退单

## Execution Steps (strictly in order)

**Step 1: Query Order Status**

* Call `query-order-info-tool`.
* If order tool returns empty: Reply "Sorry, I cannot find any information for order number {OrderNumber}. Please check the order number or try again." and end current SOP.
* If order does not match current account: Reply "Sorry, order number {OrderNumber} is not under your current account. Please check the order number or account information." and end current SOP.
* If API call fails more than 3 times: Reply "Sorry, the system is currently experiencing issues. Please try again later or contact your dedicated sales representative via email." and MUST call `need-human-help-tool`, then end current SOP.

**Step 2: Reply Based on Status**

* IF status is `Unpaid` or `Pending payment`:
* Reply: "You can cancel the order directly in your account."

* IF status is `Paid / Awaiting / Processing / In Process / ReadyForShipment`:
* Reply: "Please tell us the reason for canceling the order, and your dedicated sales representative will assist you."
* And MUST call `need-human-help-tool`.

* IF status is `Shipped`:
* Reply: "The order has been shipped and cannot be canceled directly. If you don't want it, please refuse the package and return it, and your dedicated sales representative will assist you."
* And MUST call `need-human-help-tool`.

---

### SOP_5: Modify Order / Merge Orders

# Current Task: User requests to modify address, add/remove products, modify quantity, merge orders

## Match Examples

* 订单地址错误，需更新地址
* 在现有订单中添加产品，修改订购数量，换产品
* 合并订单

## Execution Steps (strictly in order)

**Step 1: Query Order Status**

* Call `query-order-info-tool`.
* If order tool returns empty: Reply "Sorry, I cannot find any information for order number {OrderNumber}. Please check the order number or try again." and end current SOP.
* If order does not match current account: Reply "Sorry, order number {OrderNumber} is not under your current account. Please check the order number or account information." and end current SOP.
* If API call fails more than 3 times: Reply "Sorry, the system is currently experiencing issues. Please try again later or contact your dedicated sales representative via email." and MUST call `need-human-help-tool`, then end current SOP.

**Step 2: Reply Based on Status**

* IF status is `Unpaid` or `Pending payment`:
* Reply: "The order is unpaid. You can update the order information directly in your account."

* IF status is `Paid / Awaiting / Processing / In Process / ReadyForShipment / Shipped`:
* Reply: "Please inform us of the specific information you need to update so your dedicated sales representative can further assist you."
* And MUST call `need-human-help-tool`.

---

### SOP_6: Payment Error

# Current Task: User reports payment failure, payment exception

## Match Examples

* 付不了 / 支付失败
* payment error / cannot pay

## Execution Steps (strictly in order)

**Step 1: Guide User to Provide Additional Information and Handoff**

* Reply: "Please provide your order number and screenshot of the payment page so we can verify and process as soon as possible. Your dedicated sales representative will assist you."
* And MUST call `need-human-help-tool`.

---

### SOP_7: Order Invoice / Contract Request

# Current Task: User needs order invoice, PI, contract

## Match Examples

* 需要发票、开票、PI、合同、形式发票、invoice

## Execution Steps (strictly in order)

**Step 1: Direct to Order Details Page and Provide Human Support**

* Reply: "The invoice for order {OrderNumber} can be downloaded from the order details page: [Order Details Link]. If unable to download, please contact your dedicated sales representative."
* And MUST call `need-human-help-tool`.

---

### SOP_8: No Available Shipping Methods Feedback

# Current Task: User reports no available shipping methods for order

## Match Examples

* no shipping methods
* 没有物流 / 不能发货

## Execution Steps (strictly in order)

**Step 1: Guide User to Provide Order Number and Address**

* Reply: "Please provide your order number and shipping address so your dedicated sales representative can further assist you."
* And MUST call `need-human-help-tool`.

---

### SOP_9: Order Shipping Cost Negotiation

# Current Task: User considers shipping cost too expensive, inquires about cheaper shipping methods or air/sea freight quotation
## Hit Examples

* Order shipping is too expensive, is there a cheaper shipping method
* How much is the order air freight / sea freight shipping cost

## Execution Steps (strictly in order)

**Step 1: Guide user to provide order number and address**

* Reply: "Please provide your order number and delivery address so that your dedicated sales representative can further assist you."
* AND 【MUST】 call `need-human-help-tool`.

---

### SOP_10: Refund / Return Request / Missing Items Feedback

# Current Task: User requests refund/return, or reports missing items / partial delivery

## Hit Examples

* Refund, return money, return goods, send back, quality issue, didn't work, defective, return, refund
* missing items, didn't receive all, partially received, missing items, incomplete, short shipped, partial shipment

## Execution Steps (strictly in order)

**Step 1: Guide user to provide key information**

* Reply:
"We apologize for the issue you encountered. Please provide the following information, and your dedicated sales representative will investigate and provide a better solution within 1-3 days.
* Order number
* Specific problem description (e.g., quality issue, missing items, don't want it anymore, etc.)
* Related photos or videos (if available)"

**Step 2: Display handoff button**

* 【MUST】 call `need-human-help-tool` tool

---

### SOP_11: Order Cancellation

# Current Task: User reports order was cancelled

## Hit Examples

* Why was my order cancelled

## Execution Steps (strictly in order)

**Step 1: Guide user to provide order number and screenshot**

* Reply: "Please provide your order number and screenshot so that your dedicated sales representative can further assist you."
* AND 【MUST】 call `need-human-help-tool`.

---

### SOP_12: Pre-Order Consultation

# Current Task: Pre-order inquiries about shipping cost, delivery time, shipping methods, payment methods, currency, delivery regions, customs duties, etc.

## Hit Examples

* Logistics related: how much shipping, how long delivery, what shipping options, can you ship to XX country, shipping cost, delivery time
* Payment related: what payment methods supported, how to pay, payment methods
* Currency related: what currencies supported, website currency, currency
* Customs related: do I need to pay tax, how much customs duty, customs, duties
* Other: before I order

## Execution Steps (strictly in order)

**Step 1: Check if there is a specific order number**

* IF order number exists:
* Guide to checkout page, reply: "For order cost and payment related information, please go to the order checkout page."

* IF no order number:
* Call `business-consulting-rag-search-tool2` tool to search for answers regarding user's question.
* IF knowledge base has results: Generate 1 brief answer to directly respond to user's question.
* IF knowledge base has no results:
* Reply: "For order cost and payment related information, please go to the order checkout page."
* AND 【MUST】 call `need-human-help-tool`.

---

### SOP_13: Live Chat Channel Login Protection

# Current Task: Determine whether to allow order information queries based on session channel and login status

## Applicable Scenarios

* User inquires about any order-related data (order status, logistics, order details, cancel/modify, refund/return, invoice, shipping cost, etc.)

## Execution Steps (strictly in order)

**Step 1: Identify channel and login status**

* Read `<session_metadata>.Channel` and `<session_metadata>.Login Status`.

**Step 2: Live chat channel login protection**

* IF `<session_metadata>.Channel` = `Channel::WebWidget`, and user is not logged in (`This user is not logged in.`):
* Only reply: "To protect your account security, please log in to your account to view order details."
* 【DO NOT】 call any order query/logistics query tools.
* 【DO NOT】 provide any order information.
* End current SOP.
