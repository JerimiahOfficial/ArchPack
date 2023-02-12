# !/bin/bash -e
# If multilib is not enabled stop the script.
if ! grep -q "\[multilib\]" /etc/pacman.conf; then
    echo "Multilib is not enabled. Please enable multilib in /etc/pacman.conf"
    exit 1
fi

echo "Updating system"
sudo pacman -Syu --noconfirm

echo "Installing ufw"
sudo pacman -S ufw --noconfirm

echo "Enabling ufw"
sudo systemctl enable ufw
sudo systemctl start ufw

echo "Installing nix"
sudo pacman -S nix --noconfirm

echo "Launching nix daemon"
sudo systemctl enable nix-daemon
sudo systemctl start nix-daemon

echo "Adding current user to nix group"
sudo usermod -a -G nix-users $USER
sudo usermod -a -G nixbld $USER

echo "Running nix setup"
nix-env --install --quiet

echo "Adding channels"
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update

echo "Installing software"

# If you want to add your own packages to personalize
# your script goto https://search.nixos.org/packages.
list=(
    bitwarden
    discord
    github-desktop
    openrgb
    p7zip
    spotify
    steam
    vscode
)

export NIXPKGS_ALLOW_UNFREE=1
for i in "${list[@]}"; do
    echo "Installing $i"
    nix-env -iA nixpkgs.$i --quiet
done

echo "Installation complete"
exit 0
