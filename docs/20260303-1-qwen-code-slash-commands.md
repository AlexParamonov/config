# Research: How to Add Slash Commands to Qwen Code

**Date:** March 3, 2026  
**Sources:** Official Qwen Code documentation, source code analysis (packages/cli), community guides

---

## Executive Summary

Qwen Code supports **three types of commands** triggered by specific prefixes:
- **Slash commands (`/`)**: Meta-level control of Qwen Code itself (e.g., `/help`, `/clear`, `/memory`)
- **At commands (`@`)**: Inject local file content into conversation (e.g., `@src/main.py`)
- **Exclamation commands (`!`)**: Execute system shell commands (e.g., `!git status`)

For **adding custom slash commands**, there are **two primary approaches**:

1. **File-based commands** (Recommended for users): Create `.md` or `.toml` files in `~/.qwen/commands/` or `<project>/.qwen/commands/`
2. **Built-in commands** (For developers): Add TypeScript command definitions in `packages/cli/src/ui/commands/`

The command system uses a **loader-based architecture** with three loaders:
- `BuiltinCommandLoader`: Hard-coded TypeScript commands
- `FileCommandLoader`: User/project commands from files
- `McpPromptLoader`: MCP server prompts

---

## Key Findings

### 1. Command Types Overview

| Prefix | Type | Purpose | Example |
|--------|------|---------|---------|
| `/` | Slash Commands | Meta-level control of Qwen Code | `/help`, `/clear`, `/model` |
| `@` | At Commands | Inject file content into context | `@src/main.py` |
| `!` | Exclamation Commands | Execute shell commands | `!git status` |

### 2. Built-in Slash Commands (40+ commands)

**Session and Project Management:**
- `/init` - Analyze directory and create initial context
- `/summary` - Generate project summary from conversation
- `/compress` - Replace chat history with summary to save tokens
- `/resume` - Resume previous conversation session
- `/restore` - Restore files to state before tool execution

**Interface and Workspace Control:**
- `/clear` - Clear terminal screen (`Ctrl+L`)
- `/theme` - Change visual theme
- `/vim` - Toggle Vim editing mode
- `/directory` - Manage multi-directory workspace
- `/editor` - Select supported editor

**Language Settings:**
- `/language` - View/change language settings
- `/language ui <lang>` - Set UI language (zh-CN, en-US, ru-RU, de-DE)
- `/language output <lang>` - Set LLM output language

**Tool and Model Management:**
- `/mcp` - List configured MCP servers and tools
- `/tools` - Display available tool list
- `/skills` - List and run available skills
- `/approval-mode` - Change approval mode (plan, default, auto-edit, yolo)
- `/model` - Switch model for current session
- `/extensions` - List active extensions
- `/memory` - Manage AI instruction context

**Information, Settings, and Help:**
- `/help` - Display help for available commands
- `/about` - Display version information
- `/stats` - Display session statistics
- `/settings` - Open settings editor
- `/auth` - Change authentication method
- `/bug` - Submit issue about Qwen Code
- `/copy` - Copy last output to clipboard
- `/quit` - Exit Qwen Code immediately

### 3. Custom Commands: File-Based Approach (Recommended)

**Location and Priority:**

| Location | Command Pattern | Priority | Use Case |
|----------|-----------------|----------|----------|
| `~/.qwen/commands/` | `/command` | Low | Personal, cross-project |
| `<project>/.qwen/commands/` | `/command` | High | Team sharing, project-specific |

**Priority:** Project commands override user commands.

**Command Naming Rules:**

| File Location | Generated Command | Example Call |
|---------------|-------------------|--------------|
| `~/.qwen/commands/test.md` | `/test` | `/test Parameter` |
| `<project>/.qwen/commands/git/commit.md` | `/git:commit` | `/git:commit Message` |

