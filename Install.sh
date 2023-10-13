#!/bin/bash -e

# Variables
mirrorlist="https://archlinux.org/mirrorlist/?country=CA&protocol=https&ip_version=4&ip_version=6"
chrootscript="https://raw.githubusercontent.com/JerimiahOfficial/ArchPack/main/Chroot.sh"

# Sync the system clock
timedatectl

# Creating partitions using parted
# M.2
parted -s /dev/sda \
  mklabel gpt \
  mkpart primary fat32 0% 513MiB \
  set 1 esp on \
  mkpart primary linux-swap 513MiB 65GiB \
  mkpart primary ext4 65GiB 100%

# 4 TB
# parted /dev/sdb mklabel gpt \
#   mkpart primary ext4 0% 100%

# Creating filesystems
mkfs.ext4 /dev/sda3
mkswap /dev/sda2
mkfs.fat -F32 /dev/sda1

# Mounting partitions
mount /dev/sda3 /mnt
swapon /dev/sda2
mkdir -p /mnt/boot/efi
mount --mkdir /dev/sda1 /mnt/boot/efi

# Get mirror list
curl -s $mirrorlist >/etc/pacman.d/mirrorlist
awk 'NR<=12 {sub(/^#Server/, "Server")} 1' /etc/pacman.d/mirrorlist >temp && mv temp /etc/pacman.d/mirrorlist
pacman -Syy

# Installing base system
pacstrap -K /mnt base linux linux-firmware

# Generating fstab
genfstab -U -p /mnt >>/mnt/etc/fstab

# Download chroot script
curl -s $chrootscript >/mnt/Chroot.sh
chmod +x /mnt/Chroot.sh

# Chroot
arch-chroot /mnt /bin/bash /Chroot.sh
