#!/bin/bash

function usage {
        echo "Usage: ./install-px4.sh WINDOWS_USERNAME"
        exit 1
}

function call {
        echo "$1"
        eval "$1"
}

WINDOWS_USERNAME="$1"
WINDOWS_USER_DIR="/mnt/c/Users/${WINDOWS_USERNAME}"
WINDOWS_SHORTCUT_PATH="${WINDOWS_USER_DIR}/Desktop/PX4.bat"
WSLCONFIG_PATH="${WINDOWS_USER_DIR}/.wslconfig"

### INSTALL PX4 DEPENDENCIES ###

sudo apt install -y \
        git \
        build-essential \
        cmake \

test -d "${VENV_DIR}" || virtualenv -p python3 "${VENV_DIR}"
source "${VENV_DIR}/bin/activate"
pip install pyserial empy toml numpy pandas jinja2 pyyaml pyros-genmsg packaging
deactivate


### INCREASE WSL MEMORY ###

if ! [ -f "${WSLCONFIG_PATH}" ]; then
        call "echo -e '[wsl2]\nmemory=3GB\nswap=10GB' > '${WSLCONFIG_PATH}'"
fi

### BUILD THE SIMULATOR ###

PX4_REPO="https://github.com/aviant-tech/PX4-Autopilot.git"
PX4_PATH="${HOME}/PX4-Autopilot"
SCRIPT_DIR="${HOME}/various_scripts"
PX4_DESTINATION_PATH="${SCRIPT_DIR}/run-px4.sh"

if [ -z "${WINDOWS_USERNAME}" ]; then
        echo "Empty WINDOWS_USERNAME: '${WINDOWS_USERNAME}'"
        usage
fi

if ! [ -d "${WINDOWS_USER_DIR}" ]; then
        echo "Invalid WINDOWS_USER_DIR: '${WINDOWS_USER_DIR}'"
        usage
fi

if ! [ -d "${PX4_PATH}" ]; then 
        call "cd ${HOME}"
        call "git clone '${PX4_REPO}'"
fi
call "cd '${PX4_PATH}'"
call "git pull"
call "git checkout aviant-dev/1.12"
call "git submodule update --init --recursive"

BATFILE_CMD="wsl \"${PX4_DESTINATION_PATH}\""
call "echo '${BATFILE_CMD}' > ${WINDOWS_SHORTCUT_PATH}"
if ! [ -f "${WINDOWS_SHORTCUT_PATH}" ]; then
        echo "WINDOWS_SHORTCUT_PATH is not a file: ${WINDOWS_SHORTCUT_PATH}"
        exit 1
fi

echo "Done!"
