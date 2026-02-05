Provide the user with the option to contact human customer service (display a "Transfer to Agent" button in the chat interface)

**Tool Behavior**:
- After invocation, a "Transfer to Agent" button will be displayed in the user's chat interface
- Users can choose to click the button to contact a human agent, or choose not to click
- This provides an opportunity, not a forced transfer

**Applicable Scenarios**:
1. Business negotiations (price negotiation, bulk purchasing, customization needs, agency applications)
2. Technical support (manual downloads, complex technical specifications, product modifications)
3. Special services (custom packaging, certification reports, special logistics arrangements)
4. Complaint handling (strong emotions, explicit request for human transfer, quality disputes)
5. Complex mixed scenarios (multiple mixed needs, tool returns empty values, continuous user dissatisfaction)

**Post-Invocation Behavior**:
- The tool will automatically return handoff phrases (translated to the user's language)
- Use the tool output directly; DO NOT add extra content or product recommendations

**CRITICAL Constraints**:
- Invoke immediately upon scenario recognition; DO NOT attempt to answer business negotiation/technical support/complaint questions
- DO NOT promise discounts/offers; DO NOT add product recommendations after invocation
- Use the standard phrases returned by the tool
