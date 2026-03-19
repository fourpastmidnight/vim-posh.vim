" =============================================================================
" Vim plugin file: PowerShell (posh) + embedded XML for *.ps1xml
" Plugin:              vim-posh
" File:                plugin/posh.vim
" Language:            PowerShell
" Purpose:             Bootstrap the plugin.
" Maintainer:          Craig E. Shea <fourpastmidnight@hotmail.com>
" Version:             1.0
" Last Change:         2026-02-27
" Project Repository:  https://github.com/fourpastmidnight/vim-posh.vim
" Vim Script Page:
" =============================================================================

if exists('g:loaded_posh')
  finish
endif
let g:loaded_posh = 1

" Syntax enhancement tier:
"     'base' - identical to upstream or your baseline
"     'plus' - small enhancements (opt-in later)
"     'full' - maximum features (never automatic)
let g:posh_syntax_level   = get(g:, 'posh_syntax_level', 'base') " base | plus | full

" Optional indentation engine
let g:posh_enable_indent  = get(g:, 'posh_enable_indent', 0)

" Optional folding engine
let g:posh_enable_fold    = get(g:, 'posh_enable_fold', 0)

" Backing selection for Step 2 syntax wrapper:
"     'auto' (default) | 'posh' | 'ps1'
let g:posh_disable_syntax_wrapper = get(g:, 'posh_disable_syntax_wrapper', 0)

" Allow quick opt-out of Step 2 wrapper
let g:posh_disable_syntax_wrapper = get(g:, 'posh_disable_syntax_wrapper', 0)
" vim: set sw=2 ts=2 sts=2 et:
