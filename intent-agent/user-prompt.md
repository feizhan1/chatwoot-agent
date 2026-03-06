请使用以下分层信息理解用户请求，并严格按 system prompt 的规则完成意图路由。

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
    1. **当前轮优先**：仅将 `<user_query>` 作为本轮 `working_query`；不要用历史对话替代当前输入。
    2. **先提取实体再判意图**：按 `current_request -> recent_dialogue(最近1-5轮) -> active_context` 顺序补全订单号、SKU、产品关键词、目的地等。
    3. **若本轮否定旧实体必须覆盖**：如“不是上一个订单/换一个”，立即放弃旧实体，以本轮最新表达为准。
    4. **严格路由顺序**：`handoff_agent` -> `order_agent/product_agent` 强信号分流 -> `business_consulting_agent` -> `confirm_again_agent` -> `no_clear_intent_agent`。
    5. **图片分流硬规则**：
       - 有 `image_data` 且有明确商品诉求（价格/库存/同款/规格/运费） -> `product_agent`
       - 仅图片或图文目标不清且无法补全 -> `confirm_again_agent`，并在 `missing_info` 填 `product_goal`
    6. **confirm 触发条件**：业务方向明确但缺关键参数且上下文无法补全时，才用 `confirm_again_agent`。
    7. **missing_info 仅使用标准键**：`order_number`、`tracking_number`、`sku_or_keyword`、`product_goal`、`destination_country`、`business_topic`；多个键用英文逗号拼接且不加空格。
    8. **输出契约**：只输出 JSON，且仅包含 `thought`、`intent`、`detected_language`、`language_code`、`missing_info`、`reason` 六个字段；`intent` 必须是六选一。
    9. **字段约束**：
       - `thought`：输出意图判断的思考过程（1-2句），体现关键判断依据
       - `detected_language` 与 `language_code`：仅根据当前轮 `<user_query>` 识别，不使用 `session_metadata` 直接赋值
       - `missing_info`：仅在 `intent=confirm_again_agent` 时非空，其它意图必须为 `""`
       - `reason`：必须写明“命中步骤 + 规则”
</instructions>
