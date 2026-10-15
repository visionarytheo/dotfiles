#!/usr/bin/env bash

ROFI_CONF="$HOME/.config/rofi/config-power.rasi"
CURRENT_THEME="$HOME/.config/hypr/current_theme"
ICON_DIR="/tmp/rofi_power_icons"
mkdir -p "$ICON_DIR"

# Dynamically extract the active color from colors.lua or fallback based on theme path
THEME_COLOR=""

if [ -f "$CURRENT_THEME/colors.lua" ]; then
    # Extract the 6-character hex code from rgba(...) inside colors.lua
    THEME_COLOR=$(grep -oE '#[a-fA-F0-9]{6}' "$CURRENT_THEME/colors.lua" | head -n 1)
    if [ -z "$THEME_COLOR" ]; then
        # Fallback to extracting lowercase/uppercase hex or rgba strings if format differs
        RAW_HEX=$(grep -oE '([a-fA-F0-9]{6})' "$CURRENT_THEME/colors.lua" | head -n 1)
        [ -n "$RAW_HEX" ] && THEME_COLOR="#$RAW_HEX"
    fi
fi

# Fallback check based on active theme folder name if colors.lua didn't yield a hex
if [ -z "$THEME_COLOR" ]; then
    ACTIVE_DIR=$(readlink -f "$CURRENT_THEME")
    if [[ "$ACTIVE_DIR" == *"Catppuccin"* ]] || [[ "$ACTIVE_DIR" == *"cappuccino"* ]]; then
        THEME_COLOR="#cba6f7" # Mauve
    elif [[ "$ACTIVE_DIR" == *"Gruvbox"* ]]; then
        THEME_COLOR="#d79921" # Amber
    else
        THEME_COLOR="#d19a66" # Default fallback
    fi
fi

# Generate flat SVG icons rendered in the active theme color
cat << EOF > "$ICON_DIR/logout.svg"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="$THEME_COLOR"><path d="M16 17v-3H9v-4h7V7l5 5-5 5M14 2a2 2 0 0 1 2 2v2h-2V4H5v16h9v-2h2v2a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9z"/></svg>
EOF

cat << EOF > "$ICON_DIR/reboot.svg"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="$THEME_COLOR"><path d="M12 4V1L8 5l4 4V6a6 6 0 1 1-6 6H4a8 8 0 1 0 8-8z"/></svg>
EOF

cat << EOF > "$ICON_DIR/shutdown.svg"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="$THEME_COLOR"><path d="M16.56 5.44l-1.45 1.45A5.969 5.969 0 0 1 18 12a6 6 0 1 1-8.5-5.42L8.06 5.13a8 8 0 1 0 11.33 0zM11 2h2v10h-2z"/></svg>
EOF

# Dynamic 3-column layout sizing
DYNAMIC_WIDTH=665
DYNAMIC_COLS=3
ROFI_DYNAMIC_STR="window { width: ${DYNAMIC_WIDTH}px; } listview { columns: ${DYNAMIC_COLS}; } element-icon { size: 64px; }"

generate_power_entries() {
    printf 'Logout\0icon\x1f%s/logout.svg\n' "$ICON_DIR"
    printf 'Reboot\0icon\x1f%s/reboot.svg\n' "$ICON_DIR"
    printf 'Shutdown\0icon\x1f%s/shutdown.svg\n' "$ICON_DIR"
}

# Prompt selection via rofi
if [ -f "$ROFI_CONF" ]; then
    SELECTED=$(generate_power_entries | rofi -dmenu -i -selected-row 0 -p "󰐥 Power Menu" -show-icons -theme "$ROFI_CONF" -theme-str "$ROFI_DYNAMIC_STR")
else
    SELECTED=$(generate_power_entries | rofi -dmenu -i -selected-row 0 -p "󰐥 Power Menu" -show-icons -theme-str "$ROFI_DYNAMIC_STR")
fi

# Execute action based on selection
case "$SELECTED" in
    "Logout")
        uwsm stop
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
esac