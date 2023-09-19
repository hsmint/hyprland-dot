#!/bin/bash

# Define variables
GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"
YELLOW="$(tput setaf 3)[NOTE]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
LOG="install.log"

# Set the script to exit on error
set -e

printf "$(tput setaf 2) Welcome to the Arch Linux YAY Hyprland installer!\n $(tput sgr0)"

### Disable wifi powersave mode ###
read -n1 -rep 'Would you like to disable wifi powersave? (y,n)' WIFI
if [[ $WIFI == "Y" || $WIFI == "y" ]]; then
    LOC="/etc/NetworkManager/conf.d/wifi-powersave.conf"
    echo -e "The following has been added to $LOC.\n"
    echo -e "[connection]\nwifi.powersave = 2" | sudo tee -a $LOC
    echo -e "\n"
    echo -e "Restarting NetworkManager service...\n"
    sudo systemctl restart NetworkManager
    sleep 3
fi

#Check yay is installed
ISyay=/sbin/yay

if [ -f "$ISyay" ]; then
    printf "\n%s - yay was located, moving on.\n" "$GREEN"
else
    printf "\n%s - yay was NOT located\n" "$YELLOW"
    read -n1 -rep "${CAT} Would you like to install yay (y,n)" INST
    if [[ $INST =~ ^[Yy]$ ]]; then
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm 2>&1 | tee -a $LOG
        cd ..
    else
        printf "%s - yay is required for this script, now exiting\n" "$RED"
        exit
    fi
    printf "${YELLOW} System Update to avoid issue\n"
    yay -Syu --noconfirm 2>&1 | tee -a $LOG
fi

# Function to print error messages
print_error() {
    printf " %s%s\n" "$RED" "$1" "$NC" >&2
}

# Function to print success messages
print_success() {
    printf "%s%s%s\n" "$GREEN" "$1" "$NC"
}

### Install packages ####
read -n1 -rep "${CAT} Would you like to install the packages? (y/n)" inst
echo

if [[ $inst =~ ^[Nn]$ ]]; then
    printf "${YELLOW} No packages installed. Goodbye! \n"
    exit 1
fi

if [[ $inst =~ ^[Yy]$ ]]; then
    hypr_pkgs="hyprland-git wl-clipboard wf-recorder rofi wlogout swaylock-effects dunst swaybg kitty waybar-hyprland-git"
    font_pkgs="ttf-jetbrains-mono-nerd ttf-icomoon-feather noto-fonts-emoji ttf-font-awesome"
    audio_pkgs="pulseaudio pulseaudio-alsa pamixer playerctl"
    app_pkgs="nwg-look qt5ct ffmpegthumbs btop mousepad python-requests"
    bluetooth_pkgs="bluez bluez-utils"
    laptop_pkgs="brightnessctl"
    file_managers_pkgs="thunar lxappearance xfce4-settings xdg-desktop-portal-hyprland"
    theme_pkgs="rofi-emoji dracula-gtk-theme dracula-icons-git nordic-theme papirus-icon-theme starship"

    read -n1 -rep "${CAT} Would you like to install hyperland packages(Necessary)? (y/n)" hypr
    echo
    if [[ $hypr =~ ^[Nn]$ ]]; then
        if ! yay -S --noconfirm $hypr_pkgs  2>&1 | tee -a $LOG; then
            print_error " Failed to install additional packages - please check the install.log \n"
            exit 1
        fi
    fi

    read -n1 -rep "${CAT} Would you like to install font packages? (y/n)" fonts
    echo
    if [[ $fonts =~ ^[Nn]$ ]]; then
        if ! yay -S --noconfirm $font_pkgs  2>&1 | tee -a $LOG; then
            print_error " Failed to install additional packages - please check the install.log \n"
            exit 1
        fi
    fi

    read -n1 -rep "${CAT} Would you like to install audio packages? (y/n)" audio
    echo
    if [[ $audio =~ ^[Nn]$ ]]; then
        if ! yay -S --noconfirm $audio_pkgs  2>&1 | tee -a $LOG; then
            print_error " Failed to install additional packages - please check the install.log \n"
            exit 1
        fi
    fi

    read -n1 -rep "${CAT} Would you like to install app packages? (y/n)" app
    echo
    if [[ $app =~ ^[Nn]$ ]]; then
        if ! yay -S --noconfirm $app_pkgs  2>&1 | tee -a $LOG; then
            print_error " Failed to install additional packages - please check the install.log \n"
            exit 1
        fi
    fi

    read -n1 -rep "${CAT} Would you like to install bluetooth packages? (y/n)" bluetooth
    echo
    if [[ $bluetooth =~ ^[Nn]$ ]]; then
        if ! yay -S --noconfirm $bluetooth_pkgs  2>&1 | tee -a $LOG; then
            print_error " Failed to install additional packages - please check the install.log \n"
            exit 1
        fi
    fi

    read -n1 -rep "${CAT} Would you like to install laptop packages? (y/n)" laptop
    echo
    if [[ $laptop =~ ^[Nn]$ ]]; then
        if ! yay -S --noconfirm $laptop_pkgs  2>&1 | tee -a $LOG; then
            print_error " Failed to install additional packages - please check the install.log \n"
            exit 1
        fi
    fi

    read -n1 -rep "${CAT} Would you like to install laptop packages? (y/n)" file_manager
    echo
    if [[ $file_manager =~ ^[Nn]$ ]]; then
        if ! yay -S --noconfirm $file_managers_pkgs  2>&1 | tee -a $LOG; then
            print_error " Failed to install additional packages - please check the install.log \n"
            exit 1
        fi
    fi

    read -n1 -rep "${CAT} Would you like to install theme packages? (y/n)" theme
    echo
    if [[ $theme =~ ^[Nn]$ ]]; then
        if ! yay -S --noconfirm $theme_pkgs  2>&1 | tee -a $LOG; then
            print_error " Failed to install additional packages - please check the install.log \n"
            exit 1
        fi
    fi

    echo
    print_success "Package are succussfully installed!"
else
    echo
    print_error " Packages not installed - please check the install.log"
    sleep 1
fi

# BLUETOOTH
read -n1 -rep "${CAT} OPTIONAL - Would you like to start bluetooth? (y/n)" BLUETOOTH
if [[ $BLUETOOTH =~ ^[Yy]$ ]]; then
    printf " Activating Bluetooth Services...\n"
    sudo systemctl enable --now bluetooth.service
    sleep 2
fi

### Script is done ###
printf "\n${GREEN} Installation Completed.\n"
