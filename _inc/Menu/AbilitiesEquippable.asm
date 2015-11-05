EquipAbilitiesList:      ; keep this list in the order that items will be displayed
                dc.l  Inv_Null
ptr_noability:  dc.l  Ability_NoAbility
ptr_djump2:     dc.l  Ability_DoubleJumpLv2
ptr_djump1:     dc.l  Ability_DoubleJumpLv1
ptr_jdash:      dc.l  Ability_JumpDash
ptr_homing:     dc.l  Ability_Homing
ptr_ldash:      dc.l  Ability_LightDash
ptr_insta:      dc.l  Ability_InstaShield
ptr_dattack:    dc.l  Ability_DownAttack

EquipAbilitiesList_End:

;========================================================================================================================
; ---------------------------------------------------------------------------
; No Ability
; ---------------------------------------------------------------------------
Ability_NoAbility:
                dc.l    v_abil_none                                 ; quantity memory location
;                dc.l    Sonic_NoAbility                                   ; Ability Code Location
                dc.b    $0E, "= = =          "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "HAVE NO ABILITY EQUIPPED IN   "
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
                move.b  #aNoAbility,(a2)                            ; set button to this ability
                sfx     sfx_Lamppost
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Double Jump Level 1 (no spin)
; ---------------------------------------------------------------------------
Ability_DoubleJumpLv1:
                dc.l    v_abil_doublejump1                          ; quantity memory location
;                dc.l    Sonic_DoubleJump                            ; Ability Code Location
                dc.b    $0E, "DOUBLE JUMP    "                      ; Item Name
                dc.l    SIcon_Djump1                                ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "PERFORM A SECOND JUMP IN      "
                dc.b    $1D, "MID=AIR.                      "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: EQUIP      "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
                move.b  #aDoubleJump1,(a2)                          ; set button to this ability
                sfx     sfx_Lamppost
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Jump Dash
; ---------------------------------------------------------------------------
Ability_JumpDash:
                dc.l    v_abil_jumpdash                             ; quantity memory location
                dc.b    $0E, "JUMP DASH      "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "DASH FORWARDS IN MID=AIR.     "
                dc.b    $1D, "ACCELERATION STAT AFFECTS     "
                dc.b    $1D, "SPEED OF DASH.                "
                dc.b    $13, "    A/B: EQUIP      "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
                move.b  #aJumpDash,(a2)                             ; set button to this ability
                sfx     sfx_Lamppost
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Homing Attack
; ---------------------------------------------------------------------------
Ability_Homing:
                dc.l    v_abil_homing                               ; quantity memory location
                dc.b    $0E, "HOMING ATTACK  "                      ; Item Name
                dc.l    SIcon_Homing                                ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "HOME IN ON NEARBY OBJECTS WHEN"
                dc.b    $1D, "IN AIR. IF NOTHING IN RANGE,  "
                dc.b    $1D, "PERFORM A JUMP DASH.          "
                dc.b    $13, "    A/B: EQUIP      "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
                move.b  #aHoming,(a2)                               ; set button to this ability
                sfx     sfx_Lamppost
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Double Jump Level 2 (spin version)
; ---------------------------------------------------------------------------
Ability_DoubleJumpLv2:
                dc.l    v_abil_doublejump2                          ; quantity memory location
                dc.b    $0E, "DOUBLE JUMP LV2"                      ; Item Name
                dc.l    SIcon_Djump2                                ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "PERFORM A SECOND SPINNING JUMP"
                dc.b    $1D, "IN MID=AIR.                   "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: EQUIP      "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
                move.b  #aDoubleJump2,(a2)                          ; set button to this ability
                sfx     sfx_Lamppost
        @end:   rts
                even
; ===========================================================================
; ===========================================================================
; ---------------------------------------------------------------------------
; Light Dash
; ---------------------------------------------------------------------------
Ability_LightDash:
                dc.l    v_abil_lightdash                            ; quantity memory location
                dc.b    $0E, "LIGHT DASH     "                      ; Item Name
                dc.l    SIcon_LDash                                 ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "MOVE QUICKLY THROUGH A TRAIL  "
                dc.b    $1D, "OF RINGS.                     "
                dc.b    $1D, "                              "
                dc.b    $13, "    A/B: EQUIP      "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
                move.b  #aLightDash,(a2)                            ; set button to this ability
                sfx     sfx_Lamppost
        @end:   rts
                even
; ===========================================================================
; ===========================================================================
; ---------------------------------------------------------------------------
; Instashield
; ---------------------------------------------------------------------------
Ability_InstaShield:
                dc.l    v_abil_insta                                ; quantity memory location
                dc.b    $0E, "INSTA=SHIELD   "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "DOUBLE SPIN ATTACK.           "
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
                move.b  #aInstaShield,(a2)                           ; set button to this ability
                sfx     sfx_Lamppost
        @end:   rts
                even; ===========================================================================
; ===========================================================================
; ---------------------------------------------------------------------------
; Downwards Attack
; ---------------------------------------------------------------------------
Ability_DownAttack:
                dc.l    v_abil_down                                 ; quantity memory location
                dc.b    $0E, "DOWN ATTACK    "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "ATTACK DOWNWARDS.             "
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
                move.b  #aDownAttack,(a2)                           ; set button to this ability
                sfx     sfx_Lamppost
        @end:   rts
                even