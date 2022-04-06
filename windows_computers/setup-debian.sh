#!/bin/bash

function usage {
        echo "Usage: ./install-mavproxy.sh WINDOWS_USERNAME"
        exit 1
}

function call {
        echo "$1"
        eval "$1"
}

sudo apt update
sudo apt full-upgrade -y
sudo apt install -y \
        vim \
        tmux \
        htop \
        git

WINDOWS_USERNAME="$1"
WINDOWS_USER_DIR="/mnt/c/Users/${WINDOWS_USERNAME}"
WINDOWS_SHORTCUT_PATH="${WINDOWS_USER_DIR}/Desktop/restart-wsl.bat"

if [ -z "${WINDOWS_USERNAME}" ]; then
        echo "Empty WINDOWS_USERNAME: '${WINDOWS_USERNAME}'"
        usage
fi

if ! [ -d "${WINDOWS_USER_DIR}" ]; then
        echo "Invalid WINDOWS_USER_DIR: '${WINDOWS_USER_DIR}'"
        usage
fi

BATFILE_CMD="wsl --shutdown"
call "echo '${BATFILE_CMD}' > ${WINDOWS_SHORTCUT_PATH}"
if ! [ -f "${WINDOWS_SHORTCUT_PATH}" ]; then
        echo "WINDOWS_SHORTCUT_PATH is not a file: ${WINDOWS_SHORTCUT_PATH}"
        exit 1
fi

echo "Done!"
