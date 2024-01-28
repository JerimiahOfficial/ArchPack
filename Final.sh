#!/bin/bash -e

# Check if user is root
if [ "$EUID" -eq 0 ]; then
  echo "Please run as normal user"
  exit
fi

# Variables
pacman_hook="https://raw.githubusercontent.com/JerimiahOfficial/ArchPack/main/nvidia.hook"

# Edit pacman.conf
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sudo sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

# Update system
sudo pacman -Syu --noconfirm

# Enable nvidia for initial ramdisk
# Reference: https://github.com/korvahannu/arch-nvidia-drivers-installation-guide
sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm) /' /etc/mkinitcpio.conf
sudo sed -i 's/kms //' /etc/mkinitcpio.conf

# Nvidia
sudo pacman -S --noconfirm --needed mesa lib32-mesa libglvnd lib32-libglvnd lib32-keyutils lib32-krb5 nvidia nvidia-utils lib32-nvidia-utils

# Make hooks directory for pacman
sudo mkdir -p /etc/pacman.d/hooks

# Create nvidia hooks for pacman
# Reference: https://wiki.archlinux.org/title/NVIDIA#pacman_hook
sudo curl -o /etc/pacman.d/hooks/nvidia.hook $pacman_hook

# Install display manager
sudo pacman -S --noconfirm --needed wayland xorg-xwayland qt5-wayland glfw-wayland egl-wayland

# Install desktop environment
sudo pacman -S --noconfirm --needed plasma-meta plasma-wayland-session konsole ufw dolphin

# Enable services
sudo systemctl enable sddm.service
sudo systemctl enable ufw.service

# Applications
sudo pacman -S --noconfirm bitwarden discord steam lutris vlc ark obs-studio kdenlive git jre17-openjdk nodejs npm cmake vulkan-icd-loader lib32-vulkan-icd-loader

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
yay -S --noconfirm librewolf-bin portmaster-stub-bin vscodium-bin modrinth-app-bin

# Cleaning up
sudo rm /Final.sh

# Reboot the system
reboot