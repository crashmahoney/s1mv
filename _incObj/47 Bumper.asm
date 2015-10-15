; ---------------------------------------------------------------------------
; Object 47 - pinball bumper (SYZ)
; ---------------------------------------------------------------------------

Bumper:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Bump_Index(pc,d0.w),d1
		jmp	Bump_Index(pc,d1.w)
; ===========================================================================
Bump_Index:	dc.w Bump_Main-Bump_Index
		dc.w Bump_Hit-Bump_Index
; ===========================================================================

Bump_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Bump,obMap(a0)
		move.w	#$380,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.w	#$80,obPriority(a0)
		move.b	#$D7,obColType(a0)

Bump_Hit:	; Routine 2
		tst.b	obColProp(a0)	; has Sonic touched the	bumper?
		beq.w	@display	; if not, branch
		clr.b	obColProp(a0)
		lea	(v_player).w,a1
		move.w	obX(a0),d1
		move.w	obY(a0),d2
		sub.w	obX(a1),d1
		sub.w	obY(a1),d2
		jsr	(CalcAngle).l
		jsr	(CalcSine).l
		muls.w	#-$700,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a1)	; bounce Sonic away
		muls.w	#-$700,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a1)	; bounce Sonic away
		bset	#1,obStatus(a1)
		bclr	#4,obStatus(a1)
		bclr	#5,obStatus(a1)
		clr.b	$3C(a1)
		move.b	#1,obAnim(a0)	; use "hit" animation
		sfx	sfx_Bumper	; play bumper sound
        if S3KObjectManager=1
                move.w	obRespawnNo(a0),d0	; get address in respawn table
	        beq.s	@addscore		; if it's zero, don't remember object
	        movea.w	d0,a2	                ; load address into a2
		cmpi.b	#$8A,(a2)	        ; has bumper been hit 10 times?
		bcc.s	@display	        ; if yes, Sonic	gets no	points
		addq.b	#1,(a2)                 ; add to hit count
        else
 		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	@addscore
		cmpi.b	#$8A,2(a2,d0.w)	; has bumper been hit 10 times?
		bcc.s	@display	; if yes, Sonic	gets no	points
		addq.b	#1,2(a2,d0.w)
        endif

	@addscore:
		moveq	#1,d0
		jsr	AddPoints	; add 10 to score
		bsr.w	FindFreeObj
		bne.s	@display
		move.b	#id_Points,0(a1) ; load points object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	#4,obFrame(a1)

	@display:
		lea	(Ani_Bump).l,a1
		bsr.w	AnimateSprite
		obRanges	@resetcount
		bra.w	DisplaySprite
; ===========================================================================

@resetcount:
        if S3KObjectManager=1
                move.w	obRespawnNo(a0),d0	; get address in respawn table
	        beq.s	@delete		        ; if it's zero, don't remember object
	        movea.w	d0,a2	                ; load address into a2
	        bclr	#7,(a2)	                ; clear respawn table entry, so object can be loaded again
        else
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	@delete
		bclr	#7,2(a2,d0.w)
        endif

	@delete:
		bra.w	DeleteObject
