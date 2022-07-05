#!/usr/bin/env bash

################################################################################
#
# LinuxGSM Health Check.
#
################################################################################

# shellcheck disable=SC1091
source /lgsm_functions.bash
# shellcheck disable=SC1091
source /lgsm_variables.bash

fn_check_user
fn_check_lgsm_installed

if [ "${LGSM_GAMESERVER_START}" != "true" ]; then
    exit 0
fi

cd "${HOME}" || exit 1

declare lgsm_gameserver_script="${VAR_GAMESERVER_ORIGINAL_SCRIPT}"

if [ -n "${LGSM_GAMESERVER_RENAME}" ]; then
    lgsm_gameserver_script="${VAR_GAMESERVER_RENAMED_SCRIPT}"
fi

$lgsm_gameserver_script monitor

if [ $? != 0 ]; then
    exit 1
fi

exit 0
