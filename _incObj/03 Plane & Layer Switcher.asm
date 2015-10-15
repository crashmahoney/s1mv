; ===========================================================================
; ---------------------------------------------------------------------------
; Object 03 - Collision plane/layer switcher (From Sonic 2 [Modified])
; ---------------------------------------------------------------------------

PathSwapper:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj03_Index(pc,d0.w),d1
		jsr	Obj03_Index(pc,d1.w)
		obRange	Obj03_MarkChkGone
		rts

Obj03_MarkChkGone:
		jmp	Mark_ChkGone
; ===========================================================================
; ---------------------------------------------------------------------------
Obj03_Index:	dc.w Obj03_Init-Obj03_Index
		dc.w Obj03_MainX-Obj03_Index
		dc.w Obj03_MainY-Obj03_Index
; ---------------------------------------------------------------------------
; ===========================================================================
; ---------------------------------------------------------------------------
; Initiation
; ---------------------------------------------------------------------------

Obj03_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#$00000000,obMap(a0)
		move.w	#$26BC,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.w	#$280,obPriority(a0)
		move.b	obSubtype(a0),d0
		btst	#2,d0
		beq.s	Obj03_Init_CheckX

;Obj03_Init_CheckY:
		addq.b	#2,obRoutine(a0) ; => Obj03_MainY
		andi.w	#7,d0
		move.b	d0,obFrame(a0)
		andi.w	#3,d0
		add.w	d0,d0
		move.w	word_1FD68(pc,d0.w),$32(a0)
		move.w	obY(a0),d1
		lea	(v_player).w,a1 ; a1=character
		cmp.w	obY(a1),d1
		bcc.s	Obj03_Init_Next
		move.b	#1,$34(a0)
Obj03_Init_Next:
	;	lea	(Sidekick).w,a1 ; a1=character
	;	cmp.w	$0C(a1),d1
	;	bcc.s	+
	;	move.b	#1,$35(a0)
;+
		bra.w	Obj03_MainY
; ===========================================================================
word_1FD68:
	dc.w  $020
	dc.w  $040	; 1
	dc.w  $080	; 2
	dc.w  $100	; 3
; ===========================================================================
; loc_1FD70:
Obj03_Init_CheckX:
		andi.w	#3,d0
		move.b	d0,obFrame(a0)
		add.w	d0,d0
		move.w	word_1FD68(pc,d0.w),$32(a0)
		move.w	obX(a0),d1
		lea	(v_player).w,a1 ; a1=character
		cmp.w	obX(a1),d1
		bcc.s	Obj03_Init_CheckX_Next
		move.b	#1,$34(a0)
Obj03_Init_CheckX_Next:
	;	lea	(Sidekick).w,a1 ; a1=character
	;	cmp.w	$08(a1),d1
	;	bcc.s	+
	;	move.b	#1,$35(a0)
;+

Obj03_MainX:
		tst.w	(v_debuguse).w
		bne.w	return_1FEAC
		move.w	obX(a0),d1
		lea	$34(a0),a2
		lea	(v_player).w,a1 ; a1=character
;		bsr.s	+
;		lea	(Sidekick).w,a1 ; a1=character

