-------------------
---- AUTOSTART ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("fcitx5 -d")
    hl.exec_cmd("vicinae server")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprlock --immediate-render")
end)
