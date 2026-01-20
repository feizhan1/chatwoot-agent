请使用以下分层信息来理解用户的请求。

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
    1. 分析 <user_query>。
    2. 注意你的系统提示词规定了严格的响应策略，无论上下文如何。
    3. 使用目标语言输出所需的响应。
</instructions>
