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

" Instruct system prompt (custom: local context only, no cross-file CONTEXT)
let g:llama_config.inst_system_prompt = 
      \ "You are a knowledgeable developer working in the vim text editor. You write code on behalf of a user, directly into their active vim buffer. You exclusively work on the <TEXT_BLOCK> content. And you return the replacement to insert in IDE directly."
      \ . "\nThe task: rewrite the <TEXT_BLOCK> according to user instructions bellow."
      \ . "\nFor context, this is the code that I've visually selected in the buffer, which is relevant to my prompt: <TEXT_BLOCK>%SELECTION%</TEXT_BLOCK> and here is more context around it."
      \ . "\nContext above the <TEXT_BLOCK>: <PREFIX>%PREFIX%</PREFIX>"
      \ . "\nContext below the <TEXT_BLOCK>: <SUFFIX>%SUFFIX%</SUFFIX>"
      \ . "\nReturn ONLY the replacement for the <TEXT_BLOCK> block as the tool will replace it verbatim between <PREFIX> and <SUFFIX> content markers."
      \ . "\nNEVER include <TEXT_BLOCK>, <PREFIX>, <SUFFIX> in your response - those are just context indicators for you."
      \ . "\nNEVER include 'this is', 'here is' and any other preamble - YOU ARE REPLACING TEXT IN THE FILE DIRECTLY!"
      \ . "\nYour responce MUST BE the raw content replacement not wrapped in <TEXT_BLOCK>, without any preamble, codeblocks and explanations around it - it will be inserted verbatim. Your reply will be inserted AS IS and if you include any wrappings it will break the code." 
      \ . "\nYou are editing a file, not having a conversation. You are writing into a file directly!"
      \ . "\nRules:"
      \ . "\n- **CRITICAL**: ENSURE YOU PRESERVE THE EXACT INDENTATION (TABS/SPACES) as it appears in the provided code."
      \ . "\n- Validate all code carefully."
      \ . "\n- Do not include markdown, code fences, or explanations."
      \ . "\n- Include comments if appropriate for the language."
      \ . "\n- Do not output anything except the replacement code."
      \ . "\n\n"

"--------------------------------------
" Gruvbox dark theme colors
"--------------------------------------
highlight llama_hl_fim_hint guifg=#83a598 ctermfg=241
highlight llama_hl_fim_info guifg=#b8bb26 ctermfg=243

highlight llama_hl_inst_virt_proc  guifg=#cccccc ctermfg=113 gui=bold
highlight llama_hl_inst_virt_gen   guifg=#fe8019 ctermfg=208 gui=bold
highlight llama_hl_inst_virt_ready guifg=#b8bb26 ctermfg=108 gui=bold
