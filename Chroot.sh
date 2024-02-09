#!/bin/bash -e

# Set time zone for toronto
ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime

# Sync clock
hwclock --systohc

# Set locale
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

# Generate locale
locale-gen

# Set local config
echo "LANG=en_US.UTF-8" >/etc/locale.conf

# Set keymap
echo "KEYMAP=us" >/etc/vconsole.conf

# Set hostname
echo "archlinux" >/etc/hostname

# Set root password
echo "root:123214" | chpasswd

# Add user
useradd -m -G wheel -s /bin/bash jerimiah

# Set password
echo "jerimiah:123214" | chpasswd

# Allow wheel group to use sudo
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Enable networkmanager
systemctl enable NetworkManager

# Mount efi vars
mount -t efivarfs efivarfs /sys/firmware/efi/efivars

# Intall bootloader
bootctl --path=/boot install

# Create bootloader config
echo "default arch.conf" >/boot/loader/loader.conf
echo "timeout 4" >>/boot/loader/loader.conf

# Create bootloader entry config
echo "title   Arch linux" >/boot/loader/entries/arch.conf
echo "linux   /vmlinuz-linux" >>/boot/loader/entries/arch.conf
echo "initrd  /intel-ucode.img" >>/boot/loader/entries/arch.conf
echo "initrd  /initramfs-linux.img" >>/boot/loader/entries/arch.conf

if grep -q "hypervisor" /proc/cpuinfo; then
  # SATA device
  echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/sda3) zswap.enabled=0 rw rootfstype=ext4" >>/boot/loader/entries/arch.conf
else
  # NVMe device
  echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/nvme0n1p3) zswap.enabled=0 rw rootfstype=ext4" >>/boot/loader/entries/arch.conf
fi

############################################################

# Install nvidia drivers
sudo pacman -S --noconfirm mesa lib32-mesa nvidia nvidia-utils lib32-nvidia-utils

# Install display server
sudo pacman -S --noconfirm xorg-server wayland xorg-xwayland egl-wayland

# Install desktop environment
sudo pacman -S --noconfirm plasma-meta plasma-wayland-session konsole ufw dolphin

# Enable services
sudo systemctl enable sddm.service
sudo systemctl enable ufw.service

# Developement
sudo pacman -S --noconfirm git jre17-openjdk nodejs npm cmake vulkan-icd-loader lib32-vulkan-icd-loader

# Applications
sudo pacman -S --noconfirm bitwarden steam lutris vlc ark obs-studio kdenlive krita ktorrent gwenview

# Get user id and group id
UUID=$(id -u)
GUID=$(id -g)

# Installing yay
cd ~
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $UUID:$GUID yay
(cd yay && makepkg -si --noconfirm)

# Updating yay packages
yay -Syu --noconfirm

# Installing yay packages
yay -S --noconfirm librewolf-bin modrinth-app-bin portmaster-stub-bin vesktop-bin vscodium-bin
