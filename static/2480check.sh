#!/bin/bash

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
sudo apt update > /dev/null 2>&1

# Loop through each package and install if not already installed
for package in "${packages[@]}"; do
    if ! is_installed "$package"; then
        echo "Installing $package..."
        sudo apt install -y "$package" &> /dev/null
        if [ $? -eq 0 ]; then
            echo "$package installed successfully."
        else
            echo "Failed to install $package."
        fi
    else
        echo "$package is already installed."
    fi
done

echo "Installing required Python modules"

#Download and install required python packages first
curl -s https://raw.githubusercontent.com/bfranske/2480checkup/main/requirements.txt | pip install -r /dev/stdin

#Run python check script
curl -s https://raw.githubusercontent.com/bfranske/2480checkup/main/sbacheck.py | python3