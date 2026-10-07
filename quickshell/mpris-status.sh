# ~/.config/quickshell/mpris-status.sh
#!/bin/bash
# A simple script to print Mpris metadata in a single line on changes
# requires playerctl

print_metadata() {
    status=$(playerctl status 2>/dev/null)
    if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
        artist=$(playerctl metadata artist 2>/dev/null)
        title=$(playerctl metadata title 2>/dev/null)
        artUrl=$(playerctl metadata mpris:artUrl 2>/dev/null)
        echo "{\"status\": \"$status\", \"artist\": \"$artist\", \"title\": \"$title\", \"artUrl\": \"$artUrl\"}"
    else
        echo "{\"status\": \"Stopped\"}"
    fi
}

# Print once on start
print_metadata

# Follow changes
playerctl -F metadata --format '{{status}}' 2>/dev/null | while read -r change; do
    print_metadata
done
