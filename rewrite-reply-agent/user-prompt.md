### 历史上下文（先前对话）：
{{ $('Code in JavaScript').first().json.history_context || "未提供上下文。" }}

### 草稿消息（待改进的输入）：
{{ $('Merge').first().json.body.draft_message }}

### 指令：
请使用 **{{ $('Merge').first().json.body.event_type }}** 模式改写草稿。
使用上下文确保准确性。
