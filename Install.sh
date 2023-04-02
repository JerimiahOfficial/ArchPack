# !/bin/bash -e
echo "Checking for multilib"
if ! grep -q "\[multilib\]" /etc/pacman.conf; then
    echo "Multilib is not enabled."
    exit 1
fi

echo "Updating pacman packages"
sudo pacman -Syu --noconfirm >/dev/null

echo "Installing pacman packages"
sudo pacman -S bitwarden discord git p7zip steam ufw

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
yay=(github-desktop openrgb spotify visual-studio-code-bin proton wine-stable)

for i in "${yay[@]}"; do
    echo "Installing $i"
    yay -S --noconfirm $i >/dev/null
done

exit 0
