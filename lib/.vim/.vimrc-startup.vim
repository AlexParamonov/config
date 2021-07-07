let g:startify_custom_header =
     \ map(split(system('fortune'), '\n'), '"   ". v:val') + ['','']
let g:startify_session_detection = 0
let g:startify_change_to_dir = 0
let g:startify_enable_special = 0
