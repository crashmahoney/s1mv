; ---------------------------------------------------------------------------
; Object 11 - GHZ bridge
; ---------------------------------------------------------------------------
; OST Variables:
Obj11_child1		= $30	; pointer to first set of bridge segments
Obj11_child2		= $34	; pointer to second set of bridge segments, if applicable
Obj11_baseYpos		= $3C	; resting y position of bridge
Obj11_Sonanim		= $3E


Bridge:					; XREF: Obj_Index
		btst	#6,obRender(a0)	; is this a child sprite object?
		bne.w	@child			; if yes, branch
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Bri_Index(pc,d0.w),d1
		jmp	Bri_Index(pc,d1.w)
; ===========================================================================
@child:	; child sprite objects only need to be drawn
		move.w	#$180,d0
		bra.w	DisplaySprite3
; ===========================================================================
Bri_Index:	dc.w 	Bri_Main-Bri_Index
 			dc.w	Bri_Action-Bri_Index
 			dc.w 	Bri_Platform-Bri_Index
 			dc.w	Bri_Delete-Bri_Index
 			dc.w	Bri_Delete-Bri_Index
		 	dc.w	Bri_Display-Bri_Index
		 	dc.w	Bri_Collapse-Bri_Index
; ===========================================================================

Bri_Main:	; Routine 0
	addq.b	#2,obRoutine(a0)
	move.l	#Map_Bri,obMap(a0)
	move.w	#$4000+(VRAMloc_Bridge/$20),obGfx(a0)
	move.b	#4,obRender(a0)
	move.w	#$180,obPriority(a0)
	move.b	#$80,obActWid(a0)
	move.w	obY(a0),d2
	move.w	d2,Obj11_baseYpos(a0)
	move.w	obX(a0),d3
	move.b	0(a0),d4	; copy object number ($11) to d4
	lea		obSubtype(a0),a2
	moveq	#0,d1
	move.b	(a2),d1		; copy bridge length to d1
;	move.b	#0,(a2)+	; clear bridge length
	move.w	d1,d0
	lsr.w	#1,d0
	lsl.w	#4,d0
	sub.w	d0,d3		; d3 is position of leftmost log
	swap	d1	; store subtype in high word for later
	move.w	#8,d1
	bsr.s	Obj11_MakeBdgSegment
	move.w	sub6_x_pos(a1),d0
	subq.w	#8,d0
	move.w	d0,obX(a1)		; center of first subsprite object
	move.l	a1,Obj11_child1(a0)	; pointer to first subsprite object
	swap	d1	; retrieve subtype
	subq.w	#8,d1
	bls.s	@finish	; branch, if subtype <= 8 (bridge has no more than 8 logs)
	; else, create a second subsprite object for the rest of the bridge
	move.w	d1,d4
	bsr.s	Obj11_MakeBdgSegment
	move.l	a1,Obj11_child2(a0)	; pointer to second subsprite object
	move.w	d4,d0
	add.w	d0,d0
	add.w	d4,d0	; d0*3
	move.w	sub2_x_pos(a1,d0.w),d0
	subq.w	#8,d0
	move.w	d0,obX(a1)		; center of second subsprite object 
@finish:
	bra.s	Bri_Action

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
Obj11_MakeBdgSegment:
	bsr.w	FindNextFreeObj
	bne.s	@rts
	move.b	(a0),(a1) ; load obj11
	move.w	obX(a0),obX(a1)
	move.w	obY(a0),obY(a1)
	move.l	obMap(a0),obMap(a1)
	move.w	obGfx(a0),obGfx(a1)
	move.b	obRender(a0),obRender(a1)
	bset	#6,obRender(a1)
	move.b	#$40,mainspr_width(a1)
	move.b	d1,mainspr_childsprites(a1)
	subq.b	#1,d1
	lea		sub2_x_pos(a1),a2 ; starting address for subsprite data

