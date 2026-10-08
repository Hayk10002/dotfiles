-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

require("hyconf10002.commands")

-- reload hyprpm plugins at startup
-- other things are handled by systemd (via systemctl)
hl.on("hyprland.start", function ()

    hl.exec_cmd("hyprpm reload || { hyprpm update; hyprpm reload; }")

end)