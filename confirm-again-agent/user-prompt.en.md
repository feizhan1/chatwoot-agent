Please use the following context information to process the user's request.

<session_metadata>
    Channel: {channel}
    Login Status: {login_status}
    Target Language: {target_language}
    Language Code: {language_code}
</session_metadata>

<recent_dialogue>
    {recent_dialogue}
</recent_dialogue>

<current_request>
    <user_query>
        {user_query}
    </user_query>
</current_request>

<instructions>
    1. Analyze <user_query> and <recent_dialogue>, identify **what specific information is missing**.
    2. Check <session_metadata> to personalize tone (e.g., if logged in, reference their account context as appropriate).
    3. **Do not answer business questions yet.**
    4. Based on the missing information, generate a **helpful follow-up question** to clarify user intent.
       (e.g., "Could you please provide the order number?" or "Which specific product model are you referring to?")
</instructions>
