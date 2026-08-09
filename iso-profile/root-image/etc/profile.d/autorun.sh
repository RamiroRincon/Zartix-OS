#!/bin/bash
# Only run on the first virtual terminal (tty1) automatically at boot
if [ "$(tty)" = "/dev/tty1" ]; then
    echo "Starting ZArtix Installer..."
    # Launch 'cage' (a Wayland kiosk) and run the installer script inside it
    cage -s -- /usr/local/bin/installer.sh
fi
