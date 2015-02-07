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
    elseif IndentLevel(v:lnum) == g:last_indent
      return 's1'
    elseif IndentLevel(v:lnum) < g:last_indent
      return '0'
    else
      return '-1'
    endif

  else
    return "="

  endif
endfunction

function! PrivateFoldText()
  let foldsize = v:foldend-v:foldstart - 1
  " return getline(v:foldstart).' '. repeat("-", foldsize)
  return getline(v:foldstart).' '. repeat("\u2219", foldsize)
  " return getline(v:foldstart).' '. repeat("\u2744 ", foldsize)
  " return getline(v:foldstart).' '. repeat("\u238E", foldsize)
  " return getline(v:foldstart).' '. repeat("\u2699 ", foldsize)
endfunction

setlocal foldtext=PrivateFoldText()
setlocal foldmethod=expr
setlocal foldexpr=PrivateFolds()
setlocal fillchars="fold: "
