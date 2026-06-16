# packchangeイベント発火時にビルドしたいのにされない時用(ワークアラウンド)
echo "どのプラグインをビルドする？"
echo "1: peek"
echo "2: telescope-fzf-native"
echo "3: blink.cmp"
echo "4: Luasnip"
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
    "3")
        # blink.cmp
        (cd ~/.local/share/nvim/site/pack/core/opt/blink.cmp && cargo build --release);;
    "4")
        # LuaSnip
        (cd ~/.local/share/nvim/site/pack/core/opt/LuaSnip && make install_jsregexp);;
    *)
        echo "終了するよ";;
esac
