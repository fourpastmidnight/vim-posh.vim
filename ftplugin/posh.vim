" =============================================================================
" Vim filetype plugin: PowerShell (posh)
" Plugin:             vim-posh
" File:               ftplugin/posh.vim
" Purpose:            Buffer-local defaults, folding UX, comments/formatting
"                     behavior. For *.ps1xml files, switch to XML
"                     commentstring and d isable PS formatter; everything else
"                     uses PowerShell defaults.
" Maintainer:         Craig Shea <fourpastmidnight@hotmail.com>
" Version:            1.0
" Last Change:        2026-02-27
" Project Repsoitory: https://github.com/fourpastmidnight/vim-posh.vim
" Vim Script Page:
" =============================================================================

" Common PowerShell buffer settings for editing PowerShell files
setlocal expandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4

" Allow $ and - as part of keywords, since PowerShell uses Verb-Noun cmdlets
setlocal iskeyword+=$,-
" For .ps1xml, we remove '-' from keywords for better XML semantics (below)

" Folding: create all folds, but defalut to showing them open
setlocal foldmethod=syntax
setlocal foldenable

" Control default fold level based on user preference
if get(g:, 'posh_collapse_all_folds', 0)
  " Collapse ALL folds
  setlocal foldlevelstart=0
else
  " Default: Keep everything open
  setlocal foldlevelstart=99
endif

" -----------------------------------------------------------------------------
" Smart fold text for all folds used in syntax/posh.vim
" -----------------------------------------------------------------------------
if exists('*PoshFoldText') == 0
    function! PoshFoldText() abort
        let l:start = v:foldstart
        let l:end   = v:foldend
        let l:lines = l:end - l:start + 1

        " Find first non-blank inside fold
        let l:hdr = ''
        for lnum in range(l:start, min([l:start+8, l:end]))
            let line = getline(lnum)
            if line =~# '^\s*$' | continue | endif
            let l:hdr = substitute(line, '^\s*', '', '')
            break
        endfor
        if empty(l:hdr)
            let l:hdr = substitute(getline(l:start), '^\s*', '', '')
        endif

        let l:lc = tolower(l:hdr)

        " param(...) blocks
        if l:lc =~# '^param\>'
            let l:paren = ''
            for lnum in range(l:start, min([l:strart+8, l:end]))
                let L = getline(lnum)
                if L =~# '('
                    let l:paren = L
                    break
                endif
            endfor
            let l:sig = l:paren ==# '' ? 'param (...)' : substitute(l:paren, '^\s*param\s*\(', 'param (', '')
            let l:sig = substitute(l:sig, '\s\+$', '', '')
            return l:sig . '... [' . l:lines . ' lines]'
        endif


        " function Foo { ... }
        if l:lc =~# '^function\>'
            let l:name = matchstr(l:hdr, '^\s*function\s\+\zs\S\+')
            if l:name ==# '' | let l:name = 'function' | endif
            return l:name . ' { … } [' . l:lines . ' lines]'
        endif

        " class Foo { ... }
        if l:lc =~# '^class\>'
            let l:name = matchstr(l:hdr, '^\s*class\s\+\zs\S\+')
            if l:name ==# '' | let l:name = 'class' | endif
            return l:name . ' { … } [' . l:lines . ' lines]'
        endif

        " enum Foo { ... }
        if l:lc =~# '^enum\>'
            let l:name = matchstr(l:hdr, '^\s*enum\s\+\zs\S\+')
            if l:name ==# '' | let l:name = 'enum' | endif
            return l:name . ' { … } [' . l:lines . ' lines]'
        endif

        " switch(...)
        if l:lc =~# '^switch\>'
            let l:cond = matchstr(l:hdr, '^\s*switch\s*(\zs.\{-}\ze)')
            if l:cond ==# '' | let l:cond = '…' | endif
            return 'switch (' . l:cond . ') { … } [' . l:lines . ' lines]'
        endif

        " try/catch/finally
        if l:lc =~# '^try\>'     | return 'try { … } [' . l:lines . ' lines]'     | endif
        if l:lc =~# '^finally\>' | return 'finally { … } [' . l:lines . ' lines]' | endif
        if l:lc =~# '^catch\>'
            let l:typ = matchstr(l:hdr, '^\s*catch\s*\[\zs[^]\r\n]\+\ze\]')
            let l:lbl = empty(l:typ) ? 'catch' : 'catch [' . l:typ . ']'
            return l:lbl . ' { … } [' . l:lines . ' lines]'
        endif

        " #region
        if l:lc =~# '^#\s*region'
            let l:tail = substitute(l:hdr, '^#\s*region\s*', '', '')
            let l:tail = empty(l:tail) ? 'region' : l:tail
            return '#region ' . l:tail . ' … [' . l:lines . ' lines]'
        endif

        " CBH block (<# ... #>) — show SYNOPSIS if available
        if l:lc =~# '^<#'
            let l:syn = ''
            for lnum in range(l:start, min([l:start+20, l:end]))
                let L = getline(lnum)
                if L =~? '^\s*\.\s*SYNOPSIS\>'
                    for s in range(lnum+1, min([lnum+5, l:end]))
                        let P = substitute(getline(s), '^\s*#\=\s*', '', '')
                        if P =~# '\S'
                            let l:syn = P
                            break
                        endif
                    endfor
                    break
                endif
            endfor
            let l:lbl = empty(l:syn) ? 'CBH' : ('CBH: ' . l:syn)
            return l:lbl . ' … [' . l:lines . ' lines]'
        endif

        " Default: first trimmed line
        let l:trim = substitute(l:hdr, '\s\+$', '', '')
        return l:trim . ' … [' . l:lines . ' lines]'
    endfunction
endif

setlocal foldtext=PoshFoldText()

" ---------------------------------------------------------------------------
" Commenting and formatting rules
" ---------------------------------------------------------------------------

" Default: PowerShell-style comments
setlocal commentstring=#\ %s

" Use Invoke-Formatter for script files, not ps1xml
if executable('pwsh')
  setlocal formatprg=
  if expand('%:e') !=# 'ps1xml'
    setlocal formatprg=pwsh\ -NoProfile\ -Command\ Invoke-Formatter
  endif
endif

" XML comment behavior for ps1xml files
if expand('%:e') ==# 'ps1xml'
  setlocal commentstring=<!--\ %s\ -->
  setlocal iskeyword-=-   " hyphen no longer part of word in XML context
endif

" ---------------------------------------------------------------------------
" Optional indentation override
" ---------------------------------------------------------------------------
if exists('g:posh_shiftwidth') && g:posh_shiftwidth > 0
  let &l:shiftwidth  = g:posh_shiftwidth
  let &l:tabstop     = g:posh_shiftwidth
  let &l:softtabstop = g:posh_shiftwidth
endif

" vim: set sw=2 ts=2 et:
