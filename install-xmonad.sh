#!/bin/bash
#
# Installation script which setup up an Ubuntu Xenial machine to use this
# xmonad configuration.
#
# WARNING!!!
# * This has only been tested on a limited number of machines running
#   Ubuntu 16.04 64-bit.
# * This is not a sophisticated installation script by any stretch
#   of the imagination.
# * I take no responsibility if this overwrites any configuration settings
#   or otherwise messes up your system.
#
# Please review the readme file to find out exactly what it does and does not
# do. Or, visit the repository for more information:
# https://github.com/davidbrewer/xmonad-ubuntu-conf
#
# Author: David Brewer

echo "Installing required packages..."

sudo apt-get update
sudo apt-get install -y xmonad libghc-xmonad-dev libghc-xmonad-contrib-dev xmobar \
  xcompmgr nitrogen stalonetray moreutils consolekit xss-lock ssh-askpass-gnome \
  thunar terminator remmina guake rxvt-unicode-256color taffybar polybar unicode-data

## synapse is replaced w/ rofi now
sudo apt install rofi -y
#echo "synapse bleeding edge version"
#sudo add-apt-repository ppa:synapse-core/testing
#sudo apt-get update
#sudo apt-get install -y synapse

echo "thinkpad battery saver"
# http://www.webupd8.org/2013/04/improve-power-usage-battery-life-in.html
sudo add-apt-repository ppa:linrunner/tlp
sudo apt-get update
sudo apt-get install -y tlp tlp-rdw
# thinkpad only
sudo apt-get install -y  tp-smapi-dkms acpi-call-dkms

# install redshift for now, xflux is breaking :(
sudo apt-get install -y redshift redshift-gtk

## let's install the fancy terminal
cargo install --git https://github.com/jwilm/alacritty

## font and char
#sudo apt install -y font-powerline

echo "Creating xmonad xsession configuration..."
sudo mv /usr/share/xsessions/xmonad.desktop /usr/share/xsessions/xmonad.desktop.original
sudo cp ~/.xmonad/xmonad.desktop /usr/share/xsessions
sudo chmod a+r /usr/share/xsessions/xmonad.desktop
sudo cp ~/.xmonad/images/custom_xmonad_badge.png /usr/share/unity-greeter
sudo chmod a+r /usr/share/unity-greeter/custom_xmonad_badge.png

echo "Linking to customized gnome 2 configuration..."
mv ~/.gtkrc-2.0 ~/gtkrc-2.0.original
mv ~/.stalonetrayrc ~/.stalonetrayrc.original
ln -s .xmonad/.gtkrc-2.0 ~/.gtkrc-2.0
ln -s ~/.xmonad/polybar ~/.config/polybar
#ln -s ~/.xmonad/.stalonetrayrc ~/.stalonetrayrc