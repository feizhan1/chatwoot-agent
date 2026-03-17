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
    The following cases are all treated as "no image input": null, empty string, empty array, invalid URL, placeholder text only (e.g., "N/A").

    ### Query extraction hints
    From <user_query>, prioritize identifying: product identifiers (SKU/product name/link), attribute terms (price/MOQ/brand, etc.), action verbs (search/recommend/compare/customize/shipping/order process, etc.).
</input_normalization>

<current_system_time>
    ### current system time
    {current_system_time}
</current_system_time>

<instructions>
    Strictly follow the rules in the system prompt and analyze the XML data context provided above.
    Match the most appropriate SOP.
    If there is insufficient information to uniquely locate a product, do not output a clarification question; route to the fallback SOP according to the system prompt and set extracted_product_identifier to null.
    Output JSON directly without any additional explanatory text.
</instructions>
