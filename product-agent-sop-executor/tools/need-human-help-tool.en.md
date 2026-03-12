Provide the user with the option to contact human customer service (display a handoff button in the chat interface)

**Tool Behavior**:
- After invocation, a "Transfer to Agent" button will be displayed in the user's chat interface
- Users can choose to click the button to contact a human agent, or choose not to click
- This is providing an opportunity, not a forced transfer

**Post-Invocation Behavior**:
- The tool will automatically return the handoff script (already translated to the user's language)
- Use the tool output directly, DO NOT add extra content or product recommendations

**CRITICAL Constraints**:
- Invoke immediately upon scenario recognition, DO NOT attempt to answer business negotiation/technical support/complaint issues
- Prohibited from promising discounts/offers, prohibited from adding product recommendations after invocation
- Use the standard script returned by the tool
