; ---------------------------------------------------------------------------
; Subroutine to	return Sonic's angle to 0 as he jumps
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpAngle:			; XREF: Obj01_MdJump; Obj01_MdJump2
		move.b	obAngle(a0),d0	; get Sonic's angle
		beq.s	Sonic_JumpFlip	; if already 0,	branch
		bpl.s	loc_13598	; if higher than 0, branch

		addq.b	#2,d0		; increase angle
		bcc.s	loc_13596
		moveq	#0,d0

loc_13596:
		bra.s	Sonic_JumpAngleSet
; ===========================================================================

loc_13598:
		subq.b	#2,d0		; decrease angle
		bcc.s	Sonic_JumpAngleSet
		moveq	#0,d0

Sonic_JumpAngleSet:
		move.b	d0,obAngle(a0)

; End of function Sonic_JumpAngle
	; continue straight to Sonic_JumpFlip

; ---------------------------------------------------------------------------
; Updates Sonic's secondary angle if he's tumbling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AE64:
Sonic_JumpFlip:
	move.b	flip_angle(a0),d0
	beq.s	return_1AEA8
	tst.w	obInertia(a0)
	bmi.s	Sonic_JumpLeftFlip
; loc_1AE70:
Sonic_JumpRightFlip:
	move.b	flip_speed(a0),d1
	add.b	d1,d0
	bcc.s	BranchTo_Sonic_JumpFlipSet
	subq.b	#1,flips_remaining(a0)
	bcc.s	BranchTo_Sonic_JumpFlipSet
	move.b	#0,flips_remaining(a0)
	moveq	#0,d0

BranchTo_Sonic_JumpFlipSet 
	bra.s	Sonic_JumpFlipSet
; ===========================================================================
; loc_1AE88:
Sonic_JumpLeftFlip:
	tst.b	flip_turned(a0)
	bne.s	Sonic_JumpRightFlip
	move.b	flip_speed(a0),d1
	sub.b	d1,d0
	bcc.s	Sonic_JumpFlipSet
	subq.b	#1,flips_remaining(a0)
	bcc.s	Sonic_JumpFlipSet
	move.b	#0,flips_remaining(a0)
	moveq	#0,d0
; loc_1AEA4:
Sonic_JumpFlipSet:
	move.b	d0,flip_angle(a0)

return_1AEA8:
	rts
; End of function Sonic_JumpFlip