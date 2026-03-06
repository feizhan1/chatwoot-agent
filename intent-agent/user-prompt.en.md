Please use the following hierarchical information to understand the user request and strictly route the intent according to the system prompt rules.

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
    1. **Current Turn Priority**: Only use `<user_query>` as the current turn's `working_query`; do not substitute with historical dialogue.
    2. **Extract Entities Before Intent Classification**: Complete order numbers, SKUs, product keywords, destinations, etc. in the following order: `current_request -> recent_dialogue (last 1-5 turns) -> active_context`.
    3. **MUST Override When Current Turn Negates Old Entities**: If user says "not the previous order/change to another", immediately discard old entities and prioritize the current turn's latest expression.
    4. **STRICT Routing Order**: `handoff_agent` -> `order_agent/product_agent` strong signal separation -> `business_consulting_agent` -> `confirm_again_agent` -> `no_clear_intent_agent`.
    5. **Image Routing Hard Rules**:
       - Has `image_data` AND clear product request (price/stock/similar item/specs/shipping) -> `product_agent`
       - Only image OR image-text with unclear goal and cannot be completed -> `confirm_again_agent`, fill `product_goal` in `missing_info`
    6. **Confirm Trigger Condition**: Use `confirm_again_agent` only when business direction is clear but lacks critical parameters and context cannot complete them.
    7. **missing_info Standard Keys Only**: `order_number`, `tracking_number`, `sku_or_keyword`, `product_goal`, `destination_country`, `business_topic`; concatenate multiple keys with commas without spaces.
    8. **Output Contract**: Only output JSON with exactly four fields: `thought`, `intent`, `missing_info`, `reason`; `intent` must be one of six options.
    9. **Field Constraints**:
       - `thought`: One sentence of evidence summary, no lengthy reasoning
       - `missing_info`: Non-empty only when `intent=confirm_again_agent`, MUST be `""` for other intents
       - `reason`: MUST specify "triggered step + rule"
</instructions>
