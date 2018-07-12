" Enable folding based on syntax rules
set foldmethod=syntax
set foldlevelstart=2
nmap - za
nmap + zA

if has("autocmd")
  augroup SyntaxAuto
    autocmd!
    autocmd BufNewFile,BufRead *_spec.rb setlocal foldmethod=syntax
    autocmd BufNewFile,BufRead */factories/*.rb setlocal foldmethod=syntax
    autocmd BufNewFile,BufRead *.html setlocal foldmethod=indent
    autocmd BufNewFile,BufRead *.html.erb setlocal foldmethod=indent
  augroup END
endif
