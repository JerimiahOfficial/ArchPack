#!/bin/bash -e

if [ "$EUID" -eq 0 ]; then
  echo "Please run as normal user"
  exit
fi

UUID=$(id -u)
GUID=$(id -g)

cd ~
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $UUID:$GUID yay
(cd yay && makepkg -si --noconfirm)

yay -Syu --noconfirm
yay -S --noconfirm librewolf-bin modrinth-app-bin portmaster-stub-bin vesktop-bin visual-studio-code-bin

sudo rm /Final.sh
