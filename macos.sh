#!/usr/bin/env bash
# --------------------------------------------------------------------------- #
# SCRIPT NAME : macos.sh
# DESCRIPTION : Unattended script to configure dotfiles and MacOS configuration
# AUTHOR(S)   : TiYab, Adam Eivy
# LICENSE     : GNU GPLv3
# --------------------------------------------------------------------------- #

PROJECTDIR="${1}"

main() {
  sys_pref_close
  update
  bluetooth
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
  iterm
  timemachine
  activitymonitor
  messages
  mas
  misc
}

function sys_pref_close () {
  echo "==> Closing any instance of System Preferences.app"
  osascript -e 'quit app "System Preferences.app"'
}

function update() {
  echo "==> Update: Activating Automatic Update"
  sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -int 1
  sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool TRUE
}

function bluetooth() {
    # echo "==> Bluetooth: ON"
    echo "==> Bluetooth: OFF"
    # sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 1
    # sudo launchctl load /System/Library/LaunchDaemons/com.apple.blued.plist
    sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0
    sudo launchctl unload /System/Library/LaunchDaemons/com.apple.blued.plist
}

function datetime() {
  echo "==> Date & Time: Setting up automatic date & time"
  sudo systemsetup -setusingnetworktime on &>/dev/null
  echo "==> Date & Time: Using NTP time.euro.apple.com"
  sudo systemsetup -setnetworktimeserver time.euro.apple.com  &>/dev/null
  echo "==> Date & Time: Setting timezone to Europe/Paris"
  sudo systemsetup -settimezone Europe/Paris &>/dev/null
}

function screensaver() {
  echo "==> Sreensaver: Setting up password immediately after sleep or screen saver begins"
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0
}

function sharing() {
  echo "==> Sharing: Disabling Remote Apple Sharing"
  sudo systemsetup -setremoteappleevents off &>/dev/null
  echo "==> Sharing: Disabling Remote Login"
  sudo systemsetup -f -setremotelogin off &>/dev/null
  echo "==> SHaring: Disabling wake-on LAN"
  sudo systemsetup -setwakeonnetworkaccess off &>/dev/null
}

function firewall() {
  echo "==> Firewall: ON"
  sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
  echo "==> Firewall: Enabling stealth mode"
  sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -int 1
  echo "==> Firewall: Enabling logging"
  sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -int 1
}

function infrared() {
  echo "==> IR: Disabling remote control"
  sudo defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool false
}

function login() {
  echo "==> Login: Displaying login window as name and password"
  sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true
  echo "==> Login: Disabling password hints"
  sudo defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 0
  echo "==> Login: Disabling guest account"
  sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
}

function ssd() {
  echo "==> SSD: Disabling local Time Machine snapshots"
  sudo tmutil disable local
  echo "==> SSD: Disabling hibernation (speeds up entering sleep mode)"
  sudo pmset -a hibernatemode 0
  # echo "==> SSD: Removing the sleep image file to save disk space"
  # sudo rm -rf /Private/var/vm/sleepimage
  # echo "==> SSD: Creating a zero-byte file instead… and make sure it can’t be rewritten"
  # sudo touch /Private/var/vm/sleepimage
  # sudo chflags uchg /Private/var/vm/sleepimage
  echo "==> SSD: Disabling disk sudden motion sensor"
  sudo pmset -a sms 0
}

function desktop() {
  echo "==> Desjtop: Hiding icons for hard drives, servers, and removable media"
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
}

