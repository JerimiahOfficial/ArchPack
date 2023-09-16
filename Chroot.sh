# !/bin/bash
set -e

# Localization
echo "en_US.UTF-8 UTF-8" >/etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf
export LANG=en_US.UTF-8
# echo "KEYMAP=us" >>/etc/vconsole.conf

# Timezone
ln -s /usr/share/zoneinfo/Canada/Eastern >/etc/localtime
hwclock --systohc --utc

# Network configuration
echo "archlinux" >>/etc/hostname

# Enable trim support
systemctl enable fstrim.timer

# Enable multilib
sed -i '45,46 s/^#//' /etc/pacman.conf
pacman -Sy

# initramfs
mkinitcpio -P

# Allow wheel group to use sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Root password
echo "root" | passwd

# Add user
useradd -m -g users -G wheel,storage,power -s /bin/bash jerimiah
echo "1234" | passwd jerimiah

# Bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# make grub config
grub-mkconfig -o /boot/grub/grub.cfg
