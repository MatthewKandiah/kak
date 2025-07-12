eval %sh{kak-lsp}
lsp-enable

# Set the colour scheme
colorscheme lucius

# Width of a tab
set-option global tabstop 4

# Indent with 4 spaces
set-option global indentwidth 4

# Always keep 8 lines and 3 columns displayed
set-option global scrolloff 8,3

# Display the status bar on top
set-option global ui_options ncurses_status_on_top=true

# Display line numbers
add-highlighter global/ number-lines -hlcursor

# Highlight trailing whitespace
add-highlighter global/ regex \h+$ 0:Error

# Softwrap long lines
add-highlighter global/ wrap -word -indent

# Clipboard management mappings
map -docstring "yank the selection into the clipboard" global user y "<a-|> xsel -i<ret>"
map -docstring "paste the clipboard" global user p "<a-!> xsel<ret>"

