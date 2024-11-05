#!/bin/bash

# Check if DBeaver is already installed
if apt-cache policy dbeaver-ce | grep -q "100 /var/lib/dpkg/status"; then
    echo "dbeaver-ce is already installed"
    exit 0
else
    echo "Installing dbeaver-ce"
fi

# Check if current system is Debian based (Debian, Ubuntu) or RPM based (Fedora, RHEL)
if cat /etc/os-release | grep -qe "ID=debian" -e "ID=Ubuntu"; then
    echo "Installing on Debian based distribution"
    
    # Download and Verify GPG keys from Dbeaver
    sudo wget -O /usr/share/keyrings/dbeaver.gpg.key https://dbeaver.io/debs/dbeaver.gpg.key

    # Add apt repository for updates
    echo "deb [signed-by=/usr/share/keyrings/dbeaver.gpg.key] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list

    # Update package lists and Install Dbeaver
    sudo apt update && sudo apt install dbeaver-ce -y

    # Verify Installation
    if apt-cache policy dbeaver-ce | grep -q "100 /var/lib/dpkg/status"; then
        echo "dbeaver-ce installed successfully"
    else
        echo "dbeaver-ce installation failed"
    fi

    # Remove existing desktop file, if present
    echo "Checking if dbeaver-ce.desktop is already present"
    if [ -f /usr/share/applications/dbeaver-ce.desktop ]; then
        echo "/usr/share/applications/dbeaver-ce.desktop is already present"
        echo "Removing /usr/share/applications/dbeaver-ce.desktop"
        
        sudo rm /usr/share/applications/dbeaver-ce.desktop

        if [ -f /usr/share/applications/dbeaver-ce.desktop ]; then
            echo "/usr/share/applications/dbeaver-ce.desktop was not removed"
            exit 1
        else
            echo "/usr/share/applications/dbeaver-ce.desktop was removed successfully"
        fi

    elif [ -f ~/.local/share/applications/dbeaver-ce.desktop ]; then
        echo "~/.local/share/applications/dbeaver-ce.desktop is already present"
        echo "Removing ~/.local/share/applications/dbeaver-ce.desktop"

        rm ~/.local/share/applications/dbeaver-ce.desktop

        if [ -f ~/.local/share/applications/dbeaver-ce.desktop ]; then
            echo "~/.local/share/applications/dbeaver-ce.desktop was not removed"
        else
            echo "~/.local/share/applications/dbeaver-ce.desktop was removed successfully"
        fi
    
    else
        echo "dbeaver-ce.desktop is not already present"
    fi

    # Add dbeaver-ce.desktop file to /usr/share/applications so it can be read and added to Launcher
    sudo cp ./files/dbeaver-ce.desktop /usr/share/applications

    # Modify the file permissions of /usr/share/applications/dbeaver-ce.desktop
    sudo chmod 644 /usr/share/applications/dbeaver-ce.desktop

    # Verify that desktop entry is present in applications
    if [ -f /usr/share/applications/dbeaver-ce.desktop ]; then
        echo "Dbeaver desktop entry updated"
        exit 0
    else
        echo "Dbeaver desktop entry not updated"
        exit 1
    fi



