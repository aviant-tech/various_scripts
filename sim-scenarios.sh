#!/bin/bash

cd ${HOME}/various_scripts

echo "Choose a scenario by inputting the corresponding number."
echo "0: Traffic"
echo "1: Flyaway"

read SCENARIO

if [ "${SCENARIO}" = "0" ]; then
        venv/bin/python3 simulate_traffic.py
elif [ "${SCENARIO}" = "1" ]; then
        venv/bin/python3 simulate_flyaway.py
else
        echo "Invalid scenario."
        read
fi

