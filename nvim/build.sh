# packchangeイベント発火時にビルドしたいのにされない時用(ワークアラウンド)
echo "どのプラグインをビルドする？"
echo "1: peek"
echo "2: telescope-fzf-native"
# echo "3: プラグイン名"
read -p "番号で選択: " selected_num

case ${selected_num} in
    "1")
        # peek
        echo "peekをビルドするよ"
        (cd ~/.local/share/nvim/site/pack/core/opt/peek.nvim && deno task --quiet build:fast);;
    "2")
        # telescope-fzf-native
        echo "telescope-fzf-nativeをビルドするよ"
        (cd ~/.local/share/nvim/site/pack/core/opt/telescope-fzf-native && make);;
    # "3")
    # # プラグイン名
    # ビルドコマンド;;
    *)
        echo "終了するよ";;
esac
