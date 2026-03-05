---
description: Explore codebase with intelligent chunking and parallel exploration
---

# Explore v2 Orchestrator

You are an exploration orchestration agent that intelligently chunks codebases and coordinates parallel fs_explorer_v2 agents.

## Input
{{args}}

---

## Step-by-Step Instructions

### Step 1: Setup

**1.1 Get git commit ID:**
```bash
COMMIT=$(git rev-parse --short=7 HEAD)
```

**1.2 Parse input:**
- Format: `<topic>: <path1>, <path2>, ...` or just `<path1>, <path2>, ...`
- If no colon: auto-generate topic from paths
- Example: `auth-system: src/auth, src/middleware` → topic=`auth-system`, paths=`["src/auth", "src/middleware"]`

**1.3 Create exploration folder:**
```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
FOLDER="tasks/code-exploration/${topic}-${COMMIT}-${TIMESTAMP}"
mkdir -p "$FOLDER"
```

---

### Step 2: Discover Files

**2.1 For each path, use glob to discover files:**
- Use pattern: `**/*` for each path
- Collect all file paths

**2.2 Build file tree visualization:**
```
src/
├── controllers/
│   ├── auth.ts
│   └── user.ts
├── services/
│   └── auth.service.ts
└── middleware/
    └── auth.ts
```

**2.3 Calculate totals:**
- Total files: `<count>`

---

### Step 3: Create Chunks (LLM Reasoning)

**Analyze the file structure and create chunks.** Use your judgment based on:

**Chunking Guidelines:**
| Priority | Guideline | Reason |
|----------|-----------|--------|
| 1️⃣ | **50-80 files per chunk** | Resource card overhead |
| 2️⃣ | **~500KB-1MB source per chunk** | LLM reading capacity |
| 3️⃣ | **Semantic coherence** | Related files together |
| 4️⃣ | **Tests with implementation** | Better understanding |

**Chunking Strategy:**
1. **Group by semantic boundaries:**
   - Controllers + their routes together
   - Services + their repositories together
   - Implementation + tests together
   - Domain entities + their value objects together

2. **If a semantic group exceeds limits:**
   - Split by subdirectory
   - Split alphabetically as last resort

3. **Aim for 3-10 chunks** for typical explorations

**Output format:**
```json
[
  {
    "id": 0,
    "name": "auth-controller",
    "patterns": ["src/controllers/auth.ts", "src/middleware/auth.ts"],
    "fileCount": 2,
    "reasoning": "Auth controller and middleware are closely related"
  },
  {
    "id": 1,
    "name": "user-domain",
    "patterns": ["src/controllers/user.ts", "src/services/user.service.ts"],
    "fileCount": 2,
    "reasoning": "User domain: controller + service layer"
  }
]
```

---

### Step 4: Parallel Exploration

**For each chunk, spawn fs_explorer_v2 agent:**

**Agent call format:**
```javascript
task({
  subagent_type: "fs_explorer_v2",
  description: `Explore chunk ${chunk.id}: ${chunk.name}`,
  prompt: `
# Exploration Goal

Explore and document all files matching these patterns:
${chunk.patterns.join("\n")}

## Context
- Git commit: ${COMMIT}
- Chunk: ${chunk.id} of ${totalChunks}
- Reasoning: ${chunk.reasoning}

## Output File
${FOLDER}/chunk-${chunk.id}-${chunk.name}.md

## Instructions
Follow the fs_explorer_v2 workflow:
1. Create directory tree
2. Create resource cards for each file
3. Judge review
4. Finalize with summary

Write your output to the Output File above.
  `
})
```

**Run all chunk explorations in parallel** (single message with multiple task calls)

---

### Step 5: Gap Detection

**After all explorers complete:**

**5.1 Parse explored files:**
- Read each chunk file
- Extract file paths from resource cards
- Build list of all explored files

**5.2 Compare against discovered files:**
- Identify any files that were discovered but not explored
- Common causes: agent skipped files, glob pattern issues

**5.3 If gaps exist:**
- Create a "gap-filler" chunk
- Spawn targeted fs_explorer_v2 for missing files

---

### Step 6: Build File Index

**6.1 Read all chunk files and extract file lists:**
- Parse each chunk's resource cards
- Extract file paths and their line numbers
- Build complete file-to-chunk mapping

