#!/bin/bash -e

# Timezone
timedatectl set-timezone America/Toronto

# Localization
echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" >>/etc/locale.conf
export LANG=en_US.UTF-8

# localectl set-locale LANGUAGE=en_US.UTF-8
# localectl set-locale LC_ALL=en_US.UTF-8
# localectl set-locale LANG=en_US.UTF-8
# localectl set-locale en_US.UTF-8

# Network configuration
echo "archlinux" >>/etc/hostname

# Enable services
systemctl enable NetworkManager
systemctl enable fstrim.timer

# Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Syu
pacman -S grub efibootmgr sudo

# initramfs
mkinitcpio -P

# Allow wheel group to use sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Add user
useradd -m -g users -G wheel,storage,power -s /bin/bash -p '1234' jerimiah

# Bootloader
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi

# make grub config
grub-mkconfig -o /boot/grub/grub.cfg

# Exit chroot
exit
