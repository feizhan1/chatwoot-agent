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
    ### Latest conversations
    {recent_dialogue}
</recent_dialogue>

<current_request>
    ### User is currently asking
    <user_query>{user_query}</user_query>
    ### Pictures currently provided by the user
    <image_data>{image_data}</image_data>
</current_request>

<current_system_time>
    ### current system time
    {current_system_time}
</current_system_time>

<instructions>
    1. **先看 <current_request>**：仅以 `<user_query>` 作为当前轮 `working_query`，先判断本轮意图，不要用历史对话替代当前输入。
    2. **再做指代补全**：若 `working_query` 出现指代词（"那个订单"、"这个产品"、"它"）或省略主语，先从 `<recent_dialogue>` 最近 1-2 轮补全实体（订单号 / SKU / SPU / 明确主题）。
    3. **最后查 <memory_bank>**：仅在 recent 1-2 轮无法补全时，再使用 `active_context` 兜底；`user_profile` 只用于偏好理解，不可替代业务实体。
    4. **严格遵循路由优先级**：`handoff_agent`（安全/人工）→ 明确业务意图（`order_agent` / `product_agent` / `business_consulting_agent`）→ 参数不足待补全（`confirm_again_agent`）→ 无明确业务意图（`no_clear_intent_agent`）。
    5. **`confirm_again_agent` 必须同时满足 4 条**：当前请求缺关键参数 + recent_dialogue 无可继承实体 + active_context 无可用实体 + 当前消息不是对 AI 上一轮澄清问题的直接回答。
    6. **关键约束**：只要上下文能补全到明确实体，禁止因为“当前句未出现实体”直接判为 `confirm_again_agent`。
    7. **定制/样品分流硬规则**：若用户提到定制/样品/OEM/ODM/Logo，且能定位到具体产品（SKU/SPU/型号/明确产品名），必须判为 `product_agent`；只有在无具体产品目标时才判为 `business_consulting_agent`。
    8. **示例校准**：`I'd like to order a custom iPhone 17 case with a picture printed on the back` → `product_agent`（不是 `business_consulting_agent`）。
</instructions>
