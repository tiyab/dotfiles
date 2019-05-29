#!/usr/bin/env bash
# --------------------------------------------------------------------------- #
# SCRIPT NAME : macos.sh
# DESCRIPTION : Unattended script to configure dotfiles and MacOS configuration
# AUTHOR(S)   : TiYab, Adam Eivy
# LICENSE     : GNU GPLv3
# --------------------------------------------------------------------------- #

GITDIR="${1}"
PROJECTDIR="${2}"

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
  iterm
  timemachine
  activitymonitor
  messages
  mas
  misc
}

function sys_pref_close () {
  echo "== Closing any instance of System Preferences.app"
  osascript -e 'quit app "System Preferences.app"'
}

function update() {
  echo "== Activating Automatic Update"
  sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -int 1
  sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool TRUE
}

function bluetooth() {
  if [[ ${1} == ON ]]; then
    echo "== Switching ON Bluetooth"
    sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 1
    sudo launchctl load /System/Library/LaunchDaemons/com.apple.blued.plist
  else
    echo "== Switching OFF Bluetooth"
    sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0
    sudo launchctl unload /System/Library/LaunchDaemons/com.apple.blued.plist
  fi
}

function datetime() {
  echo "== Setting up automatic date & time"
  sudo systemsetup -setnetworktimeserver time.euro.apple.com
  sudo systemsetup -setusingnetworktime on
  sudo systemsetup -settimezone Europe/Paris
}

function screensaver() {
  echo "== Setting up password immediately after sleep or screen saver begins"
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0
}

function sharing() {
  echo "== Disabling Remote Apple Sharing"
  sudo systemsetup -setremoteappleevents off
  echo "== Disabling Remote Login"
  sudo systemsetup -setremotelogin off
  echo "== Disabling File Sharing"
  sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist
  echo "== Disabling wake-on LAN"
  sudo systemsetup -setwakeonnetworkaccess off
}

function firewall() {
  echo "== Enabling Firewall"
  sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
  echo "== Enabling Firewall stealth mode"
  sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -int 1
  echo "== Enabling Firewall logging"
  sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -int 1
}

function infrared() {
  echo "== Disabling IR remote control"
  sudo defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool false
}

function login() {
  echo "== Displaying login window as name and password"
  sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true
  echo "== Disabling password hints"
  sudo defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 0
  echo "== Disabling guest account login"
  sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
}

function ssd() {
  echo "== Disabling local Time Machine snapshots"
  sudo tmutil disable local
  echo "== Disabling hibernation (speeds up entering sleep mode)"
  sudo pmset -a hibernatemode 0
  # echo "== Removing the sleep image file to save disk space"
  # sudo rm -rf /Private/var/vm/sleepimage
  # echo "== Creating a zero-byte file instead… and make sure it can’t be rewritten"
  # sudo touch /Private/var/vm/sleepimage
  # sudo chflags uchg /Private/var/vm/sleepimage
  echo "== Disabling disk sudden motion sensor (not useful for SSDs)"
  sudo pmset -a sms 0
}

echo "== Disabling 'Are you sure you want to open this application?' dialog"
defaults write com.apple.LaunchServices LSQuarantine -bool false

function desktop() {
  echo "== Hiding icons for hard drives, servers, and removable media on the desktop"
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
}

