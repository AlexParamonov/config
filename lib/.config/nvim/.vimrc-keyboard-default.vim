nnoremap <C-l> >>
nnoremap <C-h> <<
vnoremap <C-l> >gv
vnoremap <C-h> <gv

" Move line(s) of text
nnoremap  <C-j> :m+<CR>==
nnoremap  <C-k> :m-2<CR>==
inoremap  <C-j> <Esc>:m+<CR>==gi
inoremap  <C-k> <Esc>:m-2<CR>==gi
vnoremap  <C-j> :m'>+<CR>gv=gv
vnoremap  <C-k> :m-2<CR>gv=gv

" disable arrow keys
noremap  <Down>  <NOP>
noremap  <Left>  <NOP>
noremap  <Up>    <NOP>
noremap  <Right> <NOP>

