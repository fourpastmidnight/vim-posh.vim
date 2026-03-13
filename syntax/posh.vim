" =============================================================================
" Vim syntax file: PowerShell (posh) + embedded XML for *.ps1xml
" Plugin:             vim-posh
" File:               syntax/posh.vim
" Language:           PowerShell
" Purpose:            PowerShell script highlighting + folds; when editing
"                     *.ps1xml, include full XML syntax and PowerShell
"                     semantic highlighting for PS formatting/type-extension
"                     tags, attributes, and content.
" Maintainer:         Craig E. Shea <fourpastmidnight@hotmail.com>
" Version:            1.0
" Last Change:        2026-02-27
" Project Repository: https://github.com/fourpastmidnight/vim-posh.vim
" Vim Script Page:
"
" Configuration:
"   g:posh_use_legacy_doccomments
"     = 1 -> <# ... #> are treated as documentation comments (and as block
"            comments); <## ... ##> are regular block comments.
"     = 0 -> <## ... ##> are documentation comments; <# ... #> are regular
"            block comments. (Default when unset.)
" =============================================================================

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" ----------------------------------------------------------------------------
" 0) Options & CBH keywords (script-local)
" ----------------------------------------------------------------------------
let s:use_legacy   = get(g:, 'posh_use_legacy_doccomments',      0)
let s:fold_cbh_all = get(g:, 'posh_fold_cbh_all',                0)
let s:fold_cbh_kw  = get(g:, 'posh_fold_cbh_only_with_keywords', 0)

let s:cbh_keywords = '\%(SYNOPSIS\|DESCRIPTION\|PARAMETERS\?\s\+\%(\S\+\)\|EX\%(AMPLES\?\|TERNALHELP\s\+\%(\w\.*\)\)\|INPUTS\|OUTPUTS\|NOTES\|LINKS\?\|COMPONENT\|R\%(EMOTEHELPRUNSPACE\s\+\%(\S\+\)\|OLE\)\|F\%(ORWARDHELP\%(CATEGORY\|TARGETNAME\)\|UNCTIONALITY\)\)'

let s:approved_verbs =
      \ 'Add\|Clear\|Close\|Copy\|Enter\|Exit\|Find\|Format\|Get\|Hide\|Join\|Lock\|Move\|New\|Open\|Optimize\|Pop\|Push\|Redo\|Remove\|Rename\|Reset\|Search\|Select\|Set\|Show\|Skip\|Split\|Step\|Switch\|Undo\|Unlock\|Watch\|' .
      \ 'Connect\|Disconnect\|Read\|Receieve\|Send\|Write\|' .
      \ 'Backup\|Checkpoint\|Compare\|Compress\|Convert\%(From\|To\)\?\|Dismount\|Edit\|Expand\|Export\|Group\|Import\|Initialize\|Limit\|Merge\|Mount\|Out\|Publish\|Restore\|Save\|Sync\|Unpublish\|Udpate\|' .
      \ 'Debug\|Measure\|Ping\|Repair\|Resolve\|Test\|Trace\|' .
      \ 'Approve\|Assert\|Build\|Complete\|Confirm\|Deny\|Deploy\|Disable\|Enable\|Install\|Invoke\|Register\|Request\|Restart\|Resume\|Start\|Stop\|Submit\|Suspend\|Uninstall\|Unregister\|Wait\|' .
      \ 'Block\|Grant\|Protect\|Revoke\|Unblock\|Unprotect\|Use'

" Optional override:
"   Override (regex string): let g:posh_approved_verbs = 'Get|\Set\|Find'
"   Override (list):         let g:posh_approved_verbs = ['Get', 'Set', 'Foo']
"   Extend (regex string):   let g:posh_approved_verbs_extra = 'Foo\|Bar'
"   Extend (list):           let g:posh_approved_verbs_extra = ['Foo','Bar']

