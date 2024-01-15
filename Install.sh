#!/bin/bash -e

# Variables
# mirrorlist="https://archlinux.org/mirrorlist/?country=CA&protocol=https&ip_version=4&ip_version=6"
chrootscript="https://raw.githubusercontent.com/JerimiahOfficial/ArchPack/main/Chroot.sh"
finalscript="https://raw.githubusercontent.com/JerimiahOfficial/ArchPack/main/Final.sh"

# Creating partitions using parted
# Check if the device is a NVMe device
if [ -e /dev/nvme0n1 ]; then
  # NVMe device
  parted -s /dev/nvme0n1 \
    mklabel gpt \
    mkpart primary fat32 0% 513MiB \
    set 1 esp on \
    mkpart primary linux-swap 513MiB 65GiB \
    mkpart primary ext4 65GiB 100%
  
  # Creating filesystems
  mkfs.fat -F32 /dev/nvme0n1p1
  mkswap /dev/nvme0n1p2
  swapon /dev/nvme0n1p2
  mkfs.ext4 /dev/nvme0n1p3

  # Mounting partitions
  mount /dev/nvme0n1p3 /mnt
  mkdir /mnt/boot
  mkdir /mnt/home
  mount /dev/nvme0n1p1 /mnt/boot
else
  # SATA device
  parted -s /dev/sda \
    mklabel gpt \
    mkpart primary fat32 0% 513MiB \
    set 1 esp on \
    mkpart primary linux-swap 513MiB 65GiB \
    mkpart primary ext4 65GiB 100%
  
  # Creating filesystems
  mkfs.fat -F32 /dev/sda1
  mkswap /dev/sda2
  swapon /dev/sda2
  mkfs.ext4 /dev/sda3

  # Mounting partitions
  mount /dev/sda3 /mnt
  mkdir /mnt/boot
  mkdir /mnt/home
  mount /dev/sda1 /mnt/boot
fi

# Installing base system
pacstrap -K /mnt base base-devel linux linux-firmware linux-headers nano sudo networkmanager --noconfirm --needed

# Generating fstab
genfstab -U -p /mnt >/mnt/etc/fstab

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
