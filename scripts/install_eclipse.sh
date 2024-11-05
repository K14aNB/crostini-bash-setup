#!/bin/bash

# Initialize variables
ECLIPSE_VERSION=""

# Handle long form of flags
for opt in "$@"; do
    shift
    case "$opt" in
    --eclipse-version) set -- "$@" "-v" ;;
    --help) set -- "$@" "-h" ;;
    *) set -- "$@" "$opt" ;;
    esac
done

# Handle short form of flags
while getopts "hv:" flags; do
    case "$flags" in
        h)
            echo "Usage $0 [-h -v]"
            echo "-v, --eclipse-version -> Specify Eclipse version to be installed in YYYY-mm. If this flag is not specified, latest version will be downloaded and installed (Optional)"
            echo "-h, --help -> Output Usage message and exit"
            exit 0
            ;;
        v)
            ECLIPSE_VERSION="$OPTARG"
            ;;
    esac
done

shift $((OPTIND - 1))

# If -v or --eclipse-version flag is not specified, then download the latest version
if [[ -z "$ECLIPSE_VERSION" ]]; then

    WEBPAGE_URL="https://mirror.kakao.com/eclipse/technology/epp/downloads/release/release.xml"
    VERSION_NUMBER_XPATH="substring(//present/text(),1,7)"
    
    # Download the webpage
    wget -O ~/eclipse_release.xml "$WEBPAGE_URL"

    VERSION_NUMBER=$(xmlstarlet sel -t -v "$VERSION_NUMBER_XPATH" ~/eclipse_release.xml)
    DOWNLOAD_MIRROR="https://mirror.kakao.com/eclipse/technology/epp/downloads/release/$VERSION_NUMBER/R/eclipse-java-$VERSION_NUMBER-R-linux-gtk-x86_64.tar.gz"

    # Download latest tar ball of Eclipse
    wget -O ~/eclipse.tar.gz "$DOWNLOAD_MIRROR"

elif [[ -n "$ECLIPSE_VERSION" ]]; then

    # Download the specific version tarball of Eclipse
    wget -O ~/eclipse.tar.gz "https://mirror.kakao.com/eclipse/technology/epp/downloads/release/$ECLIPSE_VERSION/R/eclipse-java-$ECLIPSE_VERSION-R-linux-gtk-x86_64.tar.gz"
fi

# Extract the tar ball to ~
tar -xvzf ~/eclipse.tar.gz --directory ~

# Copy the eclipse icon to /usr/share/icons directory
echo "Copying eclipse.png to /usr/share/icons"
# mkdir -p ~/.local/share/icons
sudo cp ./icons/eclipse.png /usr/share/icons

# Modify File permissions of /usr/share/icons/eclipse.png to make it accessible to Launcher
sudo chmod 644 /usr/share/icons/eclipse.png

# Create applications directory, if not exists
# mkdir -p ~/.local/share/applications

# Remove the existing desktop file, if present
echo "Checking if epp.package.java.desktop is already present"
if [ -f /usr/share/applications/epp.package.java.desktop ]; then
    echo "/usr/share/applications/epp.package.java.desktop is already present"
    echo "Removing /usr/share/applications/epp.package.java.desktop"
    sudo rm /usr/share/applications/epp.package.java.desktop
    if [ -f /usr/share/applications/epp.package.java.desktop ]; then
        echo "/usr/share/applications/epp.package.java.desktop was not removed"
        exit 1
    else
        echo "/usr/share/applications/epp.package.java.desktop was removed successfully"
    fi

elif [  -f ~/.local/share/applications/epp.package.java.desktop ]; then
    echo "~/.local/share/applications/epp.package.java.desktop is already present"
    echo "Removing ~/.local/share/applications/epp.package.java.desktop"
    rm ~/.local/share/applications/epp.package.java.desktop
    if [ -f ~/.local/share/applications/epp.package.java.desktop ]; then
        echo "~/.local/share/applications/epp.package.java.desktop was not removed"
        exit 1
    else
        echo "~/.local/share/applications/epp.package.java.desktop was removed successfully"
    fi
else
    echo "epp.package.java.desktop is not already present"

fi

# Add the epp.package.java.desktop file to /usr/share/applications directory so that it can be read and added to Launcher
sudo cp ./files/epp.package.java.desktop /usr/share/applications/

# Modify File permissions of /usr/share/applications/epp.package.java.desktop
sudo chmod 644 /usr/share/applications/epp.package.java.desktop

# Move the epp.package.java.desktop file to refresh icon cache
sudo mv /usr/share/applications/epp.package.java.desktop ~
sleep 5
sudo mv ~/epp.package.java.desktop /usr/share/applications

# Verify that .desktop file is present in applications
if [ -f /usr/share/applications/epp.package.java.desktop ]; then
    echo "Eclipse desktop entry updated"
    exit 0
else
    echo "Eclipse desktop entry not updated"
    exit 1
fi

