#!/bin/bash

function usage {
        echo "Usage: ./install-qgc.sh WINDOWS_USERNAME QGC_APPIMAGE_FILENAME"
        exit 1
}

function call {
        echo "$1"
        eval "$1"
}

#sudo apt install -y

WINDOWS_USERNAME="$1"
QGC_APPIMAGE_FILENAME="$2"

BIN_DIR="${HOME}/bin"
WINDOWS_USER_DIR="/mnt/c/Users/${WINDOWS_USERNAME}"
WINDOWS_SHORTCUT_PATH="${WINDOWS_USER_DIR}/Desktop/QGC.bat"
QGC_APPIMAGE_PATH="${WINDOWS_USER_DIR}/Downloads/${QGC_APPIMAGE_FILENAME}"
QGC_DESTINATION_PATH="${BIN_DIR}/QGroundControl"

BATFILE_CMD="wsl -e \"${QGC_DESTINATION_PATH}\""


if [ -z "${WINDOWS_USERNAME}" ]; then
        echo "Empty WINDOWS_USERNAME: '${WINDOWS_USERNAME}'"
        usage
fi

if ! [ -d "${WINDOWS_USER_DIR}" ]; then
        echo "Invalid WINDOWS_USER_DIR: '${WINDOWS_USER_DIR}'"
        usage
fi

if ! [ -d "${BIN_DIR}" ]; then
        call "mkdir -p '${BIN_DIR}'"
fi

if [ -z "${QGC_APPIMAGE_FILENAME}" ]; then 
        echo "Not installing QGC appimage from Downloads directory"
else
        echo "Installing QGC appimage from Downloads directory"
        if ! [ -f "${QGC_APPIMAGE_PATH}" ]; then
                echo "QGC_APPIMAGE_PATH is an invalid path: '${QGC_APPIMAGE_PATH}'"
                usage
        fi
        call "mv '${QGC_APPIMAGE_PATH}' '${QGC_DESTINATION_PATH}'"
        call "chmod u+x '${QGC_DESTINATION_PATH}'"
fi

if ! [ -x "${QGC_DESTINATION_PATH}" ]; then
       echo "QGC_DESTINATION_PATH is not an executable file: ${QGC_DESTINATION_FILE}"
       exit 1
fi

call "echo '${BATFILE_CMD}' > ${WINDOWS_SHORTCUT_PATH}"
if ! [ -f "${WINDOWS_SHORTCUT_PATH}" ]; then
        echo "WINDOWS_SHORTCUT_PATH is not a file: ${WINDOWS_SHORTCUT_PATH}"
        exit 1
fi

echo "Done!"
