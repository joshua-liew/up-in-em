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
echo -e "An open source tool for your eduroam infrastructure needs\n"
echo "[START] Begin the boot process."
echo "[INFO] To abort the boot process, use CTRL+C."
echo -e "Booting up the installation..."

echo "* Checking for previous installations of up-in-em..."
UPINEM_PATH="$HOME/.local/share/upinem"
if [ -d "$UPINEM_PATH" ]; then
    echo "Previous installation of up-in-em detected at '$UPINEM_PATH'."
    echo "[WARN] To install up-in-em, you must uninstall any previous version."
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
                echo "[ABORT] Boot process aborted."
                exit 1
                ;;
            *)
                echo "Invalid input. Please enter 'y' or 'n/N'."
                ;;
        esac
    done
fi

if ! command -v "git" >/dev/null; then
    echo "* 'git' is required; installing 'git' as super-user (root)..."
    sudo apt-get update >/dev/null
    sudo apt-get install -y git >/dev/null
fi

echo "* Cloning up-in-em repository..."
UPINEM_REPO="https://github.com/joshua-liew/up-in-em.git"
git clone $UPINEM_REPO $UPINEM_PATH >/dev/null && cd $UPINEM_PATH
# TODO: create stable branch & tags
git fetch origin ${UPINEM_REF:-stable} && git checkout ${UPINEM_REF:-stable}
cd - >/dev/null

echo "* Checking your OS (up-in-em only works with Ubuntu 24.04+)..."
if [ ! -f /etc/os-release ]; then
    echo "[FAIL] /etc/os-release not found. Unknown OS."
    echo "Boot process aborted."
    exit 1
fi
source /etc/os-release
if [ "$ID" != "ubuntu" ] || [ $(echo "$VERSION_ID >= 24.04" | bc) != 1 ]; then
    echo "[FAIL] Unsupported OS detected."
    echo "Current OS: $ID $VERSION_ID"
    echo "OS required: Ubuntu 24.04 or higher."
    echo "Boot process aborted."
    exit 1
fi

echo "* Checking your architecture (up-in-em only works on x86 architectures)..."
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "i686" ]; then
    echo "[FAIL] Unsupported architecture detected."
    echo "Current architecture: $ARCH"
    echo "Architecture required: x86 architectures (x86_64 or i686)"
    echo "Boot process aborted."
    exit 1
fi

echo "[SUCCESS] Boot process for the installation was successful!"
echo "[NOTE] Installation will begin in 3 seconds..."
# TODO: source install script here (after 3 seconds)
# TODO: make stdout more colorful!
