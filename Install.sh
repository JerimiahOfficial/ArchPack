#!/bin/bash -e

# Variables
mirrorlist="https://archlinux.org/mirrorlist/?country=CA&protocol=https&ip_version=4&ip_version=6"
chrootscript="https://raw.githubusercontent.com/JerimiahOfficial/ArchPack/main/Chroot.sh"
finalscript="https://raw.githubusercontent.com/JerimiahOfficial/ArchPack/main/Final.sh"

# Sync the system clock
timedatectl set-ntp true

# Enable parallel downloads
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# Update Archlinux key rings
pacman -S --noconfirm archlinux-keyring

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
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/sda1 /mnt/boot

# Fetch mirrorlist
curl -s $mirrorlist >/etc/pacman.d/mirrorlist
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist
cat /etc/pacman.d/mirrorlist >/mnt/etc/pacman.d/mirrorlist

# Installing base system
pacstrap -K /mnt base base-devel linux linux-firmware linux-headers nano sudo archlinux-keyring --noconfirm --needed

echo "keyserver hkp://keyserver.ubuntu.com" >>/mnt/etc/pacman.d/gnupg/gpg.conf

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

# Sleep for 5 seconds
Sleep 5

# Reboot the system
reboot
