# zshセットアップ
1. zshインストール
2. /etc/zsh/zshenvを編集してコンフィグパスを変更
3. /.config/zshにzshの設定ファイルを配置
4. zsh起動

```bash /etc/zsh/zshenv
# 手順2で編集する内容
# パス設定
if [[ -z "$PATH" || "$PATH" == "/bin:/usr/bin" ]]
then
	export PATH="/usr/local/bin:/usr/bin:/bin:/usr/games"
fi

# zsh設定のルート設定
if [[ -z "$XDG_CONFIG_HOME" ]]
then
    export XDG_CONFIG_HOME="$HOME/.config/"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]
then
    export ZDOTDIR="$XDG_CONFIG_HOME/zsh/"
fi
```