function dock() {
  echo "==> Dock: Wiping all (default) app icons"
  # This is only really useful when setting up a new Mac, or if you don’t use the Dock to launch apps.
  defaults write com.apple.dock persistent-apps -array ''
  echo "==> Dock: Enabling the 2D Dock"
  defaults write com.apple.dock no-glass -bool true
  echo "==> Dock: Positionning to the left"
  defaults write com.apple.dock orientation -string left
  # echo "==> Dock: Adding a spacer to the left side of the Dock (where the applications are)"
  # defaults write com.apple.dock persistent-apps -array-add '{tile-data=""; tile-type="spacer-tile";}'
  # echo "==> Dock: Adding a spacer to the right side of the Dock (where the Trash is)"
  # defaults write com.apple.dock persistent-others -array-add '{tile-data=""; tile-type="spacer-tile";}'
  echo "==> Dock: Enabling highlight hover effect for the grid view of a stack"
  defaults write com.apple.dock mouse-over-hilite-stack -bool true
  echo "==> Dock: Setting the icon size to 32 pixels"
  defaults write com.apple.dock tilesize -int 32
  echo "==> Dock: Changing minimize/maximize window effect to scale"
  defaults write com.apple.dock mineffect -string 'scale'
  echo "==> Dock: Minimizing windows into their application’s icon"
  defaults write com.apple.dock minimize-to-application -bool true
  echo "==> Dock: Enabling spring loading for all items"
  defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
  echo "==> Dock: Showing indicator lights for open applications"
  defaults write com.apple.dock show-process-indicators -bool true
  echo "==> Dock: Removing opening animation applications"
  defaults write com.apple.dock launchanim -bool false
  echo "==> Dock: Removing the auto-hiding delay"
  defaults write com.apple.dock autohide-delay -float 0
  echo "==> Dock: Removing the animation when hiding/showing"
  defaults write com.apple.dock autohide-time-modifier -float 0
  echo "==> Dock: Automatically hide and show"
  defaults write com.apple.dock autohide -bool true
  echo "==> Dock: Setting icons of hidden applications translucent"
  defaults write com.apple.dock showhidden -bool true
  echo "==> Dock: Setting Dock more transparent"
  defaults write com.apple.dock hide-mirror -bool true
}

function system() {
  # echo "==> Setting boot in verbose mode (not MacOS GUI mode)"
  # sudo nvram boot-args="-v"
  echo "==> Sytem: Settings Interface style to Dark"
  defaults write 'Apple Global Domain' AppleInterfaceStyle Dark
  echo "==> Sytem: Setting highlight color to yellow (System Preferences > General > Highlight color)"
  defaults write NSGlobalDomain AppleHighlightColor -string '1 0.937255 0.690196 Yellow'
  echo "==> Sytem: Setting Apple Accent color to yellow (System Preferences > General > Accent color)"
  defaults write NSGlobalDomain AppleAccentColor -int 2
  if [[ ! -f /var/db/locate.database ]]; then
    echo "==> Sytem: Initializing 'locate' command"
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
  fi
  echo "==> System: Deactivate opening application for the first time popup"
  sudo /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -all local,system,user
  echo "==> Sytem: Disabling the sound effects on boot"
  sudo nvram SystemAudioVolume=%01
  echo "==> Sytem: Menu bar: disabling transparency"
  defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false
  echo "==> Sytem: Setting sidebar icon size to small"
  defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1
  echo "==> Sytem: Setting scrollbars WhenScrolling (Options: WhenScrolling, Automatic, Always)"
  defaults write NSGlobalDomain AppleShowScrollBars -string 'WhenScrolling'
  echo "==> Sytem: Increasing window resize speed for Cocoa applications"
  defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
  echo "==> Sytem: Expanding save panel by default"
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
  echo "==> Sytem: Expanding print panel by default"
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
  echo "==> Sytem: Setting save to disk (not to iCloud) by default"
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
  echo "==> Sytem: Automatically quit printer app once the print jobs complete"
  defaults write com.apple.print.PrintingPrefs 'Quit When Finished' -bool true
  echo "==> Sytem: Disabling the 'Are you sure you want to open this application?' dialog"
  defaults write com.apple.LaunchServices LSQuarantine -bool false
  echo "==> Sytem: Reveal IP, hostname, OS, etc. when clicking clock in login window"
  sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
  echo "==> Sytem: Restart automatically if the computer freezes"
  sudo systemsetup -setrestartfreeze on
  echo "==> Sytem: Disabling sleep mode"
  sudo systemsetup -setcomputersleep Off &>/dev/null
  echo "==> Sytem: Disabling smart quotes as they’re annoying when typing code"
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  echo "==> Sytem: Disabling smart dashes as they’re annoying when typing code"
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
}

function trackpad() {
  echo "==> Trackpad: Disabling the Launchpad gesture (pinch with thumb and three fingers)"
  defaults write com.apple.dock showLaunchpadGestureEnabled -int 0
  echo "==> Trackpad: Enabling tap to click for this user and for the login screen"
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  echo "==> Trackpad: Mapping bottom right corner to right-click"
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
  # echo "==> Trackpad: Disabling 'natural' (Lion-style) scrolling"
  # defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
}

