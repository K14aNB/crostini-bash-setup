#!/bin/bash

# Read Dependencies from Config file
source configs.cfg

# Check if current system is Debian based (Debian, Ubuntu) or RPM based (Fedora, RHEL)
if cat /etc/os-release | grep -qe "ID=debian" -e "ID=Ubuntu"; then
    
    echo "Installing on Debian based distribution"

    # Check and install dependencies from Config file
    DEB_DEPS="$BRAVE_BROWSER_DEB_DEPS"
    DEB_DEPS_FAILED=0

    for deb_dep in "$DEB_DEPS"; do
        if apt-cache policy "$deb_dep" | grep -q "100 /var/lib/dpkg/status"; then
            echo "Dependency - $deb_dep is already installed"
        else
            sudo apt install "$deb_dep" -y
            if apt-cache policy "$deb_dep" | grep -q "100 /var/lib/dpkg/status"; then
                echo "Dependency - $deb_dep installed successfully"
            else
                echo "Dependency - $deb_dep installation failed"
                DEB_DEPS_FAILED=$((DEB_DEPS_FAILED + 1))
            fi
        fi
    done

    # Verify installation of dependencies
    if [[ "$DEB_DEPS_FAILED" -gt 0 ]]; then
        echo "Exiting due to failed installation of one or more dependencies"
        exit 1
    else
        echo "All dependencies were installed"
    fi

    # Download and Verify GPG keys from Brave
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

    # Add apt repository for updates
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
    sudo tee /etc/apt/sources.list.d/brave-browser-release.list

    # Refresh package lists and Install VS Code
    sudo apt update -y
    sudo apt install brave-browser -y

    # Verify Installation
    if apt-cache policy "brave-browser" | grep -q "100 /var/lib/dpkg/status"; then
        echo "Brave Browser installed successfully"
    else
        echo "Brave Browser installation failed"
        exit 1
    fi

    # Remove gnome-keyring (Optional)
    sudo apt remove gnome-keyring -y
    exit 0


elif cat /etc/os-release | grep -qe "ID=fedora" -e "ID=centos" -e "ID=rhel"; then

    echo "Installing on RPM based distribution"

    # Check and install dependencies from Config file
    RPM_DEPS="$BRAVE_BROWSER_RPM_DEPS"
    RPM_DEPS_FAILED=0

    for rpm_dep in "$RPM_DEPS"; do
        if rpm -q "$rpm_dep" | grep -q "package is not installed"; then
            echo "Dependency - $rpm_dep is not installed"
            echo "Installing $rpm_dep"
            sudo dnf install "$rpm_dep" -y

            if rpm -q "$rpm_dep" | grep -q "package is not installed"; then
                echo "Dependency - $rpm_dep installation failed"
                RPM_DEPS_FAILED=$((RPM_DEPS_FAILED + 1))
            else
                echo "Dependency - $rpm_dep installed successfully"
            fi

        else
            echo "Dependency - $rpm_dep is already installed"
        
        fi
    done

    # Verify installation of dependencies
    if [[ "$RPM_DEPS_FAILED" -gt 0 ]]; then
        echo "Exiting due to failed installation of one or more dependencies"
        exit 1
    else
        echo "All dependencies were installed"
    fi

    # Import GPG keys from Brave Browser
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

    # Add dnf repository for updates
    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

    # Install Brave Browser
    sudo dnf install brave-browser

    # Verify Installation
    if rpm -q "brave-browser" | grep -q "package is not installed"; then
        echo "Brave Browser installation failed"
        exit 1
    else
        echo "Brave Browser installed successfully"
        exit 0
    fi
fi