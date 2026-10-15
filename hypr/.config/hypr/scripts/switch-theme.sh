#!/usr/bin/env bash

THEMES_DIR="$HOME/.config/hypr/themes"
ROFI_CONF="$HOME/.config/rofi/config-theme.rasi"
SWATCH_DIR="$HOME/.cache/hypr/theme-swatches"

if [ ! -d "$THEMES_DIR" ]; then
    notify-send "Theme Switcher" "No themes directory found at $THEMES_DIR" -u critical
    exit 1
fi

mkdir -p "$SWATCH_DIR"

# Count theme directories robustly using find
THEME_COUNT=0
while IFS= read -r _; do
    THEME_COUNT=$((THEME_COUNT + 1))
done < <(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

if [ "$THEME_COUNT" -eq 0 ]; then
    notify-send "Theme Switcher" "No theme folders found in $THEMES_DIR" -u low
    exit 1
fi

# Calculate dynamic window width and listview column count matching theme count
if [ "$THEME_COUNT" -eq 1 ]; then
    DYNAMIC_WIDTH=220
    DYNAMIC_COLS=1
elif [ "$THEME_COUNT" -eq 2 ]; then
    DYNAMIC_WIDTH=445
    DYNAMIC_COLS=2
else
    DYNAMIC_WIDTH=665
    DYNAMIC_COLS=3
fi

# Stream entries with dynamically generated color palette dot swatches
generate_entries() {
    for _ in {1..4}; do
        while IFS= read -r theme_path; do
            [ -n "$theme_path" ] || continue
            theme_name=$(basename "$theme_path")
            swatch_path="$SWATCH_DIR/${theme_name}.png"

            # Extract colors from theme's rofi.rasi if available
            rofi_rasi="$theme_path/rofi.rasi"
            bg=""
            accent=""
            fg=""
            border=""

            if [ -f "$rofi_rasi" ]; then
                bg=$(grep -E '^\s*bg:\s*#' "$rofi_rasi" 2>/dev/null | head -n1 | awk '{print $2}' | tr -d ';')
                accent=$(grep -E '^\s*accent:\s*#' "$rofi_rasi" 2>/dev/null | head -n1 | awk '{print $2}' | tr -d ';')
                fg=$(grep -E '^\s*fg:\s*#' "$rofi_rasi" 2>/dev/null | head -n1 | awk '{print $2}' | tr -d ';')
                border=$(grep -E '^\s*border-col:\s*#' "$rofi_rasi" 2>/dev/null | head -n1 | awk '{print $2}' | tr -d ';')
            fi

            # Fallbacks if extraction fails
            bg="${bg:-#282828}"
            accent="${accent:-#fabd2f}"
            fg="${fg:-#ebdbb2}"
            border="${border:-#504945}"

            # Generate clean, perfectly centered 4-dot color palette swatch
            if [ ! -f "$swatch_path" ] && command -v magick &>/dev/null; then
                magick -size 300x120 xc:"#1e1e2e" \
                    -strokewidth 2 -stroke "#313244" \
                    -fill "$bg" -draw "circle 90,60 90,44" \
                    -fill "$accent" -draw "circle 130,60 130,44" \
                    -fill "$fg" -draw "circle 170,60 170,44" \
                    -fill "$border" -draw "circle 210,60 210,44" \
                    "$swatch_path" 2>/dev/null
            fi

            # Fallback to standard preview image if magick is missing or swatch failed
            icon_path="$swatch_path"
            if [ ! -f "$icon_path" ]; then
                if [ -f "$theme_path/preview.png" ]; then
                    icon_path="$theme_path/preview.png"
                elif [ -f "$theme_path/theme.png" ]; then
                    icon_path="$theme_path/theme.png"
                else
                    icon_path=""
                fi
            fi

            if [ -n "$icon_path" ]; then
                printf '%s\x00icon\x1f%s\n' "$theme_name" "$icon_path"
            else
                printf '%s\n' "$theme_name"
            fi
        done < <(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
    done
}

# Select theme via argument or fallback to Rofi menu
if [ -n "$1" ]; then
    SELECTED="$1"
else
    if [ -f "$ROFI_CONF" ]; then
        SELECTED=$(generate_entries | rofi -dmenu -i -selected-row 0 -p "󰔎 Select Theme" -show-icons -theme "$ROFI_CONF" -theme-str "window { width: ${DYNAMIC_WIDTH}px; }" -theme-str "listview { columns: ${DYNAMIC_COLS}; }")
    else
        SELECTED=$(generate_entries | rofi -dmenu -i -selected-row 0 -p "󰔎 Select Theme" -show-icons -theme-str "window { width: ${DYNAMIC_WIDTH}px; }" -theme-str "listview { columns: ${DYNAMIC_COLS}; }")
    fi
fi

# Apply selected theme
if [ -n "$SELECTED" ]; then
    TARGET_THEME="$THEMES_DIR/$SELECTED"
    
    if [ -d "$TARGET_THEME" ]; then
        # 1. Symlink active theme root
        ln -sfn "$TARGET_THEME" "$HOME/.config/hypr/current_theme"

        # 2. Apply Waybar styling
        if [ -f "$TARGET_THEME/waybar.css" ]; then
            mkdir -p "$HOME/.config/waybar"
            ln -sf "$TARGET_THEME/waybar.css" "$HOME/.config/waybar/style.css"
            pkill waybar && waybar >/dev/null 2>&1 &
        fi

        # 3. Apply Rofi colors
        if [ -f "$TARGET_THEME/rofi.rasi" ]; then
            mkdir -p "$HOME/.config/rofi"
            ln -sf "$TARGET_THEME/rofi.rasi" "$HOME/.config/rofi/theme.rasi"
        fi

        # 4. Apply Ghostty terminal theme
        if [ -f "$TARGET_THEME/ghostty.conf" ]; then
            mkdir -p "$HOME/.config/ghostty"
            ln -sf "$TARGET_THEME/ghostty.conf" "$HOME/.config/ghostty/theme.conf"
        fi

        # 5. Link Kitty theme if it exists
        if [ -f "$TARGET_THEME/kitty.conf" ]; then
            mkdir -p "$HOME/.config/kitty"
            ln -sf "$TARGET_THEME/kitty.conf" "$HOME/.config/kitty/theme.conf"
            killall -SIGUSR1 kitty 2>/dev/null
        fi

        # 6. Apply theme.ini settings (GTK, Icons, Cursors, and Hyprland Env)
        if [ -f "$TARGET_THEME/theme.ini" ]; then
            unset GTK_THEME ICON_THEME CURSOR_THEME CURSOR_SIZE
            . "$TARGET_THEME/theme.ini"
            
            [ -n "$GTK_THEME" ] && gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
            [ -n "$ICON_THEME" ] && gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
            [ -n "$CURSOR_THEME" ] && gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME"
            [ -n "$CURSOR_SIZE" ] && gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE"

            ENV_FILE="$HOME/.config/hypr/env_variables.lua"
            if [ -f "$ENV_FILE" ]; then
                if [ -n "$CURSOR_THEME" ]; then
                    sed -i 's/\(hl\.env("XCURSOR_THEME",\s*"\)[^"]*\("\)/\1'"$CURSOR_THEME"'\2/' "$ENV_FILE"
                    sed -i 's/\(hl\.env("HYPRCURSOR_THEME",\s*"\)[^"]*\("\)/\1'"$CURSOR_THEME"'\2/' "$ENV_FILE"
                fi
                if [ -n "$CURSOR_SIZE" ]; then
                    sed -i 's/\(hl\.env("XCURSOR_SIZE",\s*"\)[^"]*\("\)/\1'"$CURSOR_SIZE"'\2/' "$ENV_FILE"
                    sed -i 's/\(hl\.env("HYPRCURSOR_SIZE",\s*"\)[^"]*\("\)/\1'"$CURSOR_SIZE"'\2/' "$ENV_FILE"
                fi
            fi

            # Sync GTK/X11 legacy cursor fallback theme
            if [ -n "$CURSOR_THEME" ]; then
                mkdir -p "$HOME/.icons/default"
                cat <<EOF > "$HOME/.icons/default/index.theme"
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=$CURSOR_THEME
EOF
            fi
        fi

        # 7. Apply default wallpaper from new theme using awww
        FIRST_WALL=$(find -L "$TARGET_THEME/wallpapers" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | sort | head -n 1)
        if [ -n "$FIRST_WALL" ]; then
            if ! pgrep -x "awww-daemon" > /dev/null; then
                mkdir -p "$HOME/.cache/awww"
                awww-daemon &
                sleep 0.2
            fi
            awww img "$FIRST_WALL" --transition-type outer --transition-fps 60 --transition-step 90
        fi

        # 8. Reload Hyprland
        hyprctl reload >/dev/null 2>&1

        # 9. Force immediate live runtime cursor update (executed AFTER hyprctl reload)
        if [ -n "$CURSOR_THEME" ] && [ -n "$CURSOR_SIZE" ]; then
            hyprctl setcursor "$CURSOR_THEME" "$CURSOR_SIZE" 2>/dev/null
        fi

        notify-send "Theme Switched" "Active theme set to $SELECTED" -i "${FIRST_WALL:-dialog-information}"

        # 10. Apply VSCodium theme via settings.json using Python (immune to JSON comments/trailing commas)
        VSC_SETTINGS="$HOME/.config/VSCodium/User/settings.json"
        if [ -f "$TARGET_THEME/vscodium.theme" ] && [ -f "$VSC_SETTINGS" ]; then
            VSC_THEME=$(cat "$TARGET_THEME/vscodium.theme")
            python3 -c '
import json, sys, re

settings_path = sys.argv[1]
new_theme = sys.argv[2]

try:
    with open(settings_path, "r") as f:
        content = f.read()
    
    # Remove single-line comments and trailing commas to avoid parse errors
    content_clean = re.sub(r"^\s*//.*$", "", content, flags=re.MULTILINE)
    content_clean = re.sub(r",\s*([\]}])", r"\1", content_clean)
    
    data = json.loads(content_clean)
    data["workbench.colorTheme"] = new_theme
    
    with open(settings_path, "w") as f:
        json.dump(data, f, indent=4)
except Exception as e:
    print(f"Error updating VSCodium theme: {e}", file=sys.stderr)
' "$VSC_SETTINGS" "$VSC_THEME"
        fi
    fi
fi