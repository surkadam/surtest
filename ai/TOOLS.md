# Agent Tools Documentation

Documents the tools exposed by the fraud-assistant agent (`ai/assistant.py`).

| Tool | Purpose | Authorized roles |
|---|---|---|
| `classify_transaction` | Score a transaction for fraud likelihood | fraud-analyst |
| `fetch_transaction` | Retrieve a transaction record by ID | fraud-analyst |
| `generate_report` | Produce a summary report of flagged transactions | fraud-analyst, auditor |

All tool invocations are authorized via the OPA policy engine
(`ai/tool_policy.opa`), logged at invocation level, and rate-limited.
System prompts are version-controlled in `ai/prompts/system_prompt.txt`.
