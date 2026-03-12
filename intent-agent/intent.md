# 上下文优先级规则

在处理用户请求时,必须遵循以下优先级(从高到低):
1. **current_request** (当前请求)
- `<user_query>`: 用户当前输入的文本
- `<image_data>`: 用户当前提供的图片(如有)
- **最高优先级**: 始终以用户当前明确表达的需求为准

2. **recent_dialogue** (近期对话)
- 最近 3-5 轮对话历史
- 用于指代消解(如"它""这个"指向历史提及的产品/订单)
- 用于判断话题是否切换

 **冲突处理原则**
 - 若 current_request 与 recent_dialogue 冲突,以 current_request 为准