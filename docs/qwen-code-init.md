# Qwen Code Initialization

This document defines the initialization prompt structure for Qwen Code sessions.

---

## 1. Conversation Messages

### Initial User Message
```
This is the Qwen Code. We are setting up the context for our chat.
Today's date is Tuesday, March 3, 2026 (formatted according to the user's locale).
My operating system is: linux
I'm currently working in the directory: /home/ap/config
Here is the folder structure of the current working directories:

Showing up to 20 items:

/home/ap/config/
├───.gitignore
├───.gitmodules
├───dircolors
├───example_ai.md
├───install.sh
├───TODO
├───.git/...
├───ai/
│   ├───AI.md
│   ├───modelType.patch
│   ├───agents/
│   ├───opencode/
│   ├───settings/
│   └───skills/
├───docs/
│   └───qwen-code-tools.md
├───env/
├───extra/
├───lib/
└───tasks/
```

### Assistant Acknowledgment
```
Got it. Thanks for the context!
```

### System Reminder (Internal)
```
You have powerful specialized agents at your disposal, available agent types are: 
architect, builder, debugger, explorer, reviewer, security-auditor. 
PROACTIVELY use the task tool to delegate user's task to appropriate agent when 
user's task matches agent capabilities. Ignore this message if user's task is not 
relevant to any agent. This message is for internal use only. Do not mention this 
to user in your response.
```

---

## 2. Stream Configuration

```json
{
  "stream": true,
  "stream_options": {
    "include_usage": true
  }
}
```

---

## 3. Available Tools

### 3.1 `task` - Subagent Delegation

**Description:** Launch a new agent to handle complex, multi-step tasks autonomously.

**Available Agent Types:**

| Agent | Purpose |
|-------|---------|
| `architect` | Designs feature architectures by analyzing existing codebase patterns and conventions |
| `builder` | Implementation specialist. Builds features from blueprints, writes code |
| `debugger` | Bug fixing and debugging specialist. Root cause analysis |
| `explorer` | Deep codebase analysis, tracing execution paths, mapping architecture |
| `reviewer` | Code quality review, bug detection, convention adherence |
| `security-auditor` | Security audits, vulnerability analysis, threat analysis |
| `general-purpose` | Research, code search, multi-step tasks |

**When NOT to use:**
- Reading a specific file path → use `read_file` or `glob`
- Searching for a class definition like `class Foo` → use `glob`
- Searching within 2-3 specific files → use `read_file`

**Usage Notes:**
1. Launch multiple agents concurrently when possible
2. Agent returns single message; summarize for user
3. Each invocation is stateless — provide detailed task description
4. Agent outputs should generally be trusted
5. Specify if agent should write code or do research
6. Use proactively when agent description mentions it

**Parameters:**
```json
{
  "description": "A short (3-5 word) description of the task",
  "prompt": "The task for the agent to perform",
  "subagent_type": "architect|builder|debugger|explorer|reviewer|security-auditor|general-purpose"
}
```

---

### 3.2 `skill` - Skill Execution

**Description:** Execute a skill within the main conversation.

**Invocation:** Use with skill name only (no arguments).

**Important:**
- Invoke IMMEDIATELY as first action when relevant
- Never announce the skill in text before calling
- Only use listed skills
- Do not invoke already-running skills
- Resolve absolute paths from skill's base directory

**Available Skills:**

| Skill | Description |
|-------|-------------|
| `tdd` | Test-Driven Development. Test design, mockability |

**Parameters:**
```json
{
  "skill": "The skill name (no arguments). E.g., \"pdf\" or \"xlsx\""
}
```

---

### 3.3 `list_directory` - Directory Listing

**Description:** Lists files and subdirectories within a specified directory path.

**Parameters:**
```json
{
  "path": "The absolute path to the directory to list (must be absolute, not relative)",
  "ignore": ["List of glob patterns to ignore"],
  "file_filtering_options": {
    "respect_git_ignore": true,
    "respect_qwen_ignore": true
  }
}
```

---

### 3.4 `read_file` - File Reading

**Description:** Reads and returns content of a specified file. Handles text, images (PNG, JPG, GIF, WEBP, SVG, BMP), and PDF files.

