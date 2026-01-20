请使用以下分层信息来理解用户的请求。

<session_metadata>
    Channel: {channel}
    Login Status: {login_status}
    Target Language: {target_language}
    Language Code: {language_code}
</session_metadata>

<memory_bank>
    {memory_bank}
</memory_bank>

<recent_dialogue>
    {recent_dialogue}
</recent_dialogue>

<current_request>
    <user_query>
        {user_query}
    </user_query>
</current_request>

<instructions>
    1. **分析 <user_query>** 以识别业务问题（例如：运输、支付、政策）。
    2. **查阅 <memory_bank>** 以识别用户的**业务身份**（例如：批发商、代发货商、个人买家）或**地理位置**。
    3. **上下文化答案**：
       - 如果用户是 **Dropshipper（代发货商）**，在相关时强调"无 MOQ"和"API 支持"。
       - 如果用户是 **Wholesaler（批发商）**，强调"批量定价"和"定制化"。
    4. 直接使用目标语言回答。不得提及 XML 标签。
</instructions>
