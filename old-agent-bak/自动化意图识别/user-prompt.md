<!-- ================= 上下文数据 ================= -->
<context_data>
<user_profile>
频道：{{ $('Code in JavaScript1').first().json.channel }}
登录状态：{{ $('Code in JavaScript1').first().json.isLogin }}
</user_profile>

<conversation_history>
{{ $('Code in JavaScript').first().json.history_context }}
</conversation_history>
</context_data>

<!-- ================= 当前请求 ================= -->
<current_request>
{{ $('Code in JavaScript1').first().json.ask }}
</current_request>

<!-- ================= 分析任务 ================= -->
您必须通过分析用户的意图来确定正确的路由分支。

⚠️ 重要说明
您必须**结合当前请求和对话历史记录**来分析意图。
请勿仅根据当前句子判断意图。

用户可能会将一个请求拆分成多条消息。
订单号、SKU、产品名称或类别可能出现在之前的对话中。

请遵循以下决策流程：

步骤 1 — 业务检查
- 如果请求与跨境电商无关 → `general_chat_or_handoff`

步骤 2 — 清晰度检查
- 请求是否模糊、含糊不清或缺少必要的标识符？
- 如果是 → `clarify_intent`

步骤 3 — 意图匹配
A) 订单相关请求
- 存在订单号 → `query_user_order`
- 缺少订单号 → `clarify_intent`

B) 产品相关请求
- 存在任何 SKU/产品名称/产品描述/产品类型/关键词 → `query_product_data`
- 缺少产品信息 → `clarify_intent`

C) 一般信息或政策 → `query_knowledge_base`

步骤 4 — 安全检查
- 如果您是猜测或不确定 → `clarify_intent`

---
## 输出要求（重要）

**仅**输出有效的原始 JSON 对象。
请勿包含 Markdown 代码块或任何其他文本。 ## 输出格式（严格 JSON 格式）

{
"thought": "基于上下文和规则的简要推理",
"intent": "query_user_order | query_product_data | query_knowledge_base | clarify_intent | general_chat_or_handoff",
"missing_info": "如果意图是 clarify_intent，则此处填写所需信息，否则为空",
"reason": "选择此意图的原因"
}