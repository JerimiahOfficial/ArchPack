# !/bin/bash -e
###############################################################################
# This is a script to install all the software I need on a new arch system.
# It is not intended to be run as root, but as a normal user.
#
# The software that will be installed after running this script:
# - Bitwarden
# - Discord
# - github-desktop
# - openrgb
# - p7zip
# - Spotify
# - Steam
# - ufw
# - VSCode

# Cd to the opt directory
cd /opt

# Uncomment [multilib] and the next line in /etc/pacman.conf
# using a multiline sed command
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

# Make sure the system is up to date
sudo pacman -Syu --noconfirm

# Install all the packages that can be installed with pacman
pacman=(bitwarden base-devel discord git p7zip steam ufw)

for i in "${pacman[@]}"; do
    sudo pacman -S --noconfirm $i
done

# Installing yay
sudo git clone https://aur.archlinux.org/yay-git.git
sudo chown -R $USER:$USER ./yay-git

cd yay-git

makepkg -si

# Make sure the yay packages are up to date
sudo yay -Syu

# Install all the packages that can be installed with yay
yay=(github-desktop openrgb spotify visual-studio-code-bin)

for i in "${yay[@]}"; do
    yay -S --noconfirm $i
done

# Start and enable ufw
sudo systemctl enable ufw
sudo systemctl start ufw
