#!/bin/bash
# Install Docker
sudo apt install docker.io -y
# Create a Docker user
sudo usermod -aG docker Nezie


# Install Wireshark and configure GUI non-interactively
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository universe
sudo apt update -y

#sudo DEBIAN_FRONTEND=noninteractive apt install wireshark -y

# Create the wireshark group and add the user 'Nezie' to it
#sudo groupadd wireshark
#sudo usermod -aG wireshark Nezie

# Install the GUI components and configure GUI non-interactively
sudo DEBIAN_FRONTEND=noninteractive apt install ubuntu-desktop xrdp -y

# Set the default target to graphical
sudo systemctl set-default graphical.target

# Start the xrdp service
sudo systemctl start xrdp

# Reboot the system
#sudo reboot

# Wait for 60 seconds to ensure the system is fully booted
sleep 60

