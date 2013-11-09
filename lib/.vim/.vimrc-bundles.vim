set nocompatible

if !isdirectory(expand("~/.vim/bundle/vundle/.git"))
  !git clone git://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
endif

filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

"#############################################
"                  Plugins
"#############################################

Bundle 'gmarik/vundle'

"----------------
" Unprocessed
"----------------
Bundle 'L9'
Bundle 'godlygeek/tabular'
Bundle "scrooloose/nerdtree.git"
" Bundle "scrooloose/nerdcommenter"
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
" matching with "%"
Bundle 'vim-scripts/matchit.zip'
" tabcompletition
Bundle 'ervandew/supertab'
" Ruby text objects vir var
Bundle 'kana/vim-textobj-user'
Bundle 'nelstrom/vim-textobj-rubyblock'
" Other
Bundle 'jiangmiao/auto-pairs'
Bundle 'tpope/vim-unimpaired'
Bundle 'tpope/vim-speeddating'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-surround'
" Comments
Bundle 'tpope/vim-commentary'
Bundle 'sheerun/vim-polyglot'


"----------------
" Colors
"----------------
" color scheme
Bundle 'altercation/vim-colors-solarized'
" colorize fileformats, setomnifuncs, etc
Bundle 'tpope/vim-markdown'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-cucumber'
Bundle 'slim-template/vim-slim'
Bundle 'tpope/vim-rake'


"----------------
" UI
"----------------
Bundle "pearofducks/vim-powerline"
Bundle "roman/golden-ratio"
Bundle 'kien/ctrlp.vim'
" Semantic
Bundle 'scrooloose/syntastic'
" Undo tree
Bundle 'sjl/gundo.vim'
" find buffer
Bundle 'vim-scripts/FuzzyFinder'
" Ack search
Bundle 'mileszs/ack.vim'


"----------------
" Ruby
"----------------
" Ruby motions (]m ]M ]]) and Ruby text objects (am im aM iM)
Bundle 'vim-ruby/vim-ruby'
" Rails navigation
Bundle 'tpope/vim-rails'
" refactoring http://relishapp.com/despo/vim-ruby-refactoring
Bundle 'AlexParamonov/vim-ruby-refactoring'
" gem-ctags call gem ctags to generate tags
"install gem-browse for opening a gems
Bundle 'tpope/vim-bundler'
" Smart end
Bundle 'tpope/vim-endwise'

"----------------
" Perfomance
"----------------
" alternative: Bundle 'vim-hugefile'
Bundle 'markwu/LargeFile'

"----------------
" PHP
"----------------
" Bundle 'vexxor/phpdoc.vim'


"----------------
" HTML
"----------------
Bundle 'rstacruz/sparkup', {'rtp': 'vim/'}


"----------------
" Documnetation
"----------------
Bundle "danchoi/ri.vim"
Bundle "kucaahbe/vim-common-tips"


"----------------
" Deprecated
"----------------
" Bundle 'astashov/vim-ruby-debugger'
" Bundle "Lokaltog/vim-powerline"
" Bundle "bkad/CamelCaseMotion"
" Bundle "honza/snipmate-snippets"
" Bundle "garbas/vim-snipmate"
" Bundle 'fholgado/minibufexpl.vim'
" Bundle 'Townk/vim-autoclose'


filetype plugin indent on
