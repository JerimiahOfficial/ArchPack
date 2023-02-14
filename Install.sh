# !/bin/bash -e
echo "Checking for multilib"
if ! grep -q "\[multilib\]" /etc/pacman.conf; then
    echo "Multilib is not enabled. Please enable multilib in /etc/pacman.conf"
    exit 1
fi

echo "Installing pacman packages"
sudo pacman -Syu --noconfirm >/dev/null
pacman=(bitwarden discord git p7zip steam ufw nvidia nvidia-libgl)

for i in "${pacman[@]}"; do
    echo "Installing $i"
    sudo pacman -S --noconfirm $i >/dev/null
done

echo "Enabling ufw"
sudo systemctl enable ufw
sudo systemctl start ufw

echo "Installing yay"
cd /opt

sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $USER:$USER ./yay

cd yay

makepkg -si --noconfirm >/dev/null

echo "Installing yay packages"
sudo yay -Syu --noconfirm >/dev/null
yay=(github-desktop openrgb spotify visual-studio-code-bin)

for i in "${yay[@]}"; do
    echo "Installing $i"
    yay -S --noconfirm $i >/dev/null
done

exit 0
