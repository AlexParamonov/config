filetype off                   " required!
" No need for vi compatibility
set nocompatible
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
Bundle 'gmarik/vundle'

" Custom bundles
" Bundle 'jnurmine/Zenburn'
Bundle 'tpope/vim-fugitive'

Bundle 'altercation/vim-colors-solarized'
let g:solarized_termcolors=16
Bundle 'ervandew/supertab'
Bundle 'tpope/vim-markdown'

" ruby-related plugins
Bundle 'vim-ruby/vim-ruby'
Bundle 'jgdavey/vim-blockle'
Bundle 'tpope/vim-rails'
Bundle 'astashov/vim-ruby-debugger'
let g:ruby_debugger_no_maps = 1
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-cucumber'
Bundle 'tpope/vim-bundler'
Bundle 'tpope/vim-rake'
Bundle 'tpope/vim-endwise'

" PHP-related plugins
Bundle 'vexxor/phpdoc.vim'

Bundle 'Townk/vim-autoclose'
" Bundle 'jiangmiao/auto-pairs'
Bundle 'tpope/vim-unimpaired'
Bundle 'tpope/vim-speeddating'
Bundle 'tpope/vim-repeat'
Bundle 'kien/ctrlp.vim'
Bundle 'tpope/vim-commentary'
" Bundle 'fholgado/minibufexpl.vim'
Bundle 'godlygeek/tabular'
Bundle 'tpope/vim-surround'
" Bundle 'sjl/gundo.vim'
Bundle "Lokaltog/vim-powerline"
Bundle "scrooloose/nerdtree.git"
Bundle "scrooloose/nerdcommenter"

Bundle "MarcWeber/vim-addon-mw-utils"
Bundle "tomtom/tlib_vim"
Bundle "honza/snipmate-snippets"
Bundle "garbas/vim-snipmate"


set laststatus=2
filetype plugin indent on

set encoding=utf-8

" Line numbering
set number
set numberwidth=4
set ruler
set hidden

" We want colors!
syntax on

"no delay!
" set timeout timeoutlen=1000 ttimeoutlen=100
" set notimeout ttimeout ttimeoutlen=100
imap jj <Esc>:<Esc>

set t_Co=256
set background=dark
" colorscheme zenburn
colorscheme solarized
set guifont="Ubuntu\ Mono"

" Set formatter gq
set formatprg=par\ -w70

" Set Auto-indent options
set cindent
set smartindent
set autoindent

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

"set list listchars=tab:▸\ ,eol:¬,trail:·,nbsp:·
set list listchars=tab:▸\ ,trail:·,nbsp:·

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" Tab completion
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*  " Linux/MacOSX
set completeopt=menu
set dictionary-=/usr/share/dict/words dictionary+=/usr/share/dict/words
" set complete-=k complete+=k

" History & backups
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

set history=50

" Autocomd
if has("autocmd")
  autocmd InsertEnter * set nocul
  autocmd InsertLeave * set cul

  " Source the vimrc file after saving it
  autocmd bufwritepost .vimrc source $MYVIMRC

  " save all buffers when (g)vim looses focus
  au FocusLost * :wa

  " make and python use real tabs
  au FileType make   set noexpandtab
  au FileType python set noexpandtab

  " Thorfile, Rakefile and Gemfile are Ruby
  au BufRead,BufNewFile {Gemfile,Gemfile.local,Rakefile,Thorfile,config.ru} set ft=ruby

  " Remember last location in file
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
        \| exe "normal g'\"" | endif

  set title
  autocmd BufEnter * let &titlestring = "vim " . expand("%")

  " Remove trailing whitespaces on save
  " autocmd FileType c,cpp,python,ruby,java autocmd BufWritePre <buffer> :%s/\s\+$//e
  autocmd FileType c,cpp,python,ruby,php,java autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

  " Use 4 spaces in php files
  autocmd FileType php setlocal shiftwidth=4 tabstop=4 softtabstop=4
endif

" Highlight characters in column >80
" set colorcolumn=80

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" added '<buffer>' to guard against this mapping from being used in other
" filetypes
inoremap <buffer><silent><Bar>   <Bar><Esc>:call <SID>align()<CR>a

"""""""""""""""""""""
" Plugins configs
"
"""""""""""""""""""""

" Powerline
let Powerline_symbols="fancy"
let Powerline_colorscheme="skwp"
let Powerline_cache_enabled=1

" Ruby.vim
let ruby_minlines = 600
let ruby_operators = 1
let ruby_space_errors = 1

" Ruby.vim omni complete
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_rails = 1

" Supertab
let g:SuperTabDefaultCompletionType = "<c-p>"
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabContextDefaultCompletionType = "<c-p>"
let g:SuperTabCompletionContexts = ['s:ContextText', 's:ContextDiscover']
let g:SuperTabContextTextOmniPrecedence = ['&omnifunc', '&completefunc']
" let g:SuperTabLongestEnhanced = 1
let g:SuperTabNoCompleteAfter = ['\s', '{', '[', '(', '|']

