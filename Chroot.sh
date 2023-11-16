#!/bin/bash -e

# Enable parallel downloads
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# Network setup
pacman -S --noconfirm --needed networkmanager dhclient
systemctl enable --now NetworkManager

# Install pipewire
pacman -S --noconfirm --needed pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire libpulse wireplumber lib32-pipewire
systemctl enable pipewire-pulse

# Localization and Time
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

locale-gen

timedatectl --no-ask-password set-timezone America/Toronto
timedatectl --no-ask-password set-ntp 1

ln -sf /usr/share/zoneinfo/America/Toronto >/etc/localtime

localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8"
localectl --no-ask-password set-keymap us

# Set hostname of the system
echo "archlinux" >/etc/hostname

# Create the user
useradd -m -g users -G wheel,storage,power -s /bin/bash jerimiah

# Set password of the users
echo "root:123214" | chpasswd
echo "jerimiah:123214" | chpasswd

# Enable fstrim
systemctl enable fstrim.timer

# Allow wheel group to use sudo
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
echo "Defaults rootpw" >>/etc/sudoers

# Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm --needed

# Installing Microcode
pacman -S --noconfirm --needed intel-ucode
proc_ucode=intel-ucode.img

# Mount efi vars
mount -t efivarfs efivarfs /sys/firmware/efi/efivars

# Intall bootloader
bootctl install

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

# Nvidia drivers
pacman -S --noconfirm --needed nvidia-lts nvidia-utils lib32-nvidia-utils

# Create bootloader config
cat <<EOF >/boot/loader/entries/arch.conf
title   Arch
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
EOF
echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/sda3) rw nvidia-drm.modeset=1" >>/boot/loader/entries/arch.conf

# Create nvidia hooks for pacman
# https://wiki.archlinux.org/title/NVIDIA#pacman_hook
mkdir /etc/pacman.d/hooks
cat <<EOF >/etc/pacman.d/hooks/nvidia.hook
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia-lts
Target=linux

[Action]
Description=Update NVIDIA module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF

# Enable nvidia for initial ramdisk
sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm) /' /etc/mkinitcpio.conf

# initramfs
mkinitcpio -P

# Install display manager
pcaman -S --noconfirm --needed wayland xorg-xwayland qt5-wayland glfw-wayland egl-wayland

# Install desktop environment
pacman -S --noconfirm --needed plasma-meta plasma-wayland-session konsole ufw dolphin

# Enable services
systemctl enable sddm.service
systemctl enable ufw.service

# Prompt user to reboot
cat <<EOF
#########################################

Installation complete reboot the system.

#########################################
EOF
