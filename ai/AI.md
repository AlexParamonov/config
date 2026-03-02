# AI Assistant Workflow Configuration

## Workflow Orchestration

### 1. Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy
- Use for: review, exploration/research, isolated task implementation
- One task per subagent for focused execution
- Keeps main context window clean

### 3. Self-Improvement Loop
- After ANY correction: update `tasks/lessons.md` with the pattern
- Write rules that prevent the same mistake
- Ruthlessly iterate on lessons until mistake rate drops
- Review lessons at session start

## Core Principles
- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

## Agent Ecosystem

| Agent | Purpose | Artifacts |
|-------|---------|-----------|
| `explorer` | Codebase exploration | `tasks/code-exploration-*.md` |
| `architect` | Architecture design | `tasks/architecture-*.md` |
| `builder` | Implementation | `tasks/build-*.md`, code |
| `reviewer` | Quality review | Inline issues |
| `researcher` | Web research | Inline summary |
| `debugger` | Bug fixes | Code fixes |
| `security-auditor` | Security audits | Audit report |

**Workflow:** explore → architect → build → review
