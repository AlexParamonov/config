# Qwen Code Internal Tools

Complete list of internal tool names available in Qwen Code.

## Core Built-in Tools

| Tool Name | Category | Purpose |
|-----------|----------|---------|
| `read_file` | File System | Read file contents |
| `write_file` | File System | Write content to a file |
| `edit` | File System | Edit text within a file |
| `glob` | File System | Fast file pattern matching |
| `grep_search` | File System | Search file contents with regex |
| `list_directory` | File System | List files and subdirectories |
| `run_shell_command` | Shell | Execute shell commands |
| `todo_write` | Task Management | Create and manage task lists |
| `task` | Task Management | Launch specialized subagents |
| `skill` | Skills | Execute domain-specific skills |
| `exit_plan_mode` | Plan Mode | Exit planning mode |
| `web_fetch` | Web | Fetch and process web content |
| `web_search` | Web | Search the web |
| `save_memory` | Memory | Save user preferences/facts |
| `lsp` | IDE | Language Server Protocol integration |

## Additional Capabilities

- **MCP Servers**: Tools provided via Model Context Protocol (custom/extensible)
- **Sandboxing**: Security layer that constrains tool execution

## Legacy Tool Names (Backward Compatibility)

| Legacy Name | Current Name |
|-------------|--------------|
| `search_file_content` | `grep_search` |
| `replace` | `edit` |

## Notes

- **`read_many_files`** is NOT a registered tool - it's an internal utility function used by other tools.

---
*Generated: 2026-03-03*
*Source: `/home/ap/code/qwen-code/packages/core/src/tools/tool-names.ts`, `config.ts`*
