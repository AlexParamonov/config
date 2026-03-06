" vim: foldmethod=marker
"#############################################
"           WSL Windows Clipboard         {{{1
"#############################################
" Use Windows clip.exe and PowerShell for clipboard integration in WSL
" No additional packages required - uses built-in Windows tools

if executable('clip.exe')
  " Visual: yank to Windows clipboard without clobbering unnamed register
  xnoremap <silent><leader>y :<C-u>let @x=@"<CR>gvy:call system('clip.exe', @")<CR>:let @"=@x<CR>
  
  " Normal: paste from Windows clipboard (removes CRLF line endings)
  nnoremap <silent><leader>p :let @x=@"<CR>:let @"=substitute(system('powershell.exe -c "Get-Clipboard -Raw"', ''), '\r', '', 'g')<CR>p:let @"=@x<CR>
  nnoremap <silent><leader>P :let @x=@"<CR>:let @"=substitute(system('powershell.exe -c "Get-Clipboard -Raw"', ''), '\r', '', 'g')<CR>P:let @"=@x<CR>
endif
