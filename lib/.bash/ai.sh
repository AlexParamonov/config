# Claude Code - Enable experimental MCP-CLI for reduced token consumption
export ENABLE_EXPERIMENTAL_MCP_CLI=true

# Turn off telemetry
export BETA_TRACING_ENDPOINT=http://127.0.0.1/fakeuri
export ENABLE_ENHANCED_TELEMETRY_BETA=0
export CLAUDE_CODE_ENABLE_TELEMETRY=0
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1
export DISABLE_TELEMETRY=1
export OTEL_LOG_USER_PROMPTS=0
export GEMINI_TELEMETRY_ENABLED=false
export LOCAL_API_KEY="not-needed"

export OMO_DISABLE_POSTHOG=true

# opencode
export PATH=/home/ap/.opencode/bin:$PATH

# llama -hf
export HF_HOME=~/models
export LLAMA_CACHE=~/models
export LLAMACPP_API_KEY=noop
# Quick question — 35B instruct IQ4, with context and system prompt, read-only tools
alias q='pi -p --provider llamacpp --model 35B_instruct_IQ4_MTP --no-session --thinking off --no-skills --no-extensions --tools read,bash,grep,find,ls'

# Quick question — bare minimum, free model, no tools
alias qq='pi -p --provider openrouter --model openrouter/free --no-session --thinking off --no-skills --no-extensions --no-context-files --system-prompt "" --no-tools'
