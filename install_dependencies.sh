#!/bin/bash

# Ensure the script is run with sudo
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script as root (use sudo)." 
   exit 1
fi

# Update package lists
echo "Updating package lists..."
apt update -y

# Install the specified packages
echo "Installing required packages..."
apt install -y \
    xorg xbacklight xbindkeys xvkbd xinput build-essential bspwm sxhkd polybar \
    network-manager network-manager-gnome pamixer thunar thunar-archive-plugin \
    thunar-volman file-roller lxappearance dialog mtools dosfstools avahi-daemon \
    acpi acpid gvfs-backends xfce4-power-manager pavucontrol pamixer pulsemixer \
    feh fonts-recommended fonts-font-awesome fonts-terminus \
    papirus-icon-theme exa flameshot qimgv rofi dunst libnotify-bin xdotool unzip \
    libnotify-dev geany geany-plugin-addons geany-plugin-git-changebar \
    geany-plugin-spellcheck geany-plugin-treebrowser geany-plugin-markdown \
    geany-plugin-insertnum geany-plugin-lineoperations geany-plugin-automark \
    pipewire-audio \
    nala micro xdg-user-dirs-gtk tilix \
    --install-recommends arctica-greeter

# Check if installation was successful
if [[ $? -eq 0 ]]; then
    echo "All packages installed successfully!"
else
    echo "Some packages failed to install. Please check for errors."
fi