-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- Ref https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- When a window is maximazed on a workspace, disable gaps, rounding and borders
hl.workspace_rule({
    workspace = "f[1]",
    gaps_in = 0,
    gaps_out = 0,
    no_border = true,
    no_rounding = true,
})

-- Ignore maximize requests from all apps. You'll probably like this.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})


-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Disable hyprbars when the window is not focused
hl.window_rule({
    name = "no-hyprbar-when-no-focus",
    match = {
        focus = false
    },
    ["hyprbars:no_bar"] = true
})

hl.layer_rule({
    name = "dim-when-hyprlauncher",
    match = {
        namespace = "hyprlauncher"
    },

    dim_around = true
})
