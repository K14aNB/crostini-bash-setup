#!/bin/bash

# Initialize configs
source configs.cfg

# Check for Updates
sudo apt update && sudo apt upgrade -y

# Setup SSH in git
bash ./scripts/setup_ssh_git.sh

# Install Anaconda3
bash ./scripts/install_anaconda.sh

# Install Ansible
bash ./scripts/install_ansible.sh --conda-env "$CONDA_ENVIRONMENT_NAME" --python "$PYTHON_VERSION"

# Install Eclipse
bash ./scripts/install_eclipse.sh --eclipse-version "$ECLIPSE_VERSION"

# Install VS Code
bash ./scripts/install_vscode.sh

# Install Nemo File Manager
bash ./scripts/install_nemo.sh

# Install Brave Browser
bash ./scripts/install_brave_browser.sh

# Install Pomatez
bash ./scripts/install_pomatez.sh --pomatez-version "$POMATEZ_VERSION"

# Install Virt Manager
bash ./scripts/install_virt_manager.sh

# Install Docker
bash ./scripts/install_docker.sh

# Install Dbeaver Community Edition
bash ./scripts/install_dbeaver.sh

# Install Fonts
bash ./scripts/install_fonts.sh

# Set Default Browser in Crostini
bash ./scripts/set_default_browser.sh