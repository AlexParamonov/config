if !filereadable(expand('~/.vim/autoload/plug.vim'))
  !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

call plug#begin('~/.vim/plugged')

"----------------
" Unprocessed
"----------------
Plug 'eparreno/vim-l9'
Plug 'godlygeek/tabular'
Plug 'scrooloose/nerdtree'
Plug 'yazug/vim-taglist-plus'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'


"----------------
" Utils
"----------------
" Git wrapper
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-projectionist'

"----------------
" Text processing
"----------------
Plug 'will133/vim-dirdiff'
" tabcompletition
" Plug 'ervandew/supertab'
" Other
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
" Comments
Plug 'tpope/vim-commentary'
" Plug 'tpope/vim-projectionist'

Plug 'sheerun/vim-polyglot'
Plug 'nelstrom/vim-markdown-folding'

"----------------
" Colors
"----------------
" color scheme
Plug 'morhetz/gruvbox'
" colorize fileformats, setomnifuncs, etc
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-haml'
Plug 'tpope/vim-cucumber'
Plug 'slim-template/vim-slim'
Plug 'tpope/vim-rake'


"----------------
" UI
"----------------
Plug 'mhinz/vim-startify'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'roman/golden-ratio'
Plug 'kien/ctrlp.vim'
" Semantic
Plug 'w0rp/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'neoclide/coc-tsserver'
" Plugin 'zxqfl/tabnine-vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

" Undo tree
Plug 'sjl/gundo.vim'
" find buffer
Plug 'vim-scripts/FuzzyFinder'
" Ack search
Plug 'mileszs/ack.vim'
" Plug 'JamshedVesuna/vim-markdown-preview'


"----------------
" Ruby
"----------------
" Ruby motions (]m ]M ]]) and Ruby text objects (am im aM iM)
" Plug 'vim-ruby/vim-ruby'
" Rails navigation
" Plug 'tpope/vim-rails'
" refactoring http://relishapp.com/despo/vim-ruby-refactoring
Plug 'AlexParamonov/vim-ruby-refactoring'
" gem-ctags call gem ctags to generate tags
" install gem-browse for opening a gems
Plug 'tpope/vim-bundler'
" Smart end
Plug 'tpope/vim-endwise'
" Test runner
Plug 'vim-test/vim-test'
Plug 'tpope/vim-dispatch'

"----------------
" Elixir
"----------------
Plug 'elixir-editors/vim-elixir'
" Plug 'elixir-lsp/coc-elixir', {'do': 'yarn install && yarn prepack'}

"----------------
" Perfomance
"----------------
" alternative: Plug 'vim-hugefile'
Plug 'markwu/LargeFile'
Plug 'Konfekt/FastFold'

"----------------
" PHP
"----------------
" Plug 'vexxor/phpdoc.vim'


"----------------
" Kotlin
"----------------
" Plug 'udalov/kotlin-vim'


"----------------
" HTML
"----------------
Plug 'rstacruz/sparkup', {'rtp': 'vim/'}


"----------------
" Documentation
"----------------
" Plug 'danchoi/ri.vim'
Plug 'kucaahbe/vim-common-tips'

call plug#end()

filetype plugin indent on
