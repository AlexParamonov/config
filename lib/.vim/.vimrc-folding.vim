" Enable folding based on syntax rules
set foldmethod=syntax
set foldlevelstart=2
nmap - za
nmap + zA

if has("autocmd")
  autocmd BufNewFile,BufRead *_spec.rb setlocal foldmethod=syntax
endif
