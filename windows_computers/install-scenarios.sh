#!/bin/bash

function usage {
        echo "Usage: ./install-scenarios.sh WINDOWS_USERNAME"
        exit 1
}

function call {
        echo "$1"
        eval "$1"
}

WINDOWS_USERNAME="$1"

SCRIPT_DIR="${HOME}/various_scripts"
SCENARIOS_SCRIPT_PATH="${SCRIPT_DIR}/sim-scenarios.sh"
WINDOWS_USER_DIR="/mnt/c/Users/${WINDOWS_USERNAME}"
WINDOWS_SHORTCUT_PATH="${WINDOWS_USER_DIR}/Desktop/scenarios.bat"


if [ -z "${WINDOWS_USERNAME}" ]; then
        echo "Empty WINDOWS_USERNAME: '${WINDOWS_USERNAME}'"
        usage
fi

if ! [ -d "${WINDOWS_USER_DIR}" ]; then
        echo "Invalid WINDOWS_USER_DIR: '${WINDOWS_USER_DIR}'"
        usage
fi

if ! [ -x "${SCENARIOS_SCRIPT_PATH}" ]; then
       echo "SCENARIOS_SCRIPT_PATH is not an executable file: ${SCENARIOS_SCRIPT_PATH}"
       exit 1
fi

BATFILE_CMD="wsl ${SCENARIOS_SCRIPT_PATH}"
call "echo '${BATFILE_CMD}' > ${WINDOWS_SHORTCUT_PATH}"
if ! [ -f "${WINDOWS_SHORTCUT_PATH}" ]; then
        echo "WINDOWS_SHORTCUT_PATH is not a file: ${WINDOWS_SHORTCUT_PATH}"
        exit 1
fi

echo "Done!"
