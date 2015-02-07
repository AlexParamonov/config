function! IndentLevel(lnum)
    return indent(a:lnum) / &shiftwidth
endfunction

function! PrivateFolds()
  let thisline = getline(v:lnum)

  if thisline =~ "^ *def" || thisline =~ "^ *describe"
    let g:last_indent = IndentLevel(v:lnum)
    return "a1"
  elseif thisline =~ "^ *private$"
    return ">3"
  elseif thisline =~ "^ *class << self$"
    return "a1"
  elseif thisline =~ "^ *end"
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

function! PrivateFoldText()
  let foldsize = v:foldend-v:foldstart
  return getline(v:foldstart).' '. repeat('-', foldsize)
endfunction

setlocal foldtext=PrivateFoldText()
setlocal foldmethod=expr
setlocal foldexpr=PrivateFolds()
setlocal fillchars="fold: "
