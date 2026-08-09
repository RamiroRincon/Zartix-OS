# Start with the official Artix Linux base image
FROM artixlinux/artixlinux:latest

# 1. Update system and install the absolute core utilities & runit (our init system)
RUN pacman -Syu --noconfirm && \
    yes | pacman -S mkinitcpio base linux linux-firmware runit elogind-runit \
    nano sudo curl wget networkmanager networkmanager-runit

# 2. Enable 32-bit repositories (Mandatory for Steam)
RUN echo -e "\n[lib32]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf && \
    pacman -Sy --noconfirm

# 3. Install KDE Plasma Desktop, Audio, and Gaming tools
RUN pacman -S --noconfirm plasma-desktop wayland sddm sddm-runit \
    pipewire pipewire-pulse pipewire-alsa wireplumber pipewire-jack \
    steam gamescope mesa lib32-mesa flatpak \
    noto-fonts-emoji qt6-multimedia-ffmpeg xorg-server xorg-xwayland \
    vulkan-radeon lib32-vulkan-radeon

# 4. OSTree Immutability Magic 
# OSTree requires the root folder to be read-only. 
# We must move mutable folders (like /home) to /var, and create symlinks.
RUN mkdir -p /var/home /var/opt /var/srv /var/roothome /var/usrlocal && \
    rm -rf /home /opt /srv /root && \
    ln -s /var/home /home && \
    ln -s /var/opt /opt && \
    ln -s /var/srv /srv && \
    ln -s /var/roothome /root && \
    ln -s /var/usrlocal /usr/local

# 5. Enable default services to start on boot
RUN ln -s /etc/runit/sv/NetworkManager /etc/runit/runsvdir/default/ && \
    ln -s /etc/runit/sv/sddm /etc/runit/runsvdir/default/

# 6. Generate standard US English locales (you can change this later)
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
