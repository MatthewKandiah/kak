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

# Convenient vertical navigation mappings
map -docstring "jump down by paragraph" global normal ) "]p;"
map -docstring "jump up by paragraph" global normal ( "[pk"

# mawww's find function
define-command find -params 1 %{ edit %arg{1} }
complete-command -menu find shell-script-candidates %{ fd }
map -docstring "fuzzy find files" global user f ":find<space>"

# grep and dump to scratch buffer
define-command search -params 1 %{
    echo %sh{echo "search term: $1"}
    set-register | %sh{ grep -r $1 --line-number }
    edit -scratch *grep-output*
    exec '%d"|p;'
}
map -docstring "run grep" global user g ":search<space>"

# disable insert hooks to stop it auto-commenting lines
set-option global disabled_hooks .*-insert

# LSP config
eval %sh{kak-lsp}
# enable to get debug output in *debug*
set global lsp_debug true
lsp-enable

# Recommended LSP keymaps
map global user l ':enter-user-mode lsp<ret>' -docstring 'LSP mode'
map global insert <tab> '<a-;>:try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>' -docstring 'Select next snippet placeholder'
map global object a '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
map global object <a-a> '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
map global object f '<a-semicolon>lsp-object Function Method<ret>' -docstring 'LSP function or method'
map global object t '<a-semicolon>lsp-object Class Interface Struct<ret>' -docstring 'LSP class interface or struct'
map global object d '<a-semicolon>lsp-diagnostic-object --include-warnings<ret>' -docstring 'LSP errors and warnings'
map global object D '<a-semicolon>lsp-diagnostic-object<ret>' -docstring 'LSP errors'

# Enable Odin LSP
# TODO - replace hardcoded odin paths with $ODIN_ROOT
hook -group lsp-filetype-odin global BufSetOption filetype=(?:odin) %{
    set-option buffer lsp_servers %{
        [ols]
        root_globs = [".git"]
        settings_section = "ols"
    	[[ols.settings.ols.collections]]
    	name = "core"
		path = "/home/matt/code/odin-linux-amd64-nightly+2025-06-02/core"
		[[ols.settings.ols.collections]]
		name = "vendor"
		path = "/home/matt/code/odin-linux-amd64-nightly+2025-06-02/vendor"
		[[ols.settings.ols.collections]]
		name = "base"
		path = "/home/matt/code/odin-linux-amd64-nightly+2025-06-02/base"
    }
}

