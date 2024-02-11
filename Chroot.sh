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

###############################################################################################################################################

# Edit pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

# Update system
pacman -Syu --noconfirm

# Install nvidia drivers
pacman -S --noconfirm nvidia-open-dkms

# Install display server
pacman -S --noconfirm xorg-xinit wayland xorg-xwayland

# Install desktop environment
pacman -S --noconfirm plasma-meta plasma-wayland-session konsole ufw dolphin

# Developement
pacman -S --noconfirm git jre17-openjdk nodejs npm cmake vulkan-icd-loader lib32-vulkan-icd-loader

# Applications
pacman -S --noconfirm bitwarden steam lutris vlc ark obs-studio kdenlive krita ktorrent gwenview

# Enable services
systemctl enable sddm.service
systemctl enable NetworkManager.service
systemctl enable ufw.service
