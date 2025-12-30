let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" Undercurl support (requires tmux with Smulx/Setulc)
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"

" Cursor shape: block (normal), line (insert), underline (replace)
let &t_SI = "\e[6 q"  " insert mode - line
let &t_EI = "\e[2 q"    " normal mode - block
let &t_SR = "\e[4 q"    " replace mode - underline

set background=dark
" set background=light
set t_Co=256

set termguicolors

let g:solarized_termcolors=16
let g:solarized_degrad=0
let g:gruvbox_contrast_dark="hard"
colorscheme gruvbox
" colorscheme solarized
" let g:solarized_contrast="high"
set guifont=Source\ Code\ Pro\ Light\ for\ Powerline\ 14

" Undercurl for spell (after colorscheme)
hi SpellBad   guisp=red    gui=undercurl cterm=undercurl
hi SpellCap   guisp=yellow gui=undercurl cterm=undercurl
hi SpellRare  guisp=cyan   gui=undercurl cterm=undercurl
hi SpellLocal guisp=orange gui=undercurl cterm=undercurl

" Undercurl for CoC/LSP diagnostics
hi CocErrorHighlight   guisp=#ff5555 gui=undercurl cterm=undercurl
hi CocWarningHighlight guisp=#ffaa00 gui=undercurl cterm=undercurl
hi CocInfoHighlight    guisp=#88aaff gui=undercurl cterm=undercurl
hi CocHintHighlight    guisp=#aaffaa gui=undercurl cterm=undercurl

let g:airline_theme= "base16"

nnoremap <leader>ccl :call ChangeColorShemaToLight()<CR>
nnoremap <leader>ccd :call ChangeColorShemaToDark()<CR>

function! ChangeColorShemaToLight()
  set background=light
endfunction

function! ChangeColorShemaToDark()
  set background=dark
endfunction

function! ShowColors()
  let num = 255
  while num >= 0
    exec 'hi col_'.num.' ctermbg='.num.' ctermfg=white'
    exec 'syn match col_'.num.' "ctermbg='.num.':...." containedIn=ALL'
    call append(0, 'ctermbg='.num.':....')
    let num = num - 1
  endwhile
endfunction

