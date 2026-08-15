#!/usr/bin/env bash

THEMES_DIR="$HOME/.config/hypr/themes"
ROFI_CONF="$HOME/.config/rofi/config-theme.rasi"

if [ ! -d "$THEMES_DIR" ]; then
    notify-send "Theme Switcher" "No themes directory found at $THEMES_DIR" -u critical
    exit 1
fi

MENU_ENTRIES=""

for theme_path in "$THEMES_DIR"/*; do
    [ -d "$theme_path" ] || continue
    theme_name=$(basename "$theme_path")

    # Search for preview image or fallback to first wallpaper
    icon_path=""
    if [ -f "$theme_path/preview.png" ]; then
        icon_path="$theme_path/preview.png"
    elif [ -f "$theme_path/theme.png" ]; then
        icon_path="$theme_path/theme.png"
    elif [ -d "$theme_path/wallpapers" ]; then
        icon_path=$(find -L "$theme_path/wallpapers" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | head -n 1)
    fi

    if [ -n "$icon_path" ]; then
        MENU_ENTRIES+="${theme_name}\0icon\x1f${icon_path}\n"
    else
        MENU_ENTRIES+="${theme_name}\n"
    fi
done

if [ -z "$MENU_ENTRIES" ]; then
    notify-send "Theme Switcher" "No theme folders found in $THEMES_DIR" -u low
    exit 1
fi

# Launch Rofi
if [ -f "$ROFI_CONF" ]; then
    SELECTED=$(printf "%b" "$MENU_ENTRIES" | rofi -dmenu -i -p "󰔎 Select Theme" -show-icons -theme "$ROFI_CONF")
else
    SELECTED=$(printf "%b" "$MENU_ENTRIES" | rofi -dmenu -i -p "󰔎 Select Theme" -show-icons)
fi

# Apply selected theme
if [ -n "$SELECTED" ]; then
    TARGET_THEME="$THEMES_DIR/$SELECTED"
    
    if [ -d "$TARGET_THEME" ]; then
        # 1. Symlink active theme root
        ln -sfn "$TARGET_THEME" "$HOME/.config/hypr/current_theme"

        # 2. Apply Waybar styling
        if [ -f "$TARGET_THEME/waybar.css" ]; then
            ln -sf "$TARGET_THEME/waybar.css" "$HOME/.config/waybar/style.css"
            pkill waybar && waybar >/dev/null 2>&1 &
        fi

        # 3. Apply Rofi colors
        if [ -f "$TARGET_THEME/rofi.rasi" ]; then
            ln -sf "$TARGET_THEME/rofi.rasi" "$HOME/.config/rofi/theme.rasi"
        fi

        # 4. Apply Ghostty terminal theme
        if [ -f "$TARGET_THEME/ghostty.conf" ]; then
            mkdir -p "$HOME/.config/ghostty"
            ln -sf "$TARGET_THEME/ghostty.conf" "$HOME/.config/ghostty/theme.conf"
        fi

        # 5. Link Kitty theme if it exists
if [ -f "$TARGET_THEME/kitty.conf" ]; then
    ln -sf "$TARGET_THEME/kitty.conf" "$HOME/.config/kitty/theme.conf"
    # Send signal to reload Kitty colors instantly without restarting
    killall -SIGUSR1 kitty 2>/dev/null
fi

        # 6. Apply default wallpaper from new theme
        FIRST_WALL=$(find -L "$TARGET_THEME/wallpapers" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | head -n 1)
        if [ -n "$FIRST_WALL" ]; then
            if ! pgrep -x "awww-daemon" > /dev/null; then
                awww-daemon &
                sleep 0.2
            fi
            awww img "$FIRST_WALL" --transition-type outer --transition-fps 60 --transition-step 90
        fi

        # 7. Reload Hyprland to process new theme bindings/colors
        hyprctl reload >/dev/null 2>&1

        notify-send "Theme Switched" "Active theme set to $SELECTED" -i "${FIRST_WALL:-dialog-information}"
    fi
fi
