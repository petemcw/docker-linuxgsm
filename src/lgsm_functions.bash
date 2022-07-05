#!/usr/bin/env bash

################################################################################
#
# Defines common functions to support LinuxGSM functionality.
#
################################################################################

# -------------------------------------------------------------------------------
# Validate that the correct user is running the script.
# -------------------------------------------------------------------------------
fn_check_user() {
    if [ "$(whoami)" != "linuxgsm" ]; then
        printf "This script must be run as user linuxgsm!\n"
        exit 1
    fi
}

# -------------------------------------------------------------------------------
# Validate that LinuxGSM_ is installed.
# -------------------------------------------------------------------------------
fn_check_lgsm_installed() {
    if [ "$(fn_is_lgsm_installed)" != "OK" ]; then
        printf "LinuxGSM_ is not installed!\n"
        exit 1
    fi
}

# -------------------------------------------------------------------------------
# Examine install directory for LinuxGSM_.
# -------------------------------------------------------------------------------
fn_is_lgsm_installed() {
    [ -f "${HOME}/linuxgsm.sh" ] && echo "OK" || echo "KO"
}

# -------------------------------------------------------------------------------
# Return the LinuxGSM_ version installed.
# -------------------------------------------------------------------------------
fn_lgsm_file_version() {
    if [ -f "${1}" ]; then
        echo $(cat "${1}" | grep "version=" -m1 | sed -r "s/version=\"([^\"]+)\"/\1/")
    fi
}

# -------------------------------------------------------------------------------
# Return the LinuxGSM_ version.
# -------------------------------------------------------------------------------
fn_lgsm_version() {
    if [[ "${LGSM_VERSION}" =~ ^v[0-9]{2}\.[0-9]{1,2}\.[0-9]{1,2}$ ]]; then
        echo "${LGSM_VERSION}"
    else
        echo "latest"
    fi
}

# -------------------------------------------------------------------------------
# Sanitize the passed string by removing non-useful characters.
#
# Arguments:
#   $1 (required) - String
# -------------------------------------------------------------------------------
fn_sanitize_string() {
    local sanitized="${1}"

    # First, replace spaces with dashes
    sanitized=${sanitized// /-/}
    # Now, replace anything that's not alphanumeric, an underscore or a dash
    sanitized=${sanitized//[^a-zA-Z0-9_-]/-/}
    # Finally, lowercase with TR
    sanitized=$(echo -n "${sanitized}" | tr A-Z a-z)

    echo "${sanitized}"
}

# -------------------------------------------------------------------------------
# Validate that the passed URL was downloaded.
#
# Arguments:
#   $1 (required) - URL
# -------------------------------------------------------------------------------
fn_validate_url() {
    $(wget -O /dev/null -q "${1}") && echo "OK" || echo "KO"
}

# -------------------------------------------------------------------------------
# Apply configuration.
#
# Arguments:
#   $1 (required) - Configuration file
#   $2 (required) - Common Configuration
#   $3 (required) - Common Configuration file
# -------------------------------------------------------------------------------
fn_apply_configuration() {
    local config_file="${1}"
    local lgsm_config="${2}"
    local lgsm_config_file="${3}"

    if [ -n "${lgsm_config_file}" ] && [ -f "${lgsm_config_file}" ]; then
        cat "${lgsm_config_file}" >"${config_file}"
    elif [ -n "${lgsm_config}" ]; then
        echo "${lgsm_config}" >"${config_file}"
    fi
}

# -------------------------------------------------------------------------------
# Check if variable is already configured
#
# Arguments:
#   $1 (required) - Variable
# -------------------------------------------------------------------------------
fn_configuration_already_set() {
    local var_name="${1}="

    if [[ (-n "${LGSM_COMMON_CONFIG}" && -n "$(echo "${LGSM_COMMON_CONFIG}" | grep "${var_name}")") ||
    (-n "${LGSM_COMMON_CONFIG_FILE}" && -n "$(grep "${var_name}" "${LGSM_COMMON_CONFIG_FILE}")") ||
    (-n "${LGSM_SERVER_CONFIG}" && -n "$(echo "${LGSM_SERVER_CONFIG}" | grep "${var_name}")") ||
    (-n "${LGSM_SERVER_CONFIG_FILE}" && -n "$(grep "${var_name}" "${LGSM_SERVER_CONFIG_FILE}")") ]]; then
        return 1
    fi

    return 0
}

# -------------------------------------------------------------------------------
# Configure variable.
#
# Arguments:
#   $1 (required) - Variable
# -------------------------------------------------------------------------------
fn_configure_variable() {
    fn_configuration_already_set "${1}"
    local already_set=$?

    if [[ $already_set -eq 0 ]]; then
        if [ -z "$(grep "${1}" "${VAR_SERVER_CONFIG_FILE}")" ]; then
            echo "${1}=\"${2}\"" >>"${VAR_SERVER_CONFIG_FILE}"
        else
            sed -ri "s/^${1}=\"(.*)\"$/${1}=\"${2}\"/" "${VAR_SERVER_CONFIG_FILE}"
        fi
    fi
}
