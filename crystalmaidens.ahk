/*
Autohotkey script for running various macros in Crystal Maidens game

Game MUST BE run on desktop in 1280x960 resolution, otherwise the script won't work at best,
or will sell or fodder your gear, waste your gems and drain your credit card at worst.

Latest version of the file https://drive.google.com/file/d/1U7eZ_zxmrDPVKy0MRtCAGWawgW0iczT4
*/ 
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//                       Crystal Maidens
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cm_Click(button)
{
  cx := cm_buttons[button][1]
  cy := cm_buttons[button][2]
  Click %cx%, %cy%
}

cm_ScreenCheck(screen)
{
  cm_pixel = 0
  while cm_pixel < screen.Length()
  {
    cm_pixel += 1
    PixelGetColor, cm_get_pixel_color, screen[cm_pixel][1], screen[cm_pixel][2]
    cm_color := screen[cm_pixel][3]
    if cm_get_pixel_color != %cm_color%
      return 0
  }
  if cm_pixel > 0
    return 1
}

cm_ScreenCheckTestTry(screen)
{
  cm_pixel = 0
  debug := []
  while cm_pixel < screen.Length()
  {
    cm_pixel += 1
    shade = 0
    while shade < 100
    {
      px = screen[cm_pixel][1]
      py = screen[cm_pixel][2]
      PixelSearch sx, sy, px, py, px, py, screen[cm_pixel][3], shade
      if ErrorLevel = 0
      {
      ;  MsgBox pixel %cm_pixel%, shade %shade%
        debug.push([cm_pixel, shade])
        break
      }
      shade += 1
    }
  }
  for i, r in debug
  {
    x := debug[i][1]
    y := debug[i][2]
    MsgBox pixel %x%, shade %y%
    FileAppend,
    (
    , [%x%, %y%]
    ), %cm_data_file_path%
  }
}

cm_LoadWait(screen, state := 1)
{
  Sleep 1000
  GoSub, cm_ClearUI
  Loop
  {
    if cm_ScreenCheck(screen) = state
    {
      Sleep 1000
      break
    }
    else
      continue
  }
  Sleep 1000
}

cm_SelectMaiden(maiden)
{
  if cm_ScreenCheck(cm_s_PlayMaidenSelection) = 1
    cm_drag_distance = 90
  else ; cm_MenuRoster
    cm_drag_distance = 180 ; 1) needs update to account for mastery shards bar's height, 2) but since it's no longer used, i don't care
  while maiden > 2
  {
    Sleep 500
    MouseMove, 550, 655 
    ;Click, down, 550, 655
    ;Sleep 200
    ;Click, up, 550, 565
    MouseClickDrag, L, 550, 655, 550, (655 - cm_drag_distance), 30
    maiden -= 2
    Sleep 500
  }
  Sleep 1000
  if maiden = 1
    Click 540, 510
  else
    Click 850, 510
  Sleep 1000
}





cm_Initialize:
cm_data_file_path = %A_Desktop%\cm_screen_data.ahk

Global cm_Maps := {51: [485, 669], 52: [700, 785], 53: [967, 796], 55: [669, 447], 56: [803, 429], 57: [943, 471], 58: [1036, 570]}

Global cm_buttons := {cm_b_MainSettings : [1253, 63], cm_b_MainRoster: [75, 920], cm_b_MainArena: [919, 919], cm_b_MainCampaign: [1205, 902]
, cm_b_CampaignMain: [81, 912], cm_b_CampaignRoster: [218, 916], cm_b_CampaignInventory: [370, 915]
, cm_b_ArenaSearch: [660, 382], cm_b_ArenaOpponent1: [1084, 460], cm_b_ArenaMaiden1: [200, 540]
, cm_b_MaidenItem1: [1083, 346], cm_b_MaidenItem2: [1082, 425], cm_b_MaidenItem2: [1081, 507], cm_b_MaidenItem14: [1079, 590], cm_b_MaidenItem15: [1081, 671], cm_b_MaidenItem16: [1081, 754], cm_b_MaidenItemUpgrade: [944, 818]
, cm_b_InventoryItem1: [239, 480], cm_b_InventorySell: [1078, 767], cm_b_SellConfirm: [651, 749], cm_b_InventorySelectAll: [560, 390], cm_b_InventoryToFodder: [995, 770]
, cm_b_UpgradeUpgrade: [1075, 749]
, cm_b_SettingsQuit: [836, 739]
, cm_b_BattleSpeedChange: [1155, 65], cm_b_BattleExit: [650, 550]
, cm_b_ShopBuy: [987, 709]
, cm_b_blank: [650, 130]
, cm_b_ConfirmYes: [550, 620], cm_b_WindowLargeClose: [1190, 280], cm_b_WindowSmallClose: [905, 337]
, cm_b_PopupWindowOk: [620, 620]}

