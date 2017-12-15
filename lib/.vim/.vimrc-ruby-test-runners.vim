" nmap <silent> <leader>tn :TestNearest --format documentation<CR>
" nmap <silent> <leader>tf :TestFile --format documentation<CR>
" nmap <silent> <leader>ta :TestSuite<CR>
" nmap <silent> <leader>tl :TestLast<CR>
" nmap <silent> <leader>tv :TestVisit --format documentation<CR>

nmap <silent> <leader>tn :TestNearest<CR>
nmap <silent> <leader>tf :TestFile<CR>
nmap <silent> <leader>ta :TestSuite<CR>
nmap <silent> <leader>tl :TestLast<CR>
nmap <silent> <leader>tv :TestVisit<CR>

let test#strategy = "basic"
