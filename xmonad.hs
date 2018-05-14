{-
  This is my xmonad configuration file.
  There are many like it, but this one is mine.

  If you want to customize this file, the easiest workflow goes
  something like this:
    1. Make a small change.
    2. Hit "super-q", which recompiles and restarts xmonad
    3. If there is an error, undo your change and hit "super-q" again to
       get to a stable place again.
    4. Repeat

  Author:     David Brewer
  Repository: https://github.com/davidbrewer/xmonad-ubuntu-conf
-}

import XMonad
import XMonad.Hooks.SetWMName
import XMonad.Layout.Grid
import XMonad.Layout.ResizableTile
import XMonad.Layout.IM
import XMonad.Layout.ThreeColumns
import XMonad.Layout.NoBorders
import XMonad.Layout.Circle
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Fullscreen
import XMonad.Layout.Reflect
import XMonad.Util.EZConfig
import XMonad.Util.Run
import XMonad.Hooks.DynamicLog
import XMonad.Actions.Plane
import XMonad.Hooks.EwmhDesktops        (ewmh)
import XMonad.Hooks.ManageDocks
--import XMonad.Layout.MultiToggle
--import qualified XMonad.Layout.MultiToggle.Instances as Toggles
import qualified XMonad.Layout.MultiToggle as MultiToggle
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.ICCCMFocus
import XMonad.Hooks.ManageHelpers
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import Data.Ratio ((%))
-- control floating window
import XMonad.Hooks.Place

import System.Taffybar.Hooks.PagerHints (pagerHints)

{-
  Xmonad configuration variables. These settings control some of the
  simpler parts of xmonad's behavior and are straightforward to tweak.
-}

myModMask            = mod4Mask          -- changes the mod key to "super"
myFocusedBorderColor = "#ff0000"         -- color of focused border
myNormalBorderColor  = "#cccccc"         -- color of inactive border
myBorderWidth        = 1                 -- width of border around windows
myTerminal      = "alacritty"
--myTerminal           = "urxvtc"          -- gnome-terminal/terminator/urxvtc which terminal software to use
myIMRosterTitle      = "skype"           -- title of roster on IM workspace
                                         -- use "Buddy List" for Pidgin, but
                                         -- "Contact List" for Empathy


{-
  Xmobar configuration variables. These settings control the appearance
  of text which xmonad is sending to xmobar via the DynamicLog hook.
-}

myTitleColor     = "#eeeeee"  -- color of window title
myTitleLength    = 80         -- truncate window title to this length
myCurrentWSColor = "#e6744c"  -- color of active workspace
myVisibleWSColor = "#c185a7"  -- color of inactive workspace
myUrgentWSColor  = "#cc0000"  -- color of workspace with 'urgent' window
myCurrentWSLeft  = "["        -- wrap active workspace with these
myCurrentWSRight = "]"
myVisibleWSLeft  = "("        -- wrap inactive workspace with these
myVisibleWSRight = ")"
myUrgentWSLeft  = "{"         -- wrap urgent workspace with these
myUrgentWSRight = "}"


{-
  Workspace configuration. Here you can change the names of your
  workspaces. Note that they are organized in a grid corresponding
  to the layout of the number pad.

  I would recommend sticking with relatively brief workspace names
  because they are displayed in the xmobar status bar, where space
  can get tight. Also, the workspace labels are referred to elsewhere
      in the configuration file, so when you change a label you will have
  to find places which refer to it and make a change there as well.

  This central organizational concept of this configuration is that
  the workspaces correspond to keys on the number pad, and that they
  are organized in a grid which also matches the layout of the number pad.
  So, I don't recommend changing the number of workspaces unless you are
  prepared to delve into the workspace navigation keybindings section
  as well.
-}

-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
myWorkspaces = ["term","web","code","doc","mx","sfx","a","b","c"]

startupWorkspace = "term"  -- which workspace do you want to be on after launch?

{-
  Layout configuration. In this section we identify which xmonad
  layouts we want to use. I have defined a list of default
  layouts which are applied on every workspace, as well as
  special layouts which get applied to specific workspaces.

  Note that all layouts are wrapped within "avoidStruts". What this does
  is make the layouts avoid the status bar area at the top of the screen.
    Without this, they would overlap the bar. You can toggle this behavior
  by hitting "super-b" (bound to ToggleStruts in the keyboard bindings
  in the next section). To change layout, "super-tab-space"
-}

