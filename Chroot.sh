# Clear and print
clear
echo "=====| Chroot |====="

# Timezone
ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
hwclock --systohc

# Localization
echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >>/etc/locale.conf
echo "KEYMAP=de-latin1" >>/etc/vconsole.conf

# Network configuration
echo "jerimiah" >>/etc/hostname

# initramfs
mkinitcpio -P

# Root password
passwd root

# Allow wheel group to use sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Add user
useradd jerimiah -m -G wheel,optical,disk,storage
passwd jerimiah 1234

# install microcode for intel
pacman -S intel-ucode

# Bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# make grub config
grub-mkconfig -o /boot/grub/grub.cfg
