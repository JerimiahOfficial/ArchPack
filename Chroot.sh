#!/bin/bash -e

ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
hwclock --systohc

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf
echo "KEYMAP=us" >/etc/vconsole.conf

echo "archlinux" >/etc/hostname
echo "root:123214" | chpasswd
useradd -m -G wheel -s /bin/bash jerimiah
echo "jerimiah:123214" | chpasswd
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

systemctl enable NetworkManager

mount -t efivarfs efivarfs /sys/firmware/efi/efivars
bootctl --path=/boot install

echo "default arch.conf" >/boot/loader/loader.conf
echo "timeout 4" >>/boot/loader/loader.conf

echo "title   Arch linux" >/boot/loader/entries/arch.conf
echo "linux   /vmlinuz-linux" >>/boot/loader/entries/arch.conf
echo "initrd  /intel-ucode.img" >>/boot/loader/entries/arch.conf
echo "initrd  /initramfs-linux.img" >>/boot/loader/entries/arch.conf

if grep -q "hypervisor" /proc/cpuinfo; then
  echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/sda3) zswap.enabled=0 rw rootfstype=ext4" >>/boot/loader/entries/arch.conf
else
  echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/nvme0n1p3) zswap.enabled=0 rw rootfstype=ext4" >>/boot/loader/entries/arch.conf
fi

sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

pacman -Syu --noconfirm
pacman -S --noconfirm nvidia nvidia-utils lib32-nvidia-utils nvidia-settings
pacman -S --noconfirm xorg-xinit wayland xorg-xwayland
pacman -S --noconfirm plasma-meta plasma-wayland-session konsole ufw dolphin
pacman -S --noconfirm git jre17-openjdk nodejs npm cmake vulkan-icd-loader lib32-vulkan-icd-loader
pacman -S --noconfirm bitwarden steam lutris vlc ark obs-studio kdenlive krita ktorrent gwenview

systemctl enable sddm.service
systemctl enable NetworkManager.service
systemctl enable ufw.service
