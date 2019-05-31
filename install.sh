#!/usr/bin/env bash
# --------------------------------------------------------------------------- #
# SCRIPT NAME : install.sh
# DESCRIPTION : Unattended script to configure dotfiles and MacOS configuration
# AUTHOR(S)   : TiYab
# LICENSE     : GNU GPLv3
# --------------------------------------------------------------------------- #

GITDIR="${HOME}/Git"
PROJECTDIR="${GITDIR}/dotfiles"
PROJECTURL="https://github.com/tiyab/dotfiles.git"
BREWFILE="${PROJECTDIR}/Brewfile"

main() {
  sudo_get_password
  git_make_dir
  homebrew_install
  git_clone_project
  homebrew_install_brewfile
  sshkey_config
  shell_set_default
  shell_set_prezto
  hostsfile_update
  vim_install_vundle
  vscode_set_config
  os_customize
}

function sudo_get_password() {
    echo "==> Prompting for sudo password"
    if sudo --validate; then
        # Keep-alive
        while true; do sudo --non-interactive true; \
          sleep 10; kill -0 "$$" || exit; done 2>/dev/null &
        echo "==> Sudo password updated"
    else
        echo "==> Sudo password update failed"
        exit 1
    fi
}

function git_make_dir() {
  echo "==> Creating Git directory"
  mkdir -p "${GITDIR}"
}

function git_clone_project() {
  echo "==> Cloning dotfiles project locally"
  if [[ -d "${PROJECTDIR}" ]]; then
    echo "==> dotfiles already exists; checking for updates"
    git -C "${PROJECTDIR}" pull
  else
    git clone "${PROJECTURL}" "${PROJECTDIR}"
  fi
}

function homebrew_install() {
  if [[ "${OSTYPE}" == darwin* ]]; then
    if ! command -v brew &>/dev/null; then
      echo "==> Installing Homebrew"
      # Unattended installation of Homebrew
      if ! CI=1 /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; then
        echo "==> Homebrew installation failed, the installation script may be unavailable..."
        exit 1
      fi
      brew install git
    fi
  fi
}

function homebrew_install_brewfile() {
  echo "==> Installing tap/formulas/casks from Brewfile"
  if /usr/local/bin/brew bundle install --file="${BREWFILE}"; then
    echo "==> All tap/formulas/casks from Brewfile are installed"
  else
    echo "==> Failed to install tap/formulas/casks from Brewfile"
  fi
}

function shell_set_default() {
  if command -v zsh &>/dev/null; then
    if [[ "$SHELL" != *zsh* ]]; then
      echo "==> Setting up zsh as default shell for ${USER}"
      sudo chsh -s /usr/local/bin/zsh "${USER}"
      if [[ $(dscl . -read /Users/"${USER}" UserShell) == "UserShell: /usr/local/bin/zsh" ]]; then
        echo "==> zsh is now the default shell"
      else
        echo "==> Failed to set zsh as default shell"
      fi
    fi
  fi
}

function shell_set_prezto() {
  echo "==> Setting up prezto for zsh"
  if [[ -d "${HOME}/.zprezto" ]]; then
    echo "==> prezto already install, running update"
    git -C "${HOME}/.zprezto" pull
  else
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${HOME}/.zprezto"
  fi
  shopt -s extglob
  # shellcheck disable=SC2154
  if [[ -d ${PROJECTDIR}/files/zsh ]]; then
    echo "==> Setting up custom zsh configuration"
    find "${PROJECTDIR}/files/zsh" -type f -name 'z*' -exec sh -c 'name=$(basename ${1}); ln -sf ${1} ${HOME}/.${name}' _ {} \;
    ln -sfF "${PROJECTDIR}/files/zsh/zsh" "${HOME}/.zsh"
  else
    echo "==> Setting up default prezto configuration"
    find "${HOME}/.zprezto/runcoms" -type f -name 'z*' -exec sh -c 'name=$(basename ${1}); ln -sf ${1} ${HOME}/.${name}' _ {} \;
  fi
  echo "==> prezto for zsh has been setup"
  shopt -u extglob
}

function sshkey_config() {
  if [[ -f ${HOME}/.ssh/id_rsa && -f ${HOME}/.ssh/id_rsa.pub ]]; then
    echo "==> Existing SSH keys detected, skipping SSH keys creation"
  else
    echo "==> Generating new ssh key"
    ssh-keygen -t rsa -C "${USER}@$HOSTNAME" -q -N '' -f "${HOME}/.ssh/id_rsa"
    echo "==> ssh key available in ${HOME}/.ssh"
  fi
}

function hostsfile_update() {
  echo "==> Updating /etc/hosts from someonewhocares.org"
  if sudo curl -s -o /etc/hosts https://someonewhocares.org/hosts/hosts; then
    echo "==> /etc/hosts has been successfully updated"
  else
    echo "==> Failed to update /etc/hosts"
  fi
}

function vim_install_vundle() {
  echo "==> Vundle installation"
  if command -v vim &>/dev/null; then
    if [[ -d "${HOME}/.vim/bundle/Vundle.vim" ]]; then
      echo "==> Updating Vundle"
      git -C "${HOME}/.vim/bundle/Vundle.vim" pull
    else
      echo "==> Installing Vundle"
      git clone https://github.com/VundleVim/Vundle.vim.git "${HOME}/.vim/bundle/Vundle.vim"
      if [[ -f ${PROJECTDIR}/files/vimrc ]]; then
        echo "==> Setting up custom vimrc"
        ln -sf "${PROJECTDIR}/files/vimrc" "${HOME}/.vimrc"
        echo "==> Installing plugins"
        # Unattended installation of vundle plugins
        # https://github.com/VundleVim/Vundle.vim/issues/511#issuecomment-134251209
        echo | vim +PluginInstall +qall &>/dev/null
      fi
    fi
  else
    echo "==> Vim not installed"
  fi
}

function vscode_set_config() {
  echo "==> Setting up settings for VSCode"
  if [[ -f ${PROJECTDIR}/files/vscode/settings.json ]]; then
    ln -sf "${PROJECTDIR}/files/vscode/settings.json" "${HOME}/Library/Application Support/Code/User/settings.json"
  fi
  echo "==> Setting up keybindings for VSCode"
  if [[ -f ${PROJECTDIR}/files/vscode/keybindings.json ]]; then
    ln -sf "${PROJECTDIR}/files/vscode/keybindings.json" "${HOME}/Library/Application Support/Code/User/keybindings.json"
  fi
}

function os_customize() {
  if [[ ${OSTYPE} == darwin* ]]; then
    echo "==> Customizing MacOS"
    "${PROJECTDIR}"/macos.sh "${PROJECTDIR}"
  fi
}

main "$@"
