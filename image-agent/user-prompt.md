请使用以下上下文信息来分析图片内容并识别用户意图。

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
    {recent_dialogue}
</recent_dialogue>

<current_request>
    <user_query>
        {user_query}
    </user_query>

    <image_data>
        [图片内容 - 由 gemini-2.5-flash-image 多模态模型直接处理]
    </image_data>
</current_request>

<instructions>
    1. **首先分析 <image_data>**:识别图片类型(商品图/订单截图/投诉证据/业务咨询/其他)
    2. **结合 <user_query>**:理解用户文字描述与图片的关系
    3. **检查 <recent_dialogue>**:查找最近 1-2 轮是否有相关上下文
    4. **查阅 <memory_bank>**:从 Active Context 补全信息(如有)
    5. **严格遵循系统提示词中的优先级规则**
    6. **CRITICAL**:仅当图片内容模糊 + 文字模糊/无文字 + recent_dialogue 和 active_context 都无相关信息时,才归类为 confirm_again_agent
</instructions>
