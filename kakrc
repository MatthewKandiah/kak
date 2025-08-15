colorscheme lucius
set-option global tabstop 2
set-option global indentwidth 2
set-option global scrolloff 8,3
add-highlighter global/ number-lines -hlcursor
add-highlighter global/ number-lines -relative
add-highlighter global/ wrap -word -indent

# Highlight trailing whitespace
add-highlighter global/ regex \h+$ 0:Error

# Clipboard management mappings
map -docstring "yank the selection into the clipboard" global user y "<a-|> xsel --input --clipboard<ret>"
map -docstring "paste the clipboard" global user p "<a-!> xsel --clipboard<ret>"

# Convenient vertical navigation mappings
map -docstring "jump down by paragraph" global normal ) "]p;"
map -docstring "jump up by paragraph" global normal ( "[pk"

# mawww's find function - kept for cases where we're not in the right tmux directory for tmux popup searches to work
define-command find -params 1 %{ edit %arg{1} }
complete-command -menu find shell-script-candidates %{ fd }
map -docstring "fuzzy find files" global user f ":find<space>"

# disable insert hooks to stop it auto-commenting lines
set-option global disabled_hooks .*-insert

# LSP config
eval %sh{kak-lsp}
### enable to get debug output in *debug*
# set global lsp_debug true
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

# lazygit popup
define-command lazygit %{ nop %sh{
	tmux popup -w 90% -h 90% -E -e kak_command_fifo=$kak_command_fifo lazygit
}}
declare-user-mode git
map global user -docstring 'git mode' g ':enter-user-mode git<ret>'
map global git -docstring 'open lazygit' l ':lazygit<ret>'

# terminal popup (for file operations)
define-command terminal-popup %{ nop %sh{
  tmux popup -w 90% -h 90% -E
}}
map global user -docstring 'open terminal' t ':terminal-popup<ret>'

# start -- tweaked simple-fzf.kak
declare-user-mode sfzf
map global user -docstring 'sfzf mode' s ':enter-user-mode sfzf<ret>'

define-command -hidden sfzf-grep %{ nop %sh{
  tmux popup -w 90% -h 90% -E -e kak_command_fifo=$kak_command_fifo '
    RESULT="$(rg --line-number --no-hidden --color never "." | fzf)"
    FILE="$(echo $RESULT | cut -d: -f1)"
    LINE="$(echo $RESULT | cut -d: -f2)"
    echo "edit $FILE $LINE" > $kak_command_fifo
  '
}}
map global sfzf g ':sfzf-grep<ret>' -docstring 'grep file contents recursively'

define-command -hidden sfzf-git %{ nop %sh{
  tmux popup -w 90% -h 90% -E -e kak_command_fifo=$kak_command_fifo '
    FILE="$(git ls-tree --full-tree --name-only -r HEAD | fzf)"
    echo "edit $FILE" > $kak_command_fifo
  '
}}
map global sfzf p ':sfzf-git<ret>' -docstring 'find file in git project'

define-command -hidden sfzf-file %{ nop %sh{
  tmux popup -w 90% -h 90% -E -e kak_command_fifo=$kak_command_fifo '
    FILE="$(rg -L --no-hidden --no-ignore --files | fzf)"
    echo "edit $FILE" > $kak_command_fifo
  '
}}
map global sfzf f ':sfzf-file<ret>' -docstring 'find file'
# end -- simple-fzf.kak

# keep history of visited files
hook global WinDisplay .* %{
  echo "Hello there %val{bufname}"
  declare-option -hidden str mjk %val{bufname}
  evaluate-commands -draft %{edit -scratch *buf-history*} # ensure buffer exists before writing to it
  evaluate-commands -draft -buffer *buf-history* %{execute-keys "O%opt{mjk}"}
}
# fuzzy finder to open recent file
## really want to make the first command -draft so we don't jump to the history buffer
## but then we're in a context that quietly swallows our edit command!
## not sure how to handle more nicely!
define-command -hidden sfzf-recent-files %{
  evaluate-commands %{
    buffer *buf-history*
		execute-keys '%'
    nop %sh{
      tmux popup -w 90% -h 90% -E -e kak_reg_dot="$kak_reg_dot" -e kak_command_fifo=$kak_command_fifo '
        RESULT=$(echo $kak_reg_dot | sed "s/ /\n/g" | fzf)
        echo "edit $RESULT" > $kak_command_fifo
      '
    }
  }
}
map global sfzf . ':sfzf-recent-files<ret>' -docstring 'grep recent files'

