#!/usr/bin/env bash

################################################################################
#
# Configure LinuxGSM_ game server.
#
################################################################################

# shellcheck disable=SC1091
source /lgsm_functions.bash
# shellcheck disable=SC1091
source /lgsm_variables.bash

fn_check_user
fn_check_lgsm_installed

if [ -z "${LGSM_GAMESERVER}" ]; then
    exit 0
fi

cd "${HOME}" || exit 1

declare lgsm_gameserver_script="${VAR_GAMESERVER_ORIGINAL_SCRIPT}"

if [ ! -f "${VAR_GAMESERVER_ORIGINAL_SCRIPT}" ] && [ ! -f "${VAR_GAMESERVER_RENAMED_SCRIPT}" ]; then
    # First installation

    # Install server script
    printf "Installing LinuxGSM_ game server\n"
    $VAR_LGSM_SCRIPT "${LGSM_GAMESERVER}"

    # Rename server script
    if [ -n "${LGSM_GAMESERVER_RENAME}" ]; then
        printf "Renaming LinuxGSM_ game server\n"
        mv "${VAR_GAMESERVER_ORIGINAL_SCRIPT}" "${VAR_GAMESERVER_RENAMED_SCRIPT}"
        lgsm_gameserver_script="${VAR_GAMESERVER_RENAMED_SCRIPT}"
        VAR_SERVER_CONFIG_FILE="${VAR_SERVER_CONFIG_DIR}/$(fn_sanitize_string "${LGSM_GAMESERVER_RENAME}").cfg"
    fi

    # Install game server
    printf "Installing game server\n"
    $lgsm_gameserver_script auto-install
else
    # Already installed

    # Search renamed script
    if [ -n "${LGSM_GAMESERVER_RENAME}" ]; then
        lgsm_gameserver_script="${VAR_GAMESERVER_RENAMED_SCRIPT}"
        VAR_SERVER_CONFIG_FILE="${VAR_SERVER_CONFIG_DIR}/$(fn_sanitize_string "${LGSM_GAMESERVER_RENAME}").cfg"
    fi

    # Update script
    if [ "$(fn_lgsm_version)" == "latest" ]; then
        printf "Updating LinuxGSM_ to the latest version\n"
        $lgsm_gameserver_script update-lgsm
    elif [ "$(fn_lgsm_file_version "${VAR_LGSM_SCRIPT}")" != "$(fn_lgsm_file_version "${lgsm_gameserver_script}")" ]; then
        # Remove older version
        printf "Removing older version LinuxGSM_\n"
        rm -rf "${lgsm_gameserver_script}" "${VAR_LGSM_DIR}/functions"

        # Install new version
        printf "Updating LinuxGSM_ game server\n"
        $VAR_LGSM_SCRIPT "${LGSM_GAMESERVER}"

        # Rename new version of server script
        if [ -n "${LGSM_GAMESERVER_RENAME}" ]; then
            printf "Renaming new versino of LinuxGSM_ game server\n"
            mv "${VAR_GAMESERVER_ORIGINAL_SCRIPT}" "${VAR_GAMESERVER_RENAMED_SCRIPT}"
        fi
    fi
fi

printf "Applying common configuration\n"
fn_apply_configuration "${VAR_COMMON_CONFIG_FILE}" "${LGSM_COMMON_CONFIG}" "${LGSM_COMMON_CONFIG_FILE}"

printf "Applying game server configuration\n"
fn_apply_configuration "${VAR_SERVER_CONFIG_FILE}" "${LGSM_SERVER_CONFIG}" "${LGSM_SERVER_CONFIG_FILE}"

if [ -f /lgsm_configuration.sh ]; then
    # shellcheck disable=SC1091
    source /lgsm_configuration.sh
fi

# Update game server
if [ "${LGSM_GAMESERVER_UPDATE}" == "true" ]; then
    printf "Updating game server\n"
    $lgsm_gameserver_script update
fi

printf "Game server installed and up-to-date!\n"
