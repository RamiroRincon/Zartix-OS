#!/usr/bin/env bash
iso_name="zartix-installer"
iso_label="ZARTIX_LIVE"
iso_publisher="ZArtix OS"
iso_application="ZArtix Installer Live/Rescue"
iso_version="latest"
install_dir="artix"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-b' '1M')
