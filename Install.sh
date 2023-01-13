# !/bin/bash -e
# Cd to the opt directory
cd /opt

# Enable multilib inside of pacman.conf
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

# Make sure the system is up to date
sudo pacman -Syu --noconfirm

# Install all the packages that can be installed with pacman
pacman=(bitwarden base-devel discord git p7zip steam ufw)

for i in "${pacman[@]}"; do
    echo "Installing $i"
    sudo pacman -S --needed --noconfirm $i
done

# Start and enable ufw
sudo systemctl enable ufw
sudo systemctl start ufw

# Installing yay
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $USER:$USER ./yay

cd yay-git

makepkg -si

# Make sure the yay packages are up to date
sudo yay -Syu

# Install all the packages that can be installed with yay
yay=(github-desktop openrgb spotify visual-studio-code-bin)

for i in "${yay[@]}"; do
    echo "Installing $i"
    yay -S --noconfirm $i
done
