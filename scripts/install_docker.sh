#!/bin/bash

source ./configs.cfg

# Check if docker is already installed
if apt-cache policy docker | grep -q "100 /var/lib/dpkg/status"; then
    echo "docker is already installed"
    exit 0
else
    echo "Installing docker"
fi

# Check if current system is Debian based (Debian, Ubuntu) or RPM based (Fedora, RHEL)
if cat /etc/os-release | grep -qe "ID=debian" -e "ID=Ubuntu"; then
    
    # Uninstall conflicting packages
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do 
        sudo apt remove $pkg 
    done

    # Check and Install dependencies
    DEB_DEPS_LIST="$DOCKER_ENGINE_DEB_DEPS"
    DEPS_FAILED=0

    for dep in "$DEB_DEPS_LIST[@]"; do
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

    # Verify Installation of dependencies
    if [[ $"DEPS_FAILED" -gt 0 ]]; then
        echo "Exiting due to failed installation of one or more dependencies"
        exit 1
    else
        echo "All Dependencies were installed"
    fi

    # Add docker.asc to keyrings
    sudo install -m 0755 -d /etc/apt/keyrings

    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add docker repository to apt sources
    echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Update package lists and install docker engine packages
  sudo apt update -y

  sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

  # Running docker in rootless mode
  # Prerequisites
  # Add subuid and subgid
  sudo usermod --add-subuids 231072-296607 $(whoami)

  sudo usermod --add-subuids 231072-296607 $(whoami)

  # Disable system-wide docker daemon, if running
  sudo systemctl disable --now docker.service docker.socket
  sudo rm /var/run/docker.sock

  # Run setup script
  dockerd-rootless-setuptool.sh install --skip-iptables

  # Add DOCKER_HOST environment variable to .bashrc
  echo "export DOCKER_HOST=unix:///run/user/1000/docker.sock" >> ~/.bashrc

  # Start docker service
  systemctl --user enable --now docker
  sudo loginctl enable-linger $(whoami)
  




