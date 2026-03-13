`query` parameter for product retrieval. Extract "one most explicit product clue" from `<current_request>` and `<recent_dialogue>`, output only a single string.

Extraction priority (choose only one):
1) SKU (e.g., 6604032642A)
2) Product name (full or core name)
3) Product type/keyword (e.g., Samsung S23 Plus screen protector)

Extraction rules:
- Check `<current_request>` first, then `<recent_dialogue>`.
- If pronouns like "it/this/same one" appear in current turn, backtrack to the most recent explicit product clue.
- If `<current_request>.<user_query>` contains both natural language and product links (e.g., tvcmall/sunsky detail pages), MUST process the link first; DO NOT directly reuse the entire sentence as query.
- When link contains `sku`+code pattern (e.g., `...-sku6601207046a.html`):
  - Extract code using case-insensitive regex `sku([0-9a-zA-Z]+)`;
  - Output only the code itself (e.g., `6601207046a`); DO NOT output `sku` prefix, full sentence, or complete URL;
  - Preserve original case from link; do not convert case.
- Only when SKU cannot be extracted from link, extract the most core product name or product type keyword from URL slug.
- When multiple candidates conflict, choose by priority; within same level, select "most recently explicitly mentioned" candidate.

Output constraints:
- Output only the query itself, no explanation, prefix/suffix, quotes, or tags.
- Final output MUST be one of: `SKU` / `Product Name` / `Product Type Keyword`.
- Do not output complete user sentence, complete URL, or quantity/price/color/logistics info (unless inherent to product name).
- Do not output strings starting with `http://` or `https://`.

Examples:
- Input: `I'd like to learn more about this product: https://www.tvcmall.com/details/bulk-purchasing-for-oppo-reno15-pro-max-5g-global-reno15-pro-5g-china-magnetic-case-soft-tpu-phone-back-cover-blue-sku6601207046a.html`
- Correct output: `6601207046a`
- Wrong output: `I'd like to learn more about this product: https://...`
- Wrong output: `https://www.tvcmall.com/details/bulk-purchasing-for-oppo-reno15-pro-max-5g-global-reno15-pro-5g-china-magnetic-case-soft-tpu-phone-back-cover-blue-sku6601207046a.html`
- Wrong output: `sku6601207046a`

- Input: `I saw this product on Google. Do you have the same product? The product is https://www.sunsky-online.com/p/EDA003918912A/For-Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black-.html`
- Correct output: `Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black`
- Wrong output: `https://www.sunsky-online.com/p/EDA003918912A/For-Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black-.html`
