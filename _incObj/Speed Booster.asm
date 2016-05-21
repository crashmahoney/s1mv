; ===========================================================================
; ----------------------------------------------------------------------------
; Object 1B - Speed booster from CPZ
; ----------------------------------------------------------------------------
speedbooster_boostspeed =	$30

SpeedBooster:
	moveq	#0,d0
	move.b	obRoutine(a0),d0
	move.w	Obj1B_Index(pc,d0.w),d1
	jmp		Obj1B_Index(pc,d1.w)
; ===========================================================================
Obj1B_Index:	
		dc.w Obj1B_Init-Obj1B_Index	; 0
		dc.w Obj1B_Main-Obj1B_Index	; 2
; ---------------------------------------------------------------------------
Obj1B_BoosterSpeeds:
	dc.w $1000
	dc.w  $A00
; ===========================================================================
Obj1B_Init:
	addq.b	#2,obRoutine(a0) 			; => Obj1B_Main
	move.l	#Map_SpeedBooster,obMap(a0)
	move.w	#$7500/$20,obGfx(a0)
	ori.b	#4,obRender(a0)
	move.b	#$20,obHeight(a0)
	move.w	#$80,obPriority(a0)
	move.b	obSubtype(a0),d0
	andi.w	#2,d0
	move.w	Obj1B_BoosterSpeeds(pc,d0.w),speedbooster_boostspeed(a0)

Obj1B_Main:
	move.b	(v_framecount+1).w,d0
	andi.b	#2,d0
	move.b	d0,obFrame(a0)
	move.w	obX(a0),d0
	move.w	d0,d1
	subi.w	#$10,d0
	addi.w	#$10,d1
	move.w	obY(a0),d2
	move.w	d2,d3
	subi.w	#$10,d2
	addi.w	#$10,d3

	lea		(v_player).w,a1 ; a1=character
	btst	#1,obStatus(a1)					; is sonic in the air?
	bne.s	@rts							; if so, branch
	move.w	obX(a1),d4						
	cmp.w	d0,d4							; is sonic x pos less than booster-$10?
	blo.w	@rts							; if so, branch
	cmp.w	d1,d4							; is sonic x pos greater than booster+$10
	bhs.w	@rts							; if so, branch
	move.w	obY(a1),d4
	cmp.w	d2,d4							; is sonic y pos less than booster-$10?
	blo.w	@rts							; if so, branch
	cmp.w	d3,d4							; is sonic y pos greater than booster+$10
	bhs.w	@rts							; if so, branch
	bsr.w	Obj1B_GiveBoost

@rts:
	bra.w	RememberState

; ===========================================================================
Obj1B_GiveBoost:
	move.w	obVelX(a1),d0
	btst	#0,obStatus(a0)					; is booster flipped?
	beq.s	@noflip
	neg.w	d0 								; d0 = absolute value of character's x velocity
@noflip:
	cmpi.w	#$1000,d0						; is the character already going super fast?
	bge.s	Obj1B_GiveBoost_Done			; if yes, branch to not change the speed
	move.w	speedbooster_boostspeed(a0),obVelX(a1) ; make the character go super fast
	bclr	#0,obStatus(a1)					; turn him right
	btst	#0,obStatus(a0)					; was that the correct direction?
	beq.s	@noflip2						; if yes, branch
	bset	#0,obStatus(a1)					; turn him left
	neg.w	obVelX(a1)						; make the boosting direction left
@noflip2:
	move.w	#$F,obLRLock(a1)				; don't let him turn around for a few frames
	move.w	obVelX(a1),obInertia(a1)		; update his inertia value
	bclr	#5,obStatus(a0)
	bclr	#6,obStatus(a0)
	bclr	#5,obStatus(a1)

Obj1B_GiveBoost_Done:
		bset	#staBoost,obStatus2(a1)			; set boost flag
		jsr	SetStatEffects				; reset stats
		sfx	sfx_SpeedBoost, 1	 			; spring boing sound
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite obMap
; -------------------------------------------------------------------------------
	include "_maps\SpeedBooster.asm"
; ===========================================================================