InventoryItemsList:                        ; keep this list in the order that items will be displayed
                dc.l  Inv_Null
                dc.l  Inv_Invincibility
                dc.l  Inv_Shield
                dc.l  Inv_ElecShield
                dc.l  Inv_FireShield
                dc.l  Inv_SpeedShoes
                dc.l  Inv_TestSpeedup
                dc.l  Inv_Bomb
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Key
                dc.l  Inv_Null
                dc.l  Inv_Null
                dc.l  Inv_Null

;========================================================================================================================
; ===========================================================================
; ---------------------------------------------------------------------------
; Null Item
; ---------------------------------------------------------------------------

Inv_Null:
                dc.l    v_256x256                                   ; quantity memory location
                dc.b    $0E, "NULL ITEM      "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "NO ITEM IN THIS SLOT.         "       ; Description
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
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
; Invincibility
; ---------------------------------------------------------------------------
Inv_Invincibility:
                dc.l    v_inv_invinc                                ; quantity memory location
                dc.b    $0E, "INVINCIBILITY  "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_Invincibility                          ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "GRANTS SONIC 20 SECONDS OF    "       ; Description
                dc.b    $1D, "INVINCIBILITY.                "
                dc.b    $1D, "                              "
                dc.b    $13, "   A/B: USE ITEM    "
                dc.b    $13, "     C: BACK        "
                dc.b    20                                          ; effect time limit in seconds
                dc.b    eInvincibility,0                              ; effect 1, amount
                dc.b    0,0                                           ; effect 2, amount
                dc.b    0,0                                           ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press

; check if invincibility is already active
                lea     (ItemEffects).w,a3   ; current effects list
                moveq   #0,d0
                adda    #InvEffeOffset,a1    ; get effect time timit
                move.b  (a1)+,d0        ; move to d0, now a1 is first effect
                mulu.w  #60,d0          ; get time limit in frames
                moveq   #19,d1          ; loop through 20 effect slots
        @effectloop:
                cmpi.b  #eInvincibility,(a3)         ; is there an invincibility effect in this slot?
                bne.s   @skip           ; if not, branch
                move.b  (a1)+,(a3)      ; set effect type
                move.b  (a1)+,1(a3)     ; set effect amount
                move.w  d0,2(a3)        ; set time limit
                jsr     SetStatEffects  ; apply effects
                bra.s   @breakfromloop  ; exit loop
        @skip:
                adda    #4,a3           ; go to next slot
                dbf     d1,@effectloop  ; loop

; if no invincibility found, put it in a new slot
                lea     (ItemEffects).w,a3   ; current effects list
                moveq   #19,d1          ; loop through 20 effect slots
        @effectloop2:
                tst.b   (a3)            ; is there an active effect in this slot?
                bne.s   @skip2           ; if so, branch
                move.b  (a1)+,(a3)      ; set effect type
                move.b  (a1)+,1(a3)     ; set effect amount
                move.w  d0,2(a3)        ; set time limit
                tst.b   (a1)            ; is there another effect?
                beq.s   @breakfromloop2  ; if not, exit loop
        @skip2:
                lea     4(a3),a3           ; go to next slot
                dbf     d1,@effectloop2  ; loop
        @breakfromloop2:
                jsr     SetStatEffects  ; apply effects
        @breakfromloop:
; apply invincibility effects
 		move.b	#1,(v_invinc).w	         ; make Sonic invincible
		move.b	#id_InvincibilityStars,(v_objspace+$200).w ; load stars object ($3801)
		tst.b	(f_lockscreen).w          ; is boss mode on?
		bne.w	@end                      ; if yes, branch
		cmpi.w	#$C,(v_air).w
		bls.w	@end
		music	bgm_Invincible          ; play invincibility music
                tst.w   (f_pause).w
                beq.s   @end
                subi.b  #$01,(v_inv_invinc).w    ; subtract 1 from inventory
                bsr.w   RedrawFullMenu
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Key
; ---------------------------------------------------------------------------
Inv_Key:
                dc.l    v_inv_key                                   ; quantity memory location
                dc.b    $0E, "KEY            "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_Key                                    ; Icon
                dc.l    IconPal_Key                                 ; Icon Palette
                dc.b    $1D, "WHY DOES SONIC NEED KEYS? WHO "       ; Description
                dc.b    $1D, "THE HELL KNOWS? CERTAINLY NOT "
                dc.b    $1D, "ME.                           "
                dc.b    $13, "   A/B: NOTHING     "
                dc.b    $13, "     C: BACK        "
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
; Standard Shield
; ---------------------------------------------------------------------------
Inv_Shield:
                dc.l    v_inv_shield                                ; quantity memory location
                dc.b    $0E, "SHIELD         "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_Shield                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "PROTECTS SONIC FROM ONE HIT.  "       ; Description
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, "  A/B: USE SHIELD   "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
		move.b	#1,(v_shield).w	           ; give Sonic a shield
		sfx	sfx_Shield                 ; play shield sound
                tst.w   (f_pause).w
                beq.s   @end
                subi.b  #1,(v_inv_shield).w        ; subtract 1 from inventory
                bsr.w   RedrawFullMenu
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Electric Shield
; ---------------------------------------------------------------------------
Inv_ElecShield:
                dc.l    v_inv_eshield                               ; quantity memory location
                dc.b    $0E, "ELECTRIC SHIELD"                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_Shield                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "PROTECTS SONIC FROM ONE HIT.  "       ; Description
                dc.b    $1D, "ATTRACTS RINGS. PROTECTS      "
                dc.b    $1D, "FROM ELECTRICAL ATTACKS.      "
                dc.b    $13, "  A/B: USE SHIELD   "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
		move.b	#2,(v_shield).w	           ; give Sonic a shield
		sfx	$41                        ; play shield sound
                tst.w   (f_pause).w
                beq.s   @end
                subi.b  #1,(v_inv_eshield).w       ; subtract 1 from inventory
                bsr.w   RedrawFullMenu
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Fire Shield
; ---------------------------------------------------------------------------
Inv_FireShield:
                dc.l    v_inv_fshield                               ; quantity memory location
                dc.b    $0E, "FIRE SHIELD    "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_Shield                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "PROTECTS SONIC FROM ONE HIT.  "       ; Description
                dc.b    $1D, "PROTECTS FROM FIRE ATTACKS.   "
                dc.b    $1D, "                              "
                dc.b    $13, "  A/B: USE SHIELD   "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
		move.b	#3,(v_shield).w	           ; give Sonic a shield
		sfx	$41                        ; play shield sound
                tst.w   (f_pause).w
                beq.s   @end
                subi.b  #1,(v_inv_fshield).w       ; subtract 1 from inventory
                bsr.w   RedrawFullMenu
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Speed Shoes
; ---------------------------------------------------------------------------
Inv_SpeedShoes:
                dc.l    v_inv_shoes                                 ; quantity memory location
                dc.b    $0E, "SPEED SHOES    "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_SpeedShoes                             ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "GRANTS SONIC 20 SECONDS OF    "       ; Description
                dc.b    $1D, "SUPER SPEED.                  "
                dc.b    $1D, "                              "
                dc.b    $13, "   A/B: USE ITEM    "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
		move.b	#1,(v_shoes).w	        ; speed up the BG music
		move.w	#$4B0,(v_player+$34).w	; time limit for the power-up
                jsr     SetStatEffects
         if z80SoundDriver=0
                music	$E2		; Speed	up the music
         else
                move.w	#8,d0
		jsr	(SetTempo).l	; Speed	up the music
         endif
                tst.w   (f_pause).w
                beq.s   @end
                subi.b  #$01,(v_inv_shoes).w    ; subtract 1 from inventory
                bsr.w   RedrawFullMenu
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Test item, increases stats a small amount
; ---------------------------------------------------------------------------
Inv_TestSpeedup:
                dc.l    v_inv_test                                  ; quantity memory location
                dc.b    $0E, "STAT TEST      "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "TESTING, TESTING, 123.        "       ; Description
                dc.b    $1D, "                              "
                dc.b    $1D, "                              "
                dc.b    $13, " A/B: DRINK POTION  "
                dc.b    $13, "     C: BACK        "
                dc.b    20                                            ; effect time limit in seconds
                dc.b    eMaxSpeed,20                                  ; effect 1, amount
                dc.b    eAcceleration,30                              ; effect 2, amount
                dc.b    eJumpHeight,40                                ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
                bsr.w   ApplyItemEffects
                tst.w   (f_pause).w
                beq.s   @end
                subi.b  #$01,(v_inv_test).w    ; subtract 1 from inventory
                bsr.w   RedrawFullMenu
        @end:   rts
                even
; ===========================================================================
; ---------------------------------------------------------------------------
; Bomb
; ---------------------------------------------------------------------------
Inv_Bomb:
                dc.l    v_inv_bomb                                  ; quantity memory location
                dc.b    $0E, "BOMB           "                      ; Item Name
                dc.l    SIcon_Empty                                 ; Hud Icon
                dc.l    Icon_NoIcon                                 ; Icon
                dc.l    IconPal_Default                             ; Icon Palette
                dc.b    $1D, "DESTROYS ALL ENEMIES ON       "       ; Description
                dc.b    $1D, "SCREEN.                       "
                dc.b    $1D, "                              "
                dc.b    $13, " A/B: DETONATE BOMB "
                dc.b    $13, "     C: BACK        "
                dc.b    0                                           ; effect time limit in seconds
                dc.b    0,0                                         ; effect 1, amount
                dc.b    0,0                                         ; effect 2, amount
                dc.b    0,0                                         ; effect 3, amount
                dc.b    0,0                                         ; nothing
        ; code to run on button press
                jsr     DestroyEnemies         ; kill all enemies on screen
                lea     (v_player).w,a0
                bclr    #3,obstatus(a0)
                sfx     sfx_Bomb
                moveq   #4,d2                  ; create 5 explosions
        @createexplosions:                     ; create explosions
                jsr	FindFreeObj
		bne.s	@endexplosions
		move.b	#id_ExplosionBomb,0(a1)	; load explosion object
		move.w	(v_screenposx).w,obX(a1)
; 		addi.w   #160,obX(a1)            ; centre of screen
		move.w	(v_screenposy).w,obY(a1)
; 		addi.w   #112,obY(a1)            ; centre of screen
		jsr	(RandomNumber).l
		move.w	d0,d1
		moveq	#0,d1
		move.b	d0,d1
;		lsr.b	#1,d1
; 		subi.w	#80,d1
		add.w	d1,obX(a1)
		lsr.w	#8,d0
;		lsr.b	#1,d0
; 		subi.w	#56,d1
		add.w	d0,obY(a1)
		dbf     d2,@createexplosions
        @endexplosions:
                tst.w   (f_pause).w
                beq.s   @end
                subi.b  #$01,(v_inv_bomb).w    ; subtract 1 from inventory
                bsr.w   RedrawFullMenu
        @end:   rts
                even

                
                
                
