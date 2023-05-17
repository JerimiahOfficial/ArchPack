# !/bin/bash -e
echo "Checking for multilib"
if ! grep -q "\[multilib\]" /etc/pacman.conf; then
    echo "Steam requires Multilib which is not enabled."
    exit 1
fi

echo "Updating pacman packages"
sudo pacman -Syu --noconfirm

echo "Installing pacman packages"
sudo pacman -S bitwarden discord git lib32-nvidia-utils nvidia-utils p7zip steam ufw

# ufw needs to be enable in kde's firewall settings.
echo "Enabling ufw"
sudo systemctl enable ufw
sudo systemctl start ufw

cd ~

if ! command -v yay &>/dev/null; then
    echo "Installing yay"
    sudo git clone https://aur.archlinux.org/yay.git
    sudo chown -R $USER:$USER ./yay
    (cd yay && makepkg -si --noconfirm)
fi

echo "Updating yay packages"
sudo yay -Syu --noconfirm

echo "Installing yay packages"
yay -S --noconfirm github-desktop-bin librewolf-bin portmaster-stub-bin vscodium-bin

echo "Installing themes"
sudo git clone https://github.com/vinceliuice/Orchis-kde.git
(cd Orchis-kde && bash install.sh)

sudo git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
(cd Tela-circle-icon-theme && bash install.sh)

exit 0