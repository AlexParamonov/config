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

Bundle 'vim-scripts/matchit.zip'
Bundle 'altercation/vim-colors-solarized'
Bundle 'ervandew/supertab'
Bundle 'tpope/vim-markdown'

" ruby-related plugins
Bundle 'vim-ruby/vim-ruby'
Bundle 'tpope/vim-rails'
Bundle 'astashov/vim-ruby-debugger'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-cucumber'
Bundle 'tpope/vim-bundler'
Bundle 'tpope/vim-rake'
Bundle 'tpope/vim-endwise'
Bundle 'kana/vim-textobj-user'
Bundle 'nelstrom/vim-textobj-rubyblock'

" PHP-related plugins
Bundle 'vexxor/phpdoc.vim'
" Bundle 'AlexParamonov/vim_dbgp_debug'

" HTML-related
Bundle 'rstacruz/sparkup', {'rtp': 'vim/'}

" Bundle 'Townk/vim-autoclose'
Bundle 'jiangmiao/auto-pairs'
Bundle 'tpope/vim-unimpaired'
Bundle 'tpope/vim-speeddating'
Bundle 'tpope/vim-repeat'
Bundle 'kien/ctrlp.vim'
Bundle 'L9'
Bundle 'vim-scripts/FuzzyFinder'
Bundle 'tpope/vim-commentary'
" Bundle 'fholgado/minibufexpl.vim'
Bundle 'godlygeek/tabular'
Bundle 'tpope/vim-surround'
Bundle 'sjl/gundo.vim'
" Bundle "Lokaltog/vim-powerline"
Bundle "pearofducks/vim-powerline"
Bundle "scrooloose/nerdtree.git"
Bundle "scrooloose/nerdcommenter"
" Bundle "bkad/CamelCaseMotion"
Bundle "klen/vim-taglist-plus"
Bundle "roman/golden-ratio"

Bundle "MarcWeber/vim-addon-mw-utils"
Bundle "tomtom/tlib_vim"
" Bundle "honza/snipmate-snippets"
" Bundle "garbas/vim-snipmate"
Bundle "scrooloose/syntastic"

" Documnetation
Bundle "danchoi/ri.vim"
Bundle "kucaahbe/vim-common-tips"

set laststatus=2
filetype plugin indent on

set encoding=utf-8
set number
set numberwidth=5
set ruler
set hidden
set cmdheight=2
set switchbuf=useopen
" display incomplete commands
set showcmd
" Enable highlighting for syntax
syntax on

"no delay!
" set timeout timeoutlen=1000 ttimeoutlen=100
" set notimeout ttimeout ttimeoutlen=100
imap jj <Esc>:<Esc>

