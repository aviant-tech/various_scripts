#!/bin/bash

CONFIG_FILE=".px4.conf"
NEW_CONFIG_FILE=".px4.conf.new"

cd "${HOME}/PX4-Autopilot"

test -f "${CONFIG_FILE}" && source "${CONFIG_FILE}"
test -f "${NEW_CONFIG_FILE}" && rm "${NEW_CONFIG_FILE}"

function set_user_param {
        PARAM_NAME="$1"
        PARAM_VALUE="$2"

        if [ -z "${PARAM_VALUE}" ]; then
                echo -n "${PARAM_NAME}: "
        else
                echo -n "${PARAM_NAME} (ENTER to use ${PARAM_VALUE}): "
        fi
        read USER_VALUE
        if [ -z "${USER_VALUE}" ]; then
                NEW_VALUE="${PARAM_VALUE}"
        else
                NEW_VALUE="${USER_VALUE}"
        fi
        eval "${PARAM_NAME}='${NEW_VALUE}'"
        echo "${PARAM_NAME}=\"${NEW_VALUE}\"" | tee -a "${NEW_CONFIG_FILE}"

}

set_user_param HEADLESS "${HEADLESS}"
set_user_param PX4_HOME_LAT "${PX4_HOME_LAT}"
set_user_param PX4_HOME_LON "${PX4_HOME_LON}"
set_user_param PX4_HOME_ALT "${PX4_HOME_ALT}"

mv "${NEW_CONFIG_FILE}" "${CONFIG_FILE}"

make px4_sitl gazebo_standard_vtol


