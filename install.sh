#!/usr/bin/env bash
# --------------------------------------------------------------------------- #
# SCRIPT NAME : install.sh
# DESCRIPTION : Unattended script to configure dotfiles and MacOS configuration
# AUTHOR(S)   : TiYab, Adam Eivy
# LICENSE     : GNU GPLv3
# --------------------------------------------------------------------------- #

RUNDIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
LIBDIR="${RUNDIR}/lib"
BREWFILE="${RUNDIR}/Brewfile"
GITDIR="${HOME}/Git"
PROJECTDIR="${GITDIR}/dotfiles"
PROJECTURL="https://github.com/tiyab/dotfiles.git"

# shellcheck disable=SC1091
# shellcheck source=lib/sh/fmwk.sh
source "${LIBDIR}/sh/fmwk.sh"

main() {
  sudo_get_password
  homebrew_install
  homebrew_install_brewfile
  sshkey_config
  git_make_dir
  git_clone_project
  shell_set_default
  shell_set_prezto
  hostsfile_update
  vim_install_vundle
  vscode_set_config
  os_customize
}

function sudo_get_password() {
    traceinfo "Prompting for sudo password"
    if sudo --validate; then
        # Keep-alive
        while true; do sudo --non-interactive true; \
            sleep 10; kill -0 "$$" || exit; done 2>/dev/null &
        tracesuccess "Sudo password updated"
    else
        traceerror "Sudo password update failed"
        exit 1
    fi
}

function homebrew_install() {
  traceinfo "Installing Homebrew"
  if ! command -v brew > /dev/null; then
    # Unattended installation of Homebrew
    tracedebug "CI=1 /usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\""
    if ! CI=1 /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; then
      traceerror "Homebrew installation failed, the installation script may be unavailable..."
      exit 1
    fi
  fi
}

function homebrew_install_brewfile() {
  traceinfo "Installing tap/formulas/casks from Brewfile"
  tracedebug "/usr/local/bin/brew bundle install --file=${BREWFILE}"
  if /usr/local/bin/brew bundle install --file="${BREWFILE}"; then
    tracesuccess "All tap/formulas/casks from Brewfile are installed"
  else
    traceerror "Failed to install tap/formulas/casks from Brewfile"
  fi
}

function git_make_dir() {
  traceinfo "Git directory creation"
  tracecommand "mkdir -p ${GITDIR}"
}

function git_clone_project() {
  traceinfo "Cloning dotfiles project locally"
  if [[ -d "${GITDIR}/dotfiles" ]]; then
    traceinfo "dotfiles already exists; checking for updates"
    tracecommand "git -C ${GITDIR}/dotfiles pull"
  else
    tracecommand "git clone ${PROJECTURL} ${GITDIR}/dotfiles"
  fi
}

function shell_set_default() {
  if [[ $SHELL != *zsh* ]]; then
    traceinfo "Setting up zsh as default shell for ${USER}"
    tracecommand "sudo chsh -s /usr/local/bin/zsh ${USER}"
    if [[ $(dscl . -read /Users/"${USER}" UserShell) == "UserShell: /usr/local/bin/zsh" ]]; then
      tracesuccess "zsh is now the default shell"
    else
      traceerror "Failed to set zsh as default shell"
    fi
  fi
}

function shell_set_prezto() {
  traceinfo "Setting up prezto for zsh"
  if [[ -d "${HOME}/.zprezto" ]]; then
    traceinfo "prezto already install, running update"
    tracecommand "git -C ${HOME}/.zprezto pull"
  else
    tracecommand "git clone --recursive https://github.com/sorin-ionescu/prezto.git ${HOME}/.zprezto"
  fi
  tracecommand "shopt -s extglob"
  # shellcheck disable=SC2154
  if [[ -d "${GITPROJECT}/files/zsh" ]]; then
    traceinfo "Setting up custom zsh configuration"
    tracedebug "find ${PROJECTDIR}/files/zsh -name 'z*' -exec sh -c 'name=$(basename {}); ln -sf {} ${HOME}/.${name}' _ {} \;"
    find "${PROJECTDIR}/files/zsh" -name 'z*' -exec sh -c 'name=$(basename ${1}); ln -sf ${1} ${HOME}/.${name}' _ {} \;
  else
    traceinfo "Setting up default prezto configuration"
    tracedebug "find ${HOME}/.zprezto/runcoms -type f -name 'z*' -exec sh -c 'name=$(basename {}); ln -sf {} ${HOME}/.${name}' _ {} \;"
    find "${HOME}/.zprezto/runcoms" -type f -name 'z*' -exec sh -c 'name=$(basename ${1}); ln -sf ${1} ${HOME}/.${name}' _ {} \;
  fi
  tracesuccess "prezto for zsh has been setup"
  tracecommand "shopt -u extglob"
}

function sshkey_config() {
  if [[ -f ${HOME}/.ssh/id_rsa && -f ${HOME}/.ssh/id_rsa.pub ]]; then
    traceinfo "Existing SSH keys detected, skipping SSH keys creation"
  else
    traceinfo "Generating new ssh key"
    tracecommand "ssh-keygen -t rsa -C ${USER}@$HOSTNAME -q -N '' -f ${HOME}/.ssh/id_rsa"
    tracesuccess "ssh key available in ${HOME}/.ssh"
  fi
}

function hostsfile_update() {
  traceinfo "Updating /etc/hosts from someonewhocares.org"
  tracedebug "sudo curl -s -o /etc/hosts https://someonewhocares.org/hosts/hosts"
  if sudo curl -s -o /etc/hosts https://someonewhocares.org/hosts/hosts; then
    tracesuccess "/etc/hosts has been successfully updated"
  else
    traceerror "Failed to update /etc/hosts"
  fi
}

function vim_install_vundle() {
  traceinfo "Vundle installation"
  if command -v vim > /dev/null; then
    if [[ -d "${HOME}/.vim/bundle/Vundle.vim" ]]; then
      traceinfo "Updating Vundle"
      tracecommand "git -C ${HOME}/.vim/bundle/Vundle.vim pull"
    else
      traceinfo "Installing Vundle"
      tracecommand "git clone https://github.com/VundleVim/Vundle.vim.git ${HOME}/.vim/bundle/Vundle.vim"
      if [[ -f ${PROJECTDIR}/files/vimrc ]]; then
        traceinfo "Setting up custom vimrc"
        tracecommand "ln -sf ${PROJECTDIR}/files/vimrc $HOME/.vimrc"
        traceinfo "Installing plugins"
        tracecommand "vim +PluginInstall +qall"
      fi
    fi
  else
    traceerror "Vim not installed"
  fi
}

function vscode_set_config() {
  tracecommand "VScode configuration"
  traceinfo "Setting up settings for VSCode"
  if [[ -f ${FILES}/vscode/settings.json ]]; then
    tracecommand "cp -a ${FILES}/vscode/settings.json ${HOME}/Library/Application\ Support/Code/User/settings.json"
    if [[ $(md5 -q "${FILES}"/vscode/settings.json) != $(md5 -q "${HOME}"/Library/Application\ Support/Code/User/settings.json) ]]; then
      traceerror "Failed to copy VSCode settings"
    fi
  fi
  traceinfo "Setting up keybindings for VSCode"
  if [[ -f ${FILES}/vscode/keybindings.json ]]; then
    tracecommand "cp -a ${FILES}/vscode/keybindings.json ${HOME}/Library/Application\ Support/Code/User/keybindings.json"
    if [[ "$(md5 -q "${FILES}"/vscode/keybindings.json)" != "$(md5 -q "${HOME}"/Library/Application\ Support/Code/User/keybindings.json)" ]]; then
      traceerror "Failed to copy VSCode keybindings"
    fi
  fi
}

function os_customize() {
  traceinfo "Customizing MacOS"
  macos.sh
}

main "$@"
