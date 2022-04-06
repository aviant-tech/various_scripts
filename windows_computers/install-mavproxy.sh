#!/bin/bash

function usage {
        echo "Usage: ./install-mavproxy.sh WINDOWS_USERNAME"
        exit 1
}

function call {
        echo "$1"
        eval "$1"
}

sudo apt install -y \
       python3 \
       python3-pip \
       virtualenv \

WINDOWS_USERNAME="$1"

SCRIPT_DIR="${HOME}/various_scripts"
VENV_DIR="${SCRIPT_DIR}/venv"
MAVPROXY_SCRIPT_PATH="${SCRIPT_DIR}/run-mavproxy.sh"
WINDOWS_USER_DIR="/mnt/c/Users/${WINDOWS_USERNAME}"
WINDOWS_SHORTCUT_PATH="${WINDOWS_USER_DIR}/Desktop/mavproxy.bat"


test -d "${VENV_DIR}" || virtualenv -p python3 "${VENV_DIR}"
source "${VENV_DIR}/bin/activate"
pip install mavproxy
deactivate


if [ -z "${WINDOWS_USERNAME}" ]; then
        echo "Empty WINDOWS_USERNAME: '${WINDOWS_USERNAME}'"
        usage
fi

if ! [ -d "${WINDOWS_USER_DIR}" ]; then
        echo "Invalid WINDOWS_USER_DIR: '${WINDOWS_USER_DIR}'"
        usage
fi

if ! [ -x "${MAVPROXY_SCRIPT_PATH}" ]; then
       echo "MAVPROXY_SCRIPT_PATH is not an executable file: ${MAVPROXY_SCRIPT_PATH}"
       exit 1
fi

BATFILE_CMD="wsl ${MAVPROXY_SCRIPT_PATH}"
call "echo '${BATFILE_CMD}' > ${WINDOWS_SHORTCUT_PATH}"
if ! [ -f "${WINDOWS_SHORTCUT_PATH}" ]; then
        echo "WINDOWS_SHORTCUT_PATH is not a file: ${WINDOWS_SHORTCUT_PATH}"
        exit 1
fi

echo "Done!"
