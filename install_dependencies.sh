#!/bin/bash

# ========================================
# Script Banner and Intro
# ========================================
clear
echo "
 +-+-+-+-+-+-+-+-+-+-+-+-+-+ 
 |j|u|s|t|a|g|u|y|l|i|n|u|x| 
 +-+-+-+-+-+-+-+-+-+-+-+-+-+ 
 |b|s|p|w|m| | |s|c|r|i|p|t|  
 +-+-+-+-+-+-+-+-+-+-+-+-+-+                                                                            
"

CLONED_DIR="$HOME/bspwm-setup"
CONFIG_DIR="$HOME/.config/bspwm"
INSTALL_DIR="$HOME/installation"
GTK_THEME="https://github.com/vinceliuice/Orchis-theme.git"
ICON_THEME="https://github.com/vinceliuice/Colloid-icon-theme.git"

# ========================================
# User Confirmation Before Proceeding
# ========================================
echo "This script will install and configure bspwm on your Debian system."
read -p "Do you want to continue? (y/n) " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Installation aborted."
    exit 1
fi

sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get clean

# ========================================
# Initialization
# ========================================
mkdir -p "$INSTALL_DIR" || { echo "Failed to create installation directory."; exit 1; }

# Cleanup function
cleanup() {
    rm -rf "$INSTALL_DIR"
    echo "Installation directory removed."
}
trap cleanup EXIT

# ========================================
# Check for Existing BSPWM Configuration
# ========================================
check_bspwm() {
    if [ -d "$CONFIG_DIR" ]; then
        echo "An existing ~/.config/bspwm directory was found."
        read -p "Would you like to back it up before proceeding? (y/n) " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
            backup_dir="$HOME/.config/bspwm_backup_$timestamp"
            mv "$CONFIG_DIR" "$backup_dir"
            echo "Backup created at $backup_dir"
        else
            echo "Skipping backup. Your existing config will be overwritten."
        fi
    fi
}

# ========================================
# Move Config Files to ~/.config/bspwm
# ========================================
setup_bspwm_config() {
    echo "Moving configuration files..."
    mkdir -p "$CONFIG_DIR"
    cp -r "$CLONED_DIR/bspwmrc" "$CONFIG_DIR/" || echo "Warning: Failed to copy bspwmrc."
    for dir in dunst fonts picom polybar rofi scripts sxhkd wallpaper; do
        cp -r "$CLONED_DIR/$dir" "$CONFIG_DIR/" || echo "Warning: Failed to copy $dir."
    done
    echo "BSPWM configuration files copied successfully."
}

# ========================================
# Package Installation Section
# ========================================
# Install required packages (removed firefox-esr, geany and its plugins, nala, fastfetch, and wezterm)
install_packages() {
    echo "Installing required packages..."
    sudo apt-get install -y xorg xorg-dev xbacklight xbindkeys xvkbd xinput build-essential bspwm sxhkd polybar network-manager-gnome pamixer thunar thunar-archive-plugin thunar-volman lxappearance dialog mtools avahi-daemon acpi acpid gvfs-backends xfce4-power-manager pavucontrol pulsemixer feh fonts-recommended fonts-font-awesome fonts-terminus exa suckless-tools ranger redshift flameshot qimgv rofi dunst libnotify-bin xdotool unzip libnotify-dev pipewire-audio micro xdg-user-dirs-gtk tilix || echo "Warning: Package installation failed."
    echo "Package installation completed."
}

# ========================================
# Enabling Required Services
# ========================================
enable_services() {
    echo "Enabling required services..."
    sudo systemctl enable avahi-daemon || echo "Warning: Failed to enable avahi-daemon."
    sudo systemctl enable acpid || echo "Warning: Failed to enable acpid."
    echo "Services enabled."
}

# ========================================
# User Directory Setup
# ========================================
setup_user_dirs() {
    echo "Updating user directories..."
    xdg-user-dirs-update || echo "Warning: Failed to update user directories."
    mkdir -p ~/Screenshots/ || echo "Warning: Failed to create Screenshots directory."
    echo "User directories updated."
}

# ========================================
# Utility Functions
# ========================================
command_exists() {
    command -v "$1" &>/dev/null
}

install_reqs() {
    echo "Updating package lists and installing required dependencies..."
    sudo apt-get install -y meson ninja-build curl pkg-config || { echo "Package installation failed."; exit 1; }
}

# ========================================
# Picom Installation
# ========================================
install_ftlabs_picom() {
    if command_exists picom; then
        echo "Picom is already installed. Skipping installation."
        return
    fi
    sudo apt-get install -y libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev libxext-dev meson ninja-build uthash-dev

    git clone https://github.com/FT-Labs/picom "$INSTALL_DIR/picom" || { echo "Failed to clone Picom."; exit 1; }
    cd "$INSTALL_DIR/picom" || exit 1
    meson setup --buildtype=release build
    ninja -C build
    sudo ninja -C build install
}

