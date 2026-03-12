# AI Response Condensation Task

## Original AI Response to be Condensed

{input_text}

---

**Task Description**:
1. Only perform faithful condensation of the AI's original response.
2. If `max_chars` is empty or invalid, process with 120 characters.
3. Judge length by Unicode character count.
4. If original text does not exceed the limit, return original text directly.
5. Only output the final condensed text, do not add explanations or prefixes.