-- Define group of default layouts used on most screens, in the
-- order they will appear.
-- "smartBorders" modifier makes it so the borders on windows only
-- appear if there is more than one visible window.
-- "avoidStruts" modifier makes it so that the layout provides
-- space for the status bar at the top of the screen.
defaultLayouts = smartBorders(avoidStruts(
  -- ResizableTall layout has a large master window on the left,
  -- and remaining windows tile on the right. By default each area
  -- takes up half the screen, but you can resize using "super-h" and
  -- "super-l".
  ResizableTall 1 (3/100) (1/2) []

  -- Mirrored variation of ResizableTall. In this layout, the large
  -- master window is at the top, and remaining windows tile at the
  -- bottom of the screen. Can be resized as described above.
  ||| Mirror (ResizableTall 1 (3/100) (1/2) [])

  -- Full layout makes every window full screen. When you toggle the
  -- active window, it will bring the active window to the front.
  ||| noBorders Full

  -- ThreeColMid layout puts the large master window in the center
  -- of the screen. As configured below, by default it takes of 3/4 of
  -- the available space. Remaining windows tile to both the left and
  -- right of the master window. You can resize using "super-h" and
  -- "super-l".
  ||| ThreeColMid 1 (4/100) (3/4)
  -- BROKEN?

  -- Circle layout places the master window in the center of the screen.
  -- Remaining windows appear in a circle around it
  -- ||| Circle

  -- Grid layout tries to equally distribute windows in the available
  -- space, increasing the number of columns and rows as necessary.
  -- Master window is at top left.
  ||| Grid))


-- Here we define some layouts which will be assigned to specific
-- workspaces based on the functionality of that workspace.

docLayout = smartBorders(avoidStruts(Full ||| ResizableTall 1 (3/100) (1/2) [] ||| Grid ))

-- Trying different imLayout ..
--imLayout = smartBorders(avoidStruts(ThreeColMid ||| Full))
imLayout = smartBorders(avoidStruts(ThreeColMid 1 (3/100) (2/3)))

-- The chat layout uses the "IM" layout. We have a roster which takes
-- up 1/8 of the screen vertically, and the remaining space contains
-- chat windows which are tiled using the grid layout. The roster is
-- identified using the myIMRosterTitle variable, and by default is
-- configured for Pidgin, so if you're using something else you
-- will want to modify that variable.
--myIMLayout = withIM (1%7) Corebird Grid
--chatLayout = avoidStruts(withIM (1%7) (Title myIMRosterTitle) Grid)


-- numMasters, resizeIncr, splitRatio
--tall = Tall 1           0.02        0.5
-- define the list of standardLayouts
--standardLayouts = tall ||| Mirror tall ||| Full
--imLayout = withIM (1/10) (Role "roster") standardLayouts


--https://wiki.haskell.org/Xmonad/Config_archive/sphynx%27s_xmonad.hs
--imLayout = avoidStruts $ reflectHoriz $
--  IM (1%6) (Or (And (ClassName "Nocturn") (Role ""))
--  (And (ClassName "Skype")  (And (Role "") (Not (Title "Options")))))


-- from https://wiki.haskell.org/Xmonad/Config_archive/Thomas_ten_Cate%27s_xmonad.hs
--imLayout = avoidStruts $ reflectHoriz $ withIM ratio rosters chatLayout where
  --    chatLayout      = Grid
--    ratio           = 1%6
--    [rosters]       = [skypeRoster, pidginRoster]
--    pidginRoster    = And (ClassName "Pidgin") (Role "buddy_list")
--    skypeRoster     = (ClassName "Skype") `And` (Not (Title "Options")) `And` (Not (Role "Chats")) `And` (Not (Role "CallWindowForm"))

-- The GIMP layout uses the ThreeColMid layout. The traditional GIMP
-- floating panels approach is a bit of a challenge to handle with xmonad;
-- I find the best solution is to make the image you are working on the
-- master area, and then use this ThreeColMid layout to make the panels
-- tile to the left and right of the image. If you use GIMP 2.8, you
-- can use single-window mode and avoid this issue.
gimpLayout = smartBorders(avoidStruts(ThreeColMid 2 (3/100) (3/4)))
--gimpLayout = smartBorders(avoidStruts(Full ||| ResizableTall 1 (3/100) (1/2) [] ||| Grid ))