function keyboard() {
  echo "==> Keyboard: Enabling full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
  echo "==> Keyboard: Using scroll gesture with the Ctrl (^) modifier key to zoom"
  defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
  defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
  echo "==> Keyboard: Follow the keyboard focus while zoomed in"
  defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true
  echo "==> Keyboard: Disabling press-and-hold for keys in favor of key repeat"
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  echo "==> Keyboard: Set a blazingly fast keyboard repeat rate"
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 10
  echo "==> Keyboard: Setting language and text formats (english/US)"
  defaults write NSGlobalDomain AppleLanguages -array 'en'
  defaults write NSGlobalDomain AppleLocale -string 'en_US@currency=EUR'
  defaults write NSGlobalDomain AppleMeasurementUnits -string 'Centimeters'
  defaults write NSGlobalDomain AppleMetricUnits -bool true
  echo "==> Keyboard: Disabling auto-correct"
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
}

function screenshot(){
  echo "==> Screenshot: Save screenshots to the desktop screenshot folder"
  mkdir -p "${HOME}/Desktop/screenshots"
  defaults write com.apple.screencapture location -string "${HOME}/Desktop/screenshots"
  echo "==> Screenshot: Save screenshots in PNG format (options: PNG, BMP, GIF, JPG, PDF, TIFF)"
  defaults write com.apple.screencapture type -string 'png'
  echo "==> Screenshot: Disabling shadow in screenshots"
  defaults write com.apple.screencapture disable-shadow -bool true
  echo "==> Screenshot: Enable subpixel font rendering on non-Apple LCDs"
  defaults write NSGlobalDomain AppleFontSmoothing -int 2
  echo "==> Screenshot: Enable HiDPI display modes (requires restart)"
  sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true
}

function finder() {
  echo "==> Finder: Disabling 'Are you sure you want to open this application?' dialog"
  defaults write com.apple.LaunchServices LSQuarantine -bool false
  echo "==> Finder: Keep folders on top when sorting by name (Sierra only)"
  defaults write com.apple.finder _FXSortFoldersFirst -bool true
  echo "==> Finder: Allow quitting via ⌘ + Q; doing so will also hide desktop icons"
  defaults write com.apple.finder QuitMenuItem -bool true
  echo "==> Finder: Disabling window animations and Get Info animations"
  defaults write com.apple.finder DisableAllAnimations -bool true
  echo "==> Finder: Set ~/Downloads as the default location for new Finder windows"
  defaults write com.apple.finder NewWindowTarget -string 'PfLo'
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads/"
  # echo "==> Finder: Show hidden files by default"
  # defaults write com.apple.finder AppleShowAllFiles -bool true
  echo "==> Finder: Show all filename extensions"
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  echo "==> Finder: Show status bar"
  defaults write com.apple.finder ShowStatusBar -bool true
  echo "==> Finder: Show path bar"
  defaults write com.apple.finder ShowPathbar -bool true
  echo "==> Finder: Allow text selection in Quick Look"
  defaults write com.apple.finder QLEnableTextSelection -bool true
  echo "==> Finder: Display full POSIX path as Finder window title"
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
  echo "==> Finder: When performing a search, search the current folder by default"
  defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'
  echo "==> Finder: Disabling the warning when changing a file extension"
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  echo "==> Finder: Enable spring loading for directories"
  defaults write NSGlobalDomain com.apple.springing.enabled -bool true
  echo "==> Finder: Remove the spring loading delay for directories"
  defaults write NSGlobalDomain com.apple.springing.delay -float 0
  echo "==> Finder: Avoid creating .DS_Store files on network volumes"
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  echo "==> Finder: Disabling disk image verification"
  defaults write com.apple.frameworks.diskimages skip-verify -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true
  echo "==> Finder: Automatically open a new Finder window when a volume is mounted"
  defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
  defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
  defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
  echo "==> Finder: Use list view in all Finder windows by default (Options: Nlsv, icnv, clmv, Flwv)"
  defaults write com.apple.finder FXPreferredViewStyle -string 'Nlsv'
  echo "==> Finder: Disabling the warning before emptying the Trash"
  defaults write com.apple.finder WarnOnEmptyTrash -bool false
  echo "==> Finder: Empty Trash securely by default"
  defaults write com.apple.finder EmptyTrashSecurely -bool true
  echo "==> Finder: Enable AirDrop over Ethernet and on unsupported Macs"
  defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true
  echo "==> Finder: Show the ~/Library folder"
  chflags nohidden ~/Library
  echo "==> Finder: Expand the following File Info panes: 'General', 'Open with', and 'Sharing & Permissions'"
  defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true
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
  echo "==> HotCorner: Top left screen corner → Disable"
  defaults write com.apple.dock wvous-tl-corner -int 0
  defaults write com.apple.dock wvous-tl-modifier -int 0
  echo "==> HotCorner: Top right screen corner → Disable"
  defaults write com.apple.dock wvous-tr-corner -int 0
  defaults write com.apple.dock wvous-tr-modifier -int 0
  echo "==> HotCorner: Bottom left screen corner → Disable"
  defaults write com.apple.dock wvous-bl-corner -int 0
  defaults write com.apple.dock wvous-bl-modifier -int 0
  echo "==> HotCorner: Bottom right screen corner → Disable"
  defaults write com.apple.dock wvous-br-corner -int 0
  defaults write com.apple.dock wvous-br-modifier -int 0
}

function safari() {
  echo "==> Safari: Set Safari’s home page to ‘about:blank’ for faster loading"
  defaults write com.apple.Safari HomePage -string 'about:blank'
  echo "==> Safari: Prevent Safari from opening ‘safe’ files automatically after downloading"
  defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
  echo "==> Safari: Allow hitting the Backspace key to go to the previous page in history"
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true
  echo "==> Safari: Hide Safari’s bookmarks bar by default"
  defaults write com.apple.Safari ShowFavoritesBar -bool false
  echo "==> Safari: Hide Safari’s sidebar in Top Sites"
  defaults write com.apple.Safari ShowSidebarInTopSites -bool false
  echo "==> Safari: Disabling Safari’s thumbnail cache for History and Top Sites"
  defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2
  echo "==> Safari: Enable Safari’s debug menu"
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
  echo "==> Safari: Make Safari’s search banners default to Contains instead of Starts With"
  defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false
  echo "==> Safari: Remove useless icons from Safari’s bookmarks bar"
  defaults write com.apple.Safari ProxiesInBookmarksBar '()'
  echo "==> Safari: Enable the Develop menu and the Web Inspector in Safari"
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
  echo "==> Safari: Add a context menu item for showing the Web Inspector in web views"
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
}

function mail() {
  echo "==> Mail: Disabling send and reply animations in Mail.app"
  defaults write com.apple.mail DisableReplyAnimations -bool true
  defaults write com.apple.mail DisableSendAnimations -bool true
  echo "==> Mail: Copy email addresses as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app"
  defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false
  echo "==> Mail: Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app"
  defaults write com.apple.mail NSUserKeyEquivalents -dict-add 'Send' -string '@\\U21a9'
  echo "==> Mail: Display emails in threaded mode, sorted by date (oldest at the top)"
  defaults write com.apple.mail DraftsViewerAttributes -dict-add 'DisplayInThreadedMode' -string 'yes'
  defaults write com.apple.mail DraftsViewerAttributes -dict-add 'SortedDescending' -string 'yes'
  defaults write com.apple.mail DraftsViewerAttributes -dict-add 'SortOrder' -string 'received-date'
  echo "==> Mail: Disabling inline attachments (just show the icons)"
  defaults write com.apple.mail DisableInlineAttachmentViewing -bool true
  echo "==> Mail: Disabling automatic spell checking"
  defaults write com.apple.mail SpellCheckingBehavior -string 'NoSpellCheckingEnabled'
}

function spotlight() {
  echo "==> Spotlight: Change indexing order and disable some file types from being indexed"
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
  echo "==> Spotlight: Load new settings before rebuilding the index"
  sudo killall mds &>/dev/null
  echo "==> Spotlight: Make sure indexing is enabled for the main volume"
  sudo mdutil -i on / &>/dev/null
}

function iterm() {
  echo "==> iTerm2: Installing the Base16 default dark theme for iTerm (opening file)"
  if ! defaults read com.googlecode.iterm2 'Custom Color Presets' | grep 'base16-default.dark' &>/dev/null; then
    open "${PROJECTDIR}/files/iterm/base16-default.dark.itermcolors"
  fi
  echo "==> iTerm2: Don’t display the annoying prompt when quitting iTerm"
  defaults write com.googlecode.iterm2 PromptOnQuit -bool false
  echo "==> iTerm2: hide pane titles in split panes"
  defaults write com.googlecode.iterm2 ShowPaneTitles -bool false
  echo "==> iTerm2: animate split-terminal dimming"
  defaults write com.googlecode.iterm2 AnimateDimming -bool true
  defaults write com.googlecode.iterm2 HotkeyChar -int 96
  defaults write com.googlecode.iterm2 HotkeyCode -int 50
  defaults write com.googlecode.iterm2 FocusFollowsMouse -int 1
  defaults write com.googlecode.iterm2 HotkeyModifiers -int 262401
  echo "==> iTerm2: setting fonts"
  defaults write com.googlecode.iterm2 'Normal Font' -string 'PragmataPro Mono Liga 14'
  defaults write com.googlecode.iterm2 'Non Ascii Font' -string 'PragmataPro Mono Liga 14'
}

function timemachine() {
  echo "==> TimeMachine: Prevent Time Machine from prompting to use new hard drives as backup volume"
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
  echo "==> TimeMachine: Disabling local Time Machine backups"
  sudo tmutil disable
}

function activitymonitor() {
  echo "==> ActivityMonitor: Show the main window when launching Activity Monitor"
  defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
  echo "==> ActivityMonitor: Visualize CPU usage in the Activity Monitor Dock icon"
  defaults write com.apple.ActivityMonitor IconType -int 5
  echo "==> ActivityMonitor: Show all processes in Activity Monitor"
  defaults write com.apple.ActivityMonitor ShowCategory -int 0
  echo "==> ActivityMonitor: Sort Activity Monitor results by CPU usage"
  defaults write com.apple.ActivityMonitor SortColumn -string 'CPUUsage'
  defaults write com.apple.ActivityMonitor SortDirection -int 0
}

function messages() {
  echo "==> Messages: Disabling automatic emoji substitution (i.e. use plain text smileys)"
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'automaticEmojiSubstitutionEnablediMessage' -bool false
  echo "==> Messages: Disabling smart quotes as it’s annoying for messages that contain code"
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'automaticQuoteSubstitutionEnabled' -bool false
  echo "==> Messages: Disabling continuous spell checking"
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'continuousSpellCheckingEnabled' -bool false
}

function mas() {
echo "==> MAS: Enable the WebKit Developer Tools in the Mac App Store"
defaults write com.apple.appstore WebKitDeveloperExtras -bool true
echo "==> MAS: Enable Debug Menu in the Mac App Store"
defaults write com.apple.appstore ShowDebugMenu -bool true
}

function misc() {
  echo "==> Misc: Increase sound quality for Bluetooth headphones/headsets"
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

  echo "==> Misc: Enable the debug menu in Address Book"
  defaults write com.apple.addressbook ABShowDebugMenu -bool true

  echo "==> Misc: Enable Dashboard dev mode (allows keeping widgets on the desktop)"
  defaults write com.apple.dashboard devmode -bool true

  echo "==> Misc: Use plain text mode for new TextEdit documents"
  defaults write com.apple.TextEdit RichText -int 0
  echo "==> Misc: Open and save files as UTF-8 in TextEdit"
  defaults write com.apple.TextEdit PlainTextEncoding -int 4
  defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

  echo "==> Misc: Enable the debug menu in Disk Utility"
  defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
  defaults write com.apple.DiskUtility advanced-image-options -bool true

  echo "==> Misc: Speed up Mission Control animations"
  defaults write com.apple.dock expose-animation-duration -float 0.1

  echo "==> Misc: Don’t group windows by application in Mission Control"
  # (i.e. use the old Exposé behavior instead)
  defaults write com.apple.dock expose-group-by-app -bool false

  echo "==> Misc: Disabling Dashboard"
  defaults write com.apple.dashboard mcx-disabled -bool true

  echo "==> Misc: Don’t show Dashboard as a Space"
  defaults write com.apple.dock dashboard-in-overlay -bool true

  echo "==> Misc: Don’t automatically rearrange Spaces based on most recent use"
  defaults write com.apple.dock mru-spaces -bool false
}

main "$@"
