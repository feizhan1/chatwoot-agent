# image-agent 提示词编写任务说明（用于撰写 system-prompt / user-prompt）

## 1. 文档目的
本文件不是运行时提示词，而是“写提示词的规范”。
目标：指导生成稳定、可执行、可校验的 image-agent system-prompt 和 user-prompt。

## 2. 输入上下文约定
编写的 user-prompt 必须向 system-prompt 提供以下上下文块：
- `<session_metadata>`：`channel`、`login_status`、`target_language`、`language_code`
- `<memory_bank>`：`user_profile`、`active_context`
- `<recent_dialogue>`：最近 3-5 轮对话
- `<current_request>`：`user_query`（可能为空）
- `<image_data>`：用户当前图片 URL 或图片数据（可能为空）

## 3. 关键信息提取规则（图片侧）
- 必须尝试提取：`sku/spu`、商品名称（若可识别）。
- SKU 识别规则：`^\d{10}[A-Z]$`（10 位数字 + 1 位大写字母），示例：`6601167986A`
- SPU 识别规则：`^\d{9}$`（9 位纯数字），示例：`661100272`
- 同时识别到 SKU 与 SPU：SKU 作为主标识，SPU 作为补充信息。
- 无法识别时不得编造，字段留空并降低置信度。

## 4. “商品咨询相关”统一定义
命中任一即视为商品咨询相关：
1. 用户询问具体商品动作：价格、库存、规格、MOQ、材质、兼容性、替代品、型号对比等。
2. 用户或图片中出现可定位商品实体：SKU/SPU/商品名/型号。
3. 用户表达以图搜图诉求：找同款、识别图中商品、按图找货。
4. 当前句出现代词或省略（这个/它/这款），但 `recent_dialogue` 可补全到明确商品实体。

非商品咨询相关（示例）：
1. 纯订单问题：订单状态、物流、取消、售后进度。
2. 纯政策或流程：支付方式、物流政策、退换规则、账号规则。
3. 闲聊、问候、无业务语义。

## 5. user_query 非空场景规则
当 `user_query` 非空时：
- 优先使用 `user_query` 判断诉求类型。
- `recent_dialogue` / `active_context` 仅用于补全实体和消歧。
- 若判定“商品相关但动作不明确”，输出澄清意图文案：
  `用户可能想xxx，需要向用户澄清`
- `xxx` 填充优先级：
  1) `咨询 SKU {sku} 的{诉求}`
  2) `咨询 SPU {spu} 的{诉求}`
  3) `咨询{商品名}的{诉求}`
  4) `咨询某个商品的{诉求}`

## 6. user_query 为空场景规则
当 `user_query` 为空时：
- 禁止使用“从 `user_query` 提取诉求”的方式。
- 诉求来源优先级：
  1) `recent_dialogue` 最近 1-2 轮中的明确诉求词；
  2) `image_data` 中可识别商品线索对应的常见诉求；
  3) 若仍无法判断，统一写“具体信息”。
- 若商品相关，输出：
  `用户可能想xxx，需要向用户澄清`
  其中 `xxx` 仍按 `SKU > SPU > 商品名 > 某个商品`。
- 若不相关，输出：
  `用户无明确意图`

## 7. system-prompt 编写要求
编写出的 system-prompt 必须明确：
1. 角色与任务边界：只能做意图识别和路由，不直接回答业务问题。
2. 输入使用优先级与上下文边界（哪些用于判定、哪些用于补全）。
3. 单一路由流程与优先级（投诉/订单/业务咨询/商品咨询/澄清/无明确意图）。
4. 严格输出约束（仅 JSON、字段必填、不可编造）。
5. 语言规则（内容随目标语言输出；SKU/SPU/订单号/品牌型号不翻译）。
6. 澄清触发条件（仅“业务相关但动作不明确”时进入澄清意图）。

## 8. user-prompt 编写要求
编写出的 user-prompt 必须：
1. 完整注入结构化上下文（`session_metadata`、`memory_bank`、`recent_dialogue`、`current_request`、`image_data`）。
2. 明确提醒模型按 system-prompt 的单一流程决策。
3. 显式区分 `user_query` 非空与为空两种分支。
4. 避免在 user-prompt 中重复定义与 system-prompt 冲突的规则。

## 9. 质量自检清单
- SKU/SPU 正则是否与本规范一致。
- “商品相关/非相关”定义是否完整且无冲突。
- `user_query` 为空场景是否禁用了 `user_query` 诉求提取。
- 澄清文案模板是否统一为：`用户可能想xxx，需要向用户澄清`。
- 兜底文案是否统一为：`用户无明确意图`。
- system-prompt / user-prompt 的职责是否清晰分离。
