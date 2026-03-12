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

<analysis_task>

您必须通过分析用户的意图来确定正确的路由分支。

⚠️ 重要说明
您必须结合**当前请求和对话历史记录**来分析用户的意图。
切勿仅凭当前句子来判断意图。

用户可能会将一个请求拆分成多条消息。
订单号、SKU、产品名称或类别可能出现在之前的对话中。

您的任务：
1. 利用完整的上下文识别用户的真实意图。
2. 确定路由分支：
- automation_only（仅自动化处理）
- direct_handoff（直接转接人工客服）
- collect_info_then_handoff（收集信息后转接人工客服）
3. 如果选择 collect_info_then_handoff，请确定缺少哪些关键信息。

请严格遵守系统消息规则。

</analysis_task>