#!/bin/bash
set -e

banner() {
  echo "|-----------------------------------------|"
  echo "|--------- ghaiklor-os bootstrap ---------|"
  echo "|-----------------------------------------|"
}

osx() {
  echo "Detected OSX!"
  if [ ! -z "$(which brew)" ]; then
    echo "Homebrew detected! Now updating..."
    brew update
    if [ -z "$(which git)" ]; then
      echo "Now installing git..."
      brew install git
    fi
    if [ -z "$(which qemu-system-x86_64)" ]; then
      echo "Installing qemu..."
      brew install qemu
    fi
  else
    echo "Homebrew does not appear to be installed! Would you like me to install it?"
    printf "(Y/n): "
    read -r installit
    if [ "$installit" == "Y" ]; then
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
      echo "Will not install, now exiting..."
      exit
    fi
  fi
  echo "Running setup script..."
  brew install nasm
  brew tap djphoenix/gcc_cross_compilers
  brew install djphoenix/gcc_cross_compilers/x86_64-elf-binutils
}

archLinux() {
  echo "Detected Arch Linux"
  echo "You can help me and write bootstrap script for your OS"
}

ubuntu() {
  echo "Detected Ubuntu/Debian"
  echo "You can help me and write bootstrap script for your OS"
}

fedora() {
  echo "Detected Fedora"
  echo "You can help me and write bootstrap script for your OS"
}

suse() {
  echo "Detected a suse"
  echo "You can help me and write bootstrap script for your OS"
}

gentoo() {
  echo "Detected Gentoo Linux"
  echo "You can help me and write bootstrap script for your OS"
}

endMessage() {
  echo
  echo "|-----------------------------------------|"
  echo "| Well it looks like you are ready to go! |"
  echo "|-----------------------------------------|"
  echo "| make                                    |"
  echo "|-----------------------------------------|"
  echo "|-------------- Good luck! ---------------|"
  echo "|-----------------------------------------|"
  exit
}

banner
if [ "Darwin" == "$(uname -s)" ]; then
  osx
else
  # Arch linux
  if hash 2>/dev/null pacman; then
    archLinux
  fi
  # Debian or any derivative of it
  if hash 2>/dev/null apt-get; then
    ubuntu
  fi
  # Fedora
  if hash 2>/dev/null yum; then
    fedora
  fi
  # Suse and derivatives
  if hash 2>/dev/null zypper; then
    suse
  fi
  # Gentoo
  if hash 2>/dev/null emerge; then
    gentoo
  fi
fi
endMessage
