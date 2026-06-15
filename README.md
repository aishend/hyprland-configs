# hyprland-configs

Personal Hyprland dotfiles written in **Lua** (requires Hyprland v0.55+). Tested on an Acer Predator Neo 16 with Nvidia (dGPU only) and a dual-monitor setup.

---

## Stack

| Role | Tool |
|------|------|
| Window manager | [Hyprland](https://hyprland.org) v0.55+ |
| Status bar | [Waybar](https://github.com/Alexays/Waybar) |
| Terminal | [Kitty](https://sw.kovidgoyal.net/kitty/) |
| File manager | Nautilus |
| App launcher | Rofi (Wayland build) |
| Screenshots | Grim + Slurp |
| Wallpaper | Hyprpaper |
| Idle / lock screen | Hypridle + Hyprlock |
| Notifications | Swaync |
| Polkit agent | Hyprpolkitagent |
| Audio | Pipewire + WirePlumber + Pavucontrol |
| Bluetooth | Blueman |
| System monitor | Btop |
| Font | JetBrainsMono Nerd Font |
| Editor | VS Code (Ayu Dark Bordered) |

---

## Fresh install

> Arch Linux (or Arch-based). Run as your normal user, not root.

```bash
sudo pacman -S --needed hyprland uwsm waybar kitty nautilus rofi grim slurp hyprpaper hypridle hyprlock swaync hyprpolkitagent xdg-desktop-portal-hyprland xdg-desktop-portal-gtk pipewire-alsa pipewire-pulse wireplumber power-profiles-daemon blueman wl-clipboard jq playerctl brightnessctl networkmanager qt5ct ttf-jetbrains-mono-nerd && git clone https://github.com/aishend/hyprland-configs.git /tmp/hyprland-configs && cp -r /tmp/hyprland-configs/* ~/.config/ && chmod +x ~/.config/hypr/scripts/*.sh ~/.config/waybar/scripts/*.sh && systemctl --user enable --now hyprpolkitagent hypridle hyprpaper waybar swaync
```

Then log out and select **Hyprland** from your display manager.

---

## Step by step

### 1 — Install packages

**Required** — the config will not work without these:

```bash
sudo pacman -S --needed hyprland uwsm waybar kitty nautilus rofi grim slurp \
    hyprpaper hypridle hyprlock swaync hyprpolkitagent \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    pipewire-alsa pipewire-pulse wireplumber \
    power-profiles-daemon wl-clipboard jq playerctl brightnessctl \
    networkmanager qt5ct ttf-jetbrains-mono-nerd
```

**Optional** — useful extras, install what you need:

```bash
sudo pacman -S --needed blueman pavucontrol btop fastfetch
```

### 2 — Deploy config

```bash
git clone https://github.com/aishend/hyprland-configs.git
cp -r hyprland-configs/* ~/.config/
chmod +x ~/.config/hypr/scripts/*.sh ~/.config/waybar/scripts/*.sh
```

### 3 — Enable systemd services

All daemons run under systemd with `Restart=on-failure`. Enable them once:

```bash
systemctl --user enable --now hyprpolkitagent hypridle hyprpaper waybar swaync
```

### 4 — Set your wallpaper

Place your wallpaper at `~/.config/hypr/wallpapers/gradient.jpg`, or edit the path in two places:

- `hypr/hyprpaper.conf` — preload and initial assignment
- `hypr/conf/autostart.lua` — the `hyprctl hyprpaper wallpaper` line

> **Wallpaper not appearing?** The `sleep 1` in `autostart.lua` waits for the compositor socket before setting the wallpaper. On slower machines it may need more time — increase it to `sleep 2` or `sleep 3`.

### 5 — VS Code theme

Install the Ayu extension:

```bash
code --install-extension teabyii.ayu
```

The theme (`Ayu Dark Bordered`) is applied automatically via `Code/User/settings.json`.

### 6 — Log in

Log out and select **Hyprland** from your display manager.

---

## Hardware adaptation

### Monitors

Find your output names with `hyprctl monitors` or `wlr-randr`, then edit `hypr/conf/monitors.lua`:

```lua
hl.monitor({ output = "DP-1",  mode = "1920x1080@100", position = "0x0",    scale = 1    })
hl.monitor({ output = "DP-2",  mode = "1920x1080@100", position = "0x0",    scale = 1    })
hl.monitor({ output = "eDP-1", mode = "2560x1600@165", position = "0x1080", scale = 1.25 })
```

For a single monitor keep one line. Remove or adjust `position` so monitors don't overlap.

### Workspaces

By default, workspaces 1–5 go to `eDP-1` and 6–10 go to `DP-1`. Edit `hypr/conf/workspaces.lua`:

```lua
for i = 1, 5  do hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1" }) end
for i = 6, 10 do hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1"  }) end
```

For a single monitor, remove both loops and use a single one for 1–10.

### Keyboard layout

```lua
-- hypr/conf/input.lua
hl.config({
    input = { kb_layout = "pt" },  -- change to your layout, e.g. "us", "br"
})
```

### Nvidia GPU

If you are on AMD or Intel only, remove the Nvidia env vars from `hypr/hyprland.lua`:

```lua
hl.env("LIBVA_DRIVER_NAME",         "nvidia")
hl.env("GBM_BACKEND",               "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND",               "direct")
```

And remove this block from `hl.config()` in `hypr/conf/input.lua`:

```lua
cursor = { no_hardware_cursors = true },
```

---

## File structure

```
~/.config/
├── hypr/
│   ├── hyprland.lua              # Entry point: env vars, loads conf/*.lua
│   ├── conf/
│   │   ├── monitors.lua          # Monitor layout — edit for your hardware
│   │   ├── autostart.lua         # D-Bus env, dark mode, wallpaper, Firefox
│   │   ├── input.lua             # Input, cursor, touchpad, XWayland
│   │   ├── animations.lua        # Animations and bezier curves
│   │   ├── decorations.lua       # Borders, rounded corners, shadow, blur
│   │   ├── keybindings.lua       # All keybindings
│   │   └── workspaces.lua        # Workspace rules + workspace keybindings
│   ├── hyprpaper.conf            # Wallpaper preload and assignment
│   ├── hypridle.conf             # Idle timeouts and lock triggers
│   ├── hyprlock.conf             # Lock screen appearance
│   ├── wallpapers/               # Wallpaper files
│   └── scripts/
│       ├── smart-focus.sh        # Focus movement with workspace switching at edge
│       ├── smart-move.sh         # Window movement with workspace switching at edge
│       ├── screenshot-region.sh  # Region select → save + clipboard
│       ├── screenshot-monitor.sh # Full monitor → save
│       └── scratchpad-toggle.sh  # Send to / retrieve from scratchpad
├── xdg-desktop-portal/
│   └── hyprland-portals.conf     # Portal backend config (dark mode)
├── rofi/
│   └── themes/
│       └── default.rasi          # App launcher theme
├── waybar/
│   ├── config.jsonc              # Bar layout and modules
│   ├── style.css                 # Stylesheet
│   └── scripts/
│       ├── audio-menu.sh         # Audio output selector (rofi)
│       ├── bluetooth-menu.sh     # Bluetooth device menu (rofi)
│       └── wifi-menu.sh          # Wi-Fi network menu (rofi + nmcli)
└── README.md
```

---

## Keybindings

### Applications

| Shortcut | Action |
|----------|--------|
| `Super + A` | App launcher (Rofi) |
| `Super + T` | Terminal (Kitty) |
| `Super + E` | File manager (Nautilus) |
| `Super + B` | Browser (Firefox) |
| `Super + Q` | Close window |
| `Super + V` | Toggle floating |
| `Super + F` | Toggle fullscreen |

### Focus & window movement

Arrow keys and Vim keys (`h/j/k/l`) are equivalent. Left/right switch workspace at the screen edge.

| Shortcut | Action |
|----------|--------|
| `Super + ←/→` or `Super + H/L` | Move focus (switches workspace at edge) |
| `Super + ↑/↓` or `Super + K/J` | Move focus up / down |
| `Super + Shift + ←/→` or `Super + Shift + H/L` | Move window (sends to next workspace at edge) |
| `Super + Shift + ↑/↓` or `Super + Shift + K/J` | Move window up / down |

### Workspaces

| Shortcut | Action |
|----------|--------|
| `Super + 1–9, 0` | Switch to workspace 1–10 |
| `Super + Shift + 1–9, 0` | Move window to workspace 1–10 |

### Scratchpad

Floating overlay workspace (`special:global`) accessible from anywhere.

| Shortcut | Action |
|----------|--------|
| `Super + S` | Toggle scratchpad visibility |
| `Super + Alt + S` | Send window to scratchpad / pull it back out |

### Screenshots

Saved to `~/Pictures/Screenshots/`.

| Shortcut | Action |
|----------|--------|
| `Super + Shift + S` | Region select → save + copy to clipboard |
| `Print` | Full monitor → save |

### Mouse

| Shortcut | Action |
|----------|--------|
| `Super + Left drag` | Move window |
| `Super + Right drag` | Resize window |

### Media & hardware keys

| Key | Action |
|-----|--------|
| Volume Up / Down | ±5% volume |
| Mute | Toggle mute |
| Mic Mute | Toggle mic |
| Brightness Up / Down | ±5% brightness |
| Play / Pause / Next / Prev | Media control |

### Power & session

| Shortcut | Action |
|----------|--------|
| `Super + Ctrl + L` | Lock screen |
| `Super + Ctrl + S` | Suspend |
| `Super + Ctrl + R` | Reboot |
| `Super + Ctrl + P` | Power off |
