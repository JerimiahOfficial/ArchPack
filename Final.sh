#!/bin/bash -e

# Check if user is root
# if root then close
if [ "$EUID" -eq 0 ]; then
  echo "Please run as normal user"
  exit
fi

# Variables
mirrorlist="https://archlinux.org/mirrorlist/?country=CA&protocol=https&ip_version=4&ip_version=6"

# Fetch mirrorlist
sudo curl -s $mirrorlist >/etc/pacman.d/mirrorlist
sudo sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist

# Updating pacman packages
sudo pacman -Syu --noconfirm

# Applications
sudo pacman -S bitwarden discord steam vlc ark

# Recording and editing
sudo pacman -S obs-studio kdenlive

# Developement
sudo pacman -S git jre17-openjdk nodejs npm cmake

# Vulkan
sudo pacman -S vulkan-icd-loader lib32-vulkan-icd-loader vulkan-headers vulkan-validation-layers vulkan-tools

# Installing virtualization packages
sudo pacman -S qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat libguestfs libvirt

# Change directory to home directory
cd ~

# Get user id and group id
UUID=$(id -u)
GUID=$(id -g)

# Installing yay
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $UUID:$GUID yay
(cd yay && makepkg -si --noconfirm)

# Updating yay packages
yay -Syu --noconfirm

# Installing yay packages
yay -S librewolf-bin github-desktop-bin vscodium-bin minecraft-launcher

# Adding user to libvirt group and starting the service.
sudo usermod -aG libvirt $USER

# Services
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

# Cleaning up
sudo rm /Final.sh
