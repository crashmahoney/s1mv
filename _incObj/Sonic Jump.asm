; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Jump:				; XREF: Obj01_MdNormal; Obj01_MdRoll
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		beq.w	locret_1348E	; if not, branch
		moveq	#aLightDash,d0  ; check for light dash
                jsr     CheckAbility    ; check if equppied
                tst.b   d1              ; is ability equipped?
                bne.w   locret_1348E    ; if so, branch
                moveq	#0,d0
		move.b	obAngle(a0),d0
		addi.b	#$80,d0
		bsr.w	sub_14D48
		cmpi.w	#6,d1
		blt.w	locret_1348E
		move.w	#$680,d2
		btst	#6,obStatus(a0)
		beq.s	loc_1341C
		move.w	#$380,d2

loc_1341C:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)	; make Sonic jump
		muls.w	d2,d0
		asr.l	#8,d0
                moveq   #$0,d6          ; +++ increase jump height according to jump stat
                move.b  (v_statjump).w,d6  ; +++
                mulu    #4,d6           ; +++ multlply the jump stat by 4
		sub.w	d6,d0           ; +++ add to jump height
		add.w	d0,obVelY(a0)	; make Sonic jump
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		addq.l	#4,sp
		move.b	#1,$3C(a0)
		clr.b	$38(a0)
		sfx	sfx_Jump	; play jumping sound
		move.b	#$13,obWidth(a0)
		move.b	#9,obHeight(a0)
		btst	#2,obStatus(a0)
		bne.s	loc_13490
		move.b	#$E,obWidth(a0)
		move.b	#7,obHeight(a0)
		move.b	#id_Roll,obAnim(a0) ; use "jumping" animation
		bset	#2,obStatus(a0)
		addq.w	#5,obY(a0)

locret_1348E:
		rts	
; ===========================================================================

loc_13490:
		bset	#4,obStatus(a0)
		rts	
; End of function Sonic_Jump