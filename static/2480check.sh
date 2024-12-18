#!/bin/bash

#This script should be executed like: sudo bash -c "$(wget -qO- https://info.ihitc.net/2480check.sh)"

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "This command must be run as root or with sudo. Exiting, please run again with appropriate permissions."
  exit 1
fi

#Start updating locate database in background
updatedb& > /dev/null 2>&1

# List of packages to check and install
packages=("curl" "python3" "python3-pip")

# Function to check if a package is installed
is_installed() {
    dpkg -l "$1" &> /dev/null
    return $?
}

echo "Please wait, updating package lists..."

# Update package list silently
apt update > /dev/null 2>&1

# Loop through each package and install if not already installed
for package in "${packages[@]}"; do
    if ! is_installed "$package"; then
        echo "Installing $package..."
        apt install -y "$package" &> /dev/null
        if [ $? -eq 0 ]; then
            echo "$package installed successfully."
        else
            echo "Failed to install $package."
        fi
    else
        echo "$package is already installed."
    fi
done

echo "Handing off to Python..."

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

# Download sbacheck.py
curl -O https://raw.githubusercontent.com/bfranske/2480checkup/main/sbacheck.py

# Download requirements.txt
curl -O https://raw.githubusercontent.com/bfranske/2480checkup/main/requirements.txt

# Create a virtual environment
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Install the requirements
pip install -r requirements.txt

# Run the sbacheck.py script
python sbacheck.py

# Deactivate the virtual environment
deactivate

# Remove the temporary directory
cd ..
rm -rf $TEMP_DIR

echo "Command complete."