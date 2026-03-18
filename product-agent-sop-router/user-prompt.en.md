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
    The following cases are treated as "no image input": null, empty string, empty array, invalid URL, placeholder text only (e.g., "N/A").

    ### Query extraction hints
    Prioritize identifying from <user_query>: product identifiers (SKU/product name/link), attribute words (price/MOQ/brand, etc.), action words (search/recommend/compare/customize/shipping/order process, etc.).
</input_normalization>

<current_system_time>
    ### current system time
    {current_system_time}
</current_system_time>
