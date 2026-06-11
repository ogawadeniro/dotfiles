os=$(cat /etc/os-release | grep PRETTY_NAME | sed -r 's/PRETTY_NAME="(.+)"/\1/')
echo "             ╭───────────── ── ─"
echo "     ∧──∧  .*│ HostName: $(cat /etc/hostname)"
echo "    ﾐ ･-･ﾐ   │ OS: ${os}"
echo " 〜ﾐ__O oﾐ   ╰──────────────────────── ── ─ ─"
