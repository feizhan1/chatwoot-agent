---
name: order-router-sop-triggering
description: Maintain the order-agent-sop-router SOP list so each value states its trigger conditions (order number presence, user intent, login/channel guardrails), and keep zh/en system prompts in sync when updating SOP summaries.
---

# Order Router SOP Triggering

## Overview
Keep the SOP list inside `order-agent-sop-router/system-prompt.md` (and `.en.md`) concise and trigger-driven. Use this when refining the “Available SOP List” section so each SOP value explains when it should fire, without altering other routing logic.

## Quick Workflow
- Open `order-agent-sop-router/system-prompt.md` and mirror changes in `order-agent-sop-router/system-prompt.en.md`.
- For each SOP entry, rewrite the value as “trigger conditions” (what user asks + whether an order/tracking number is present + any channel/login constraints + whether to hand off to human/tools).
- Keep numbering and SOP labels unchanged; avoid modifying other sections (decision flow, output format).
- Ensure zh/en wording match semantically; keep phrasing concise and action-oriented.

## Trigger Writing Guidelines
- SOP_1 is only for “no order/tracking number detected anywhere”; explicitly say it asks for the number and calls no tools.
- SOP_11 must mention `<session_metadata>.Login Status` not logged in AND channel not WhatsApp; no tools.
- Distinguish order-specific vs generic: SOP_8 is for generic freight/ETA without a specific order; others require an extracted order number.
- Capture typical intents: status/ETA (SOP_2), details link (SOP_3), cancel (SOP_4), modify/merge (SOP_5), payment error/refund/return (SOP_6), logistics issues needing human (SOP_7), shipment/transit delay complaints (SOP_9), pre-sale policy questions (SOP_10).
- Note required actions if applicable (e.g., hand off to human) but keep the list item to one concise sentence.

## File Touchpoints
- system prompt zh: `order-agent-sop-router/system-prompt.md`
- system prompt en: `order-agent-sop-router/system-prompt.en.md`
