" =============================================================================
" Vim filetype detection: PowerShell (posh)
" Plugin:             vim-posh
" File:               ftdetect/posh.vim
" Purpose:            Detect PowerShell-related files and set 'filetype=posh';
"                     also detect shebangs for powershell/pwsh.
" Maintainer:         Craig Shea <fourpastmidnight@hotmail.com>
" Version:            1.0
" Last Change:        2026-02-27
" Project Repsoitory: https://github.com/fourpastmidnight/vim-posh.vim
" Vim Script Page:
" =============================================================================

" Set the filetype based on the filename extension
autocmd BufNewFile,BufRead   *.ps1,*.ps1xml,*.psm1,*.psd1,*.pssc  set ft=posh

" Set the filetype based on any shebang--for example, loose scripts
autocmd BufNewFile,BufRead *
            \ if getline(1) =~# '^#!.*\<powershell\>\|^#!.*\<pwsh\>' |
            \ setf ft=posh |
            \ endif

" vim: set sw=2 ts=2 sts=2 et:
