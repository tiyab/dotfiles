![](https://img.shields.io/badge/dotfiles-v2-green.svg)
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

V2 !! Overall simplification (I think) and seperation of tasks via functions. Implementation of a Brewfile too!!

---

# Installation
> Note: Please review the code before running it blindly

Open a Terminal and run the following commands:
```
curl --silent https://raw.githubusercontent.com/tiyab/dotfiles/master/install.sh | bash
```

Once finish, just reboot as there is many settings that require an app restart.

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

## softwares installation

Softwares are installed via [Homebrew](https://brew.sh/) and [Homebrew-Bundle](https://github.com/Homebrew/homebrew-bundle).
Refer to [Brewfile](Brewfile) to see the list of installed applications.

> Calibre and VLC failed to be installed on the first run. But after reboot, installation is successful.

## softwares customization

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

Too many to be listed here but here a list of few settings that are enforced:
- System: Dark mode
- System: Highlight and accent color is yellow
- Bluetooth: OFF
- timeserver: time.euro.apple.com
- timezone: Europe/Paris
- applelanguage: English
- currency: EUR
- measurement: centimeters 
- Remote Login: OFF (it means no SSH)
- hotcorners: all disable

Everything else you will have to read `macos.sh`.

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
