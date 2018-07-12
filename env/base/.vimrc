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

" a bit faster vim
set lazyredraw 
highlight NonText cterm=NONE ctermfg=NONE

set number
set numberwidth=5
set noruler

runtime .vimrc-colors.vim

" Set formatter gq
set formatprg=par\ -w70

" Set Auto-indent options
set cindent
set smartindent
set autoindent
set ttyfast " Indicates a fast terminal connection

" Enable Spell Checking
" set spell

" Cursor styles
set cul

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
    autocmd InsertEnter * set nocul
    autocmd InsertLeave * set cul

    " make uses real tabs
    au FileType make   set noexpandtab
    " au FileType python set noexpandtab

    " Thorfile, Rakefile and Gemfile are Ruby
    au BufRead,BufNewFile {Gemfile,Gemfile.local,Rakefile,Thorfile,config.ru} set ft=ruby

    " Remember last location in file
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
          \| exe "normal g'\"" | endif

    " Remove trailing whitespaces on save
    autocmd FileType c,cpp,python,ruby,php,java autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

    " Use 4 spaces in php files
    autocmd FileType php setlocal shiftwidth=4 tabstop=4 softtabstop=4

    autocmd FileType ruby setlocal re=1

    " collapse .vimrc
    autocmd FileType vim normal zM

    " Indent p tags
    " autocmd FileType html,eruby if g:html_indent_tags !~ '\\|p\>' | let g:html_indent_tags .= '\|p\|li\|dt\|dd' | endif

    " Autoclean fugitive buffers
    autocmd BufReadPost fugitive://* set bufhidden=delete

    autocmd BufNewFile,BufRead COMMIT_EDITMSG setlocal spell

    " Handle relative numbers
    " autocmd InsertEnter * :set number
    " autocmd InsertLeave * :set relativenumber
  augroup END
endif

"#############################################
"            Plugins configs              {{{1
"#############################################

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
let g:SuperTabDefaultCompletionType = "<c-p>"
let g:SuperTabContextDefaultCompletionType = "<c-p>"
let g:SuperTabCompletionContexts = ['s:ContextText', 's:ContextDiscover']
let g:SuperTabLongestEnhanced = 1
let g:SuperTabNoCompleteAfter = ['^', '\s', '{', '[', '(', '|']

"----------------
" CTRLP
"----------------
let g:ctrlp_use_caching = 1
let g:ctrlp_max_files = 90000
let g:ctrlp_clear_cache_on_exit = 0
" let g:ctrlp_user_command = ['.git/', 'cd %s && git ls-files']
let g:ctrlp_arg_map = 1
let g:ctrlp_show_hidden = 1
" let g:ctrlp_root_markers = ['tags']
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v(tmp|log|\.git|\.hg|\.svn|\.bundle)$',
  \ 'file': '\v(\.log|tags)$',
  \ }

"----------------
" Syntastic
"----------------
let g:airline#extensions#ale#enabled = 1
let g:ale_fixers = {
      \   'elixir': ['mix_format'],
      \}
let g:ale_sign_error='⚠'

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
let vim_markdown_preview_github=1
let vim_markdown_preview_hotkey='<C-m>'


"---------------
" Polyglot
"---------------
let g:jsx_ext_required = 1

"#############################################
"             Leader Mappings             {{{1
"#############################################

"----------------
" Fugitive
"----------------
nnoremap <leader>gc :Gst<CR>
nnoremap <leader>gl :Glog -- %<CR>
" Search for word under the cursor using git
nnoremap <leader>gs :Ggrep <C-r><C-w><CR>


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
nnoremap <leader>. :R<CR>

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
let g:LargeFile = 2

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
nnoremap <leader>i gg=G\|

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

"----------------
" Ctrl keys
"----------------
" Omni complete by Ctrl + Space
imap <C-Space> <C-x><C-o>
imap <C-@> <C-Space>

"Time tree
nnoremap <F9> :GundoToggle<CR>

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
" runtime .vimrc-startup.vim

"#############################################
"                 Functions              {{{1
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

