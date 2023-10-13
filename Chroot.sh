#!/bin/bash -e

# Timezone
ln -sf /usr/share/zoneinfo/Canada/Eastern >/etc/localtime
hwclock --systohc --utc

# Localization
echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" >/etc/locale.conf
export LANG=en_US.UTF-8

# localectl set-locale LANGUAGE=en_US.UTF-8
# localectl set-locale LC_ALL=en_US.UTF-8
# localectl set-locale LANG=en_US.UTF-8
# localectl set-locale en_US.UTF-8

# Network configuration
echo "archlinux" >>/etc/hostname

# Enable fstrim
systemctl enable fstrim.timer

# Enable multilib
sed -i '/^\s*#\s*\[multilib\]/,/^#\s*Include = \/etc\/pacman.d\/mirrorlist/ s/#\s*//' /etc/pacman.conf
pacman -Syu
pacman -S --noconfirm grub efibootmgr sudo

# initramfs
mkinitcpio -P

# Allow wheel group to use sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Add user
useradd -m -g users -G wheel,storage,power -s /bin/bash jerimiah

# Bootloader
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi

# make grub config
grub-mkconfig -o /boot/grub/grub.cfg

# Install desktop environment
pacman -S --noconfirm xorg plasma plasma-wayland-session konsole networkmanager ufw dolphin lib32-nvidia-utils nvidia-settings nvidia-utils

# Enable services
systemctl enable sddm.service
systemctl enable NetworkManager.service
systemctl enable ufw.service

# Prompt user to reboot
echo "#########################################"
echo "Installation complete"
echo ""
echo "1. Enter arch-chroot /mnt"
echo "2. Set root a password"
echo "3. Set user a password"
echo "4. unmount -a"
echo ""
echo "Reboot to complete installation"
echo "#########################################"
