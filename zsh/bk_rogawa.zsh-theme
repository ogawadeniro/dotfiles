# See: https://github.com/ohmyzsh/ohmyzsh/wiki/Customization#overriding-and-adding-themes

fg_na=$FG[247]

function virtualenv_info {
    [ $CONDA_DEFAULT_ENV ] && echo "($CONDA_DEFAULT_ENV) "
    [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
}

function prompt_char {
    #git branch >/dev/null 2>/dev/null && echo '󰊤 ' && return
    git branch >/dev/null 2>/dev/null && echo "%(?.%{$fg[green]%}󰊤 %f.%{$fg[red]%}󰊤 %f)" && return
    #echo '󰐌 '
    # echo ' '
    #echo "%(?.%F{green} %f.%F{red} %f)"
    echo "%(?.%{$FG[247]%} %f.%F{red} %f)"
}

function box_name {
  local box="${SHORT_HOST:-$HOST}"
  [[ -f ~/.box-name ]] && box="$(< ~/.box-name)"
  echo "${box:gs/%/%%}"
}

function get_space {
  local STR=$1$2
  local zero='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~zero/}}
  local SPACES=$(( COLUMNS - LENGTH - ${ZLE_RPROMPT_INDENT:-1} ))

  (( SPACES > 0 )) || return
  printf ' %.0s' {1..$SPACES}
}

# gitプロンプト設定󰊤 
ZSH_THEME_GIT_PROMPT_PREFIX="["
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%} %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%} %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{%B$fg[green]%}]%{$reset_color%}"

ZSH_THEME_RUBY_PROMPT_PREFIX=" %{$FG[239]%}using%{$FG[243]%} ‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%{$reset_color%}"

# プロンプト組み立て
PROMPT="%{%B$fg_na%}╭─%{$reset_color%}"
# ユーザ名
PROMPT=${PROMPT}"%{%B$fg[green]%}%n%{$reset_color%}"
PROMPT=${PROMPT}"%{$fg_na%}@%{$reset_color%}"
# ホスト名
PROMPT=${PROMPT}"%{%B$fg[magenta]%}$(box_name)%{$reset_color%}"
PROMPT=${PROMPT}"%{$fg_na%}:%{$reset_color%}"
# ファイルパス
PROMPT=${PROMPT}"%{%B$fg[blue]%}%~%{$reset_color%}"
# git情報など  
PROMPT=${PROMPT}"%{%B$fg[green]%}\$(git_prompt_info)"
PROMPT=${PROMPT}"%{%B%}\$(ruby_prompt_info)"
#PROMPT=${PROMPT}"
#%{%B$fg_na%}╰─\$(virtualenv_info)%(?.%F{green} %f.%F{red} %f) %{$reset_color%}"
PROMPT=${PROMPT}"
%{%B$fg_na%}\$(virtualenv_info)%(?.%F{green} %f.%F{red} %f) %{$reset_color%}"

# 右✔
RPS1=${RPS1}%{$fg_na%}%*%{$reset_color%}

setopt prompt_subst

# autoload -U add-zsh-hook
# bg-black
# bg-blue
# bg-cyan
# bg-default
# bg-green
# bg-magenta
# bg-red
# bg-white
# bg-yellow
# black
# blink
# blue
# conceal
# cyan
# default
# faint
# green
# italic
# magenta
# no-blink
# no-conceal
# no-reverse
# no-underline
# normal
# red
# reverse
# underline
# white
# yellow
