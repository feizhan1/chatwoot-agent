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

    ### Query extraction hints
    从 <user_query> 中优先识别：产品标识（SKU/产品名/链接）、属性词（价格/MOQ/品牌等）、动作词（搜索/推荐/比较/定制/运费/下单流程等）。
</input_normalization>

<current_system_time>
    ### current system time
    {current_system_time}
</current_system_time>

<instructions>
    请严格遵循系统提示词中的规则，分析上述提供的 XML 数据上下文。
    匹配最合适的 SOP。
    如果信息不足以唯一定位产品，不要输出澄清问句；请按系统提示词路由到兜底 SOP，并将 extracted_product_identifier 置为 null。
    请直接输出 JSON，不要添加任何额外的解释性文字。
</instructions>