function dock() {
  echo "== Wiping all (default) app icons from the Dock"
  # This is only really useful when setting up a new Mac, or if you don’t use the Dock to launch apps.
  defaults write com.apple.dock persistent-apps -array ''
  echo "== Enabling the 2D Dock"
  defaults write com.apple.dock no-glass -bool true
  echo "== Setting Dock to the left"
  defaults write com.apple.dock orientation -string left
  # echo "== Adding a spacer to the left side of the Dock (where the applications are)"
  # defaults write com.apple.dock persistent-apps -array-add '{tile-data=""; tile-type="spacer-tile";}'
  # echo "== Adding a spacer to the right side of the Dock (where the Trash is)"
  # defaults write com.apple.dock persistent-others -array-add '{tile-data=""; tile-type="spacer-tile";}'
  echo "== Enabling highlight hover effect for the grid view of a stack (Dock)"
  defaults write com.apple.dock mouse-over-hilite-stack -bool true
  echo "== Setting the icon size of Dock items to 32 pixels"
  defaults write com.apple.dock tilesize -int 32
  echo "== Changing minimize/maximize window effect to scale"
  defaults write com.apple.dock mineffect -string 'scale'
  echo "== Minimizing windows into their application’s icon"
  defaults write com.apple.dock minimize-to-application -bool true
  echo "== Enabling spring loading for all Dock items"
  defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
  echo "== Showing indicator lights for open applications in the Dock"
  defaults write com.apple.dock show-process-indicators -bool true
  echo "== Removing opening animation applications from the Dock"
  defaults write com.apple.dock launchanim -bool false
  echo "== Removing the auto-hiding Dock delay"
  defaults write com.apple.dock autohide-delay -float 0
  echo "== Removing the animation when hiding/showing the Dock"
  defaults write com.apple.dock autohide-time-modifier -float 0
  echo "== Automatically hide and show the Dock"
  defaults write com.apple.dock autohide -bool true
  echo "== Setting Dock icons of hidden applications translucent"
  defaults write com.apple.dock showhidden -bool true
  echo "== Setting Dock more transparent"
  defaults write com.apple.dock hide-mirror -bool true
}

function system() {
  # echo "== Setting boot in verbose mode (not MacOS GUI mode)"
  # sudo nvram boot-args="-v"
  echo "== Settings Interface style to Dark"
  defaults write 'Apple Global Domain' AppleInterfaceStyle Dark
  echo "== Setting highlight color to yellow (System Preferences > General > Highlight color)"
  defaults write NSGlobalDomain AppleHighlightColor -string '1 0.937255 0.690196 Yellow'
  echo "== Setting Apple Accent color to yellow (System Preferences > General > Accent color)"
  defaults write NSGlobalDomain AppleAccentColor -int 2
  if [[ ! -f /var/db/locate.database ]]; then
    echo "== Initializing 'locate' command"
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
  fi
  echo "== Disabling the sound effects on boot"
  sudo nvram SystemAudioVolume=''
  echo "== Menu bar: disabling transparency"
  defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false
  echo "== Setting sidebar icon size to small"
  defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1
  echo "== Setting scrollbars WhenScrolling (Options: WhenScrolling, Automatic, Always)"
  defaults write NSGlobalDomain AppleShowScrollBars -string 'WhenScrolling'
  echo "== Increasing window resize speed for Cocoa applications"
  defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
  echo "== Expanding save panel by default"
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
  echo "== Expanding print panel by default"
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
  echo "== Setting save to disk (not to iCloud) by default"
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
  echo "== Automatically quit printer app once the print jobs complete"
  defaults write com.apple.print.PrintingPrefs 'Quit When Finished' -bool true
  echo "== Disabling the 'Are you sure you want to open this application?' dialog"
  defaults write com.apple.LaunchServices LSQuarantine -bool false
  echo "== Reveal IP, hostname, OS, etc. when clicking clock in login window"
  sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
  echo "== Restart automatically if the computer freezes"
  sudo systemsetup -setrestartfreeze on
  echo "== Disabling sleep mode"
  sudo systemsetup -setcomputersleep Off
  echo "== Disabling smart quotes as they’re annoying when typing code"
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  echo "== Disabling smart dashes as they’re annoying when typing code"
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  echo "== Disabling Notification Center and remove the menu bar icon"
  launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist
}

function trackpad() {
  echo "== Disabling the Launchpad gesture (pinch with thumb and three fingers)"
  defaults write com.apple.dock showLaunchpadGestureEnabled -int 0
  echo "== Trackpad: enabling tap to click for this user and for the login screen"
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  echo "== Trackpad: mapping bottom right corner to right-click"
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
  # echo "== Disabling 'natural' (Lion-style) scrolling"
  # defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
}

