### Deprecated; please use [kylebarron/language-stata](https://github.com/kylebarron/language-stata), available on Atom as [`language-stata`](https://atom.io/packages/language-stata).

# language-stata package

A language syntax package for Stata code in Atom.

# Features

This package highlights:
- System commands, functions, and function arguments
- Macros, both global and local
- Regular expressions

Other nice features:
- Autocomplete for built-in commands and functions, and for macros as you write them.
- Alerts you if your variable name is illegal, i.e. if your variable name is more than 32 chars, starts with a number, or is a reserved name.
- Support for programming ligatures for all valid Stata syntax for fonts that support them, like the [Fira Code](https://github.com/tonsky/FiraCode) font.

This package includes syntax highlighting, but no tools for executing Stata code. 

To execute Stata code from Atom, consider the `stata-exec` or `script` packages in Atom.

Alternatively, if you're using Linux, consider using [Autokey](https://github.com/autokey-py3/autokey) with [scripts](https://github.com/kylebarron/stata-autokey) that programmatically copy and run lines of code in an open Stata window.
