#!/bin/bash

# Check if Nemo File Manager is already installed
if apt-cache policy nemo | grep -q "100 /var/lib/dpkg/status"; then
    echo "Nemo File Manager is already installed"
else
    echo "Nemo File Manager is not installed"
    echo "Installing Nemo File Manager"
    # Install Nemo File Manager
    sudo apt install nemo -y
fi

# Verify Installation
if apt-cache policy nemo | grep -q "100 /var/lib/dpkg/status"; then
    echo "Nemo File Manager installed successfully"
else
    echo "Nemo File Manager installation failed"
    exit 1
fi

# Copy the nemo icon to /usr/share/icons directory
echo "Copying filemanager.png to /usr/share/icons"
sudo cp ./icons/filemanager.png /usr/share/icons

# Modify File permissions of /usr/share/applications/filemanager.png to make it accessible to Launcher
sudo chmod 644 /usr/share/icons/filemanager.png


# Remove the existing nemo.desktop file, if present
echo "Checking if nemo.desktop is already present in /usr/share/applications"

if [ -f /usr/share/applications/nemo.desktop ]; then
    echo "nemo.desktop is already present in /usr/share/applications"
    echo "Removing /usr/share/applications/nemo.desktop"
    sudo rm /usr/share/applications/nemo.desktop

    if [ -f /usr/share/applications/nemo.desktop ]; then
        echo "/usr/share/applications/nemo.desktop was not removed"
        exit 1
    else
        echo "/usr/share/applications/nemo.desktop was removed successfully"
    fi

elif [ -f ~/.local/share/applications/nemo.desktop ]; then
    echo "nemo.desktop is already present in ~/.local/share/applications"
    echo "Removing ~/.local/share/applications/nemo.desktop"
    rm ~/.local/share/applications/nemo.desktop

    if [ -f ~/.local/share/applications/nemo.desktop ]; then
        echo "~/.local/share/applications/nemo.desktop was not removed"
        exit 1
    else
        echo "~/.local/share/applications/nemo.desktop was removed successfully"
    fi
fi

# Add the nemo.desktop file to /usr/share/applications directory so that it can be read and added to Launcher
sudo cp ./files/nemo.desktop /usr/share/applications

# Modify File permissions of /usr/share/applications/nemo.desktop to make it accessible to Launcher
sudo chmod 644 /usr/share/applications/nemo.desktop

# Move the nemo.desktop file to refresh icon cache
sudo mv /usr/share/applications/nemo.desktop ~
sleep 5
sudo mv ~/nemo.desktop /usr/share/applications/ 

# Verify that .desktop file is present in applications directory
if [ -f /usr/share/applications/nemo.desktop ]; then
    echo "Nemo desktop file updated"
    exit 0
else
    echo "Nemo desktop file not updated"
    exit 1
fi




