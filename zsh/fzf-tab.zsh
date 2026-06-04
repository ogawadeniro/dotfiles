# ------------------------------------------------------------------------------
# == fzf-tab設定
_zplugin_load aloxaf fzf-tab
# ------------------------------------------------------------------------------
# `git checkout` の補完でソートを無効化
zstyle ':completion:*:git-checkout:*' sort false
# グループ表示を有効化するため descriptions のフォーマットを設定
# NOTE: エスケープシーケンス ('%F{red}%d%f' など) を使うと fzf-tab が無視するので使わない
zstyle ':completion:*:descriptions' format '[%d]'
# list-colors を設定してファイル名に色をつける
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# zsh の補完メニューを無効化し、fzf-tab が unambiguous prefix を取得できるようにする
zstyle ':completion:*' menu no
# cd 補完時に eza でディレクトリ内容をプレビュー
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# カスタム fzf フラグ
# NOTE: fzf-tab はデフォルトでは FZF_DEFAULT_OPTS を参照しない
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept --preview-window=right:80%
# fzf-tab に FZF_DEFAULT_OPTS を反映させる
# NOTE: 一部のフラグはこのプラグインを壊す可能性がある。Aloxaf/fzf-tab#455 参照
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# `<` `>` でグループ切り替え
zstyle ':fzf-tab:*' switch-group '<' '>'
# tmuxのポップアップ機能で補完メニューが開く?
# zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
# ファイルのプレビューを表示
zstyle ':fzf-tab:complete:*:*' fzf-preview "if [[ -d \$realpath ]]; then eza -la --color=always \$realpath; else ${CMD_BAT} --style=numbers --color=always \$realpath; fi"
# コマンドのヘルプを表示
zstyle ':fzf-tab:complete:*:options' fzf-preview 'tldr ${(M)words[1]:-$word} 2>/dev/null || man ${(M)words[1]:-$word} 2>/dev/null || echo "No help available"'
zstyle ':fzf-tab:complete:*:arguments' fzf-preview 'tldr ${(M)words[1]:-$word} 2>/dev/null || man ${(M)words[1]:-$word} 2>/dev/null || echo "No help available"'

zstyle ':completion::complete:cd:*' fzf-preview "${CMD_FD} --hidden --max-depth 1 --color=always \$word"
