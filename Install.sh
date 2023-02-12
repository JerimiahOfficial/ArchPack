# !/bin/bash -e
# Check if multilib is installed
if ! grep -q "\[multilib\]" /etc/pacman.conf; then
    echo "Enabling multilib"
    sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
fi

# Make sure the system is up to date
echo "Updating system"
sudo pacman -Syu --noconfirm

# Install ufw
echo "Installing ufw"
sudo pacman -S ufw --noconfirm

# Enable ufw
echo "Enabling ufw"
sudo systemctl enable ufw
sudo systemctl start ufw

# Install nix package manager
echo "Installing nix"
pacman -S nix --noconfirm

# Launch nix daemon
echo "Launching nix daemon"
sudo systemctl enable nix-daemon
sudo systemctl start nix-daemon

# Add current user to nix group
echo "Adding current user to nix group"
sudo usermod -a -G nix-users $USER
sudo usermod -a -G nix-bld $USER

# Run nix setup
echo "Running nix setup"
nix-env --install

# Add channels
echo "Adding channels"
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update

# Install software
echo "Installing software"

# List of packages to install
# Bitwarden
# Discord
# github-desktop
# openrgb
# p7zip
# Spotify
# Steam
# vscodium
list=(
    bitwarden
    discord
    github-desktop
    openrgb
    p7zip
    spotify
    steam
    vscodium
)

# Install packages
for i in "${list[@]}"; do
    echo "Installing $i"
    nix-env -iA nixpkgs.$i
done