# ========================================
# Font Installation
# ========================================
install_fonts() {
    echo "Installing fonts..."

    mkdir -p ~/.local/share/fonts

    fonts=( "FiraCode" "Hack" "JetBrainsMono" "RobotoMono" "SourceCodePro" "UbuntuMono" )

    for font in "${fonts[@]}"; do
        if ls ~/.local/share/fonts/$font/*.ttf &>/dev/null; then
            echo "Font $font is already installed. Skipping."
        else
            echo "Installing font: $font"
            wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/$font.zip" -P /tmp || {
                echo "Warning: Error downloading font $font."
                continue
            }
            unzip -q /tmp/$font.zip -d ~/.local/share/fonts/$font/ || {
                echo "Warning: Error extracting font $font."
                continue
            }
            rm /tmp/$font.zip
        fi
    done

    # Refresh font cache
    fc-cache -f || echo "Warning: Error rebuilding font cache."

    echo "Font installation completed."
}

# ========================================
# GTK Theme Installation
# ========================================
install_theming() {
    GTK_THEME_NAME="Orchis-Teal-Dark"
    ICON_THEME_NAME="Colloid-Teal-Everforest-Dark"

    if [ -d "$HOME/.themes/$GTK_THEME_NAME" ] || [ -d "$HOME/.icons/$ICON_THEME_NAME" ]; then
        echo "One or more themes/icons already installed. Skipping theming installation."
        return
    fi

    echo "Installing GTK and Icon themes..."

    # GTK Theme Installation
    git clone "$GTK_THEME" "$INSTALL_DIR/Orchis-theme" || { echo "Failed to clone Orchis theme."; exit 1; }
    cd "$INSTALL_DIR/Orchis-theme" || exit 1
    yes | ./install.sh -c dark -t teal orange --tweaks black

    # Icon Theme Installation
    git clone "$ICON_THEME" "$INSTALL_DIR/Colloid-icon-theme" || { echo "Failed to clone Colloid icon theme."; exit 1; }
    cd "$INSTALL_DIR/Colloid-icon-theme" || exit 1
    ./install.sh -t teal orange -s default gruvbox everforest

    echo "Theming installation complete."
}

# ========================================
# GTK Theme Settings
# ========================================
change_theming() {
    mkdir -p ~/.config/gtk-3.0

    cat << EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Orchis-Teal-Dark
gtk-icon-theme-name=Colloid-Teal-Everforest-Dark
gtk-font-name=Sans 10
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
EOF

    cat << EOF > ~/.gtkrc-2.0
gtk-theme-name="Orchis-Teal-Dark"
gtk-icon-theme-name="Colloid-Teal-Everforest-Dark"
gtk-font-name="Sans 10"
gtk-cursor-theme-name="Adwaita"
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintfull"
EOF

    echo "GTK settings updated."
}

# ========================================
# .bashrc Replacement Prompt
# ========================================
replace_bashrc() {
    echo "Would you like to overwrite your current .bashrc with the justaguylinux .bashrc? (y/n)"
    read response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        if [[ -f ~/.bashrc ]]; then
            mv ~/.bashrc ~/.bashrc.bak
            echo "Your current .bashrc has been moved to .bashrc.bak"
        fi
        wget -O ~/.bashrc https://raw.githubusercontent.com/drewgrif/jag_dots/main/.bashrc
        source ~/.bashrc
        if [[ $? -eq 0 ]]; then
            echo "justaguylinux .bashrc has been copied to ~/.bashrc"
        else
            echo "Failed to download justaguylinux .bashrc"
        fi
    elif [[ "$response" =~ ^[Nn]$ ]]; then
        echo "No changes have been made to ~/.bashrc"
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
}

# ========================================
# Minimal GDM3 Installation Section
# ========================================
# Function to check if a service is active and enabled
service_active_and_enabled() {
    local service="$1"
    sudo systemctl is-active --quiet "$service" && sudo systemctl is-enabled --quiet "$service"
}

# Check if GDM is installed and enabled
check_gdm() {
    service_active_and_enabled gdm
}

# Function to install and enable minimal GDM3
install_gdm() {
    echo "Installing minimal GDM3..."
    sudo apt update
    sudo apt install -y --no-install-recommends gdm3
    sudo systemctl enable gdm3
    echo "GDM3 has been installed and enabled."
}

# ========================================
# Main Script Execution
# ========================================
echo "Starting installation process..."

check_bspwm
setup_bspwm_config
install_packages
enable_services
setup_user_dirs
install_reqs
install_ftlabs_picom
install_fonts
install_theming
change_theming
replace_bashrc

# Minimal GDM3 installation check and install if not already enabled
if check_gdm; then
    echo "GDM3 is already installed and enabled."
else
    install_gdm
fi

echo "All installations completed successfully!"