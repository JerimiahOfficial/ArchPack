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

# check if system is not a hyper visor using grep
if grep -q "hypervisor" /proc/cpuinfo; then
  echo "System is a hypervisor skipping nvidia setup."
else
  # Enable nvidia for initial ramdisk
  sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm) /' /etc/mkinitcpio.conf
  sudo sed -i 's/kms //' /etc/mkinitcpio.conf

  # Nvidia
  sudo pacman -S --noconfirm mesa lib32-mesa libglvnd lib32-libglvnd lib32-keyutils lib32-krb5 nvidia nvidia-utils lib32-nvidia-utils

  # Create nvidia hooks for pacman
  # Reference: https://wiki.archlinux.org/title/NVIDIA#pacman_hook
  sudo mkdir -p /etc/pacman.d/hooks
  sudo curl -o /etc/pacman.d/hooks/nvidia.hook $pacman_hook
fi

# Install display server
sudo pacman -S --noconfirm xorg-server wayland xorg-xwayland qt5-wayland glfw-wayland egl-wayland

if grep -q "hypervisor" /proc/cpuinfo; then
  # Install desktop environment
  sudo pacman -S --noconfirm plasma-meta konsole ufw dolphin
else
  # Install desktop environment
  sudo pacman -S --noconfirm plasma-meta plasma-wayland-session konsole ufw dolphin
fi

# Enable services
sudo systemctl enable sddm.service
sudo systemctl enable ufw.service

# Applications
sudo pacman -S --noconfirm bitwarden steam lutris vlc ark obs-studio kdenlive git jre17-openjdk nodejs npm cmake vulkan-icd-loader lib32-vulkan-icd-loader

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

# Reboot the system
reboot
