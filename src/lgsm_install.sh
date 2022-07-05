#!/usr/bin/env bash

################################################################################
#
# Install LinuxGSM_.
#
################################################################################

# shellcheck disable=SC1091
source /lgsm_functions.bash
# shellcheck disable=SC1091
source /lgsm_variables.bash

fn_check_user

declare lgsm_install_latest="https://linuxgsm.sh"
declare lgsm_install="${lgsm_install_latest}"

cd "${HOME}" || exit 1

if [ "$(fn_is_lgsm_installed)" == "OK" ] && [ "$(fn_lgsm_file_version "${VAR_LGSM_SCRIPT}")" == "$(fn_lgsm_version)" ]; then
    exit 0
fi

# Install specific version of LinuxGSM_
if [ "$(fn_lgsm_version)" != "latest" ]; then
    lgsm_install="https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/$(fn_lgsm_version)/linuxgsm.sh"

    # Check if specific version exists
    if [ "$(fn_validate_url "${lgsm_install}")" != "OK" ]; then
        lgsm_install="${lgsm_install_latest}"
    fi
fi

# Download install script
printf "Downloading LinuxGSM_ script from %s\n" "${lgsm_install}"
wget -q -O "${VAR_LGSM_SCRIPT}" "${lgsm_install}"
chmod +x "${VAR_LGSM_SCRIPT}"
