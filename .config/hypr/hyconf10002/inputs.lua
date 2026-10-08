-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
    input = {
        kb_layout = "us, am, ru",
        kb_variant = ", phonetic-alt, phonetic_winkeys",
        kb_model = "",
        kb_rules = "",

        follow_mouse = 1, -- mouse cursor will focus windows, and keyboard focus will follow it

        accel_profile = "flat",
        sensitivity = 1, -- value from -1 to 1, 0 means no modification.

        touchpad = {
            natural_scroll = true
        }
    }
})

hl.config({
    cursor = {
        no_hardware_cursors = true
    }
})

-- maximize when swiping up with 3 fingers
hl.gesture({
    fingers = 3,
    direction = "vertical",
    action = "fullscreen",
    mode = "maximize",
})

-- fullscreen when swiping up with 3 fingers with shift holded
hl.gesture({
    fingers = 3,
    direction = "vertical",
    action = "fullscreen",
    mods = "SHIFT",
})

-- swipe workspaces with 4 fingers
hl.gesture({
    fingers = 4,
    direction = "horizontal",
    action = "workspace"
})