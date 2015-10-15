AlwaysOnAbilitiesList:                        ; keep this list in the order that items will be displayed
                dc.l  Inv_Null
                dc.l  Ability_Spindash
                dc.l  Ability_Peelout
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
; Spindash
; ---------------------------------------------------------------------------
Ability_Spindash:
                dc.l    v_abil_spindash                             ; quantity memory location
                dc.b    $0F, "SPINDASH       "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_Spindash                               ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "DUCK AND TAP JUMP TO REV UP.  "
                dc.b    $1D, "RELEASE TO TAKE OFF.          "
                dc.b    $1D, "USEFUL FOR BREAKING WALLS.    "
                dc.b    $13, "                    "
                dc.b    $13, "                    "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Peelout
; ---------------------------------------------------------------------------
Ability_Peelout:
                dc.l    v_abil_peelout                              ; quantity memory location
                dc.b    $0F, "SUPER PEELOUT  "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "LOOK UP AND TAP JUMP TO REV   "
                dc.b    $1D, "UP. RELEASE TO TAKE OFF.      "
                dc.b    $1D, "ZOOM OFF AT HIGH SPEED!       "
                dc.b    $13, "                    "
                dc.b    $13, "                    "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
        @end:   rts
                even
; ===========================================================================
