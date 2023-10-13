# !/bin/bash -e

# Timezone
ln -s /usr/share/zoneinfo/Canada/Eastern >/etc/localtime
hwclock --systohc --utc

# Localization
echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen
echo "LANG=en_US.UTF-8" >>/etc/locale.conf
echo "KEYMAP=us" >>/etc/vconsole.conf

locale-gen

# Network configuration
echo "archlinux" >>/etc/hostname

# Enable services
systemctl enable NetworkManager
systemctl enable fstrim.timer

# Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy

# initramfs
mkinitcpio -P

# Allow wheel group to use sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Add user
useradd -m -g users -G wheel,storage,power -s /bin/bash -p '1234' jerimiah

# Bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# make grub config
grub-mkconfig -o /boot/grub/grub.cfg

# Exit chroot
exit
