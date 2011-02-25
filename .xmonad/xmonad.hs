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
import XMonad.Actions.CycleWS       (nextWS, prevWS, moveTo, 
                                        Direction1D(..), WSType(..))
import XMonad.Actions.UpdatePointer (updatePointer, PointerPosition(..))
import XMonad.Actions.WindowBringer (gotoMenu, bringMenu)
import XMonad.Config.Gnome          (gnomeConfig)
import XMonad.Hooks.DynamicLog      (dynamicLogWithPP, defaultPP, PP(..),
                                        shorten, wrap)
import XMonad.Hooks.ManageDocks     (avoidStruts)
import XMonad.Hooks.SetWMName       (setWMName)
import XMonad.Layout.IM             (gridIM, Property(..))
import XMonad.Layout.NoBorders      (noBorders, smartBorders)
import XMonad.Layout.PerWorkspace   (onWorkspace)
import XMonad.Prompt                (defaultXPConfig)
import XMonad.Prompt.XMonad         (xmonadPrompt)
import qualified XMonad.StackSet as W (focusUp, focusDown)
import XMonad.Util.EZConfig         (additionalKeysP, checkKeymap)

import Data.Ratio                   ((%))

import Control.OldException         (catchDyn, try)
import DBus                         (Error(..), interfaceDBus,
                                        serviceDBus, pathDBus)
import DBus.Connection
import DBus.Message

-- All chat-related windows on this workspace
sjChatWS :: String
sjChatWS = "9"

-- Window management hook
sjManageHook :: ManageHook
sjManageHook = composeAll
               [ className =? "Pidgin" --> doShift sjChatWS ]

-- Layouts
sjLayoutDefault = noBorders Full
                  ||| smartBorders (Tall 1 (3/100) (1/2))
sjLayoutChat = gridIM (1%4) (Role "buddy_list")
sjLayoutHook = avoidStruts $
               onWorkspace sjChatWS sjLayoutChat $
               sjLayoutDefault

-- Keymaps
sjModMask :: KeyMask
sjModMask = mod3Mask
sjKeymap :: [([Char], X ())]
sjKeymap  = [ ("M3-g",          gotoMenu)
            , ("M3-S-g",        bringMenu)
            , ("M3-<Tab>",      cycleRecentWS [xK_Hyper_L] xK_Tab xK_grave)
              -- start cycling current workspace windows with Hyper-Shift-Tab,
              -- but continue with Hyper-Tab and Hyper-Grave (no shift)
            , ("M3-S-<Tab>",    cycleRecentWindows
                                              [xK_Hyper_L] xK_Tab xK_grave)
            , ("M3-<Up>",       windows W.focusUp)
            , ("M3-<Down>",     windows W.focusDown)
            , ("M3-<Right>",    moveTo Next NonEmptyWS)
            , ("M3-<Left>",     moveTo Prev NonEmptyWS)
            , ("M3-S-<Right>",  nextWS)
            , ("M3-S-<Left>",   prevWS)
            , ("M3-S-a",        xmonadPrompt defaultXPConfig)
            , ("M3-p",          spawn "exec `dmenu_path | dmenu`")
            ]

sjConfig dbus = gnomeConfig
         { modMask     = sjModMask
         , numlockMask = mod2Mask
         , terminal    = "gnome-terminal"
         , layoutHook  = sjLayoutHook
         -- Note: do NOT recurse over sjConfig in manageHook!
         , manageHook    = sjManageHook <+> manageHook gnomeConfig
         , logHook     = updatePointer (Relative 0.02 0.02)
                         >> dynamicLogWithPP (sjPrettyPrinter dbus)
         , startupHook = return ()
                         >> checkKeymap (sjConfig dbus) sjKeymap
                         -- Hack for Java 1.6 and lower
                         >> setWMName "LG3D"
         , focusFollowsMouse = False
         }
         `additionalKeysP` sjKeymap

main = withConnection Session $ \dbus -> do
  getWellKnownName dbus
  xmonad $ sjConfig dbus


-- All of the DBus stuff taken from http://uhsure.com/xmonad-log-applet.html
-- His xmonad.hs is at http://git.uhsure.com/

-- DBus log printer
sjPrettyPrinter :: Connection -> PP
sjPrettyPrinter dbus = defaultPP
  { ppOutput  = outputThroughDBus dbus
  , ppTitle   = shorten 50 . pangoSanitize
  , ppCurrent = wrap "[" "]" . pangoSanitize
  , ppVisible = wrap "(" ")" . pangoSanitize
  , ppHidden  = wrap " " " "
  , ppUrgent  = pangoColor "red"
  , ppSep     = " : "
  }

-- This retry is really awkward, but sometimes DBus won't let us get our
-- name unless we retry a couple times.
getWellKnownName :: Connection -> IO ()
getWellKnownName dbus = tryGetName `catchDyn`
                        (\ (DBus.Error _ _) -> getWellKnownName dbus)
 where
  tryGetName = do
    namereq <- newMethodCall serviceDBus pathDBus interfaceDBus "RequestName"
    addArgs namereq [String "org.xmonad.Log", Word32 5]
    sendWithReplyAndBlock dbus namereq 0
    return ()

outputThroughDBus :: Connection -> String -> IO ()
outputThroughDBus dbus str = do
  -- let str' = "<span font=\"foo\">" ++ str ++ "</span>"
  msg <- newSignal "/org/xmonad/Log" "org.xmonad.Log" "Update"
  addArgs msg [String str]
  send dbus msg 0 `catchDyn` (\ (DBus.Error _ _ ) -> return 0)
  return ()

pangoColor :: String -> String -> String
pangoColor fg = wrap left right
 where
  left  = "<span foreground=\"" ++ fg ++ "\">"
  right = "</span>"

pangoSanitize :: String -> String
pangoSanitize = foldr sanitize ""
 where
  sanitize '>'  acc = "&gt;" ++ acc
  sanitize '<'  acc = "&lt;" ++ acc
  sanitize '\"' acc = "&quot;" ++ acc
  sanitize '&'  acc = "&amp;" ++ acc
  sanitize x    acc = x:acc
