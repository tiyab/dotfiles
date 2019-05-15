#!/usr/bin/env bash
# --------------------------------------------------------------------------- #
# SCRIPT NAME : installers.sh
# DESCRIPTION : Manage different installers
# AUTHOR(S)   : TiYab
# LICENSE     : GNU GPLv3
# --------------------------------------------------------------------------- #

function fontinstall(){
  traceinfo "Installing fonts from ${1}"
  tracecommand "find ${1} -type f -name '*.(ttf|ttc|otf)' -exec cp -a {} ${HOME}/Library/fonts \;"
}

function caskinstall(){
  if brew cask info "${1}" > /dev/null 2>&1; then
    if ! brew cask list "${1}" > /dev/null 2>&1; then
      tracecommand "brew cask install ${1}"
      tracesuccess "cask ${1} installed"
    else
      traceinfo "cask ${1} already installed"
    fi
  else
    traceerror "cask ${1} not available"
  fi
}

function brewinstall(){
  if brew info "${1}" > /dev/null 2>&1; then
    if ! brew list "${1}" > /dev/null 2>&1; then
      tracecommand "brew install ${1}"
      tracesuccess "formula ${1} installed"
    else
      traceinfo "formula ${1} already installed"
    fi
  else
    traceerror "formula ${1} not available"
  fi
}
