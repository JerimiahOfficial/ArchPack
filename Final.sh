# !/bin/bash
set -e

# Installing display manager and desktop environment
sudo pacman -Syu --noconfirm xorg-server xorg-xrandr dolphin konsole plasma

# Enable sddm
sudo systemctl enable sddm

# Enable multilib
sudo sed -i '/\[multilib\]/aInclude = /etc/pacman.d/mirrorlist' /etc/pacman.conf

cd ~

echo "Updating pacman packages"
sudo pacman -Syu --noconfirm

echo "Installing system packages"
sudo pacman -S firewalld lib32-nvidia-utils nvidia-settings nvidia-utils xdg-desktop-portal

echo "Installing applications"
sudo pacman -S bitwarden discord obs-studio steam

echo "Installing developement packages"
sudo pacman -S git jre17-openjdk nodejs npm

echo "Installing virtualization packages"
sudo pacman -S bridge-utils dnsmasq libvirt openbsd-netcat qemu-full vde2 virt-manager virt-viewer

echo "Installing yay"
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $USER:$USER ./yay
(cd yay && makepkg -si --noconfirm)

echo "Updating yay packages"
yay -Syu --noconfirm

echo "Installing yay packages"
yay -S github-desktop-bin vscodium-bin minecraft-launcher librewolf

echo "Installing themes"
sudo git clone https://github.com/vinceliuice/Orchis-kde.git
sudo bash ./Orchis-kde/install.sh
sudo bash ./Orchis-kde/sddm/install.sh

sudo git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
sudo bash ./Tela-circle-icon-theme/install.sh

echo "Services"
# ufw needs to be enable in kde's firewall settings page.
sudo systemctl enable firewalld
sudo systemctl start firewalld

# Adding user to libvirt group and starting the service.
sudo usermod -aG libvirt $USER

sudo systemctl enable libvirtd
sudo systemctl start libvirtd