;+
		tst.b	(a2)+
		bne.s	Obj03_MainX_Alt
		cmp.w	obX(a1),d1
		bhi.w	return_1FEAC
		move.b	#1,-1(a2)
		move.w	obY(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blt.w	return_1FEAC
		cmp.w	d3,d4
		bge.w	return_1FEAC
		move.b	obSubtype(a0),d0
		bpl.s	Obj03_ICX_B1
		btst	#1,$2B(a1)
		bne.w	return_1FEAC

Obj03_ICX_B1:
		btst	#0,obRender(a0)
		bne.s	Obj03_ICX_B2
			move.b	#$00,(v_layer).w
	;	move.b	#$C,$3E(a1)
	;	move.b	#$D,$3F(a1)
		btst	#3,d0
		beq.s	Obj03_ICX_B2
			move.b	#$01,(v_layer).w
	;	move.b	#$E,$3E(a1)
	;	move.b	#$F,$3F(a1)

Obj03_ICX_B2:
		andi.w	#$7FFF,obGfx(a1)
		btst	#5,d0
		beq.s	return_1FEAC
		ori.w	#$8000,obGfx(a1)
		bra.s	return_1FEAC
; ===========================================================================

Obj03_MainX_Alt:
		cmp.w	obX(a1),d1
		bls.w	return_1FEAC
		move.b	#0,-1(a2)
		move.w	obY(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blt.w	return_1FEAC
		cmp.w	d3,d4
		bge.w	return_1FEAC
		move.b	obSubtype(a0),d0
		bpl.s	Obj03_MXA_B1
		btst	#1,$2B(a1)
		bne.w	return_1FEAC

Obj03_MXA_B1:
		btst	#0,$01(a0)
		bne.s	Obj03_MXA_B2
			move.b	#$00,(v_layer).w
	;	move.b	#$C,$3E(a1)
	;	move.b	#$D,$3F(a1)
		btst	#4,d0
		beq.s	Obj03_MXA_B2
			move.b	#$01,(v_layer).w
	;	move.b	#$E,$3E(a1)
	;	move.b	#$F,$3F(a1)

Obj03_MXA_B2:
		andi.w	#$7FFF,obGfx(a1)
		btst	#6,d0
		beq.s	return_1FEAC
		ori.w	#$8000,obGfx(a1)

return_1FEAC:
		rts

; ===========================================================================

Obj03_MainY:
		tst.w	(v_debuguse).w
		bne.w	return_1FFB6
		move.w	obY(a0),d1
		lea	$34(a0),a2
		lea	(v_player).w,a1 ; a1=character
;		bsr.s	+
;		lea	(Sidekick).w,a1 ; a1=character

;+
		tst.b	(a2)+
		bne.s	Obj03_MainY_Alt
		cmp.w	obY(a1),d1
		bhi.w	return_1FFB6
		move.b	#1,-1(a2)
		move.w	obX(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obX(a1),d4
		cmp.w	d2,d4
		blt.w	return_1FFB6
		cmp.w	d3,d4
		bge.w	return_1FFB6
		move.b	obSubtype(a0),d0
		bpl.s	Obj03_MY_B1
		btst	#1,$2B(a1)
		bne.w	return_1FFB6

Obj03_MY_B1:
		btst	#0,obRender(a0)
		bne.s	Obj03_MY_B2
			move.b	#$00,(v_layer).w
	;	move.b	#$C,$3E(a1)
	;	move.b	#$D,$3F(a1)
		btst	#3,d0
		beq.s	Obj03_MY_B2
			move.b	#$01,(v_layer).w
	;	move.b	#$E,$3E(a1)
	;	move.b	#$F,$3F(a1)

Obj03_MY_B2:
		andi.w	#$7FFF,obGfx(a1)
		btst	#5,d0
		beq.s	return_1FFB6
		ori.w	#$8000,obGfx(a1)
		bra.s	return_1FFB6

; ===========================================================================

Obj03_MainY_Alt:
		cmp.w	obY(a1),d1
		bls.w	return_1FFB6
		move.b	#0,-1(a2)
		move.w	obX(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obX(a1),d4
		cmp.w	d2,d4
		blt.w	return_1FFB6
		cmp.w	d3,d4
		bge.w	return_1FFB6
		move.b	obSubtype(a0),d0
		bpl.s	Obj03_MYA_B1
		btst	#1,$2B(a1)
		bne.w	return_1FFB6

Obj03_MYA_B1
		btst	#0,obRender(a0)
		bne.s	Obj03_MYA_B2
			move.b	#$00,(v_layer).w
	;	move.b	#$C,$3E(a1)
	;	move.b	#$D,$3F(a1)
		btst	#4,d0
		beq.s	Obj03_MYA_B2
			move.b	#$01,(v_layer).w
	;	move.b	#$E,$3E(a1)
	;	move.b	#$F,$3F(a1)

Obj03_MYA_B2:
		andi.w	#$7FFF,obGfx(a1)
		btst	#6,d0
		beq.s	return_1FFB6
		ori.w	#$8000,obGfx(a1)

return_1FFB6:
		rts

; ===========================================================================
