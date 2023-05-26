# !/bin/bash -e
echo "Checking for multilib"
if ! grep -q "\[multilib\]" /etc/pacman.conf; then
    echo "Steam requires Multilib which is not enabled."
    exit 1
fi

echo "Updating pacman packages"
sudo pacman -Syu --noconfirm

echo "Installing pacman packages"
sudo pacman -S bitwarden discord firefox firewalld git lib32-nvidia-utils nvidia-utils obs-studio p7zip steam

echo "Installing virtualization packages"
sudo pacman -S aqemu bridge-utils dnsmasq libvirt openbsd-netcat qemu vde2 virt-manager virt-viewer

echo "Services"
# ufw needs to be enable in kde's firewall settings page.
sudo systemctl enable firewalld
sudo systemctl start firewalld

# Adding user to libvirt group and starting the service.
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

sudo usermod -aG libvirt $USER

sudo systemctl restart libvirtd

# Installing aur package manager.
cd ~

if ! command -v yay &>/dev/null; then
    echo "Installing yay"
    sudo git clone https://aur.archlinux.org/yay.git
    sudo chown -R $USER:$USER ./yay
    (cd yay && makepkg -si --noconfirm)
fi

echo "Updating yay packages"
yay -Syu --noconfirm

echo "Installing yay packages"
yay -S github-desktop-bin vscodium-bin minecraft-launcher

echo "Installing themes"
sudo git clone https://github.com/vinceliuice/Orchis-kde.git
(cd Orchis-kde && bash install.sh)

sudo git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
(cd Tela-circle-icon-theme && bash install.sh)

exit 0