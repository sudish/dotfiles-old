-- xmonad.hs:
--
-- Copyright (C) Sudish Joseph, 2011
-- All Rights Reserved.
--
-- Sudish Joseph <sudish@gmail.com>, 2011-01-19
--

import XMonad
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog (dzen, xmobar)
import XMonad.Hooks.ManageDocks (avoidStruts)
import XMonad.Util.EZConfig (additionalKeysP, checkKeymap)
import XMonad.Actions.WindowBringer (gotoMenu, bringMenu)
import XMonad.Actions.CycleRecentWS (cycleRecentWS)
import XMonad.Actions.CycleWS (nextWS, prevWS,
                                  shiftToNext, shiftToPrev, toggleWS)
import XMonad.Prompt (defaultXPConfig)
import XMonad.Prompt.XMonad (xmonadPrompt)

-- Layouts
sjLayoutHook = avoidStruts $ Full ||| Tall 1 (3/100) (1/2)

-- Keymaps
sjModMask = mod3Mask
sjKeymap  = [ ("M3-g",          gotoMenu)
            , ("M3-S-g",        bringMenu)
              -- this next binding is on Alt-Tab, not Hyper-Tab
            , ("M1-<Tab>",      cycleRecentWS [xK_Alt_L] xK_Tab xK_grave)
            , ("M3-<Right>",    nextWS)
            , ("M3-<Left>",     prevWS)
            , ("M3-S-<Right>",  shiftToNext >> nextWS)
            , ("M3-S-<Left>",   shiftToPrev >> prevWS)
            , ("M3-z",          toggleWS)
            , ("M3-S-a",        xmonadPrompt defaultXPConfig)
            , ("M3-p",          spawn "exec `dmenu_path | dmenu`")
            ]

sjConfig = gnomeConfig
         { modMask = sjModMask
         , numlockMask = mod2Mask
         , terminal = "gnome-terminal"
         , layoutHook = sjLayoutHook
         , startupHook = return () >> checkKeymap sjConfig sjKeymap
         }
         `additionalKeysP` sjKeymap

main = xmonad sjConfig