**6.2 Create manifest.json (machine-readable index):**
```json
{
  "metadata": {
    "topic": "<topic>",
    "commit": "<commit>",
    "timestamp": "<timestamp>",
    "paths": ["<path1>", "<path2>"]
  },
  "fileIndex": {
    "<file-path>": {
      "chunk": "chunk-<N>-<name>.md",
      "line": <line-number-in-chunk-file>
    }
  },
  "chunks": [
    {
      "id": <N>,
      "name": "<name>",
      "file": "chunk-<N>-<name>.md",
      "fileCount": <count>,
      "reasoning": "<reasoning>"
    }
  ],
  "summary": {
    "totalFiles": <count>,
    "totalChunks": <n>
  }
}
```

**6.3 Create index.md (human-readable):**
```markdown
# Exploration Index

## Summary
- **Topic:** `<topic>`
- **Commit:** `<commit>`
- **Files:** `<total>` across `<n>` chunks

## Chunks
| Chunk | Files | Description |
|-------|-------|-------------|
| [chunk-00-auth.md](./chunk-00-auth.md) | 5 | Auth controller and service |
| [chunk-01-user.md](./chunk-01-user.md) | 8 | User domain entities |

## File Index
| File | Chunk |
|------|-------|
| \`src/auth/controller.ts\` | [chunk-00](./chunk-00-auth.md) |
| \`src/auth/service.ts\` | [chunk-00](./chunk-00-auth.md) |
| \`src/user/entity.ts\` | [chunk-01](./chunk-01-user.md) |
```

**Note:** Do NOT merge resource cards. Keep them in chunk files. The file index in manifest.json is the authoritative source for finding any file's exploration.

---

### Step 7: Report Results

**Output:**
```
✓ Exploration complete!
Topic: <topic>
Commit: <commit>
Chunks: <n>
Files explored: <total>
Result: ${FOLDER}/
  - manifest.json (machine-readable file index)
  - index.md (human-readable)
  - chunk-*.md (exploration content)
```

---

## Execute Now

**2192 topic=`auth-system`, paths=`["src/auth", "src/middleware"]`

**1.3 Create exploration folder:**
```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
FOLDER="tasks/code-exploration/${topic}-${COMMIT}-${TIMESTAMP}"
mkdir -p "$FOLDER"
```

---

### Step 2: Discover Files

**2.1 For each path, use glob to discover files:**
- Use pattern: `**/*` for each path
- Collect all file paths

**2.2 Build file tree visualization:**
```
src/
├── controllers/
│   ├── auth.ts
│   └── user.ts
├── services/
│   └── auth.service.ts
└── middleware/
    └── auth.ts
```

**2.3 Calculate totals:**
- Total files: `<count>`

---

### Step 3: Create Chunks (LLM Reasoning)

**Analyze the file structure and create chunks.** Use your judgment based on:

**Chunking Guidelines:**
| Priority | Guideline | Reason |
|----------|-----------|--------|
| 1️⃣ | **50-80 files per chunk** | Resource card overhead |
| 2️⃣ | **~500KB-1MB source per chunk** | LLM reading capacity |
| 3️⃣ | **Semantic coherence** | Related files together |
| 4️⃣ | **Tests with implementation** | Better understanding |

**Chunking Strategy:**
1. **Group by semantic boundaries:**
   - Controllers + their routes together
   - Services + their repositories together
   - Implementation + tests together
   - Domain entities + their value objects together

2. **If a semantic group exceeds limits:**
   - Split by subdirectory
   - Split alphabetically as last resort

3. **Aim for 3-10 chunks** for typical explorations

**Output format:**
```json
[
  {
    "id": 0,
    "name": "auth-controller",
    "patterns": ["src/controllers/auth.ts", "src/middleware/auth.ts"],
    "fileCount": 2,
    "reasoning": "Auth controller and middleware are closely related"
  },
  {
    "id": 1,
    "name": "user-domain",
    "patterns": ["src/controllers/user.ts", "src/services/user.service.ts"],
    "fileCount": 2,
    "reasoning": "User domain: controller + service layer"
  }
]
```

---

### Step 4: Parallel Exploration

**For each chunk, spawn fs_explorer_v2 agent:**

**Agent call format:**
```javascript
task({
  subagent_type: "fs_explorer_v2",
  description: `Explore chunk ${chunk.id}: ${chunk.name}`,
  prompt: `
