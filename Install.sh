# !/bin/bash -e

echo "Checking for multilib"
if ! grep -q "\[multilib\]" /etc/pacman.conf; then
    echo "Multilib is not enabled."
    exit 1
fi

echo "Updating pacman packages"
sudo pacman -Syu --noconfirm

echo "Installing pacman packages"
sudo pacman -S bitwarden discord firefox git lib32-nvidia-utils nvidia-utils p7zip steam ufw

# Note -> ufw needs to be enable through kde's firewall application.
echo "Enabling ufw"
sudo systemctl enable ufw
sudo systemctl start ufw

if ! command -v yay &>/dev/null; then
    echo "Installing yay"
    sudo git clone https://aur.archlinux.org/yay.git
    sudo chown -R $USER:$USER ./yay
    cd yay
    makepkg -si --noconfirm
fi

echo "Updating yay packages"
sudo yay -Syu --noconfirm

echo "Installing yay packages"
yay -S github-desktop-bin spotify visual-studio-code-bin

exit 0
