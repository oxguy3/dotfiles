#!/usr/bin/env bash
# setup up Homebrew, install essential packages

# OUTDATED, USE THE BREWFILE INSTEAD

# update brew
brew update

# replace outdated OS X utils with the latest versions
brew tap homebrew/dupes
brew install bash
brew install curl
brew install git
brew install emacs
brew install make
brew install nano
brew install less
brew install rsync
brew install ruby
brew install svn
brew install unzip
brew install vim --override-system-vi
brew install zsh

# replace icky BSD tools with glorious GNU versions
# h/t: https://www.topbug.net/blog/2013/04/14/install-and-use-gnu-command-line-tools-in-mac-os-x/
brew install coreutils
brew install binutils
brew install diffutils
brew install ed --default-names
brew install findutils --with-default-names
brew install gawk
brew install gnu-indent --with-default-names
brew install gnu-sed --with-default-names
brew install gnu-tar --with-default-names
brew install gnu-which --with-default-names
brew install gnutls
brew install grep --with-default-names
brew install gzip
brew install wdiff --with-gettext

# useful dev environments
brew install python
brew install python3
brew install node

# misc utilities and whatnot
brew install dnsmasq
brew install ffmpeg --with-ffplay --with-faac
brew install gist
brew install httpie
brew install imagemagick
brew install keybase
brew install mmv
brew install mpv
brew install p7zip
brew install pv
brew install redshift
brew install screen
brew install slackcat
brew install watch
brew install wget
brew install xcv
brew install xz

# fun stuff
brew install archey
brew install cowsay
brew install figlet


# delete unneeded files
brew cleanup