" 1) Overrde defaults if g:posh_approved_verbs is provided.
if exists('g:posh_approved_verbs')
  if type(g:posh_approved_verbs) == type ('')
    " Direct regex alterantion provided by user
    let s:approved_verbs = g:posh_approved_verbs
  elseif type(g:posh_approved_verbs) == type([])
    " Join a list of verbs into a safe alternation
    let s:approved_verbs = join(map(copy(g:posh_approved_verbs), {_,v -> escape(v, '\.^$~[]|\')}), '\|')
  endif
endif

" 2) Always allow extension via g:posh_approved_verbs_extra
if exists('g:posh_approved_verbs_extra')
  if type(g:posh_approved_verbs_extra) == type('')
    let s:approved_axtra = g:posh_approved_verbs_extra
  elseif type(g:posh_approved_verbs_extra) == type([])
    let s:approved_extra = join(map(copy(g:posh_approved_verbs_extra),{_,v -> escape(v, '\.^$~[]|\')}), '\|')
  endif
endif

if exists('s:approved_extra') && !empty(s:approved_extra)
  let s:approvedVerbs = s:approved_verbs . '\|' . s:approved_extra
  unlet s:approved_extra
endif

" ----------------------------------------------------------------------------
" 1) Base PowerShell script syntax
" ----------------------------------------------------------------------------
" PowerShell is case-insensitive
syntax case ignore

syntax cluster poshNotTop        contains=poshComment,poshBlockComment,poshDocBlockComment
syntax cluster poshStringSpecial contains=@Spell,poshEscape,poshInterpolation,poshBracedVariable,poshScopedVariable,poshNsVariable,poshVariable,poshBoolean,poshConstant,poshAutomaticVar

" --- Single-line comments ---
syntax match  poshComment      "#.*" contains=@Spell,poshTodo
syntax keyword poshTodo        FIXME HACK NOTE TODO UNDONE XXX contained
hi def link   poshComment      Comment
hi def link   poshTodo         Todo

" Single-line CBH keywords (e.g., '# .SYNOPSIS')
execute 'syntax match poshDocKeyword /^\s*\.' . s:cbh_keywords . '\>/ containedin=poshComment'
hi def link poshDocKeyword SpecialComment

" ----------------------------------------------------------------------------
" 2) Block Comments & Comment-Based Help
"     (Comments-first ordering prevents leakage.)
" ----------------------------------------------------------------------------

" CBH keyword lines inside block comments (contained)
execute 'syntax match poshDocBlockKeyword /^\s*\.' . s:cbh_keywords . '\>/ contained'
hi def link poshDocBlockKeyword SpecialComment

" Doc/block comment regions: opaque, allow only CBH tag/Example handling
if s:use_legacy
  " Legacy: doc = <# ... #>, regular = <## ... ##>
  syntax region poshDocBlockComment start=/<#/   end=/#>/  keepend fold contains=@Spell,poshTodo,poshDocBlockKeyword,poshDocExampleTag
  syntax region poshBlockComment    start=/\<##/ end=/##>/ keepend contains=@Spell,poshTodo
else
  " Default: doc = <## ... ##>, regular = <# ... #>
  " Guard <## ...> so <### ...> banners are not misclassified as doc comments
  syntax region poshDocBlockComment start=/^\s*<##\%(\s\|$\)/ end=/^\s*##>\%(\s\|$\)/ keepend fold contains=@Spell,poshTodo,poshDocBlockKeyword,poshDocExampleTag
  syntax region poshBlockComment    start=/<#/   end=/#>/  keepend contains=@Spell,poshTodo
endif

hi def link poshDocBlockComment Comment
hi def link poshBlockComment    Comment

" ----------------------------------------------------------------------------
" 2a) .EXAMPLE handling — Variant B
"      Code from the first non-blank after '.EXAMPLE' → first blank line,
"      or next CBH header, or doc end. Prose after that is plain comment.
" ----------------------------------------------------------------------------

" PowerShell groups allowed inside example code (plus poshComment for code-#)
syntax cluster poshExampleCode contains=
      \ poshExHereStringD,poshExHereStringS,poshStringD,poshStringS,poshConstant,
      \ poshBracedVariable,poshScopedVariable,poshNsVariable,poshVariable,
      \ poshOperator,poshCast,poshKeyword,poshReservedKeyword,poshTypeName,
      \ poshCmdlet,poshEscape,poshUnaryBang,poshUnaryOpSign,poshUnaryComma,
      \ poshRange,poshSlice,poshArraySubExpr,
      \ poshNumberLit,poshParameter,poshCmdletConventional,poshFunctionHyphen,
      \ poshComment,poshBlockComment

" .EXAMPLE tag (inside doc block); jumps to first non-blank after it
syntax match poshDocExampleTag /^\s*\.EXAMPLE\>/ contained containedin=poshDocBlockComment nextgroup=poshDocExampleStart skipwhite skipnl
hi def link poshDocExampleTag SpecialComment

" Sentinel: first non-blank line after .EXAMPLE
syntax match poshDocExampleStart /^\s*\ze\S/ contained nextgroup=poshDocExampleCode skipwhite skipnl

" Example CODE region (variant B): first non-blank → first blank line / next CBH / doc end
syntax region poshDocExampleCode
    \ start=/./
    \ end=/^\s*$/
    \ end=/^\s*\.[A-Z]\+\>/
    \ end=/#>/
    \ end=/##>/
    \ keepend
    \ contained
    \ contains=poshComment,poshBlockComment,poshExHereStringD,poshExHereStringS,poshExamplePSLine,poshExampleContinuationLine,poshExampleOutputLine,poshExamplePromptContinuation

" --- PS> command lines: highlight the code AFTER the prompt with normal @poshCode ---
" Supports either PS> or 'PS <anything> >'
syntax region poshExamplePSLine
    \ matchgroup=poshExamplePromptPS
    \ start=/^\s*PS\%(\s\+[^>]*\)\?>\s*\zs/
    \ end=/$/
    \ keepend
    \ contained
    \ containedin=ALLBUT,poshExHereStringD,poshExHereStringS
    \ contains=@poshExampleCode

" --- >> continuation command lines: also highlight like code ---
syntax region poshExampleContinuationLine
    \ matchgroup=poshExamplePromptContinuation
    \ start=/^\s*>>\s*\zs/
    \ end=/$/
    \ keepend
    \ contained
    \ containedin=ALLBUT,poshExHereStringD,poshExHereStringS
    \ contains=@poshExampleCode

" --- Example-scoped here-strings ---
syntax region poshExHereStringD
    \ start=/@"\s*$/
    \ end=/^\s*>>\s*"@\s*$/
    \ keepend
    \ contained
    \ containedin=poshDocExampleCode
    \ contains=@poshStringSpecial,poshExamplePromptPS,poshExamplePromptContinuation,poshExamplePromptContinuationOnly

syntax region poshExHereStringS
    \ start=/@'\s*$/
    \ end=/^\s*>>\s*'@\s*$/
    \ keepend
    \ contained
    \ containedin=poshDocExampleCode
    \ contains=@Spell,poshExamplePromptPS,poshExamplePromptContinuation,poshExamplePromptContinuationOnly

hi def link poshExHereStringD String
hi def link poshExHereStringS String

syntax cluster poshExStringSpecial contains=
    \ poshEscape,
    \ poshBracedVariable,poshScopedVariable,poshNsVariable,poshVariable,
    \ poshExInterpolation

syntax region poshExInterpolation
    \ matchgroup=Delimiter
    \ start=/\$(/ end=/)/
    \ keepend
    \ contained
    \ contains=@poshInterpCode,poshExNestedParentheses,poshExInterpolation

syntax region poshExNestedParentheses
    \ matchgroup=Delimiter
    \ start=/(/ end=/)/
    \ skip=/\\\\\|\\)/
    \ keepend
    \ transparent
    \ contained
    \ contains=@poshInterpCode,poshExNestedParentheses,poshExInterpolation

" --- Prompt tokens (for styling the PS ...> or >> prefixes) ---
syntax match poshExamplePromptPS               /^\s*PS\%(\s\+[^>]*\)\?>\s*/ contained containedin=poshDocExampleCode,poshExamplePSLine,poshExHereStringD,poshExHereStringS
syntax match poshExamplePromptContinuation     /^\s*>>\s/                   contained containedin=poshDocExampleCode,poshExampleContinuationLine,poshExHereStringD,poshExHereStringS
syntax match poshExamplePromptContinuationOnly /^\s*\zs>>\ze\s*$/           contained containedin=poshExHereStringD,poshExHereStringS contains=NONE
syntax match poshExampleHereBodyLine           /^\s*>>\s*\S.*$/             contained containedin=poshExHereStringD,poshExHereStringS contains=@poshStringSpecial,poshExamplePromptContinuation
hi def link poshExamplePromptPS               SpecialComment
hi def link poshExamplePromptContinuation     SpecialComment
hi def link poshExamplePromptContinuationOnly SpecialComment
hi def link poshExampleHereBodyLine           String

" --- Output lines (NOT PS> or >>): show as plain text--no code highlighting ---
syntax match poshExampleOutputLine /^\s*\%(\%(PS\%(\s\+[^>]*\)\?\|>>\)\)\@!\S.*$/ contained containedin=poshDocExampleCode
hi def link poshExampleOutputLine Normal

" ----------------------------------------------------------------------------
" 3) Strings & Here-Strings
" ----------------------------------------------------------------------------
syntax region poshStringD      start=/"/  skip=/`"/ end=/"/   contains=@poshStringSpecial
syntax region poshStringS      start=/'/  skip=/''/ end=/'/   contains=@Spell
syntax region poshHereStringD  start=/@"\n/ end=/^"@/         contains=@poshStringSpecial
syntax region poshHereStringS  start=/@'\n/ end=/^'@/         contains=@Spell
hi def link poshStringD      String
hi def link poshStringS      String
hi def link poshHereStringD  String
hi def link poshHereStringS  String

" Code allowed inside string interpolation (lean set; no fold/top-level regions)
syntax cluster poshInterpCode contains=
    \ poshOperator,poshCast,poshKeyword,poshReservedKeyword,poshConstant,poshTypeName,
    \ poshEscape,poshBracedVariable,poshScopedVariable,poshNsVariable,poshVariable,
    \ poshArraySubExpr,poshIndex,
    \ poshStringD,poshStringS,poshHereStringD,poshHereStringS,
    \ poshNumberLit,poshParameter,poshSplat,poshFunctionHyphen,poshCmdletConventional,
    \ poshCallOp

" --- String interpolation ($(...)) inside double-quoted strings ---
" Keep this contained (only activated by string containers above).
" Allow nested $(....) and nested (...) via a helper region, so )
" inside method calls or casts doesn't prematurely end the outer
" interpolation.

" Interpolation region: $(...)
syntax region poshInterpolation matchgroup=poshInterpolationDelimiter start=/\$(/ end=/)/ contained contains=ALLBUT,@poshNotTop
hi def link poshInterpolationDelimiter Delimiter

" Parentheses nested inside interpolation (e.g. MethodCall(...))
syntax region poshNestedParentheses matchgroup=Delimiter start=/(/ end=/)/ skip=/\\\\\|\\)/ keepend transparent contained

" --- Powell escape sequences (double-quoted contexts) ---
" Scope: contained - only active in containers that list poshEscape
" Matches:
"     `0 (Null), `a (Alert), `b (Backspace), `e (Escape, PS6+), `f (Form
"     Feed), `n (New Line), `r (Carriage Return), `t (Horz. Tab), `u{x}
"     (Unicode escape sequence, pS6+), `v (Vert. Tab), `x{nn} (Hex char, PS6+)
syntax match poshEscape /`["'$`]/               contained
syntax match poshEscape /`[0abefnrtv]/          contained
syntax match poshEscape /`x[0-9A-Fa-f]\{2}/     contained
syntax match poshEscape /`u{[0-9A-Fa-f]\{1,6}}/ contained
hi def link poshEscape SpecialChar

" ----------------------------------------------------------------------------
" 4) Numeric Literals - Integers and Reals
" ----------------------------------------------------------------------------
"
" Shapes we admit:
"   * Integers:          \d+   | 0x[0-9A-Fa-f]+ | 0[bB][01]+ (PS7+)
"   * Reals (dot):       \d+\.\d+  (optional exponent)
"   * Reals (exp):       \d+[eE][+-]\?\d+
"   * Type suffix:       uy|y|us|s|ul|l|u|n|d
"   * Multiplier:        kb|mb|gb|tb|pb
"   * Order:             <number><type?><multiplier?>
"
syntax match poshNumberLit /\<\%(0[xX][0-9A-Fa-f]\+\|0[bB][01]\+\|\d\?\.\d\?\%([eE][+-]\?\d\+\)\=\|\d\+[eE][+-]\?\d\+\|\d\+\)\%(uy\|y\|us\|s\|ul\|l\|u\|n\|d\)\?\%([kKmMgGtTpP][bB]\)\?\>/ containedin=ALLBUT,poshComment,poshBlockComment,poshDocBlockComment,poshStringD,poshStringS,poshHereStringD,poshHereStringS,poshExHereStringD,poshExHereStringS,xmlRegion,xmlString,xmlCdata
hi def link poshNumberLit Number

" ----------------------------------------------------------------------------
" 5) Variables (scoped, namespaced, braced, generic)
" ----------------------------------------------------------------------------
syntax region poshBracedVariable start=/\${/ end=/}/ keepend contains=poshVarSigil,poshVarLBrace,poshVarRBrace,poshVarScope,poshVarNamespace,poshVarColon,poshVarNameLoose

syntax match poshVarSigil     /\$/        contained
syntax match poshVarLBrace    /{/         contained
syntax match poshVarRBrace    /}/         contained
syntax match poshVarScope     /\%(global\|script\|private\|local\|using\)/  contained
syntax match poshVarNamespace /\%(env\|executioncontext\)/                  contained
syntax match poshVarColon     /:/         contained
syntax match poshVarNameLoose /[^}][^}]*/ contained

syntax match poshScopedVariable /\$\%(global\|script\|private\|local\|using\)\s*:\s*[A-Za-z_][A-Za-z0-9_]*/ contains=poshVarSigil,poshVarScope,poshVarColon,poshVarName

syntax match poshNsVariable /\$\%(env\|executioncontext\)\s*:\s*[A-Za-z_][A-Za-z0-9_]*/ contains=poshVarSigil,poshVarNamespace,poshVarColon,poshVarName

syntax match poshVarName /[A-Za-z_][A-Za-z0-9_]*/ contained

syntax match poshVariable "\$[A-Za-z_][A-Za-z0-9_]*\(:[A-Za-z_][A-Za-z0-9_]*\)\?"

hi def link poshVarSigil       SpecialChar
hi def link poshVarLBrace      Delimiter
hi def link poshVarRBrace      Delimiter
hi def link poshVarScope       PreProc
hi def link poshVarNamespace   Type
hi def link poshVarColon       Delimiter
hi def link poshVarNameLoose   Identifier
hi def link poshVarName        Identifier
hi def link poshScopedVariable Identifier
hi def link poshNsVariable     Identifier
hi def link poshVariable       Identifier

" ----------------------------------------------------------------------------
" 6) Types & Brackets
" ----------------------------------------------------------------------------
syntax match  poshTypeName "\[[A-Za-z_][A-Za-z0-9_.\[\],]*\]" contains=NONE
" [Type] cast - highlight only the brackets as operator: inner remains
" poshTypeName
syntax region poshCast          matchgroup=Type start=/\%(^\|\s\|[([{,;|]\)\zs\[/  end=/]/       keepend transparent           contains=poshTypeName containedin=ALLBUT,poshAttribute,poshStringD,poshStringS,poshHereStringD,poshHereStringS,poshExHereStringD,poshExHereStringS,poshComment,poshBlockComment,poshDocBlockComment,xmlRegion,xmlString,xmlCdata
syntax region poshAttribute     matchgroup=Delimiter start="\%(^\|\s\|[([{,;|]\)\zs\["  end="\]" keepend transparent           contains=poshTypeName,poshAttributeArgs
syntax region poshAttributeArgs matchgroup=Delimiter start=/(/                          end=/)/  keepend transparent contained contains=@poshExampleCode containedin=poshAttribute
hi def link   poshTypeName Type
" TODO: Change this highlighting link for attributes....
hi def link   poshAttribute PreProc

" ----------------------------------------------------------------------------
" 7) Operators, Keywords, Reserved Keywords, Types, Cmdlets, Escapes
" ----------------------------------------------------------------------------
" Arithmetic operators
syntax match poshOperator /[-+*%\/]\%(\h\)\@!/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine
" Assignment operators
syntax match poshOperator /[-+*%\/]\?=/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine
" Comparison operators
syntax match poshOperator /-[ci]\?\%(eq\|ne\|gt\|ge\|lt\|le\)\>/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine
" Containment operators
syntax match poshOperator /-[ci]\?\%(not\)\?\%(contains\|in\)\>/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine
" Pattern-matching and text-manipulation operators
syntax match poshOperator /-\%([ci]\?\%(not\)\?\%(like\|match\|replace\|split\)\|join\)\>/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine
" Logical and bitwise operators
syntax match poshOperator /-\%(sh[lr]\|b\?\%(and\|x\?or\|not\)\)\>/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine
" Type operators
syntax match poshOperator /-\%(is\%(not\)\?\|as\)\>/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine

" -----------------------------------------------------------------------------
"  Unary operators (placed AFTER broad operator matches above so they take
"  precedence)
" -----------------------------------------------------------------------------
" Unary + / - (prefix sign only), allowing numbers, $, quotes, grouping (,
" casts [, and here-strings (@" / @') - but NOT array subexpressions (@(...)).
syntax match poshUnaryOpSign /\%(^\|[([{;,|=?:]\)\s*\zs[+-]\ze\s*\%(\d\|\$\|["']\|(\|\[\|@\%(["']\)\)/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine
hi def link poshUnaryOpSign Operator
" Unary ! operator
syntax match poshUnaryBang /\%(^\|[([{;,|=?:]\)\s*\zs!\ze\s*\S/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine
hi def link poshUnaryBang Operator
" Unary comma at expression start (array construction)
syntax match poshUnaryComma /\%(^\|[([{;,|=?:]\)\s*\zs,\ze\s*\S/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine
hi def link poshUnaryComma Operator
" Increment / Decrement (always unary)
syntax match poshOperator /++\|--/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine

" Property and method reference operators
syntax match poshOperator /::/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine
syntax match poshMemberDot /\%(\h\|\]\|)\)\zs\.\ze\%(\h\|[[(]\)/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine
"hi def link poshMemberDot Operator
hi def link poshMemberDot Delimiter
" Format operator
syntax match poshOperator /-f\>/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine
" Redirection operators
syntax match poshOperator /\d\?>\%(>\|&\d\)/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine
hi def link poshOperator Operator

syntax match poshCallOp /\%(&\|\.\%(\s\+\)\@=\)/ containedin=ALLBUT,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine
hi def link poshCallOp Operator

" ----------------------------------------------------------------------------
" 8) Grouping & Sub-experssion regions
" ----------------------------------------------------------------------------
"syntax region poshSubExpr      start=/\$(/ end=/)/ matchgroup=Delimiter keepend transparent contained contains=@poshExampleCode,poshSubExpr containedin=ALLBUT,poshStringD,poshstringS,poshHereStringD,poshHereStringS,poshInterpolation
syntax region poshArraySubExpr matchgroup=Delimiter start=/@(/  end=/)/ keepend transparent           contains=@poshExampleCode,poshArraySubExpr,poshSubExpr
"syntax region poshParenGroup   start=/(/   end=/)/ matchgroup=Delimiter keepend transparent           contains=@poshExampleCode,poshParenGroup,poshSubExpr

" ----------------------------------------------------------------------------
" 9) Indexers
" ----------------------------------------------------------------------------
syntax region poshIndex           matchgroup=Delimiter start=/\%(\k\|\]\|)\|["']\)\s*\zs\[\%(\s*\h\)\@!/ end=/]/ keepend transparent       contains=@poshExampleCode,poshSubExpr,poshArraySubExpr containedin=ALLBUT,poshTypeName,poshAttribute,poshCast,poshStringD,poshStringS,poshHereStringD,poshHereStringS,poshExHereStringD,poshExHereStringS,poshComment,poshBlockComment,poshDocBlockComment,xmlRegion,xmlString,xmlCdata
" Indexer operators
syntax match poshRange /\.\./ contained containedin=poshIndex
"hi def link poshRange Operator
hi def link poshRange Delimiter
syntax match poshSlice /,/ contained containedin=poshIndex
"hi def link poshSlice Operator
hi def link poshSlice Delimiter

" ----------------------------------------------------------------------------
" 10) Miscellaneous operators
" ----------------------------------------------------------------------------
" Splat operator
syntax match poshSplat /@\h\w*\>/ containedin=ALLBUT,poshStringD,poshStringS,poshHereStringD,poshHereStringS,xmlRegion,xmlString,xmlCdata skipwhite skipnl
hi def link poshSplat Operator
" Stop parsing token
"syntax match poshStopParsing /\%(^\|\s\)\zs--%\ze\%(\s\|$\)/ containedin=ALLBUT,poshStringD,poshStringS,poshHereStringD,poshHereStringS,xmlRegion,xmlString,xmlCdata
"hi def link poshStopParsing Operator
syntax region poshStopParsingRHS start=/\%(^\|\s\)\zs--%/ end=/$/ keepend oneline containedin=ALLBUT,poshStringD,poshStringS,poshHereStringD,poshHereStringS,xmlRegion,xmlString,xmlCdata contains=NONE
hi def link poshStopParsingRHS String
" End of parameters token
syntax match poshParamEnd /\%(^\|\s\)\zs--\%(%\)\@!\ze\%(\s\|$\)/ containedin=ALLBUT,poshStringD,poshStringS,poshHereStringD,poshHereStringS,xmlRegion,xmlString,xmlCdata
hi def link poshParamEnd Operator
" Home directory expansion token
"syntax match poshHomeTilde /\%(^\|\s\|[([{=,:;|]\)\zs~\ze\(\$\|[\/\\]\)/ containedin=ALLBUT,poshStringD,poshStringS,poshHereStringD,poshHereStringS,xmlRegion,xmlString,xmlCdata
hi def link poshHomeTilde Special

" ----------------------------------------------------------------------------
" 11) Functions/Cmdlets and their parameters
" ----------------------------------------------------------------------------
"syntax match poshFunctionKW /\%(^\|\s\)\zs\%(function\|filter\)\>/ nextgroup=poshFuncName skipwhite skipnl containedin=ALLBUT,poshComment,poshBlockComment,poshDocBlockComment,poshStringD,poshStringS,poshHereStringD,poshHereStringS,xmlRegion,xmlString,xmlCdata
"hi def link poshFunctionKW Keyword
syntax match poshFuncScope /\%(global\|script\|local\|private\):/ contained nextgroup=poshFuncName skipwhite
" TODO: May want to change the syntax highlight associated with this...
hi def link poshFuncScope PreProc
"syntax match poshFuncName /\%(\h\w*\\\)\?\h\w*\%(-\h\w*\)*/ contained
"hi def link poshFuncName Function

" -----------------------------------------------------------------------------
"  11a) Conventional vs. non-conventional hyphenated function names
" -----------------------------------------------------------------------------
" Conventional cmdlets (those with approved verbs): highlight whole token as
" Function. Optional prefixes: Module\Name OR Drive:\Name
execute 'syntax match poshCmdletConventional /\<\%(\h\k*:\\\|\h\k*\\\)\?\%(' . s:approved_verbs . '\)\%(-\k\+\)\+\>/ containedin=ALLBUT,poshComment,poshBlockComment,poshDocBlockComment,poshStringD,poshStringS,poshHereStringD,poshHereStringS,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine,xmlRegion,xmlString,xmlCdata,poshCast,poshAttribute,poshTypeName,poshAttributeArgs'
hi def link poshCmdletConventional Function

" Hyphenated function names (fallback when verb is not in the approved list).
" These are visually different (Identifier) to flag non-conventional naming.
syntax match poshFunctionHyphen /\<\%(\h\k*:\\\|\h\k*\\\)\?\k\+\%(-\k\+\)\+\>/ containedin=ALLBUT,poshComment,poshBlockComment,poshDocBlockComment,poshStringD,poshStringS,postHereStringD,poshHereStringS,poshExHereStringD,poshExHereStringS,xmlRegion,xmlString,xmlCdata,poshCast,poshAttribute,poshTypeName,poshAttributeArgs contains=poshCmdletConventional
hi def link poshFunctionHyphen Identifier

syntax match poshParameter /\<-\%(-\|%\)\@!\%(\%([ci]\)\?\%(not\)\?\%(eq\|ne\|gt\|ge\|lt\|le\|contains\|in\|like\|match\|replace\|split\|join\|b\?\%(and\|x\?or\)\|bnot\|sh[lr]\|is\%(not\)\?\|as\|f\)\>\)\@!\h\w*\>/ containedin=ALLBUT,poshComment,poshBlockComment,poshDocBlockComment,poshStringD,poshStringS,poshHereStringD,poshHereStringS,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine,xmlRegion,xmlString,xmlCdata,poshCast,poshAttribute,poshTypeName,poshAttributeArgs contains=poshCmdletConventional
hi def link poshParameter Identifier

syntax keyword poshKeyword
      \ begin break catch class clean continue data default do dynamicparam
      \ else elseif end enum exit extends filter finally for foreach function
      \ hidden if in param private process protected public return static
      \ switch throw trap try until using where while workflow
      \ containedin=ALLBUT,poshCast,poshAttribute,poshIndex,poshTypeName,poshComment,poshBlockComment,poshDocBlockComment,poshStringD,poshStringS,poshHereStringD,poshHereStringS,poshExHereStringD,poshExHereStringS,poshExampleHereBodyLine
hi def link poshKeyword Keyword

syntax keyword poshReservedKeyword case define export from global import namespace containedin=ALLBUT,poshCast,poshAttribute,poshIndex,poshTypeName,poshComment,poshBlockComment,poshDocBlockComment,poshStringD,poshStringS,poshHereStringD,poshHereStringS,poshExHereStringD,poshExHereStringS
hi def link poshReservedKeyword Special

" --- Type core word inside [ ... ] (override keywords only in type brackets) ---
" Matches an identifier (optionally dotted) that is the inner word of a [...]
" type. Restricted to cast/attribute brackets so it won't affect indexers.
" This rule MUST appear after poshKeyword/poshReservedKeyword to work
" properly.
syntax match poshTypeCore /\%(\[\)\@<=\s*\zs\h\w*\%(\.\h\w*\)*\ze\_s*\%(\[\|]\)/ containedin=poshCast,poshAttribute
hi def link poshTypeCore Type

" ----------------------------------------------------------------------------
" 12) Folding for scripts (syntax-driven)
" ----------------------------------------------------------------------------
syntax region poshRegion         start=/^\s*#\s*region/ end=/^\s*#\s*endregion/ fold keepend
hi def link   poshRegion         PreProc

syntax region poshBracesFold     start=/{/ end=/}/ fold transparent

syntax region poshParamFold      start=/^\s*param\>\_s*(/ms=e+1 end=/)/me=s-1 fold keepend transparent
syntax region poshFunctionFold   start=/^\s*function\>\_.\{-}\_s*{/ms=e+1 end=/^\s*}/me=s-1 fold keepend transparent
syntax region poshClassFold      start=/^\s*class\>\_.\{-}\_s*{/ms=e+1 end=/^\s*}/me=s-1 fold keepend transparent
syntax region poshEnumFold       start=/^\s*enum\>\_.\{-}\_s*{/ms=e+1 end=/^\s*}/me=s-1 fold keepend transparent
syntax region poshSwitchFold     start=/^\s*switch\>\_s*(\_.\{-})\_s*{/ms=e+1 end=/^\s*}/me=s-1 fold keepend transparent

" Optional per-case folding inside switch
if get(g:, 'posh_fold_switch_cases', 0)
  syntax region poshSwitchCaseFold start=/^\s*\%(default\|'\_.\{-}'\|"\_.\{-}"\|{\_.\{-}}\)\_s*{/ms=e+1 end=/^\s*}/me=s-1 fold keepend transparent containedin=poshSwitchFold
endif

syntax region poshTryFold        start=/^\s*try\>\_s*{/ms=e+1 end=/^\s*}/me=s-1 fold keepend transparent
syntax region poshCatchFold      start=/^\s*catch\>\_s*\%(\[[^]\r\n]\_s*\)\?{/ms=e+1 end=/^\s*}/me=s-1 fold keepend transparent
syntax region poshFinallyFold    start=/^\s*finally\>\_s*{/ms=e+1 end=/^\s*}/me=s-1 fold keepend transparent

" ----------------------------------------------------------------------------
" 13) Embedded XML for *.ps1xml + PowerShell semantics
" ----------------------------------------------------------------------------
if expand('%:e') ==# 'ps1xml'
  syntax include @xml syntax/xml.vim

  syntax region poshXmlFile start=+\%1l\_s*+ end=+\%$+ contains=@xml keepend

  syntax match  poshXmlPsTagName /\<\(Types\|Type\|TypeName\|Members\|MemberSet\|ScriptMethod\|ScriptProperty\|NoteProperty\|AliasProperty\|ViewDefinitions\|View\|ViewSelectedBy\|SelectionSet\|SelectionCondition\|ListControl\|ListEntries\|ListEntry\|TableControl\|TableHeaders\|TableColumnHeader\|TableColumnItems\|TableColumnItem\|TableRowEntries\|TableRowEntry\|FormatString\|FormatCondition\|Label\|GroupBy\|DisplayEntry\|ExpressionBinding\|ScriptBlock\|PropertyName\)\>/ containedin=xmlTagName
  hi def link poshXmlPsTagName Structure

  syntax match  poshXmlPsAttribName /\<\(Name\|ReferenceName\|TypeName\|Alignment\|Width\|DisplayName\|Condition\|Expression\)\>/ containedin=xmlAttrib
  hi def link poshXmlPsAttribName Identifier

  syntax region poshXmlTypeNameText start=+<TypeName>\s*+ end=+</TypeName>+ keepend contains=poshXmlTypeToken,@Spell
  syntax match  poshXmlTypeToken /\<[A-Za-z_][A-Za-z0-9_.\[\],]*\>/ contained containedin=poshXmlTypeNameText
  hi def link poshXmlTypeToken Type

  syntax region poshXmlPropertyNameText start=+<PropertyName>\s*+ end=+</PropertyName>+ keepend contains=poshXmlPropertyToken,@Spell
  syntax match  poshXmlPropertyToken /\<[A-Za-z_][A-Za-z0-9_.]*\>/ contained containedin=poshXmlPropertyNameText
  hi def link poshXmlPropertyToken Identifier

  syntax region poshXmlScriptBlock start=+<ScriptBlock>\s*+ end=+</ScriptBlock>+ keepend
        \ contains=poshStringD,poshStringS,poshHereStringD,poshHereStringS,
        \ poshVariable,poshOperator,poshKeyword,poshTypeName,poshCmdlet,poshEscape,@Spell
        \ containedin=xmlRegion,xmlString,xmlCdata
  hi def link poshXmlScriptBlock Special

  syntax region poshXmlFoldView        start=+<View\>\|<ViewDefinitions\>+  end=+</View>\|</ViewDefinitions>+  fold keepend transparent
  syntax region poshXmlFoldTable       start=+<TableControl>+               end=+</TableControl>+              fold keepend transparent
  syntax region poshXmlFoldList        start=+<ListControl>+                end=+</ListControl>+               fold keepend transparent
  syntax region poshXmlFoldMemberSet   start=+<MemberSet>+                  end=+</MemberSet>+                 fold keepend transparent
endif

" --- Syntax synchronization anchors for dock blocks ---
" Keehe min/max modest; anchors do the heavy lifting.
syntax sync minlines=200
syntax sync maxlines=1000

" Clear any prior anchors if re-sourced
silent! syntax clear poshSyncDocStart poshSyncDocEnd
silent! syntax clear poshSyncRegStartHash poshSyncRegEndHash
silent! syntax clear poshSyncRegStartHash2 poshSyncRegEndHash2
silent! syntax clear poshSyncLegacyDoc poshSyncLegacyDoc2

if s:use_legacy
  " 1) Baseline anchors: treat both openers as REGULAR comment containers.
  "     (This prevents falling out of comment when sync starts mid-block.)
  syntax sync match poshSyncRegStart grouphere  poshBlockComment /^\s*<##\?/
  syntax sync match poshSyncRegEnd   groupthere NONE             /^\s*#\+>/

  " 2) Doc "upgrade" anchors:
  "    If a CBH header appears near the top of the block, sync as DOC.
  "    We reuse s:cbh_keywords and look ahead up to ~8 logical lines.
  "    (Tune {,8} if your CBH header is farther down.)
  "
  " Build a CBH header line fragment the same way the matchers currently do:
  "    ^\s*\.{CBH}\>
  let s:cbh_line = '\s*\.\%(' . s:cbh_keywords . '\)\>'

  " Upgrade when opener is <# and a CBH header is found within a short window
  execute 'syntax sync match poshSyncLegacyDoc  grouphere poshDocBlockComment /^\s*<##\?\%(\_s*\n\)\{,8}' . s:cbh_line . '/'
else
  " ---------------------------------------------------------------------------
  "  MODERN MODE
  "  Requirements: <## ... ##> = Doc Block Comment; <# ... #> = Block comment
  " ---------------------------------------------------------------------------
  syntax sync match poshSyncDocStart  grouphere  poshDocBlockComment /^\s*<##\%(\s\|$\)/
  syntax sync match poshSyncDocEnd    groupthere NONE                /^\s*##>\%(\s\|$\)/
  syntax sync match poshSyncRegStart  grouphere  poshBlockComment    /^\s*<#/
  syntax sync match poshSyncRegEnd    groupthere NONE                /^\s*#>/
endif

let b:current_syntax = "posh"
