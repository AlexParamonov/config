set t_Co=16
" set background=light
let g:solarized_termcolors=16
" set background=dark
set background=light
" let g:solarized_contrast="high"
colorscheme solarized
set guifont=Ubuntu\ Mono\ for\ Powerline\ 14

let Powerline_colorscheme="solarizedLight"
" let Powerline_colorscheme="skwp"

nnoremap <leader>ccl :call ChangeColorShemaToLight()<CR>
nnoremap <leader>ccd :call ChangeColorShemaToDark()<CR>

function! ChangeColorShemaToLight()
  set background=light
  let g:Powerline_colorscheme = 'solarizedLight'
endfunction

function! ChangeColorShemaToDark()
  set background=dark
  let g:Powerline_colorscheme = 'skwp'
endfunction
