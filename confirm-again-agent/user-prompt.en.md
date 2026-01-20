Please use the following context information to process the user's request.

<context_data>
    <user_profile>
        Channel: {{ $('Code in JavaScript1').first().json.channel }}
        Login Status: {{ $('Code in JavaScript1').first().json.isLogin }}
    </user_profile>

    <conversation_history>
        {{ $('Code in JavaScript').first().json.history_context }}
    </conversation_history>
</context_data>

<current_request>
    <user_query>
        {{ $('Code in JavaScript1').first().json.ask }}
    </user_query>
</current_request>

<instructions>
    1. Analyze <user_query> and <conversation_history> to identify **specifically what information is missing**.
    2. Check <user_profile> to personalize tone (e.g., if logged in, reference their account context as appropriate).
    3. **Do not answer the business question yet.**
    4. Based on the missing information, generate a **helpful follow-up question** to clarify user intent.
       (e.g., "Could you please provide the order number?" or "Which specific product model are you referring to?")
</instructions>
