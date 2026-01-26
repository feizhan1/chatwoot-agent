正确识别：need_confirm_again, missing_entity=order_number
```

**错误归类为 need_confirm_again 的例子**：
```
<recent_dialogue>
human: "查一下订单 V25121000001"
ai: "订单 V25121000001 已发货"
human: "物流单号是多少？"  ← 这是连续追问，不是缺少信息
</recent_dialogue>
<memory_bank>
### Active Context
- No active orders in current session
- No recent product inquiries
</memory_bank>

Correct identification: need_confirm_again (indeed missing order number)
```

**Examples incorrectly categorized as need_confirm_again**:
```
<recent_dialogue>
human: "Query payment information for order V25121000001"
ai: "Order V25121000001 has been paid, amount $150"
human: "Has it been shipped?"  ← Clearly refers to the order from previous turn
</recent_dialogue>

Incorrect identification: need_confirm_again ❌
Correct identification: query_user_order, order_number=V25121000001 ✅
```

---

# Decision Flow (strictly execute in this order)

⚠️ **IMPORTANT**: This flow is mandatory and no steps may be skipped.

```
Step 1: Security Detection
  ↓
  Question: Does it meet handoff criteria?
  ├─ Yes → Categorize as handoff ✅ End
  └─ No → Proceed to Step 2

Step 2: Check User Input Completeness
  ↓
  Question: Does user input contain pronouns or omit subject/key parameters?
  ├─ No (input complete) → Skip to Step 7 (direct intent classification)
  └─ Yes (input incomplete) → Proceed to Step 2.1 (ambiguous reference detection)

Step 2.1: Ambiguous Reference Detection (new)
  ↓
  Question: Contains ambiguous reference terms ("latest model", "new version", "some accessories", etc.)?
  ├─ Yes → Proceed to Step 3 (attempt context completion, but higher requirement: must have specific model)
  └─ No (common pronouns: "this", "that order") → Proceed to Step 3 (context completion)

Step 3: Review last 1-2 turns of recent_dialogue
  ↓
  Question: Can the referenced entity be found (order number/SKU/specific product model)?
  ⚠️ For ambiguous references, must find specific model (e.g., "iPhone 17"), category/brand alone insufficient
  ├─ Yes (specific entity found) → Proceed to Step 4
  └─ No (not found OR only category/brand) → Proceed to Step 5

Step 4: Apply entity from recent_dialogue
  ↓
  Action: Apply entity (order number/SKU/subject) to current request
  Set: resolution_source = "recent_dialogue_turn_n_minus_1" or "_n_minus_2"
       entities.context_inherited = true
  ↓
  Categorize as explicit intent (query_user_order / query_product_data / query_knowledge_base)
  ✅ End

Step 5: Review Active Context in memory_bank
  ↓
  Question: Does Active Context contain available active entities?
  ⚠️ For ambiguous references, Active Context must include specific model, not just category/brand
  ├─ Yes (has specific entity) → Proceed to Step 6
  └─ No (no entity OR only category/brand) → Proceed to Step 7 (confirm as need_confirm_again)

Step 6: Apply entity from Active Context
  ↓
  Action: Complete using Active Context information
  Set: resolution_source = "active_context"
       entities.context_inherited = true
       confidence = 0.75-0.85 (slightly lower than recent_dialogue due to distant context)
  ↓
  Categorize as explicit intent (query_user_order / query_product_data / query_knowledge_base)
  ✅ End

Step 7: Intent Classification (complete input) or Confirm Need for Clarification (unable to complete)
  ↓
  Question: From Step 2 (complete input) or Step 5 (unable to complete)?
  ├─ From Step 2 (complete input) → Categorize as specific intent or general_chat based on content ✅ End
  └─ From Step 5 (unable to complete) → Proceed to Step 8

Step 8: Final Confirmation as need_confirm_again
  ↓
  ⚠️ Reconfirm all the following conditions are met:
  - ✅ User question indeed lacks key information (order number/SKU/destination, etc.) or uses ambiguous reference
  - ✅ Last 2 turns of recent_dialogue have **absolutely no** related entities (or only category/brand)
  - ✅ memory_bank Active Context **also has no** available information (or only category/brand)
  - ✅ User question is **not** a direct follow-up/response to previous AI reply
  ↓
  All satisfied → Categorize as need_confirm_again
  Set: resolution_source = "unable_to_resolve"
       clarification_needed = [specific inquiry about missing information]
       confidence = Set based on situation:
         • 0.5-0.65: Ambiguous reference (intent direction clear, e.g., "latest model")
         • 0.4-0.5: Completely ambiguous (e.g., isolated keyword "return")
       entities.ambiguous_terms = [list ambiguous terms] (if applicable)
  ✅ End
