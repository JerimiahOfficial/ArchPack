#!/bin/bash -e

# Localization
echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" >/etc/locale.conf
export LANG=en_US.UTF-8

# Timezone
ln -sf /usr/share/zoneinfo/Canada/Eastern >/etc/localtime
hwclock --systohc --utc

# Network configuration
echo "archlinux" >>/etc/hostname

# Create the user
useradd -m -g users -G wheel,storage,power -s /bin/bash jerimiah

# Enable fstrim
systemctl enable fstrim.timer

# Enable multilib
sed -i '/^\s*#\s*\[multilib\]/,/^#\s*Include = \/etc\/pacman.d\/mirrorlist/ s/#\s*//' /etc/pacman.conf
pacman -Sy
pacman -S --noconfirm intel-ucode
#pacman -S --noconfirm grub efibootmgr sudo

# Allow wheel group to use sudo
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
echo "Defaults rootpw" >>/etc/sudoers

# Mount efi vars
mount -t efivarfs efivarfs /sys/firmware/efi/efivars

# Intall bootloader
bootctl install

# Create bootloader config
cat <<EOF >/boot/loader/entries/arch.conf
title   Arch
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
EOF
echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/sda3) rw nvidia-drm.modeset=1" >>/boot/loader/entries/arch.conf

# Nvidia drivers
pacman -S --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings

# Create nvidia hooks for pacman
# https://wiki.archlinux.org/title/NVIDIA#pacman_hook
mkdir /etc/pacman.d/hooks
cat <<EOF >/etc/pacman.d/hooks/nvidia.hook
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia

[Action]
Depends=mkinitcpio
When=PostTransaction
Exec=/usr/bin/mkinitcpio -P'
EOF

# Enable nvidia for initial ramdisk
sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm) /' /etc/mkinitcpio.conf

# initramfs
mkinitcpio -P

# Install display manager
pacman -S --noconfirm xorg xorg-apps xorg-xinit xorg-twm xorg-xclock xterm xorg-xwayland

# Install desktop environment
pacman -S --noconfirm plasma plasma-meta plasma-wayland-session konsole networkmanager ufw dolphin

# Enable services
systemctl enable sddm.service
systemctl enable NetworkManager.service
systemctl enable ufw.service

# Prompt user to reboot
cat <<EOF
#########################################
Installation complete

1. Enter arch-chroot /mnt
2. Set root a password
3. Set user a password
4. unmount -a

Reboot to complete installation
#########################################
EOF
