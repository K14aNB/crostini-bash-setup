#!/bin/bash

# Check if current system is Debian based (Debian, Ubuntu) or RPM based (Fedora, RHEL)
if cat /etc/os-release | grep -qe "ID=debian" -e "ID=Ubuntu"; then
    
    echo "Installing on Debian based distribution"
    # Check and Install dependencies
    DEPS_LIST=("wget" "gpg" "apt-transport-https")
    DEPS_FAILED=0
    for dep in "${DEPS_LIST[@]}"; do
        if apt-cache policy "$dep" | grep -q "100 /var/lib/dpkg/status"; then
            echo "Dependency - $dep is already installed"
        else
            sudo apt install "$dep" -y
            if apt-cache policy "$dep" | grep -q "100 /var/lib/dpkg/status"; then
                echo "Dependency - $dep installed successfully"
            else
                echo "Dependecy - $dep installation failed"
                DEPS_FAILED=$((DEPS_FAILED + 1))
            fi
        fi
    done

    # Verify installation of dependencies
    if [[ "$DEPS_FAILED" -gt 0 ]]; then
        echo "Exiting due to failed installation of one or more dependencies"
        exit 1
    else
        echo "All dependencies were Installed"
    fi

    # Download and Verify GPG keys from Microsoft
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg

    # Install Verified GPG key
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg

    # Add apt repository for updates
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

    rm -f packages.microsoft.gpg

    # Update package lists and Install VS Code
    sudo apt update -y
    sudo apt install code -y

    # Verify Installation
    if apt-cache policy code | grep -q "100 /var/lib/dpkg/status"; then
        echo "VS Code installed successfully"
    else
        echo "VS Code installation failed"
        exit 1
    fi

    # Remove existing code.desktop file, if existing
    if [ -f /usr/share/applications/code.desktop ]; then
        echo "code.desktop file is already present in ~/.local/share/applications"
        echo "Removing /usr/share/applications/code.desktop"
        sudo rm /usr/share/applications/code.desktop
        if [ -f /usr/share/applications/code.desktop ]; then
            echo "/usr/share/applications/code.desktop was not removed"
            exit 1
        else
            echo "/usr/share/applications/code.desktop was removed successfully"
        fi
    
    elif [ -f ~/.local/share/applications/code.desktop ]; then
        echo "code.desktop file is already present in ~/.local/share/applications"
        echo "Removing ~/.local/share/applications/code.desktop"
        rm ~/.local/share/applications/code.desktop
        if [ -f ~/.local/share/applications/code.desktop ]; then
            echo "~/.local/share/applications/code.desktop was not removed"
            exit 1
        else
            echo "~/.local/share/applications/code.desktop was removed successfully"
        fi

    fi

    # Add code.desktop file to /usr/share/applications directory so it can be read and added to Launcher
    sudo cp ./files/code.desktop /usr/share/applications/

    # Modify File permissions of /usr/share/applications/code.desktop to make it accessible to Launcher
    sudo chmod 644 /usr/share/applications/code.
    
    # Move the code.desktop file to refresh icon cache
    sudo mv /usr/share/applications/code.desktop ~
    sleep 5
    sudo mv ~/code.desktop /usr/share/applications

    if [ -f /usr/share/applications/code.desktop ]; then
        echo "VS Code desktop entry updated"
        exit 0
    else
        echo "VS Code desktop entry not updated"
        exit 1
    fi     

elif cat /etc/os-release | grep -qe "ID=fedora" -e "ID=centos" -e "ID=rhel"; then
    echo "Installing on RPM based distribution"
    
    # Import GPG keys from Microsoft
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

    # Add dnf repository for updates
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

    # Update package cache and Install VS Code
    sudo dnf check-update
    sudo dnf install code

    # Verify Installation
    if rpm -q code | grep -q "package code is not installed"; then
        echo "VS Code installation failed"
        exit 1
    else
        echo "VS Code installed successfully"
    fi

else
    echo "Error - Unknown Distribution"

fi

