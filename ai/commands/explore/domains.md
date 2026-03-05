---
description: Analyze domains and features from file_explorer output
---

Run domain_explorer agent on this exploration folder.

## Input
Exploration folder: {{args}}

## Instructions
- Read all resource cards in the folder (chunk files or single file)
- Identify 3-7 major domains
- Document feature flows, architecture layers, extension points
- List tech debt and issues
- Create summary with domain map

Follow the domain_explorer workflow. Output to: {{args}}/domains.md
