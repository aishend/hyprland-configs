-- =============================================================================
-- decorations.lua — Borders, rounded corners, shadow, blur
-- =============================================================================
-- Colors use Catppuccin Mocha: https://catppuccin.com/palette
--   active_border   → Mauve  #cba6f7 at ee opacity
--   inactive_border → Surface 1 #45475a at aa opacity
--   shadow.color    → Base #1e1e2e at cc opacity
--
-- Note: in Hyprland Lua, `col.active_border` from hyprlang maps to a nested
-- table  col = { active_border = "rgba(...)" }  — NOT ["col.active_border"].
-- Color format for single colors: "rgba(rrggbbaa)" (lowercase hex, no spaces).
-- Gradients are not yet supported in the Lua binding.
-- =============================================================================

hl.config({
    general = {
        border_size = 2,
        gaps_in  = 0,
        gaps_out = 0,
        col = {
            active_border   = "rgba(cba6f7ee)",
            inactive_border = "rgba(45475aaa)",
        },
    },
    decoration = {
        rounding = 10,
        shadow = {
            enabled      = true,
            range        = 10,
            render_power = 2,
            color        = "rgba(1e1e2ecc)",
        },
        blur = {
            enabled = true,
            size    = 6,
            passes  = 2,
        },
    },
})
