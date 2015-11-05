
;========================================================================================================================
; TEXTS
;========================================================================================================================

;========================================================================================================================
; Top Menu text
;========================================================================================================================
                even
TopMenu_Positions:
                dc.w    $00A6          ; on left
                dc.w    $00D8          ; on right
                even
;-------------------------------------------------------------------------------
TopMenuIndex:
                dc.w    TopMenu_Status-TopMenuIndex
                dc.w    TopMenu_Map-TopMenuIndex
                dc.w    TopMenu_Equip-TopMenuIndex
                dc.w    TopMenu_Status-TopMenuIndex
                dc.w    TopMenu_Status-TopMenuIndex
                dc.w    TopMenu_Status-TopMenuIndex

TopMenu_Status: dc.b    $08, "< EQUIP  "
                dc.b    $08, "   MAP  >"
TopMenu_Map:    dc.b    $08, "< STATUS "
                dc.b    $08, "  EQUIP >"
TopMenu_Equip:  dc.b    $08, "<  MAP   "
                dc.b    $08, " STATUS >"

                even

;========================================================================================================================
; Stats text
;========================================================================================================================

StatTextPosotions:
                dc.w    $020A          ; 'stats      '                $0000               $0005
                dc.w    $025A          ; dividing line                $0001               $0004
                dc.w    $02AA          ; speed                        $0002               $0003
                dc.w    $02FA          ; accel                        $0003               $0002
                dc.w    $034A          ; jump                         $0004               $0001
                even

StatText:
                dc.b    $0E, "STATISTICS     "
                dc.b    $0E, "==============="
                dc.b    $0E, "MAX SPEED      "
                dc.b    $0E, "ACCELERATION   "
                dc.b    $0E, "JUMP HEIGHT    "
                even
                
;========================================================================================================================
; Status text
;========================================================================================================================

StatusTextPositions:
                dc.w    $01E6          ; rings                        $0000               $0007
                dc.w    $0236          ; parts                        $0001               $0006
                dc.w    $0286          ; exp                          $0002               $0005
                dc.w    $02D6          ; next                         $0003               $0004
                dc.w    $0326          ; time                         $0004               $0003
                dc.w    $0464          ; collected items              $0005               $0002
                dc.w    $04B4          ; dividing line                $0006               $0001
                even

StatusText:
                dc.b    $0E, "RINGS          "
                dc.b    $0E, "PARTS          "
                dc.b    $0E, "EXP            "
                dc.b    $0E, "NEXT           "
                dc.b    $0E, "TIME           "
                dc.b    $0E, "COLLECTED ITEMS"
                dc.b    $22, "===================================="
                even

;========================================================================================================================
; Equip Menu text
;========================================================================================================================

Equip_Menu_Items:
                dc.b    $0E, "ABILITY A      "          ; 8
                dc.b    $0E, "ABILITY B      "          ; 7
                dc.b    $0E, "ABILITY C      "          ; 6
                dc.b    $0E, "SHOES          "          ; 5
                dc.b    $0E, "ITEM 1         "          ; 4
                dc.b    $0E, "ITEM 2         "          ; 3
                dc.b    $0E, "CHAOS EMERALD  "          ; 2
                even

Equip_Text_Positions:
                dc.w    $01E6          ; ability a
                dc.w    $0286          ; ability b
                dc.w    $0326          ; ability c
                dc.w    $020A          ; shoes
                dc.w    $02AA          ; item 1
                dc.w    $034A          ; item 2
                dc.w    $03EA          ; chaos emerald
                even