@makelog:
	move.w	d3,(a2)+	; sub?_x_pos
	move.w	d2,(a2)+	; sub?_y_pos
	move.w	#0,(a2)+	; sub?_mapframe
	addi.w	#$10,d3		; width of a log, x_pos for next log
	dbf	d1,@makelog		; repeat for d1 logs
@rts:
	rts
; End of function Obj11_MakeBdgSegment

; ===========================================================================
Bri_Action:	; Routine 2
		bsr.s	Bri_Solid
		tst.b	$3E(a0)
		beq.s	@display
		subq.b	#4,$3E(a0)
		bsr.w	Bri_Bend

	@display:
		;bsr.w	DisplaySprite
		bra.w	Bri_ChkDel

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Bri_Solid:
		moveq	#0,d1
		move.b	obSubtype(a0),d1
		lsl.w	#3,d1
		move.w	d1,d2
		addq.w	#8,d1
		add.w	d2,d2
		lea	(v_player).w,a1
		move.b	obAnim(a1),obAnim(a0) 	; remember sonic's animation
		move.w	obVelY(a1),obVelY(a0) 	; remember sonic's y speed		
		tst.w	obVelY(a1)
		bmi.w	Plat_Exit
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	Plat_Exit
		cmp.w	d2,d0
		bcc.w	Plat_Exit
		bra.w	Plat_NoXCheck
; End of function Bri_Solid

; ===========================================================================

Bri_ChkDel:
	obRange	@delete
	rts
; ---------------------------------------------------------------------------
@delete:	; delete first subsprite object
	movea.l	Obj11_child1(a0),a1 ; a1=object
	bsr.w	DeleteChild
	cmpi.b	#8,obSubtype(a0)
	bls.s	@delparent	; if bridge has more than 8 logs, delete second subsprite object
	movea.l	Obj11_child2(a0),a1 ; a1=object
	bsr.w	DeleteChild
@delparent:
	if S3KObjectManager=1
        move.w	obRespawnNo(a0),d0	; get address in respawn table
	    movea.w	d0,a2				; load address into a2
	    bclr	#7,(a2)				; clear respawn table entry, so object can be loaded again
	endif
	bra.w	DeleteObject
; ===========================================================================
Bri_Delete:	; Routine 6, 8
		bra.w	DeleteObject
Bri_Display:
		bra.w	DisplaySprite
; ===========================================================================

Bri_Platform:	; Routine 4
		cmpi.b	#id_stomp,obAnim(a0) 		; is Sonic stomping?
		bne.s	@bend
		move.b	#$C,obRoutine(a0)		; go to collapsing routine
		lea	(v_player).w,a1
		bclr	#3,obStatus(a1)
		bclr	#3,obStatus(a0)
		move.b	#id_stomp,obAnim(a1) 	
		move.w	obVelY(a0),obVelY(a1) 		; restore sonic's y speed		
		bra.w	Bri_Collapse
	@bend:	
		bsr.w	Bri_Bend
		bsr.s	Bri_WalkOff
	;	bsr.w	DisplaySprite
		bra.w	Bri_ChkDel
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk off a bridge
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Bri_WalkOff:				; XREF: Bri_Platform
		lea	(v_player).w,a1
		moveq	#0,d1
		move.b	obSubtype(a0),d1
		lsl.w	#3,d1
		move.w	d1,d2
		addq.w	#8,d1
		bsr.w	ExitPlatform2
		bcc.s	locret_75BE
		lsr.w	#4,d0
		move.b	d0,$3F(a0)
		move.b	$3E(a0),d0
		cmpi.b	#$40,d0
		beq.s	loc_75B6
		addq.b	#4,$3E(a0)

loc_75B6:
		bsr.w	Bri_MoveSonic

locret_75BE:
		rts	
; End of function Bri_WalkOff


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Bri_MoveSonic:				; XREF: Bri_WalkOff
		moveq	#0,d0
		move.b	$3F(a0),d0						; which piece sonic is standing on
	movea.l	Obj11_child1(a0),a2
	cmpi.w	#8,d0								; is piece number under 8
	blo.s	@got_object							; if so, we have the right one
	movea.l	Obj11_child2(a0),a2 ; a2=object
	subi.w	#8,d0
