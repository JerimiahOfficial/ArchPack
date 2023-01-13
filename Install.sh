# !/bin/bash -e
# Check if multilib is installed
if ! grep -q "\[multilib\]" /etc/pacman.conf; then
    echo "Enabling multilib"
    sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
fi

# Make sure the system is up to date
echo "Updating system"
sudo pacman -Syu --noconfirm

# Install all the packages that can be installed with pacman
pacman=(bitwarden discord git p7zip steam ufw)
for i in "${pacman[@]}"; do
    echo "Installing $i"
    sudo pacman -S --noconfirm $i >/dev/null
done

# Start and enable ufw
echo "Enabling ufw"
sudo systemctl enable ufw
sudo systemctl start ufw

# Installing yay
echo "Installing yay"
cd /opt

sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $USER:$USER ./yay

cd yay

makepkg -si

# Make sure the yay packages are up to date
echo "Updating yay packages"
sudo yay -Syu

# Install all the packages that can be installed with yay
yay=(github-desktop openrgb spotify visual-studio-code-bin)
for i in "${yay[@]}"; do
    echo "Installing $i"
    yay -S --noconfirm $i >/dev/null
done
