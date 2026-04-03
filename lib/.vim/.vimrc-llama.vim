" llama.vim configuration - proxy integration
" Uses llama.vim defaults, only overrides what's needed

"--------------------------------------
" Endpoint configuration
"--------------------------------------
let g:llama_config = {}

" --------------------------------------
" FIM - Granite 32B MoE (rocm, 977/68) - precise
"--------------------------------------
let g:llama_config.endpoint_fim = 'http://127.0.0.1:8093/infill'
let g:llama_config.endpoint_inst = 'http://127.0.0.1:8093/v1/chat/completions'

" --------------------------------------
" FIM - 30B A3 Coder Q4 (vulkan, 2062/203) - verbose
"--------------------------------------
" let g:llama_config.endpoint_fim = 'http://127.0.0.1:8091/infill'
" let g:llama_config.endpoint_inst = 'http://127.0.0.1:8091/v1/chat/completions'

" --------------------------------------
" FIM - 35B IQ4 (vulkan, 3375/134) - bad for FIM
"--------------------------------------
" let g:llama_config.endpoint_fim = 'http://127.0.0.1:8092/infill'
" let g:llama_config.endpoint_inst = 'http://127.0.0.1:8092/v1/chat/completions'

" --------------------------------------
" FIM - StableDiffCoder 8B (rocm, 2583/78) - doesnt work?
"--------------------------------------
" let g:llama_config.endpoint_fim = 'http://127.0.0.1:8094/infill'
" let g:llama_config.endpoint_inst = 'http://127.0.0.1:8094/v1/chat/completions'

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
let g:llama_config.n_predict_fim = 256     " FIM: short completions
let g:llama_config.n_predict_inst = 8192   " Instruct: long-form
let g:llama_config.max_line_suffix = 16    " default: 8 - chars after cursor before auto-trigger
let g:llama_config.t_max_predict_ms = 60000

"--------------------------------------
" Configuration
"-------------------------------------
let g:llama_config.show_info = v:false

"--------------------------------------
" Gruvbox dark theme colors
"--------------------------------------
highlight llama_hl_fim_hint guifg=#83a598 ctermfg=241
highlight llama_hl_fim_info guifg=#b8bb26 ctermfg=243

highlight llama_hl_inst_virt_proc  guifg=#cccccc ctermfg=113 gui=bold
highlight llama_hl_inst_virt_gen   guifg=#fe8019 ctermfg=208 gui=bold
highlight llama_hl_inst_virt_ready guifg=#b8bb26 ctermfg=108 gui=bold