function keyboard() {
  echo "== Enabling full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
  echo "== Using scroll gesture with the Ctrl (^) modifier key to zoom"
  defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
  defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
  echo "== Follow the keyboard focus while zoomed in"
  defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true
  echo "== Disabling press-and-hold for keys in favor of key repeat"
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  echo "== Set a blazingly fast keyboard repeat rate"
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 10
  echo "== Setting language and text formats (english/US)"
  defaults write NSGlobalDomain AppleLanguages -array 'en'
  defaults write NSGlobalDomain AppleLocale -string 'en_US@currency=EUR'
  defaults write NSGlobalDomain AppleMeasurementUnits -string 'Centimeters'
  defaults write NSGlobalDomain AppleMetricUnits -bool true
  echo "== Disabling auto-correct"
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
}

function screenshot(){
  echo "== Save screenshots to the desktop screenshot folder"
  mkdir -p ${HOME}/Desktop/screenshots
  defaults write com.apple.screencapture location -string ${HOME}/Desktop/screenshots
  echo "== Save screenshots in PNG format (options: PNG, BMP, GIF, JPG, PDF, TIFF)"
  defaults write com.apple.screencapture type -string 'png'
  echo "== Disabling shadow in screenshots"
  defaults write com.apple.screencapture disable-shadow -bool true
  echo "== Enable subpixel font rendering on non-Apple LCDs"
  defaults write NSGlobalDomain AppleFontSmoothing -int 2
  echo "== Enable HiDPI display modes (requires restart)"
  sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true
}

function finder() {
  echo "== Keep folders on top when sorting by name (Sierra only)"
  defaults write com.apple.finder _FXSortFoldersFirst -bool true
  echo "== Allow quitting via ⌘ + Q; doing so will also hide desktop icons"
  defaults write com.apple.finder QuitMenuItem -bool true
  echo "== Disabling window animations and Get Info animations"
  defaults write com.apple.finder DisableAllAnimations -bool true
  echo "== Set ~/Downloads as the default location for new Finder windows"
  defaults write com.apple.finder NewWindowTarget -string 'PfLo'
  defaults write com.apple.finder NewWindowTargetPath -string file://${HOME}/Downloads/
  # echo "== Show hidden files by default"
  # defaults write com.apple.finder AppleShowAllFiles -bool true
  echo "== Show all filename extensions"
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  echo "== Show status bar"
  defaults write com.apple.finder ShowStatusBar -bool true
  echo "== Show path bar"
  defaults write com.apple.finder ShowPathbar -bool true
  echo "== Allow text selection in Quick Look"
  defaults write com.apple.finder QLEnableTextSelection -bool true
  echo "== Display full POSIX path as Finder window title"
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
  echo "== When performing a search, search the current folder by default"
  defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'
  echo "== Disabling the warning when changing a file extension"
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  echo "== Enable spring loading for directories"
  defaults write NSGlobalDomain com.apple.springing.enabled -bool true
  echo "== Remove the spring loading delay for directories"
  defaults write NSGlobalDomain com.apple.springing.delay -float 0
  echo "== Avoid creating .DS_Store files on network volumes"
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  echo "== Disabling disk image verification"
  defaults write com.apple.frameworks.diskimages skip-verify -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true
  echo "== Automatically open a new Finder window when a volume is mounted"
  defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
  defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
  defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
  echo "== Use list view in all Finder windows by default (Options: Nlsv, icnv, clmv, Flwv)"
  defaults write com.apple.finder FXPreferredViewStyle -string 'Nlsv'
  echo "== Disabling the warning before emptying the Trash"
  defaults write com.apple.finder WarnOnEmptyTrash -bool false
  echo "== Empty Trash securely by default"
  defaults write com.apple.finder EmptyTrashSecurely -bool true
  echo "== Enable AirDrop over Ethernet and on unsupported Macs"
  defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true
  echo "== Show the ~/Library folder"
  chflags nohidden ~/Library
  echo "== Expand the following File Info panes: 'General', 'Open with', and 'Sharing & Permissions'"
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
  echo "== Top left screen corner → Mission Control"
  defaults write com.apple.dock wvous-tl-corner -int 0
  defaults write com.apple.dock wvous-tl-modifier -int 0
  echo "== Top right screen corner → Desktop"
  defaults write com.apple.dock wvous-tr-corner -int 0
  defaults write com.apple.dock wvous-tr-modifier -int 0
  echo "== Bottom right screen corner → Start screen saver"
  defaults write com.apple.dock wvous-br-corner -int 0
  defaults write com.apple.dock wvous-br-modifier -int 0
}

