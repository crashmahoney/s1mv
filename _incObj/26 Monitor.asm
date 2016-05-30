; ---------------------------------------------------------------------------
; Object 26 - monitors
; ---------------------------------------------------------------------------
mon_ActBit		= $30		; which bit in the act flags this monitor is mapped to

Monitor:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Mon_Index(pc,d0.w),d1
		jmp		Mon_Index(pc,d1.w)
; ===========================================================================
Mon_Index:	dc.w Mon_Main-Mon_Index
		dc.w Mon_Solid-Mon_Index
		dc.w Mon_BreakOpen-Mon_Index
		dc.w Mon_Animate-Mon_Index
		dc.w Mon_Display-Mon_Index
; ===========================================================================

Mon_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	#$E,obWidth(a0)
		move.b	#$E,obHeight(a0)
		move.l	#Map_Monitor,obMap(a0)
		move.w	#$680,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$180,obPriority(a0)
		move.b	#$F,obActWid(a0)
		obTestBit 0                   ; check if marked as broken in respawn table
		beq.s	@checksavedstatus     ; if not, branch
@broken:
		move.b	#8,obRoutine(a0)      ; run "Mon_Display" routine
		move.b	#$B,obFrame(a0)	      ; use broken monitor frame
		bra.w     RememberState       ; check if in range, display if so, delete if not
; ---------------------------------------------------------------------------
; Decide if monitor has already been destroyed on previous time in level
; ---------------------------------------------------------------------------
@checksavedstatus:
		obSetBit 1                    ; set bit so this check doesn't get run again
		lea     (v_monitorlocations).w,a3
		moveq   #23,d0                ; number of loops
	@x_pos_loop:
		move.w  (a3)+,d1              ; put x postion out of table into d3
		cmp.w   obX(a0),d1            ; is it equal to monitor's x position?
		beq.s   @checkbit             ; if so, check if bit is set
		dbf     d0,@x_pos_loop

@checkbit:
		move.b	d0,mon_ActBit(a0)	; remember which bit this is saved to
		bsr.w	GetActFlag			; check bit number in d0 is set
		tst.b	d0					; is it set?
		bne.s	@broken				; if yes, branch
; ===========================================================================

	@notbroken:
		move.b	#$46,obColType(a0)
		move.b	obSubtype(a0),obAnim(a0)

Mon_Solid:	; Routine 2
		jsr     FindHomingAttackTarget
		move.b	ob2ndRout(a0),d0 ; is monitor set to fall?
		beq.s	@normal		; if not, branch
		subq.b	#2,d0
		bne.s	@fall

		; 2nd Routine 2
		moveq	#0,d1
		move.b	obActWid(a0),d1
		addi.w	#$B,d1
		bsr.w	ExitPlatform
		btst	#3,obStatus(a1) ; is Sonic on top of the monitor?
		bne.w	@ontop		; if yes, branch
		clr.b	ob2ndRout(a0)
		bra.w	Mon_Animate
; ===========================================================================

	@ontop:
		move.w	#$10,d3
		move.w	obX(a0),d2
		bsr.w	MvSonicOnPtfm
		bra.w	Mon_Animate
; ===========================================================================

@fall:		; 2nd Routine 4
		bsr.w	ObjectFall
		jsr	(ObjFloorDist).l
		tst.w	d1
		bpl.w	Mon_Animate
		add.w	d1,obY(a0)
		clr.w	obVelY(a0)
		clr.b	ob2ndRout(a0)
		bra.w	Mon_Animate
; ===========================================================================

@normal:	; 2nd Routine 0
;                bsr.w   Mon_BreakOpen
		move.w	#$1A,d1
		move.w	#$F,d2
		bsr.w	Mon_SolidSides
		beq.w	loc_A25C
		tst.w	obVelY(a1)
		bmi.s	loc_A20A
		cmpi.b	#id_Roll,obAnim(a1) ; is Sonic rolling?
		beq.s	loc_A25C	; if yes, branch
		cmp.b	#id_SpinDash,obAnim(a1)	; +++ is Sonic spin-dashing?
		beq	loc_A25C	; +++ if yes, branch

loc_A20A:
		tst.w	d1
		bpl.s	loc_A220
		sub.w	d3,obY(a1)
		bsr.w	loc_74AE
		move.b	#2,ob2ndRout(a0)
		bra.w	Mon_Animate
; ===========================================================================

loc_A220:
		tst.w	d0
		beq.w	loc_A246
		bmi.s	loc_A230
		tst.w	obVelX(a1)
		bmi.s	loc_A246
		bra.s	loc_A236
; ===========================================================================

loc_A230:
		tst.w	obVelX(a1)
		bpl.s	loc_A246

loc_A236:
		sub.w	d0,obX(a1)
		move.w	#0,obInertia(a1)
		move.w	#0,obVelX(a1)

loc_A246:
		btst	#1,obStatus(a1)
		bne.s	loc_A26A
		bset	#5,obStatus(a1)
		bset	#5,obStatus(a0)
		bra.s	Mon_Animate
; ===========================================================================

loc_A25C:
		btst	#5,obStatus(a0)
		beq.s	Mon_Animate
		cmp.b	#id_Roll,obAnim(a1); check if in jumping/rolling animation
		beq.s	loc_A26A
		cmp.b	#id_Drown,obAnim(a1); check if in jumping/rolling animation
		beq.s	loc_A26A
		move.w	#1,obAnim(a1)

loc_A26A:
		bclr	#5,obStatus(a0)
		bclr	#5,obStatus(a1)

Mon_Animate:	; Routine 6
		lea	(Ani_Monitor).l,a1
		bsr.w	AnimateSprite

Mon_Display:	; Routine 8
                bra.w     RememberState         ; check if in range, display if so, delete if not
;                rts                            ; not needed, RemeberState returns
; ===========================================================================

Mon_BreakOpen:	; Routine 4
		addq.b	#2,obRoutine(a0)
; ---------------------------------------------------------------------------
; Save the fact that monitor is destroyed
; ---------------------------------------------------------------------------
		moveq	#0,d0
		move.b	mon_ActBit(a0),d0
		bsr.w	SetActFlag
; ---------------------------------------------------------------------------

     @breakopen:
		clr.b   (v_jumpdashcount).w
		move.b	#0,obColType(a0)
		bsr.w	FindFreeObj
		bne.s	Mon_Explode
		move.b	#id_PowerUp,0(a1) ; load monitor contents object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obAnim(a0),obAnim(a1)

Mon_Explode:
		bsr.w	FindFreeObj
		bne.s	@fail
		move.b	#id_GunstarExplosion,0(a1) ; load explosion object
;		addq.b	#2,obRoutine(a1) ; don't create an animal
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

	@fail:
		obSetBit 0                              ; set status in respawn table
                move.b	#id_Breakingmon,obAnim(a0)	; set monitor animation to broken
		bra.w	DisplaySprite