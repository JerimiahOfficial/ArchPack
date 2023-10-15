#!/bin/bash -e

# Updating pacman packages
sudo pacman -Syu --noconfirm

# Installing applications
sudo pacman -S firefox bitwarden discord obs-studio steam

# Installing developement packages
sudo pacman -S git jre17-openjdk nodejs npm

# Installing virtualization packages
# sudo pacman -S bridge-utils dnsmasq libvirt openbsd-netcat qemu-full vde2 virt-manager virt-viewer

# Change directory to home directory
cd ~

# Installing yay
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R 1000:984 ./yay
(cd yay && makepkg -si --noconfirm)

# Updating yay packages
yay -Syu --noconfirm

# Installing yay packages
yay -S github-desktop-bin vscodium-bin minecraft-launcher

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
