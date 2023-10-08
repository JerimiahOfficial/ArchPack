# !/bin/bash -e

# Sync the system clock
timedatectl

# Creating partitions using parted
# M.2
parted -s /dev/sda \
  mklabel gpt \
  mkpart "EFI system partition" fat32 1MiB 301MiB \
  set 1 esp on \
  mkpart "swap partition" linux-swap 301MiB 4.3GiB \
  mkpart "root partition" ext4 4.3GiB 100%

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

# Installing base system
pacstrap /mnt base base-devel linux linux-firmware grub efibootmgr sudo networkmanager vim git intel-ucode

# Generating fstab
genfstab -U -p /mnt >>/mnt/etc/fstab

# Add permanent mounts to fstab
echo "/dev/sda1 /boot vfat defaults 0 2" >>/mnt/etc/fstab
echo "/dev/sda2 none swap defaults 0 2" >>/mnt/etc/fstab
echo "/dev/sda3 / ext4 defaults 0 2" >>/mnt/etc/fstab

# Chroot
arch-chroot /mnt bash <(curl -s https://raw.githubusercontent.com/JerimiahOfficial/ArchPack/main/Chroot.sh)

# unmount all
# umount -R /mnt

# Reboot
echo "########################################"
echo "Please reboot"
echo "umount -R /mnt"
echo "########################################"
