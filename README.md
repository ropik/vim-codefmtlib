codefmtlib is the interface between the
[codefmt](https://github.com/google/vim-codefmt) plugin and other plugins that
register formatters for codefmt. It offers no useful functionality by itself.

For details, see the executable documentation in the `vroom/` directory or the
helpfiles in the `doc/` directory. The helpfiles are also available via `:help
codefmtlib` if codefmtlib is installed (and helptags have been generated).

# Commands

Use `:FormatLines` to format a range of lines or use `:FormatCode` to format
the entire buffer.

# Installation and Usage

This example uses [Vundle](https://github.com/gmarik/Vundle.vim), whose
plugin-adding command is `Plugin`.

```vim
" Add maktaba and codefmt to the runtimepath.
" (The latter must be installed before it can be used.)
Plugin 'google/vim-maktaba'
Plugin 'google/vim-codefmtlib'
Plugin 'google/vim-codefmt'

let custom_formatter = { ... }
call codefmtlib#AddFormatter({custom_formatter})
```

