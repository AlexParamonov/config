" Ruby test runners
"
" nmap <silent> <leader>tn :TestNearest --format documentation<CR>
" nmap <silent> <leader>tf :TestFile --format documentation<CR>
" nmap <silent> <leader>ta :TestSuite<CR>
" nmap <silent> <leader>tl :TestLast<CR>
" nmap <silent> <leader>tv :TestVisit --format documentation<CR>

" Elixir test runners
" nmap <silent> <leader>tn :TestNearest --trace<CR>
" nmap <silent> <leader>tf :TestFile --trace<CR>
" nmap <silent> <leader>ta :TestSuite<CR>
" nmap <silent> <leader>tl :TestLast<CR>
" nmap <silent> <leader>tv :TestVisit --trace<CR>

nmap <silent> <leader>tn :TestNearest<CR>
nmap <silent> <leader>tf :TestFile<CR>
nmap <silent> <leader>ta :TestSuite<CR>
nmap <silent> <leader>tl :TestLast<CR>
nmap <silent> <leader>tv :TestVisit<CR>

let test#strategy = "basic"


" let test#enabled_runners = ["javascript#jest", "ruby#rspec"]
" let g:test#javascript#jest#file_pattern = 'spec.ts'
" let test#strategy = 'vimterminal'
" let g:test#javascript#jest#executable = 'foreman run rspec'
" yarn --cwd invoice/backend/ jest --no-coverage invoice/backend/src/core/order/application/OrderService.spec.ts

" let test#project_root = "/path/to/your/project"
" let test#vim#term_position = "topleft"
" |projectionist| plug-in
let g:test#ruby#rspec#executable = 'bundle exec rspec'