GoSub, cm_ScreenData
#Include *i %A_Desktop%\cm_screen_data.ahk ; update screen data with locally recalibrated values, if they exist

return




;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//                       hotkeys
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#IfWinActive, Crystal Maidens ahk_class UnityWndClass

; press CTRL-Q to open macro menu
^q::
GoSub, cm_GUIMacroMenu_Main
return

; press F5 to reload the script
F5::Reload

; press F6 to pause the script - does it even work as i think it does..?
F6::Pause

;///////////////////////////////////////////////////////////////////////////////////////
;//                       other macros

; grind c2e22 map for kills on alt account - move to gui (?)
^g::
Loop, 100
  GoSub, cm_PlayMapGrindKills
return


;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//                       subroutine blocks
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;///////////////////////////////////////////////////////////////////////////////////////
;//                       quit the game

cm_QuitGame:
cm_Click("cm_b_MainSettings")
Sleep 5000
cm_Click("cm_b_SettingsQuit")
Sleep 5000
cm_Click("cm_b_ConfirmYes")
return

;///////////////////////////////////////////////////////////////////////////////////////
;//                       move mouse away from interactive elements

cm_ClearUI:
cm_Click("cm_b_blank")
Sleep 500
return

;///////////////////////////////////////////////////////////////////////////////////////
;//                       close autohotkey GUI

cm_MacroRunStart:
Gui, Destroy
Sleep 500
WinActivate, Crystal Maidens ahk_class UnityWndClass
Sleep 500
cm_Click("cm_b_blank")
Sleep 500
return

;///////////////////////////////////////////////////////////////////////////////////////
;//                       set battle speed to x4

cm_SetSpeedx4:
while cm_ScreenCheck(cm_s_BattleSpeed_1or2) = 1
{
  cm_Click("cm_b_BattleSpeedChange")
  Sleep 500
  GoSub, cm_ClearUI
}
return

;///////////////////////////////////////////////////////////////////////////////////////
;//                       start map

cm_StartMap:
cm_no_energy = 0
while cm_no_energy = 0
{
  GoSub, cm_ClearUI
  if cm_ScreenCheck(cm_s_PlayMapMenu) = 1
  {
    Click 1030, 760 ; "Play" button
    Sleep 1000
    cm_Click("cm_b_ConfirmYes") ; close items/coins/orbs overcap warning window, if it pops up
  }
  if cm_ScreenCheck(cm_s_BattleVictoryDefeat) = 1
    Click 530, 760 ; "Retry" button
  Sleep 3000
  if cm_ScreenCheck(cm_s_PlayWarningEnergy) = 0
    cm_no_energy = 1
  else
  {
    cm_Click("cm_b_WindowSmallClose")
    Sleep 60000 ; wait 5 minutes before trying again
  }
}
return

;///////////////////////////////////////////////////////////////////////////////////////
;//                       play map

cm_PlayMap:

GoSub, cm_StartMap
cm_LoadWait(cm_s_BattleMap)
GoSub, cm_SetSpeedx4

Sleep 1000
Click, down, 280, 930
Sleep 200
Click, up, 380, 600
Sleep 200
Click, down, 490, 930
Sleep 200
Click, up, 590, 600
Sleep 200
Click, down, 700, 930
Sleep 200
Click, up, 800, 600
Sleep 200
Click, down, 910, 930
Sleep 200
Click, up, 1010, 600
Sleep 200

cm_LoadWait(cm_s_BattleVictoryDefeat)

return

;///////////////////////////////////////////////////////////////////////////////////////
;//                       drop in ranks in arena, one maiden cycle

