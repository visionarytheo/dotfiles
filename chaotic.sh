#!/usr/bin/env bash
set -e

# Idempotency check: Exit safely if the keyrings are already mounted inside pacman
if grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    echo "Chaotic-AUR is already declared inside /etc/pacman.conf. Skipping install."
    exit 0
fi

echo "Receiving primary Chaotic-AUR key from keyserver..."
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

echo "Downloading database mirror profiles..."
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

echo "Appending repository configurations to /etc/pacman.conf..."
sudo bash -c 'cat << EOF >> /etc/pacman.conf

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF'
