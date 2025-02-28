#!/bin/bash

# Ensure the script is run with sudo or as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

echo "Updating package lists..."
apt update

echo "Installing required dependencies..."
apt install -y \
    build-essential cmake meson ninja-build git wget curl \
    libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev \
    libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev \
    libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev \
    libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev \
    libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev \
    libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev \
    libxcb-xfixes0-dev libxext-dev uthash-dev \
    libgtk-4-dev libadwaita-1-dev \
    pkg-config

# Check if the installation was successful
if [ $? -eq 0 ]; then
    echo "Installation completed successfully!"
else
    echo "Installation encountered errors. Check the output for details."
fi