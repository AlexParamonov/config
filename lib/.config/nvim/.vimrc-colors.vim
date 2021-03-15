let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

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

