---
name: nlm-skill
version: "0.7.3"
description: "Expert guide for using Google NotebookLM MCP tools to query notebooks. Triggers on mentions of \"nlm\", \"notebooklm\", \"notebook lm\", or when querying existing notebooks using MCP."
---

# NotebookLM MCP Query Guide

This skill guides usage of Google NotebookLM **MCP tools** for querying notebooks. No CLI needed.

## Authentication (CRITICAL)

If MCP tools fail with auth errors (e.g. "expired"):
1. Run `nlm login` in terminal.
2. Call `notebooklm__refresh_auth()` to reload tokens in MCP server.

---

## Querying Notebooks (MCP Tools Only)

Use these tools to ask questions about sources already in a notebook.

### 1. Single Notebook Query

- **`notebooklm__notebook_query(notebook_id, query, source_ids=None, conversation_id=None)`**
  - Standard one-shot or follow-up query.
  - **Maintain Context**: Pass the `conversation_id` returned from a previous query to ask follow-up questions.

- **`notebooklm__notebook_query_start(notebook_id, query, source_ids=None, conversation_id=None)`** & **`notebooklm__notebook_query_status(query_id)`**
  - For large notebooks (50+ sources) to avoid 60-second timeouts.
  - Call `notebooklm__notebook_query_start` first, get `query_id`, then poll `notebooklm__notebook_query_status` every few seconds until `completed`.

---

### 2. Notebook Discovery

To find `notebook_id` or check sources before querying:
- **`notebooklm__notebook_list(max_results=100)`**: List all notebooks and their UUIDs.
- **`notebooklm__notebook_get(notebook_id)`**: Get details and source IDs for a notebook.

---

## Troubleshooting

- **Auth Expired**: Run `nlm login` in terminal, then call `notebooklm__refresh_auth()`.
- **Query Timeouts**: Use `notebooklm__notebook_query_start()` and poll `notebooklm__notebook_query_status()`.
