# Intent-Agent 测试用例

## 案例 1: 运输时间连续追问（本次失败案例）

### 输入
```xml
<recent_dialogue>
human: "How long will it take to ship to my country?"
ai: "Could you please specify which country you would like the shipment to be sent to?"
human: "China"
</recent_dialogue>

<current_request>
    <user_query>China</user_query>
</current_request>
```

### 预期输出
```json
{
  "intent": "query_knowledge_base",
  "confidence": 0.95,
  "entities": {
    "destination_country": "China",
    "query_type": "shipping_time",
    "context_inherited": true
  },
  "resolution_source": "recent_dialogue_turn_n_minus_1",
  "reasoning": "用户回答了上一轮 AI 询问的国家信息，继承运输时间查询意图"
}
```

### 错误输出（需避免）
```json
{
  "intent": "need_confirm_again",  // ❌
  "resolution_source": "unable_to_resolve"  // ❌
}
```

---

## 案例 2: 订单号连续追问

### 输入
```xml
<recent_dialogue>
human: "帮我查下订单 V25121000001"
ai: "订单 V25121000001 状态：已发货，快递单号 SF123456"
human: "什么时候到？"
</recent_dialogue>
```

### 预期输出
```json
{
  "intent": "query_user_order",
  "confidence": 0.95,
  "entities": {
    "order_number": "V25121000001",
    "query_type": "delivery_time"
  },
  "resolution_source": "recent_dialogue_turn_n_minus_1"
}
```

---

## 案例 3: 产品 SKU 连续追问

### 输入
```xml
<recent_dialogue>
ai: "这款 iPhone 17 红色手机壳（SKU: IP17-RED-TPU-001）价格是 $5.99"
human: "有库存吗？"
</recent_dialogue>
```

### 预期输出
```json
{
  "intent": "query_product_data",
  "confidence": 0.95,
  "entities": {
    "sku": "IP17-RED-TPU-001",
    "query_type": "stock_availability"
  },
  "resolution_source": "recent_dialogue_turn_n_minus_1"
}
```

---

## 案例 4: Active Context 补全

### 输入
```xml
<memory_bank>
### Active Context (Current Session Summary)
- Active Order: V25121000001 (discussed in Turn 3)
- Session Theme: Order tracking
</memory_bank>

<recent_dialogue>
human: "你好"
ai: "您好！有什么可以帮您？"
human: "那个订单发货了吗？"
</recent_dialogue>
```

### 预期输出
```json
{
  "intent": "query_user_order",
  "confidence": 0.85,
  "entities": {
    "order_number": "V25121000001",
    "query_type": "shipping_status"
  },
  "resolution_source": "active_context"
}
```

---

## 案例 5: 真正需要澄清的情况

### 输入
```xml
<memory_bank>
### Active Context
- No active orders in current session
- No recent product inquiries
</memory_bank>

<recent_dialogue>
human: "你好"
ai: "您好！有什么可以帮您？"
human: "我想查物流"
</recent_dialogue>
```

### 预期输出
```json
{
  "intent": "need_confirm_again",
  "confidence": 0.7,
  "entities": {},
  "resolution_source": "unable_to_resolve",
  "reasoning": "用户请求查物流但未提供订单号，且上下文中无订单信息",
  "clarification_needed": [
    "请提供您的订单号，以便查询物流信息"
  ]
}
```
