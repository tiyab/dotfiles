#!/usr/bin/env bash
# --------------------------------------------------------------------------- #
# SCRIPT NAME : install.sh
# DESCRIPTION : Unattended script to configure dotfiles and MacOS configuration
# AUTHOR(S)   : TiYab, Adam Eivy
# LICENSE     : GNU GPLv3
# --------------------------------------------------------------------------- #

RUNDIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
LOGDIR="${RUNDIR}/log"
CONFIGDIR="${RUNDIR}/config"
FILESDIR="${RUNDIR}/files"
LIBDIR="${RUNDIR}/lib"
BACKUP_DIR="${HOME}/dotfiles_backup"
LOGFILE="${LOGDIR}/$(date +"%Y%m%d%H%M%S").${BASH_SOURCE##*/}.log"

export LOGFILE
export VERBOSE

# CD into script directory
cd "${RUNDIR}" || exit
# shellcheck disable=SC1091
# shellcheck source=lib/sh/fmwk.sh
source "${LIBDIR}/sh/fmwk.sh"
# shellcheck disable=SC1091
# shellcheck source=lib/sh/isntallers.sh
source "${LIBDIR}/sh/installers.sh"

OPTIND=1
while getopts ":SVD" opt; do
  case ${opt} in
    S) VERBOSE=${SILENT}; tracedebug "SILENT mode ON";;
    V) VERBOSE=${INFO}; tracedebug "VERBOSE mode ON";;
    D) VERBOSE=${DEBUG}; tracedebug "DEBUG mode ON";;
    *) VERBOSE=${NOTIF};;
  esac
done

function backup() {
  separator
  tracenotify "● Configuring backup"
  traceinfo "Creating backup directory"
  tracecommand "mkdir -p ${BACKUP_DIR}"
  if [[ -d ${BACKUP_DIR} ]]; then
    traceinfo "Backup directory: ${BACKUP_DIR}"
  else
    traceerror "Failed to create ${BACKUP_DIR}"
    tracewarning "No backup directory detected"
    tracewarning "The script will automatically proceed in 10s"
    tracewarning "or Press any key to exit now"
    if read -rsn1 -t10; then
      traceinfo "Exiting"
      exit 1
    fi
  fi
  traceinfo "Backuping hosts file"
  tracecommand "cp -a /etc/hosts ${BACKUP_DIR}"
  if [[ -f ${BACKUP_DIR}/hosts && $(md5 -q /etc/hosts) == $(md5 -q "${BACKUP_DIR}"/hosts) ]]; then
    tracesuccess "/etc/hosts backup done"
  fi
  traceinfo "Backuping SSH keys"
  if [[ -d ${HOME}/.ssh ]]; then
    tracecommand "cp -aR ${HOME}/.ssh ${BACKUP_DIR}/dotfiles/ssh"
  fi
  traceinfo "Backuping existing dotfiles"
  tracecommand "mkdir -p ${BACKUP_DIR}/dotfiles"
  tracecommand "shopt -s dotglob"
  tracecommand "find ${HOME} -type f -name '.*' -maxdepth 1 -exec cp {} ${BACKUP_DIR}/dotfiles/ \;"
  tracecommand "shopt -u dotglob"
  tracesuccess "Backup done"
}

function passwordlesssudo() {
  separator
  tracenotify "● SUDO configuration"
  tracecommand "sudo -v"
  traceinfo "Setting up passwordless SUDO"
  if ! grep "#includedir /private/etc/sudoers.d" /etc/sudoers > /dev/null 2>&1; then
    traceinfo "Adding option to load sudoers from /private/etc/sudoers.d/"
    tracecommand "sudo echo \"#includedir /private/etc/sudoers.d\" >> /etc/sudoers"
  fi

  if ! grep "${LOGNAME} ALL=(ALL) NOPASSWD:ALL" /private/etc/sudoers.d/"${LOGNAME}" > /dev/null 2>&1; then
    traceinfo "Creating sudoer file for ${LOGNAME}"
    # Dont know how to use tracecommand with the next command :/
    tracedebug "sudo sh -c \"echo \"${LOGNAME} ALL=(ALL) NOPASSWD:ALL\" > /private/etc/sudoers.d/${LOGNAME}\""
    sudo sh -c "echo \"${LOGNAME} ALL=(ALL) NOPASSWD:ALL\" > /private/etc/sudoers.d/${LOGNAME}"
    tracecommand "sudo chmod 440 /private/etc/sudoers.d/*"
    tracesuccess "Passwordless SUDO active"
  else
    tracecommand "sudo chmod 440 /private/etc/sudoers.d/*"
    traceinfo "Passowrdless SUDO already configured"
  fi
}

function getconfig() {
  separator
  tracenotify "● Getting configuration information"
  if [[ "$(md5 -q "${CONFIGDIR}/config.yaml")" == "367d9ad33b978d94ddc5e6e8ba6af7f3" ]]; then
    traceerror "Please update ${CONFIGDIR}/config.yaml file"
    exit 1
  fi
  if [[ -f ${CONFIGDIR}/config.yaml && -s ${CONFIGDIR}/config.yaml ]]; then
    while IFS=': ' read -r key value; do
      case $key in
        '#'*) ;;
        *) eval "$key"="${value}"
      esac
    done < "${CONFIGDIR}/config.yaml"
    traceinfo "Setting variables"
  else
    traceerror "Missing ${CONFIGDIR}/config.yaml file or empty"
    exit 1
  fi
}

function hostconfig() {
  separator
  tracenotify "● Hosts file configuration"
  traceinfo "Configuring /etc/hosts from someonewhocares.org"
  tracecommand "sudo curl -s -o test.hosts https://someonewhocares.org/hosts/hosts"
  if [[ $(md5 -q /etc/hosts) != $(md5 -q /etc/hosts.bk) ]]; then
    tracesuccess "/etc/hosts has been updated"
  else
    traceerror "Failed to retrieve last version of hosts file"
  fi
}

function sshconfig() {
  separator
  tracenotify "● SSH keys configuration"
  if [[ -f ${HOME}/.ssh/id_rsa && -f ${HOME}/.ssh/id_rsa.pub ]]; then
    traceinfo "Existing SSH keys detected, skipping SSH keys creation"
  else
    traceinfo "Generating new ssh keys"
    tracedebug "ssh keygen -t rsa -C \"${GITUSER}@${HOSTNAME}\" -q"
    if [[ -f ${HOME}/.ssh/id_rsa && -f ${HOME}/.ssh/id_rsa.pub ]]; then
      tracesuccess "New ssh keys available in ${HOME}/.ssh"
    else
      traceerror "Failed to create SSH keys"
    fi
  fi  
}

function xcodeconfig() {
  separator
  tracenotify "● XCode installation"
  tracecommand "xcode-select --install"
  tracedebug "sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  tracedebug "sudo xcodebuild -license accept"
}

function brewconfig() {
  separator
  tracenotify "● Homebrew installation"
  if [[ ! $(command -v brew) ]]; then
    traceinfo "Installing Homebrew"
    # Unattended installation of Homebrew
    tracedebug "CI=1 /usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\""
    if ! CI=1 /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; then
      traceerror "Homebrew installation failed, the installation script may be unavailable"
      exit 1
    fi
  else
    traceinfo "Updating Homebrew"
    tracecommand "brew update"
    traceinfo "Upgrading brew packages"
    tracecommand "brew upgrade"
    tracesuccess "Homebrew updated & upgraded"
  fi

  tracenotify "● brew-cask installation"
  traceinfo "Installing caskroom/cask"
  tracedebug "brew tap caskroom/cask"
  if brew tap caskroom/cask; then
    tracesuccess "caskroom/cask installed"
  fi

  tracenotify "● Brew app installation"
  while IFS= read -r brew; do
    brewinstall "${brew}"
  done < "${CONFIGDIR}/brew.yaml"
  tracenotify "● Casks app installation"
  while IFS= read -r cask; do
    caskinstall "${cask}"
  done < "${CONFIGDIR}/cask.yaml"

  traceinfo "Cleanup homebrew"
  tracedebug "brew cleanup --force"
  tracedebug "rm -rf /Library/Caches/Homebrew/*"
}

function gitconfig() {
  separator
  # skip those GUI clients, git command-line all the way
  tracenotify "● GIT installation"
  brewinstall git
  tracenotify "● GIT configuration"
  traceinfo "Setting up global .gitconfig"
  tracecommand "cp -a ${FILESDIR}/gitconfig ${HOME}/.gitconfig"
  tracecommand "sed -ie 's/GITHUBNAME/${FIRSTNAME} ${LASTNAME}/g' ${HOME}/.gitconfig"
  tracecommand "sed -ie 's/GITHUBMAIL/${EMAIL}/g' ${HOME}/.gitconfig"
  tracecommand "sed -ie 's/GITUSER/${GITUSER}/g' ${HOME}/.gitconfig"

  traceinfo "Setting up directory for Git projects"
  tracecommand "mkdir -p ${GITDIR}"
}

function zshconfig() {
  separator
  # update zsh to latest
  tracenotify "● ZSH installation"
  brewinstall zsh
  tracenotify "● ZSH configuration"
  traceinfo "Setting up zsh as default shell for ${USER}"
  tracecommand "sudo chsh -s /usr/local/bin/zsh ${USER}"
  if [[ $(dscl . -read /Users/"${USER}" UserShell) == "UserShell: /usr/local/bin/zsh" ]]; then
    tracesuccess "zsh is now the default shell"
  else
    traceerror "Failed to set zsh as default shell"
  fi

  traceinfo "Setting up prezto for zsh"
  if [[ -d "${HOME}/.zprezto" ]]; then
    # If zprezto already exists remove it
    traceinfo "Removing previous installation of prezto"
    tracecommand "rm -rf ${HOME}/.zprezto"
  fi
    # and get the most recent version
  tracecommand "git clone --recursive https://github.com/sorin-ionescu/prezto.git \"${HOME}/.zprezto\""
  tracecommand "shopt -s extglob"
  # shellcheck disable=SC2154
  tracecommand "find ${HOME}/.zprezto/runcoms -type f -name 'z*' -exec sh -c 'name=$(basename {}); ln -sf {} ${HOME}/.${name}' _ {} \;"
  tracecommand "shopt -u extglob"
  if [[ -f ${FILESDIR}/zprofile ]]; then
    traceinfo "Setting up custom .zprofile"
    tracecommand "ln -sf ${FILESDIR}/zprofile $HOME/.zprofile"
  fi
  if [[ -f ${FILESDIR}/zshrc ]]; then
    traceinfo "Setting up custom .zshrc"
    tracecommand "ln -sf ${FILESDIR}/zshrc $HOME/.zshrc"
  fi
  tracesuccess "prezto for zsh has been setup"
}

function fontconfig() {
  separator
  # need fontconfig to install/build fonts
  tracenotify "● FONTCONFIG installation"
  tracecommand "brew tap caskroom/fonts"
  brewinstall fontconfig
}

function vimconfig() {
  separator
  tracenotify "● VIM installation"
  traceinfo "Vim installation"
  brewinstall vim
  traceinfo "Setting up custom vimrc"
  if [[ -f ${FILESDIR}/vimrc ]]; then
    tracecommand "ln -sf ${SCRIPT_DIR}/files/vimrc $HOME/.vimrc"
  fi
  traceinfo "Installing Vundle"
  if ! git clone https://github.com/VundleVim/Vundle.vim.git "${HOME}"/.vim/bundle/Vundle.vim; then
    traceerror "Failed to download Vundle"
  else
    traceinfo "Installing VIM plugins"
    tracecommand "vim +PluginInstall +qall"
    tracesuccess "Vundle has been installed"
  fi
}

function vscodeconfig() {
  separator
  tracenotify "● VSCode configuration"
  traceinfo "VS Code installation"
  caskinstall visual-studio-code
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

function dotfiles() {
  tracenotify "DOTFILES CONFIGURATION"
  hostconfig
  sshconfig
  xcodeconfig
  brewconfig
  gitconfig
  zshconfig
  fontconfig
  vimconfig
  vscodeconfig
  tracesuccess "DONE"
}

function ossettings() {
  separator
  tracenotify "OS CONFIGURATION"
  traceinfo "Closing any system preferences to prevent issues with automated changes"
  # tracecommand doesn't work for the following command
  tracedebug "osascript -e 'quit app \"System Preferences.app\"'"
  osascript -e 'quit app "System Preferences.app"'

  # --------------------------------------------------------------------------- #
  # Security
  # --------------------------------------------------------------------------- #
  # Based on:
  # https://github.com/drduh/macOS-Security-and-Privacy-Guide
  # https://benchmarks.cisecurity.org/tools2/osx/CIS_Apple_OSX_10.12_Benchmark_v1.0.0.pdf
  tracenotify "● Security settings"
  traceinfo "Enabling firewall"
  #   0 = off
  #   1 = on for specific sevices
  #   2 = on for essential services
  tracecommand "sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1"

  # Source: https://support.apple.com/kb/PH18642
  traceinfo "Enabling firewall stealth mode"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -int 1"

  traceinfo "Enabling firewall logging"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -int 1"

  # traceinfo "Denying automatically signed software for receinving incoming connections"
  # tracecommand "sudo defaults write /Library/Preferences/com.apple.alf allowsignedenabled -bool false"

  # traceinfo "Setting firewall log to 90 days"
  # sudo perl -p -i -e 's/rotate=seq compress file_max=5M all_max=50M/rotate=utc compress file_max=5M ttl=90/g' "/etc/asl.conf"
  # sudo perl -p -i -e 's/appfirewall.log file_max=5M all_max=50M/appfirewall.log rotate=utc compress file_max=5M ttl=90/g' "/etc/asl.conf"

  # (uncomment if above is not commented out)
  # traceinfo "Reloading firewall"
  # tracecommand "launchctl unload /System/Library/LaunchAgents/com.apple.alf.useragent.plist"
  # tracecommand "sudo launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist"
  # tracecommand "sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist"
  # tracecommand "launchctl load /System/Library/LaunchAgents/com.apple.alf.useragent.plist"

  traceinfo "Disabling IR remote control"
  # true = enabled
  # false = disabled
  tracecommand "sudo defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool false"
  traceinfo "Switching off bluetooth completely"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0"
  tracecommand "sudo launchctl unload /System/Library/LaunchDaemons/com.apple.blued.plist"
  tracecommand "sudo launchctl load /System/Library/LaunchDaemons/com.apple.blued.plist"

  #traceinfo "Disabling Wifi captive portal"
  #tracecommand "sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control Active -bool false"

  traceinfo "Disabling remote apple events"
  tracecommand "sudo systemsetup -setremoteappleevents off"

  traceinfo "Disabling remote login"
  tracecommand "sudo systemsetup -setremotelogin off"

  traceinfo "Disabling wake-on modem"
  tracecommand "sudo systemsetup -setwakeonmodem off"

  traceinfo "Disabling wake-on LAN"
  tracecommand "sudo systemsetup -setwakeonnetworkaccess off"

  # traceinfo "Disabling file-sharing via AFP or SMB"
  # tracecommand "sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist"
  # tracecommand "sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist"

  # traceinfo "Displaying login window as name and password"
  # tracecommand "sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true"

  traceinfo "Deactivating password hints"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 0"

  traceinfo "Disable guest account login"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false"

  # traceinfo "Locking automatically the login keychain after 6 hours of inactivity"
  # tracecommand "security set-keychain-settings -t 21600 -l ~/Library/Keychains/login.keychain"

  # traceinfo "Activating re-auth afecter destroying FileVault key when going into standby mode"
  # Source: https://web.archive.org/web/20160114141929/http://training.apple.com/pdf/WP_FileVault2.pdf
  # tracecommand "sudo pmset destroyfvkeyonstandby 1"

  # traceinfo "Disabling Bonjour multicast advertisements"
  # tracecommand "sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true"

  # traceinfo "Disabling the crash reporter"
  # tracecommand "defaults write com.apple.CrashReporter DialogType -string \"none\""

  # traceinfo "Disabling diagnostic reports"
  # tracecommand "sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.SubmitDiagInfo.plist"

  # traceinfo "Setting authentication log events to 90 days"
  # tracecommand "sudo perl -p -i -e 's/rotate=seq file_max=5M all_max=20M/rotate=utc file_max=5M ttl=90/g' "/etc/asl/com.apple.authd""

  # traceinfo "Setting installation events log to a year"
  # tracecommand "sudo perl -p -i -e 's/format=bsd/format=bsd mode=0640 rotate=utc compress file_max=5M ttl=365/g' "/etc/asl/com.apple.install""

  # traceinfo "Increasing the retention time for system.log and secure.log"
  # tracecommand "sudo perl -p -i -e 's/\/var\/log\/wtmp.*$/\/var\/log\/wtmp   \t\t\t640\ \ 31\    *\t\@hh24\ \J/g' "/etc/newsyslog.conf""

  # traceinfo "Keeping kernel events log for 30 days"
  # tracecommand "sudo perl -p -i -e 's|flags:lo,aa|flags:lo,aa,ad,fd,fm,-all,^-fa,^-fc,^-cl|g' /private/etc/security/audit_control"
  # tracecommand "sudo perl -p -i -e 's|filesz:2M|filesz:10M|g' /private/etc/security/audit_control"
  # tracecommand "sudo perl -p -i -e 's|expire-after:10M|expire-after: 30d |g' /private/etc/security/audit_control"

  traceinfo "Disabling \"Are you sure you want to open this application?\" dialog"
  tracecommand "defaults write com.apple.LaunchServices LSQuarantine -bool false"

  # --------------------------------------------------------------------------- #
  # SSD-specific tweaks
  # --------------------------------------------------------------------------- #
  tracenotify "● SSD specific tweaks"
  traceinfo "Disabling local Time Machine snapshots"
  tracecommand "sudo tmutil disablelocal"

  traceinfo "Disabling hibernation (speeds up entering sleep mode)"
  tracecommand "sudo pmset -a hibernatemode 0"

  traceinfo "Removing the sleep image file to save disk space"
  tracecommand "sudo rm -rf /Private/var/vm/sleepimage"
  traceinfo "Creating a zero-byte file instead… and make sure it can’t be rewritten"
  tracecommand "sudo touch /Private/var/vm/sleepimage"
  tracecommand "sudo chflags uchg /Private/var/vm/sleepimage"

  traceinfo "Disabling disk sudden motion sensor (not useful for SSDs)"
  tracecommand "sudo pmset -a sms 0"

  # --------------------------------------------------------------------------- #
  # Optional / Experimental
  # --------------------------------------------------------------------------- #
  tracenotify "● Optional"
  traceinfo "Setting computer name"
  tracecommand "sudo scutil --set ComputerName ${HOSTNAME}"
  tracecommand "sudo scutil --set HostName ${HOSTNAME}"
  tracecommand "sudo scutil --set LocalHostName ${HOSTNAME}"
  tracecommand "sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string ${HOSTNAME}"

  # traceinfo "Disabling smooth scrolling"
  # (Uncomment if you’re on an older Mac that messes up the animation)
  # tracecommand "defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false;ok"

  # traceinfo "Disabling Resume system-wide"
  # tracecommand "defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false;ok"
  # TODO: might want to enable this again and set specific apps that this works great for
  # e.g. defaults write com.microsoft.word NSQuitAlwaysKeepsWindows -bool true

  # traceinfo "Fixing ancient UTF-8 bug in QuickLook (http://mths.be/bbo)""
  # Commented out, as this is known to cause problems in various Adobe apps :(
  # See https://github.com/mathiasbynens/dotfiles/issues/237
  # tracecommand "echo \"0x08000100:0\" > ~/.CFUserTextEncoding;ok"

  # traceinfo "Stopping iTunes from responding to the keyboard media keys"
  # tracecommand "launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist"

  # traceinfo "Showing icons for hard drives, servers, and removable media on the desktop"
  # tracecommand "defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true"
  # tracecommand "defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true"
  # tracecommand "defaults write com.apple.finder ShowMountedServersOnDesktop -bool true"
  # tracecommand "defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true;ok"

  # traceinfo "Enabling the MacBook Air SuperDrive on any Mac"
  # tracecommand "sudo nvram boot-args=\"mbasd=1\""

  traceinfo "Wiping all (default) app icons from the Dock"
  # This is only really useful when setting up a new Mac, or if you don’t use the Dock to launch apps.
  tracecommand "defaults write com.apple.dock persistent-apps -array \"\""

  # traceinfo "Enabling the 2D Dock"
  # tracecommand "defaults write com.apple.dock no-glass -bool true"

  traceinfo "Disabling the Launchpad gesture (pinch with thumb and three fingers)"
  tracecommand "defaults write com.apple.dock showLaunchpadGestureEnabled -int 0"

  traceinfo "Add a spacer to the left side of the Dock (where the applications are)"
  tracecommand "defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type=\"spacer-tile\";}'"
  traceinfo "Add a spacer to the right side of the Dock (where the Trash is)"
  tracecommand "defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type=\"spacer-tile\";}'"

  # --------------------------------------------------------------------------- #
  tracenotify "● Standard System Changes"
  # --------------------------------------------------------------------------- #
  # traceinfo "Setting boot in verbose mode (not MacOS GUI mode)"
  # tracecommand "sudo nvram boot-args=\"-v\""

  traceinfo "Activating 'locate' command"
  tracecommand "sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist"

  traceinfo "Setting standby delay to 24 hours (default is 1 hour)"
  tracecommand "sudo pmset -a standbydelay 86400"

  traceinfo "Disabling the sound effects on boot"
  tracecommand "sudo nvram SystemAudioVolume=\" \""

  traceinfo "Menu bar: disabling transparency"
  tracecommand "defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false"

  traceinfo "Menu bar: hiding the Time Machine, Volume, User, and Bluetooth icons"
  for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
    defaults write "${domain}" dontAutoLoad -array \
      "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
      "/System/Library/CoreServices/Menu Extras/Volume.menu" \
      "/System/Library/CoreServices/Menu Extras/User.menu"
  done
  defaults write com.apple.systemuiserver menuExtras -array \
    "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
    "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
    "/System/Library/CoreServices/Menu Extras/Battery.menu" \
    "/System/Library/CoreServices/Menu Extras/Clock.menu"

  traceinfo "Setting highlight color to yellow (from Monokai Pro)"
  tracecommand "defaults write NSGlobalDomain AppleHighlightColor -string '251 219 100'"

  traceinfo "Setting sidebar icon size to small"
  tracecommand "defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1"

  traceinfo "Setting scrollbars WhenScrolling"
  tracecommand "defaults write NSGlobalDomain AppleShowScrollBars -string 'WhenScrolling'"
  # Possible values: `WhenScrolling`, `Automatic` and `Always`

  traceinfo "Increasing window resize speed for Cocoa applications"
  tracecommand "defaults write NSGlobalDomain NSWindowResizeTime -float 0.001"

  traceinfo "Expanding save panel by default"
  tracecommand "defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true"
  tracecommand "defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true"

  traceinfo "Expanding print panel by default"
  tracecommand "defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true"
  tracecommand "defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true"

  traceinfo "Setting save to disk (not to iCloud) by default"
  tracecommand "defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false"

  traceinfo "Automatically quit printer app once the print jobs complete"
  tracecommand "defaults write com.apple.print.PrintingPrefs  'Quit When Finished' -bool true"

  traceinfo "Disabling the \"Are you sure you want to open this application?\" dialog"
  tracecommand "defaults write com.apple.LaunchServices LSQuarantine -bool false"

  traceinfo "Removing duplicates in the \"Open With\" menu (also see 'lscleanup' alias)"
  tracecommand "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user"

  traceinfo "Display ASCII control characters using caret notation in standard text views"
  # Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
  tracecommand "defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true"

  traceinfo "Disable automatic termination of inactive apps"
  tracecommand "defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true"

  traceinfo "Disable the crash reporter"
  tracecommand "defaults write com.apple.CrashReporter DialogType -string 'none'"

  traceinfo "Set Help Viewer windows to non-floating mode"
  tracecommand "defaults write com.apple.helpviewer DevMode -bool true"

  traceinfo "Reveal IP, hostname, OS, etc. when clicking clock in login window"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName"

  traceinfo "Restart automatically if the computer freezes"
  tracecommand "sudo systemsetup -setrestartfreeze on"

  traceinfo "Never go into computer sleep mode"
  tracecommand "sudo systemsetup -setcomputersleep Off"

  traceinfo "Check for software updates daily, not just once per week"
  tracecommand "defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1"

  traceinfo "Disable Notification Center and remove the menu bar icon"
  tracecommand "launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist"

  traceinfo "Disable smart quotes as they’re annoying when typing code"
  tracecommand "defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false"

  traceinfo "Disable smart dashes as they’re annoying when typing code"
  tracecommand "defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false"

  # --------------------------------------------------------------------------- #
  tracenotify "● Trackpad, mouse, keyboard, Bluetooth accessories, and input"
  # --------------------------------------------------------------------------- #

  traceinfo "Trackpad: enable tap to click for this user and for the login screen"
  tracecommand "defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true"
  tracecommand "defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1"
  tracecommand "defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1"

  traceinfo "Trackpad: map bottom right corner to right-click"
  tracecommand "defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2"
  tracecommand "defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true"
  tracecommand "defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1"
  tracecommand "defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true"

  # traceinfo "Disable 'natural' (Lion-style) scrolling"
  # tracecommand "defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false"

  traceinfo "Increase sound quality for Bluetooth headphones/headsets"
  tracecommand "defaults write com.apple.BluetoothAudioAgent \"Apple Bitpool Min (editable)\" -int 40"

  traceinfo "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
  tracecommand "defaults write NSGlobalDomain AppleKeyboardUIMode -int 3"

  traceinfo "Use scroll gesture with the Ctrl (^) modifier key to zoom"
  tracecommand "defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true"
  tracecommand "defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144"
  traceinfo "Follow the keyboard focus while zoomed in"
  tracecommand "defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true"

  traceinfo "Disable press-and-hold for keys in favor of key repeat"
  tracecommand "defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false"

  traceinfo "Set a blazingly fast keyboard repeat rate"
  traceinfo "defaults write NSGlobalDomain KeyRepeat -int 2"
  traceinfo "defaults write NSGlobalDomain InitialKeyRepeat -int 10"

  traceinfo "Set language and text formats (english/US)"
  tracecommand "defaults write NSGlobalDomain AppleLanguages -array 'en'"
  tracecommand "defaults write NSGlobalDomain AppleLocale -string 'en_US@currency=EUR'"
  tracecommand "defaults write NSGlobalDomain AppleMeasurementUnits -string 'Centimeters'"
  tracecommand "defaults write NSGlobalDomain AppleMetricUnits -bool true"

  traceinfo "Disable auto-correct"
  tracecommand "defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false"

  # --------------------------------------------------------------------------- #
  tracenotify "● Configuring the Screen"
  # --------------------------------------------------------------------------- #

  # traceinfo "Require password immediately after sleep or screen saver begins"
  # tracecommand "defaults write com.apple.screensaver askForPassword -int 1"
  # tracecommand "defaults write com.apple.screensaver askForPasswordDelay -int 0"

  traceinfo "Save screenshots to the desktop screenshot folder"
  tracecommand "mkdir -p ${HOME}/Desktop/screenshots"
  tracecommand "defaults write com.apple.screencapture location -string ${HOME}/Desktop/screenshots"

  traceinfo "Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)"
  tracecommand "defaults write com.apple.screencapture type -string 'png'"

  traceinfo "Disable shadow in screenshots"
  tracecommand "defaults write com.apple.screencapture disable-shadow -bool true"

  traceinfo "Enable subpixel font rendering on non-Apple LCDs"
  tracecommand "defaults write NSGlobalDomain AppleFontSmoothing -int 2"

  traceinfo "Enable HiDPI display modes (requires restart)"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true"

  # --------------------------------------------------------------------------- #
  tracenotify "● Finder Configs"
  # --------------------------------------------------------------------------- #
  traceinfo "Keep folders on top when sorting by name (Sierra only)"
  tracecommand "defaults write com.apple.finder _FXSortFoldersFirst -bool true"

  traceinfo "Allow quitting via ⌘ + Q; doing so will also hide desktop icons"
  tracecommand "defaults write com.apple.finder QuitMenuItem -bool true"

  traceinfo "Disable window animations and Get Info animations"
  tracecommand "defaults write com.apple.finder DisableAllAnimations -bool true"

  traceinfo "Set Downloads as the default location for new Finder windows"
  # For other paths, use 'PfLo' and 'file:///full/path/here/'
  # defaults write com.apple.finder NewWindowTarget -string "PfDe"
  tracecommand "defaults write com.apple.finder NewWindowTarget -string 'PfLo'"
  tracecommand "defaults write com.apple.finder NewWindowTargetPath -string \"file://${HOME}/Downloads/\""

  # traceinfo "Show hidden files by default"
  # tracecommand "defaults write com.apple.finder AppleShowAllFiles -bool true"

  traceinfo "Show all filename extensions"
  tracecommand "defaults write NSGlobalDomain AppleShowAllExtensions -bool true"

  traceinfo "Show status bar"
  tracecommand "defaults write com.apple.finder ShowStatusBar -bool true"

  traceinfo "Show path bar"
  tracecommand "defaults write com.apple.finder ShowPathbar -bool true"

  traceinfo "Allow text selection in Quick Look"
  tracecommand "defaults write com.apple.finder QLEnableTextSelection -bool true"

  traceinfo "Display full POSIX path as Finder window title"
  tracecommand "defaults write com.apple.finder _FXShowPosixPathInTitle -bool true"

  traceinfo "When performing a search, search the current folder by default"
  tracecommand "defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'"

  traceinfo "Disable the warning when changing a file extension"
  tracecommand "defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false"

  traceinfo "Enable spring loading for directories"
  tracecommand "defaults write NSGlobalDomain com.apple.springing.enabled -bool true"

  traceinfo "Remove the spring loading delay for directories"
  tracecommand "defaults write NSGlobalDomain com.apple.springing.delay -float 0"

  traceinfo "Avoid creating .DS_Store files on network volumes"
  tracecommand "defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true"

  traceinfo "Disable disk image verification"
  tracecommand "defaults write com.apple.frameworks.diskimages skip-verify -bool true"
  tracecommand "defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true"
  tracecommand "defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true"

  traceinfo "Automatically open a new Finder window when a volume is mounted"
  tracecommand "defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true"
  tracecommand "defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true"
  tracecommand "defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true"

  traceinfo "Use list view in all Finder windows by default"
  # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
  tracecommand "defaults write com.apple.finder FXPreferredViewStyle -string 'Nlsv'"

  traceinfo "Disable the warning before emptying the Trash"
  tracecommand "defaults write com.apple.finder WarnOnEmptyTrash -bool false"

  traceinfo "Empty Trash securely by default"
  tracecommand "defaults write com.apple.finder EmptyTrashSecurely -bool true"

  traceinfo "Enable AirDrop over Ethernet and on unsupported Macs traceinfo Lion"
  tracecommand "defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true"

  traceinfo "Show the ~/Library folder"
  tracecommand "chflags nohidden ~/Library"

  traceinfo "Expand the following File Info panes: \"General\", \"Open with\", and \"Sharing & Permissions\""
  tracecommand "defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true"

  # --------------------------------------------------------------------------- #
  tracenotify "● Dock & Dashboard"
  # --------------------------------------------------------------------------- #
  traceinfo "Set the dock orientation to left"
  tracecommand "default write com.apple.dock orientation -string 'left'"

  traceinfo "Enable highlight hover effect for the grid view of a stack (Dock)"
  tracecommand "defaults write com.apple.dock mouse-over-hilite-stack -bool true"

  traceinfo "Set the icon size of Dock items to 24 pixels"
  tracecommand "defaults write com.apple.dock tilesize -int 24"

  traceinfo "Change minimize/maximize window effect to scale"
  tracecommand "defaults write com.apple.dock mineffect -string 'scale'"

  traceinfo "Minimize windows into their application’s icon"
  tracecommand "defaults write com.apple.dock minimize-to-application -bool true"

  traceinfo "Enable spring loading for all Dock items"
  tracecommand "defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true"

  traceinfo "Show indicator lights for open applications in the Dock"
  tracecommand "defaults write com.apple.dock show-process-indicators -bool true"

  traceinfo "Don’t animate opening applications from the Dock"
  tracecommand "defaults write com.apple.dock launchanim -bool false"

  traceinfo "Speed up Mission Control animations"
  tracecommand "defaults write com.apple.dock expose-animation-duration -float 0.1"

  traceinfo "Don’t group windows by application in Mission Control"
  # (i.e. use the old Exposé behavior instead)
  tracecommand "defaults write com.apple.dock expose-group-by-app -bool false"

  traceinfo "Disable Dashboard"
  tracecommand "defaults write com.apple.dashboard mcx-disabled -bool true"

  traceinfo "Don’t show Dashboard as a Space"
  tracecommand "defaults write com.apple.dock dashboard-in-overlay -bool true"

  traceinfo "Don’t automatically rearrange Spaces based on most recent use"
  tracecommand "defaults write com.apple.dock mru-spaces -bool false"

  traceinfo "Remove the auto-hiding Dock delay"
  tracecommand "defaults write com.apple.dock autohide-delay -float 0"
  traceinfo "Remove the animation when hiding/showing the Dock"
  tracecommand "defaults write com.apple.dock autohide-time-modifier -float 0"

  traceinfo "Automatically hide and show the Dock"
  tracecommand "defaults write com.apple.dock autohide -bool true"

  traceinfo "Make Dock icons of hidden applications translucent"
  tracecommand "defaults write com.apple.dock showhidden -bool true"

  traceinfo "Make Dock more transparent"
  tracecommand "defaults write com.apple.dock hide-mirror -bool true"

  traceinfo "Reset Launchpad, but keep the desktop wallpaper intact"
  tracecommand "find ${HOME}/Library/Application Support/Dock -name '*-*.db' -maxdepth 1 -delete"

  # --------------------------------------------------------------------------- #
  tracenotify "● Hot Corner configuration"
  # --------------------------------------------------------------------------- #
  # Possible values:
  #  0: no-op
  #  2: Mission Control
  #  3: Show application windows
  #  4: Desktop
  #  5: Start screen saver
  #  6: Disable screen saver
  #  7: Dashboard
  # 10: Put display to sleep
  # 11: Launchpad
  # 12: Notification Center

  traceinfo "Top left screen corner → Mission Control"
  tracecommand "defaults write com.apple.dock wvous-tl-corner -int 0"
  tracecommand "defaults write com.apple.dock wvous-tl-modifier -int 0"
  traceinfo "Top right screen corner → Desktop"
  tracecommand "defaults write com.apple.dock wvous-tr-corner -int 0"
  tracecommand "defaults write com.apple.dock wvous-tr-modifier -int 0"
  traceinfo "Bottom right screen corner → Start screen saver"
  tracecommand "defaults write com.apple.dock wvous-br-corner -int 0"
  tracecommand "defaults write com.apple.dock wvous-br-modifier -int 0"

  # --------------------------------------------------------------------------- #
  tracenotify "● Configuring Safari & WebKit"
  # --------------------------------------------------------------------------- #
  traceinfo "Set Safari’s home page to ‘about:blank’ for faster loading"
  tracecommand "defaults write com.apple.Safari HomePage -string 'about:blank'"

  traceinfo "Prevent Safari from opening ‘safe’ files automatically after downloading"
  tracecommand "defaults write com.apple.Safari AutoOpenSafeDownloads -bool false"

  traceinfo "Allow hitting the Backspace key to go to the previous page in history"
  tracecommand "defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true"

  traceinfo "Hide Safari’s bookmarks bar by default"
  tracecommand "defaults write com.apple.Safari ShowFavoritesBar -bool false"

  traceinfo "Hide Safari’s sidebar in Top Sites"
  tracecommand "defaults write com.apple.Safari ShowSidebarInTopSites -bool false"

  traceinfo "Disable Safari’s thumbnail cache for History and Top Sites"
  tracecommand "defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2"

  traceinfo "Enable Safari’s debug menu"
  tracecommand "defaults write com.apple.Safari IncludeInternalDebugMenu -bool true"

  traceinfo "Make Safari’s search banners default to Contains instead of Starts With"
  tracecommand "defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false"

  traceinfo "Remove useless icons from Safari’s bookmarks bar"
  tracecommand "defaults write com.apple.Safari ProxiesInBookmarksBar '()'"

  traceinfo "Enable the Develop menu and the Web Inspector in Safari"
  tracecommand "defaults write com.apple.Safari IncludeDevelopMenu -bool true"
  tracecommand "defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true"
  tracecommand "defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true"

  traceinfo "Add a context menu item for showing the Web Inspector in web views"
  tracecommand "defaults write NSGlobalDomain WebKitDeveloperExtras -bool true"

  # --------------------------------------------------------------------------- #
  tracenotify "● Configuring Mail"
  # --------------------------------------------------------------------------- #
  traceinfo "Disable send and reply animations in Mail.app"
  tracecommand "defaults write com.apple.mail DisableReplyAnimations -bool true"
  tracecommand "defaults write com.apple.mail DisableSendAnimations -bool true"

  traceinfo "Copy email addresses as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app"
  tracecommand "defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false"

  traceinfo "Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app"
  tracecommand "defaults write com.apple.mail NSUserKeyEquivalents -dict-add 'Send' -string '@\\U21a9'"

  traceinfo "Display emails in threaded mode, sorted by date (oldest at the top)"
  tracecommand "defaults write com.apple.mail DraftsViewerAttributes -dict-add 'DisplayInThreadedMode' -string 'yes'"
  tracecommand "defaults write com.apple.mail DraftsViewerAttributes -dict-add 'SortedDescending' -string 'yes'"
  tracecommand "defaults write com.apple.mail DraftsViewerAttributes -dict-add 'SortOrder' -string 'received-date'"

  traceinfo "Disable inline attachments (just show the icons)"
  tracecommand "defaults write com.apple.mail DisableInlineAttachmentViewing -bool true"

  traceinfo "Disable automatic spell checking"
  tracecommand "defaults write com.apple.mail SpellCheckingBehavior -string 'NoSpellCheckingEnabled'"

  # --------------------------------------------------------------------------- #
  tracenotify "● Spotlight"
  # --------------------------------------------------------------------------- #
  # traceinfo "Hide Spotlight tray-icon (and subsequent helper)"
  # tracecommand "sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search"

  traceinfo "Disable Spotlight indexing for any volume that gets mounted and has not yet been indexed"
  # Use `sudo mdutil -i off "/Volumes/foo"` to stop indexing any volume.
  tracecommand "sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array '/Volumes'"
  traceinfo "Change indexing order and disable some file types from being indexed"
  defaults write com.apple.spotlight orderedItems -array \
    '{"enabled" = 1;"name" = "APPLICATIONS";}' \
    '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
    '{"enabled" = 1;"name" = "DIRECTORIES";}' \
    '{"enabled" = 1;"name" = "PDF";}' \
    '{"enabled" = 1;"name" = "FONTS";}' \
    '{"enabled" = 0;"name" = "DOCUMENTS";}' \
    '{"enabled" = 0;"name" = "MESSAGES";}' \
    '{"enabled" = 0;"name" = "CONTACT";}' \
    '{"enabled" = 0;"name" = "EVENT_TODO";}' \
    '{"enabled" = 0;"name" = "IMAGES";}' \
    '{"enabled" = 0;"name" = "BOOKMARKS";}' \
    '{"enabled" = 0;"name" = "MUSIC";}' \
    '{"enabled" = 0;"name" = "MOVIES";}' \
    '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
    '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
    '{"enabled" = 0;"name" = "SOURCE";}'
  traceinfo "Load new settings before rebuilding the index"
  tracecommand "killall mds"
  traceinfo "Make sure indexing is enabled for the main volume"
  tracecommand "sudo mdutil -i on /"
  # traceinfo "Rebuild the index from scratch"
  # tracecommand "sudo mdutil -E /"

  # --------------------------------------------------------------------------- #
  tracenotify "● Terminal & iTerm2"
  # --------------------------------------------------------------------------- #
  # traceinfo "Only use UTF-8 in Terminal.app"
  # tracecommand "defaults write com.apple.terminal StringEncodings -array 4"

  traceinfo "Use a modified version of the Solarized Dark theme by default in Terminal.app"
  TERM_PROFILE='Solarized.Dark.xterm-256color'
  CURRENT_PROFILE="$(defaults read com.apple.terminal 'Default Window Settings')"
  if [ "${CURRENT_PROFILE}" != "${TERM_PROFILE}" ]; then
    tracecommand "open ${FILESDIR}/terminal/${TERM_PROFILE}.terminal"
    sleep 1; # Wait a bit to make sure the theme is loaded
    tracecommand "defaults write com.apple.terminal 'Default Window Settings' -string ${TERM_PROFILE}"
    tracecommand "defaults write com.apple.terminal 'Startup Window Settings' -string ${TERM_PROFILE}"
  fi;

  traceinfo "Enable \"focus follows mouse\" for Terminal.app and all X11 apps"
  # i.e. hover over a window and start `typing in it without clicking first
  tracecommand "defaults write com.apple.terminal FocusFollowsMouse -bool true"
  # tracecommand "defaults write org.x.X11 wm_ffm -bool true"
  traceinfo "Installing the Solarized Light theme for iTerm (opening file)"
  tracecommand open "${FILESDIR}/terminal/Solarized.Light.itermcolors"
  traceinfo "Installing the Patched Solarized Dark theme for iTerm (opening file)"
  tracecommand open "${FILESDIR}/terminal/Solarized.Dark.Patch.itermcolors"
  traceinfo "Installing the Panda syntax theme for iTerm (opening file)"
  tracecommand "open ${FILESDIR}/terminal/panda.syntax.itermcolors"

  traceinfo "Don’t display the annoying prompt when quitting iTerm"
  tracecommand "defaults write com.googlecode.iterm2 PromptOnQuit -bool false"
  traceinfo "hide tab title bars"
  tracecommand "defaults write com.googlecode.iterm2 HideTab -bool true"
  traceinfo "set system-wide hotkey to show/hide iterm with ^\`"
  tracecommand "defaults write com.googlecode.iterm2 Hotkey -bool true"
  traceinfo "hide pane titles in split panes"
  tracecommand "defaults write com.googlecode.iterm2 ShowPaneTitles -bool false"
  traceinfo "animate split-terminal dimming"
  tracecommand "defaults write com.googlecode.iterm2 AnimateDimming -bool true"
  tracecommand "defaults write com.googlecode.iterm2 HotkeyChar -int 96"
  tracecommand "defaults write com.googlecode.iterm2 HotkeyCode -int 50"
  tracecommand "defaults write com.googlecode.iterm2 FocusFollowsMouse -int 1"
  tracecommand "defaults write com.googlecode.iterm2 HotkeyModifiers -int 262401"
  traceinfo "Make iTerm2 load new tabs in the same directory"
  tracecommand "/usr/libexec/PlistBuddy -c \"set 'New Bookmarks':0:'Custom Directory' Recycle' ~/Library/Preferences/com.googlecode.iterm2.plist"
  traceinfo "setting fonts"
  tracecommand "defaults write com.googlecode.iterm2 'Normal Font' -string 'PragmataPro Mono Liga 14'"
  tracecommand "defaults write com.googlecode.iterm2 'Non Ascii Font' -string 'PragmataPro Mono Liga 14'"
  traceinfo "reading iterm settings"
  tracecommand "defaults read -app iTerm"

  # --------------------------------------------------------------------------- #
  tracenotify "● Time Machine"
  # --------------------------------------------------------------------------- #
  traceinfo "Prevent Time Machine from prompting to use new hard drives as backup volume"
  tracecommand "defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true"

  traceinfo "Disable local Time Machine backups"
  tracecommand "hash tmutil"
  tracecommand "sudo tmutil disablelocal"

  # --------------------------------------------------------------------------- #
  tracenotify "● Activity Monitor"
  # --------------------------------------------------------------------------- #
  traceinfo "Show the main window when launching Activity Monitor"
  tracecommand "defaults write com.apple.ActivityMonitor OpenMainWindow -bool true"

  traceinfo "Visualize CPU usage in the Activity Monitor Dock icon"
  tracecommand "defaults write com.apple.ActivityMonitor IconType -int 5"

  traceinfo "Show all processes in Activity Monitor"
  tracecommand "defaults write com.apple.ActivityMonitor ShowCategory -int 0"

  traceinfo "Sort Activity Monitor results by CPU usage"
  tracecommand "defaults write com.apple.ActivityMonitor SortColumn -string 'CPUUsage'"
  tracecommand "defaults write com.apple.ActivityMonitor SortDirection -int 0"

  # --------------------------------------------------------------------------- #
  tracenotify "● Address Book, Dashboard, iCal, TextEdit, and Disk Utility"
  # --------------------------------------------------------------------------- #
  traceinfo "Enable the debug menu in Address Book"
  tracecommand "defaults write com.apple.addressbook ABShowDebugMenu -bool true"

  traceinfo "Enable Dashboard dev mode (allows keeping widgets on the desktop)"
  tracecommand "defaults write com.apple.dashboard devmode -bool true"

  traceinfo "Use plain text mode for new TextEdit documents"
  tracecommand "defaults write com.apple.TextEdit RichText -int 0"
  traceinfo "Open and save files as UTF-8 in TextEdit"
  tracecommand "defaults write com.apple.TextEdit PlainTextEncoding -int 4"
  tracecommand "defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4"

  traceinfo "Enable the debug menu in Disk Utility"
  tracecommand "defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true"
  tracecommand "defaults write com.apple.DiskUtility advanced-image-options -bool true"

  # --------------------------------------------------------------------------- #
  tracenotify "● Mac App Store"
  # --------------------------------------------------------------------------- #
  traceinfo "Enable the WebKit Developer Tools in the Mac App Store"
  tracecommand "defaults write com.apple.appstore WebKitDeveloperExtras -bool true"

  traceinfo "Enable Debug Menu in the Mac App Store"
  tracecommand "defaults write com.apple.appstore ShowDebugMenu -bool true"

  # --------------------------------------------------------------------------- #
  tracenotify "● Messages"
  # --------------------------------------------------------------------------- #
  traceinfo "Disable automatic emoji substitution (i.e. use plain text smileys)"
  tracecommand "defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'automaticEmojiSubstitutionEnablediMessage' -bool false"

  traceinfo "Disable smart quotes as it’s annoying for messages that contain code"
  tracecommand "defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'automaticQuoteSubstitutionEnabled' -bool false"

  traceinfo "Disable continuous spell checking"
  tracecommand "defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'continuousSpellCheckingEnabled' -bool false"

  # --------------------------------------------------------------------------- #
  # Kill affected applications
  # --------------------------------------------------------------------------- #
  traceinfo "OK. Note that some of these changes require a logout/restart to take effect."
  traceinfo "Killing affected applications (so they can reboot)...."
  for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" "Dock" "Finder" "Mail" "Messages" "Safari" "SizeUp" "SystemUIServer" "iCal"; do
    tracecommand "killall ${app}"
  done
  tracesuccess "DONE"
}

function cleanup() {
  traceinfo "Cleaning installation files"
  traceinfo "Making sure that the project has been clone to ${GITDIR}"
  tracecommand "git clone git@github.com:${GITUSER}/${GITPROJECT}.git ${GITDIR}"
  traceinfo "Saving modified config.yaml"
  tracecommand "cp -a ${CONFIGDIR}/config.yaml ${GITDIR}/dotfiles/config/config.yaml"
  traceinfo "Making sure that config.yaml is not uploaded to git"
  if ! grep "config/config.yaml" "${GITDIR}/dotfiles/.gitignore"; then
    tracecommand "echo \"config/config.yaml\" >> ${GITDIR}/dotfiles/.gitignore"
  fi
  if [[ ${KEEPSUDO} == false ]]; then
    traceinfo "Removing passwordless sudo"
    tracecommand "sudo rm -rf /private/etc/sudoers.d/${LOGNAME}"
  fi
}

logstart
tracedumpvar RUNDIR LOGDIR LOGFILE VERBOSE GITPROJECT GITUSER LASTNAME FIRSTNAME EMAIL GITDIR HOSTNAME KEEPSUDO
backup
passwordlesssudo
dotfiles
ossettings
cleanup
logstop

"${GITDIR}"/dotfiles/cleanup.sh "${SCRIPT_DIR}" "${GITDIR}"