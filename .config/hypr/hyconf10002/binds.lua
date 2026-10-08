-- See https://wiki.hypr.land/Configuring/Basics/Binds/

require("hyconf10002.commands")

-- double tap mainMod to open the Menu (implemented using submaps)
function BindDoubleTap(name, key, action, flags, timeoutSeconds, baseSubMap)
    if timeoutSeconds == nil then timeoutSeconds = 0.3 end
    if baseSubMap == nil then baseSubMap = "reset" end
    local mainModDoubleTapSubmapName = name .. "DoubleTap"
    hl.bind(key, function() 
        hl.dispatch(hl.dsp.submap(mainModDoubleTapSubmapName))
        hl.dispatch(hl.dsp.exec_cmd("{ sleep " .. timeoutSeconds .. " ; hyprctl dispatch 'hl.dsp.submap(\"" .. baseSubMap .. "\")' ; } &"))
    end, flags)
    hl.define_submap(mainModDoubleTapSubmapName, function ()
        hl.bind(key, function() 
            hl.dispatch(action)
            hl.dispatch(hl.dsp.submap(baseSubMap))
        end, flags)
    end)
end

local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(Terminal))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(LogOff))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(FileManager))
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(TaskManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(LockSession))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(SwitchKeyboardLayout))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(ToggleWaybar))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(ReloadWaybar))

-- double tap mainMod to open the Menu (implemented using submaps)
hl.bind(mainMod .. " + " .. mainMod .. "_L", hl.dsp.exec_cmd(Menu), { release = true })

-- Screenshot or screenrecord with Print Screen key
hl.bind("Print",  function() hl.plugin.hyprcapture.open() end)

-- if focus can't go more left for example, stay at the window, do not go right or something
hl.config({ general = { no_focus_fallback = true } })

-- Move focus with mainMod + arrow keys
for _, dir in ipairs{ "up", "down" } do
    hl.bind(mainMod .. " + " .. dir, hl.dsp.focus({ direction = dir }), { repeating = true })
end

-- If most right or most left window, switch workspaces
for dir, delta in pairs{ left = "-1" , right = "+1" } do
    hl.bind(mainMod .. " + " .. dir, function ()
        local reverseDir = dir == "left" and "right" or "left"
        local prevWindow = hl.get_active_window()
        -- try to move focus
        hl.dispatch(hl.dsp.focus({ direction = dir }))
        
        if hl.get_active_window() == prevWindow then
            -- moving focus did nothing, we need to go to the next workspace
            hl.dispatch(hl.dsp.focus({ workspace = delta }))

            -- move focus in the new workspace in both directions to make the mouse follow subsequent focus moves
            hl.dispatch(hl.dsp.focus({ direction = dir }))
            hl.dispatch(hl.dsp.focus({ direction = reverseDir }))

            -- move the focus in the reverse direction until can't, to be on a logically sound window
            repeat 
                prevWindow = hl.get_active_window()
                hl.dispatch(hl.dsp.focus({ direction = reverseDir }))
            until prevWindow == hl.get_active_window()
        end
    end, { repeating = true })
end

-- Move windows with mainMod + SHIFT + arrow keys
for _, dir in ipairs{ "up", "down" } do
    hl.bind(mainMod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }), { repeating = true })
end

-- If most right or most left window, move to other workspace
for dir, delta in pairs{ left = "-1" , right = "+1" } do
    hl.bind(mainMod .. " + SHIFT + " .. dir, function ()
        local reverseDir = dir == "left" and "right" or "left"
        local prevWindow = hl.get_active_window()
        -- try to move focus
        hl.dispatch(hl.dsp.focus({ direction = dir }))

        -- if focus on a new window, then there is a space ot move the window, back the focus back and move the window
        if hl.get_active_window() ~= prevWindow then
            hl.dispatch(hl.dsp.focus({ direction = reverseDir }))
            hl.dispatch(hl.dsp.window.move({ direction = dir }))
        else
            -- if focus stayed on the same window, move the window to the next workspace in the direction 
            hl.dispatch(hl.dsp.window.move({ workspace = delta }))

            -- -- move focus in the new workspace in both directions to make the mouse follow subsequent focus moves
            -- hl.dispatch(hl.dsp.focus({ direction = dir }))
            -- hl.dispatch(hl.dsp.focus({ direction = reverseDir }))

            -- move the windows in the reverse direction until can't, to be on a logically sound position
            repeat 
                prevWindow = hl.get_active_window()
                hl.dispatch(hl.dsp.focus({ direction = reverseDir }))
                if hl.get_active_window() == prevWindow then break end
                hl.dispatch(hl.dsp.focus({ direction = dir }))
                hl.dispatch(hl.dsp.window.move({ direction = reverseDir }))
            until false
        end
    end, { repeating = true })
end


-- Maximize/unmaximize on mainMod + ALT + up/down
-- Fullscreen/unfullscreen on mainMod + ALT + SHIFT + up/down

for action, key in pairs{ toggle = "up", unset = "down" } do
for mode, mod in pairs{ maximized = "", fullscreen = " + SHIFT" } do
    hl.bind(mainMod .. mod .. " + ALT + " .. key, hl.dsp.window.fullscreen({ mode = mode, action = action}))
end
end

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(SetVolume("@DEFAULT_AUDIO_SINK@", "5%+", 1)), { locked = true, repeating = true })
hl.bind(mainMod .. " + XF86AudioRaiseVolume", hl.dsp.exec_cmd(SetVolume("@DEFAULT_AUDIO_SINK@", "5%+")), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(SetVolume("@DEFAULT_AUDIO_SINK@", "5%-")),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(Mute("@DEFAULT_AUDIO_SINK@", "toggle")),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(Mute("@DEFAULT_AUDIO_SOURCE@", "toggle")),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd(SetBrightness("5%+")),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd(SetBrightness("5%-")),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


function table_to_string(tbl, indent)
    if type(tbl) ~= "table" then return tostring(tbl) end
    indent = indent or 0
    local formatting = string.rep("  ", indent)
    local result = "{\n"
    
    for k, v in pairs(tbl) do
        local key = type(k) == "string" and '["' .. k .. '"]' or "[" .. tostring(k) .. "]"
        if type(v) == "table" then
            result = result .. formatting .. "  " .. key .. " = " .. table_to_string(v, indent + 1) .. ",\n"
        elseif type(v) == "string" then
            result = result .. formatting .. "  " .. key .. ' = "' .. v .. '",\n'
        else
            result = result .. formatting .. "  " .. key .. " = " .. tostring(v) .. ",\n"
        end
    end
    
    return result .. formatting .. "}"
end

hl.bind(mainMod .. " + G", function () hl.notification.create({ text = table_to_string(hl.get_layers()[2].namespace), timeout = 4000 }) end)