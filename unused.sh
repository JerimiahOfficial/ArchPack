# This file contains the unused commands from pervious versions.

echo "keyserver hkp://keyserver.ubuntu.com" >>/mnt/etc/pacman.d/gnupg/gpg.conf

# Variables
mirrorlist="https://archlinux.org/mirrorlist/?country=CA&protocol=https&ip_version=4&ip_version=6"
pacman_hook="https://raw.githubusercontent.com/JerimiahOfficial/ArchPack/main/nvidia.hook"

# Fetch mirrorlist
curl -s $mirrorlist >/etc/pacman.d/mirrorlist
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist

# Install pipewire
pacman -S --noconfirm --needed pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire libpulse wireplumber lib32-pipewire
systemctl enable pipewire-pulse

# Enable fstrim
systemctl enable fstrim.timer

# Systemd-boot hook
cat <<EOF >/etc/pacman.d/hooks/95-systemd-boot.hook
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Gracefully upgrading systemd-boot...
When = PostTransaction
Exec = /usr/bin/systemctl restart systemd-boot-update.service
EOF

# virtualization stuff

# Installing virtualization packages
sudo pacman -S qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat libguestfs libvirt

# Adding user to libvirt group and starting the service.
sudo usermod -aG libvirt $USER

# Services
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

# Create nvidia hooks for pacman
# Reference: https://wiki.archlinux.org/title/NVIDIA#pacman_hook
sudo mkdir -p /etc/pacman.d/hooks
sudo curl -o /etc/pacman.d/hooks/nvidia.hook $pacman_hook

# Nvidia for dkms
sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm) /' /etc/mkinitcpio.conf
sudo sed -i 's/kms //' /etc/mkinitcpio.conf
