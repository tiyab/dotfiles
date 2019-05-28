![](https://img.shields.io/badge/dotfiles-v2-yellow.svg)
![](https://img.shields.io/badge/license-GPL%20v3-green.svg)
![](https://img.shields.io/badge/GNU%20bash-%3E%3D%203.2-blue.svg)
![](https://img.shields.io/badge/dependencies-none-lightgrey.svg)

---

# ╰[ ⁰﹏⁰ ]╯ - Dotfiles bot

Almost unattended dotfiles for Mac.
Bash only, no dependencies!

---

# About

> Note: Read me until the end before running the install script!

This script purposes is to configure newly installed Mac with just the input of sudo password. It is idempotent too. Once finished it will reboot.


It is using only bash command and is shellcheck proof.
If it is reminding you of another dotfiles, that is normal. This is a copy AND reviewed version of this [atomantic dotfiles project](https://github.com/atomantic/dotfiles).

V2 !! Overall simplification (I think) and seperation of tasks. Implementation of a Brewfile too!!


---

# Installation
> Note: Please review the code before running it blindly

Open a Terminal and run the following commands:
```
curl --silent https://raw.githubusercontent.com/tiyab/dotfiles/v2/install.sh | bash
```

---

# Description

Most of the code is self explanatory.

Function has the following naming convention: `object` _ `action` _ `specificity`
For example: 
- Getting sudo password => `sudo_get_password`
- Setting default shell => `shell_set_default`
- ...

## sudo

Require SUDO to execute the script and it is use the whole execution.

## hosts file

A good machine is a machine with a good `/etc/hosts` file.
Updated from [https://someonewhocares.org/hosts/hosts](https://someonewhocares.org/hosts/hosts)

## ssh

It will generate a new pair of SSH keys ready to be used if none exist.

## software installation

Software are installed via [Homebrew](https://brew.sh/) and [Homebrew-Bundle](https://github.com/Homebrew/homebrew-bundle).
Refer to [Brewfile](Brewfile) to see the list of installed applications.

## software customization

### zsh

Usage of [prezto](https://github.com/sorin-ionescu/prezto)

If there is no custom zsh configuration then prezto configuration is used.

### vim

Usage of [Vundle](https://github.com/VundleVim/Vundle.vim)

Vundle is installed only if VIM exist on the system which should be the case ^^

### vscode

Custom `settings.json` and `keybindings.json`

---

# OS configuration

### SSD-specific tweaks  
- Disable local Time Machine snapshots
- Disable hibernation (speeds up entering sleep mode)
- Remove the sleep image file to save disk space

### General System Changes
- always boot in verbose mode (not MacOS GUI mode)
- Disable the sound effects on boot
- Menu bar: disable transparency
- Menu bar: hide the Time Machine, Volume, User, and Bluetooth icons
- Set highlight color to green
- Set sidebar icon size to medium
- Always show scrollbars
- Increase window resize speed for Cocoa applications
- Expand save panel by default
- Expand print panel by default
- allow 'locate' command
- Set standby delay to 24 hours (default is 1 hour)
- Save to disk (not to iCloud) by default
- Automatically quit printer app once the print jobs complete
- Disable the “Are you sure you want to open this application?” dialog
- Remove duplicates in the “Open With” menu (also see 'lscleanup' alias)
- Display ASCII control characters using caret notation in standard text views
- Disable automatic termination of inactive apps
- Disable the crash reporter
- Set Help Viewer windows to non-floating mode
- Reveal IP, hostname, OS, etc. when clicking clock in login window
- Restart automatically if the computer freezes
- Never go into computer sleep mode
- Check for software updates daily, not just once per week
- Disable smart quotes as they’re annoying when typing code
- Disable smart dashes as they’re annoying when typing code

### Security
- Enable firewall
- Enable firewall stealth mode (no response to ICMP / ping requests)
- Disable remote apple events
- Disable wake-on modem
- Disable wake-on LAN
- Disable guest account login

### Trackpad, mouse, keyboard, Bluetooth accessories, and input
- Trackpad: enable tap to click for this user and for the login screen
- Trackpad: map bottom right corner to right-click
- Disable “natural” (Lion-style) scrolling
- Increase sound quality for Bluetooth headphones/headsets
- Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
- Use scroll gesture with the Ctrl (^) modifier key to zoom
- Follow the keyboard focus while zoomed in
- Disable press-and-hold for keys in favor of key repeat
- Set a blazingly fast keyboard repeat rate:
- Set language and text formats (english/US)
- Disable auto-correct

### Configuring the Screen
- Require password immediately after sleep or screen saver begins
- Save screenshots to the desktop
- Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
- Disable shadow in screenshots
- Enable subpixel font rendering on non-Apple LCDs
- Enable HiDPI display modes (requires restart)

### Finder Configs
- Keep folders on top when sorting by name (Sierra only)
- Allow quitting via ⌘ + Q; doing so will also hide desktop icons
- Disable window animations and Get Info animations
- Set Desktop as the default location for new Finder windows
- Show hidden files by default
- Show all filename extensions
- Show status bar
- Show path bar
- Allow text selection in Quick Look
- Display full POSIX path as Finder window title
- When performing a search, search the current folder by default
- Disable the warning when changing a file extension
- Enable spring loading for directories
- Remove the spring loading delay for directories
- Avoid creating .DS_Store files on network volumes
- Disable disk image verification
- Automatically open a new Finder window when a volume is mounted
- Use list view in all Finder windows by default
- Disable the warning before emptying the Trash
- Empty Trash securely by default
- Enable AirDrop over Ethernet and on unsupported Macs running Lion
- Show the ~/Library folder
- Expand the following File Info panes: “General”, “Open with”, and “Sharing & Permissions”

### Dock & Dashboard
- Enable highlight hover effect for the grid view of a stack (Dock)
- Position the dock to the left of the screen
- Set the icon size of Dock items to 36 pixels
- Change minimize/maximize window effect to scale
- Minimize windows into their application’s icon
- Enable spring loading for all Dock items
- Show indicator lights for open applications in the Dock
- Don’t animate opening applications from the Dock
- Speed up Mission Control animations
- Don’t group windows by application in Mission Control
- Disable Dashboard
- Don’t show Dashboard as a Space
- Don’t automatically rearrange Spaces based on most recent use
- Remove the auto-hiding Dock delay
- Remove the animation when hiding/showing the Dock
- Automatically hide and show the Dock
- Make Dock icons of hidden applications translucent
- Make Dock more transparent
- Reset Launchpad, but keep the desktop wallpaper intact

### Configuring Hot Corners
- Top left screen corner → Mission Control
- Top right screen corner → Desktop
- Bottom right screen corner → Start screen saver

### Configuring Safari & WebKit
- Set Safari’s home page to ‘about:blank’ for faster loading
- Prevent Safari from opening ‘safe’ files automatically after downloading
- Allow hitting the Backspace key to go to the previous page in history
- Hide Safari’s bookmarks bar by default
- Hide Safari’s sidebar in Top Sites
- Disable Safari’s thumbnail cache for History and Top Sites
- Enable Safari’s debug menu
- Make Safari’s search banners default to Contains instead of Starts With
- Remove useless icons from Safari’s bookmarks bar
- Enable the Develop menu and the Web Inspector in Safari
- Add a context menu item for showing the Web Inspector in web views

### Configuring Mail
- Disable send and reply animations in Mail.app
- Copy email addresses as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app
- Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app
- Display emails in threaded mode, sorted by date (oldest at the top)
- Disable inline attachments (just show the icons)
- Disable automatic spell checking

### Spotlight
- Disable Spotlight indexing for any volume that gets mounted and has not yet been indexed
- Change indexing order and disable some file types from being indexed
- Load new settings before rebuilding the index
- Make sure indexing is enabled for the main volume

### iTerm2
- Installing the Solarized Dark theme for iTerm
- Don’t display the annoying prompt when quitting iTerm
- Hide tab title bars
- Set system-wide hotkey to show/hide iterm with ctrl+tick ( `^` + `)
- Set normal font to Hack 12pt
- Set non-ascii font to Roboto Mono for Powerline 12pt

### Time Machine
- Prevent Time Machine from prompting to use new hard drives as backup volume
- Disable local Time Machine backups

### Activity Monitor
- Show the main window when launching Activity Monitor
- Visualize CPU usage in the Activity Monitor Dock icon
- Show all processes in Activity Monitor
- Sort Activity Monitor results by CPU usage

### Address Book, Dashboard, iCal, TextEdit, and Disk Utility
- Enable the debug menu in Address Book
- Enable Dashboard dev mode (allows keeping widgets on the desktop)
- Use plain text mode for new TextEdit documents
- Open and save files as UTF-8 in TextEdit
- Enable the debug menu in Disk Utility

### Mac App Store
- Enable the WebKit Developer Tools in the Mac App Store
- Enable Debug Menu in the Mac App Store

### Messages
- Disable automatic emoji substitution (i.e. use plain text smileys)
- Disable smart quotes as it’s annoying for messages that contain code
- Disable continuous spell checking

# Resources
- :coffee: :coffee: :coffee:
- [vscode](https://code.visualstudio.com/download)
- [shellcheck](https://www.shellcheck.net/)
- [BashFAQ](https://mywiki.wooledge.org/BashFAQ)
- [StyleGuide](https://google.github.io/styleguide/shell.xml#Variable_Names)
- [Log level](http://www.ludovicocaldara.net/dba/bash-tips-4-use-logging-levels/)
- [Log file](http://www.ludovicocaldara.net/dba/bash-tips-5-output-logfile/)
- [Root of everything](https://github.com/HiDeoo)
- [Root of v1](https://github.com/atomantic/dotfiles)
- [Root of v2](https://github.com/sam-hosseini/dotfiles)
- [Shields IO](https://shields.io/)

# LICENSE
[GNU GENERAL PUBLIC LICENSE v3](LICENSE)

# Warning / Liability
> Warning:
The creator of this repo is not responsible if your machine ends up in a state you are not happy with. If you are concerned, look at the code to review everything this will do to your machine :)
