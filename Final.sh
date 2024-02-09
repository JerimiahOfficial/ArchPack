#!/bin/bash -e

# Check if user is root
if [ "$EUID" -eq 0 ]; then
  echo "Please run as normal user"
  exit
fi

# Get user id and group id
UUID=$(id -u)
GUID=$(id -g)

# Installing yay
cd ~
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $UUID:$GUID yay
(cd yay && makepkg -si --noconfirm)

# Updating yay packages
yay -Syu --noconfirm

# Installing yay packages
yay -S --noconfirm librewolf-bin modrinth-app-bin portmaster-stub-bin vesktop-bin vscodium-bin

# Cleaning up
sudo rm /Final.sh
