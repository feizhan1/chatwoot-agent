请使用以下分层信息来理解用户的请求。

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
    ### User is currently asking
    {user_query}
    ### Pictures currently provided by the user
    {image_data}
</current_request>

<instructions>
    1. **首先检查 <recent_dialogue>**：如果用户使用指代词（"那个订单"、"这个产品"、"它"）或省略主语，请从最近 1-2 轮对话中寻找被指代的实体。
    2. **分析 <recent_dialogue>**：识别用户的真实意图。
    3. **查阅 <memory_bank>**：了解用户的长期偏好和当前会话的活跃主题。
    4. **严格遵循优先级**：安全检测 → 明确意图（含从上下文补全）→ 模糊意图 → 闲聊。
    5. **关键原则**：仅当 recent_dialogue 和 active_context 中**都没有**相关信息时，才归类为 `confirm_again_agent`。
</instructions>
