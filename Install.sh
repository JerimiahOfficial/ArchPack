#!/bin/bash -e

chrootscript="https://raw.githubusercontent.com/JerimiahOfficial/ArchPack/main/Chroot.sh"
finalscript="https://raw.githubusercontent.com/JerimiahOfficial/ArchPack/main/Final.sh"

if grep -q "hypervisor" /proc/cpuinfo; then
  # SATA device
  parted -s /dev/sda \
  mklabel gpt \
  mkpart primary fat32 0% 513MiB \
  set 1 esp on \
  mkpart primary linux-swap 513MiB 65GiB \
  mkpart primary ext4 65GiB 100%

  mkfs.fat -F32 /dev/sda1
  mkswap /dev/sda2
  swapon /dev/sda2
  mkfs.ext4 /dev/sda3

  mount /dev/sda3 /mnt
  mkdir /mnt/boot
  mkdir /mnt/home
  mount /dev/sda1 /mnt/boot
else
  parted -s /dev/nvme0n1 \
  mklabel gpt \
  mkpart primary fat32 0% 513MiB \
  set 1 esp on \
  mkpart primary linux-swap 513MiB 65GiB \
  mkpart primary ext4 65GiB 100%

  mkfs.fat -F32 /dev/nvme0n1p1
  mkswap /dev/nvme0n1p2
  swapon /dev/nvme0n1p2
  mkfs.ext4 /dev/nvme0n1p3

  mount /dev/nvme0n1p3 /mnt
  mkdir /mnt/boot
  mkdir /mnt/home
  mount /dev/nvme0n1p1 /mnt/boot
fi

pacstrap -K /mnt base base-devel linux linux-firmware linux-headers nano sudo network-manager-applet intel-ucode --noconfirm --needed

genfstab -U -p /mnt >/mnt/etc/fstab

curl -s $chrootscript >/mnt/Chroot.sh
curl -s $finalscript >/mnt/Final.sh
chmod +x /mnt/Chroot.sh
chmod +x /mnt/Final.sh

arch-chroot /mnt /bin/bash /Chroot.sh

rm /mnt/Chroot.sh

umount -R /mnt

reboot
