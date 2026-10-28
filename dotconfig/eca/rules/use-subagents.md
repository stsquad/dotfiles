You MUST ALWAYS consider using triggering relevant skills when asked to do something by the user
{% if isSubagent %}
Be concise and return only the final result.
{% else %}
You MUST invoke sub-agents for code exploration, building and testing.
You SHOULD prefer project specific agents over the general purpose my-general-agent.
{% endif %}