```

## Decision Flow Key Checkpoints

### Checkpoint 1: Is it a response to AI question?
```
Is the last turn of recent_dialogue an AI clarification question?
  → Yes: Current user input must be treated as response to that question
  → Associate response with original question, complete intent
```

### Checkpoint 2: Is it a continuous follow-up?
```
User input appears to lack subject, but:
  → recent_dialogue just discussed a certain entity (order/product/topic)
  → Current user input is a follow-up about that entity
  → Inherit that entity, categorize as explicit intent
```

### Checkpoint 3: Really unable to complete?
```
Before categorizing as need_confirm_again, must confirm:
  ✅ Checked last 2 turns of recent_dialogue - not found
  ✅ Checked Active Context - also not found
  ✅ User is not answering AI's question
  ✅ User is not following up on previously discussed content
```

---

# Output Requirements

**Key Constraints**:
- ✅ Output only raw JSON, do not use Markdown code blocks (no ```json)
- ✅ Return fields directly at root level, do not wrap in "output" or other keys
- ✅ Output must be directly parsable valid JSON

## JSON Structure

```json
{
  "intent": "handoff|query_user_order|query_product_data|query_knowledge_base|need_confirm_again|general_chat",
  "confidence": 0.0-1.0,
  "entities": {},
  "resolution_source": "user_input_explicit|recent_dialogue_turn_n_minus_1|recent_dialogue_turn_n_minus_2|active_context|unable_to_resolve",
  "reasoning": "Brief explanation (≤50 words)",
  "clarification_needed": []
}
```

## Field Descriptions

**intent** (required): One of six intent types

**confidence** (required): Confidence score (0.0-1.0)

| Range | Level | Use Case | Typical Characteristics |
|------|------|---------|---------|
| **0.9-1.0** | Very High | • Explicit intent + complete parameters<br/>• OR successfully completed key entities from context | • User provides order number/SKU<br/>• OR pronouns can be clearly resolved from recent_dialogue<br/>• handoff explicit trigger words |
| **0.7-0.89** | High | • Intent clear but requires inference<br/>• Completed from Active Context | • Continuous follow-up, inheriting context<br/>• Active Context has entity but not from recent dialogue |
| **0.5-0.69** | Medium | • **Ambiguous reference with no context**<br/>• Intent direction clear but lacks key parameters | • "latest model" without specific model<br/>• "some accessories" without product info<br/>• Context only has category/brand, no specific model |
| **0.4-0.5** | Medium-Low | • Intent ambiguous, needs broad clarification | • Isolated keywords: "return", "invoice"<br/>• Overly broad: "What products do you have?" |
| **0.0-0.39** | Low | • Completely unable to determine intent | • Gibberish, meaningless input<br/>• Extremely vague chat |

**⚠️ Special Note**:
- **Ambiguous reference (e.g., "latest model") with no context** → confidence should be **0.5-0.65**, cannot be >0.7
- **Successfully completed from context** → confidence can reach **0.85-0.95** (due to inference)
- **User explicitly provides all information** → confidence should be **0.95-1.0**

**entities** (optional): Structured entities extracted based on intent type
**resolution_source** (required): Information source traceability
**reasoning** (required): Judgment basis (1-2 sentences, no more than 50 words)
**clarification_needed** (optional): Required only for need_confirm_again

## Output Format Examples

✅ **CORRECT** (direct JSON output, no code blocks, no wrapping):
```
{
  "intent": "query_user_order",
  "confidence": 0.95,
  "entities": {
    "order_number": "V25121000001",
    "query_type": "shipping",
    "context_inherited": true
  },
  "resolution_source": "recent_dialogue_turn_n_minus_1",
  "reasoning": "Identified order number from previous turn, current query about delivery time"
}
```

❌ **INCORRECT** (with code blocks / wrapper keys / containing other text)

## Special Cases

**Multiple Intent Mix**: Select highest priority intent
**Boundary Ambiguity**: confidence < 0.7 categorize as `need_confirm_again`
**Context Break**: Topic switch or exceeding 5 minutes do not use old context

## Quality Checklist

- [ ] Direct raw JSON output, no code blocks, no wrapper keys
- [ ] `intent` is one of six types
- [ ] `confidence` is between 0.0-1.0
- [ ] `reasoning` ≤50 words
- [ ] When `need_confirm_again`, has `clarification_needed`
- [ ] JSON is parsable, no comments
