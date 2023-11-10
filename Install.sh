#!/bin/bash -e

# Variables
chrootscript="https://raw.githubusercontent.com/JerimiahOfficial/ArchPack/main/Chroot.sh"
finalscript="https://raw.githubusercontent.com/JerimiahOfficial/ArchPack/main/Final.sh"

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
if [ -b /dev/sdb ]; then
  parted -s /dev/sdb \
    mklabel gpt \
    mkpart primary ext4 0% 100%
fi

# Creating filesystems
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/sda3

# Mounting partitions
mount /dev/sda3 /mnt
mkdir -p /mnt/boot
mkdir -p /mnt/home
mount /dev/sda1 /mnt/boot

# Install ranked mirrors
pacman -S --noconfirm pacman-contrib

# Get mirror list
rankmirrors -n 6 /etc/pacman.d/mirrorlist >temp && mv temp /etc/pacman.d/mirrorlist

# Update pacman
pacman -Syu --noconfirm

# Installing base system
pacstrap -K /mnt base base-devel linux linux-firmware linux-headers

# Generating fstab
genfstab -U -p /mnt >>/mnt/etc/fstab

# Download chroot script
curl -s $chrootscript >/mnt/Chroot.sh
chmod +x /mnt/Chroot.sh

# Chroot
arch-chroot /mnt /bin/bash /Chroot.sh

# Download final script
curl -s $finalscript >/mnt/Final.sh
chmod +x /mnt/Final.sh

# Delete chroot script
rm /mnt/Chroot.sh
