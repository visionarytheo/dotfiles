#!/usr/bin/env bash

WALL_DIR="$HOME/.config/hypr/current_theme/wallpapers"
ROFI_CONF="$HOME/.config/rofi/config-wallpaper.rasi"
CACHE_DIR="$HOME/.cache/rofi-wallpapers"

mkdir -p "$CACHE_DIR"

if [ ! -d "$WALL_DIR" ]; then
    WALL_DIR="$HOME/Pictures/Wallpapers"
fi

# Detect ImageMagick command (magick or convert)
MAGICK_CMD=""
if command -v magick &>/dev/null; then
    MAGICK_CMD="magick"
elif command -v convert &>/dev/null; then
    MAGICK_CMD="convert"
fi

MENU_ENTRIES=""

while IFS= read -r img; do
    [ -z "$img" ] && continue
    filename=$(basename "$img")
    filepath=$(realpath "$img")

    # Generate unique hash for cache filename based on full path
    hash=$(echo -n "$filepath" | md5sum | cut -d' ' -f1)
    thumb_path="$CACHE_DIR/${hash}.png"

    # Pre-assign thumbnail path if ImageMagick is available
    if [ -n "$MAGICK_CMD" ]; then
        if [ ! -f "$thumb_path" ] || [ "$filepath" -nt "$thumb_path" ]; then
            "$MAGICK_CMD" "$filepath" -thumbnail 300x200^ -gravity center -extent 300x200 "$thumb_path" &
        fi
        ICON_PATH="$thumb_path"
    else
        ICON_PATH="$filepath"
    fi

    MENU_ENTRIES+="${filename}\x00icon\x1f${ICON_PATH}\n"
done < <(find -L "$WALL_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \))

# Wait for background thumbnail processes to finish before opening Rofi
wait

# Exit gracefully if no wallpapers were found
if [ -z "$MENU_ENTRIES" ]; then
    notify-send "Wallpaper Selector" "No wallpapers found in $WALL_DIR" -u low
    exit 1
fi

# Pass entries to Rofi
if [ -f "$ROFI_CONF" ]; then
    SELECTED=$(printf "%b" "$MENU_ENTRIES" | rofi -dmenu -i -p "󰸉 Select Wallpaper" -show-icons -theme "$ROFI_CONF")
else
    SELECTED=$(printf "%b" "$MENU_ENTRIES" | rofi -dmenu -i -p "󰸉 Select Wallpaper" -show-icons)
fi

# Apply wallpaper via awww
if [ -n "$SELECTED" ]; then
    IMAGE_PATH=$(realpath "$WALL_DIR/$SELECTED")

    if ! pgrep -x "awww-daemon" > /dev/null; then
        mkdir -p "$HOME/.cache/awww"
        awww-daemon &
        sleep 0.2
    fi

    awww img "$IMAGE_PATH" \
        --transition-type outer \
        --transition-fps 60 \
        --transition-step 90

    notify-send "Wallpaper Changed" "Applied $SELECTED" -i "$IMAGE_PATH"
fi
