#!/bin/sh -ex

# Resources:
# - https://fedoramagazine.org/setting-up-the-sway-window-manager-on-fedora/
#
# - install automatic updates
# - touchpad -> scrolling -> traditional
# - accessibility -> seeing -> enable large text
# - set `menuAccessKeyFocuses` to false in firefox

pkgs=()
pkgs+=("alacritty")
pkgs+=("fish")
pkgs+=("btop" "eza" "fzf" "neovim" "zoxide")
pkgs+=("sway" "waybar" "yambar" "rofi" "network-manager-applet" "mako")
# for controlling via sway XF86 keys
pkgs+=("brightnessctl" "pulseaudio-utils")

# XXX maybe remove this if we like firefox enough
sudo dnf config-manager --set-enabled google-chrome
pkgs+=("google-chrome-stable")

# coding / tools
# XXX: check whether golang-x-tools-gopls is included in go
pkgs+=("go" "golang-x-tools-gopls")
pkgs+=("protobuf-compiler" "golang-google-protobuf")
# https://bugzilla.redhat.com/show_bug.cgi?id=1783723#c6
# for wasm_exec.js
pkgs+=("golang-misc")
# needed to install python 3.10.5 (via asdf)
pkgs+=("openssl-devel" "zlib-devel")

sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
test -e /etc/yum.repos.d/1password.repo || \
  sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
pkgs+=("1password")

mkdir -p ~/Pictures/Screenshots
pkgs+=("flameshot")

# light/dark mode + gamma
pkgs+=("darkman" "gammastep")
# XXX: cannot get this working... maybe need perms? (TODO: maybe try gammastep ?)
pkgs+=("redshift")

pkgs+=("powertop")

pkgs+=("steam")

# NOTE: slack, discord use browser for now
sudo dnf -y install ${pkgs[*]}

# use asdf for this instead
sudo dnf -y remove python-unversioned-command

which rustup || \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# fonts
mkdir -p ~/.local/share/fonts
test -e ~/.local/share/fonts/FiraCodeNerdFont-Regular.ttf || \
  (cd ~/.local/share/fonts && curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf)

# asdf
test -e ~/.asdf || \
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
# mkdir -p ~/.config/fish/completions
# ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions

# to swap background in neovim
# https://github.com/mhinz/neovim-remote
# asdf plugin-add python
# asdf python install 3.10.5
# echo 'python 3.10.5' >> ~/.tool-versions
pip install neovim-remote

test -e /etc/sysctl.d/50-unprivileged-ports.conf || \
  sudo sh -c "echo 'net.ipv4.ip_unprivileged_port_start=0' > /etc/sysctl.d/50-unprivileged-ports.conf"
# sudo sysctl --system

mkdir -p ~/src/github.com

# TODO: none of this stuff below works (uninstall xdotool too)
# for ctrl+click -> right-click
# TODO: install xdotool
# TODO: and enter this into the file at /etc/swhkd/swhkdrc
# ctrl + @button1
#	  xdotool sleep 0.05 click --clearmodifiers 3
sudo dnf -y install rust-libudev-devel
test -e ~/src/github.com/waycrate/swhkd || \
  (mkdir -p ~/src/github.com/waycrate && \
  cd ~/src/github.com/waycrate && \
  git clone https://github.com/waycrate/swhkd && \
  cd swhkd && \
  make setup && \
  make clean && \
  make && \
  sudo make install)