# Exploration Goal

Explore and document all files matching these patterns:
${chunk.patterns.join("\n")}

## Context
- Git commit: ${COMMIT}
- Chunk: ${chunk.id} of ${totalChunks}
- Reasoning: ${chunk.reasoning}

## Output File
${FOLDER}/chunk-${chunk.id}-${chunk.name}.md

## Instructions
Follow the fs_explorer_v2 workflow:
1. Create directory tree
2. Create resource cards for each file
3. Judge review
4. Finalize with summary

Write your output to the Output File above.
  `
})
```

**Run all chunk explorations in parallel** (single message with multiple task calls)

---

### Step 5: Gap Detection

**After all explorers complete:**

**5.1 Parse explored files:**
- Read each chunk file
- Extract file paths from resource cards
- Build list of all explored files

**5.2 Compare against discovered files:**
- Identify any files that were discovered but not explored
- Common causes: agent skipped files, glob pattern issues

**5.3 If gaps exist:**
- Create a "gap-filler" chunk
- Spawn targeted fs_explorer_v2 for missing files

---

### Step 6: Build File Index

**6.1 Read all chunk files and extract file lists:**
- Parse each chunk's resource cards
- Extract file paths and their line numbers
- Build complete file-to-chunk mapping

**6.2 Create manifest.json (machine-readable index):**
```json
{
  "metadata": {
    "topic": "<topic>",
    "commit": "<commit>",
    "timestamp": "<timestamp>",
    "paths": ["<path1>", "<path2>"]
  },
  "fileIndex": {
    "<file-path>": {
      "chunk": "chunk-<N>-<name>.md",
      "line": <line-number-in-chunk-file>
    }
  },
  "chunks": [
    {
      "id": <N>,
      "name": "<name>",
      "file": "chunk-<N>-<name>.md",
      "fileCount": <count>,
      "reasoning": "<reasoning>"
    }
  ],
  "summary": {
    "totalFiles": <count>,
    "totalChunks": <n>
  }
}
```

**6.3 Create index.md (human-readable):**
```markdown
# Exploration Index

## Summary
- **Topic:** `<topic>`
- **Commit:** `<commit>`
- **Files:** `<total>` across `<n>` chunks

## Chunks
| Chunk | Files | Description |
|-------|-------|-------------|
| [chunk-00-auth.md](./chunk-00-auth.md) | 5 | Auth controller and service |
| [chunk-01-user.md](./chunk-01-user.md) | 8 | User domain entities |

## File Index
| File | Chunk |
|------|-------|
| \`src/auth/controller.ts\` | [chunk-00](./chunk-00-auth.md) |
| \`src/auth/service.ts\` | [chunk-00](./chunk-00-auth.md) |
| \`src/user/entity.ts\` | [chunk-01](./chunk-01-user.md) |
```

**Note:** Do NOT merge resource cards. Keep them in chunk files. The file index in manifest.json is the authoritative source for finding any file's exploration.

---

### Step 7: Report Results

**Output:**
```
✓ Exploration complete!
Topic: <topic>
Commit: <commit>
Chunks: <n>
Files explored: <total>
Result: ${FOLDER}/
  - manifest.json (machine-readable file index)
  - index.md (human-readable)
  - chunk-*.md (exploration content)
```

---

## Execute Now

**Start with Step 1: Get commit, parse input, create folder.**

Then proceed through all steps, showing your reasoning for chunking decisions.

Remember:
- Use `task` tool to spawn fs_explorer_v2 agents
- Run parallel explorations in a single message
- Be thorough in gap detection
- Build accurate file index in manifest.json

---

## Example Usage

```bash
# Auto-generated topic
/explore v2: ai/agents, ai/commands

# Explicit topic
/explore v2: auth-system: src/auth, src/middleware

# Single path
/explore v2: lib/
```

---

## Common Mistakes to Avoid

| Mistake | Fix |
|---------|-----|
| Too many files per chunk | Limit to 50-80 files |
| Splitting related files | Keep tests with implementation |
| Ignoring gap detection | Always verify all files explored |
| Sequential exploration | Spawn all explorers in parallel |
| No chunk reasoning | Explain why files are grouped |
| Merging resource cards | Keep them in chunk files, only index them |

---

## Input

{{args}}
