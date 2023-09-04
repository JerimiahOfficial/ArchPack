# !/bin/bash -e
# ArchPack
# This is a simple script to install Arch Linux for my personal computer.
# It will not work on all systems, it installs all the packages I use.

# Sync the system clock
timedatectl

# Creating partitions using parted
# M.2
sudo parted /dev/sda mklabel gpt
sudo parted /dev/sda mkpart primary fat32 1MiB 512MiB
sudo parted /dev/sda mkpart primary linux-swap 512MiB 1GiB
sudo parted /dev/sda mkpart primary ext4 1GiB 100%

# 4 TB
# FileSystem: ext4
# MountPoint: /mnt
# Type: Linux
# Size: 100%
# sudo parted /dev/sdb mklabel gpt
# sudo parted /dev/sdb mkpart primary ext4 1MiB 100%

# Formatting partitions
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3

# Mounting partitions
mount --mkdir /dev/sda1 /mnt/boot
swapon /dev/sda2
mount --mkdir /dev/sda3 /mnt

# Installing base system
pacstrap /mnt base base-devel linux linux-firmware grub efibootmgr sudo networkmanager vim git

# Generating fstab
genfstab -U /mnt >>/mnt/etc/fstab

# Chroot
arch-chroot /mnt

# Timezone
ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
hwclock --systohc

# Localization
locale-gen
echo "LANG=en_US.UTF-8" >>/etc/locale.conf
echo "KEYMAP=de-latin1" >>/etc/vconsole.conf

# Network configuration
echo "jerimiah" >>/etc/hostname

# initramfs
mkinitcpio -P

# Root password
passwd root

# Add user
useradd jerimiah -m -G wheel,optical,disk,storage

# Bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Reboot
reboot
