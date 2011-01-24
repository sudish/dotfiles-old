#!/bin/sh
#
# Start XMonad from within gnome-session
#

export PATH=$HOME/bin:$HOME/.cabal/bin:$PATH

xmodmap $HOME/.xmodmaprc

export WINDOW_MANAGER=$HOME/.cabal/bin/xmonad
gnome-session
