---
description: Explore codebase with intelligent chunking and parallel exploration
---

# Explore Orchestrator

You coordinate parallel file_explorer agents to explore codebases in manageable chunks.

## Input
{{args}}

---

## Workflow

### 1. Setup
- **Get commit:** `git rev-parse --short=7 HEAD`
- **Get timestamp:** `date +%Y%m%d-%H%M%S`
- **Parse input:** `<topic>: <paths>` or `<paths>`
- **Create folder:** `mkdir -p tasks/code-exploration/${topic}-${commit}-${timestamp}`

### 2. Discover Files
- Use glob `**/*` on each path to discover all files
- **Keep track of this list** (needed for gap detection in step 5)
- Build visual tree

### 3. Create Chunks
Group files into chunks
- **Priority 1:** Semantic coherence (tests with implementation, controllers with routes)
- **Priority 2:** Max 50-80 files per chunk
- **Priority 3:** ~700KB source per chunk (flexible)
- **Priority 4:** No overlapping patterns (each file belongs to exactly one chunk)

Dont create micro chunks with few files of small size, merge them in a bigger chunk.
When using globs like `dir/*`, exclude subdirectories that have their own chunk.

Output chunk definitions:
```json
[{"id": 0, "name": "auth-controller", "patterns": ["src/auth/*.ts"], "reasoning": "..."}]
```

### 4. Parallel Exploration
Spawn file_explorer agents for each chunk (all in one message):

description: `Explore chunk ${chunk.id}: ${chunk.name}`,
prompt: `Explore files: ${chunk.patterns}. Output to: ${folder}/chunk-${chunk.id}-${chunk.name}.md`

Dont add anything else to prompt as agent has internal instructions

### 5. Gap Detection
- Read all chunk files, extract explored files
- Compare against discovered files
- Log gaps, optionally explore missing files

### 6. Build Index
Create `manifest.json`:
```json
{
  "metadata": {"topic": "...", "commit": "...", "timestamp": "..."},
  "fileIndex": {"<file-path>": "chunk-<N>-<name>.md"},
  "chunks": [...],
  "summary": {"totalFiles": N, "totalChunks": N, "gaps": []}
}
```

Create `index.md`: Human-readable summary with chunk and file tables.

### 7. Report
```
✓ Exploration complete!
Topic: <topic> | Commit: <commit> | Chunks: <n> | Files: <total>
Result: ${folder}/
```

---

## Execute

Start with setup, then proceed through all steps. Show chunking reasoning.

**Key reminders:**
- Track discovered files for gap detection
- Spawn all explorers in parallel
- Build accurate file index in manifest.json

---

## Error Handling

### Auto-Restart Triggers

If you encounter this error, restart the affected agent:

```
Failed to run subagent: Invalid diff: now finding less tool calls!
```

**Action:** When this error occurs for a file_explorer subagent:
1. Note the chunk that failed
2. Re-run just that chunk with a fresh file_explorer agent
3. Continue with remaining steps

This error indicates a tool call validation failure and typically resolves with a retry.

## Input

{{args}}
