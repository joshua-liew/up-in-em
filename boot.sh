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
echo -e "An open source tool for your eduroam infrastructure needs.\n"
echo "[ START ] Begin the boot process."
echo "[ INFO ] To abort the boot process, use CTRL+C."
echo -e "Booting up the installation..."

echo "* Checking your architecture (up-in-em only works on x86 architectures)..."
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "i686" ]; then
    echo "[ FAIL ] Unsupported architecture detected."
    echo "Current architecture: $ARCH"
    echo "Architecture required: x86 architectures (x86_64 or i686)"
    echo "Boot process aborted."
    exit 1
fi

echo "* Checking your OS (up-in-em only works with Ubuntu 24.04+)..."
if [ ! -f /etc/os-release ]; then
    echo "[ FAIL ] /etc/os-release not found. Unknown OS."
    echo "Boot process aborted."
    exit 1
fi
source /etc/os-release # ID and VERSION_ID are sourced into this script
if [ "$ID" != "ubuntu" ] || [ $(echo "$VERSION_ID >= 24.04" | bc) != 1 ]; then
    echo "[ FAIL ] Unsupported OS detected."
    echo "Current OS: $ID $VERSION_ID"
    echo "OS required: Ubuntu 24.04 or higher."
    echo "Boot process aborted."
    exit 1
fi

echo "* Checking for previous installation of up-in-em..."
UPINEM_PATH="$HOME/.local/share/upinem"
if [ -d "$UPINEM_PATH" ]; then
    echo "Previous installation of up-in-em detected at '$UPINEM_PATH'."
    echo "[ WARN ] To install up-in-em, you must uninstall any previous installation."
    while true; do
        read -p "[ INPUT ] Enter 'y' to uninstall the previous installation: " var
        case $var in
            y)
                echo "Uninstalling previous version..."
                # TODO: run the uninstall script
                rm -rf $UPINEM_PATH
                break
                ;;
            n | N)
                echo "[ ABORT ] Boot process aborted."
                exit 1
                ;;
            *)
                echo "Invalid input. Please enter 'y' or 'n/N'."
                ;;
        esac
    done
fi

echo "* Cloning up-in-em repository..."
if ! command -v "git" >/dev/null; then
    echo "[ WARN ] git is required; installing git as super-user (root)..."
    sudo apt-get update >/dev/null
    sudo apt-get install -y git >/dev/null
fi
UPINEM_REPO="https://github.com/joshua-liew/up-in-em.git"
git clone $UPINEM_REPO $UPINEM_PATH >/dev/null && cd $UPINEM_PATH
# TODO: create stable branch & tags
git fetch origin ${UPINEM_REF:-install} && git switch ${UPINEM_REF:-install}
cd - >/dev/null

echo "[ SUCCESS ] Boot process is complete!"
echo -e "[ NOTE ] Installation will begin in 3 seconds...\n" && sleep 3
source $UPINEM_PATH/install/install.sh
# TODO: make stdout more colorful!
