# !/bin/bash -e

# Sync the system clock
timedatectl

# Creating partitions using parted
# M.2
parted -s /dev/sda \
  mklabel gpt \
  mkpart ESP fat32 0% 513MiB \
  set 1 boot on \
  set 1 esp on \
  mkpart primary linux-swap 513MiB 65GiB \
  mkpart primary ext4 65GiB 100%

# 4 TB
# parted /dev/sdb mklabel gpt \
#   mkpart primary ext4 0% 100%

# Formatting partitions
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3

# Mounting partitions
mount --mkdir /dev/sda1 /mnt/boot
swapon /dev/sda2
mount --mkdir /dev/sda3 /mnt

# Get mirror list
curl -s 'https://archlinux.org/mirrorlist/?country=CA&protocol=http&protocol=https&ip_version=4&ip_version=6' >/etc/pacman.d/mirrorlist
awk 'NR<=12 {sub(/^#Server/, "Server")} 1' /etc/pacman.d/mirrorlist >/etc/pacman.d/mirrorlist
pacman -Syy

# Installing base system
pacstrap -K /mnt base linux linux-firmware

# Generating fstab
genfstab -U -p /mnt >>/mnt/etc/fstab

# Download chroot script
curl -s https://raw.githubusercontent.com/JerimiahOfficial/ArchPack/main/Chroot.sh >/mnt/Chroot.sh
chmod +x /mnt/Chroot.sh

# Chroot
arch-chroot /mnt /bin/bash /Chroot.sh

# unmount all
# umount -R /mnt

# Reboot
echo "########################################"
echo "Please reboot"
echo "umount -R /mnt"
echo "########################################"
