---------------------
---- MY PROGRAMS ----
---------------------

TERMINAL = "kitty"
FILE_MANAGER = "nautilus"
MENU = "rofi -show drun -theme " .. HOME .. "/.config/rofi/config-theme.rasi"
BROWSER = "google-chrome-stable"

-- Web App Shortcuts
SPOTIFY = BROWSER .. " --app=https://open.spotify.com"
YOUTUBE = BROWSER .. " --app=https://www.youtube.com"
YOUTUBE_MUSIC = BROWSER .. " --app=https://music.youtube.com"

-- Custom Picker Scripts
WALLPAPER_PICKER = CONFIG_DIR .. "/scripts/wallpaper-picker.sh"
THEME_PICKER = CONFIG_DIR .. "/scripts/switch-theme.sh"
POWER_MENU = CONFIG_DIR .. "/power.sh"

-- Screenshot Utilities
local snap_dir = HOME .. "/Pictures/Screenshots"
SCREENSHOT_AREA = "mkdir -p " .. snap_dir .. " && FILE=" .. snap_dir .. "/$(date +'%Y-%m-%d_%H-%M-%S').png && grim -g \"$(slurp)\" \"$FILE\" && wl-copy < \"$FILE\" && notify-send 'Screenshot' 'Area saved & copied to clipboard' -i image-x-generic"
SCREENSHOT_FULL = "mkdir -p " .. snap_dir .. " && FILE=" .. snap_dir .. "/$(date +'%Y-%m-%d_%H-%M-%S').png && grim \"$FILE\" && wl-copy < \"$FILE\" && notify-send 'Screenshot' 'Full screen saved & copied to clipboard' -i image-x-generic"
CLIPBOARD_MANAGER = "cliphist list | rofi -dmenu | cliphist decode | wl-copy"