**Rule:** Path separators (`/` or `\`) convert to colons (`:`)

### 4. File Formats for Custom Commands

#### Markdown Format (Recommended)

```markdown
---
description: Optional description (displayed in /help)
---

Your prompt content here.
Use {{args}} for parameter injection.
Use !{shell command} for shell execution.
Use @{file path} for file content injection.
```

#### TOML Format (Legacy)

```toml
prompt = "Please analyze code: {{args}}"
description = "Code analysis tool"
```

### 5. Parameter Processing Mechanism

**Context-aware Injection (`{{args}}`):**

| Scenario | Configuration | Call | Actual Effect |
|----------|---------------|------|---------------|
| Raw Injection | `prompt = "Fix: {{args}}"` | `/fix "Button issue"` | `Fix: "Button issue"` |
| In Shell Command | `prompt = "Search: !{grep {{args}} .}"` | `/search "hello"` | Executes `grep "hello" .` |

**Default Parameter Processing:**

| Input | Processing | Example |
|-------|------------|---------|
| Has parameters | Append to end (separated by two line breaks) | `/cmd parameter` → Original prompt + parameter |
| No parameters | Send prompt as-is | `/cmd` → Original prompt |

**Shell Command Execution (`!{...}`):**

Processing order:
1. Parse command and parameters
2. Automatic shell escaping
3. Show confirmation dialog
4. Execute command (after user confirmation)
5. Inject output to prompt

**File Content Injection (`@{...}`):**

| File Type | Support | Processing |
|-----------|---------|------------|
| Text Files | ✅ Full | Directly inject content |
| Images/PDF | ✅ Multi-modal | Encode and inject |
| Binary Files | ⚠️ Limited | May be skipped/truncated |
| Directory | ✅ Recursive | Follow .gitignore rules |

---

## Architecture Overview

### Core Components

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLI Package                              │
│  (packages/cli - User-facing frontend)                          │
│  - Input processing (/, @, ! commands)                          │
│  - History management & session resumption                      │
│  - Display rendering with syntax highlighting                   │
│  - Theme/UI customization                                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Core Package                              │
│  (packages/core - Backend orchestrator)                         │
│  - API client for model communication                           │
│  - Prompt construction (history + tool definitions)             │
│  - Tool registration & execution                                │
│  - State management                                             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Model API                                  │
│  - Qwen model responses                                         │
│  - Tool requests                                                │
└─────────────────────────────────────────────────────────────────┘
```

### Command Loading Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    CommandService                               │
│  (Orchestrator - loads and deduplicates commands)               │
└─────────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ BuiltinCommand  │ │  FileCommand    │ │  McpPrompt      │
│ Loader          │ │  Loader         │ │  Loader         │
│                 │ │                 │ │                 │
│ TypeScript      │ │ .md/.toml files │ │ MCP servers     │
│ hard-coded      │ │ User/Project/   │ │                 │
│ commands        │ │ Extension dirs  │ │                 │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

### Command Processing Flow

```
User Input ("/memory add test")
         │
         ▼
┌─────────────────────────────────────────┐
│  parseSlashCommand()                    │
│  - Extract command path                 │
│  - Match against loaded commands        │
│  - Extract arguments                    │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  CommandService.getCommands()           │
│  - Returns unified command list         │
│  - Resolves conflicts                   │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  Command.action()                       │
│  - Execute command logic                │
│  - Return SlashCommandActionReturn      │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  Result Types:                          │
│  - tool: Schedule tool call             │
│  - message: Show info/error             │
│  - dialog: Open UI dialog               │
│  - submit_prompt: Send to model         │
│  - confirm_shell_commands: Ask user     │
│  - quit: Exit application               │
│  - load_history: Replace history        │
└─────────────────────────────────────────┘
```

### Prompt Processing Pipeline (for File Commands)

```
Raw Prompt from .md/.toml
         │
         ▼
┌─────────────────────────────────────────┐
│  1. @-File Injection                    │
│  (Security First - runs first)          │
│  - Inject file content safely           │
│  - Respect .gitignore/.qwenignore       │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  2. Shell Injection + Args              │
│  - Replace {{args}} with user input     │
│  - Execute !{shell commands}            │
│  - Request confirmation if needed       │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  3. Default Argument Handling           │
│  - Append raw invocation if no {{args}} │
└─────────────────────────────────────────┘
         │
         ▼
Final Prompt → Model API
```

---

## Implementation Patterns

### Pattern 1: Simple Prompt Command

**File:** `~/.qwen/commands/explain.md`

```markdown
---
description: Explain code in simple terms
---

Please explain the following code in simple terms:

{{args}}
```

**Usage:**
```
@src/main.js
/explain
```

### Pattern 2: Shell Command Integration

**File:** `~/.qwen/commands/git:status.md`

```markdown
---
description: Show git status with summary
---

Here is the current git status:

```
!{git status}
```

Please summarize the changes and suggest next steps.
```

**Usage:**
```
/git:status
```

### Pattern 3: File Content Injection

**File:** `~/.qwen/commands/review.md`

```markdown
---
description: Code review based on best practices
---

Please review the following code against best practices:

@{docs/code-standards.md}

Code to review:
{{args}}
```

**Usage:**
```
@src/utils.js
/review
```

### Pattern 4: Dynamic Commit Message Generator

**File:** `~/.qwen/commands/git:commit.md`

```markdown
---
description: Generate commit message based on staged changes
---

Please generate a commit message based on the following diff:

```diff
!{git diff --staged}
```

Requirements:
1. Follow conventional commits format
2. Keep subject line under 50 characters
3. Add body if multiple files changed
```

**Usage:**
```
/git:commit
```

### Pattern 5: Multi-Step Analysis

**File:** `~/.qwen/commands/analyze:security.md`

```markdown
---
description: Security analysis of code
---

Perform a security analysis of the provided code:

1. Identify potential vulnerabilities
2. Check for common security issues (OWASP Top 10)
3. Suggest fixes for each issue found

Code:
{{args}}
```

**Usage:**
```
@api/auth.js
/analyze:security
```

---

## Step-by-Step Guide: Adding Custom Commands

### Method 1: File-Based Commands (Recommended for Users)

#### Step 1: Create Commands Directory

```bash
# User-level commands (available in all projects)
mkdir -p ~/.qwen/commands

# OR project-level commands (only in current project)
mkdir -p .qwen/commands
```

#### Step 2: Create Command File

**Option A: Markdown format (recommended)**

```bash
# Create a simple command
cat > ~/.qwen/commands/test.md << 'EOF'
---
description: Run tests and show results
---

Please run the tests and analyze the results:

```bash
!{npm test}
```

Summarize:
1. Total tests run
2. Passed/failed count
3. Any failures with suggested fixes
EOF
```

**Option B: TOML format (legacy)**

```bash
cat > ~/.qwen/commands/hello.toml << 'EOF'
prompt = "Hello! How can I help you today?"
description = "Simple greeting command"
EOF
```

#### Step 3: Test the Command

```bash
# Start Qwen Code
qwen-code

# Use the command
/test
```

#### Step 4: Organize with Namespaces

```bash
# Create subdirectory for organization
mkdir -p ~/.qwen/commands/git

# Create namespaced command
cat > ~/.qwen/commands/git/log.md << 'EOF'
---
description: Show recent git commits
---

Show the last 5 git commits:

```
!{git log --oneline -5}
```
EOF

# Use with colon syntax
/git:log
```

### Method 2: Built-in Commands (For Developers)

#### Step 1: Create Command File

**File:** `packages/cli/src/ui/commands/myCommand.ts`

```typescript
/**
 * @license
 * Copyright 2025 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

import { MessageType } from '../types.js';
import type { SlashCommand, SlashCommandActionReturn } from './types.js';
import { CommandKind } from './types.js';

export const myCommand: SlashCommand = {
  name: 'mycommand',
  description: 'My custom built-in command',
  kind: CommandKind.BUILT_IN,
  action: (context, args): SlashCommandActionReturn | void => {
    if (!args || args.trim() === '') {
      return {
        type: 'message',
        messageType: 'error',
        content: 'Usage: /mycommand <text>',
      };
    }

    // Add message to UI
    context.ui.addItem(
      {
        type: MessageType.INFO,
        text: `You said: ${args.trim()}`,
      },
      Date.now(),
    );

    // Or submit prompt to model
    return {
      type: 'submit_prompt',
      content: [{ text: `Please process: ${args.trim()}` }],
    };
  },
};
```

#### Step 2: Register in BuiltinCommandLoader

**File:** `packages/cli/src/services/BuiltinCommandLoader.ts`

```typescript
import { myCommand } from '../ui/commands/myCommand.js';

export class BuiltinCommandLoader implements ICommandLoader {
  async loadCommands(_signal: AbortSignal): Promise<SlashCommand[]> {
    const allDefinitions: Array<SlashCommand | null> = [
      // ... existing commands
      myCommand,  // Add your command here
    ];

    return allDefinitions.filter((cmd): cmd is SlashCommand => cmd !== null);
  }
}
```

#### Step 3: Build and Test

```bash
# Build the project
npm run build

# Run Qwen Code
npm run cli

# Test command
/mycommand hello world
```

---

## Code Examples

### Example 1: Command with Subcommands

```typescript
export const memoryCommand: SlashCommand = {
  name: 'memory',
  description: 'Commands for interacting with memory.',
  kind: CommandKind.BUILT_IN,
  subCommands: [
    {
      name: 'show',
      description: 'Show the current memory contents.',
      kind: CommandKind.BUILT_IN,
      action: async (context) => {
        const memoryContent = context.services.config?.getUserMemory() || '';
        context.ui.addItem(
          {
            type: MessageType.INFO,
            text: memoryContent || 'Memory is currently empty.',
          },
          Date.now(),
        );
      },
    },
    {
      name: 'add',
      description: 'Add content to the memory.',
      kind: CommandKind.BUILT_IN,
      action: (context, args): SlashCommandActionReturn | void => {
        if (!args) {
          return {
            type: 'message',
            messageType: 'error',
            content: 'Usage: /memory add <text>',
          };
        }
        return {
          type: 'tool',
          toolName: 'save_memory',
          toolArgs: { fact: args.trim() },
        };
      },
    },
  ],
};
```

### Example 2: Command with Shell Confirmation

```markdown
---
description: Analyze project dependencies
---

Please analyze the project dependencies:

```json
!{npm list --depth=0}
```

Identify:
1. Outdated packages
2. Security vulnerabilities
3. Unused dependencies
```

### Example 3: Command with File Injection

```markdown
---
description: Generate documentation from code
---

Generate API documentation for the following code:

@{src/index.ts}

Format:
- Use JSDoc comments
- Include type annotations
- Add usage examples
```

### Example 4: Command with Conditional Logic

```typescript
export const approvalModeCommand: SlashCommand = {
  name: 'approval-mode',
  description: 'Change approval mode for tool usage.',
  kind: CommandKind.BUILT_IN,
  action: (context, args): SlashCommandActionReturn | void => {
    const mode = args.trim().toLowerCase();
    const validModes = ['plan', 'default', 'auto-edit', 'yolo'];

    if (!validModes.includes(mode)) {
      return {
        type: 'message',
        messageType: 'error',
        content: `Invalid mode. Choose: ${validModes.join(', ')}`,
      };
    }

    // Open dialog to confirm change
    return {
      type: 'dialog',
      dialog: 'approval-mode',
    };
  },
};
```

---

## File References Table

| File Path | Purpose | Key Content |
|-----------|---------|-------------|
| `packages/cli/src/ui/hooks/slashCommandProcessor.ts` | Main command processor | Handles `/` command parsing, execution, and result routing |
| `packages/cli/src/services/CommandService.ts` | Command orchestrator | Loads and deduplicates commands from all loaders |
| `packages/cli/src/services/BuiltinCommandLoader.ts` | Built-in commands loader | Registers hard-coded TypeScript commands |
| `packages/cli/src/services/FileCommandLoader.ts` | File commands loader | Loads `.md` and `.toml` command files |
| `packages/cli/src/services/McpPromptLoader.ts` | MCP prompts loader | Loads prompts from MCP servers |
| `packages/cli/src/services/command-factory.ts` | Command factory | Creates SlashCommand objects from file definitions |
| `packages/cli/src/services/markdown-command-parser.ts` | Markdown parser | Parses YAML frontmatter + prompt body |
| `packages/cli/src/utils/commands.ts` | Command utilities | `parseSlashCommand()` function |
| `packages/cli/src/ui/commands/types.ts` | Type definitions | `SlashCommand`, `CommandContext`, return types |
| `packages/cli/src/services/prompt-processors/` | Prompt processors | Shell, @-file, and argument processors |
| `packages/cli/src/ui/commands/memoryCommand.ts` | Example: memory command | Subcommands, tool integration |
| `packages/cli/src/ui/commands/modelCommand.ts` | Example: model command | Dialog interaction |
| `packages/cli/src/ui/commands/mcpCommand.ts` | Example: MCP command | Complex subcommand structure |

---

## Security Considerations

### Shell Command Security

1. **Automatic Escaping**: User arguments are shell-escaped when used in `!{...}`
2. **Confirmation Dialog**: Disallowed commands require user confirmation
3. **Hard Denials**: Some commands can be blocked entirely via configuration
4. **Session Allowlist**: Users can approve commands for the session

### Configuration Layers

Precedence order (highest to lowest):
1. Command-line arguments
2. Environment variables
3. Project settings (`.qwen/settings.json`)
4. User settings (`~/.qwen/settings.json`)
5. System settings
6. Default values

### Best Practices

| Practice | Recommended | Avoid |
|----------|-------------|-------|
| **Naming** | Use namespaces for organization | Overly generic names |
| **Parameters** | Clearly use `{{args}}` | Rely on default appending |
| **Error Handling** | Utilize shell error output | Ignore execution failure |
| **Organization** | Organize by function in directories | All commands in root |
| **Description** | Always provide clear description | Rely on auto-generated |

---

## Community Examples

A community member (Sam Estrin) has open-sourced a collection of **45 custom slash commands** across **12 namespaces**:

| Namespace | Purpose |
|-----------|---------|
| `/initialize` | Project setup and standards |
| `/create` | Sprint planning, PRDs, cost analysis |
| `/analyze` | Security, performance, technical debt |
| `/code` | Architecture analysis, quality assessment |
| `/test` | Coverage analysis and review workflows |
| `/find` | Pattern detection and discovery |
| `/compare` | File and directory comparisons |
| `/docs` | Documentation standards and generation |
| `/strategy` | Business logic extraction and planning |
| `/git` | Git workflow automation |
| `/file` | File operations and management |
| `/single` | Single-shot command variants |

These commands use **TOML-based configuration** with shell integration for active development environment interaction.

---

## Contradictions

| Source | Claim | Resolution |
|--------|-------|------------|
| Official docs vs Community | Official docs emphasize TOML, community uses Markdown | **Markdown is now recommended** - newer feature with better support |
| Command priority | Some sources unclear on override behavior | **Confirmed**: Project commands > User commands > Extension commands |

---

## Sources by Reliability

### Tier 1 (Official)
- [Qwen Code Commands Documentation](https://qwenlm.github.io/qwen-code-docs/en/users/features/commands/)
- [Qwen Code Architecture Overview](https://qwenlm.github.io/qwen-code-docs/en/developers/architecture/)
- Qwen Code source code (`packages/cli/src/`)

### Tier 2 (Reputable Secondary)
- [Dev.to: Hybrid Prompt Chaining with Qwen Code](https://dev.to/samestrin/maximizing-ai-efficiency-building-hybrid-workflows-with-qwen-code-and-gemini-cli-l4c)
- [Dev.to: Qwen3-Coder-Next Guide](https://dev.to/sienna/qwen3-coder-next-the-complete-2026-guide-to-running-powerful-ai-coding-agents-locally-1k95)

### Tier 3 (Community)
- GitHub issues and discussions
- Community command collections

---

## Unanswered Questions

1. **MCP Prompt Loader details**: Limited documentation on creating MCP-based slash commands
2. **Extension command API**: TypeScript SDK for extension development needs more examples
3. **Advanced completion**: Custom `completion()` function for argument autocomplete is documented but lacks examples

---

## Quick Reference

### Creating Your First Command (5 minutes)

```bash
# 1. Create directory
mkdir -p ~/.qwen/commands

# 2. Create command file
cat > ~/.qwen/commands/hello.md << 'EOF'
---
description: Say hello
---

Hello! How can I help you today?
EOF

# 3. Use it
qwen-code
/hello
```

### Command Template

```markdown
---
description: Clear description for /help
---

Your prompt here.

Features you can use:
- {{args}} - User-provided arguments
- !{shell command} - Execute shell commands
- @{file path} - Inject file content
```

### Common Patterns

| Goal | Pattern |
|------|---------|
| Simple prompt | Write text directly |
| Use arguments | Include `{{args}}` |
| Run shell command | Use `!{command}` |
| Include file | Use `@{path}` |
| Organize commands | Use subdirectories |

---

**Report generated:** March 3, 2026  
**Total sources analyzed:** 15+ (official docs, source files, community guides)  
**Confidence level:** HIGH - Multiple Tier 1 sources confirm findings