@got_object:
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	move.w	sub2_y_pos(a2,d0.w),d0
	subq.w	#8,d0
	moveq	#0,d1
	move.b	obWidth(a1),d1
	sub.w	d1,d0
	move.w	d0,obY(a1)							; change Sonic's position on y-axis
;	moveq	#0,d4
	rts
; End of function Bri_MoveSonic

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; subroutine to make the bridge push down where Sonic or Tails walks over
Bri_Bend:
	move.b	objoff_3E(a0),d0
	bsr.w	CalcSine
	move.w	d0,d4
	lea	(byte_FB28).l,a4
	moveq	#0,d0
	move.b	obSubtype(a0),d0
	lsl.w	#4,d0
	moveq	#0,d3
	move.b	objoff_3F(a0),d3
	move.w	d3,d2
	add.w	d0,d3
	moveq	#0,d5
	lea	(Obj11_DepressionOffsets-$80).l,a5
	move.b	(a5,d3.w),d5
	andi.w	#$F,d3
	lsl.w	#4,d3
	lea	(a4,d3.w),a3
	movea.l	Obj11_child1(a0),a1
	lea	sub9_y_pos+next_subspr(a1),a2
	lea	sub2_y_pos(a1),a1

@set_piece_y:
	moveq	#0,d0
	move.b	(a3)+,d0
	addq.w	#1,d0
	mulu.w	d5,d0
	mulu.w	d4,d0
	swap	d0
	add.w	Obj11_baseYpos(a0),d0
	move.w	d0,(a1)
	addq.w	#6,a1
	cmpa.w	a2,a1
	bne.s	@next_piece
	movea.l	Obj11_child2(a0),a1 ; a1=object
	lea	sub2_y_pos(a1),a1
@next_piece:
	dbf	d2,@set_piece_y

	moveq	#0,d0
	move.b	obSubtype(a0),d0
	moveq	#0,d3
	move.b	objoff_3F(a0),d3
	addq.b	#1,d3
	sub.b	d0,d3
	neg.b	d3
	bmi.s	@rts
	move.w	d3,d2
	lsl.w	#4,d3
	lea	(a4,d3.w),a3
	adda.w	d2,a3
	subq.w	#1,d2
	bcs.s	@rts

@set_piece_y2:
	moveq	#0,d0
	move.b	-(a3),d0
	addq.w	#1,d0
	mulu.w	d5,d0
	mulu.w	d4,d0
	swap	d0
	add.w	Obj11_baseYpos(a0),d0
	move.w	d0,(a1)
	addq.w	#6,a1
	cmpa.w	a2,a1
	bne.s	@next_piece2
	movea.l	Obj11_child2(a0),a1 ; a1=object
	lea	sub2_y_pos(a1),a1
@next_piece2:
	dbf	d2,@set_piece_y2
@rts:
	rts
; ===========================================================================
; seems to be bridge piece vertical position offset data
Obj11_DepressionOffsets: ; byte_FA98:
	dc.b   2,  4,  6,  8,  8,  6,  4,  2,  0,  0,  0,  0,  0,  0,  0,  0; 16
	dc.b   2,  4,  6,  8, $A,  8,  6,  4,  2,  0,  0,  0,  0,  0,  0,  0; 32
	dc.b   2,  4,  6,  8, $A, $A,  8,  6,  4,  2,  0,  0,  0,  0,  0,  0; 48
	dc.b   2,  4,  6,  8, $A, $C, $A,  8,  6,  4,  2,  0,  0,  0,  0,  0; 64
	dc.b   2,  4,  6,  8, $A, $C, $C, $A,  8,  6,  4,  2,  0,  0,  0,  0; 80
	dc.b   2,  4,  6,  8, $A, $C, $E, $C, $A,  8,  6,  4,  2,  0,  0,  0; 96
	dc.b   2,  4,  6,  8, $A, $C, $E, $E, $C, $A,  8,  6,  4,  2,  0,  0; 112
	dc.b   2,  4,  6,  8, $A, $C, $E,$10, $E, $C, $A,  8,  6,  4,  2,  0; 128
	dc.b   2,  4,  6,  8, $A, $C, $E,$10,$10, $E, $C, $A,  8,  6,  4,  2; 144

