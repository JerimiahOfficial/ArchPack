# !/bin/bash -e

# Timezone
ln -s /usr/share/zoneinfo/Canada/Eastern >/etc/localtime
hwclock --systohc --utc

# Localization
echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen
echo "KEYMAP=us" >>/etc/vconsole.conf

# localectl set-locale LANGUAGE=en_US.UTF-8
# localectl set-locale LC_ALL=en_US.UTF-8
# localectl set-locale LANG=en_US.UTF-8
# localectl set-locale en_US.UTF-8

# export LANG=en_US.UTF-8
# export LANGUAGE=en_US.UTF-8
# export LC_ALL=en_US.UTF-8
# export LC_MESSAGES=en_US.UTF-8

locale-gen

# cat /etc/locale.gen >>/mnt/etc/locale.gen
# cat /etc/locale.conf >>/mnt/etc/locale.conf
# cat /etc/vconsole.conf >>/mnt/etc/vconsole.conf

echo "######################"
echo "Localization:"
locale -a
echo "######################"

# Network configuration
echo "archlinux" >>/etc/hostname

# Enable trim support
systemctl enable fstrim.timer

# Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
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
