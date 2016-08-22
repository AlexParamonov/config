nmap <leader>sf :call RunTestFile("spring")<cr>
nmap <leader>sn :call RunNearestTest("spring")<cr>
nmap <leader>tf :call RunTestFile()<cr>
nmap <leader>tn :call RunNearestTest()<cr>

function! RunTestFile(...)
  let command_prefix = get(a:000, 0, "")
  let command_suffix = get(a:000, 1, "")

  " Run the tests for the previously-marked file.
  let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\)$') != -1
  if in_test_file
    call SetTestFile()
  elseif !exists("t:grb_test_file")
    return
  end
  call RunTests(command_prefix, command_suffix, t:grb_test_file)
endfunction

function! RunNearestTest(...)
  let command_prefix = get(a:000, 0, "")
  let command_suffix = get(a:000, 1, "")

  let spec_line_number = line('.')
  let command_suffix .= ":" . spec_line_number . " -b"

  call RunTestFile(command_prefix, command_suffix)
endfunction

function! SetTestFile()
  " Set the spec file that tests will be run for.
  let t:grb_test_file=@%
endfunction

function! RunTests(command_prefix, command_suffix, filename)
  :w
  :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
  exec ":!NO_CODE_COVERAGE=1 " . a:command_prefix . "bundle exec bin/rspec --color --format documentation " . a:filename . a:command_suffix
endfunction

