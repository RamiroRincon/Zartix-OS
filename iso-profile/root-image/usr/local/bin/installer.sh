#!/bin/bash
# ZArtix Standalone GUI Installer

# 1. UI: Select Disk
DISK=$(lsblk -dno NAME,SIZE,TYPE | grep disk | zenity --list --title="ZArtix Setup" --text="Select the drive to install ZArtix.\n\n⚠️ WARNING: This will permanently erase ALL DATA on the selected drive." --column="Disk" --column="Size" --column="Type" --width=600 --height=400 | awk '{print "/dev/"$1}')
[[ -z "$DISK" ]] && exit 1

zenity --info --text="Installation will now begin in the background. Please wait." &

# 2. Partitioning
sgdisk -Z $DISK
sgdisk -n 1:0:+512M -t 1:ef00 $DISK 
sgdisk -n 2:0:0 -t 2:8300 $DISK     

# 3. Formatting & Mounting
mkfs.vfat -F 32 "${DISK}1"
mkfs.ext4 -F "${DISK}2"
mount "${DISK}2" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot

# 4. Download and Extract Cloud Image
podman pull ghcr.io/ramirorincon/zartix-os:latest
podman create --name zartix_extract ghcr.io/ramirorincon/zartix-os:latest
podman export zartix_extract | tar -xf - -C /mnt/
podman rm zartix_extract

# 5. Setup Bootloader
artix-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable
artix-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

zenity --info --title="Success" --text="Installation Complete!\n\nPlease remove the USB drive and restart your computer."
poweroff
