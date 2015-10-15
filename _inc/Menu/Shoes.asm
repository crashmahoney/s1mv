EquipShoesList:                        ; keep this list in the order that items will be displayed
                dc.l  Inv_Null
ptr_default:    dc.l  Shoe_Sonic
ptr_runners:    dc.l  Shoe_Runners
ptr_springsh:   dc.l  Shoe_Spring
ptr_spikeproof: dc.l  Shoe_Spikeproof
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
; Default Shoes
; ---------------------------------------------------------------------------
Shoe_Sonic:
                dc.l    v_shoe_default                              ; quantity memory location
                dc.b    $0E, "= = =          "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_SpeedShoes                             ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "SONIC@S REGULAR SHOES.        "
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: EQUIP      "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
                move.b  #sDefault,(v_equippedshoes).w               ; set shoe
                jsr     SetStatEffects
                bsr.w   RedrawFullMenu
                sfx     sfx_Lamppost
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Runners
; ---------------------------------------------------------------------------
Shoe_Runners:
                dc.l    v_shoe_runners                              ; quantity memory location
                dc.b    $0E, "BASIC RUNNERS  "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "BASIC RUNNING SHOE.           "
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: EQUIP      "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    eMaxSpeed,10                                ; effect 1, amount
                dc.b    eAcceleration,7                             ; effect 2, amount
                dc.b    eJumpHeight,11                              ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
                move.b  #sRunners,(v_equippedshoes).w               ; set shoe
                jsr     SetStatEffects
                bsr.w   RedrawFullMenu
                sfx     sfx_Lamppost
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Spring Shoes
; ---------------------------------------------------------------------------
Shoe_Spring:
                dc.l    v_shoe_spring                               ; quantity memory location
                dc.b    $0E, "SPRING SOLES   "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "SPRINGY SHOES.                "
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: EQUIP      "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    eJumpHeight,$F                              ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
                move.b  #sSpring,(v_equippedshoes).w                ; set shoe
                jsr     SetStatEffects
                bsr.w   RedrawFullMenu
                sfx     sfx_Lamppost
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Spikeproof Shoes
; ---------------------------------------------------------------------------
Shoe_Spikeproof:
                dc.l    v_shoe_spikeproof                           ; quantity memory location
                dc.b    $0E, "ARMOURED BOOTS "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "HEAVY IRON BOOTS THAT PROTECT "
                dc.b    $1D, "SONIC@S FEET FROM SPIKES.     "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: EQUIP      "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
                move.b  #sSpike,(v_equippedshoes).w                 ; set shoe
                jsr     SetStatEffects
                bsr.w   RedrawFullMenu
                sfx     sfx_Lamppost
        @end:   rts
                even
; ===========================================================================
