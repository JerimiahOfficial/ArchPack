# !/bin/bash
set -e

# Clear and print
clear
echo "=====| Chroot |====="

# Timezone
ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
hwclock --systohc

# Localization
# sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
# Set env variables
# export LANGUAGE=en_US.UTF-8
# export LANG=en_US.UTF-8
# export LC_ALL=en_US.UTF-8
# LANGUAGE=en_US.UTF-8
# LANG=en_US.UTF-8
# LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
loadkeys us

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
