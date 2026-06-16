---------------------
---- KEYBINDINGS ----
---------------------
-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more

local programs = require("core.programs")

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- hyprlandを終了する
hl.bind(mainMod .. " + M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- == ウィンドウ操作系
-- ウィンドウを閉じる
hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- -- ウィンドウフロート切り替え
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
-- フルスクリーンに切り替え
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen_state({ internal = 2, client = 2, action = "toggle" }))
-- 疑似ウィンドウ切り替え
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- 分割の水平/垂直切り替え
hl.bind(mainMod .. " + d", hl.dsp.layout("togglesplit")) -- dwindle only
-- フォーカスするウィンドウを移動
-- hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))
-- ウィンドウ移動
hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.move({ direction = "down" }))
-- ウィンドウリサイズ
hl.bind("SUPER + CTRL + Right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + Left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + Up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + Down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })

-- Move/resize windows with mainMod + LMB/RMB and dragging
-- hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
-- hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- == アプリケーションを開く系
-- ターミナルを開く
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(programs.terminal))
-- ファイルマネージャを開く
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.fileManager))
-- ランチャーを開く
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(programs.menu .. " toggle"))
-- ブラウザを開く
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(programs.browser))

-- よく使うアプリケーションを開く
hl.bind(mainMod .. " + CTRL + Return", function()
    hl.exec_cmd(programs.terminal, { workspace = "2" })
    hl.exec_cmd(programs.browser .. " https://music.apple.com/jp/library/recently-added", { workspace = "1" })
end)

-- == ワークスペース系
-- 矢印キーでワークスペース切り替え
hl.bind(mainMod .. " + " .. "Left", hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + " .. "Right", hl.dsp.focus({ workspace = "+1" }))
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    -- アクティブウィンドウを指定のワークスペースに移動
    hl.bind(mainMod .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))


-- == 音楽系
--マルチメディアキーを使えるようにする
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })

-- 要playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- == 他
-- 明るさ調整キーを使えるようにする LCD brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- スクリーンショット起動
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" ~/ScreenShots/$(date +%Y%m%d_%H%M%S).png'))

-- waybarの設定を更新する
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("pkill waybar && waybar & disown"))

-- hyprlockを起動する
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("wlogout"))