function safari() {
  echo "== Set Safari’s home page to ‘about:blank’ for faster loading"
  defaults write com.apple.Safari HomePage -string 'about:blank'
  echo "== Prevent Safari from opening ‘safe’ files automatically after downloading"
  defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
  echo "== Allow hitting the Backspace key to go to the previous page in history"
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true
  echo "== Hide Safari’s bookmarks bar by default"
  defaults write com.apple.Safari ShowFavoritesBar -bool false
  echo "== Hide Safari’s sidebar in Top Sites"
  defaults write com.apple.Safari ShowSidebarInTopSites -bool false
  echo "== Disabling Safari’s thumbnail cache for History and Top Sites"
  defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2
  echo "== Enable Safari’s debug menu"
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
  echo "== Make Safari’s search banners default to Contains instead of Starts With"
  defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false
  echo "== Remove useless icons from Safari’s bookmarks bar"
  defaults write com.apple.Safari ProxiesInBookmarksBar '()'
  echo "== Enable the Develop menu and the Web Inspector in Safari"
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
  echo "== Add a context menu item for showing the Web Inspector in web views"
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
}

function mail() {
  echo "== Disabling send and reply animations in Mail.app"
  defaults write com.apple.mail DisableReplyAnimations -bool true
  defaults write com.apple.mail DisableSendAnimations -bool true
  echo "== Copy email addresses as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app"
  defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false
  echo "== Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app"
  defaults write com.apple.mail NSUserKeyEquivalents -dict-add 'Send' -string '@\\U21a9'
  echo "== Display emails in threaded mode, sorted by date (oldest at the top)"
  defaults write com.apple.mail DraftsViewerAttributes -dict-add 'DisplayInThreadedMode' -string 'yes'
  defaults write com.apple.mail DraftsViewerAttributes -dict-add 'SortedDescending' -string 'yes'
  defaults write com.apple.mail DraftsViewerAttributes -dict-add 'SortOrder' -string 'received-date'
  echo "== Disabling inline attachments (just show the icons)"
  defaults write com.apple.mail DisableInlineAttachmentViewing -bool true
  echo "== Disabling automatic spell checking"
  defaults write com.apple.mail SpellCheckingBehavior -string 'NoSpellCheckingEnabled'
}

function spotlight() {
  # echo "== Hide Spotlight tray-icon (and subsequent helper)"
  # sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search
  echo "== Disabling Spotlight indexing for any volume that gets mounted and has not yet been indexed"
  # Use `sudo mdutil -i off "/Volumes/foo"` to stop indexing any volume.
  sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array '/Volumes'
  echo "== Change indexing order and disable some file types from being indexed"
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
  echo "== Load new settings before rebuilding the index"
  killall mds
  echo "== Make sure indexing is enabled for the main volume"
  sudo mdutil -i on /
  # echo "== Rebuild the index from scratch"
  # sudo mdutil -E /
}