; something else important for bridge depression to work (phase? bridge size adjustment?)
byte_FB28:
	dc.b $FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 16
	dc.b $B5,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 32
	dc.b $7E,$DB,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 48
	dc.b $61,$B5,$EC,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 64
	dc.b $4A,$93,$CD,$F3,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 80
	dc.b $3E,$7E,$B0,$DB,$F6,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 96
	dc.b $38,$6D,$9D,$C5,$E4,$F8,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0; 112
	dc.b $31,$61,$8E,$B5,$D4,$EC,$FB,$FF,  0,  0,  0,  0,  0,  0,  0,  0; 128
	dc.b $2B,$56,$7E,$A2,$C1,$DB,$EE,$FB,$FF,  0,  0,  0,  0,  0,  0,  0; 144
	dc.b $25,$4A,$73,$93,$B0,$CD,$E1,$F3,$FC,$FF,  0,  0,  0,  0,  0,  0; 160
	dc.b $1F,$44,$67,$88,$A7,$BD,$D4,$E7,$F4,$FD,$FF,  0,  0,  0,  0,  0; 176
	dc.b $1F,$3E,$5C,$7E,$98,$B0,$C9,$DB,$EA,$F6,$FD,$FF,  0,  0,  0,  0; 192
	dc.b $19,$38,$56,$73,$8E,$A7,$BD,$D1,$E1,$EE,$F8,$FE,$FF,  0,  0,  0; 208
	dc.b $19,$38,$50,$6D,$83,$9D,$B0,$C5,$D8,$E4,$F1,$F8,$FE,$FF,  0,  0; 224
	dc.b $19,$31,$4A,$67,$7E,$93,$A7,$BD,$CD,$DB,$E7,$F3,$F9,$FE,$FF,  0; 240
	dc.b $19,$31,$4A,$61,$78,$8E,$A2,$B5,$C5,$D4,$E1,$EC,$F4,$FB,$FE,$FF; 256

		include	"_maps\Bridge.asm"



; ===========================================================================
PlatformObj_Bridge:
		tst.w	obVelY(a1)
		bmi.w	Plat_Exit
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	Plat_Exit
		cmp.w	d2,d0
		bcc.w	Plat_Exit
		bra.w	Plat_NoXCheck
; End of function Bri_Solid

; ===========================================================================
Bri_Collapse:
	movea.l	Obj11_child1(a0),a1	
	lea	sub2_y_pos(a1),a2	; load first childsprite y pos
	lea	(Bri_Piece_Speed).l,a3	; load peice speeds
	moveq	#8-1,d1			; move first 8 childsprites
@child1_yfall:
	move.w	(a3)+,d0		; add to childsprite y pos
	add.w	d0,(a2)
	adda.l	#6,a2			; advance to next piece
	dbf	d1,@child1_yfall

	moveq	#0,d1
	move.b	obSubtype(a0),d1	; retrieve subtype
	subq.w	#8,d1
	bls.s	@finish			; branch, if subtype <= 8 (bridge has no more than 8 logs)
		
	movea.l	Obj11_child2(a0),a1	
	lea	sub2_y_pos(a1),a2	; load first childsprite y pos
@child2_yfall:
	move.w	(a3)+,d0		; add to childsprite y pos
	add.w	d0,(a2)
	adda.l	#6,a2			; advance to next piece
	dbf	d1,@child2_yfall

@finish:
		bra.w	Bri_ChkDel



Bri_Piece_Speed:
	dc.w	$03,$02,$05,$04,$03,$05,$02,$04,$06,$05,$02,$03,$04,$02,$05,$02
	even