# !/bin/bash
set -e

# Clear and print
clear
echo "=====| Chroot |====="

# Timezone
ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
hwclock --systohc

# Localization
echo "en_US.UTF-8 UTF-8" >/etc/locale.gen
locale-gen
echo "LANGUAGE=en_US.UTF-8\nLANG=en_US.UTF-8\nLC_ALL=en_US.UTF-8" >/etc/locale.conf
echo "KEYMAP=us" >>/etc/vconsole.conf

# Network configuration
echo "jerimiah" >>/etc/hostname

# initramfs
mkinitcpio -P

# Allow wheel group to use sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Root password
echo "root" | passwd

# Add user
useradd jerimiah -m -G wheel,optical,disk,storage
echo "1234" | passwd jerimiah

# Bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# make grub config
grub-mkconfig -o /boot/grub/grub.cfg