function iterm() {
  echo "== Installing the Base16 default dark theme for iTerm (opening file)"
  if ! defaults read com.googlecode.iterm2 'Custom Color Presets' | grep 'base16-default-dark' > /dev/null; then
    open ${PROJECTDIR}/files/iterm/base16-default.dark.itermcolors
  fi
  echo "== Don’t display the annoying prompt when quitting iTerm"
  defaults write com.googlecode.iterm2 PromptOnQuit -bool false
  echo "== hide tab title bars"
  # defaults write com.googlecode.iterm2 HideTab -bool true
  # echo "== set system-wide hotkey to show/hide iterm with ^\`"
  defaults write com.googlecode.iterm2 Hotkey -bool true
  echo "== hide pane titles in split panes"
  defaults write com.googlecode.iterm2 ShowPaneTitles -bool false
  echo "== animate split-terminal dimming"
  defaults write com.googlecode.iterm2 AnimateDimming -bool true
  defaults write com.googlecode.iterm2 HotkeyChar -int 96
  defaults write com.googlecode.iterm2 HotkeyCode -int 50
  defaults write com.googlecode.iterm2 FocusFollowsMouse -int 1
  defaults write com.googlecode.iterm2 HotkeyModifiers -int 262401
  echo "== Make iTerm2 load new tabs in the same directory"
  /usr/libexec/PlistBuddy -c "set 'New Bookmarks':0:'Custom Directory' Recycle" ~/Library/Preferences/com.googlecode.iterm2.plist
  echo "== setting fonts"
  defaults write com.googlecode.iterm2 'Normal Font' -string 'PragmataPro Mono Liga 14'
  defaults write com.googlecode.iterm2 'Non Ascii Font' -string 'PragmataPro Mono Liga 14'
  # echo "== reading iterm settings"
  # defaults read -app iTerm
}

function timemachine() {
  echo "== Prevent Time Machine from prompting to use new hard drives as backup volume"
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
  echo "== Disabling local Time Machine backups"
  hash tmutil
  sudo tmutil disable
}

function activitymonitor() {
  echo "== Show the main window when launching Activity Monitor"
  defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
  echo "== Visualize CPU usage in the Activity Monitor Dock icon"
  defaults write com.apple.ActivityMonitor IconType -int 5
  echo "== Show all processes in Activity Monitor"
  defaults write com.apple.ActivityMonitor ShowCategory -int 0
  echo "== Sort Activity Monitor results by CPU usage"
  defaults write com.apple.ActivityMonitor SortColumn -string 'CPUUsage'
  defaults write com.apple.ActivityMonitor SortDirection -int 0
}

function messages() {
  echo "== Disabling automatic emoji substitution (i.e. use plain text smileys)"
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'automaticEmojiSubstitutionEnablediMessage' -bool false
  echo "== Disabling smart quotes as it’s annoying for messages that contain code"
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'automaticQuoteSubstitutionEnabled' -bool false
  echo "== Disabling continuous spell checking"
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'continuousSpellCheckingEnabled' -bool false
}

function mas() {
echo "== Enable the WebKit Developer Tools in the Mac App Store"
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

echo "== Enable Debug Menu in the Mac App Store"
defaults write com.apple.appstore ShowDebugMenu -bool true
}

function misc() {
  echo "== Increase sound quality for Bluetooth headphones/headsets"
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

  echo "== Enable the debug menu in Address Book"
  defaults write com.apple.addressbook ABShowDebugMenu -bool true

  echo "== Enable Dashboard dev mode (allows keeping widgets on the desktop)"
  defaults write com.apple.dashboard devmode -bool true

  echo "== Use plain text mode for new TextEdit documents"
  defaults write com.apple.TextEdit RichText -int 0
  echo "== Open and save files as UTF-8 in TextEdit"
  defaults write com.apple.TextEdit PlainTextEncoding -int 4
  defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

  echo "== Enable the debug menu in Disk Utility"
  defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
  defaults write com.apple.DiskUtility advanced-image-options -bool true

  echo "== Speed up Mission Control animations"
  defaults write com.apple.dock expose-animation-duration -float 0.1

  echo "== Don’t group windows by application in Mission Control"
  # (i.e. use the old Exposé behavior instead)
  defaults write com.apple.dock expose-group-by-app -bool false

  echo "== Disabling Dashboard"
  defaults write com.apple.dashboard mcx-disabled -bool true

  echo "== Don’t show Dashboard as a Space"
  defaults write com.apple.dock dashboard-in-overlay -bool true

  echo "== Don’t automatically rearrange Spaces based on most recent use"
  defaults write com.apple.dock mru-spaces -bool false
}

main "$@"
