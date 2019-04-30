; ---------------------------------------------------------------------------
; Object 2E - contents of monitors
; ---------------------------------------------------------------------------

PowerUp:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Pow_Index(pc,d0.w),d1
		jsr		Pow_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
Pow_Index:	dc.w Pow_Main-Pow_Index
			dc.w Pow_Move-Pow_Index
			dc.w Pow_Delete-Pow_Index
; ===========================================================================

Pow_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#$8680,obGfx(a0)
		move.b	#$24,obRender(a0)
		move.w	#$180,obPriority(a0)
		move.b	#8,obActWid(a0)
		move.w	#-$300,obVelY(a0)
		moveq	#0,d0
		move.b	obAnim(a0),d0	; get subtype
		addq.b	#2,d0
		move.b	d0,obFrame(a0)	; use correct frame
		movea.l	#Map_Monitor,a1
		add.b	d0,d0
		adda.w	(a1,d0.w),a1
		addq.w	#1,a1
		move.l	a1,obMap(a0)

Pow_Move:	; Routine 2
		tst.w	obVelY(a0)	; is object moving?
		bpl.w	Pow_Checks	; if not, branch
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)	; reduce object	speed
		rts	
; ===========================================================================
Pow_Checks:
		addq.b	#2,obRoutine(a0)
		move.w	#29,obTimeFrame(a0) 		; display icon for half a second
        moveq   #0,d0
		move.b	obAnim(a0),d0				; use animation to get powerup type
		add.w	d0,d0
		move.w	Pow_Types(pc,d0.w),d1
		jmp		Pow_Types(pc,d1.w)
; ---------------------------------------------------------------------------
Pow_Types:
		dc.w	Pow_Rts-Pow_Types			; 0 - null
		dc.w	Pow_Collectable-Pow_Types	; 1 - Elec Shield
		dc.w	ExtraLife-Pow_Types			; 2 - Sonic
		dc.w	Pow_Collectable-Pow_Types	; 3 - Speed Shoes
		dc.w	Pow_Collectable-Pow_Types	; 4 - Standard Shield
		dc.w	Pow_Collectable-Pow_Types	; 5 - Invincibility
		dc.w	Pow_Rings-Pow_Types			; 6 - Rings
		dc.w	Pow_Collectable-Pow_Types	; 7 - Fire Shield
		dc.w	Pow_Goggles-Pow_Types		; 8 - Goggle Monitor
; ===========================================================================
ExtraLife:
		addq.b	#1,(v_lives).w			; add 1 to the number of lives you have
		addq.b	#1,(f_lifecount).w 		; update the lives counter
		music	bgm_ExtraLife,1			; play extra life music
; ===========================================================================
Pow_Rings:
		addi.w	#10,(v_rings).w			; add 10 rings to the number of rings you have
		ori.b	#1,(f_ringcount).w 		; update the ring counter
		cmpi.w	#100,(v_rings).w 		; check if you have 100 rings
		bcs.s	Pow_RingSound
		bset	#1,(v_lifecount).w
		beq.w	ExtraLife
		cmpi.w	#200,(v_rings).w 		; check if you have 200 rings
		bcs.s	Pow_RingSound
		bset	#2,(v_lifecount).w
		beq.w	ExtraLife
	Pow_RingSound:
		music	sfx_Ring,1				; play ring sound
; ===========================================================================
; GOGGLES MONITOR
; Multipurpose monitor, changes depending on the level
; note, use cmpi.w #$0000,(v_zone).w; for green hill act 1, #$0102 for LZ act 3 etc, etc
; the monitor icon is overwritten with an extra entry in the Zone's PLC
; ===========================================================================
Pow_Goggles: ;The Goggles monitor changes depending on the zone.
		cmpi.b	#id_GHZ,(v_zone).w ; check if level is GHZ
		bne.s	@notgreenhill	; if not, branch
		move.b  #1,(v_abil_spindash).w
		bra.s   @showcard
@notgreenhill
		cmpi.b	#id_MZ,(v_zone).w ; check if level is MZ
		bne.s	@notmarble	; if not, branch
		move.b  #1,(v_abil_doublejump1).w
		bra.s   @showcard