" CTRLP
let g:ctrlp_max_files = 90000
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_user_command = ['.git/', 'cd %s && git ls-files']

" SnipMate
let g:snips_author = 'Alexander Paramonov'

"""""""""""""""""""""
" Leader Mappings
"
"""""""""""""""""""""

" Leader key
let mapleader=','

" Pressing ,v opens the vimrc file in a new tab.
nnoremap <leader>v :e $MYVIMRC<CR>

" CTags
noremap <leader>rt :!ctags --extra=+f --exclude=tmp --exclude=log -R *<CR><CR>

" Tabs
if exists(":Tabularize")
  nnoremap <leader>= :Tabularize /=<CR>
  vnoremap <leader>= :Tabularize /=<CR>
  nnoremap <leader>: :Tabularize /:\zs<CR>
  vnoremap <leader>: :Tabularize /:\zs<CR>
endif

" Toggle spaces and tabs
nnoremap <leader>l :set list!<CR>

" OS clipboard
nnoremap <leader>y "+y
vnoremap <leader>y "+y

nnoremap <leader>p "+p
vnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>P "+P

noremap <leader>e :edit %:h/

" NerdTree
nnoremap <leader>n :NERDTreeToggle<CR>
let NERDTreeMapOpenSplit = "s"
let NERDTreeMapOpenVSplit = "v"
let NERDTreeMinimalUI = 1
let NERDTreeIgnore=['\.rbc$', '\~$']

" Auto indent whole file
" TODO:  does not work
nnoremap <leader>i gg=G\|

"PHP doc
noremap <leader>pd :call PhpDoc()<CR>

" Debugger

noremap <Leader>dl  :Rdebugger<CR>
noremap <Leader>db  :call g:RubyDebugger.toggle_breakpoint()<CR>
noremap <Leader>dv  :call g:RubyDebugger.open_variables()<CR>
noremap <Leader>dm  :call g:RubyDebugger.open_breakpoints()<CR>
noremap <Leader>dt  :call g:RubyDebugger.open_frames()<CR>
noremap <Leader>ds  :call g:RubyDebugger.step()<CR>
noremap <Leader>df  :call g:RubyDebugger.finish()<CR>
noremap <Leader>dn  :call g:RubyDebugger.next()<CR>
noremap <Leader>dc  :call g:RubyDebugger.continue()<CR>
noremap <Leader>de  :call g:RubyDebugger.exit()<CR>
noremap <Leader>dd  :call g:RubyDebugger.remove_breakpoints()<CR>


"""""""""""""""""""""
" Key bindings
"
"""""""""""""""""""""

" Hide search highlighting
nnoremap <silent> <Space> :noh<CR>

""""""""""
" F keys

"Save file
nnoremap <F2> :wa<CR>
vnoremap <F2> :wa<CR>
inoremap <F2> <ESC>:wa<CR>

"Close buffer
noremap <F12> :bd<CR>

" По <F4> открывается new buffer и выводится список каталогов и файлов текущего каталога.
noremap <F4> <Esc>:e.<CR>

" Cycle buffer switch
inoremap <F6> <Esc> :bn <CR>i
noremap <F6> :bn <CR>
inoremap <F5> <Esc> :bp <CR>i
noremap <F5> :bp <CR>

""""""""""
" Ctrl keys

" Indenting with Ctrl + h and j
nnoremap <C-h> <<
nnoremap <C-l> >>
vnoremap <C-h> <gv
vnoremap <C-l> >gv

" Move line(s) of text using Ctrl+j/k
nnoremap  <C-j> :m+<CR>==
nnoremap  <C-k> :m-2<CR>==
inoremap  <C-j> <Esc>:m+<CR>==gi
inoremap  <C-k> <Esc>:m-2<CR>==gi
vnoremap  <C-j> :m'>+<CR>gv=gv
vnoremap  <C-k> :m-2<CR>gv=gv

" disable arrow keys
"inoremap <Up>    <NOP>
"inoremap <Down>  <NOP>
"inoremap <Left>  <NOP>
"inoremap <Right> <NOP>
noremap  <Up>    <NOP>
noremap  <Down>  <NOP>
noremap  <Left>  <NOP>
noremap  <Right> <NOP>

"Time tree
"nnoremap <F9> :GundoToggle<CR>

"""""""""""""""""""""
" Functions
"
"""""""""""""""""""""

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

" convert var assignment to rspec let
" stolen from: https://github.com/garybernhardt/dotfiles/blob/master/.vimrc
function! PromoteToLet()
  :normal! dd
  :exec '?^\s*it\>'
  :normal! P
  :.s/\(\w\+\) = \(.*\)$/let(:\1) { \2 }/
  :normal ==
endfunction
:command! PromoteToLet :call PromoteToLet()
:map <leader>rl :PromoteToLet<cr>

fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

