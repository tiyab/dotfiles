![](https://img.shields.io/badge/dotfiles-v2-green.svg)
![](https://img.shields.io/badge/license-GPL%20v3-green.svg)
![](https://img.shields.io/badge/GNU%20bash-%3E%3D%203.2-blue.svg)
![](https://img.shields.io/badge/shellcheck-100%25-green.svg)
![](https://img.shields.io/badge/dependencies-none-lightgrey.svg)

---

# ╰[ ⁰﹏⁰ ]╯ - Dotfiles bot

Almost unattended dotfiles for Mac.
Bash only, no dependencies!

---

# About

> Note: Read me until the end before running the install script!

This script purposes is to configure newly installed Mac (tested only on Mojave, 10.14.x) with just the input of sudo password. 
The script is idempotent and use bash only commands.

At first it was based on [atomantic dotfiles](https://github.com/atomantic/dotfiles), heavily modified by me. And then the V2 was inspired by [sam-hosseini dotfiles](https://github.com/sam-hosseini/dotfiles). The result is the current version.

---

# Installation
> Note: Please review the code before running it blindly

Open a Terminal and run the following commands:
```
curl --silent https://raw.githubusercontent.com/tiyab/dotfiles/master/install.sh | bash
```

During the installation there will be a `gpg-suite` popup, didn't found out yet how to auto accept :/

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

Require SUDO to execute the script.

## hosts file

A good machine is a machine with a good `/etc/hosts` file.
Updated from [https://someonewhocares.org/hosts/hosts](https://someonewhocares.org/hosts/hosts)

## ssh

It will generate a new pair of SSH keys ready to be used if none exist.

## softwares installation

Softwares are installed via [Homebrew](https://brew.sh/) and [Homebrew-Bundle](https://github.com/Homebrew/homebrew-bundle).
Refer to [Brewfile](Brewfile) to see the list of installed applications.

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
- [Root of everything](https://github.com/HiDeoo)
- [Root of v1](https://github.com/atomantic/dotfiles)
- [Root of v2](https://github.com/sam-hosseini/dotfiles)
- [Shields IO](https://shields.io/)

# LICENSE
[GNU GENERAL PUBLIC LICENSE v3](LICENSE)

# Warning / Liability
> Warning:
The creator of this repo is not responsible if your machine ends up in a state you are not happy with. If you are concerned, look at the code to review everything this will do to your machine :)
