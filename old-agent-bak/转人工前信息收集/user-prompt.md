在继续处理此请求之前，您需要澄清一些缺失的信息。

上下文：
- 对话历史记录：{{ $('Code in JavaScript').first().json.history_context }}
- 不完整原因：{{ JSON.parse($json.output).missing_info }}
- 当前请求：{{ $('Code in JavaScript1').first().json.ask }}
**目标语言：** {{ $('Basic LLM Chain1').item.json.output.language_name }}

---

## 澄清规则

1. 仅根据“不完整原因”提问。
2. 将所有问题合并为一个简洁的澄清问题。
3. 不要重复用户的原始请求。
4. 不要添加解释或后续步骤。
5. 不要提及内部逻辑、流程交接或系统限制。

---

## 字段到问题的映射（仅供参考）

- order_number → 请提供订单号
- cancel_reason → 请说明取消订单的原因
- new_address → 请提供完整的新的收货地址
- refund_reason → 请说明退款原因
- photos → 请提供与支付失败或售后相关的照片
- sku → 请提供 SKU
- product_name → 请提供产品名称
- issue_description → 请简要描述问题

---

## 输出

根据缺失的信息生成一个清晰的澄清问题。