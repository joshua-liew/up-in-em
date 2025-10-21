#!/bin/bash

set -e

ascii_art='
                     __                         
  __  ______        /_/___        ___  ____ ___ 
 / / / / __ \______/ / __ \______/ _ \/ __ `__ \
/ /_/ / /_/ /_____/ / / / /_____/  __/ / / / / /
\__,_/ .___/     /_/_/ /_/      \___/_/ /_/ /_/ 
    /_/                                         
'

echo -e "$ascii_art"
echo "=> Installing your eduroam infrastructure up-in-em!"
echo "To abort installation: CTRL+C"
echo "Booting up the installation..."

echo -e "\n* Checking for previous installations of up-in-em..."
UPINEM_PATH="$HOME/.local/share/upinem"
if [ -d "$UPINEM_PATH" ]; then
    echo "Previous installation of up-in-em detected at '$UPINEM_PATH'."
    echo "To install up-in-em, you must uninstall any previous version."
    while true; do
        read -p "Enter 'y' to uninstall the previous installation: " var
        case $var in
            y)
                echo "Uninstalling previous version..."
                # TODO: run the uninstall script
                rm -rf $UPINEM_PATH
                break
                ;;
            n | N)
                echo "Installation aborted."
                break
                ;;
            *)
                echo "Invalid input. Please enter 'y' or 'n/N'."
                ;;
        esac
    done
fi

if ! command -v "git" >/dev/null; then
    echo -e "* 'git' is required; installing 'git' as super-user (root)..."
    sudo apt-get update >/dev/null
    sudo apt-get install -y git >/dev/null
fi

echo -e "* Cloning up-in-em repository..."
UPINEM_REPO="https://github.com/joshua-liew/up-in-em.git"
git clone $UPINEM_REPO $UPINEM_PATH >/dev/null && cd $UPINEM_PATH
# TODO: create stable branch & tags
git fetch origin ${UPINEM_REF:-stable} && git checkout ${UPINEM_REF:-stable}
cd - >/dev/null

echo -e "\n* Checking your OS (up-in-em only works with Ubuntu 24.04+)..."
if [ ! -f /etc/os-release ]; then
    echo "Error: /etc/os-release not found. Unknown OS."
    echo "Installation aborted."
    exit 1
fi
source /etc/os-release
# TODO: check if running ubuntu

# TODO: make stdout more colorful!
