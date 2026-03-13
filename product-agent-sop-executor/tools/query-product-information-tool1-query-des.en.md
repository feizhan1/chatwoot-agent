The `query` parameter for product retrieval. Extract "one most explicit product clue" from `<current_request>` and `<recent_dialogue>`, output only a single string.

Extraction Priority (select only one):
1) SKU (e.g., 6604032642A)
2) Product Name (full or core name)
3) Product Type/Keyword (e.g., Samsung S23 Plus screen protector)

Extraction Rules:
- Check `<current_request>` first, then `<recent_dialogue>`.
- If pronouns like "it/this/same one" appear in current turn, backtrack to the most recent explicit product clue.
- If product links (e.g., tvcmall/sunsky detail pages) appear, prioritize extracting clues from the link; do not use entire natural language sentence as query.
- When link contains `sku` + code (e.g., `...-sku6601207046a.html`):
  - Use regex `sku([0-9a-zA-Z]+)` to extract the code;
  - Output only the code itself (e.g., `6601207046a`), DO NOT output `sku` prefix, full sentence, or full URL;
  - Preserve original case from link, do not convert case.
- When link has no SKU, extract the most core product name or product type keyword from URL slug.
- When multiple candidates conflict, select by priority; within same level, select the "most recently explicitly mentioned" candidate.

Output Constraints:
- Output only the query itself, no explanations, prefixes/suffixes, quotes, or tags.
- Final output must be one of three types: `SKU` / `Product Name` / `Product Type Keyword`.
- Do not output complete user sentence, complete URL, or non-retrieval information like quantity, price, color, logistics (unless inherently part of product name).

Example:
- Input: `I'd like to learn more about this product: https://www.tvcmall.com/details/...-sku6601207046a.html`
- Correct Output: `6601207046a`
- Incorrect Output: `I'd like to learn more about this product: https://...`
