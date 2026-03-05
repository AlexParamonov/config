# Research: Qwen 3.5 Thinking Budget Configuration

**Date:** March 4, 2026

## Executive Summary

Qwen 3.5 supports "thinking mode" (also called reasoning mode), which enables the model to generate internal reasoning content before producing final responses. The thinking budget can be controlled through several parameters depending on the API provider:

1. **`thinking_budget`** - Direct token limit for reasoning (Alibaba Cloud DashScope)
2. **`reasoning.max_tokens`** - Token budget mapped to `thinking_budget` (OpenRouter, OpenAI-compatible)
3. **`reasoning.effort`** - Qualitative control (low/medium/high) that maps to token allocations
4. **`enable_thinking`** - Boolean to enable/disable thinking mode entirely

The qwen-code project supports these configurations through `settings.json` using `model.generationConfig.extra_body` for OpenAI-compatible providers.

---

## Key Findings

### 1. What "Thinking Budget" Means for Qwen 3.5

**Confidence:** HIGH

**Evidence:**
- [Alibaba Cloud Model Studio Documentation](https://www.alibabacloud.com/help/en/model-studio/deep-thinking)
- [Hugging Face Qwen3.5-27B](https://huggingface.co/Qwen/Qwen3.5-27B)
- [OpenRouter Reasoning Tokens Guide](https://openrouter.ai/docs/guides/best-practices/reasoning-tokens)

**Definition:**
Thinking budget refers to the maximum number of tokens the model can use for internal reasoning before generating the final response. When the limit is exceeded, the model immediately stops thinking and generates a response.

**Key Characteristics:**
- Qwen3.5 operates in **thinking mode by default** for larger models (27B+)
- Thinking content is signified by `<think>\n...\n</think>\n\n` markers
- Thinking tokens are **billed as output tokens**
- Small models (0.8B, 2B, 4B, 9B) have thinking **disabled by default**

---

### 2. Specific Parameters for Controlling Thinking Budget

**Confidence:** HIGH

#### A. Alibaba Cloud DashScope API (Native)

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `enable_thinking` | boolean | Enables/disables thinking mode | `true` |
| `thinking_budget` | number | Maximum reasoning tokens | `50`, `200`, `1000` |

**Source:** [Alibaba Cloud Model Studio](https://www.alibabacloud.com/help/en/model-studio/deep-thinking)

**Example (Python):**
```python
from openai import OpenAI

client = OpenAI(
    api_key=os.getenv("DASHSCOPE_API_KEY"),
    base_url="https://dashscope-intl.aliyuncs.com/compatible-mode/v1",
)

completion = client.chat.completions.create(
    model="qwen-plus",
    messages=[{"role": "user", "content": "Your prompt"}],
    extra_body={
        "enable_thinking": True,
        "thinking_budget": 50  # Limit reasoning to 50 tokens
    }
)
```

#### B. OpenRouter / OpenAI-Compatible APIs

| Parameter | Type | Description | Values |
|-----------|------|-------------|--------|
| `reasoning.enabled` | boolean | Enable reasoning | `true`, `false` |
| `reasoning.effort` | string | Qualitative effort level | `"xhigh"`, `"high"`, `"medium"`, `"low"`, `"minimal"`, `"none"` |
| `reasoning.max_tokens` | number | Direct token budget | `1024`, `8000`, etc. |
| `reasoning.exclude` | boolean | Use reasoning but don't return it | `true`, `false` |

**Source:** [OpenRouter Reasoning Tokens Guide](https://openrouter.ai/docs/guides/best-practices/reasoning-tokens)

**Effort Level Token Allocation:**

| Value | Token Allocation | Description |
|-------|-----------------|-------------|
| `"xhigh"` | ~95% of max_tokens | Largest reasoning portion |
| `"high"` | ~80% of max_tokens | Large reasoning portion |
| `"medium"` | ~50% of max_tokens | Moderate portion (default) |
| `"low"` | ~20% of max_tokens | Smaller portion |
| `"minimal"` | ~10% of max_tokens | Even smaller portion |
| `"none"` | 0% | Disables reasoning entirely |

**Note for Qwen:** Some Qwen thinking models support `reasoning.max_tokens` (mapped to `thinking_budget`), but support varies by model. No specific effort levels are documented for Qwen.

#### C. Local Deployment (vLLM/SGLang)

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `chat_template_kwargs.enable_thinking` | boolean | Control thinking via chat template | `{"enable_thinking": false}` |
| `--reasoning-parser` | string | Enable reasoning content parsing | `qwen3` |

**Source:** [Hugging Face Qwen3.5-27B](https://huggingface.co/Qwen/Qwen3.5-27B), [Unsloth Documentation](https://unsloth.ai/docs/models/qwen3.5)

**Example (vLLM):**
```bash
vllm serve Qwen/Qwen3.5-27B --port 8000 --tensor-parallel-size 8 \
  --max-model-len 262144 --reasoning-parser qwen3
```

**Disable thinking:**
```bash
--chat-template-kwargs '{"enable_thinking":false}'
```

---

### 3. How to Configure in qwen-code Project

**Confidence:** HIGH

**Evidence:**
- [/home/ap/code/qwen-code/docs/users/configuration/settings.md](file:///home/ap/code/qwen-code/docs/users/configuration/settings.md)
- [/home/ap/code/qwen-code/docs/users/configuration/model-providers.md](file:///home/ap/code/qwen-code/docs/users/configuration/model-providers.md)
- [/home/ap/code/qwen-code/packages/core/src/core/contentGenerator.ts](file:///home/ap/code/qwen-code/packages/core/src/core/contentGenerator.ts)

#### A. Using settings.json (Global/Project)

For OpenAI-compatible providers (`openai`, `qwen-oauth`):

```json
{
  "model": {
    "generationConfig": {
      "extra_body": {
        "enable_thinking": true,
        "thinking_budget": 200
      }
    }
  }
}
```

**Location options:**
- User settings: `~/.qwen/settings.json`
- Project settings: `.qwen/settings.json` (in project root)

#### B. Using modelProviders Configuration

```json
{
  "modelProviders": {
    "openai": [
      {
        "id": "qwen3.5-plus",
        "name": "Qwen 3.5 Plus",
        "envKey": "DASHSCOPE_API_KEY",
        "baseUrl": "https://dashscope-intl.aliyuncs.com/compatible-mode/v1",
        "generationConfig": {
          "extra_body": {
            "enable_thinking": true,
            "thinking_budget": 500
          },
          "samplingParams": {
            "temperature": 1.0,
            "top_p": 0.95,
            "max_tokens": 8192
          }
        }
      }
    ]
  }
}
```

**Source:** [model-providers.md](file:///home/ap/code/qwen-code/docs/users/configuration/model-providers.md)

#### C. Recommended Sampling Parameters by Mode

**Thinking Mode:**

| Task Type | temperature | top_p | top_k | presence_penalty | repetition_penalty |
|-----------|-------------|-------|-------|------------------|-------------------|
| General tasks | 1.0 | 0.95 | 20 | 1.5 | 1.0 |
| Precise coding | 0.6 | 0.95 | 20 | 0.0 | 1.0 |

**Non-Thinking (Instruct) Mode:**

| Task Type | temperature | top_p | top_k | presence_penalty | repetition_penalty |
|-----------|-------------|-------|-------|------------------|-------------------|
| General tasks | 0.7 | 0.8 | 20 | 1.5 | 1.0 |
| Reasoning tasks | 1.0 | 0.95 | 20 | 1.5 | 1.0 |

**Source:** [Hugging Face Qwen3.5-27B](https://huggingface.co/Qwen/Qwen3.5-27B), [Unsloth Documentation](https://unsloth.ai/docs/models/qwen3.5)

#### D. Code-Level Configuration (TypeScript)

The qwen-code project defines reasoning configuration in `ContentGeneratorConfig`:

```typescript
reasoning?:
  | false
  | {
      effort?: 'low' | 'medium' | 'high';
      budget_tokens?: number;
    };
```

**Source:** [/home/ap/code/qwen-code/packages/core/src/core/contentGenerator.ts](file:///home/ap/code/qwen-code/packages/core/src/core/contentGenerator.ts)

For Anthropic providers, the `budget_tokens` is mapped to the thinking configuration:

```typescript
private buildThinkingConfig(request: GenerateContentParameters) {
  if (reasoning?.budget_tokens !== undefined) {
    return {
      type: 'enabled',
      budget_tokens: reasoning.budget_tokens,
    };
  }
  // Default budget based on effort level
  const budgetTokens = effort === 'low' ? 16_000 : effort === 'high' ? 64_000 : 32_000;
}
```

**Source:** [/home/ap/code/qwen-code/packages/core/src/core/anthropicContentGenerator/anthropicContentGenerator.ts](file:///home/ap/code/qwen-code/packages/core/src/core/anthropicContentGenerator/anthropicContentGenerator.ts)

---

### 4. Limitations and Considerations

**Confidence:** HIGH

#### A. Model-Specific Limitations

1. **Qwen 3.5 does NOT support** the soft switch commands from Qwen3 (i.e., `/think` and `/nothink`)
   - Thinking mode is controlled **only via API parameters**, not through conversation commands
   - **Source:** [Hugging Face Qwen3.5-27B](https://huggingface.co/Qwen/Qwen3.5-27B)

2. **Small models have thinking disabled by default**
   - Qwen3.5 Small models (0.8B, 2B, 4B, 9B) have thinking/reasoning disabled by default
   - Larger models (27B+) have it enabled by default
   - **Source:** [Unsloth Documentation](https://unsloth.ai/docs/models/qwen3.5)

3. **Support varies by model**
   - Not all Qwen models support `thinking_budget` parameter
   - Check individual model descriptions for compatibility
   - **Source:** [OpenRouter Reasoning Tokens Guide](https://openrouter.ai/docs/guides/best-practices/reasoning-tokens)

#### B. Token Budget Considerations

1. **Billing Impact**
   - Thinking content is billed as **output tokens**
   - Setting a budget helps control costs
   - **Source:** [Alibaba Cloud Model Studio](https://www.alibabacloud.com/help/en/model-studio/deep-thinking)

2. **Trade-offs**
   - Lower budgets = faster responses but potentially lower reasoning quality
   - Higher budgets = better reasoning for complex tasks but slower and more expensive
   - **Source:** [Alibaba Cloud Model Studio](https://www.alibabacloud.com/help/en/model-studio/deep-thinking)

3. **Recommended Budget Values**
   - Simple queries: `thinking_budget: 50-100`
   - Complex reasoning: `thinking_budget: 200+` or omit for no limit
   - **Source:** [Alibaba Cloud Model Studio](https://www.alibabacloud.com/help/en/model-studio/deep-thinking)

#### C. Context Window Considerations

1. **Minimum Context Length**
   - Maintain at least **128K tokens** context length to preserve thinking capabilities
   - Native context length: 262,144 tokens
   - Extensible up to: 1,010,000 tokens (with YaRN scaling)
   - **Source:** [Hugging Face Qwen3.5-27B](https://huggingface.co/Qwen/Qwen3.5-27B)

2. **max_tokens Requirement**
   - `max_tokens` must be higher than reasoning budget to leave tokens for the final response
   - Formula: `budget_tokens = max(min(max_tokens * effort_ratio, 128000), 1024)`
   - **Source:** [OpenRouter Reasoning Tokens Guide](https://openrouter.ai/docs/guides/best-practices/reasoning-tokens)

#### D. Multi-Turn Conversation Best Practices

1. **Historical outputs should NOT include thinking content**
   - Only the final response should be preserved in conversation history
   - This is handled automatically by the Jinja2 chat template
   - For frameworks not using Jinja2 templates, developers must implement this manually
   - **Source:** [Hugging Face Qwen3.5-27B](https://huggingface.co/Qwen/Qwen3.5-27B)

2. **Preserving reasoning across turns**
   - When continuing a conversation, preserve the complete `reasoning_details` when passing messages back
   - Use `message.reasoning` (string) or `message.reasoning_details` (array)
   - **Source:** [OpenRouter Reasoning Tokens Guide](https://openrouter.ai/docs/guides/best-practices/reasoning-tokens)

#### E. qwen-code Project Limitations

1. **extra_body only supported for OpenAI-compatible providers**
   - The `extra_body` field is **only supported for OpenAI-compatible providers** (`openai`, `qwen-oauth`)
   - It is ignored for Anthropic and Gemini providers
   - **Source:** [model-providers.md](file:///home/ap/code/qwen-code/docs/users/configuration/model-providers.md)

2. **Reasoning config is fragmented**
   - The qwen-code project notes that "Reasoning configuration for OpenAI-compatible endpoints is highly fragmented"
   - Different providers have different parameter names and behaviors
   - The project avoids mapping values and passes through configured reasoning objects when explicitly enabled
   - **Source:** [/home/ap/code/qwen-code/packages/core/src/core/openaiContentGenerator/pipeline.ts](file:///home/ap/code/qwen-code/packages/core/src/core/openaiContentGenerator/pipeline.ts)

---

## Contradictions

| Claim | Source A | Source B | Resolution |
|-------|----------|----------|------------|
| Qwen 3.5 thinking default behavior | Hugging Face: "Qwen3.5 will think by default" | Unsloth: "Small models have thinking disabled by default" | **Resolved:** Larger models (27B+) think by default; small models (0.8B-9B) do not |
| `thinking_budget` support | Alibaba Cloud: Supported for Qwen3 | OpenRouter: "Support varies by model" | **Resolved:** Not all Qwen models support it; check individual model documentation |

---

## Sources by Reliability

**Tier 1 (Official/Authoritative):**
- [Alibaba Cloud Model Studio Documentation](https://www.alibabacloud.com/help/en/model-studio/deep-thinking) - Official API documentation
- [Hugging Face Qwen3.5-27B](https://huggingface.co/Qwen/Qwen3.5-27B) - Official model card
- [OpenRouter Reasoning Tokens Guide](https://openrouter.ai/docs/guides/best-practices/reasoning-tokens) - Official API documentation
- [qwen-code repository](file:///home/ap/code/qwen-code/) - Source code and documentation

**Tier 2 (Reputable Secondary):**
- [Unsloth Documentation](https://unsloth.ai/docs/models/qwen3.5) - Technical documentation for running locally
- [Modelscope Qwen3.5-9B](https://modelscope.cn/models/Qwen/Qwen3.5-9B) - Model repository

**Tier 3 (Informal):**
- [Reddit r/LocalLLaMA](https://www.reddit.com/r/LocalLLaMA/comments/1rgzfat/how_is_qwen_35_moe_35b_in_instruct_mode_with_no/) - Community discussion
- [Medium article](https://medium.com/data-science-in-your-pocket/qwen-3-5-free-api-for-everyone-afcf8ed3adb7) - Blog post

---

## Unanswered Questions (Out of Scope)

The following questions are noted but are outside the scope of this research:

1. **Exact token allocation for Qwen-specific effort levels** - While OpenRouter documents effort levels for OpenAI/Anthropic/Google, Qwen-specific effort mappings are not clearly documented. *Out of scope: Requires direct testing with Qwen API or waiting for official documentation.*

2. **Maximum thinking_budget value** - The documentation mentions minimum values (1024 for Anthropic) but doesn't specify maximum limits for Qwen models specifically. *Out of scope: Requires API testing or official specification.*

3. **Performance impact of different budget values** - No quantitative benchmarks showing how different thinking_budget values affect response quality vs. latency for Qwen 3.5. *Out of scope: Requires benchmark testing.*

4. **Qwen OAuth specific configuration** - The qwen-code project mentions Qwen OAuth as an auth type, but specific thinking configuration for this authentication method is not well documented. *Out of scope: The qwen-code source code shows Qwen OAuth uses the same ContentGeneratorConfig interface, so thinking configuration should work similarly, but this has not been verified through testing.*

---

## Troubleshooting Common Issues

### Thinking Mode Not Working

**Problem:** Model responds without thinking content even with `enable_thinking: true`

**Possible causes:**
1. Using a small model (0.8B, 2B, 4B, 9B) which has thinking disabled by default
   - **Solution:** Explicitly set `enable_thinking: true` in extra_body
2. Model doesn't support thinking_budget parameter
   - **Solution:** Check model documentation or try without budget limit
3. Using Anthropic or Gemini provider where `extra_body` is ignored
   - **Solution:** Use provider-specific configuration (reasoning object for Anthropic)

### Thinking Content Not Visible in Response

**Problem:** Model is thinking but reasoning content not returned

**Possible causes:**
1. `reasoning.exclude: true` is set
   - **Solution:** Set `reasoning.exclude: false` or remove the parameter
2. Provider doesn't return reasoning by default (e.g., OpenAI o-series)
   - **Solution:** Check provider documentation for reasoning output format

### High Token Usage/Costs

**Problem:** Thinking tokens consuming too much of budget

**Solutions:**
1. Set explicit `thinking_budget` limit (e.g., 200-500 tokens)
2. Use lower effort level: `reasoning.effort: "low"` or `"minimal"`
3. Disable thinking for simple queries: `enable_thinking: false`

### Configuration Not Applied

**Problem:** Settings in settings.json not taking effect

**Possible causes:**
1. Using wrong provider type (extra_body only works for `openai` and `qwen-oauth`)
   - **Solution:** Verify authType in modelProviders configuration
2. Provider layer is impermeable - settings layer won't override
   - **Solution:** Configure thinking in modelProviders[].generationConfig, not in model.generationConfig
3. JSON syntax error in settings file
   - **Solution:** Validate JSON syntax

---

## Quick Reference: Configuration Examples

### Minimal Configuration (Enable Thinking)
```json
{
  "model": {
    "generationConfig": {
      "extra_body": {
        "enable_thinking": true
      }
    }
  }
}
```

### With Budget Control
```json
{
  "model": {
    "generationConfig": {
      "extra_body": {
        "enable_thinking": true,
        "thinking_budget": 200
      },
      "samplingParams": {
        "temperature": 1.0,
        "top_p": 0.95,
        "max_tokens": 8192
      }
    }
  }
}
```

### Disable Thinking
```json
{
  "model": {
    "generationConfig": {
      "extra_body": {
        "enable_thinking": false
      },
      "samplingParams": {
        "temperature": 0.7,
        "top_p": 0.8
      }
    }
  }
}
```

### Using modelProviders (Recommended)
```json
{
  "modelProviders": {
    "openai": [
      {
        "id": "qwen3.5-plus",
        "name": "Qwen 3.5 Plus",
        "envKey": "DASHSCOPE_API_KEY",
        "baseUrl": "https://dashscope-intl.aliyuncs.com/compatible-mode/v1",
        "generationConfig": {
          "extra_body": {
            "enable_thinking": true,
            "thinking_budget": 500
          }
        }
      }
    ]
  }
}
```
