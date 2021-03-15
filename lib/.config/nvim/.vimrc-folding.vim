" Enable folding based on syntax rules
set foldmethod=syntax
set foldlevelstart=10
nmap - za
nmap + zA

xmap <leader>f jzMzak
nmap <leader>f jzMzak


set fillchars+=fold:\ 
function! NeatFoldText()
  let line = substitute(substitute(getline(v:foldstart), '^\s', '', 'g'), '{{{\d', '', 'g')
  let lines_count = v:foldend - v:foldstart + 1
  let lines_count_text = '| ' . printf("%10s", lines_count . ' lines') . ' |'
  let foldchar = '·'
  let foldtextstart = '+' . line
  let foldtextend = lines_count_text . repeat(foldchar, 8)
  let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
  return foldtextstart . repeat(foldchar, lines_count)
endfunction
set foldtext=NeatFoldText()

if has("autocmd")
  augroup SyntaxAuto
    autocmd!
    autocmd BufNewFile,BufRead *_spec.rb setlocal foldmethod=syntax
    autocmd BufNewFile,BufRead */factories/*.rb setlocal foldmethod=syntax
    autocmd BufNewFile,BufRead *.html setlocal foldmethod=indent
    autocmd BufNewFile,BufRead *.html.erb setlocal foldmethod=indent
    autocmd BufNewFile,BufRead *.ex setlocal foldmethod=indent
  augroup END
endif
