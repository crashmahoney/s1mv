EquipItemsList:                        ; keep this list in the order that items will be displayed
                dc.l  Inv_Null
ptr_noitem:     dc.l  Item_NoItem
ptr_goggles:    dc.l  Item_Goggles
ptr_itemsaver:  dc.l  Item_ItemSaver
ptr_spdbracelet:dc.l  Item_SpeedBracelet
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null

;========================================================================================================================
; ---------------------------------------------------------------------------
; No Ability
; ---------------------------------------------------------------------------
Item_NoItem:
                dc.l    v_abil_none                                 ; quantity memory location;                dc.l    Sonic_NoAbility                                   ; Ability Code Location
                dc.b    $0E, "= = =          "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "HAVE NO ITEM EQUIPPED IN      "
                dc.b    $1D, "THIS SLOT.                    "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: EQUIP      "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
                move.b  #iNoItem,(a2)                               ; set item to this item
                jsr     SetStatEffects
                bsr.w   RedrawFullMenu
                sfx     sfx_Lamppost
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Goggles
; ---------------------------------------------------------------------------
Item_Goggles:
                dc.l    v_item_goggles                              ; quantity memory location
                dc.b    $0E, "SCUBA MASK     "                      ; Item Name
                dc.l    SIcon_Djump1                                ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "BREATHE INDEFINITELY          "
                dc.b    $1D, "UNDERWATER.                   "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: EQUIP      "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
                move.b  #iGoggles,(a2)                              ; set item to this item
                jsr     SetStatEffects
                bsr.w   RedrawFullMenu
                sfx     sfx_Lamppost
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Item Saver - puts monitor items into inventory when broken
; ---------------------------------------------------------------------------
Item_ItemSaver:
                dc.l    v_item_itemsaver                            ; quantity memory location
                dc.b    $0E, "ITEM SAVER     "                      ; Item Name
                dc.l    SIcon_Djump1                                ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "SAVES MONITOR ITEMS INTO      "
                dc.b    $1D, "YOUR INVENTORY FOR LATER USE. "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: EQUIP      "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
                move.b  #iItemSaver,(a2)                            ; set item to this item
                jsr     SetStatEffects
                bsr.w   RedrawFullMenu
                sfx     sfx_Lamppost
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Item Saver - puts monitor items into inventory when broken
; ---------------------------------------------------------------------------
Item_SpeedBracelet:
                dc.l    v_item_speedbracelet                        ; quantity memory location
                dc.b    $0E, "SPEED BRACELET "                      ; Item Name
                dc.l    SIcon_Djump1                                ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "JUST A TEST THING I GUESS.    "
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: EQUIP      "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    eMaxSpeed,$20                               ; effect 1, amount
                dc.b    eAcceleration,$20                           ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
                move.b  #iSpdBracelet,(a2)                          ; set item to this item
                jsr     SetStatEffects
                bsr.w   RedrawFullMenu
                sfx     sfx_Lamppost
        @end:   rts
                even