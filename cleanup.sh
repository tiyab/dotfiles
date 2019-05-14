#!/usr/bin/env bash
# --------------------------------------------------------------------------- #
# SCRIPT NAME : cleanup.sh
# DESCRIPTION : clean after everything has been done
# AUTHOR(S)   : TiYab
# LICENSE     : GNU GPLv3
# --------------------------------------------------------------------------- #
RUN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
LIB_DIR="${RUN_DIR}/lib"
# shellcheck disable=SC1091
# shellcheck source=lib/sh/fmwk.sh
source "${LIB_DIR}/sh/fmwk.sh"

traceinfo "Deleting directory ${1} since it has been copied to ${2}"
tracecommand "rm -rf ${1}"
tracesuccess "Everything is done, rebooting in 10sec"
tracecommand "sleep 10"
tracecommand "sudo reboot"