Equip_Text_Highlight:            ; in pairs of 2, i think. first is the text to highlight, second is the number (zone, quantity, wahtever it's dispalying)
                dc.w    $0606, $0624  ; ability a                                    ; as for the numbers themselves,
                dc.w    $0806, $0824  ; ability b                                    ; the first byte is how many rows from the top it is,
                dc.w    $0A06, $0A24  ; ability c                                    ; the second is the horizontal rows multiplied by 2 for some reason
                dc.w    $062A, $0940  ; shoes
                dc.w    $082A, $0A40  ; item 1
                dc.w    $0A2A, $0B40  ; item 2
                dc.w    $0C2A, $0C40  ; chaos emerald
                even



;-------------------------------------------------------------------------------
Inventory_Text_Positions:   ; I think these numbers are how many 8x8 tiles before drawing each option
                dc.w    $0504          ; $0000               $000C
                dc.w    $052A          ; $0006               $0006
                dc.w    $0554          ; $0001               $000B
                dc.w    $057A          ; $0007               $0005
                dc.w    $05A4          ; $0002               $000A
                dc.w    $05CA          ; $0008               $0004
                dc.w    $05F4          ; $0003               $0009
                dc.w    $061A          ; $0009               $0003
                dc.w    $0644          ; $0004               $0008
                dc.w    $066A          ; $000A               $0002
                even
Inventory_Text_Highlight:            ; in pairs of 2, i think. first is the text to highlight, second is the number (zone, quantity, wahtever it's dispalying)
                dc.w    $1004, $1022                                 ; as for the numbers themselves,
                dc.w    $102A, $1048
                dc.w    $1104, $1122                                 ; the first byte is how many rows from the top it is,
                dc.w    $112A, $1148
                dc.w    $1204, $1222                                 ; the second is the horizontal rows multiplied by 2 for some reason
                dc.w    $122A, $1248
                dc.w    $1304, $1322
                dc.w    $132A, $1348
                dc.w    $1404, $1422
                dc.w    $142A, $1448
                dc.w    $1504, $1522
                dc.w    $152A, $1548
                even
;-------------------------------------------------------------------------------

Debug_Menu_Items:
                dc.b    $0E, "SAVE IN SLOT 1 "          ; 9
                dc.b    $0E, "SAVE IN SLOT 2 "          ; 8
                dc.b    $0E, "SAVE IN SLOT 3 "          ; 7
                dc.b    $0E, "ITEM PLACEMENT "          ; 6
                dc.b    $0E, "SUPER SONIC    "          ; 5
                dc.b    $0E, "ADD 1 MINUTE   "          ; 4
                dc.b    $0E, "ADD EMERALD    "          ; 3
                dc.b    $0E, "LEVEL SELECT   "          ; 2
                dc.b    $0E, "ALL ABILITIES  "          ; 1
                dc.b    $0E, "1 OF EVERY ITEM"          ; 0
                dc.b    $0E, "VRAM VIEWER    "          ; 0
                even

Debug_Text_Positions:
                dc.w    $01E6          ; save slot 1
                dc.w    $0236          ; save slot 2
                dc.w    $0286          ; save slot 3
                dc.w    $02D6          ; debug item placement
                dc.w    $0326          ; toggle super sonic mode
                dc.w    $0376          ; add to timer
                dc.w    $03C6          ; add emerald
                dc.w    $0416          ; level select
                dc.w    $0466          ; all abilities
                dc.w    $04B6          ; give all items
                dc.w    $0506          ; vram
                even

Debug_Text_Highlight:            ; in pairs of 2, i think. first is the text to highlight, second is the number (zone, quantity, wahtever it's dispalying)
                dc.w    $0606, $0624  ; save slot 1                                  ; as for the numbers themselves,
                dc.w    $0706, $0724  ; save slot 2                                  ; the first byte is how many rows from the top it is,
                dc.w    $0806, $0824  ; save slot 3                                  ; the second is the horizontal rows multiplied by 2 for some reason
                dc.w    $0906, $0924  ; debug item placement
                dc.w    $0A06, $0A24  ; toggle super sonic mode
                dc.w    $0B06, $0B24  ; add to timer
                dc.w    $0C06, $0C24  ; add emerald
                dc.w    $0D06, $0D24  ; level select
                dc.w    $0E06, $0E24  ; all abilities
                dc.w    $0F06, $0F24  ; give all items
                dc.w    $1006, $1024  ; vram
                even
; ===========================================================================

SoundTest_Menu_Items:
                dc.b    $0E, "PLAY SOUND     "          ; 4
                dc.b    $0E, "TEMPO DIVIDER  "          ; 3
                dc.b    $0E, "TEMPO MODIFIER "          ; 2
                dc.b    $0E, "MUSIC PITCH    "          ; 1
                dc.b    $0E, "DRUM KIT       "          ; 0
                even

SoundTest_Text_Positions:
                dc.w    $0196          ; SOUND TEST
                dc.w    $01E6          ; TEMPO DIVIDER
                dc.w    $0236          ; TEMPO MODIFIER
                dc.w    $0286          ; MUSIC PITCH
                dc.w    $02D6          ; DRUM KIT
                even

SoundTest_Text_Highlight:            ; in pairs of 2, i think. first is the text to highlight, second is the number (zone, quantity, wahtever it's dispalying)
                dc.w    $0506, $0524  ; SOUND TEST                                     ; as for the numbers themselves,
                dc.w    $0606, $0624  ; TEMPO DIVIDER                                  ; the first byte is how many rows from the top it is,
                dc.w    $0706, $0724  ; TEMPO MODIFIER                                 ; the second is the horizontal rows multiplied by 2 for some reason
                dc.w    $0806, $0824  ; MUSIC PITCH
                dc.w    $0906, $0924  ; DRUM KIT
                even

SoundTest_VU_Text:
                dc.b    " DAC"          ; 0
                dc.b    "PSG3"          ; 1
                dc.b    "PSG2"          ; 2
                dc.b    "PSG1"          ; 3
                dc.b    " FM6"          ; 4
                dc.b    " FM5"          ; 5
                dc.b    " FM4"          ; 6
                dc.b    " FM3"          ; 7
                dc.b    " FM2"          ; 8
                dc.b    " FM1"          ; 9
                even

SoundTestNotes:
                dc.b	"    "
                dc.b	"C  0"
                dc.b	"C* 0"
                dc.b	"D  0"
                dc.b	"D* 0"
                dc.b	"E  0"
                dc.b	"F  0"
                dc.b	"F* 0"
                dc.b	"G  0"
                dc.b	"G* 0"
                dc.b	"A  0"
                dc.b	"A* 0"
                dc.b	"B  0"
                dc.b	"C  1"
                dc.b	"C* 1"
                dc.b	"D  1"
                dc.b	"D* 1"
                dc.b	"E  1"
                dc.b	"F  1"
                dc.b	"F* 1"
                dc.b	"G  1"
                dc.b	"G* 1"
                dc.b	"A  1"
                dc.b	"A* 1"
                dc.b	"B  1"
                dc.b	"C  2"
                dc.b	"C* 2"
                dc.b	"D  2"
                dc.b	"D* 2"
                dc.b	"E  2"
                dc.b	"F  2"
                dc.b	"F* 2"
                dc.b	"G  2"
                dc.b	"G* 2"
                dc.b	"A  2"
                dc.b	"A* 2"
                dc.b	"B  2"
                dc.b	"C  3"
                dc.b	"C* 3"
                dc.b	"D  3"
                dc.b	"D* 3"
                dc.b	"E  3"
                dc.b	"F  3"
                dc.b	"F* 3"
                dc.b	"G  3"
                dc.b	"G* 3"
                dc.b	"A  3"
                dc.b	"A* 3"
                dc.b	"B  3"
                dc.b	"C  4"
                dc.b	"C* 4"
                dc.b	"D  4"
                dc.b	"D* 4"
                dc.b	"E  4"
                dc.b	"F  4"
                dc.b	"F* 4"
                dc.b	"G  4"
                dc.b	"G* 4"
                dc.b	"A  4"
                dc.b	"A* 4"
                dc.b	"B  4"
                dc.b	"C  5"
                dc.b	"C* 5"
                dc.b	"D  5"
                dc.b	"D* 5"
                dc.b	"E  5"
                dc.b	"F  5"
                dc.b	"F* 5"
                dc.b	"G  5"
                dc.b	"G* 5"
                dc.b	"A  5"
                dc.b	"A* 5"
                dc.b	"B  5"
                dc.b	"C  6"
                dc.b	"C* 6"
                dc.b	"D  6"
                dc.b	"D* 6"
                dc.b	"E  6"
                dc.b	"F  6"
                dc.b	"F* 6"
                dc.b	"G  6"
                dc.b	"G* 6"
                dc.b	"A  6"
                dc.b	"A* 6"
                dc.b	"B  6"
                dc.b	"C  7"
                dc.b	"C* 7"
                dc.b	"D  7"
                dc.b	"D* 7"
                dc.b	"E  7"
                dc.b	"F  7"
                dc.b	"F* 7"
                dc.b	"G  7"
                dc.b	"G* 7"
                dc.b	"A  7"
                dc.b	"A* 7"
                dc.b	"B  7"
                dc.b	"C  8"
                dc.b	"C* 8"
                dc.b	"D  8"
                dc.b	"D* 8"
                dc.b	"E  8"
                dc.b	"F  8"
                dc.b	"F* 8"
                dc.b	"G  8"
                dc.b	"G* 8"
                dc.b	"A  8"
                dc.b	"A* 8"
                dc.b	"ERR "
                even
                
SoundTest_Pan:
                dc.b	" <> "
                dc.b	"  > "
                dc.b	" <  "
                dc.b	" <> "
                even
;========================================================================================================================
; Descriptions
;========================================================================================================================
Description_Text_Positions:   ; I think these numbers are how many 8x8 tiles before drawing each option
                dc.w    $078C          ; line1                        $0002               $0004
                dc.w    $07DC          ; line2                        $0003               $0003
                dc.w    $082C          ; line3                        $0004               $0002
                dc.w    $0870          ; line5                        $0005               $0001
                dc.w    $0898          ; line6                        $0006               $0000
                even
; ===========================================================================
Tab_Descriptions:
                dc.w    UseItem_Description-Tab_Descriptions
                dc.w    Map_Description-Tab_Descriptions
                dc.w    Equip_Description-Tab_Descriptions
                dc.w    Debug_Description-Tab_Descriptions
                dc.w    SoundTest_Description-Tab_Descriptions
                dc.w    Status_Description-Tab_Descriptions

Status_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "                              "       ; Description
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, "  A/B: ENTER MENU   "
                dc.b    $13, "START: BACK TO GAME "
                even
Map_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "                              "       ; Description
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, "  A/B: SCROLL MAP   "
                dc.b    $13, "START: BACK TO GAME "
                even
UseItem_Description:
                dc.l    Icon_UseItem                                ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "USE CONSUMABLE INVENTORY      "       ; Description
                dc.b    $1D, "ITEMS.                        "
                dc.b    $1D, "                              "
                dc.b    $13, "  A/B: ENTER MENU   "
                dc.b    $13, "START: BACK TO GAME "
                even
Equip_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "ASSIGN ABILITIES AND EQUIP    "       ; Description
                dc.b    $1D, "ITEMS.                        "
                dc.b    $1D, "                              "
                dc.b    $13, "  A/B: ENTER MENU   "
                dc.b    $13, "START: BACK TO GAME "
                even
Debug_Description:
                dc.l    Icon_Debug                                  ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "HEY, YOU@D BETTER NOT BE      "       ; Description
                dc.b    $1D, "CHEATING :P                   "
                dc.b    $1D, "                              "
                dc.b    $13, "  A/B: ENTER MENU   "
                dc.b    $13, "START: BACK TO GAME "
                even
SoundTest_Description:
                dc.l    Icon_SoundTest                              ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "PLAY THE SOUNDS AND MUSIC     "       ; Description
                dc.b    $1D, "                              "
        if z80SoundDriver=1
                dc.b    $1D, "       DRIVER VERSION:SMPS Z80"
        else
                dc.b    $1D, "      DRIVER VERSION:SMPS M68K"
        endif
                dc.b    $13, "  A/B: ENTER MENU   "
                dc.b    $13, "START: BACK TO GAME "
                even
                
; ===========================================================================
EquipSlotDescriptions:
                dc.w    AbilityA_Description-EquipSlotDescriptions
                dc.w    AbilityB_Description-EquipSlotDescriptions
                dc.w    AbilityC_Description-EquipSlotDescriptions
                dc.w    Shoes_Description-EquipSlotDescriptions
                dc.w    Item1_Description-EquipSlotDescriptions
                dc.w    Item2_Description-EquipSlotDescriptions
                dc.w    Chaos_Description-EquipSlotDescriptions
; --------------------------------------------------------------------------
AbilityA_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "ASSIGN AN ABILITY TO THE @A@  "       ; Description
                dc.b    $1D, "BUTTON.                       "
                dc.b    $1D, "                              "
                dc.b    $13, " A/B: SELECT ABILITY"
                dc.b    $13, "     C: BACK        "
                even
AbilityB_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "ASSIGN AN ABILITY TO THE @B@  "       ; Description
                dc.b    $1D, "BUTTON.                       "
                dc.b    $1D, "                              "
                dc.b    $13, "A/B: SELECT ABILITY "
                dc.b    $13, "     C: BACK        "
                even
AbilityC_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "ASSIGN AN ABILITY TO THE @C@  "       ; Description
                dc.b    $1D, "BUTTON.                       "
                dc.b    $1D, "                              "
                dc.b    $13, " A/B: SELECT ABILITY"
                dc.b    $13, "     C: BACK        "
                even
Shoes_Description:
                dc.l    Icon_SpeedShoes                             ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "EQUIP A PAIR OF SHOES.        "       ; Description
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, "  A/B: SELECT SHOES "
                dc.b    $13, "     C: BACK        "
                even
Item1_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "EQUIP AN ITEM.                "       ; Description
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, "  A/B: SELECT ITEM  "
                dc.b    $13, "     C: BACK        "
                even
Item2_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "EQUIP AN ITEM.                "       ; Description
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, "  A/B: SELECT ITEM  "
                dc.b    $13, "     C: BACK        "
                even
Chaos_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "EQUIP A CHAOS EMERALD.        "       ; Description
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, " A/B: SELECT EMERALD"
                dc.b    $13, "     C: BACK        "
                even
; ===========================================================================
DebugSlotDescriptions:
                dc.w    DebugSave1_Description-DebugSlotDescriptions
                dc.w    DebugSave2_Description-DebugSlotDescriptions
                dc.w    DebugSave3_Description-DebugSlotDescriptions
                dc.w    DebugItemPlace_Description-DebugSlotDescriptions
                dc.w    DebugSuperSonic_Description-DebugSlotDescriptions
                dc.w    DebugAddToTimer_Description-DebugSlotDescriptions
                dc.w    DebugChaosEmeralds_Description-DebugSlotDescriptions
                dc.w    DebugLevelSelect_Description-DebugSlotDescriptions
                dc.w    DebugAllAbilities_Description-DebugSlotDescriptions
                dc.w    DebugAllItems_Description-DebugSlotDescriptions
                dc.w    DebugVRAM_Description-DebugSlotDescriptions
; --------------------------------------------------------------------------
DebugSave1_Description:
                dc.l    Icon_Save                                   ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "SAVE GAME IN SLOT 1.          "       ; Description
                dc.b    $1D, "                              "       
                dc.b    $1D, "                              "
                dc.b    $13, "   A/B: SAVE GAME   "
                dc.b    $13, "     C: BACK        "
                even
DebugSave2_Description:
                dc.l    Icon_Save                                   ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "SAVE GAME IN SLOT 2.          "       ; Description
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, "   A/B: SAVE GAME   "
                dc.b    $13, "     C: BACK        "
                even
DebugSave3_Description:
                dc.l    Icon_Save                                   ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "SAVE GAME IN SLOT 3.          "       ; Description
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, "   A/B: SAVE GAME   "
                dc.b    $13, "     C: BACK        "
                even
DebugItemPlace_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "TOGGLE DEBUG ITEM PLACEMENT   "       ; Description
                dc.b    $1D, "MODE.                         "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: TOGGLE     "
                dc.b    $13, "     C: BACK        "
                even
DebugSuperSonic_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "TOGGLE SUPER SONIC ON AND OFF "       ; Description
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: TOGGLE     "
                dc.b    $13, "     C: BACK        "
                even
DebugAddToTimer_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "ADDS A MINUTE TO THE INGAME   "       ; Description
                dc.b    $1D, "TIMER, GO HOG WILD\           "
                dc.b    $1D, "                              "
                dc.b    $13, "  A/B: DO IT PLEASE "
                dc.b    $13, "     C: BACK        "
                even
DebugChaosEmeralds_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "ADD 1 TO THE CHAOS EMERALD    "       ; Description
                dc.b    $1D, "COUNT. DOESN@T ADD IT TO THE  "
                dc.b    $1D, "INVENTORY THOUGH\             "
                dc.b    $13, "  A/B: ADD EMERALD  "
                dc.b    $13, "     C: BACK        "
                even
DebugLevelSelect_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "JUMP TO A DIFFERENT LEVEL.    "       ; Description
                dc.b    $1D, "PRESS ENTER TWICE WHEN        "
                dc.b    $1D, "CHOOSING BECAUSE IT@S BUGGY :P"
                dc.b    $13, "    A/B: CHEAT      "
                dc.b    $13, "     C: BACK        "
                even
DebugAllAbilities_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "CHEAT AND GIVE YOURSELF ALL   "       ; Description
                dc.b    $1D, "THE ABILITIES IN THE GAME.    "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: CHEAT      "
                dc.b    $13, "     C: BACK        "
                even
DebugAllItems_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "CHEAT AND GIVE YOURSELF ONE   "       ; Description
                dc.b    $1D, "OF EVERY ITEM IN THE GAME.    "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: CHEAT      "
                dc.b    $13, "     C: BACK        "
                even
DebugVRAM_Description:
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "VIEW TILES                    "       ; Description
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: VIEW       "
                dc.b    $13, "     C: BACK        "
                even

; =========================================================================
SoundTestSlotDescriptions:
                dc.w    PlaySound_Description-SoundTestSlotDescriptions
                dc.w    TempoDiv_Description-SoundTestSlotDescriptions
                dc.w    TempoMod_Description-SoundTestSlotDescriptions
                dc.w    Pitch_Description-SoundTestSlotDescriptions
                dc.w    DrumKit_Description-SoundTestSlotDescriptions
; --------------------------------------------------------------------------
PlaySound_Description:
                dc.l    Icon_SoundTest                              ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "SOUND TEST\                   "       ; Description
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, "      A: +10        "
                dc.b    $13, "  B/C: PLAY SONG    "
                even
TempoDiv_Description:
                dc.l    Icon_SoundTest                              ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "CURRENT SONG@S TEMPO DIVIDER. "       ; Description
                dc.b    $1D, "BREAKS THE SONG@S TIMING IF   "
                dc.b    $1D, "YOU CHANGE IT MID=SONG\       "
                dc.b    $13, "                    "
                dc.b    $13, "                    "
                even
TempoMod_Description:
                dc.l    Icon_SoundTest                              ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "CURRENT SONG@S TEMPO MODIFIER."       ; Description
                dc.b    $1D, "CHANGE THE SPEED OF THE       "
                dc.b    $1D, "CURRENTLY PLAYING SONG\       "
                dc.b    $13, "      A: +10        "
                dc.b    $13, "      B: -10        "
                even
Pitch_Description:
                dc.l    Icon_SoundTest                              ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "CHANGE THE PITCH OF ALL MUSIC "       ; Description
                dc.b    $1D, "AND SOUNDS.                   "
                dc.b    $1D, "\68K DRIVER ONLY\             "
                dc.b    $13, "                    "
                dc.b    $13, "                    "
                even
DrumKit_Description:
                dc.l    Icon_SoundTest                              ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "CHANGE THE DRUM KIT.          "       ; Description
                dc.b    $1D, "                              "
                dc.b    $1D, "\68K DRIVER ONLY\             "
                dc.b    $13, "                    "
                dc.b    $13, "                    "
                even

; ---------------------------------------------------------------------------
; Error Text
; ---------------------------------------------------------------------------
ErrorText:	dc.w @exception-ErrorText, @bus-ErrorText
		dc.w @address-ErrorText, @illinstruct-ErrorText
		dc.w @zerodivide-ErrorText, @chkinstruct-ErrorText
		dc.w @trapv-ErrorText, @privilege-ErrorText
		dc.w @trace-ErrorText, @line1010-ErrorText
		dc.w @line1111-ErrorText
@exception:	dc.b "ERROR EXCEPTION    "
@bus:		dc.b "BUS ERROR          "
@address:	dc.b "ADDRESS ERROR      "
@illinstruct:	dc.b "ILLEGAL INSTRUCTION"
@zerodivide:	dc.b "@ERO DIVIDE        "
@chkinstruct:	dc.b "CHK INSTRUCTION    "
@trapv:		dc.b "TRAPV INSTRUCTION  "
@privilege:	dc.b "PRIVILEGE VIOLATION"
@trace:		dc.b "TRACE              "
@line1010:	dc.b "LINE 1010 EMULATOR "
@line1111:	dc.b "LINE 1111 EMULATOR "
		even


PClabel:        dc.b $3, "PC: "
                even

RegisterLabels:
               	dc.b "D0:D1:D2:D3:D4:D5:D6:D7:A0:A1:A2:A3:A4:A5:A6:"


