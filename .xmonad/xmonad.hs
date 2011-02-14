-- xmonad.hs:
--
-- Copyright (C) Sudish Joseph, 2011
-- All Rights Reserved.
--
-- Sudish Joseph <sudish@gmail.com>, 2011-01-19
--

import XMonad
import XMonad.Actions.CycleRecentWS (cycleRecentWS)
import XMonad.Actions.CycleWindows  (cycleRecentWindows)
import XMonad.Actions.CycleWS       (nextWS, prevWS, shiftToNext, shiftToPrev)
import XMonad.Actions.UpdatePointer (updatePointer, PointerPosition(..))
import XMonad.Actions.WindowBringer (gotoMenu, bringMenu)
import XMonad.Config.Gnome          (gnomeConfig)
import XMonad.Hooks.ManageDocks     (avoidStruts)
import XMonad.Hooks.SetWMName       (setWMName)
import XMonad.Layout.NoBorders      (noBorders, smartBorders)
import XMonad.Prompt                (defaultXPConfig)
import XMonad.Prompt.XMonad         (xmonadPrompt)
import qualified XMonad.StackSet as W (focusUp, focusDown)
import XMonad.Util.EZConfig         (additionalKeysP, checkKeymap)

-- Layouts
sjLayoutHook = avoidStruts $ noBorders Full
                         ||| smartBorders (Tall 1 (3/100) (1/2))

-- Keymaps
sjModMask = mod3Mask
sjKeymap  = [ ("M3-g",          gotoMenu)
            , ("M3-S-g",        bringMenu)
            , ("M3-<Tab>",      cycleRecentWS [xK_Hyper_L] xK_Tab xK_grave)
              -- start cycling current workspace windows with Hyper-Shift-Tab,
              -- but continue with Hyper-Tab and Hyper-Grave (no shift)
            , ("M3-S-<Tab>",    cycleRecentWindows 
                                              [xK_Hyper_L] xK_Tab xK_grave)
            , ("M3-<Up>",       windows W.focusUp)
            , ("M3-<Down>",     windows W.focusDown)
            , ("M3-<Right>",    nextWS)
            , ("M3-<Left>",     prevWS)
            , ("M3-S-<Right>",  shiftToNext >> nextWS)
            , ("M3-S-<Left>",   shiftToPrev >> prevWS)
            , ("M3-S-a",        xmonadPrompt defaultXPConfig)
            , ("M3-p",          spawn "exec `dmenu_path | dmenu`")
            ]

sjConfig = gnomeConfig
         { modMask     = sjModMask
         , numlockMask = mod2Mask
         , terminal    = "gnome-terminal"
         , layoutHook  = sjLayoutHook
         , logHook     = updatePointer (Relative 0.02 0.02)
         , startupHook = return ()
                         >> checkKeymap sjConfig sjKeymap
                         -- Hack for Java 1.6 and lower
                         >> setWMName "LG3D"
         , focusFollowsMouse = False
         }
         `additionalKeysP` sjKeymap

main = xmonad sjConfig
