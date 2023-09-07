#!/bin/bash

# Time Zone Settings
timedatectl set-timezone Africa/Lagos


# Default Date Format
echo "d_fmt \"+%A %B %d, %Y\"" >> /etc/locale.conf


# Update System
sudo apt update -y && sudo apt upgrade -y


# Install network tools
sudo apt install -y nmap net-tools


# Admin User to run sudo commands without password
echo -e "\n\n# User Nezie to run sudo commands without password prompt" >> /etc/sudoers
echo "Nezie   ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


# Configure VM to show date and time for history
echo -e "\n# Show date and time for history command" >> /etc/bash.bashrc
echo "HISTTIMEFORMAT=\"%d-%m-%y %T  \"" >> /etc/bash.bashrc


# Alias for timedatectl command
echo -e "\n# Alias for timedatectl command" >> /etc/bash.bashrc
echo "alias now='timedatectl'" >> /etc/bash.bashrc



# Configure Line number in Vim
#echo -e "\n#Set Line Number in Vim" >> /etc/vim/vimrc
#echo "set number" >> /etc/vim/vimrc



