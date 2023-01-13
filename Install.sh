# !/bin/bash -e
###############################################################################
# This is a script to install all the software I need on a new arch system.
# It is not intended to be run as root, but as a normal user.
#
# The software that will be installed after running this script:
# - Bitwarden
# - Discord
# - Firefox
# - github-desktop
# - Spotify
# - Steam
# - ufw
# - VSCode

# Cd to the opt directory
cd /opt

# Make sure the system is up to date
sudo pacman -Syu --noconfirm

# Installing yay
sudo pacman -S --noconfirm git base-devel
sudo git clone https://aur.archlinux.org/yay-git.git
sudo chown -R $USER:$USER ./yay-git

cd yay-git

makepkg -si

# Make sure the yay packages are up to date
sudo yay -Syu

# Installing the software with no prompts
sudo yay -S --noconfirm bitwarden discord firefox github-desktop spotify steam ufw visual-studio-code-bin

# Start and enable ufw
sudo systemctl enable ufw
sudo systemctl start ufw