-- Here we combine our default layouts with our specific, workspace-locked
-- layouts.
myLayouts =
  -- onWorkspace "c" imLayout
  -- $ onWorkspace "6:Pix" gimpLayout
   onWorkspace "doc" docLayout
  $ MultiToggle.mkToggle (MultiToggle.single REFLECTX)
  $ MultiToggle.mkToggle (MultiToggle.single REFLECTY)
  $ onWorkspace "web" imLayout
  $ defaultLayouts


{-
  Custom keybindings. In this section we define a list of relatively
  straightforward keybindings. This would be the clearest place to
  add your own keybindings, or change the keys we have defined
  for certain functions.

  It can be difficult to find a good list of keycodes for use
  in xmonad. I have found this page useful -- just look
  for entries beginning with "xK":

  http://xmonad.org/xmonad-docs/xmonad/doc-endex-X.html

  Note that in the example below, the last three entries refer
  to nonstandard keys which do not have names assigned by
  xmonad. That's because they are the volume and mute keys
  on my laptop, a Lenovo W520.

  If you have special keys on your keyboard which you
  want to bind to specific actions, you can use the "xev"
  command-line tool to determine the code for a specific key.
    Launch the command, then type the key in question and watch
  the output.
    -}

myKeyBindings =
  [
    ((myModMask, xK_b), sendMessage ToggleStruts)
    , ((myModMask, xK_a), sendMessage MirrorShrink)
    , ((myModMask, xK_z), sendMessage MirrorExpand)
    , ((myModMask .|. shiftMask , xK_x), sendMessage $ MultiToggle.Toggle REFLECTX)
    , ((myModMask .|. shiftMask , xK_y), sendMessage $ MultiToggle.Toggle REFLECTY)
    --, ((myModMask, xK_o), spawn "emacs-snapshot")
    , ((myModMask, xK_o), spawn "$HOME/.local/bin/emacs --dump-file=$HOME/.emacs.d/.cache/dumps/spacemacs.pdmp &")
    , ((myModMask, xK_e), spawn "emacs-snapshot")  -- broken
    , ((myModMask, xK_p), spawn "rofi -show run") -- no more synapse
    , ((myModMask .|. shiftMask, xK_t), spawn "terminator")
    -- Different browsers
    , ((myModMask .|. shiftMask, xK_g), spawn "google-chrome")
    , ((myModMask .|. shiftMask, xK_m), spawn "chromium-browser")
    --, ((myModMask, xK_f), spawn "$HOME/.local/share/umake/bin/firefox-developer")
    , ((myModMask .|. shiftMask, xK_f), spawn "$HOME/.local/share/umake/bin/firefox-developer")
    , ((myModMask, xK_t), spawn "caja")
    , ((myModMask, xK_f), spawn "caja .")
    , ((myModMask, xK_c), spawn "caja")
    , ((myModMask .|. shiftMask, xK_l), spawn "gnome-screensaver-command --lock")  -- screenlock
    , ((myModMask, xK_s), spawn "gnome-screenshot")  -- screenshot
    -- it is broken for some unknow reason
    , ((myModMask .|. shiftMask, xK_s), spawn "gnome-screenshot -a")  -- interactive screenshot
    --, ((myModMask .|. shiftMask, xK_t), rectFloatFocused)   --Push window into float
    --, ((myModMask .|. shiftMask, xK_f), fullFloatFocused)   --Push window into full screen
    , ((myModMask, xK_u), focusUrgent)
    , ((myModMask, xK_F1), spawn "sudo -E -u jethros $HOME/.xmonad/bin/hotplug-dp.sh &")
    , ((myModMask, xK_F9), spawn "$HOME/.xmonad/bin/voldzen.sh + -d")
    , ((myModMask, xK_F10), spawn "$HOME/.xmonad/bin/voldzen.sh - -d")
  ] --where
    --fullFloatFocused = withFocused $ \f -> windows =<< appEndo `fmap` runQuery doFullFloat f
    --rectFloatFocused = withFocused $ \f -> windows =<< appEndo `fmap` runQuery (doRectFloat $ W.RationalRect 0.05 0.05 0.9 0.9) f