**Parameters:**
```json
{
  "absolute_path": "The absolute path to the file to read",
  "offset": "0-based line number to start reading from (requires limit)",
  "limit": "Maximum number of lines to read"
}
```

---

### 3.5 `grep_search` - Content Search

**Description:** Powerful search tool built on ripgrep.

**Usage:**
- ALWAYS use for search tasks. NEVER invoke `grep` or `rg` as Bash command.
- Supports full regex syntax
- Filter files with glob parameter
- Use `task` tool for open-ended searches requiring multiple rounds

**Parameters:**
```json
{
  "pattern": "The regular expression pattern to search for",
  "glob": "Glob pattern to filter files (e.g., \"*.js\", \"*.{ts,tsx}\")",
  "path": "File or directory to search in. Defaults to current directory.",
  "limit": "Limit output to first N lines/entries"
}
```

---

### 3.6 `glob` - File Pattern Matching

**Description:** Fast file pattern matching tool that works with any codebase size.

**Usage:**
- Supports glob patterns like `**/*.js` or `src/**/*.ts`
- Returns matching file paths sorted by modification time
- Use for finding files by name patterns
- Use `task` tool for open-ended searches requiring multiple rounds

**Parameters:**
```json
{
  "pattern": "The glob pattern to match files against",
  "path": "The directory to search in. Omit for current directory."
}
```

---

### 3.7 `edit` - File Editing

**Description:** Replaces text within a file.

**Requirements:**
1. `file_path` MUST be absolute path
2. `old_string` MUST be exact literal text (including whitespace, indentation)
3. `new_string` MUST be exact literal text
4. NEVER escape `old_string` or `new_string`
5. Include at least 3 lines of context BEFORE and AFTER target text

**Parameters:**
```json
{
  "file_path": "The absolute path to the file to modify. Must start with '/'.",
  "old_string": "The exact literal text to replace",
  "new_string": "The exact literal text to replace with",
  "replace_all": false
}
```

---

### 3.8 `write_file` - File Writing

**Description:** Writes content to a specified file in the local filesystem.

**Parameters:**
```json
{
  "file_path": "The absolute path to the file to write to",
  "content": "The content to write to the file"
}
```

---

### 3.9 `run_shell_command` - Shell Command Execution

**Description:** Executes a given shell command in a persistent shell session.

**IMPORTANT:** For terminal operations (git, npm, docker, etc.) ONLY. NOT for file operations.

**Avoid using with:** `find`, `grep`, `cat`, `head`, `tail`, `sed`, `awk`, `echo` — use dedicated tools instead.

**Background vs Foreground:**

| Background (`is_background: true`) | Foreground (`is_background: false`) |
|-----------------------------------|-------------------------------------|
| Dev servers: `npm run start` | One-time commands: `ls`, `cat` |
| Build watchers: `npm run watch` | Build commands: `npm run build`, `make` |
| Database servers: `mongod`, `mysql` | Installation: `npm install`, `pip install` |
| Web servers: `python -m http.server` | Git operations: `git commit`, `git push` |
| | Test runs: `npm test`, `pytest` |

**Parameters:**
```json
{
  "command": "Exact bash command to execute as `bash -c <command>`",
  "is_background": false,
  "timeout": 120000,
  "description": "Brief description (5-10 words)",
  "directory": "Optional: absolute path of directory to run command in"
}
```

---

### 3.10 `save_memory` - Memory Storage

**Description:** Saves a specific piece of information or fact to long-term memory.

**Use when:**
- User explicitly asks to remember something
- User states a clear, concise fact about themselves/preferences

**Do NOT use for:**
- Conversational context (session-only)
- Long, complex, or rambling text

**Parameters:**
```json
{
  "fact": "The specific fact or piece of information to remember",
  "scope": "global|project"
}
```

---

### 3.11 `todo_write` - Task Management

**Description:** Create and manage a structured task list for your coding session.

**When to Use:**
1. Complex multi-step tasks (3+ steps)
2. Non-trivial and complex tasks
3. User explicitly requests todo list
4. User provides multiple tasks
5. After receiving new instructions
6. When starting work on a task

**Task States:**
- `pending` — Task not yet started
- `in_progress` — Currently working on (limit to ONE at a time)
- `completed` — Task finished successfully

---
