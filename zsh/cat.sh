os=$(cat /etc/os-release | grep PRETTY_NAME | sed -r 's/PRETTY_NAME="(.+)"/\1/')
echo "           ╭───────────── ── ─"
echo "    ∧_∧    │ HostName: $(hostname)"
echo "   ﾐ｡･ω･ﾐ <  OS: ${os}"
echo " ~ﾐ_ u uﾐ  ╰──────────────────────── ── ─ ─"
