# !/bin/bash -e
echo "Checking for multilib"
if ! grep -q "\[multilib\]" /etc/pacman.conf; then
    echo "Multilib is not enabled."
    exit 1
fi

echo "Updating pacman packages"
sudo pacman -Syu --noconfirm >/dev/null

echo "Installing pacman packages"
sudo pacman -S bitwarden discord git lib32-nvidia-utils nvidia-utils p7zip steam ufw

echo "Enabling ufw"
sudo systemctl enable ufw
sudo systemctl start ufw

echo "Installing yay"
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $USER:$USER ./yay
cd yay
makepkg -si --noconfirm >/dev/null

echo "Updating yay packages"
sudo yay -Syu --noconfirm >/dev/null

echo "Installing yay packages"
yay -S --noconfirm github-desktop spotify visual-studio-code-bin librewolf-bin >/dev/null

exit 0
