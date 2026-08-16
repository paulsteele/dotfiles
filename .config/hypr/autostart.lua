-- Startup commands.

local function start(cmd)
    hl.exec_cmd(cmd)
end

hl.on("hyprland.start", function()
    start("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    start([[bash -lc 'sleep 1 && waybar']])
    start("hypridle")
    start("/home/paul/lib/wayland-pipewire-idle-inhibit/target/release/wayland-pipewire-idle-inhibit")
    start("nm-applet")
    start("/home/paul/projects/birb-background/target/release/birb-background projects/birb-background/background.html")
    start("nvidia-smi")
end)
