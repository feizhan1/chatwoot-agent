Please use the following hierarchical information to understand the user's request.

<session_metadata>
    Channel: {{ $('Code in JavaScript1').first().json.channel }}
    Login Status: {{ $('Code in JavaScript1').first().json.isLogin }}
</session_metadata>

<memory_bank>
    {{ $('Code in JavaScript10').first().json.final_memory_context }}
</memory_bank>

<recent_dialogue>
    {{ $('Code in JavaScript').first().json.history_context }}
</recent_dialogue>

<current_request>
    <user_query>
        {{ $('Code in JavaScript1').first().json.ask }}
    </user_query>
</current_request>

<instructions>
    1. Analyze the <user_query>.
    2. Note that your system prompt specifies strict response policies, regardless of context.
    3. Output the required response in the target language.
</instructions>
