set nocompatible

if !isdirectory(expand("~/.vim/bundle/vundle/.git"))
  !git clone git://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
endif

filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

"#############################################
"                  Bundleins
"#############################################

Bundle 'gmarik/vundle'

"----------------
" Unprocessed
"----------------
Bundle 'L9'
Bundle 'godlygeek/tabular'
Bundle "scrooloose/nerdtree.git"
Bundle "yazug/vim-taglist-plus"
Bundle "MarcWeber/vim-addon-mw-utils"
Bundle "tomtom/tlib_vim"


"----------------
" Utils
"----------------
" Git wrapper
Bundle 'tpope/vim-fugitive'


"----------------
" Text processing
"----------------
Bundle 'will133/vim-dirdiff'
" tabcompletition
Bundle 'ervandew/supertab'
" Other
Bundle 'jiangmiao/auto-pairs'
Bundle 'tpope/vim-unimpaired'
Bundle 'tpope/vim-speeddating'
Bundle 'tpope/vim-surround'
" Comments
Bundle 'tpope/vim-commentary'
Bundle 'sheerun/vim-polyglot'
Bundle 'nelstrom/vim-markdown-folding.git'


"----------------
" Colors
"----------------
" color scheme
Bundle 'morhetz/gruvbox'
" colorize fileformats, setomnifuncs, etc
Bundle 'tpope/vim-markdown'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-cucumber'
Bundle 'slim-template/vim-slim'
Bundle 'tpope/vim-rake'


"----------------
" UI
"----------------
Bundle "bling/vim-airline"
Bundle "vim-airline/vim-airline-themes"
Bundle "roman/golden-ratio"
Bundle 'kien/ctrlp.vim'
" Semantic
" Bundle 'scrooloose/syntastic'
Plugin 'w0rp/ale'

" Undo tree
Bundle 'sjl/gundo.vim'
" find buffer
Bundle 'vim-scripts/FuzzyFinder'
" Ack search
Bundle 'mileszs/ack.vim'
Bundle 'JamshedVesuna/vim-markdown-preview'


"----------------
" Ruby
"----------------
" Ruby motions (]m ]M ]]) and Ruby text objects (am im aM iM)
" Bundle 'vim-ruby/vim-ruby'
" Rails navigation
" Bundle 'tpope/vim-rails'
" refactoring http://relishapp.com/despo/vim-ruby-refactoring
Bundle 'AlexParamonov/vim-ruby-refactoring'
" gem-ctags call gem ctags to generate tags
"install gem-browse for opening a gems
Bundle 'tpope/vim-bundler'
" Smart end
Bundle 'tpope/vim-endwise'
" Test runner
Bundle 'janko-m/vim-test'

"----------------
" Perfomance
"----------------
" alternative: Bundle 'vim-hugefile'
Bundle 'markwu/LargeFile'
Bundle 'Konfekt/FastFold'

"----------------
" PHP
"----------------
" Bundle 'vexxor/phpdoc.vim'


"----------------
" HTML
"----------------
Bundle 'rstacruz/sparkup', {'rtp': 'vim/'}


"----------------
" Documentation
"----------------
" Bundle "danchoi/ri.vim"
Bundle "kucaahbe/vim-common-tips"


filetype plugin indent on
