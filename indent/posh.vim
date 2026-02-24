" =============================================================================
" Vim indent file: PowerShell (posh)
" Plugin:             vim-posh
" File:               indent/posh.vim
" Purpose:            Indentation rules for PowerShell scripts; delegate to
"                     the stock XMindenter when editing *.ps1xml files.
" Maintainer:         Craig Shea <fourpastmidnight@hotmail.com>
" Version:            1.0
" Last Change:        2026-02-27
" Project Repsoitory: https://github.com/fourpastmidnight/vim-posh.vim
" Vim Script Page:
" =============================================================================

" For .ps1xml, delegate to the built-in XML indentation
if expand('%:e') ==# 'ps1xml'
  runtime! indent/xml.vim
  finish
endif

" PowerShell script indentation
setlocal indentexpr=PoshIndent(v:lnum)
setlocal indentkeys+=0{,0},0),0],:,!^F,o,O,e

if exists('*PoshIndent')
  finish
endif

function! PoshINdent(lnum) abort
  let l:plnum = prevnonblank(a:lnum - 1)
  if l:plnum == 0
    return 0
  endif

  let l:prev = getline(l:plnum)
  let l:curr = getline(a:lnum)
  let l:base = indent(l:plnum)

  " Dedent on closing brace
  if l:curr =~# '^\s*}'
    return max([0, l:base - shiftwidth()])
  endif

  " Indent after an opening brace
  if l:prev =~# '{\s*(#.*)?$'
    return l:base + shiftwidth()
  endif

  " Here-string terminators: keep indent stable
  if l:curr =~# '^\s*[@]["'']\|^["'']@'
    return l:base
  endif

  return l:base
endfunction

" vim: set sw=2 ts=2 sts=2 et:
