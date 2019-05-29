#!/usr/bin/env bash
# --------------------------------------------------------------------------- #
# SCRIPT NAME : macos.sh
# DESCRIPTION : Unattended script to configure dotfiles and MacOS configuration
# AUTHOR(S)   : TiYab, Adam Eivy
# LICENSE     : GNU GPLv3
# --------------------------------------------------------------------------- #

# shellcheck disable=SC1091
# shellcheck source=lib/sh/fmwk.sh
source "${LIBDIR}/sh/fmwk.sh"

main() {
  sys_pref_close
  update
  bluetooth "OFF"
  datetime
  screensaver
  sharing
  firewall
  infrared
  login
  ssd
  desktop
  dock
  system
  trackpad
  keyboard
  screenshot
  finder
  hotcorner
  safari
  mail
  spotlight
  terminal
  timemachine
  activitymonitor
  messages
  mas
  misc
}

function sys_pref_close () {
  traceinfo "Closing any instance of System Preferences.app"
  tracedebug "osascript -e 'quit app \"System Preferences.app\"'"
  osascript -e 'quit app "System Preferences.app"'
}

function update() {
  traceinfo "Activating Automatic Update"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -int 1"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool TRUE"
}

function bluetooth() {
  if [[ ${1} == ON ]]; then
    traceinfo "Switching ON Bluetooth"
    tracecommand "sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 1"
    tracecommand "sudo launchctl load /System/Library/LaunchDaemons/com.apple.blued.plist"
  else
    traceinfo "Switching OFF Bluetooth"
    tracecommand "sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0"
    tracecommand "sudo launchctl unload /System/Library/LaunchDaemons/com.apple.blued.plist"
  fi
}

function datetime() {
  traceinfo "Setting up automatic date & time"
  tracecommand "sudo systemsetup -setnetworktimeserver time.euro.apple.com"
  tracecommand "sudo systemsetup -setusingnetworktime on"
  tracecommand "sudo systemsetup -settimezone Europe/Paris"
}

function screensaver() {
  traceinfo "Setting up password immediately after sleep or screen saver begins"
  tracecommand "defaults write com.apple.screensaver askForPassword -int 1"
  tracecommand "defaults write com.apple.screensaver askForPasswordDelay -int 0"
}

function sharing() {
  traceinfo "Disabling Remote Apple Sharing"
  tracecommand "sudo systemsetup -setremoteappleevents off"
  traceinfo "Disabling Remote Login"
  tracecommand "sudo systemsetup -setremotelogin off"
  traceinfo "Disabling File Sharing"
  tracecommand "sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist"
  traceinfo "Disabling wake-on LAN"
  tracecommand "sudo systemsetup -setwakeonnetworkaccess off"
}

function firewall() {
  traceinfo "Enabling Firewall"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1"
  traceinfo "Enabling Firewall stealth mode"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -int 1"
  traceinfo "Enabling Firewall logging"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -int 1"
}

function infrared() {
  traceinfo "Disabling IR remote control"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool false"
}

function login() {
  traceinfo "Displaying login window as name and password"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true"
  traceinfo "Disabling password hints"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 0"
  traceinfo "Disabling guest account login"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false"
}

function ssd() {
  traceinfo "Disabling local Time Machine snapshots"
  tracecommand "sudo tmutil disable local"
  traceinfo "Disabling hibernation (speeds up entering sleep mode)"
  tracecommand "sudo pmset -a hibernatemode 0"
  # traceinfo "Removing the sleep image file to save disk space"
  # tracecommand "sudo rm -rf /Private/var/vm/sleepimage"
  # traceinfo "Creating a zero-byte file instead… and make sure it can’t be rewritten"
  # tracecommand "sudo touch /Private/var/vm/sleepimage"
  # tracecommand "sudo chflags uchg /Private/var/vm/sleepimage"
  traceinfo "Disabling disk sudden motion sensor (not useful for SSDs)"
  tracecommand "sudo pmset -a sms 0"
}

traceinfo "Disabling \"Are you sure you want to open this application?\" dialog"
tracecommand "defaults write com.apple.LaunchServices LSQuarantine -bool false"

function desktop() {
  traceinfo "Hiding icons for hard drives, servers, and removable media on the desktop"
  tracecommand "defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false"
  tracecommand "defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false"
  tracecommand "defaults write com.apple.finder ShowMountedServersOnDesktop -bool false"
  tracecommand "defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false"
}

function dock() {
  traceinfo "Wiping all (default) app icons from the Dock"
  # This is only really useful when setting up a new Mac, or if you don’t use the Dock to launch apps.
  tracecommand "defaults write com.apple.dock persistent-apps -array \"\""
  traceinfo "Enabling the 2D Dock"
  tracecommand "defaults write com.apple.dock no-glass -bool true"
  traceinfo "Setting Dock to the left"
  tracecommand "defaults write com.apple.dock orientation -string left"
  # traceinfo "Adding a spacer to the left side of the Dock (where the applications are)"
  # tracecommand "defaults write com.apple.dock persistent-apps -array-add '{tile-data=\"\"; tile-type=\"spacer-tile\";}'"
  # traceinfo "Adding a spacer to the right side of the Dock (where the Trash is)"
  # tracecommand "defaults write com.apple.dock persistent-others -array-add '{tile-data=\"\"; tile-type=\"spacer-tile\";}'"
  traceinfo "Enabling highlight hover effect for the grid view of a stack (Dock)"
  tracecommand "defaults write com.apple.dock mouse-over-hilite-stack -bool true"
  traceinfo "Setting the icon size of Dock items to 32 pixels"
  tracecommand "defaults write com.apple.dock tilesize -int 32"
  traceinfo "Changing minimize/maximize window effect to scale"
  tracecommand "defaults write com.apple.dock mineffect -string 'scale'"
  traceinfo "Minimizing windows into their application’s icon"
  tracecommand "defaults write com.apple.dock minimize-to-application -bool true"
  traceinfo "Enabling spring loading for all Dock items"
  tracecommand "defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true"
  traceinfo "Showing indicator lights for open applications in the Dock"
  tracecommand "defaults write com.apple.dock show-process-indicators -bool true"
  traceinfo "Removing opening animation applications from the Dock"
  tracecommand "defaults write com.apple.dock launchanim -bool false"
  traceinfo "Removing the auto-hiding Dock delay"
  tracecommand "defaults write com.apple.dock autohide-delay -float 0"
  traceinfo "Removing the animation when hiding/showing the Dock"
  tracecommand "defaults write com.apple.dock autohide-time-modifier -float 0"
  traceinfo "Automatically hide and show the Dock"
  tracecommand "defaults write com.apple.dock autohide -bool true"
  traceinfo "Setting Dock icons of hidden applications translucent"
  tracecommand "defaults write com.apple.dock showhidden -bool true"
  traceinfo "Setting Dock more transparent"
  tracecommand "defaults write com.apple.dock hide-mirror -bool true"
}

function system() {
  # traceinfo "Setting boot in verbose mode (not MacOS GUI mode)"
  # tracecommand "sudo nvram boot-args=\"-v\"
  traceinfo "Settings Interface style to Dark"
  tracecommand "defaults write 'Apple Global Domain' AppleInterfaceStyle Dark"
  traceinfo "Setting highlight color to yellow (System Preferences > General > Highlight color)"
  tracecommand "defaults write NSGlobalDomain AppleHighlightColor -string '1 0.937255 0.690196 Yellow'"
  traceinfo "Setting Apple Accent color to yellow (System Preferences > General > Accent color)"
  tracecommand "defaults write NSGlobalDomain AppleAccentColor -int 2"
  if [[ ! -f /var/db/locate.database ]]; then
    traceinfo "Initializing 'locate' command"
    tracecommand "sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist"
  fi
  traceinfo "Disabling the sound effects on boot"
  tracecommand "sudo nvram SystemAudioVolume=''"
  traceinfo "Menu bar: disabling transparency"
  tracecommand "defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false"
  traceinfo "Setting sidebar icon size to small"
  tracecommand "defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1"
  traceinfo "Setting scrollbars WhenScrolling (Options: WhenScrolling, Automatic, Always)"
  tracecommand "defaults write NSGlobalDomain AppleShowScrollBars -string 'WhenScrolling'"
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
  tracecommand "defaults write com.apple.print.PrintingPrefs 'Quit When Finished' -bool true"
  traceinfo "Disabling the 'Are you sure you want to open this application?' dialog"
  tracecommand "defaults write com.apple.LaunchServices LSQuarantine -bool false"
  traceinfo "Reveal IP, hostname, OS, etc. when clicking clock in login window"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName"
  traceinfo "Restart automatically if the computer freezes"
  tracecommand "sudo systemsetup -setrestartfreeze on"
  traceinfo "Never go into computer sleep mode"
  tracecommand "sudo systemsetup -setcomputersleep Off"
  traceinfo "Disable smart quotes as they’re annoying when typing code"
  tracecommand "defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false"
  traceinfo "Disable smart dashes as they’re annoying when typing code"
  tracecommand "defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false"
  traceinfo "Disable Notification Center and remove the menu bar icon"
  tracecommand "launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist"
}

function trackpad() {
  traceinfo "Disabling the Launchpad gesture (pinch with thumb and three fingers)"
  tracecommand "defaults write com.apple.dock showLaunchpadGestureEnabled -int 0"
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
}

function keyboard() {
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
}

function screenshot(){
  traceinfo "Save screenshots to the desktop screenshot folder"
  tracecommand "mkdir -p ${HOME}/Desktop/screenshots"
  tracecommand "defaults write com.apple.screencapture location -string ${HOME}/Desktop/screenshots"
  traceinfo "Save screenshots in PNG format (options: PNG, BMP, GIF, JPG, PDF, TIFF)"
  tracecommand "defaults write com.apple.screencapture type -string 'png'"
  traceinfo "Disable shadow in screenshots"
  tracecommand "defaults write com.apple.screencapture disable-shadow -bool true"
  traceinfo "Enable subpixel font rendering on non-Apple LCDs"
  tracecommand "defaults write NSGlobalDomain AppleFontSmoothing -int 2"
  traceinfo "Enable HiDPI display modes (requires restart)"
  tracecommand "sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true"
}

function finder() {
  traceinfo "Keep folders on top when sorting by name (Sierra only)"
  tracecommand "defaults write com.apple.finder _FXSortFoldersFirst -bool true"
  traceinfo "Allow quitting via ⌘ + Q; doing so will also hide desktop icons"
  tracecommand "defaults write com.apple.finder QuitMenuItem -bool true"
  traceinfo "Disable window animations and Get Info animations"
  tracecommand "defaults write com.apple.finder DisableAllAnimations -bool true"
  traceinfo "Set ~/Downloads as the default location for new Finder windows"
  tracecommand "defaults write com.apple.finder NewWindowTarget -string 'PfLo'"
  tracecommand "defaults write com.apple.finder NewWindowTargetPath -string file://${HOME}/Downloads/"
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
  traceinfo "Use list view in all Finder windows by default (Options: Nlsv, icnv, clmv, Flwv)"
  tracecommand "defaults write com.apple.finder FXPreferredViewStyle -string 'Nlsv'"
  traceinfo "Disable the warning before emptying the Trash"
  tracecommand "defaults write com.apple.finder WarnOnEmptyTrash -bool false"
  traceinfo "Empty Trash securely by default"
  tracecommand "defaults write com.apple.finder EmptyTrashSecurely -bool true"
  traceinfo "Enable AirDrop over Ethernet and on unsupported Macs"
  tracecommand "defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true"
  traceinfo "Show the ~/Library folder"
  tracecommand "chflags nohidden ~/Library"
  traceinfo "Expand the following File Info panes: 'General', 'Open with', and 'Sharing & Permissions'"
  tracecommand "defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true"
}

function hotcorner() {
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
}

function safari() {
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
}

function mail() {
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
}

function spotlight() {
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
}

function terminal() {
  traceinfo "Installing the Base16 default dark theme for iTerm (opening file)"
  if ! defaults read com.googlecode.iterm2 'Custom Color Presets' | grep 'base16-default-dark' > /dev/null; then
    tracecommand "open ${FILESDIR}/terminal/base16-default.dark.itermcolors"
  fi
  traceinfo "Don’t display the annoying prompt when quitting iTerm"
  tracecommand "defaults write com.googlecode.iterm2 PromptOnQuit -bool false"
  traceinfo "hide tab title bars"
  # tracecommand "defaults write com.googlecode.iterm2 HideTab -bool true"
  # traceinfo "set system-wide hotkey to show/hide iterm with ^\`"
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
}

function timemachine() {
  traceinfo "Prevent Time Machine from prompting to use new hard drives as backup volume"
  tracecommand "defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true"
  traceinfo "Disable local Time Machine backups"
  tracecommand "hash tmutil"
  tracecommand "sudo tmutil disable"
}

function activitymonitor() {
  traceinfo "Show the main window when launching Activity Monitor"
  tracecommand "defaults write com.apple.ActivityMonitor OpenMainWindow -bool true"
  traceinfo "Visualize CPU usage in the Activity Monitor Dock icon"
  tracecommand "defaults write com.apple.ActivityMonitor IconType -int 5"
  traceinfo "Show all processes in Activity Monitor"
  tracecommand "defaults write com.apple.ActivityMonitor ShowCategory -int 0"
  traceinfo "Sort Activity Monitor results by CPU usage"
  tracecommand "defaults write com.apple.ActivityMonitor SortColumn -string 'CPUUsage'"
  tracecommand "defaults write com.apple.ActivityMonitor SortDirection -int 0"
}

function messages() {
  traceinfo "Disable automatic emoji substitution (i.e. use plain text smileys)"
  tracecommand "defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'automaticEmojiSubstitutionEnablediMessage' -bool false"
  traceinfo "Disable smart quotes as it’s annoying for messages that contain code"
  tracecommand "defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'automaticQuoteSubstitutionEnabled' -bool false"
  traceinfo "Disable continuous spell checking"
  tracecommand "defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'continuousSpellCheckingEnabled' -bool false"
}

function mas() {
traceinfo "Enable the WebKit Developer Tools in the Mac App Store"
tracecommand "defaults write com.apple.appstore WebKitDeveloperExtras -bool true"

traceinfo "Enable Debug Menu in the Mac App Store"
tracecommand "defaults write com.apple.appstore ShowDebugMenu -bool true"
}

function misc() {
  traceinfo "Increase sound quality for Bluetooth headphones/headsets"
  tracecommand "defaults write com.apple.BluetoothAudioAgent \"Apple Bitpool Min (editable)\" -int 40"

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
}

main "$@"