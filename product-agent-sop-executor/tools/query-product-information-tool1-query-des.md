用于商品检索的 `query` 参数。请从 `<current_request>` 和 `<recent_dialogue>` 中提取“一个最明确的产品线索”，仅输出一个字符串。

提取优先级（只选一项）：
1) SKU（例：6604032642A）
2) 产品名称（完整名或核心名）
3) 产品类型/关键词（例：Samsung S23 Plus screen protector）

提取规则：
- 先看 `<current_request>`，再看 `<recent_dialogue>`。
- 若本轮出现“它/这个/同款”等代词，回溯最近一次明确产品线索。
- 若 `<current_request>.<user_query>` 同时出现自然语言与商品链接（如 tvcmall/sunsky 详情页），必须先处理链接，不得直接复用整句作为 query。
- 链接中命中 `sku`+编号时（如 `...-sku6601207046a.html`）：
  - 使用大小写不敏感正则 `sku([0-9a-zA-Z]+)` 提取编号；
  - 仅输出编号本体（如 `6601207046a`），禁止输出 `sku` 前缀、整句、或整条 URL；
  - 保持链接中的原始大小写，不做大小写转换。
- 仅当链接提取不到 SKU 时，才提取 URL slug 中最核心的产品名称或产品类型关键词。
- 多个候选冲突时，按优先级选择；同级选择“最近一次明确出现”的候选。

输出约束：
- 只输出 query 本身，不加解释、前后缀、引号、标签。
- 最终输出必须是以下三者之一：`SKU` / `产品名称` / `产品类型关键词`。
- 不输出完整用户句子，不输出完整 URL，不输出数量、价格、颜色、物流等非检索主线信息（除非是产品名固有组成）。
- 不输出以 `http://` 或 `https://` 开头的字符串。

示例：
- 输入：`I’d like to learn more about this product: https://www.tvcmall.com/details/bulk-purchasing-for-oppo-reno15-pro-max-5g-global-reno15-pro-5g-china-magnetic-case-soft-tpu-phone-back-cover-blue-sku6601207046a.html`
- 正确输出：`6601207046a`
- 错误输出：`I’d like to learn more about this product: https://...`
- 错误输出：`https://www.tvcmall.com/details/bulk-purchasing-for-oppo-reno15-pro-max-5g-global-reno15-pro-5g-china-magnetic-case-soft-tpu-phone-back-cover-blue-sku6601207046a.html`
- 错误输出：`sku6601207046a`

- 输入：`I saw this product on Google. Do you have the same product? The product is https://www.sunsky-online.com/p/EDA003918912A/For-Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black-.html`
- 正确输出：`Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black`
- 错误输出：`https://www.sunsky-online.com/p/EDA003918912A/For-Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black-.html`
