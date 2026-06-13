is_playing=$(playerctl metadata --format '{{status}}' 2>/dev/null)

if [ "$is_playing" == "Playing" ] ; then
    echo " "
elif [ "$is_playing" == "Paused" ] ; then
    echo " "
else
    echo "󰽺"
fi
