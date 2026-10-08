Terminal = "kitty"
Shell = "bash"
Menu = "hyprlauncher --toggle"

OpenInTerminal = Terminal .. " " .. Shell .. " -ic "
FileManager = OpenInTerminal .. "yazi"

TaskManager = OpenInTerminal .. "htop"

LockSession = "loginctl lock-session"
LogOff = "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"
ToggleWaybar = "killall -SIGUSR1 waybar"
ReloadWaybar = "systemctl --user reload waybar || systemctl --user enable waybar --now"

SwitchKeyboardLayout = "hyprctl switchxkblayout current next && notify-send -t 500 \"$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')\""

function SetVolume(what, volume, limit)
    if limit ~= nil 
    then limit = "-l " .. limit .. " "
    else limit = ""
    end

    return "wpctl set-volume " .. limit .. what .. " " .. volume
end

function Mute(what, mode)
    return "wpctl set-mute " .. what .. " " .. mode
end

function SetBrightness(brightness)
    return "brightnessctl -e4 -n2 set " .. brightness
end

