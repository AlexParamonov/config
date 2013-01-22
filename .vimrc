set nocompatible               " be iMproved

"#############################################
"                 Plugins
"#############################################
runtime .vim-bundles.vim

"#############################################
"               Configuration
"#############################################

set laststatus=2
set encoding=utf-8
set hidden
set cmdheight=2
set switchbuf=useopen
" display incomplete commands
set showcmd
" Enable highlighting for syntax
syntax on

set number
set numberwidth=5
set ruler

set t_Co=16
set background=light
" set background=light
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
inoremap <buffer><silent><Bar>   <Bar><Esc>:call <SID>align()<CR>a


"#############################################
"                  Autocmd
"#############################################

if has("autocmd")
  autocmd InsertEnter * set nocul
  autocmd InsertLeave * set cul

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

"#############################################
"            Plugins configs
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
let NERDTreeIgnore=['\.rbc$', '\~$', '\.git$', '\.bundle$']

"----------------
" Golden ratio
"----------------
let g:golden_ratio_autocommand = 0

"----------------
" Powerline
"----------------
let Powerline_symbols="fancy"
let Powerline_colorscheme="solarizedLight"
" let Powerline_colorscheme="skwp"
let Powerline_cache_enabled=1

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
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabContextDefaultCompletionType = "<c-p>"
let g:SuperTabCompletionContexts = ['s:ContextText', 's:ContextDiscover']
let g:SuperTabLongestEnhanced = 1
let g:SuperTabNoCompleteAfter = ['^', '\s', '{', '[', '(', '|']

"----------------
" CTRLP
"----------------
let g:ctrlp_max_files = 90000
let g:ctrlp_clear_cache_on_exit = 0
" let g:ctrlp_user_command = ['.git/', 'cd %s && git ls-files']
let g:ctrlp_arg_map = 1
let g:ctrlp_show_hidden = 1
" let g:ctrlp_root_markers = ['tags']

"----------------
" Syntastic
"----------------
let g:syntastic_warning_symbol='⚠'
let g:syntastic_auto_loc_list=2
let g:syntastic_enable_highlighting = 1
let g:syntastic_enable_balloons = 0
let g:syntastic_enable_signs=1
let g:syntastic_echo_current_error=1

"#############################################
"             Leader Mappings
"#############################################

" Leader key
let mapleader=','

"----------------
" CTags
"----------------
noremap <leader>rt :!ctags -f tags --extra=+f --exclude=tmp --exclude=log -R *<CR><CR>

"----------------
" Golden ratio
"----------------
nnoremap <F7> :GoldenRatioToggle<CR>

"----------------
" Tabularize
"----------------
nnoremap <leader>= :Tabularize /=<CR>
vnoremap <leader>= :Tabularize /=<CR>
nnoremap <leader>: :Tabularize /:\zs<CR>
vnoremap <leader>: :Tabularize /:\zs<CR>
nnoremap <leader>=> :Tabularize /=><CR>
vnoremap <leader>=> :Tabularize /=><CR>

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
" General
"----------------
" Pressing ,v opens the vimrc file in a new tab.
nnoremap <leader>v :e $MYVIMRC<CR>

" Toggle spaces and tabs
nnoremap <leader>l :set list!<CR>

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

nnoremap <leader>ccl :call ChangeColorShemaToLight()<CR>
nnoremap <leader>ccd :call ChangeColorShemaToDark()<CR>

"#############################################
"               Key bindings
"#############################################

imap jj <Esc>:<Esc>

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

" Indenting with Ctrl + h and j
nnoremap <C-Right> <<
nnoremap <C-Left> >>
vnoremap <C-Right> <gv
vnoremap <C-Left> >gv

" Move line(s) of text using Ctrl+j/k
nnoremap  <C-Down> :m+<CR>==
nnoremap  <C-Up> :m-2<CR>==
inoremap  <C-Down> <Esc>:m+<CR>==gi
inoremap  <C-Up> <Esc>:m-2<CR>==gi
vnoremap  <C-Down> :m'>+<CR>gv=gv
vnoremap  <C-Up> :m-2<CR>gv=gv

" disable arrow keys
" noremap  <Down>  <NOP>
" noremap  <Left>  <NOP>
" noremap  <Up>    <NOP>
" noremap  <Right> <NOP>

"Time tree
nnoremap <F9> :GundoToggle<CR>

"#############################################
"                 Functions
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

"----------------
" Running tests
"----------------
nmap <leader>t :call RunTestFile()<cr>
nmap <leader>T :call RunNearestTest()<cr>

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
    :w
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    exec ":!rspec --color " . a:filename
endfunction

function! ChangeColorShemaToLight()
  set background=light
  let g:Powerline_colorscheme = 'solarizedLight'
endfunction

function! ChangeColorShemaToDark()
  set background=dark
  let g:Powerline_colorscheme = 'skwp'
endfunction

function! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

