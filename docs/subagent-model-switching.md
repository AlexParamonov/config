# Subagent Model and AuthType Switching

## Problem

Subagents like `fs_explorer` specify a model configuration in their YAML frontmatter:

```yaml
modelConfig:
  model: llama-explorer
  authType: openai
```

Your `qwen-settings.json` defines `llama-explorer` with a specific baseUrl:

```json
{
  "id": "llama-explorer",
  "baseUrl": "http://192.168.0.101:8085/v1"
}
```

However, when the subagent ran, it was using port 8080 (default) instead of 8085 because:
1. Only the model name was being used, not the full model config from the registry
2. The baseUrl lookup happens during `refreshAuth`, but subagents weren't triggering it with their specific model

## Solution

The patch adds model switching logic to the subagent's `runNonInteractive` method:

### Changes Made

1. **Save original config** (line ~175610)
   - Saves the current model and authType before subagent execution

2. **Convert string authType to enum** (line ~175614)
   - Converts YAML string authType (e.g., "openai") to AuthType enum (e.g., `AuthType2.USE_OPENAI`)

3. **Look up and switch model** (line ~175628)
   - Gets `modelRegistry` from `modelsConfig`
   - Calls `modelRegistry.getModel(authType, modelId)` to retrieve full config including baseUrl
   - Calls `setModel()` followed by `refreshAuth()` to apply the new model's configuration

4. **Restore original config** (line ~175825)
   - In the `finally` block, restores both model and authType to their original values

5. **Deprecation notice** (line ~176082)
   - The old authType switching in `createChatObject` is kept for backwards compatibility but marked as deprecated

## Usage Example

When `fs_explorer` agent runs with:

```yaml
modelConfig:
  model: llama-explorer
  authType: openai
```

The subagent will now:
1. Look up `llama-explorer` in the `openai` model providers config
2. Find baseUrl `http://192.168.0.101:8085/v1`
3. Switch to that model config before execution
4. Log: `Subagent "fs_explorer" switching from model "coder-model" to "llama-explorer" (authType: openai, baseUrl: http://192.168.0.101:8085/v1)`
5. Restore the original model after completion
6. Log: `Subagent "fs_explorer" restoring model to "coder-model"`

## Files Modified

- `/home/ap/.asdf/installs/nodejs/lts/lib/node_modules/@qwen-code/qwen-code/cli.js` (patched)
- `/home/ap/config/ai/cli.js.patch` (unified diff for re-application)
- `/home/ap/config/ai/modelType.patch` (human-readable documentation)
- `/home/ap/.asdf/installs/nodejs/lts/lib/node_modules/@qwen-code/qwen-code/cli.js.bak` (original backup)
- `/home/ap/.asdf/installs/nodejs/lts/lib/node_modules/@qwen-code/qwen-code/cli.js.patched` (backup of patched file)

## Re-applying the Patch

After updating qwen-code, re-apply the patch:

```bash
# Method 1: Using the unified diff
cd /home/ap/.asdf/installs/nodejs/lts/lib/node_modules/@qwen-code/qwen-code/
patch cli.js < /home/ap/config/ai/cli.js.patch

# Method 2: Using the shell script
bash /tmp/apply_full_patch.sh
```

## Testing

To verify the patch is working:

1. Run a subagent that specifies a different model:
   ```
   /task Use fs_explorer to explore the codebase
   ```

2. Check the logs for:
   - `Subagent "fs_explorer" switching from model ...`
   - The correct baseUrl should be shown

3. After the subagent completes, verify:
   - `Subagent "fs_explorer" restoring model to ...`
   - The main session continues with the original model

## Current Status

✅ Patch applied successfully
✅ Syntax validation passed
✅ Qwen CLI starts and runs correctly
