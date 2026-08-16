-- Keybinds and mouse binds.

local mainMod = "ALT"
local terminal = "alacritty"
local menu = "rofi -show run"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + Space", hl.dsp.window.pin({ action = "toggle" }))

hl.bind(mainMod .. " + l",         hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + semicolon", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k",         hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j",         hl.dsp.focus({ direction = "down" }))

local workspaceKeys = {
    { "1", 1 },
    { "2", 2 },
    { "3", 3 },
    { "4", 4 },
    { "5", 5 },
    { "6", 6 },
    { "7", 7 },
    { "8", 8 },
    { "9", 9 },
    { "0", 10 },
    { "minus", 11 },
    { "equal", 12 },
}

for _, binding in ipairs(workspaceKeys) do
    local key = binding[1]
    local workspace = binding[2]

    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = workspace }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(mainMod .. " + SHIFT + F1", hl.dsp.exec_cmd("~/.config/hypr/screen-on.sh"))
hl.bind(mainMod .. " + SHIFT + F2", hl.dsp.exec_cmd("~/.config/hypr/screen-off.sh"))

hl.bind(mainMod .. " + SHIFT + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + SHIFT + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + R", hl.dsp.exec_cmd([[bash -lc 'pkill -SIGUSR1 waybar || waybar']]))

hl.bind("Print", hl.dsp.exec_cmd([[bash -lc 'grim -g "$(slurp)" - | tee "$HOME/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png" | wl-copy']]))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[bash -lc 'grim - | tee "$HOME/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png" | wl-copy']]))

hl.bind(
    "SUPER + D",
    hl.dsp.exec_cmd("/home/paul/lib/hyprwhspr/config/hyprland/hyprwhspr-tray.sh record"),
    { description = "Speech-to-text" }
)
