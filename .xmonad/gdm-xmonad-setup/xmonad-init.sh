#!/bin/sh
#
# Start XMonad from within gnome-session
#

export PATH=$HOME/bin:$HOME/.cabal/bin:$PATH

[[ -e $HOME/.xmodmaprc ]] && xmodmap $HOME/.xmodmaprc

export WINDOWMANAGER=$HOME/.cabal/bin/xmonad
gnome-session
