#!/bin/bash

LASTIP_FILE=".last-mavproxy-ip"

cd ${HOME}/various_scripts
echo "Make sure this computer and the pad are on the same WiFi network"

if [ -f ${LASTIP_FILE} ]; then
        LAST_IP=$(cat ${LASTIP_FILE})
        echo -n "Enter the IP address of the pad, or hit ENTER to use ${LAST_IP}: "
else
        echo -n "Enter the IP address of the pad: "
fi

read PAD_IP

if [ -z "${PAD_IP}" ]; then
        PAD_IP="${LAST_IP}"
fi
if [ -z "${PAD_IP}" ]; then
        echo "Invalid PAD_IP: ${PAD_IP}"
        exit 1
fi

echo -n "${PAD_IP}" > "${LASTIP_FILE}"

PYVERSION="p$(venv/bin/python --version | grep -oP 'ython \d\.\d' | tr -d ' ')"
MAVPROXY_SCRIPT="venv/lib/${PYVERSION}/site-packages/MAVProxy/mavproxy.py"
if ! [ -f "${MAVPROXY_SCRIPT}" ]; then
        echo "MAVPROXY_SCRIPT is not a file: ${MAVPROXY_SCRIPT}"
        exit 1
fi

venv/bin/python $MAVPROXY_SCRIPT --master=0.0.0.0:14550 --out=${PAD_IP}:14550
