#!/bin/bash -e

# Check if user is root
# if root then close
if [ "$EUID" -eq 0 ]; then
  echo "Please run as normal user"
  exit
fi

# Updating pacman packages
sudo pacman -Syu --noconfirm

# Applications
sudo pacman -S bitwarden discord steam vlc

# Recording and editing
sudo pacman -S obs-studio kdenlive

# Developement
sudo pacman -S git jre17-openjdk nodejs npm cmake

# Installing virtualization packages
# sudo pacman -S bridge-utils dnsmasq libvirt openbsd-netcat qemu-full vde2 virt-manager virt-viewer

# Change directory to home directory
cd ~

# Get user id and group id
UID=$(id -un)
GID=$(id -gn)

# Installing yay
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $UID:$GID yay
(cd yay && makepkg -si --noconfirm)

# Updating yay packages
yay -Syu --noconfirm

# Installing yay packages
yay -S mercury-browser-bin github-desktop-bin vscodium-bin minecraft-launcher

# Installing themes
sudo git clone https://github.com/vinceliuice/Orchis-kde.git
sudo bash ./Orchis-kde/install.sh
sudo bash ./Orchis-kde/sddm/install.sh

sudo git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
sudo bash ./Tela-circle-icon-theme/install.sh

# Adding user to libvirt group and starting the service.
# sudo usermod -aG libvirt $USER

# Services
# sudo systemctl enable libvirtd
# sudo systemctl start libvirtd
