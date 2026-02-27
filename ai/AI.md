# AI Assistant Workflow Configuration

## Workflow Orchestration

### 1. Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Use plan mode for verification steps, not just building
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

### 4. Verification Before Done
- Never mark complete without proving it works
- Diff against `master`/`main` branch: `git diff HEAD`
- Ask: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)
- Simple/obvious fixes: just do it, don't over-engineer
- Non-trivial changes: pause and ask "is there a more elegant way?"
- Hacky feeling: step back and implement the elegant solution
- Always challenge your own work before presenting

### 6. Autonomous Bug Fixing
- Given a bug: just fix it. No hand-holding requests.
- Point at logs, errors, failing tests -> then resolve them
- Zero context switching required from user
- Fix failing CI tests without being told how

## Task Management
1. **Plan First**: Write plan to `tasks/todo.md` (per-project) with checkable items
2. **Verify Plan**: Self-review before coding:
   - Compare against original request
   - Check for bugs, security issues, best practices
   - Ask: simpler? more elegant?
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review to `tasks/todo.md`
6. **Capture Lessons**: Update `tasks/lessons.md` after corrections

## Core Principles
- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

## Commit messages
- concise, follow Conventional Commits format
- no extra collaborators
