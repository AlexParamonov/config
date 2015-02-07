function! IndentLevel(lnum)
    return indent(a:lnum) / &shiftwidth
endfunction

function! PrivateFolds()
  let thisline = getline(v:lnum)

  if thisline =~ "^ *def"
    let g:last_indent = IndentLevel(v:lnum)
    return "a1"
  elseif thisline =~ "^ *describe"
    let g:last_indent = IndentLevel(v:lnum)
    return "a1"
  elseif match(thisline, "^ *private$") >= 0
    return ">3"
  elseif match(thisline, "^ *class << self$") >= 0
    return "a1"
  elseif match(thisline, "^ *end") >= 0
    if ! exists("g:last_indent")
      return '='
    endif

    if IndentLevel(v:lnum) == g:last_indent
      return 's1'
    endif

    if IndentLevel(v:lnum) < g:last_indent
      return '0'
    endif

    return '-1'
  else
    return "="
  endif
endfunction
setlocal foldmethod=expr
setlocal foldexpr=PrivateFolds()