set t_Co=16
set background=dark
" set background=light
" colorscheme zenburn
let g:solarized_termcolors=16
" let g:solarized_contrast="high"
colorscheme solarized
set guifont=Ubuntu\ Mono\ for\ Powerline\ 14

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
set wildignore+=.git/*,.svn/*
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

  " Indent p tags
  autocmd FileType html,eruby if g:html_indent_tags !~ '\\|p\>' | let g:html_indent_tags .= '\|p\|li\|dt\|dd' | endif

  "maps .. to go to parent command, but only for buffers containing a git blob or tree TODO it not actually working
  autocmd BufReadPost fugitive://* if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' | nnoremap <buffer> .. :edit %:h<CR> | endif

  " Autoclean fugitive buffers
  autocmd BufReadPost fugitive://* set bufhidden=delete

  " Handle relative numbers
  " autocmd InsertEnter * :set number
  " autocmd InsertLeave * :set relativenumber
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

" Golden ratio
let g:golden_ratio_autocommand = 0

" Powerline
let Powerline_symbols="fancy"
" let Powerline_colorscheme="solarizedLight"
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
let g:ctrlp_arg_map = 1
let g:ctrlp_root_markers = ['tags']

" " SnipMate
" let g:snips_author = 'Alexander Paramonov'

" Syntastic
let g:syntastic_warning_symbol='⚠'
let g:syntastic_auto_loc_list=2
let g:syntastic_enable_highlighting = 1
let g:syntastic_enable_balloons = 0
let g:syntastic_enable_signs=1
let g:syntastic_echo_current_error=1

"""""""""""""""""""""
" Leader Mappings
"
"""""""""""""""""""""

" Leader key
let mapleader=','

" Pressing ,v opens the vimrc file in a new tab.
nnoremap <leader>v :e $MYVIMRC<CR>


" CTags
noremap <leader>rt :!ctags -f tags --extra=+f --exclude=tmp --exclude=log -R *<CR><CR>


" Golden ratio
nnoremap <F7> :GoldenRatioToggle<CR>
if exists("g:loaded_golden_ratio")
endif

" Tabs
nnoremap <leader>= :Tabularize /=<CR>
vnoremap <leader>= :Tabularize /=<CR>
nnoremap <leader>: :Tabularize /:\zs<CR>
vnoremap <leader>: :Tabularize /:\zs<CR>
nnoremap <leader>=> :Tabularize /=><CR>
vnoremap <leader>=> :Tabularize /=><CR>

" Toggle spaces and tabs
nnoremap <leader>l :set list!<CR>

nnoremap <leader>. :R<CR>

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
let NERDTreeShowHidden=1
let NERDTreeMapOpenSplit = "s"
let NERDTreeMapOpenVSplit = "v"
let NERDTreeMinimalUI = 1
let NERDTreeIgnore=['\.rbc$', '\~$']

" Auto indent whole file
" TODO:  does not work
nnoremap <leader>i gg=G\|

"PHP doc
noremap <leader>pd :call PhpDoc()<CR>

" Buffer window (find file in open buffers)
nmap <silent> <leader>b :FufBuffer<CR>

" Debugger

let g:ruby_debugger_no_maps = 1
" let g:ruby_debugger_debug_mode=3
" let g:ruby_debugger_fast_sender = 2
" let g:ruby_debugger_spec_path='~/.rvm/gems/ruby-1.9.3-p194@ap/gems/rspec-core-2.10.0/exe/rspec'
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

noremap <F4> <Esc>:TlistToggle<CR>
noremap <F3> <Esc>:NERDTreeToggle<CR>

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
nnoremap <F9> :GundoToggle<CR>

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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EXTRACT VARIABLE (SKETCHY)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! ExtractVariable()
    let name = input("Variable name: ")
    if name == ''
        return
    endif
    " Enter visual mode (not sure why this is needed since we're already in
    " visual mode anyway)
    normal! gv

    " Replace selected text with the variable name
    exec "normal c" . name
    " Define the variable on the line above
    exec "normal! O" . name . " = "
    " Paste the original selected text to be the variable value
    normal! $p
endfunction
vnoremap <leader>rv :call ExtractVariable()<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INLINE VARIABLE (SKETCHY)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! InlineVariable()
    " Copy the variable under the cursor into the 'a' register
    :let l:tmp_a = @a
    :normal "ayiw
    " Delete variable and equals sign
    :normal 2daW
    " Delete the expression into the 'b' register
    :let l:tmp_b = @b
    :normal "bd$
    " Delete the remnants of the line
    :normal dd
    " Go to the end of the previous line so we can start our search for the
    " usage of the variable to replace. Doing '0' instead of 'k$' doesn't
    " work; I'm not sure why.
    normal k$
    " Find the next occurence of the variable
    exec '/\<' . @a . '\>'
    " Replace that occurence with the text we yanked
    exec ':.s/\<' . @a . '\>/' . @b
    :let @a = l:tmp_a
    :let @b = l:tmp_b
endfunction
nnoremap <leader>ri :call InlineVariable()<cr>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RUNNING TESTS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <leader>t :call RunTestFile()<cr>
nmap <leader>T :call RunNearestTest()<cr>
nmap <leader>a :call RunTests('')<cr>
" map <leader>c :w\|:!script/features<cr>
" map <leader>w :w\|:!script/features --profile wip<cr>

function! RunTestFile(...)
    if a:0
        let command_suffix = a:1
    else
        let command_suffix = ""
    endif

    " Run the tests for the previously-marked file.
    let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\)$') != -1
    if in_test_file
        call SetTestFile()
    elseif !exists("t:grb_test_file")
        return
    end
    call RunTests(t:grb_test_file . command_suffix)
endfunction

function! RunNearestTest()
    let spec_line_number = line('.')
    call RunTestFile(":" . spec_line_number . " -b")
endfunction

function! SetTestFile()
    " Set the spec file that tests will be run for.
    let t:grb_test_file=@%
endfunction

function! RunTests(filename)
    " Write the file and run tests for the given filename
    :w
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    if match(a:filename, '\.feature$') != -1
        exec ":!script/features " . a:filename
    else
        if filereadable("script/test")
            exec ":!script/test " . a:filename
        elseif filereadable("Gemfile")
            exec ":!bundle exec rspec --color " . a:filename
        else
            exec ":!rspec --color " . a:filename
        end
    end
endfunction

