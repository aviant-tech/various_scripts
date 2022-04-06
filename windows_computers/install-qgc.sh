#!/bin/bash

function usage {
        echo "Usage: ./install-qgc.sh WINDOWS_USERNAME QGC_APPIMAGE_FILENAME"
        exit 1
}

function call {
        echo "$1"
        eval "$1"
}

### INSTALL QGC DEPENDENCIES ###

sudo apt install -y \
        fuse \
        libsdl2-2.0-0 \
        gstreamer1.0-plugins-bad \
        libpulse-mainloop-glib0 \
        qt5dxcb-plugin

### SET USER PERMISSION ###

sudo adduser aviant dialout

### INSTALL THE QGC APP IMAGE ###

WINDOWS_USERNAME="$1"
QGC_APPIMAGE_FILENAME="$2"

BIN_DIR="${HOME}/bin"
WINDOWS_USER_DIR="/mnt/c/Users/${WINDOWS_USERNAME}"
WINDOWS_SHORTCUT_PATH="${WINDOWS_USER_DIR}/Desktop/QGC.bat"
QGC_APPIMAGE_PATH="${WINDOWS_USER_DIR}/Downloads/${QGC_APPIMAGE_FILENAME}"
QGC_DESTINATION_PATH="${BIN_DIR}/${QGC_APPIMAGE_FILENAME}"


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
        QGC_DESTINATION_PATH="${BIN_DIR}/QGroundControl-Aviant.AppImage"
else
        echo "Installing QGC appimage from Downloads directory"
        if ! [ -f "${QGC_APPIMAGE_PATH}" ]; then
                echo "QGC_APPIMAGE_PATH is an invalid path: '${QGC_APPIMAGE_PATH}'"
                usage
        fi
        call "mv '${QGC_APPIMAGE_PATH}' '${QGC_DESTINATION_PATH}'"
        call "chmod u+x '${QGC_DESTINATION_PATH}'"
fi

if ! [ -x "${QGC_DESTINATION_PATH}" ] || [ -d "${QGC_DESTINATION_PATH}" ]; then
       echo "QGC_DESTINATION_PATH is not an executable file: ${QGC_DESTINATION_PATH}"
       exit 1
fi

BATFILE_CMD="wsl -e \"${QGC_DESTINATION_PATH}\""
call "echo '${BATFILE_CMD}' > ${WINDOWS_SHORTCUT_PATH}"
if ! [ -f "${WINDOWS_SHORTCUT_PATH}" ]; then
        echo "WINDOWS_SHORTCUT_PATH is not a file: ${WINDOWS_SHORTCUT_PATH}"
        exit 1
fi

echo "Done!"
