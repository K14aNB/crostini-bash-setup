#!/bin/bash

# Initialize variables
ANACONDA_VERSION=""

# Handle long form of flags
for opt in "$@"; do
    shift
    case "$opt" in
    --anaconda-version) set -- "$@" "-v" ;;
    --help) set -- "$@" "-h" ;;
    *) set -- "$@" "$opt" ;;
    esac

done

# Handle short form of flags
while getopts "hv:" flags; do
    
    case "$flags" in 
    h) 
        echo "Usage $0 [-h -v]"
        echo "-v, --anaconda-version -> Specify Anaconda3 version to be installed in YYYY.mm-<version_no>. If this flag is not specified, latest version will be downloaded and installed (Optional)"
        echo "-h, --help -> Output the Usage message and exit"
        exit 0
        ;;

    v)  
        ANACONDA_VERSION="$OPTARG"
        ;;
    
    esac
done

shift $((OPTIND - 1))

# If -v or --anaconda-version flag is not provided, then download the latest version
if [ -z "$ANACONDA_VERSION" ]; then

    WEBPAGE_URL="https://repo.anaconda.com/archive/"
    XPATH_EXP="(//a[contains(@href,'Linux-x86_64.sh')])[1]"
    
    # Download the webpage
    wget -O ~/anaconda3_webpage.html "$WEBPAGE_URL"
    
    DOWNLOAD_FILE=$(xmlstarlet sel -t -v "$XPATH_EXP" ~/anaconda3_webpage.html)

    # Download latest linux version of Anaconda3 Installer script
    wget -r "$WEBPAGE_URL$DOWNLOAD_FILE"

    # Move the downloaded directory to ~
    cp -r ./repo.anaconda.com/ ~
    rm -r ./repo.anaconda.com

    # Remove the ~/anaconda3 directory, if present
    if [ -d ~/anaconda3 ]; then
        echo "~/anaconda3 directory already exists"
        echo "Removing the directory and performing reinstallation"
        rm -r ~/anaconda3
    fi

    # Install Anaconda3
    bash ~/repo.anaconda.com/archive/"$DOWNLOAD_FILE" -b -p ~/anaconda3

# If -v or --anaconda-version flag is provided, then download the specific version
elif [ -n "$ANACONDA_VERSION" ]; then

    # Download specific linux version of Anaconda3 Installer script
    wget -O ~/Anaconda3-"$ANACONDA_VERSION"-Linux-x86_64.sh https://repo.anaconda.com/archive/Anaconda3-"$ANACONDA_VERSION"-Linux-x86_64.sh 

    # Install Anaconda3
    bash ~/Anaconda3-"$ANACONDA_VERSION"-Linux-x86_64.sh -b -p ~/anaconda3

fi

# Verify Anaconda3 Installation
if [ -d ~/anaconda3 ]; then
    echo "Anaconda3 installed successfully"
else 
    echo "Anaconda3 installation failed"
    exit 1
fi

if grep -q 'eval "$($HOME/anaconda3/bin/conda shell.bash hook)"' ~/.bashrc; then
    echo "Command to activate base environment is already present in .bashrc"
else
    # Adding command to activate base environment automatically to ~/.bashrc
    echo 'eval "$($HOME/anaconda3/bin/conda shell.bash hook)"' >> ~/.
fi

# Activate the base environment for current shell session
source ~/.bashrc

# Verify if base environment is activated
if which python | grep -qe "anaconda3/bin/python"; then
    echo "base environment is activated"
    exit 0
else
    echo "Failed to activate base environment"
    exit 1
fi 

