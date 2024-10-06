#!/bin/bash

# Initialize variables
CONDA_ENV=""
PYTHON_VERSION="3.12"
PYTHON_FLAG=false

# Handle long form of flags
for opt in "$@"; do
    shift
    case "$opt" in
    --conda-env) set -- "$@" "-e" ;;
    --python) set -- "$@" "-p" ;;
    --help) set -- "$@" "-h" ;;
    *) set -- "$@" "$opt" ;;
    esac
done

# Handle short form of flags
while getopts "he:p:" flags; do
    case "$flags" in
    h)
        echo "Usage $0 [-h -e -p]"
        echo "-e, --conda-env -> Specify the name of conda environment to be created (Optional)."
        echo "-p, --python -> Specify python version to be installed in the conda environment. This python version will be used when installing Ansible. (Optional)."
        echo "-h, --help -> Output the Usage message and exit."
        exit 0
        ;;
    e)
        CONDA_ENV="$OPTARG"
        ;;
    p)
        PYTHON_VERSION="$OPTARG"
        PYTHON_FLAG=true
        ;;
    esac
done

shift $((OPTIND - 1))
    

# Check if Anaconda3 is installed and base environment is active
if which python | grep -q "anaconda3/bin/python"; then
    echo "Anaconda3 is installed and conda base environment is active"
elif which python | grep -q "anaconda3/bin/envs"; then
    echo "Anaconda3 is installed and conda specific environment is active"
    source ~/anaconda3/bin/deactivate
elif [ -d ~/anaconda3 ]; then
    echo "Anaconda3 is installed but not in PATH"
else
    echo "Anaconda3 is not installed"
    # Download and Install latest version of Anaconda3
    bash ./install_anaconda.sh
fi

if [ -z "$CONDA_ENV" ]; then
    echo "conda environment was not specified. Using install-ansible-env as conda environment"
    CONDA_ENV="install-ansible-env"
else
    echo "Using $CONDA_ENV as conda environment name"
fi

if "$PYTHON_FLAG"; then
    echo "Using python=$PYTHON_VERSION"
else
    echo "Python version was not specified. Using python=$PYTHON_VERSION"
fi

if conda env list | grep -q "$CONDA_ENV"; then
    source ~/anaconda3/bin/activate "$CONDA_ENV"
    if ansible --version | grep -q "anaconda3/envs/$CONDA_ENV/bin/ansible"; then
        echo "Ansible is already installed"
        exit 0
    fi
else
    # Create conda environment
    conda create -n "$CONDA_ENV" python="$PYTHON_VERSION" && source ~/anaconda3/bin/activate "$CONDA_ENV"
    echo "conda environment is created and activated"
fi

# Install Ansible inside the conda environment
if which python | grep -q "anaconda3/envs/$CONDA_ENV/bin/python"; then
    echo "Installing Ansible" 
    pip install ansible

    # Verifying Installation
    if ansible --version | grep -q "/anaconda3/envs/$CONDA_ENV/bin/ansible"; then
        echo "Ansible installed successfully"
        exit 0
    else
        echo "Ansible installation failed"
        exit 1
    fi

else 
    echo "Please check if conda environment is created properly and python is installed in it."
    exit 1
fi