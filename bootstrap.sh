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
    # Install all dependencies through brew
    brew update
    brew install qemu
    brew install gmp mpfr libmpc autoconf automake
    brew install nasm
    brew install xorriso
    brew tap djphoenix/gcc_cross_compilers
    brew install djphoenix/gcc_cross_compilers/x86_64-elf-binutils djphoenix/gcc_cross_compilers/x86_64-elf-gcc

    # Start building objconv and grub
    # There are no formulas for brew, so compiling from sources
    export PREFIX="$HOME/opt/"
    export TARGET=x86_64-elf
    export PATH="$PREFIX/bin:$PATH"

    mkdir -p $HOME/src
    mkdir -p $PREFIX
    mkdir -p $PREFIX/bin

    # objconv
    cd $HOME/src

    if [ ! -d "objconv" ]; then
      curl http://www.agner.org/optimize/objconv.zip > objconv.zip
      mkdir -p build-objconv
      unzip objconv.zip -d build-objconv

      cd build-objconv
      unzip source.zip -d src
      g++ -o objconv -O2 src/*.cpp --prefix="$PREFIX"
      cp objconv $PREFIX/bin/objconv
    fi

    # grub
    cd $HOME/src

    if [ ! -d "grub" ]; then
      git clone --depth 1 git://git.savannah.gnu.org/grub.git

      cd grub
      sh autogen.sh
      mkdir -p build-grub
      cd build-grub
      ../configure --disable-werror TARGET_CC=$TARGET-gcc TARGET_OBJCOPY=$TARGET-objcopy TARGET_STRIP=$TARGET-strip TARGET_NM=$TARGET-nm TARGET_RANLIB=$TARGET-ranlib --target=$TARGET --prefix=$PREFIX
      make
      make install
    fi

    # Install rust
    export PATH="$HOME/.cargo/bin"

    curl https://sh.rustup.rs -sSf | sh
    rustup override add nightly
  else
    echo "Homebrew does not appear to be installed!"
    echo "Install Homebrew and run this script again"
    exit
  fi
}

archLinux() {
  echo "Detected Arch Linux"
  echo "You can help me and write bootstrap script for your OS"
  exit
}

ubuntu() {
  echo "Detected Ubuntu/Debian"
  echo "You can help me and write bootstrap script for your OS"
  exit
}

fedora() {
  echo "Detected Fedora"
  echo "You can help me and write bootstrap script for your OS"
  exit
}

suse() {
  echo "Detected a suse"
  echo "You can help me and write bootstrap script for your OS"
  exit
}

gentoo() {
  echo "Detected Gentoo Linux"
  echo "You can help me and write bootstrap script for your OS"
  exit
}

endMessage() {
  echo
  echo "|-----------------------------------------|"
  echo "| Well it looks like you are ready to go! |"
  echo "|-----------------------------------------|"
  echo "| make                                    |"
  echo "| make run                                |"
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
