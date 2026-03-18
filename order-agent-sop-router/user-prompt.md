<session_metadata>
    Channel: {channel}
    Login Status: {login_status}
    Target Language: {target_language}
    Language Code: {language_code}
</session_metadata>

<memory_bank>
    ### User Long-term Profile (Historical Data)
    {user_profile}

    ### Active Context (Current Session Summary)
    {active_context}
</memory_bank>

<recent_dialogue>
    ### Latest conversations
    {recent_dialogue}
</recent_dialogue>

<current_request>
    ### User is currently asking
    <user_query>{user_query}</user_query>
    ### Pictures currently provided by the user
    <image_data>{image_data}</image_data>
</current_request>

<context_priority>
    ### Context priority for routing (high -> low)
    1) current_request
    2) recent_dialogue
    3) active_context
    4) user_profile
</context_priority>

<input_normalization>
    ### Image input normalization
    以下情况均视为“无图片输入”：null、空字符串、空数组、无效 URL、仅占位文本（如 "N/A"）。

    ### Order number extraction hints
    在订单相关场景下，优先从 <user_query> 提取订单号，再用 <recent_dialogue> 与 <active_context> 补充。
    有效订单号格式：
    1) M/V/T/R/S + 11-14 位数字
    2) M/V/T/R/S + 6-12 位字母数字
    3) 纯 6-14 位数字
    多个号码时，优先使用“当前消息最新提及 > 最近一条用户消息 > 最近一次客服-用户互动”。
</input_normalization>

<current_system_time>
    ### current system time
    {current_system_time}
</current_system_time>