cm_ArenaDrop:
Loop, %cm_arena_repeat%
{
  cm_Click("cm_b_MainArena")
  cm_LoadWait(cm_s_ArenaMenu)
  Sleep 2000
  cm_Click("cm_b_PopupWindowOk") ; accept defense wins
  Sleep 2000
  cm_maiden_search = 0
  while cm_ScreenCheck(cm_s_ArenaMaidenTired) = 1
  {
    cm_maiden += 1
    cm_select_maiden := cm_maiden
    cm_Click("cm_b_ArenaMaiden1")
    cm_LoadWait(cm_s_PlayMaidenSelection)
    if cm_maiden_search = 1
    {
      cm_select_maiden = 2
      if Floor(cm_maiden / 2) * 2 = cm_maiden
        cm_select_maiden = 3
    }
    cm_SelectMaiden(cm_select_maiden)
    cm_LoadWait(cm_s_ArenaMenu)
    cm_maiden_search = 1
  }
  cm_Click("cm_b_ArenaSearch")
  Sleep 2000
  cm_Click("cm_b_ConfirmYes")
  cm_LoadWait(cm_s_ArenaOpponentSelection)
  cm_Click("cm_b_ArenaOpponent1")
  cm_LoadWait(cm_s_BattleMap)
  cm_Click("cm_b_MainSettings")
  Sleep 2000
  cm_Click("cm_b_BattleExit")
  Sleep 2000
  cm_Click("cm_b_ConfirmYes")
  cm_LoadWait(cm_s_MainMenu)
}
return


;///////////////////////////////////////////////////////////////////////////////////////
;//                       turn rare items to fodder

cm_FodderRares:
Sleep 100
cm_Click("cm_b_blank")
Sleep 100
Click 680, 390 ; select all by type
Sleep 1000
Click 680, 470 ; rare
Sleep 2000
if cm_ScreenCheck(cm_s_InventoryFodderButton) = 1
{
  Sleep 200
  cm_Click("cm_b_InventoryToFodder")
  cm_LoadWait(cm_s_SmallWindowConfirm)
  cm_Click("cm_b_ConfirmYes")
  cm_LoadWait(cm_s_SmallWindowConfirm)
  cm_Click("cm_b_PopupWindowOk")
  cm_LoadWait(cm_s_InventoryMenu)
}
return

/*
cm_FodderRares:
cm_RareFodderColor := cm_s_RareFodderColor[1][3]
Loop, 999
{
  Sleep 100
  cm_Click("cm_b_blank")
  Sleep 100
  ;cm_Click("cm_b_InventorySelectAll")
  Click 560, 390
  Sleep 100
  cm_Click("cm_b_blank")
  
  cm_inv_y = 505 ; 115
  Loop, 3
  {
    cm_inv_x = 265 ; 115
    Loop, 5
    {
      PixelGetColor, color, %cm_inv_x%, %cm_inv_y%
      if color = %cm_RareFodderColor%
      {
        Sleep 200
        cm_inv_y2 := cm_inv_y - 60
        Click %cm_inv_x%, %cm_inv_y2%
        Sleep 100
        cm_Click("cm_b_blank")
        Sleep 100
      }
      cm_inv_x += 115
    }
    cm_inv_y += 115
  }  
  if cm_ScreenCheck(cm_s_InventoryFodderButton) = 1
  {
    Sleep 200
    cm_Click("cm_b_InventoryToFodder")
    cm_LoadWait(cm_s_SmallWindowConfirm)
    cm_Click("cm_b_ConfirmYes")
    cm_LoadWait(cm_s_SmallWindowConfirm)
    cm_Click("cm_b_PopupWindowOk")
    cm_LoadWait(cm_s_InventoryMenu)
  }
  else
    break
}
return
*/


;///////////////////////////////////////////////////////////////////////////////////////
;//                       farm fodder

cm_InfiniteEnergyFarm:
Sleep 1000
GoSub, cm_ClearUI
Sleep 1000
Loop, 999
{
  ; open selected map
  click_mapx := cm_Maps[cm_MapToFarm][1]
  click_mapy := cm_Maps[cm_MapToFarm][2]
  Click %click_mapx%, %click_mapy%
  cm_LoadWait(cm_s_PlayMapMenu)
  
  ; run the map X times
  Loop, %cm_LoopRepeat%
  {
    Gosub, cm_PlayMap
    if cm_LoopRepeat = 999 ; or until inventory is full
    {
      Sleep 2000
      if cm_ScreenCheck(cm_s_VictoryLootOvercap) = 1
        break
    }
  }
  
  ; exit victory menu
  Sleep 1000
  Click 1060, 330
  cm_LoadWait(cm_s_CampaignMenu)
  
  ; open inventory menu
  cm_Click("cm_b_CampaignInventory")
  cm_LoadWait(cm_s_InventoryMenu)
  
  ; turn all rare items into fodder
  Gosub, cm_FodderRares
  
  ; exit inventory menu
  cm_Click("cm_b_WindowLargeClose")
  cm_LoadWait(cm_s_CampaignMenu)
}

