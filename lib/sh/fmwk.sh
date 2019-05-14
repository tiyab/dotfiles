#!/usr/bin/env bash
# --------------------------------------------------------------------------- #
# SCRIPT NAME : fmwk.sh
# DESCRIPTION : Small bash framework for colored output and trace
# AUTHOR(S)   : Stéphane DAMOUR
# LICENSE     : GNU GPLv3
# --------------------------------------------------------------------------- #

# FROM: http://www.ludovicocaldara.net/dba/bash-tips-4-use-logging-levels/

DATE=$(date +"%F %T")

readonly CRED="\e[31m" # Red
readonly CGREEN="\e[32m" # Green
readonly CYELLOW="\e[33m" # Yellow
readonly CBLUE="\e[34m" # Blue
readonly CPURPLE="\e[35m" # Purple
readonly CCYAN="\e[36m" # Cyan
readonly CGRAY="\e[90m" # Gray
readonly CRESET="\e[0m"    # Text Reset

# verbosity levels
readonly SILENT=0
readonly CRIT=1
readonly ERROR=2
readonly WARNING=3
readonly NOTIF=4
readonly INFO=5
readonly DEBUG=6
# Default set to 4 - NOTIF
VERBOSE=4

function separator(){
  printf -v res %120s "";
  printf "${CGRAY}%s${CRESET}\n" "${res// /━}"
}

function trace() {
  COLOR=${1}
  EVENT_LVL=${2}
  EVENT_MSG=${3}
  if [[ "${VERBOSE}" -ge "${VERBOSE_LVL}" ]]; then
    printf "%s ${COLOR}%10s${CRESET} - %s\n" "${DATE}" "${EVENT_LVL}" "${EVENT_MSG}"
  fi
}

## tracesilent prints output even in silent mode
function tracesilent() {
  VERBOSE_LVL=${SILENT}
  trace "${CGRAY}" "" "${1}"
}
function tracenotify() {
  VERBOSE_LVL=${NOTIF}
  trace "${CPURPLE}" "╰[ ⁰﹏⁰ ]╯" "${1}"
}
function tracesuccess() {
  VERBOSE_LVL=${NOTIF}
  trace "${CGREEN}" "SUCCESS" "${1}"
}
function tracewarning() {
  VERBOSE_LVL=${WARNING}
  trace "${CYELLOW}" "WARNING" "${1}"
}
function traceinfo() {
  VERBOSE_LVL=${INFO}
  trace "${CBLUE}" "INFO" "${1}"
}
function traceerror() {
  VERBOSE_LVL=${ERROR}
  trace "${CRED}" "ERROR" "$1"
}
function tracecrit() {
  VERBOSE_LVL=${CRIT}
  trace "${CRED}" "FATAL" "${1}"
}
function tracecommand() {
  VERBOSE_LVL=${DEBUG}
  trace "${CGRAY}" "DEBUG" "${1}"
  # shellcheck disable=2091
  $(${1}) > /dev/null 2>&1
}
function tracedebug() {
  VERBOSE_LVL=${DEBUG}
  trace "${CGRAY}" "DEBUG" "${1}"
}
function tracedumpvar() {
  for var in "$@" ; do
    tracedebug "${var}=${!var}"
  done
}

function logstart() {
  mkdir -p "${LOG_DIR}"
  touch "${LOG_FILE}"
  pipe="/tmp/${LOG_FILE##*/}.pipe"
  mkfifo -m 700 "${pipe}"
  exec 3>&1
  tee "${LOG_FILE}" < "$pipe" >&1 &
  teepid=$!
  exec 1>"${pipe}"
  PIPE_OPEN=1
  tracesilent "Logging to ${LOG_FILE}"
}

function logstop() {
  if [[ ${PIPE_OPEN} ]]; then
    exec 1<&3
    sleep 0.2
    if ps -j $teepid >/dev/null; then
      sleep 1
      kill $teepid
    fi
    rm -f "${pipe}"
    unset PIPE_OPEN
  fi
}
