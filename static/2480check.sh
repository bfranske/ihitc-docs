#!/bin/bash

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "This command must be run as root or with sudo. Exiting, please run again with appropriate permissions."
  exit 1
fi

#Download and install required python packages first
curl -s https://raw.githubusercontent.com/bfranske/2480checkup/main/requirements.txt | pip install -r /dev/stdin

#Run python check script
curl -s https://raw.githubusercontent.com/bfranske/2480checkup/main/sbacheck.py | python3