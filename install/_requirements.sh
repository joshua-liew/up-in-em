#!/bin/bash

# Check if running on x86
echo "* Checking your architecture (up-in-em only works on x86 architectures)..."
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "i686" ]; then
    echo "[ FAIL ] Unsupported architecture detected."
    echo "Current architecture: $ARCH"
    echo "Architecture required: x86 architectures (x86_64 or i686)"
    echo "Boot process aborted."
    exit 1
fi

# Check if running >= Ubuntu 24.04+
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
