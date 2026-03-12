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
将此视为**与订单相关的请求**。

重要提示：
- 您必须**结合当前查询和对话历史记录**进行分析。
- 用户可能会在多条消息中提供订单号、追踪号或表达请求意图。
- 如果存在多个订单号或追踪号，请使用**最新且最相关的那个**。

严格遵守系统消息规则：
- 检查登录状态
- 从当前消息和历史记录中检测订单号
- 如果存在订单号，则调用订单工具进行查询
- 使用正确的场景进行回复
- 只回答用户明确提出的问题