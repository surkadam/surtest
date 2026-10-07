package agent.authorization

import future.keywords

# OPA policy — tool authorization for AI agents (safety.policy_engine)
default allow = false

allow {
    input.agent_id == "fraud-assistant-001"
    tool_authorized[input.tool]
}

tool_authorized = {
    "classify_transaction",
    "fetch_transaction",
    "generate_report",
}
