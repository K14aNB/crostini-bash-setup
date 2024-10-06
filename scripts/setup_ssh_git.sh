#!/bin/bash

source .env

# Check if email address is provided in a .env file
if [ -n "$EMAIL_ADDRESS" ]; then
    # Generating a new SSH key
    ssh-keygen -t  ed25519 -C "$EMAIL_ADDRESS" -f ~/.ssh/id_ed25519

    # Adding the SSH key to SSH agent
    # Start the SSH agent in the background
    eval "$(ssh-agent -s)"

    ssh-add ~/.ssh/id_ed25519

    cat ~/.ssh/id_ed25519.pub
    exit 0

else 
    echo "Email Address is required to set up git ssh"
    exit 1

fi
