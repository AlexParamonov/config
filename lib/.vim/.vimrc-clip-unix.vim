" vim: foldmethod=marker
"#############################################
"           Unix/Linux Clipboard          {{{1
"#############################################
" Use wl-clipboard for Wayland clipboard integration
" Requires: sudo apt install wl-clipboard

if executable('wl-copy') && executable('wl-paste')
  " Visual: yank to clipboard without clobbering unnamed register
  xnoremap <silent><leader>y :<C-u>let @x=@"<CR>gvy:call system('wl-copy', @")<CR>:let @"=@x<CR>

  " Normal: paste from clipboard (removes CRLF line endings)
  nnoremap <silent><leader>p :let @x=@"<CR>:let @"=substitute(system('wl-paste --no-newline'), '\r', '', 'g')<CR>p:let @"=@x<CR>
  nnoremap <silent><leader>P :let @x=@"<CR>:let @"=substitute(system('wl-paste --no-newline'), '\r', '', 'g')<CR>P:let @"=@x<CR>
endif