return


;///////////////////////////////////////////////////////////////////////////////////////
;//                       grind kills on c2e22 with astrid (slot 1) and taki (slot 3)

cm_PlayMapGrindKills:
GoSub, cm_StartMap
cm_LoadWait(cm_s_BattleMap)
GoSub, cm_SetSpeedx4

Sleep 1000

Click, down, 700, 930 ; maiden in 3rd slot (Taki)
Sleep 200
Click, up, 40, 525
Sleep 100
Click, down, 700, 930
Sleep 100
MouseMove, 40, 525
Sleep 3000
Click, up, 40, 525
Sleep 100

Click, down, 280, 930 ; maiden in 1st slot (Astrid)
Sleep 200
Click, up, 150, 450
Sleep 200

Loop, 35
{
  Click 800, 930 ; cast 3rd maiden's skill
  GoSub, cm_ClearUI
}

Click, down, 490, 930 ; maiden in 1st slot (Amira)
Sleep 200
Click, up, 40, 645
Sleep 200

Loop, 3
{
  Click 800, 930 ; cast 3rd maiden's skill
  GoSub, cm_ClearUI
}

Loop, 4
{
  Click 590, 930 ; cast 2nd maiden's skill
  GoSub, cm_ClearUI
}

Sleep 500
Click, down, 700, 930 ; maiden in 3rd slot (Taki)
Sleep 100
Click, up, 815, 355
Sleep 100
Click, down, 490, 930 ; maiden in 1st slot (Amira)
Sleep 100
Click, up, 815, 355
Sleep 5500

Click 725, 610 ; defeat button
cm_LoadWait(cm_s_BattleVictoryDefeat)

return


;///////////////////////////////////////////////////////////////////////////////////////
;//                       update screen data

cm_ScreenUpdate:
{
  FileAppend,
  (

Global %cm_d_update% := [
  ), %cm_data_file_path%
  cm_d_comma = 0
  for i in %cm_d_update%
  {
    if cm_d_comma
    {
      FileAppend,
      (
      ,
      ), %cm_data_file_path%
    }
    cm_d_comma = 1
    x := %cm_d_update%[i][1]
    y := %cm_d_update%[i][2]
    PixelGetColor, color, %x%, %y%
    FileAppend,
    (
    [%x%, %y%, %color%]
    ), %cm_data_file_path%
  }
  FileAppend,
  (
  ]
  ), %cm_data_file_path%
  for i in %cm_d_update%
  {
    Sleep 500
    MouseMove, %cm_d_update%[i][1], %cm_d_update%[i][2]
  }
}
return


;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//                       read screen/menu/button ui
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; 1) press Ctrl+Z to initialize
; 2) move cursor over desired UI element and press Ctrl+X
; 3) repeat previous step with several UI elements unique to the current screen/menu
; 4) move mouse away from any selected cursor-sensitive buttons and elements
; 5) press Ctrl+C to read colors at selected locations and write data to text file

^z::
cm_new_screen_label := []
return

^x::
MouseGetPos, x, y
cm_new_screen_label.push([x, y])
return

^c::
cm_d_update = cm_new_screen_label
GoSub, cm_ScreenUpdate
return


;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//                       macro ui
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;///////////////////////////////////////////////////////////////////////////////////////
;//                       main menu

cm_GUIMacroMenu_Main:
Gui, cm_GUIMacroMenu:New,, Crystal Maidens macros
Gui, Add, Text, x0 vcmGUImain1, Select the macro for Crystal Maidens:
Gui, Add, ListBox, w200 r6 Choose1 vcmGUIMacroChoice, Play Map|Arena Derank|Sell Items|Infinite Energy Farm|Fodder Rare Items|Screen Recalibration
Gui, Add, Button, x0 gcm_GUIMacroMenu_Cancel vcmGUImain2, Cancel
Gui, Add, Button, x+0 gcm_GUIMacroMenu_Continue vcmGUImain3 Default, Continue
Gui, Show, w250
return

