#!/bin/bash

# Initialize variables
POMATEZ_VERSION=""

# Handle long form of flags
for opt in "$@"; do
    shift
    case "$opt" in
    --pomatez-version) set -- "$@" "-v" ;;
    --help) set -- "$@" "-h" ;;
    *) set -- "$@" "$opt" ;;
    esac
done

# Handle short form of flags
while getopts "hv:" flags; do

    case "$flags" in
    h)
        echo "Usage $0 [-h -v] -v -> Specify the Pomatez version to be installed"
        exit 1
        ;;
    v)
        POMATEZ_VERSION="$OPTARG"
        ;;
    esac
done

shift $((OPTIND - 1))

# If -v or --pomatez-version flag is not provided, download the latest version
# TO DO
# if [ -z "$POMATEZ_VERSION" ]; then
    
#     WEBPAGE_URL="https://zidoro.github.io/pomatez/"
    
#     DOWNLOAD_FILE_XPATH="//a[contains(@href, '-linux-amd64.deb')]"

#     DOWNLOAD_FILE=wget $WEBPAGE_URL | $(xmlstarlet sel -t -v "$DOWNLOAD_FILE_XPATH")

#     # Download latest version of .deb 
#     wget -r "$DOWNLOAD_FILE"

#     # Move the downloaded .deb file to ~
#     mv ./"$DOWNLOAD_FILE" ~

#     # Install Pomatez
#     sudo dpkg -i ~/"$DOWNLOAD_FILE"


# If -v or --pomatez-version flag is provided, download the specific version
if [ -n "$POMATEZ_VERSION" ]; then

    # Download the specific version of .deb 
    wget -O ~/Pomatez-v"$POMATEZ_VERSION"-linux-amd64.deb https://github.com/zidoro/pomatez/releases/download/v"$POMATEZ_VERSION"/Pomatez-v"$POMATEZ_VERSION"-linux-amd64.deb

    # Install the specific version of .deb
    sudo dpkg -i ~/Pomatez-v"$POMATEZ_VERSION"-linux-amd64.deb

else
    echo "Pomatez is not installed"
    exit 1
fi

# Verify Installation
if apt-cache policy pomatez | grep -q "100 /var/lib/dpkg/status"; then
    echo "Pomatez is installed successfully"
    exit 0
else 
    echo "Pomatez installation failed"
    exit 1
fi