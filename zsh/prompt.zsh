# ==============================================================================
# Prompt Configuration (Pure zsh + vcs_info)
#
# Features:
#   - No oh-my-zsh dependency
#   - vcs_info based Git status
#   - Conda / VirtualEnv display
#   - Ruby version display (rbenv)
#   - Host alias via ~/.box-name
#   - Right prompt clock
#
# ==============================================================================

# ------------------------------------------------------------------------------
# zsh built-in modules
# ------------------------------------------------------------------------------

autoload -Uz colors
autoload -Uz vcs_info
autoload -Uz add-zsh-hook #fix

colors

# Enable command substitution inside PROMPT
setopt PROMPT_SUBST

# ------------------------------------------------------------------------------
# Color definitions
# ------------------------------------------------------------------------------

# Equivalent to old FG[247]
FG_NEUTRAL="%F{247}"

# ------------------------------------------------------------------------------
# Host name helper
# ------------------------------------------------------------------------------

# If ~/.box-name exists, use its contents as the hostname.
#
# Example:
#   echo "prod01" > ~/.box-name
#
# Prompt:
#   ryoma@prod01
#
box_name() {
    local box="${SHORT_HOST:-$HOST}"

    [[ -f ~/.box-name ]] && box="$(<~/.box-name)"

    # Escape % because PROMPT interprets it specially.
    print -r -- "${box//\%/%%}"
}

# ------------------------------------------------------------------------------
# Python virtual environment helper
# ------------------------------------------------------------------------------

# Display:
#
#   (base)
#   (venv)
#
virtualenv_info() {

    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        printf '(%s) ' "$CONDA_DEFAULT_ENV"
        return
    fi

    if [[ -n "$VIRTUAL_ENV" ]]; then
        printf '(%s) ' "${VIRTUAL_ENV:t}"
    fi
}

# ------------------------------------------------------------------------------
# Ruby version helper
# ------------------------------------------------------------------------------

# Display:
#
#   using ‹3.3.0›
#
ruby_prompt_info() {

    local version

    if command -v rbenv >/dev/null 2>&1; then
        version=$(rbenv version-name 2>/dev/null)
    fi

    if [[ -n "$version" ]]; then
        return
    fi

    print -P " %F{239}using%f%F{243} ‹${version}›%f"
}

# ------------------------------------------------------------------------------
# Clock helper
# ------------------------------------------------------------------------------

clock_info() {
    print "%*"
}

# ------------------------------------------------------------------------------
# vcs_info configuration
# ------------------------------------------------------------------------------

# Git only
zstyle ':vcs_info:*' enable git

# Detect staged / unstaged changes
zstyle ':vcs_info:git:*' check-for-changes true

# Normal state
#
# Examples:
#
#   [main]
#   [main ●]
#   [main ● ●]
#
zstyle ':vcs_info:git:*' formats "${FG_NEUTRAL}(%b)%f%c%u"

# Action state
#
# Examples:
#
#   [main|rebase]
#   [main|merge]
#
zstyle ':vcs_info:git:*' actionformats "${FG_NEUTRAL}(%b-%a)%f%c%u"

# Symbols used when files are staged / modified
zstyle ':vcs_info:git:*' stagedstr ' %F{yellow} %f'
zstyle ':vcs_info:git:*' unstagedstr '%F{red} %f'

git_clean() {

    if [ $(git status --short 2>&1 | wc -l) -eq 0 ]; then
        print '%F{green}  %f'
    fi
}

# ------------------------------------------------------------------------------
# Prompt symbol
# ------------------------------------------------------------------------------

# Git repository:
#
#   󰊤
#
# Normal directory:
#
#   
#
# Failure:
#
#   
#
prompt_char() {

    if [[ -n "$vcs_info_msg_0_" ]]; then
        print '%(?.%F{247}󰊤 %f.%F{red}󰊤 %f)'
    else
        print '%(?.%F{247}󰐌 %f.%F{red} %f)'
    fi
}
# ------------------------------------------------------------------------------
# Build first line
# ------------------------------------------------------------------------------

prompt_header() {

    local left=""

    left+="${FG_NEUTRAL}╭─%f"

    # username
    left+="%B%F{green}%n%f%b"

    # @
    left+="${FG_NEUTRAL}@%f"

    # hostname
    left+="%B%F{magenta}$(box_name)%f%b"

    # :
    left+="${FG_NEUTRAL}:%f"

    # current directory
    left+="%B%F{blue}%~%f%b"

    # git
    left+="%B${vcs_info_msg_0_}%b"
    left+="%B$(git_clean)%b"

    # ruby
    left+="$(ruby_prompt_info)"

    print -r "${left}"

}

# ------------------------------------------------------------------------------
# Prompt
# ------------------------------------------------------------------------------
add-zsh-hook precmd vcs_info
PROMPT='$(prompt_header)%f
${FG_NEUTRAL}╰─%f$(virtualenv_info)$(prompt_char) %f'

RPROMPT="${FG_NEUTRAL}$(clock_info)%f"