cm_GUIMacroMenu_Cancel:
Gui, Destroy
return

cm_GUIMacroMenu_Continue:
Gui, Submit, NoHide
cm_GUIMacro_selected := StrReplace(cmGUIMacroChoice, " ", "") ; remove single whitespaces
GoSub, cm_GUIMacroSettings_%cm_GUIMacro_selected%
return

cm_GUIMacroMenu_Page2:
GuiControl, Hide, cmGUImain1
GuiControl, Hide, cmGUImain2
GuiControl, Hide, cmGUImain3
GuiControl, Hide, cmGUIMacroChoice
Gui, Add, Button, x0 gcm_GUIMacroMenu_Back, Back
Gui, Add, Button, x+0 gcm_GUIMacroMenu_Begin Default, Begin
return

cm_GUIMacroMenu_Back:
GoSub, cm_GUIMacroMenu_Main
return

cm_GUIMacroMenu_Begin:
Gui, Submit, NoHide
GoSub, cm_MacroRunStart
cm_LoopRepeat := cmGUIMacroRepeatTimes ? cmGUIMacroRepeatTimes : 999
GoSub, cm_MacroRun_%cm_GUIMacro_selected%
return

;///////////////////////////////////////////////////////////////////////////////////////
;//                       macro settings

;// Play Map
cm_GUIMacroSettings_PlayMap:
GoSub, cm_GUIMacroMenu_Page2
Gui, Add, Text, x0, Repeat:
Gui, Add, Edit
Gui, Add, UpDown, vcmGUIMacroRepeatTimes Range0-50, 10
Gui, Add, Text, x+0, (0 = infinite)
Gui, Add, Text, x0 y0, "%cmGUIMacroChoice%"
Gui, Add, Text, x0 y+0, `nDESCRIPTION:
Gui, Add, Text, x0 y+0, Play the currently selected map
Gui, Show, h300
return

;// Sell Items
cm_GUIMacroSettings_SellItems:
GoSub, cm_GUIMacroMenu_Page2
Gui, Add, Text, x0, Repeat:
Gui, Add, ListBox, w200 r3 Choose1 vcmGUIMacroRepeatTimes, 5|10|25
Gui, Add, Text, x0 y0, "%cmGUIMacroChoice%"
Gui, Add, Text, x0 y+0, `nDESCRIPTION:
Gui, Add, Text, x0 y+0, Sell items in he first slot`n`nOpen inventory tab to sell `nitems from (e.g. event ingredients)`nand select the amount to sell.
Gui, Show, h300
return

;// Arena Derank
cm_GUIMacroSettings_ArenaDerank:
GoSub, cm_GUIMacroMenu_Page2
Gui, Add, Text, x0, Repeat:
Gui, Add, Edit
Gui, Add, UpDown, vcmGUIMacroRepeatTimes Range0-200, 200
Gui, Add, Text, x+0, (0 = infinite)
Gui, Add, Text, x0, Start with maiden in roster:
Gui, Add, Edit
Gui, Add, UpDown, vcm_start_maiden Range1-100, 1
Gui, Add, Text, x0 y0, "%cmGUIMacroChoice%"
Gui, Add, Text, x0 y+0, `nDESCRIPTION:
Gui, Add, Text, x0 y+0, Lose PvP matches`n`nLeave a single maiden in your`nPvP attack team, then return to`nthe main island menu.
Gui, Show, h300
return

;// Infinite Energy Farm
cm_GUIMacroSettings_InfiniteEnergyFarm:
GoSub, cm_GUIMacroMenu_Page2
Gui, Add, Text, x0, Repeat before foddering the loot:
Gui, Add, Edit, w50
Gui, Add, UpDown, vcmGUIMacroRepeatTimes Range0-120, 70
Gui, Add, Text, x+0, (0 = repeat until inventory is full)
Gui, Add, Text, x0, Select which map to farm:
Gui, Add, ListBox, w150 r7 Choose1 vcm_MapToFarm, 51 - Water|52 - Dark|53 - Dark|55 - Light|56 - Fire|57 - Nature|58 - Light
Gui, Add, Text, x0 y0, "%cmGUIMacroChoice%"
Gui, Add, Text, x0 y+0, `nDESCRIPTION:
Gui, Add, Text, x0 y+0, Farm infinite energy event`n`nSelect the map in campaign 3`nand make sure you have enough free`nspace in your inventory.
Gui, Show, h350
return

