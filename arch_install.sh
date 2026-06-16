# == シンボリックリンクを作成
# シンボリックリンク作成用ヘルパー
create_link() {
    target=$1
    link=$2
    # シンボリックリンクがない場合、作成する
    if [ ! -L "$link" ]; then
        # リンク先にすでに設定ディレクトリがある場合、バックアップを作成する
        if [ -e "${link}" ]; then
            link_bk="${link}_bk"
            # バックアップもすでに存在する場合は、コンフィグディレクトリかバックアップを削除するよう促す
            if [ -e "$link_bk" ]; then
                echo "バックアップを作成しようとしましたが、すでにバックアップがあるようです。"
                echo "手動でバックアップを作成するか、${link}もしくは${link_bk}を削除してください。"
                return
            fi
            mv "${link}" "${link_bk}"
            if [ $? -eq 0 ]; then
                echo "バックアップ ${link_bk} を作成しました"
            else
                echo "バックアップ ${link_bk} の作成に失敗しました。中断します。"
                exit 1
            fi
        fi
        ln -s "$target" "$link"
        if [ $? -eq 0 ]; then
            echo "$target のシンボリックリンクを $link に作成しました"
        else
            echo "$target のシンボリックリンクを作成できませんでした。"
            exit 1
        fi
    fi
}

create_link "$HOME/.dotfiles/ghostty" "$HOME/.config/ghostty"
create_link "$HOME/.dotfiles/nvim" "$HOME/.config/nvim"
create_link "$HOME/.dotfiles/tmux" "$HOME/.config/tmux"
create_link "$HOME/.dotfiles/zsh" "$HOME/.config/zsh"
# create_link "$HOME/.dotfiles/opencode" "$HOME/.config/opencode"
create_link "$HOME/.dotfiles/fontconfig" "$HOME/.config/fontconfig"
create_link "$HOME/.dotfiles/waybar" "$HOME/.config/waybar"
create_link "$HOME/.dotfiles/kitty" "$HOME/.config/kitty"
create_link "$HOME/.dotfiles/hypr" "$HOME/.config/hypr"
create_link "$HOME/.dotfiles/fastfeth" "$HOME/.config/fastfetch"
