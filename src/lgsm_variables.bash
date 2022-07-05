#!/usr/bin/env bash

################################################################################
#
# Defines common variables to support LinuxGSM functionality.
#
################################################################################

# shellcheck disable=SC1091
source /lgsm_functions.bash

fn_check_user

if [ -z "${VAR_LGSM_VARIABLES_DEFINED}" ]; then
    declare VAR_LGSM_SCRIPT="${HOME}/linuxgsm.sh"
    declare VAR_LGSM_DIR="${HOME}/lgsm"
    declare VAR_CONFIG_DIR="${VAR_LGSM_DIR}/config-lgsm"
    declare VAR_SERVER_CONFIG_DIR="${VAR_CONFIG_DIR}/${LGSM_GAMESERVER}"
    declare VAR_SERVER_CONFIG_FILE="${VAR_SERVER_CONFIG_DIR}/${LGSM_GAMESERVER}.cfg"
    declare VAR_COMMON_CONFIG_FILE="${VAR_SERVER_CONFIG_DIR}/common.cfg"
    declare VAR_GAMESERVER_ORIGINAL_SCRIPT="${HOME}/${LGSM_GAMESERVER}"
    declare VAR_GAMESERVER_RENAMED_SCRIPT="${HOME}/$(fn_sanitize_string "${LGSM_GAMESERVER_RENAME}")"
    declare VAR_LGSM_VARIABLES_DEFINED="true"
fi