;// Fodder Rare Items
cm_GUIMacroSettings_FodderRareItems:
GoSub, cm_GUIMacroMenu_Page2
Gui, Add, Text, x0 y0, "%cmGUIMacroChoice%"
Gui, Add, Text, x0 y+0, `nDESCRIPTION:
Gui, Add, Text, x0 y+0, Turn all rare items into fodder`n`nMainly for testing before infinite energy event.`nOpen inventory and see if all visible rare items`nwill turn into fodder.
Gui, Show, h300
Gui, Add, Text, y+65, If it doesn't work, then make sure "select all"`noption is on, hover mouse cursor over`nrare item's dark blue filling (several pixels`nto the left or right of its level display), then`npress CTRL-Z,X,C and update`ncm_RareFodderColor variable in the`n"crystalmaidens.ahk" file with new value`nwritten in "cm_screen_data.ahk" on your desktop.
return

;// Screen Recalibration
cm_GUIMacroSettings_ScreenRecalibration:
GoSub, cm_GUIMacroMenu_Page2
Gui, Add, Text, x0, Select the screen:
Gui, Add, ListBox, w200 r16 Choose1 vcm_d_update, cm_s_CampaignMenu|cm_s_PlayMapMenu|cm_s_PlayWarningEnergy|cm_s_BattleMap|cm_s_BattleSpeed_1or2|cm_s_BattleVictoryDefeat|cm_s_VictoryLootOvercap|cm_s_InventoryMenu|cm_s_InventoryFodderButton|cm_s_SmallWindowConfirm|cm_s_MainMenu|cm_s_ArenaMenu|cm_s_ArenaOpponentSelection|cm_s_ArenaMaidenTired|cm_s_PlayMaidenSelection|cm_s_RareFodderColor
Gui, Add, Text, x0 y0, "%cmGUIMacroChoice%"
Gui, Add, Text, x0 y+0, `nDESCRIPTION:
Gui, Add, Text, x0 y+0, Updates pixel color data used`nto identify the active screen`nto match the current pixel colors.
Gui, Show, h450
return

;///////////////////////////////////////////////////////////////////////////////////////
;//                       run selected macro

;// Play Map
cm_MacroRun_PlayMap:
Loop, %cm_LoopRepeat%
  GoSub, cm_PlayMap
return

;// Sell Items
cm_MacroRun_SellItems:
Loop, %cm_LoopRepeat%
{
  cm_Click("cm_b_InventoryItem1")
  Sleep 300
  cm_Click("cm_b_InventorySell")
  Sleep 300
  cm_Click("cm_b_SellConfirm")
  Sleep 300
  cm_Click("cm_b_ConfirmYes")
  Sleep 2000
}
return

;// Arena Derank
cm_MacroRun_ArenaDerank:
cm_maiden := cm_start_maiden
cm_arena_repeat := cm_LoopRepeat
GoSub, cm_ArenaDrop
;GoSub, cm_QuitGame
return

;// Infinite Energy Farm
cm_MacroRun_InfiniteEnergyFarm:
cm_MapToFarm := RegExReplace(cm_MapToFarm, "[^0-9]") ; remove text
GoSub, cm_InfiniteEnergyFarm
;MsgBox cm_MapToFarm %cm_MapToFarm%, cm_LoopRepeat %cm_LoopRepeat%
return

;// Fodder Rare Items
cm_MacroRun_FodderRareItems:
GoSub, cm_FodderRares
return

;// Screen Recalibration
cm_MacroRun_ScreenRecalibration:
GoSub, cm_ScreenUpdate
Reload
return


;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//                       screen data
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cm_ScreenData:

Global cm_s_CampaignMenu := [[78, 933, 0x4DB5EA],[212, 917, 0x62ABF5],[350, 925, 0xFFA694],[880, 900, 0x42A2E7],[932, 902, 0x682F86],[1197, 894, 0x0D4968],[387, 56, 0x39E7FF],[591, 63, 0xD1C3B3],[1022, 56, 0x3130BD],[1246, 50, 0x2E82D4]]
Global cm_s_PlayMapMenu := [[82, 270, 0xF793DF],[486, 280, 0xBDEAFA],[547, 280, 0x4233AA],[741, 285, 0x8459F7],[647, 300, 0x526084],[283, 278, 0x4D6D8F],[969, 280, 0x4D688B],[72, 538, 0xD645B5],[1225, 538, 0xD74DB8],[191, 828, 0x3F455E],[1023, 746, 0x55BFE4]]
Global cm_s_PlayWarningEnergy := [[437, 751, 0x4A6889],[459, 750, 0x4A6889],[504, 749, 0x4A6889],[776, 750, 0x4A6889],[808, 745, 0x4A6889],[857, 749, 0x4A6889]]
Global cm_s_BattleMap := [[549, 51, 0x2C1799],[591, 66, 0x4F6186],[742, 41, 0xB2CEC8],[1125, 66, 0x76D0F4],[1149, 83, 0x40A0E7],[1228, 67, 0x3F9FE7],[45, 806, 0x8CB621],[121, 806, 0x9CA2AD]]
Global cm_s_BattleSpeed_1or2 := [[1177, 67, 0x42A2E7],[1177, 68, 0x42A2E7],[1178, 67, 0x42A2E7],[1178, 68, 0x42A2E7]]
Global cm_s_BattleVictoryDefeat := [[587, 426, 0x4D46B8],[595, 426, 0x4D46B8],[608, 426, 0x4D46B8],[588, 439, 0x4D46B8],[596, 437, 0x4D46B8],[608, 437, 0x4D46B8],[587, 450, 0x4D46B8],[595, 447, 0x4D46B8],[602, 447, 0x4D46B8]]
Global cm_s_VictoryLootOvercap := [[470, 617, 0xAFD7E3]]

Global cm_s_InventoryMenu := [[105, 380, 0x476934],[108, 514, 0x476935],[107, 651, 0x476834],[109, 714, 0x476936],[195, 304, 0x813965],[245, 303, 0x793861],[303, 304, 0x813965],[853, 740, 0x5475A6],[938, 740, 0x5576A8],[1057, 740, 0x5576A8],[1168, 740, 0x5576A8]]
Global cm_s_InventoryFodderButton := [[959, 778, 0x67C084],[959, 782, 0x6BC489],[1036, 777, 0x549C5C],[1036, 782, 0x5AA966]]
Global cm_s_SmallWindowConfirm := [[423, 323, 0x4F7299],[549, 322, 0x7D4FF9],[744, 321, 0xD3C6FC],[862, 319, 0x4F7399],[432, 676, 0x4A6889],[646, 673, 0x4A6889],[852, 678, 0x4A6889],[412, 639, 0xFD9BE5],[891, 645, 0xF796DE]]

Global cm_s_MainMenu := [[41, 468, 0x462A39],[43, 468, 0x452939],[46, 468, 0x452939],[49, 468, 0x452939]]

Global cm_s_ArenaMenu := [[596, 296, 0x4F6186],[610, 297, 0x4F6186],[635, 297, 0x4F6186],[651, 296, 0x4F6186],[1078, 460, 0x3F4A76],[1087, 460, 0x3F4A76],[1077, 470, 0x3F4B76],[1088, 474, 0x3F4B76]]
Global cm_s_ArenaOpponentSelection := [[596, 296, 0x4F6186],[610, 297, 0x4F6186],[635, 297, 0x4F6186],[651, 296, 0x4F6186],[1062, 422, 0xADD1DE],[1069, 422, 0xADD1DE],[1080, 422, 0xADD1DE]]
Global cm_s_ArenaMaidenTired := [[297, 532, 0x4E4288],[300, 532, 0x4E4288],[303, 532, 0x4E4288]]
Global cm_s_PlayMaidenSelection := [[596, 296, 0x4F6186],[610, 297, 0x4F6186],[635, 297, 0x4F6186],[651, 296, 0x4F6186],[770, 388, 0xBEDEF4],[785, 388, 0xBEDEF4],[803, 388, 0xBEDEF4],[772, 399, 0xBEDEF4],[785, 398, 0xBEDEF4],[804, 400, 0xBEDEF4]]

Global cm_s_RareFodderColor := [[265, 505, 0x655C55]]

return