{-
  Management hooks. You can use management hooks to enforce certain
  behaviors when specific programs or windows are launched. This is
  useful if you want certain windows to not be managed by xmonad,
  or sent to a specific workspace, or otherwise handled in a special
  way.

  Each entry within the list of hooks defines a way to identify a
  window (before the arrow), and then how that window should be treated
  (after the arrow).

  To figure out to identify your window, you will need to use a
  command-line tool called "xprop". When you run xprop, your cursor
  will temporarily change to crosshairs; click on the window you
  want to identify. In the output that is printed in your terminal,
  look for a couple of things:
    - WM_CLASS(STRING): values in this list of strings can be compared
      to "className" to match windows.
        To find out the className, run ``$ xprop | grep WM_CLASS && APP_NAME_HERE``_
    - WM_NAME(STRING): this value can be compared to "resource" to match
      windows.

  The className values tend to be generic, and might match any window or
  dialog owned by a particular program. The resource values tend to be
  more specific, and will be different for every dialog. Sometimes you
  might want to compare both className and resource, to make sure you
  are matching only a particular window which belongs to a specific
  program.

  Once you've pinpointed the window you want to manipulate, here are
  a few examples of things you might do with that window:
        - doIgnore: this tells xmonad to completely ignore the window. It will
      not be tiled or floated. Useful for things like launchers and
      trays.
        - doFloat: this tells xmonad to float the window rather than tiling
      it. Handy for things that pop up, take some input, and then go away,
      such as dialogs, calculators, and so on.
        - doF (W.shift "Workspace"): this tells xmonad that when this program
      is launched it should be sent to a specific workspace. Useful
      for keeping specific tasks on specific workspaces. In the example
      below I have specific workspaces for chat, development, and
      editing images.
        -}

myManagementHooks :: [ManageHook]
myManagementHooks =
    [ resource =? "synapse" --> doIgnore
    , resource =? "stalonetray" --> doIgnore
    , className =? "mpv" --> doFloat <+> doF (W.shift "term")
    , (className =? "TexMaker") --> doF (W.shift "code")
    , (className =? "Code") --> doF (W.shift "code")
    , (className =? "Emacs-snapshot") --> doF (W.shift "code")
    , (className =? "Emacs") --> doF (W.shift "code")
    , (className =? "jetbrains-pycharm") --> doF (W.shift "code")
    , (className =? "jetbrains-idea") --> doF (W.shift "code")

    , (className =? "Zathura") --> doF (W.shift "doc")
    , (className =? "Master PDF Editor") --> doF (W.shift "doc")
    , (className =? "Evince") --> doF (W.shift "doc")

    , (className =? "Meld") --> doF (W.shift "mx")

    , (className =? "Mailspring") --> doF (W.shift "b")
    , (className =? "VirtualBox") --> doF (W.shift "b")
    , (className =? "Virt-manager") --> doF (W.shift "b")

    , (className =? "qutebrowser") --> doF (W.shift "web")
    , (className =? "Firefox") --> doF (W.shift "web")
    , (className =? "Firefox Developer Edition") --> doF (W.shift "web")

    , (className =? "vlc") --> doF (W.shift "a")

    , (className =? "Skype") --> doF (W.shift "b")
    , (className =? "Nocturn") --> doF (W.shift "a")
    , (className =? "Slack") --> doF (W.shift "b")
    , (className =? "desktop") --> doF (W.shift "a") -- reMarkable
    , (className =? "Corebird") --> doF (W.shift "a")
    , (className =? "Empathy") --> doF (W.shift "a")
    , (className =? "Pidgin") --> doF (W.shift "a")
    , (className =? "ScudCloud Slack") --> doF (W.shift "a")

    -- and float everything but the roster
    --, classNotRole ("Nocturn", "roster") --> doFloat

    , (className =? "Chromium-browser") --> doF (W.shift "web")
    , (className =? "Google-chrome") --> doF (W.shift "c")

    , (className =? "Terminator") --> doF (W.shift "a")
    , (className =? "Mendeley Desktop") --> doF (W.shift "b")

    , (className =? "terminus") --> doF (W.shift "a")

    , (className =? "Komodo IDE" <&&> resource =? "Komodo_find2") --> doFloat
    , (className =? "Komodo IDE" <&&> resource =? "Komodo_gotofile") --> doFloat
    , (className =? "Komodo IDE" <&&> resource =? "Toplevel") --> doFloat
    , (className =? "XMind") --> doF (W.shift "a")
    , (className =? "Gimp-2.8") --> doF (W.shift "a")
    ]
    where
        classNotRole :: (String, String) -> Query Bool
        classNotRole (c,r) = className =? c <&&> role /=? r
        role = stringProperty "WM_WINDOW_ROLE"


{-
  Workspace navigation keybindings. This is probably the part of the
  configuration I have spent the most time messing with, but understand
  the least. Be very careful if messing with this section.
    -}

