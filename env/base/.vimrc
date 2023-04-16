" vim: foldmethod=marker
set nocompatible               " be iMproved

"#############################################
"                 Plugins                 {{{1
"#############################################
runtime .vimrc-bundles.vim

"#############################################
"               Configuration             {{{1
"#############################################

" Leader key
let mapleader=','

set laststatus=2
set encoding=utf-8
set hidden
set cmdheight=2
set switchbuf=useopen
set clipboard=unnamed
" display incomplete commands
set showcmd
" Enable highlighting for syntax
syntax on
" don't give |ins-completion-menu| messages.
set shortmess+=c

" a bit faster vim
set lazyredraw
highlight NonText cterm=NONE ctermfg=NONE
set nocursorline
set synmaxcol=400

set number
set numberwidth=5
set noruler

runtime .vimrc-colors.vim

" Set formatter gq
set formatprg=par\ -w120

" Set Auto-indent options
set cindent
set smartindent
set autoindent
set ttyfast " Indicates a fast terminal connection

" Enable Spell Checking
" set spell

" visible lines
set scrolloff=8

" Whitespace stuff
set nowrap
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

set list listchars=tab:▸\ ,trail:·,nbsp:·

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" Tab completion
set wildignore+=.git/*,.svn/*
set completeopt=menu
set complete-=i " do not hang on included files
set pumheight=15
" Cmd menu
set wildmenu
set wildmode=list:longest

" History & backups
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

set history=50

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" added '<buffer>' to guard against this mapping from being used in other
" filetypes
" inoremap <buffer><silent><Bar>   <Bar><Esc>:call <SID>align()<CR>a


"#############################################
"                  Autocmd                {{{1
"#############################################

if has("autocmd")
  augroup EditVim
    autocmd!
    " autocmd InsertEnter * set nocul
    " autocmd InsertLeave * set cul

    " make uses real tabs
    au FileType make,go   set noexpandtab
    " au FileType python set noexpandtab

    au FileType go   set nolist

    " Thorfile, Rakefile and Gemfile are Ruby
    au BufRead,BufNewFile {Gemfile,Gemfile.local,Rakefile,Thorfile,config.ru} set ft=ruby

    " Remember last location in file
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
          \| exe "normal g'\"" | endif

    " Remove trailing whitespaces on save
    autocmd FileType c,cpp,python,ruby,php,java,go,elixir autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

    au FileType ruby set re=1

    " Use 4 spaces in php files
    autocmd FileType php,kotlin setlocal shiftwidth=4 tabstop=4 softtabstop=4
    autocmd FileType eelixir setlocal shiftwidth=2 tabstop=2 softtabstop=2

    " collapse .vimrc
    autocmd FileType vim normal zM

    autocmd FileType scss setl iskeyword+=@-@

    " Indent p tags
    " autocmd FileType html,eruby if g:html_indent_tags !~ '\\|p\>' | let g:html_indent_tags .= '\|p\|li\|dt\|dd' | endif

    " Autoclean fugitive buffers
    autocmd BufReadPost fugitive://* set bufhidden=delete

    autocmd BufNewFile,BufRead COMMIT_EDITMSG setlocal spell
    autocmd FileType python let b:coc_root_patterns = ['.git', '.env']
    autocmd FileType elixir let b:coc_root_patterns = ['mix.exs']

    " Handle relative numbers
    " autocmd InsertEnter * :set number
    " autocmd InsertLeave * :set relativenumber
  augroup END
endif

"#############################################
"            Plugins configs              {{{1
"#############################################


"----------------
" Copilot
"----------------
imap <silent><script><expr> <End> copilot#Accept("\<CR>")
imap <silent><script><expr> <Home> copilot#Next()

let g:copilot_no_tab_map = v:true

"----------------
" Ruby refactoring
"----------------
let g:ruby_refactoring_map_keys=0

"----------------
" NerdTree
"----------------
let NERDTreeShowHidden=1
let NERDTreeMapOpenSplit = "s"
let NERDTreeMapOpenVSplit = "v"
let NERDTreeMinimalUI = 1
let NERDTreeIgnore=['\.rbc$', '\~$', '\.git$', '\.bundle$', '\.elasticbeanstalk$']

"----------------
" Golden ratio
"----------------
let g:golden_ratio_autocommand = 0

"----------------
" Airline
"----------------
let g:airline_powerline_fonts = 1

"----------------
" Ruby.vim
"----------------
let ruby_minlines = 600
let ruby_operators = 1
let ruby_space_errors = 1

"----------------
" Ruby.vim omni complete
"----------------
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_rails = 1

"----------------
" Supertab
"----------------
let g:SuperTabDefaultCompletionType = "<c-n>"
let g:SuperTabContextDefaultCompletionType = "<c-n>"
let g:SuperTabCompletionContexts = ['s:ContextText', 's:ContextDiscover']
let g:SuperTabLongestEnhanced = 1
let g:SuperTabNoCompleteAfter = ['^', '\s', '{', '[', '(', '|']
" autocmd FileType *
"   \ if &omnifunc != '' |
"   \   call SuperTabChain(&omnifunc, '<c-p>') |
"   \ endif

" let g:SuperTabContextTextOmniPrecedence = ['&omnifunc', '&completefunc']
" let g:SuperTabContextDiscoverDiscovery =
"     \ ["&completefunc:<c-x><c-u>", "&omnifunc:<c-x><c-o>"]



"----------------
" CTRLP
"----------------
let g:ctrlp_use_caching = 1
let g:ctrlp_max_files = 100000
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_user_command = ['.git/', 'cd %s && git ls-files']
let g:ctrlp_arg_map = 1
let g:ctrlp_show_hidden = 1
" let g:ctrlp_root_markers = ['tags']

" let g:ctrlp_user_command = 'find %s -type f'       " MacOSX/Linux
let g:ctrlp_mruf_max = 100
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v(node_modules|tmp|log|\.git|\.hg|\.svn|\.bundle)$',
  \ 'file': '\v(\.log|tags)$',
  \ }

"----------------
" ALE
"----------------
" let g:ale_javascript_prettier_use_local_config = 1
" let g:airline#extensions#ale#enabled = 1
" let g:ale_completion_enabled = 1
let g:ale_sign_error='✘'
let g:ale_sign_warning='⚠'
let g:ale_sign_info='i>'
let g:ale_sign_style_error='ஐ'
let g:ale_sign_style_warning='ஐ'
let g:ale_lint_on_text_changed = 'never'
let g:ale_fix_on_save = 0
" let g:ale_typescript_tsserver_use_global = 0

let g:ale_fixers = {
\   'elixir': ['mix_format'],
\   'typescript': [
\       'prettier',
\       'remove_trailing_lines',
\       'trim_whitespace'
\   ],
\   'javascript': [
\       'prettier',
\       'remove_trailing_lines',
\       'trim_whitespace'
\   ],
\   'kotlin': [
\       'remove_trailing_lines',
\       'trim_whitespace'
\   ],
\   'go': [
\       'gofmt',
\       'goimports',
\       'remove_trailing_lines',
\       'trim_whitespace'
\   ],
\   'ruby': [
\       'rubocop',
\       'standardrb',
\       'remove_trailing_lines',
\       'trim_whitespace'
\   ],
\}
" \   'ruby': ['standardrb', 'rubocop'],
let g:ale_linters = {
\   'ruby': ['standardrb', 'rubocop'],
\   'typescript': [
\       'tsserver',
\   ]
\}

" let g:ale_linters = {
" \   'kotlin': [
" \       'languageserver',
" \       'ktlint',
" \   ],
" \   'ruby': ['standardrb', 'rubocop'],
" \   'typescript': [
" \       'tsserver',
" \   ]
" \}

" inoremap <silent><expr> <Tab>
"       \ pumvisible() ? "\<C-n>" : "\<TAB>"

" let g:ale_kotlin_kotlinc_enable_config = 1

" let g:syntastic_warning_symbol='⚠'
" let g:syntastic_auto_loc_list=2
" let g:syntastic_enable_highlighting = 1
" let g:syntastic_enable_balloons = 0
" let g:syntastic_enable_signs=1
" let g:syntastic_echo_current_error=1
" let g:syntastic_javascript_checkers = ['eslint']
" let g:syntastic_javascript_eslint_exec = '~/.bash/.eslint_npm.sh'

" let g:syntastic_elixir_checkers = ['elixir']
" let g:syntastic_enable_elixir_checker = 1

"----------------
" Ack
"----------------
let g:ack_default_options = " -H --nocolor --nogroup --column --smart-case --follow"
if executable('ag')
  let g:ackprg = 'ag'
endif

"----------------
" Markdown
" ---------------
nmap <silent> <C-s> :CocCommand markdown-preview-enhanced.openPreview<CR>

"---------------
" Polyglot
"---------------
let g:jsx_ext_required = 1

"#############################################
"             Leader Mappings             {{{1
"#############################################
"----------------
" Test runners
"----------------
nnoremap <leader>to :cclose<CR>

"----------------
" Fugitive
"----------------
nnoremap <leader>gc :G<CR>
" nnoremap <leader>gl :G log --graph --decorate --pretty=oneline --abbrev-commit -- %<CR>
nnoremap <leader>gl :0Gclog<CR>
" Search for word under the cursor using git
nnoremap <leader>gs :Ggrep <C-r><C-w><CR>
" nnoremap <leader>as :ALEFindReferences<CR>

"----------------
" CTags
"----------------
noremap <leader>rt :!ctags -f tags --extra=+f --fields=+l --exclude=tmp --exclude=log --exclude=node_modules --exclude=vendor -R *<CR><CR>

"----------------
" Golden ratio
"----------------
nnoremap <F7> :GoldenRatioToggle<CR>

"----------------
" Tabularize
"----------------
nnoremap <leader>t= :tabularize /=<cr>
vnoremap <leader>t= :Tabularize /=<CR>
nnoremap <leader>t: :Tabularize /:\zs<CR>
vnoremap <leader>t: :Tabularize /:\zs<CR>
vnoremap <leader>t, :Tabularize /,\zs<CR>
nnoremap <leader>t, :Tabularize /,\zs<CR>
nnoremap <leader>t=> :Tabularize /=><CR>
vnoremap <leader>t=> :Tabularize /=><CR>

"----------------
" Rails
"----------------
" nnoremap <leader>. :call EditAlternativeFile()<CR>
nnoremap <leader>. :A<CR>

"----------------
" NerdTree
"----------------
nnoremap <leader>n :NERDTreeToggle<CR>

"----------------
" PHP doc
"----------------
" noremap <leader>pd :call PhpDoc()<CR>

"----------------
" Buffer window (find file in open buffers)
"----------------
nmap <silent> <leader>b :FufBuffer<CR>

"----------------
" Ruby refactoring
"----------------
:nnoremap <leader>rp  :RAddParameter<cr>
:nnoremap <leader>rl  :RExtractLet<cr>
:nnoremap <leader>ri  :RInlineTemp<cr>
:nnoremap <leader>rf  :RConvertPostConditional<cr>

:vnoremap <leader>rl  :RExtractLocalVariable<cr>
:vnoremap <leader>rc  :RExtractConstant<cr>
:vnoremap <leader>rrl :RRenameLocalVariable<cr>
:vnoremap <leader>rri :RRenameInstanceVariable<cr>
:vnoremap <leader>rm  :RExtractMethod<cr>


"----------------
" Large file
"----------------
let g:LargeFile = 10

"----------------
" COC
"----------------
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
" xmap <leader>f  <Plug>(coc-format-selected)
" nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for select selections ranges, needs server support, like: coc-tsserver, coc-python
" nmap <silent> <TAB> <Plug>(coc-range-select)
" xmap <silent> <TAB> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Using CocList
" Show all diagnostics
nnoremap <silent> <leader><space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <leader><space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <leader><space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <leader><space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <leader><space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <leader><space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <leader><space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <leader><space>p  :<C-u>CocListResume<CR>

"----------------
" General
"----------------
" Pressing ,v opens the vimrc file in a new tab.
nnoremap <leader>v :e $MYVIMRC<CR>

" Toggle spaces and tabs
nnoremap <leader>l :set list!<CR>

" Edit file in same directory
noremap <leader>e :edit %:h/

" OS clipboard
nnoremap <leader>y "+y
vnoremap <leader>y "+y

nnoremap <leader>p "+p
vnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>P "+P

" Auto indent whole file
" TODO:  does not work
" nnoremap <leader>i gg=G\|
nnoremap <leader>i :Format<CR>
" noremap <leader>h :ALEHover<CR>
autocmd FileType typescript let b:coc_root_patterns = ['tsconfig.json', '.env', '.git']


"#############################################
"               Key bindings              {{{1
"#############################################

inoremap <Del> <Esc>
nnoremap <Del> <Esc>
vnoremap <Del> <Esc>

imap jj <Esc>l

" Hide search highlighting
nnoremap <silent> <Space> :noh<CR>

"----------------
" F keys
"----------------
nnoremap <F1> :ALEFix<CR>
"Save file
nnoremap <F2> :wa<CR>
vnoremap <F2> :wa<CR>
inoremap <F2> <ESC>:wa<CR>

"Close buffer
noremap <F12> :bd<CR>

noremap <F4> <Esc>:TlistToggle<CR>
noremap <F3> <Esc>:NERDTreeToggle<CR>

" Cycle buffer switch
inoremap <F6> <Esc> :bn <CR>i
noremap <F6> :bn <CR>
inoremap <F5> <Esc> :bp <CR>i
noremap <F5> :bp <CR>

nnoremap <F8> :call <SID>ToggleBreakpoint()<CR>


"----------------
" Ctrl keys
"----------------
" Omni complete by Ctrl + Space
" imap <C-Space> <C-x><C-o>
" imap <C-@> <C-Space>

"Time tree
nnoremap <F9> :GundoToggle<CR>
" noremap ]g <C-w>j<C-w>q<C-w>k<C-n>
" noremap [g <C-w>j<C-w>q<C-w>k<C-p>

"----------------
" [] keys
"----------------

" noremap <C-]> :ALEGoToDefinition<CR>

"#############################################
"                 Enviroment              {{{1
"#############################################
runtime .vimrc-environment.vim

"#############################################
"                 Folding                 {{{1
"#############################################
runtime .vimrc-folding.vim

"#############################################
"                 Startup                 {{{1
"#############################################
runtime .vimrc-startup.vim

"#############################################
"                 Functions               {{{1
"#############################################

" smart file rename
" stolen from: https://github.com/garybernhardt/dotfiles/blob/master/.vimrc
function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'))
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction
map <leader>m :call RenameFile()<cr>

function! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

function! AlternativeFile()
  let current_path = expand('%')

  if current_path =~ '.spec.ts$'
    return substitute(current_path, ".spec.ts$", ".ts", "")
  endif

  if current_path =~ '.ts$'
    return substitute(current_path, ".ts$", ".spec.ts", "")
  endif

  if current_path =~ '^app/'
    let spec_folder = substitute(current_path, "^app/", "spec/", "")
    let spec_file = substitute(spec_folder, ".rb$", "_spec.rb", "")
    return spec_file
  endif

  if current_path =~ '^lib/'
    let spec_folder = substitute(current_path, "^lib/", "test/", "")
    let spec_file = substitute(spec_folder, ".ex$", "_test.exs", "")
    return spec_file
  endif

  " if current_path =~ '^lib/'
  "   let spec_folder = substitute(current_path, "^lib/", "spec/lib/", "")
  "   let spec_file = substitute(spec_folder, ".rb$", "_spec.rb", "")
  "   return spec_file
  " endif

  if current_path =~ '^spec/lib'
    let app_folder = substitute(current_path, "^spec/lib", "lib/", "")
    let app_file = substitute(app_folder, "_spec.rb$", ".rb", "")
    return app_file
  endif

  if current_path =~ '^spec/'
    let app_folder = substitute(current_path, "^spec/", "app/", "")
    let app_file = substitute(app_folder, "_spec.rb$", ".rb", "")
    return app_file
  endif

  if current_path =~ '^test/'
    let spec_folder = substitute(current_path, "^test/", "lib/", "")
    let spec_file = substitute(spec_folder, "_test.exs$", ".ex", "")
    return spec_file
  endif
endfunction

function! EditAlternativeFile()
  exec ':e ' . AlternativeFile()
  return
endfunction

func! s:SetBreakpoint()
    cal append('.', repeat(' ', strlen(matchstr(getline('.'), '^\s*'))) . 'import ipdb; ipdb.set_trace()')
endf

func! s:RemoveBreakpoint()
    exe 'silent! g/^\s*import\sipdb\;\?\n*\s*ipdb.set_trace()/d'
endf

func! s:ToggleBreakpoint()
    if getline('.')=~#'^\s*import\sipdb' | cal s:RemoveBreakpoint() | el | cal s:SetBreakpoint() | en
endf
