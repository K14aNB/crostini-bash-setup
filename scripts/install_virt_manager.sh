#!/bin/bash

source ./configs.cfg

# Check if Virt Manager is already installed
if apt-cache policy virtmanager | grep -q "100 /var/lib/dpkg/status"; then
    echo "virt-manager is already installed"
    exit 0
else
    echo "Installing virt-manager"
fi

# Check if current system is Debian based (Debian, Ubuntu) or RPM based (Fedora, RHEL)
if cat /etc/os-release | grep -qe "ID=debian" -e "ID=Ubuntu"; then
    
    echo "Installing on Debian based distribution"
    # Check and install dependencies from Configs file
    DEB_DEPS="$VIRT_MANAGER_DEB_DEPS"
    DEPS_FAILED=0

    for dep in "${DEB_DEPS[@]}"; do
        if apt-cache policy "$dep" | grep -q "100 /var/lib/dpkg/status"; then
            echo "Dependency - $dep is already installed"
        else
            sudo apt install "$dep" -y
            if apt-cache policy "$dep" | grep -q "100 /var/lib/dpkg/status"; then
                echo "Dependency - $dep installed successfully"
            else
                echo "Dependency - $dep installation failed"
                DEPS_FAILED=$(( DEPS_FAILED + 1 ))
            fi
        fi
    done

    # Verify installation of dependencies
    if [[ "$DEPS_FAILED" -gt 0 ]]; then
        echo "Exiting due to failed installation of one or more dependencies"
        exit 1
    else
        echo "All dependencies were installed"
    fi

    # Install virt-manager
    sudo apt install virt-manager -y

    # Verify Installation
    if apt-cache policy virt-manager | grep -q "100 /var/lib/dpkg/status"; then
        echo "Virt Manager installed successfully"
    else
        echo "Virt Manager installation failed"
        exit 1
    fi
