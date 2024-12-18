#!/bin/bash

#This script should be executed like: sudo bash -c "$(wget -qO- https://info.ihitc.net/2480check.sh)"

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "------------------------------------"
  echo "This command must be run as root or with sudo. Exiting, please run again with appropriate permissions."
  echo "------------------------------------"
  exit 1
fi

#Start updating locate database in background
updatedb &>/dev/null &

# List of packages to check and install
packages=("curl" "python3" "python3-pip" "python3-venv")

# Function to check if a package is installed
is_installed() {
    dpkg -s "$1" &> /dev/null
    return $?
}

echo ""
echo "------------------------------------"
echo "Please wait, updating package lists..."
echo "------------------------------------"
echo ""

# Update package list silently
apt update > /dev/null 2>&1


echo ""
echo "------------------------------------"
echo "Please wait, installing required packages..."
echo "------------------------------------"
echo ""

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

echo ""
echo "------------------------------------"
echo "Creating Python Environment..."
echo "------------------------------------"
echo ""

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

# Download sbacheck.py
curl -O -s https://raw.githubusercontent.com/bfranske/2480checkup/main/sbacheck.py

# Download requirements.txt
curl -O -s https://raw.githubusercontent.com/bfranske/2480checkup/main/requirements.txt

# Create a virtual environment
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

echo ""
echo "------------------------------------"
echo "Please wait, installing Python requirements..."
echo "------------------------------------"
echo ""

# Install the requirements
pip install -r requirements.txt &> /dev/null

echo ""
echo "------------------------------------"
echo "Beginning to Run Python Test Script..."
echo "------------------------------------"
echo ""

# Run the sbacheck.py script
python sbacheck.py

# Deactivate the virtual environment
deactivate

# Remove the temporary directory
cd ..
rm -rf $TEMP_DIR

echo "------------------------------------"
echo "All check commands finished."
echo "------------------------------------"