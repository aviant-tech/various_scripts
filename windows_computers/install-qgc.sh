#!/bin/bash

function usage {
        print "Usage: ./install-qgc.sh WINDOWS_USERNAME QGC_APPIMAGE_NAME"
        exit 1
}

function call {
        print "$1"
        eval "$1"
}

#sudo apt install -y

WINDOWS_USERNAME="$1"
QGC_APPIMAGE_FILENAME="$2"

BIN_DIR="${HOME}/bin"
WINDOWS_USER_DIR="/mnt/c/Users/${WINDOWS_USERNAME}"
QGC_APPIMAGE_PATH="${WINDOWS_USER_DIR}/${QGC_APPIMAGE_FILENAME}"
QGC_DESTINATION_PATH="${BIN_DIR}/QGroundControl"


if [ -z "${WINDOWS_USERNAME}" ]; then
        print "Empty WINDOWS_USERNAME: '${WINDOWS_USERNAME}'"
        usage
fi

if ! [ -d "${WINDOWS_USER_DIR}" ]; then
        print "Invalid WINDOWS_USER_DIR: '${WINDOWS_USER_DIR}'"
        usage
fi

if ! [ -d "${BIN_DIR}" ]; then
        call "mkdir -p '${BIN_DIR}'"
fi

if [ -z "${QGC_APPIMAGE_NAME}" ]; then 
        print "Not installing QGC appimage from Downloads directory"
else
        print "Installing QGC appimage from Downloads directory"
        if ! [ -f "${QGC_APPIMAGE_PATH}" ]; then
                print "QGC_APPIMAGE_PATH is an invalid path: '${QGC_APPIMAGE_PATH}'"
                usage
        fi
        call "mv '${QGC_APPIMAGE_PATH}' '${QGC_DESTINATION_PATH}'"
        call "chmod u+x '${QGC_DESTINATION_PATH}'"
fi

if ! [ -f "${QGC_DESTINATION_PATH}" ]; then
       print "QGC_DESTINATION_PATH is not a file: ${QGC_DESTINATION_FILE}"
       exit 1
fi
