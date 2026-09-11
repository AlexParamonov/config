" llama.vim configuration - proxy integration
" Uses llama.vim defaults, only overrides what's needed

"--------------------------------------
" Endpoint configuration
"--------------------------------------
let g:llama_config = {}

let g:llama_config.endpoint_fim = 'http://127.0.0.1:8080/infill'
let g:llama_config.endpoint_inst = 'http://127.0.0.1:8080/v1/chat/completions'
" --------------------------------------
" FIM - Granite 32B MoE (rocm, 977/68) - precise
"--------------------------------------
let g:llama_config.model_fim = 'fim_granite_32b'
let g:llama_config.model_inst = 'fim_granite_32b'

" --------------------------------------
"  9b
" --------------------------------------
" let g:llama_config.model_fim = '9b_think'
" let g:llama_config.model_inst = '9b_think'

" --------------------------------------
" FIM - Gemma 4 MoE
"--------------------------------------
" let g:llama_config.model_fim = 'fim_gemma_26b'
" let g:llama_config.model_inst = 'fim_gemma_26b'

" --------------------------------------
" FIM - 30B A3 Coder Q4 (vulkan, 2062/203) - verbose
"--------------------------------------
" let g:llama_config.model_fim = 'fim_30b_coder'
" let g:llama_config.model_inst = 'fim_30b_coder'

" --------------------------------------
" FIM - 35B IQ4 (vulkan, 3375/134) - bad for FIM
"--------------------------------------
" let g:llama_config.model_fim = 'fim_35b_iq4'
" let g:llama_config.model_inst = 'fim_35b_iq4'
" let g:llama_config.model_fim = '35B_think_IQ4_MTP'
" let g:llama_config.model_inst = '35B_think_IQ4_MTP'

"--------------------------------------
" Keymaps - use <leader>l instead of <leader>ll
"--------------------------------------
let g:llama_config.keymap_fim_trigger = '<leader>lf'       " Trigger FIM completion
let g:llama_config.keymap_fim_accept_word = '<leader>ll'   " Accept current word
let g:llama_config.keymap_fim_accept_line = '<End>'      " Accept current line
let g:llama_config.keymap_fim_accept_full = '<S-End>'        " Accept full suggestion

let g:llama_config.keymap_inst_trigger = '<leader>li'      " Trigger instruction mode
let g:llama_config.keymap_inst_rerun = '<leader>lr'        " Rerun instruction
let g:llama_config.keymap_inst_continue = '<leader>lc'     " Continue generation
let g:llama_config.keymap_debug_toggle = '<leader>ld'      " Toggle debug mode

" Accept suggestions by end key
let g:llama_config.keymap_fim_accept_end = '<End>'

"--------------------------------------
" Ring buffer - optimized for quality/token ratio
"--------------------------------------
let g:llama_config.n_suffix = 96           " default: 64 - see closing braces, return types
let g:llama_config.ring_n_chunks = 16      " default: 16 - cross-file context
let g:llama_config.ring_chunk_size = 64    " default: 64 - lines per chunk
let g:llama_config.n_predict = 8192        " Instruct: long-form
let g:llama_config.max_line_suffix = 16    " default: 8 - chars after cursor before auto-trigger
let g:llama_config.t_max_predict_ms = 60000

"--------------------------------------
" Configuration
"-------------------------------------
let g:llama_config.show_info = v:false
let g:llama_config.inst_temperature = 0.7

" Instruct system prompt (custom: local context only, no cross-file CONTEXT)
" Structure: contract first, few-shot example in the middle, contract restated last.
" Weak local models follow the start and end of the prompt most reliably.
let g:llama_config.inst_system_prompt = 
      \ "You are a code editing engine running inside the vim text editor. You never converse with the user: your entire reply is inserted verbatim into their file, replacing the selected code."
      \ . "\nThe code the user selected in the buffer - your reply replaces exactly this:"
      \ . "\n<TEXT_BLOCK>%SELECTION%</TEXT_BLOCK>"
      \ . "\nCode above the selection (context only, do not change): <PREFIX>%PREFIX%</PREFIX>"
      \ . "\nCode below the selection (context only, do not change): <SUFFIX>%SUFFIX%</SUFFIX>"
      \ . "\nThe user's request arrives as the message 'INSTRUCTION: ...'. Apply it to the <TEXT_BLOCK> only."
      \ . "\nYour reply is new file content, not a message to a person. The first character you write is the first character that goes into the file. No preamble of any kind (no 'Here is ...'), no explanation, no markdown, no code fences, no tags - just the replacement."
      \ . "\nExample (note: the REPLY is only code, nothing else):"
      \ . "\nSELECTION:"
      \ . "\n    def add(a, b):"
      \ . "\n        return a + b"
      \ . "\nINSTRUCTION: rename the function to sum2"
      \ . "\nREPLY:"
      \ . "\n    def sum2(a, b):"
      \ . "\n        return a + b"
      \ . "\nRules:"
      \ . "\n- Keep the exact indentation (tabs or spaces) of every line you keep."
      \ . "\n- Keep existing comments and style unless the instruction asks to change them."
      \ . "\n- Never output the <TEXT_BLOCK>, <PREFIX> or <SUFFIX> tags themselves."
      \ . "\nNow apply the INSTRUCTION. Your reply starts with the replacement - nothing before it, nothing after it."

"--------------------------------------
" Gruvbox dark theme colors
"--------------------------------------
highlight llama_hl_fim_hint guifg=#83a598 ctermfg=241
highlight llama_hl_fim_info guifg=#b8bb26 ctermfg=243

highlight llama_hl_inst_virt_proc  guifg=#cccccc ctermfg=113 gui=bold
highlight llama_hl_inst_virt_gen   guifg=#fe8019 ctermfg=208 gui=bold
highlight llama_hl_inst_virt_ready guifg=#b8bb26 ctermfg=108 gui=bold
