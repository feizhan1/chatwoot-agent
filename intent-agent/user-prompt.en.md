Please use the following layered information to understand the user request and strictly complete intent routing according to the system prompt rules.

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
    1. **Current Turn Priority**: Only use `<user_query>` as the current turn's `working_query`; do not replace current input with historical dialogue.
    2. **Extract Entities Before Determining Intent**: Complete order numbers, SKUs, product keywords, destination countries, etc. in the order of `current_request -> recent_dialogue (last 1-5 turns) -> active_context`.
    3. **MUST Override When Current Turn Negates Old Entities**: If "not the previous order/change to another one", immediately discard old entities and use the latest expression from current turn.
    4. **STRICT Routing Order**: `handoff_agent` (Step 1) -> `business_consulting_agent` (Step 2) -> `order_agent/product_agent` strong signal split (Step 3) -> `confirm_again_agent` (Step 4) -> `no_clear_intent_agent` (Step 5).
    5. **Confirm Trigger Condition**: Only use `confirm_again_agent` when business direction is clear but missing key parameters that cannot be completed from context.
    6. **missing_info MUST Use Standard Keys Only**: `order_number`, `tracking_number`, `sku_or_keyword`, `product_goal`, `destination_country`, `business_topic`; concatenate multiple keys with commas without spaces.
    7. **Output Contract**: Output JSON only, containing exactly six fields: `thought`, `intent`, `detected_language`, `language_code`, `missing_info`, `reason`; `intent` MUST be one of six options.
    8. **Field Constraints**:
       - `thought`: Output the reasoning process for intent determination (1-2 sentences), reflecting key judgment basis
       - `detected_language` & `language_code`: Identify based ONLY on current turn's `<user_query>`, DO NOT directly assign from `session_metadata`
       - `missing_info`: Non-empty ONLY when `intent=confirm_again_agent`, MUST be `""` for other intents
       - `reason`: MUST specify "matched step + rule"
</instructions>
