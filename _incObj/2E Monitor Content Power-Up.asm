; ---------------------------------------------------------------------------
; Object 2E - contents of monitors
; ---------------------------------------------------------------------------

PowerUp:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Pow_Index(pc,d0.w),d1
		jsr	Pow_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
Pow_Index:	dc.w Pow_Main-Pow_Index
		dc.w Pow_Move-Pow_Index
		dc.w Pow_Delete-Pow_Index
; ===========================================================================

Pow_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#$680,obGfx(a0)
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
		move.w	#29,obTimeFrame(a0) ; display icon for half a second
                moveq   #0,d0
		move.b	obAnim(a0),d0

; Pow_ChkEggman:
; 		cmpi.b	#1,d0		; does monitor contain Eggman?
; 		bne.s	Pow_ChkSonic
; 		rts			; Eggman monitor does nothing
; ===========================================================================

Pow_ChkSonic:
		cmpi.b	#2,d0		; does monitor contain Sonic?
		bne.s	Pow_ChkRings

	ExtraLife:
		addq.b	#1,(v_lives).w	; add 1 to the number of lives you have
		addq.b	#1,(f_lifecount).w ; update the lives counter
		music	bgm_ExtraLife,1	; play extra life music

; ===========================================================================

Pow_ChkRings:
		cmpi.b	#6,d0		; does monitor contain 10 rings?
		bne.s	Pow_ChkS

		addi.w	#10,(v_rings).w	; add 10 rings to the number of rings you have
		ori.b	#1,(f_ringcount).w ; update the ring counter
		cmpi.w	#100,(v_rings).w ; check if you have 100 rings
		bcs.s	Pow_RingSound
		bset	#1,(v_lifecount).w
		beq.w	ExtraLife
		cmpi.w	#200,(v_rings).w ; check if you have 200 rings
		bcs.s	Pow_RingSound
		bset	#2,(v_lifecount).w
		beq.w	ExtraLife

	Pow_RingSound:
		music	sfx_Ring,1	; play ring sound
; ===========================================================================
Pow_ChkS:
		cmpi.b	#7,d0		; does monitor contain 'S'?
		bne.s	Pow_ChkGoggles
 
		nop ;Insert code here.
; ===========================================================================
; GOGGLES MONITOR
; Multipurpose monitor, changes depending on the level
; note, use cmpi.w #$0000,(v_zone).w; for green hill act 1, #$0102 for LZ act 3 etc, etc
; the monitor icon is overwritten with an extra entry in the Zone's PLC
; ===========================================================================
Pow_ChkGoggles: ;The Goggles monitor changes depending on the zone.
		cmpi.b	#8,d0		; does monitor contain goggles?
		bne.w	Pow_Collectable    ; +++ was bne.s
 
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
;                bra.s   @showcard
@showcard:
; 		move.b	#1,(f_lockctrl).w	; lock controls
; 	        move.w	#btnNone<<8,(v_jpadhold2).w ; make Sonic stop
        	music   bgm_extralife
		move.b	#id_GotPowUpCard,(v_objspace+$5C0).w   ; load PowerUp Card
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
                add.b   d0,d0
                add.b   d0,d0
                movea.l Collectable_Index(pc,d0.w),a1
                cmpi.b  #iItemSaver,(v_equippeditem1).w
                beq.s   @putintoinventory
                cmpi.b  #iItemSaver,(v_equippeditem2).w
                beq.s   @putintoinventory
		jmp     InvCodeOffset(a1)      ; activate monitor powerup
@putintoinventory:
                movea.l  (a1),a1               ; item quantity RAM address is the first thing in inventory item data
		cmpi.b  #9,(a1)                ; have we already got 9 of item?
		bge.s   Pow_ChkInvalid1
                add.b   #1,(a1)                ; add 1 to item count in inventory
                movea.l Collectable_Popups(pc,d0.w),a2
         ;       movea.l	(a2),a2
;         	move.w	d0,-(sp)
                jsr	CreateHudPopup
;                move.w	(sp)+,d0

                rts

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
 
Pow_ChkInvalid1:
		cmpi.b	#9,d0		; Is this the 1st invalid monitor?
		bne.s	Pow_ChkInvalid2
 
		nop ;Insert code here.
; ==========================================================================
 
Pow_ChkInvalid2:
		cmpi.b	#$A,d0		; Is this the 2nd invalid monitor?
		bne.s	Pow_ChkInvalid3
 
		nop ;Insert code here.
; ==========================================================================
 
Pow_ChkInvalid3:
		cmpi.b	#$B,d0		; Is this the 3rd invalid monitor?
		bne.s	Pow_ChkInvalid4
 
		nop ;Insert code here.
; ==========================================================================
 
Pow_ChkInvalid4:
		cmpi.b	#$C,d0		; Is this the 4th invalid monitor?
		bne.s	Pow_ChkInvalid5
 
		nop ;Insert code here.
; ==========================================================================
 
Pow_ChkInvalid5:
		cmpi.b	#$D,d0		; Is this the 5th invalid monitor?
		bne.s	Pow_ChkInvalid6
 
		nop ;Insert code here.
; ==========================================================================
 
Pow_ChkInvalid6:
		cmpi.b	#$E,d0		; Is this the 6th invalid monitor?
		bne.s	Pow_ChkInvalid7
 
		nop ;Insert code here.
; ==========================================================================
 
Pow_ChkInvalid7:
		cmpi.b	#$F,d0		; Is this the 7th invalid monitor?
		bne.s	Pow_ChkBlank
 
		nop ;Insert code here.
; ==========================================================================
 
Pow_ChkBlank:
		cmpi.b	#0,d0		; Is this the blank monitor?
		bne.s	Pow_ChkEnd
		nop ;Insert code here.
; ==========================================================================
 
Pow_ChkEnd:
		rts
; ===========================================================================
; 
; Pow_ChkS:
; 		cmpi.b	#7,d0		; does monitor contain 'S'?
; 		bne.s	Pow_ChkEnd
; 		nop	
; 
; Pow_ChkEnd:
; 		rts			; 'S' and goggles monitors do nothing
; ===========================================================================
;
Pow_Delete:	; Routine 4
		subq.w	#1,obTimeFrame(a0)
		bmi.w	DeleteObject	; delete after half a second
		rts	