@notmarble
		cmpi.b	#id_SYZ,(v_zone).w ; check if level is SYZ
		bne.s	@notspringyard	; if not, branch
		bra.s   @showcard
@notspringyard
		cmpi.b	#id_LZ,(v_zone).w ; check if level is LZ
		bne.s	@notlabyrinth	; if not, branch
		bra.s   @showcard
@notlabyrinth
		cmpi.b	#id_SLZ,(v_zone).w ; check if level is SLZ
		bne.s	@notstarlight	; if not, branch
		bra.s   @showcard
@notstarlight
		cmpi.b	#id_SBZ,(v_zone).w ; check if level is SBZ
;		bne.s	@notscrapbrain	; if not, branch
;		bra.s   @showcard
@showcard:
; 		move.b	#1,(f_lockctrl).w	; lock controls
;		move.w	#btnNone<<8,(v_jpadhold2).w ; make Sonic stop
		music   bgm_extralife
		move.b	#id_GotPowUpCard,(v_objspace+$5C0).w   ; load PowerUp Card
		move.b	#$04,obRender(a0)		; put powerup behind card

		rts
; ===========================================================================
Collectable_Index:
               dc.l     Inv_Null              ; 0
               dc.l     Inv_ElecShield        ; 1           ; replaces eggman monitor
               dc.l     Inv_Null              ; 2
               dc.l     Inv_SpeedShoes        ; 3
               dc.l     Inv_Shield            ; 4
               dc.l     Inv_Invincibility     ; 5
               dc.l     Inv_Null              ; 6
               dc.l     Inv_FireShield        ; 7           ; replaces 'S' monitor
               dc.l     Inv_Null              ; 8
               dc.l     Inv_Null              ; 0
               dc.l     Inv_Null              ; 0
               dc.l     Inv_Null              ; 0
               dc.l     Inv_Null              ; 0
               dc.l     Inv_Null              ; 0
               dc.l     Inv_Null              ; 0
               dc.l     Inv_Null              ; 0
; --------------------------------------------------------------------------
Pow_Collectable:
        add.w   d0,d0					
        movea.l Collectable_Index(pc,d0.w),a1
        cmpi.b  #iItemSaver,(v_equippeditem1).w
        beq.s   @putintoinventory
        cmpi.b  #iItemSaver,(v_equippeditem2).w
        beq.s   @putintoinventory
		jmp     InvCodeOffset(a1)      ; activate monitor powerup
@putintoinventory:
        movea.l	(a1),a1                ; item quantity RAM address is the first thing in inventory item data
		cmpi.b  #9,(a1)                ; have we already got 9 of item?
		bge.s   Pow_Rts
        add.b   #1,(a1)                ; add 1 to item count in inventory
        movea.l Collectable_Popups(pc,d0.w),a2
        jmp		CreateHudPopup
; --------------------------------------------------------------------------
Collectable_Popups:
		dc.l	0
		dc.l	HUD_Text_ElecShield
		dc.l	0
		dc.l	HUD_Text_SpeedSh
		dc.l	HUD_Text_Shield
		dc.l	HUD_Text_Invinc
		dc.l	0
		dc.l	HUD_Text_FireShield

HUD_Text_ElecShield:
		dc.b   0,";ELEC SHIELD"		; 0+even alignment, 1-odd alignment
		even	
HUD_Text_SpeedSh:
		dc.b   0,";SPEED SHOES"		; 0+even alignment, 1-odd alignment
		even	
HUD_Text_Shield:
		dc.b   1," ; SHIELD   "		; 0+even alignment, 1-odd alignment
		even	
HUD_Text_Invinc:
		dc.b   1,";INVINCIBLE "		; 0+even alignment, 1-odd alignment
		even	
HUD_Text_FireShield:
		dc.b   0,";FIRE SHIELD"		; 0+even alignment, 1-odd alignment
		even	

; ==========================================================================
Pow_Delete:	; Routine 4
		subq.w	#1,obTimeFrame(a0)
		bmi.w	DeleteObject	; delete after half a second
Pow_Rts:
		rts	
