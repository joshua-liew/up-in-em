#!/bin/bash

set -e

ascii_art='
                     _                          
  __  ______        (_)___        ___  ____ ___ 
 / / / / __ \______/ / __ \______/ _ \/ __ `__ \
/ /_/ / /_/ /_____/ / / / /_____/  __/ / / / / /
\__,_/ .___/     /_/_/ /_/      \___/_/ /_/ /_/ 
    /_/                                         
'

echo -e "$ascii_art"
echo "=> Installing your eduroam infrastructure up-in-em!"
echo "To abort installation: CTRL+C"
echo "Begin installation..."

#sudo apt-get update >/dev/null
#sudo apt-get install -y git >/dev/null

echo -e "\nChecking for previous installations of up-in-em..."
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


# TODO: git clone upinem
#
# TODO: check os version - only work with Ubuntu 24.04+
#
# TODO: make stdout more colorful!
