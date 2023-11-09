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

# Install desktop environment
pacman -S --noconfirm xorg xorg-xwayland plasma plasma-meta plasma-wayland-session konsole networkmanager ufw dolphin nvidia nvidia-utils lib32-nvidia-utils nvidia-settings

# Create nvidia hooks for pacman
# https://wiki.archlinux.org/title/NVIDIA#pacman_hook
cat <<EOF >/etc/pacman.d/hooks/nvidia.hook
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux

[Action]
Description=Update NVIDIA module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case \$trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF

# Enable nvidia for initial ramdisk
sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm) /' /etc/mkinitcpio.conf

# initramfs
mkinitcpio -P

# Allow wheel group to use sudo
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Create the user
useradd -U -m -g users -G wheel,storage,power -s /bin/bash jerimiah

# Bootloader
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi

# Add the following line to /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia-drm.modeset=1"/' /etc/default/grub

# make grub config
grub-mkconfig -o /boot/grub/grub.cfg

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
