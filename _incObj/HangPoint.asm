; ===========================================================================
; ----------------------------------------------------------------------------
; Object 98 - Object Sonic can hang from
; ----------------------------------------------------------------------------
HangPoint:
	moveq	#0,d0
	move.b	obRoutine(a0),d0
	move.w	Hang_Index(pc,d0.w),d1
	jmp		Hang_Index(pc,d1.w)
; ===========================================================================
Hang_Index:	
		dc.w Hang_Init-Hang_Index	; 0
		dc.w Hang_Main-Hang_Index	; 2
; ===========================================================================
Hang_Init:
	addq.b	#2,obRoutine(a0)
	move.l	#Map_Edge,obMap(a0)
	move.w	#$C000,obGfx(a0)
	ori.b	#4,obRender(a0)
	move.b	#8,obActWid(a0)
	move.w	#$200,obPriority(a0)
; ----------------------------------------------------------------------------
Hang_Main:
	lea		objoff_30(a0),a2
	lea		(v_player).w,a1
	tst.b	(a2)					; is sonic hanging on already?
	beq.s	@chk_timer				; if not, branch

	move.w	(v_Ctrl1Held).w,d0
	andi.b	#btnABC,d0				; is a, b, or c pressed?
	beq.w	@rts					; if not, branch

	clr.b	(f_lockmulti).w			; allow sonic control again
	clr.b	(a2)					; clear hanging flag
	move.b	#$12,2(a2)				; set timer 
	andi.w	#btnDir<<8,d0			; is a direction held?
	beq.s	@jumpoff				; if not, branch
	move.b	#$3C,2(a2)				; set timer higher
@jumpoff:
;	addq.w	#8,obY(a1)
	move.w	#-$300,obVelY(a1)
	bset	#1,obStatus(a1)
	bclr	#3,obStatus(a1)
;	move.b	#id_Spring,obAnim(a1) ; use "bouncing" animation
	move.b	#2,obRoutine(a1)
;	sfx		sfx_ThrownOff
	bra.s	@rts
; ----------------------------------------------------------------------------
@chk_timer:
	tst.b	2(a2)					; is timer 0?
	beq.s	@chk_inrange			; if yes, branch
	subq.b	#1,2(a2)				; sub 1 from timer
	bne.w	@rts					; if still not 0, branch
@chk_inrange:
	move.w	obX(a1),d0
	sub.w	obX(a0),d0
	addi.w	#$C,d0
	cmpi.w	#$18,d0
	bhs.w	@rts
	move.w	obY(a1),d1
	sub.w	obY(a0),d1
	subi.w	#$28,d1
	cmpi.w	#$10,d1
	bhs.w	@rts
	tst.b	(f_lockmulti).w
	bmi.s	@rts
	cmpi.b	#4,obRoutine(a1)
	bhs.s	@rts
;	tst.w	(Debug_placement_mode).w
;	bne.s	@rts
@holdon:
	clr.w	obVelX(a1)
	clr.w	obVelY(a1)
	clr.w	obInertia(a1)
	move.w	obX(a0),obX(a1)
	move.w	obY(a0),obY(a1)
	addi.w	#$30,obY(a1)
	move.b	#id_Hang3,obAnim(a1)
	move.b	#1,(f_lockmulti).w
	move.b	#1,(a2)
	sfx		sfx_GrabOn

@rts:
	bra.w	RememberState