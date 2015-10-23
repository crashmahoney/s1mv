; ===========================================================================
; ----------------------------------------------------------------------------
; Object 99 - Object Sonic can hang from and spring upwards
; ----------------------------------------------------------------------------
Springpole:
	moveq	#0,d0
	move.b	obRoutine(a0),d0
	move.w	SprPoleIndex(pc,d0.w),d1
	jsr		SprPoleIndex(pc,d1.w)
	bra.w	RememberState
; ===========================================================================
SprPoleIndex:	
		dc.w SprPoleInit-SprPoleIndex	; 0
		dc.w SprPoleMain-SprPoleIndex	; 2
		dc.w SprPoleAni-SprPoleIndex	; 4
		dc.w SprPoleReset-SprPoleIndex	; 6

; ===========================================================================
SprPoleInit:
	addq.b	#2,obRoutine(a0)
	move.l	#Map_Springpole,obMap(a0)
	move.w	#(VRAMloc_SpringPole/$20)+$2000,obGfx(a0)
	ori.b	#4,obRender(a0)
	move.b	#8,obActWid(a0)
	move.w	#$200,obPriority(a0)
; ----------------------------------------------------------------------------
SprPoleMain:
	lea		(v_player).w,a1
	move.w	obX(a1),d0
	sub.w	obX(a0),d0
	addi.w	#$C,d0
	cmpi.w	#$24,d0
	bhs.w	@rts
	move.w	obY(a1),d1
	sub.w	obY(a0),d1
	subi.w	#$4,d1
	cmpi.w	#$C,d1
	bhs.w	@rts
	tst.b	(f_lockmulti).w
	bmi.s	@rts
	cmpi.b	#4,obRoutine(a1)
	bhs.s	@rts
;	tst.w	(Debug_placement_mode).w
;	bne.s	@rts
@holdon:
	addq.b	#2,obRoutine(a0)
	clr.w	obVelX(a1)
	clr.w	obVelY(a1)
	clr.w	obInertia(a1)
	move.w	obX(a0),obX(a1)
	move.w	obY(a0),obY(a1)
	bclr	#1,obStatus(a1)			; clear in air flag
	bset	#3,obStatus(a1)			; set standing flag
	clr.b	obJumping(a1)
	move.b	#id_Hang3,obAnim(a1)	; change sonic's animation
	move.b	#1,(f_lockmulti).w		; lock sonic's controls
	sfx		sfx_GrabOn
@rts:
	rts
; ===========================================================================
SprPoleAni:
	lea		(v_player).w,a1
	cmpi.b	#7,objoff_30(a0)		; is springing timer elapsed?
	bgt.s	@rts					; if greater than, branch
	beq.s	@launch					; if equal, branch
	add.w	#1,obY(a1)				; shift sonic down a pixel
	bra.s	@rts

@launch:
	move.w	#-$A00,obVelY(a1)		; move sonic upwards
	bset	#1,obStatus(a1)			; set in air flag
	bclr	#3,obStatus(a1)			; clear standing flag
	move.b	#id_Spring,obAnim(a1) 	; use "bouncing" animation
	move.b	#2,obRoutine(a1)
	clr.b	(f_lockmulti).w			; allow sonic control again
	sfx		sfx_ThrownOff

@rts:
	addq.b	#1,objoff_30(a0)		; add to timer
	lea		(Ani_SpringPole).l,a1
	jsr		AnimateSprite
	rts

; ===========================================================================
SprPoleReset:
	move.b	#1,obNextAni(a0) 		; reset animation
	clr.b	objoff_30(a0)			; reset timer
	move.b	#2,obRoutine(a0)		; reset routine
	rts

; ===========================================================================
; Mappings
		include	"_maps\Spring Pole.asm"
; ===========================================================================
; Animations
Ani_SpringPole:
	dc.w	@spring-Ani_SpringPole
; ----------------------------------------------------------------------------
@spring:	dc.b	$2, 1, 2, 2, 1, 3, 1, 3, 0, 1, 0, 3, 0, 1, 0, 3, 0, 1, 0, afRoutine
; ===========================================================================
