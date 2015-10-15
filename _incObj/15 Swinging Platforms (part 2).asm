; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Swing_Move:				; XREF: Swing_Action; Swing_Action2
		move.b	(v_oscillate+$1A).w,d0
		move.w	#$80,d1
		btst	#0,obStatus(a0)
		beq.s	loc_7B78
		neg.w	d0
		add.w	d1,d0

loc_7B78:
		bra.s	Swing_Move2
; End of function Swing_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj48_Move:				; XREF: Obj48_Display2
		tst.b	$3D(a0)
		bne.s	loc_7B9C
		move.w	$3E(a0),d0
		addq.w	#8,d0
		move.w	d0,$3E(a0)
		add.w	d0,obAngle(a0)
		cmpi.w	#$200,d0
		bne.s	loc_7BB6
		move.b	#1,$3D(a0)
		bra.s	loc_7BB6
; ===========================================================================

loc_7B9C:
		move.w	$3E(a0),d0
		subq.w	#8,d0
		move.w	d0,$3E(a0)
		add.w	d0,obAngle(a0)
		cmpi.w	#-$200,d0
		bne.s	loc_7BB6
		move.b	#0,$3D(a0)

loc_7BB6:
		move.b	obAngle(a0),d0
; End of function Obj48_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Swing_Move2:				; XREF: Swing_Move; Obj48_Display
		bsr.w	CalcSine
		move.w	$38(a0),d2
		move.w	$3A(a0),d3
		lea	obSubtype(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6

loc_7BCE:
		moveq	#0,d4
		move.b	(a2)+,d4
		lsl.w	#6,d4
		addi.l	#v_objspace&$FFFFFF,d4
		movea.l	d4,a1
		moveq	#0,d4
		move.b	$3C(a1),d4
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,obY(a1)
		move.w	d5,obX(a1)
		dbf	d6,loc_7BCE
		rts	
; End of function Swing_Move2

; ===========================================================================

Swing_ChkDel:				; XREF: Swing_Action; Swing_Action2
		obRange	Swing_DelAll,$3A(a0)
		rts	
; ===========================================================================

Swing_DelAll:				; XREF: Swing_ChkDel
        if S3KObjectManager=1
		obMarkGone
        endif
		moveq	#0,d2
		lea	obSubtype(a0),a2
		move.b	(a2)+,d2        ; number of links in chain

Swing_DelLoop:
		moveq	#0,d0
		move.b	(a2)+,d0        ; copy ram slot of link to d0
		lsl.w	#6,d0           ; multiply by $40
		addi.l	#v_objspace&$FFFFFF,d0  ; make into a ram address
		movea.l	d0,a1           ; child object to delete goes into a1
		bsr.w	DeleteChild
		dbf	d2,Swing_DelLoop ; repeat for length of	chain
		rts
; ===========================================================================

Swing_Delete:	; Routine 6, 8
		bsr.w	DeleteObject
		rts
; ===========================================================================

Swing_Display:	; Routine $A
		bra.w	DisplaySprite