-- We define two lists of keycodes for use in the rest of the
-- keyboard configuration. The first is the list of numpad keys,
-- in the order they occur on the keyboard (left to right and
-- top to bottom). The second is the list of number keys, in an
-- order corresponding to the numpad. We will use these to
-- make workspace navigation commands work the same whether you
-- use the numpad or the top-row number keys. And, we also
-- use them to figure out where to go when the user
-- uses the arrow keys.
numPadKeys =
  [
    xK_KP_Home, xK_KP_Up, xK_KP_Page_Up
      , xK_KP_Left, xK_KP_Begin,xK_KP_Right
      , xK_KP_End, xK_KP_Down, xK_KP_Page_Down
      , xK_KP_Insert, xK_KP_Delete, xK_KP_Enter
  ]

numKeys =
  [
    xK_7, xK_8, xK_9
      , xK_4, xK_5, xK_6
      , xK_1, xK_2, xK_3
      , xK_0, xK_minus, xK_equal
  ]

-- Here, some magic occurs that I once grokked but has since
-- fallen out of my head. Essentially what is happening is
-- that we are telling xmonad how to navigate workspaces,
-- how to send windows to different workspaces,
-- and what keys to use to change which monitor is focused.
myKeys = myKeyBindings ++
  [
    ((m .|. myModMask, k), windows $ f i)
      | (i, k) <- zip myWorkspaces numPadKeys
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
  ] ++
    [
    ((m .|. myModMask, k), windows $ f i)
      | (i, k) <- zip myWorkspaces numKeys
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
    ] ++
      M.toList (planeKeys myModMask (Lines 4) Finite) ++
        [
    ((m .|. myModMask, key), screenWorkspace sc
      >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [1,0,2]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
        ]

myThinkpadKeys :: [(String, X())]
myThinkpadKeys = [
         ("<XF86AudioLowerVolume>", spawn "$HOME/.xmonad/bin/voldzen.sh - -d")
        --, ("M-<XF86AudioLowerVolume>", spawn "amixer set Master 3dB-")
        , ("<XF86AudioRaiseVolume>", spawn "$HOME/.xmonad/bin/voldzen.sh + -d")
        --, ("M-<XF86AudioRaiseVolume>", spawn "amixer set Master 3dB+")
        --, ("<XF86AudioMute>", spawn "amixer set Master toggle; amixer set Headphone unmute &")
        , ("<XF86AudioMute>", spawn "amixer -q -D pulse sset Master toggle &")
        , ("<XF86Display>", spawn "sudo -E -u jethros $HOME/.xmonad/bin/hotplug-dp.sh &")
          -- FIXME:
        , ("<XF86MonBrightnessUp>"  , spawn "sudo $HOME/.xmonad/bin/adjust_brightness.sh + &")
        , ("<XF86MonBrightnessDown>", spawn "sudo $HOME/.xmonad/bin/adjust_brightness.sh - &")
        , ("M-\\", toggleTouchpad)
 ]

toggleTouchpad =
  let
    touchpad = "'SynPS/2 Synaptics TouchPad'"
    newStatus = "$(xinput --list " ++ touchpad ++ " | grep -c disabled)"
  in
    spawn $ "xinput --set-prop " ++ touchpad ++ " 'Device Enabled' " ++ newStatus


{-
  Here we actually stitch together all the configuration settings
  and run xmonad. We also spawn an instance of xmobar and pipe
  content into it via the logHook.
    -}

main = do
  --xmproc <- spawnPipe "xmobar ~/.xmonad/xmobarrc"
  xmonad $ docks $ ewmh $ pagerHints $ withUrgencyHook NoUrgencyHook $ defaultConfig {
    focusedBorderColor = myFocusedBorderColor
    , normalBorderColor = myNormalBorderColor
    , terminal = myTerminal
    , borderWidth = myBorderWidth
    , layoutHook = myLayouts
    , workspaces = myWorkspaces
    , modMask = myModMask
    , handleEventHook = fullscreenEventHook
    , startupHook = do
      setWMName "LG3D"
      windows $ W.greedyView startupWorkspace
      spawn "~/.xmonad/startup-hook"
    , manageHook = manageHook defaultConfig
      -- <+> placeHook (withGaps (16,0,16,0) (smart (1,0.98))) -- save some space for polybar
      <+> composeAll myManagementHooks
      <+> manageDocks
    }
    `additionalKeys` myKeys
    `additionalKeysP` myThinkpadKeys
