-- =============================================================================
-- hyprland.lua — Hyprland entry point (v0.55+ Lua syntax)
-- =============================================================================
-- Hardware: Nvidia + Intel hybrid graphics, dual monitor (DP-1 + eDP-1),
--           Wacom Intuos BT M tablet.
--
-- This file defines global variables and environment variables, then loads
-- the remaining configuration from hypr/conf/*.lua via dofile().
--
-- Files:
--   conf/monitors.lua     — monitor layout
--   conf/autostart.lua    — startup daemons
--   conf/input.lua        — input, cursor, XWayland
--   conf/animations.lua   — animations and bezier curves
--   conf/decorations.lua  — borders, rounded corners, shadow, blur
--   conf/keybindings.lua  — all keybindings
--   conf/workspaces.lua   — workspace-to-monitor rules
-- =============================================================================

-- ---------------------------------------------------------------------
-- 1. VARIABLES
-- Defined as globals (no `local`) so they are accessible in files
-- loaded via dofile().
-- ---------------------------------------------------------------------
mainMod     = "SUPER"
terminal    = "kitty"
fileManager = "nautilus"
menu        = "rofi -show drun -theme ~/.config/rofi/themes/default.rasi"
scriptDir   = "~/.config/hypr/scripts"

-- ---------------------------------------------------------------------
-- 2. ENVIRONMENT VARIABLES
-- hl.env(key, value) replaces `env = KEY,VALUE` from hyprlang.
-- Note: if using uwsm, prefer ~/.config/uwsm/env (general variables)
--       and ~/.config/uwsm/env-hyprland (Hyprland-specific variables)
--       instead of hl.env(), for better compositor portability.
-- ---------------------------------------------------------------------

-- XDG session
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Nvidia
hl.env("LIBVA_DRIVER_NAME",          "nvidia")
hl.env("GBM_BACKEND",                "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME",  "nvidia")
hl.env("NVD_BACKEND",                "direct")

-- Toolkit backends
hl.env("GDK_BACKEND",          "wayland,x11,*")
hl.env("QT_QPA_PLATFORM",      "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

-- App compatibility
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
hl.env("MOZ_ENABLE_WAYLAND",          "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT","auto")

-- Dark mode
hl.env("GTK_THEME",    "Adwaita-dark")
hl.env("COLOR_SCHEME", "prefer-dark")

-- HiDPI scaling — delegated to the compositor, not the toolkits
hl.env("GDK_SCALE",     "1")
hl.env("GDK_DPI_SCALE", "1")

-- Flatpak data dirs
-- os.getenv() expands environment variables at Lua parse time.
hl.env("XDG_DATA_DIRS",
    os.getenv("HOME") .. "/.local/share/flatpak/exports/share" ..
    ":/var/lib/flatpak/exports/share:/usr/local/share:/usr/share:" ..
    (os.getenv("XDG_DATA_DIRS") or ""))

-- ---------------------------------------------------------------------
-- 3. LOAD CONFIGURATION FILES
-- ---------------------------------------------------------------------
local conf = os.getenv("HOME") .. "/.config/hypr/conf/"

dofile(conf .. "monitors.lua")
dofile(conf .. "autostart.lua")
dofile(conf .. "input.lua")
dofile(conf .. "animations.lua")
dofile(conf .. "decorations.lua")
dofile(conf .. "keybindings.lua")
dofile(conf .. "workspaces.lua")
