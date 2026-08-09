#!/bin/bash
# ZArtix Installer
if [[ $EUID -ne 0 ]]; then echo "Must run as root (use sudo)"; exit 1; fi

echo "Preparing installer tools..."
# Changed arch-install-scripts to artix-install-scripts
pacman -Sy --noconfirm zenity podman artix-install-scripts gptfdisk

# 1. UI: Select Disk
DISK=$(lsblk -dno NAME,SIZE,TYPE | grep disk | zenity --list --title="ZArtix Installer" --text="Select disk to install (WARNING: ERASES ALL DATA):" --column="Disk" --column="Size" --column="Type" --width=400 --height=300 | awk '{print "/dev/"$1}')
[[ -z "$DISK" ]] && exit 1

# 2. Partitioning the selected disk
echo "Partitioning $DISK..."
sgdisk -Z $DISK
sgdisk -n 1:0:+512M -t 1:ef00 $DISK 
sgdisk -n 2:0:0 -t 2:8300 $DISK     

# 3. Formatting
echo "Formatting partitions..."
mkfs.vfat -F 32 "${DISK}1"
mkfs.ext4 -F "${DISK}2"

# 4. Mounting
echo "Mounting drives..."
mount "${DISK}2" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot

# 5. Download your custom OS from GitHub
echo "Downloading your OS from the cloud..."
podman pull ghcr.io/ramirorincon/zartix-os:latest

# 6. Extract the OS to the drive
echo "Installing OS to disk (this will take a moment)..."
podman create --name zartix_extract ghcr.io/ramirorincon/zartix-os:latest
podman export zartix_extract | tar -xf - -C /mnt/
podman rm zartix_extract

# 7. Setup Bootloader
echo "Setting up bootloader..."
# Changed arch-chroot to artix-chroot
artix-chroot /mnt pacman -S --noconfirm grub efibootmgr
artix-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable
artix-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

zenity --info --text="Installation Complete! You can now reboot."
