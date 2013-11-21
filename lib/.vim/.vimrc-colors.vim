set t_Co=16
let g:solarized_termcolors=16
let g:solarized_degrad=0
colorscheme solarized
" set background=light
set background=dark
" let g:solarized_contrast="high"
set guifont=Ubuntu\ Mono\ for\ Powerline\ 14

" let Powerline_colorscheme="solarizedLightLC"
let Powerline_colorscheme="solarizedDarkLC"
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
