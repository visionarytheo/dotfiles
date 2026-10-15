#!/usr/bin/env bash

CURRENT_THEME="$HOME/.config/hypr/current_theme"
WALL_DIR="$CURRENT_THEME/wallpapers"
ROFI_CONF="$HOME/.config/rofi/config-wallpaper.rasi"

if [ ! -d "$WALL_DIR" ]; then
    notify-send "Wallpaper Picker" "No wallpapers directory found at $WALL_DIR" -u critical
    exit 1
fi

WALL_COUNT=0
while IFS= read -r _; do
    WALL_COUNT=$((WALL_COUNT + 1))
done < <(find -L "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null)

if [ "$WALL_COUNT" -eq 0 ]; then
    notify-send "Wallpaper Picker" "No wallpapers found in $WALL_DIR" -u low
    exit 1
fi

# Calculate width and columns
if [ "$WALL_COUNT" -eq 1 ]; then
    DYNAMIC_WIDTH=220
    DYNAMIC_COLS=1
elif [ "$WALL_COUNT" -eq 2 ]; then
    DYNAMIC_WIDTH=440
    DYNAMIC_COLS=2
else
    DYNAMIC_WIDTH=665
    DYNAMIC_COLS=3
fi

ROFI_DYNAMIC_STR="window { width: ${DYNAMIC_WIDTH}px; } listview { columns: ${DYNAMIC_COLS}; }"

generate_wall_entries() {
    for _ in {1..4}; do
        while IFS= read -r wall_path; do
            [ -n "$wall_path" ] || continue
            wall_name=$(basename "$wall_path")
            printf '%s\0icon\x1f%s\n' "$wall_name" "$wall_path"
        done < <(find -L "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | sort)
    done
}

# Select wallpaper
if [ -f "$ROFI_CONF" ]; then
    SELECTED_NAME=$(generate_wall_entries | rofi -dmenu -i -selected-row 0 -p "󰸉 Select Wallpaper" -show-icons -theme "$ROFI_CONF" -theme-str "$ROFI_DYNAMIC_STR")
else
    SELECTED_NAME=$(generate_wall_entries | rofi -dmenu -i -selected-row 0 -p "󰸉 Select Wallpaper" -show-icons -theme-str "$ROFI_DYNAMIC_STR")
fi

# Apply wallpaper via awww
if [ -n "$SELECTED_NAME" ]; then
    SELECTED_PATH="$WALL_DIR/$SELECTED_NAME"
    if [ -f "$SELECTED_PATH" ]; then
        if ! pgrep -x "awww-daemon" > /dev/null; then
            mkdir -p "$HOME/.cache/awww"
            awww-daemon &
            sleep 0.2
        fi
        awww img "$SELECTED_PATH" --transition-type outer --transition-fps 60 --transition-step 90
        notify-send "Wallpaper Updated" "Set to $SELECTED_NAME" -i "$SELECTED_PATH"
    fi
fi