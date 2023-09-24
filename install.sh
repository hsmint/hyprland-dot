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
    if ! yay -S --noconfirm sdbus-cpp 2>&1 | tee -a $LOG; then
        print_error " Failed to install additional packages - please check the install.log \n"
        exit 1
    fi

    hypr_pkgs="hyprland-git kitty waybar-git swaybg wl-clipboard wf-recorder rofi wlogout swaylock-effects dunst python-requests cliphists polkit-kde-agent xdg-desktop-portal-hyprland-git qt5-wayland qt6-wayland"
    font_pkgs="ttf-jetbrains-mono-nerd ttf-font-awesome ttf-icomoon-feather noto-fonts-emoji"
    audio_pkgs="pulseaudio pulseaudio-alsa pamixer playerctl pavucontrol"
    app_pkgs="neofetch firefox viewnior code code-features code-marketplace"
    bluetooth_pkgs="bluez bluez-utils"
    laptop_pkgs="brightnessctl"
    file_managers_pkgs="thunar thunar-archive-plugin nwg-look"
    theme_pkgs="rofi-emoji dracula-gtk-theme dracula-icons-git nordic-theme papirus-icon-theme starship"

    if ! yay -S --noconfirm $hypr_pkgs $font_pkgs $audio_pkgs $app_pkgs $bluetooth_pkgs $laptop_pkgs $file_managers_pkgs $theme_pkgs 2>&1 | tee -a $LOG; then
        print_error " Failed to install additional packages - please check the install.log \n"
        exit 1
    fi

    echo
    print_success "Package are succussfully installed!"
else
    echo
    print_error " Packages not installed - please check the install.log"
    sleep 1
fi

if ! yay -S --noconfirm wget unzip 2>&1 | tee -a $LOG; then
    print_error " Failed to install additional packages - please check the install.log \n"
    exit 1
fi

## ADD SOME FONTS
mkdir -p $HOME/Downloads/nerdfonts/
cd $HOME/Downloads/
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.1/CascadiaCode.zip
unzip '*.zip' -d $HOME/Downloads/nerdfonts/
rm -rf *.zip
sudo cp -R $HOME/Downloads/nerdfonts/ /usr/share/fonts/

# BLUETOOTH
read -n1 -rep "${CAT} OPTIONAL - Would you like to start bluetooth? (y/n)" BLUETOOTH
if [[ $BLUETOOTH =~ ^[Yy]$ ]]; then
    printf " Activating Bluetooth Services...\n"
    sudo systemctl enable --now bluetooth.service
    sleep 2
fi

### Copy Config Files ###
read -n1 -rep 'Would you like to copy config files? (y,n)' CFG
if [[ $CFG == "Y" || $CFG == "y" ]]; then
    echo -e "Copying config files...\n"
    cp -R $PWD/hypr ~/.config/
    cp -R $PWD/kitty ~/.config/
    cp -R $PWD/waybar ~/.config/
    cp -R $PWD/swaylock ~/.config/
    cp -R $PWD/rofi ~/.config/
    cp -R $PWD/dunst ~/.config/
    cp -R $PWD/wlogout ~/.config/
    cp -R $PWD/starship ~/.config/

    # Set some files as exacutable
    chmod +x ~/.config/waybar/scripts/waybar-wttr.py
fi

### Script is done ###
printf "\n${GREEN} Installation Completed.\n"
