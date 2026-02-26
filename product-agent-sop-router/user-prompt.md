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
    {recent_dialogue}
</recent_dialogue>

<current_request>
    <user_query>
        {user_query}
    </user_query>
   <image_data>
        {image_data}
    </image_data>
</current_request>

<current_system_time>{{ $now.format('yyyy-MM-dd') }}</current_system_time>

<instructions>
    请严格遵循系统提示词中的规则，分析上述提供的 XML 数据上下文。
    匹配最合适的 SOP。
    请直接输出 JSON，不要添加任何额外的解释性文字。
</instructions>
