# !/bin/bash -e
# Sync the system clock
timedatectl

# Creating partitions using parted
# M.2
parted /dev/sda mklabel gpt
parted /dev/sda mkpart primary fat32 1MiB 512MiB
parted /dev/sda mkpart primary linux-swap 512MiB 1GiB
parted /dev/sda mkpart primary ext4 1GiB 100%

# 4 TB
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
chroot /mnt bash <(curl -s https://raw.githubusercontent.com/JerimiahOfficial/ArchPack/main/Chroot.sh)

# unmount all
umount -R /mnt

# Reboot
reboot
