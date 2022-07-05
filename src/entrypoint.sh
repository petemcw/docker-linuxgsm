#!/usr/bin/env bash

################################################################################
#
# LinuxGSM Server.
#
################################################################################

# Set to `-x` for Debug logging
set +x -o pipefail

# -------------------------------------------------------------------------------
# Call to exit the script.
# -------------------------------------------------------------------------------
_fail() {
    _cleanup
    if [[ "${DEBUG}" == "true" ]] || [[ "${DEBUG}" == "1" ]]; then
        printf "\nTrapped exit in function: '%s'.\n" "${FUNCNAME[*]}"
    else
        printf "\nExiting.\n"
        _exit 1
    fi
}

# -------------------------------------------------------------------------------
# Any actions that should be taken if the script is prematurely
# exited. Always call this function at the top of your script.
# -------------------------------------------------------------------------------
_cleanup() {
    # re-enable echoing of terminal input
    stty echo
    # shows the input cursor
    tput cnorm
    echo -n
}

# -------------------------------------------------------------------------------
# Non-destructive exit for when script exits naturally. Add this function at
# the end of the script.
#
# Arguments:
#   $1 (optional) - Exit code (defaults to 0)
# -------------------------------------------------------------------------------
_exit() {
    _cleanup
    exit "${1:-0}"
}

################################################################################
#
# RUN THE SCRIPT
# Nothing should be edited below this block.
#
################################################################################

# trap exits with your cleanup function
trap _fail SIGINT SIGQUIT
trap _shutdown SIGTERM SIGINT
trap _exit INT TERM EXIT

# run in debug mode, if set
[[ "${DEBUG}" == "true" ]] && set -x

if [ -f /lgsm_bootstrap.sh ]; then
    # shellcheck disable=SC1091
    source /lgsm_bootstrap.sh
fi

# shellcheck disable=SC1091
source /lgsm_functions.bash
# shellcheck disable=SC1091
source /lgsm_variables.bash

if [ $# = 0 ]; then
    # no command
    fn_check_user

    # shellcheck disable=SC1091
    source /lgsm_install.sh
    # shellcheck disable=SC1091
    source /lgsm_gameserver.sh
    # shellcheck disable=SC1091
    source /lgsm_start.sh

    if [ -f /lgsm_console.sh ]; then
        # shellcheck disable=SC1091
        source /lgsm_console.sh
    fi

    tail -f /dev/null
else
    # execute the command passed through docker
    "$@"
fi

exit 0
