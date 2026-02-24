
# vim-posh  

## A complete PowerShell filetype plugin for Vim and Neovim

`vim-posh` provides advanced PowerShell editing support including syntax
highlighting, folding, document-based help awareness, scoped variables,
braced variable parsing, and embedded XML formatting-file support.

## ✨ Features

### Syntax

- Full PowerShell language coverage  
- Real + reserved keywords (including clean, class, enum, extends, static, etc.)  
- Cmdlet highlighting: Verb-Noun  
- Scoped variables ($global:, $script:, $private:, $local:, $using:)  
- Namespaced variables ($env:, $executioncontext:)  
- Braced variables: ${My variable name}  
- Embedded PS inside `<ScriptBlock>` tags  
- XML semantic awareness for `.ps1xml` files  

### Folding

- `param( … )`  
- `function Name { … }`  
- `class Name { … }`  
- `enum Name { … }`  
- `switch (…) { … }` (with optional per-case folds)  
- `try`, `catch`, `finally`  
- Comment-Based Help blocks (`<# … #>`)  
- `#region / #endregion`  
- Generic brace-based folding  
- Smart foldtext summarizing each region  

### XML Integration

- Full XML syntax highlighting  
- Semantic tag/attribute highlighting for PS formatting schema  
- Folding for `View`, `TableControl`, `ListControl`, `MemberSet`, etc.  

### Indentation

- Custom PowerShell indentation engine  
- XML indentation for `.ps1xml`

### Comment-Based Help

- Full CBH keyword detection via an advanced regex  
- Optional folding only when CBH keywords are present  
- Foldtext extracts the `.SYNOPSIS` line if available  

## 📦 Installation

Below are installation examples for different plugin managers.

### 1. Built‑in Vim/Neovim package manager (recommended)

Place this repo at:

```
~/.vim/pack/posh/start/vim-posh/
```

or (Vim 9.2.0+)

```
~/.config/.vim/pack/posh/start/vim-posh/
  ```

or (Neovim):

```
~/.local/share/nvim/site/pack/posh/start/vim-posh/
```

or (Windows):

```
%USERPROFILE%/vimfiles/pack/posh/start/vim-posh/
```

No additional config is needed.

### 2. vim‑plug

```
Plug 'yourname/vim-posh'
```

Then:

```
:PlugInstall
```

### 3. Vundle

```
Plugin 'yourname/vim-posh'
```

Then:

```
:PluginInstall
```

### 4. Pathogen

```
cd ~/.vim/bundle
git clone https://github.com/yourname/vim-posh.git
```

Ensure Pathogen is loaded:

```
execute pathogen#infect()
```

### 5. packer.nvim

```lua
use 'yourname/vim-posh'
```

### 6. lazy.nvim

```lua
{
  'yourname/vim-posh',
  event = { 'BufReadPre *.ps1', 'BufReadPre *.psm1', 'BufReadPre *.ps1xml' },
}
```

### 7. Manual runtimepath install

Add this to your config:

```
set rtp+=/path/to/vim-posh
```

## 🔧 Required: Disable Vim’s Built‑In PowerShell Syntax

Vim ships with a minimal PowerShell syntax file:

```
$VIMRUNTIME/syntax/ps1.vim
```

Even when the `posh` filetype is active, some Vim configurations
(particularly on Windows) will *still* load the default `ps1.vim` as a
compatibility fallback. When this happens, the built‑in syntax overrides the
vim-posh syntax definitions, resulting in incorrect highlighting, broken
Comment-Based Help blocks, and inconsistent folding.

To ensure vim-posh is the only syntax applied to PowerShell files, you must
disable the built-in ps1 syntax by creating an override in your personal
`after` directory.

### Create this file:

**Unix/macOS**

```
~/.vim/after/syntax/ps1.vim
```

**Windows**

```
%USERPROFILE%\vimfiles\after\syntax\ps1.vim
```

### And place exactly this one line inside the file created above:

```vim
finish
```

This tells Vim: “Do not load ps1.vim syntax ever again.”
This also prevents other plugins (such as vim-polyglot, which bundles a
ps1 syntax file) from re‑enabling the old PowerShell syntax.

> [!IMPORNTANT]
> Do not include ps1-related overrides inside the vim-posh plugin directory.
> Those would cause Vim to reload ps1 settings for posh buffers. The override
> belongs only in your personal after/syntax directory.

## 🔧 Configuration Options
```
let g:posh_use_legacy_doccomments = 0
let g:posh_fold_cbh_all = 0
let g:posh_fold_cbh_only_with_keywords = 1
let g:posh_shiftwidth = 4
```

## 🧱 File Structure

```
ftdetect/posh.vim
ftplugin/posh.vim
syntax/posh.vim
indent/posh.vim
doc/posh.txt
README.md
```

## 📜 License

MIT. See [LICENSCE.md](LICENSE.md).

## 👤 Author

Craig Shea <fourpastmidnight@hotmail.com>

Pull requests welcome.
