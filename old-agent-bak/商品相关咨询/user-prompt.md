<!-- 用户上下文 -->
<user_profile>
频道：{{ $('Code in JavaScript1').first().json.channel }}
登录状态：{{ $('Code in JavaScript1').first().json.isLogin }}
</user_profile>

<conversation_history>
{{ $('Code in JavaScript').first().json.history_context }}
</conversation_history>

<!-- 当前查询 -->
<user_query>
{{ $('Code in JavaScript1').first().json.ask }}
</user_query>

<!-- 任务 -->
将此视为**产品相关请求**进行处理。

重要提示：
- 您必须**结合当前查询和对话历史记录**进行分析。
- 用户可能会询问之前提到的产品的后续问题。
- 如果出现多个 SKU 或产品关键词，请使用**最新且与上下文最相关的那个**。

严格遵守系统消息规则：
- 使用当前查询和历史记录识别产品。
- 确定查询类型（详细信息/关键字段/搜索）。
- 当产品可识别时，调用产品数据工具查询产品信息。
- 仅在没有明确的产品目标时才要求澄清。
- 使用正确的模板和格式进行回复。