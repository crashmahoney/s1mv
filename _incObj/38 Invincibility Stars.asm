; ---------------------------------------------------------------------------
; Object 38 - shield and invincibility stars
; ---------------------------------------------------------------------------
invinc_anim     = $30
invinc_obj_num  = $36
invinc_frame    = $38

InvincibilityStars:				; XREF: Obj_Index
	moveq	#0,d0
	move.b	obRoutine(a0),d0
	move.w	InvincibilityStars_Index(pc,d0.w),d1
	jmp	InvincibilityStars_Index(pc,d1.w)
; ===========================================================================
InvincibilityStars_Index:
		dc.w InvincibilityStars_Main-InvincibilityStars_Index	        ; 0
		dc.w InvincibilityStars_Routine_2-InvincibilityStars_Index	; 2
		dc.w InvincibilityStars_Routine_4-InvincibilityStars_Index	; 4
; ===========================================================================
off_1D992:
	dc.l Invic_Anim1
	dc.w $B
	dc.l Invic_Anim2
	dc.w $160D
	dc.l Invic_Anim3
	dc.w $2C0D
; ===========================================================================

InvincibilityStars_Main:
    writeVRAM Art_Stars, $22*$20, $A9E0            ; DMA $22 tiles to VRAM
	moveq	#0,d2
	lea		off_1D992-6(pc),a2
	lea		(a0),a1

	moveq	#3,d1                           ; create 4 star objects
@makestarparent:
	move.b	(a0),(a1)                       ; create object with the same id as this one
	move.b	#4,obRoutine(a1)				; make new onject go straight to routine $4
	move.l	#Map_Invinc,obMap(a1)           ; mappings in sonic 2 format :o
	move.w	#$54F,obGfx(a1)
	move.b	#4,obRender(a1)
	bset	#6,obRender(a1)                 ; enable childsprites
	move.b	#$10,mainspr_width(a1)
	move.b	#2,mainspr_childsprites(a1)     ; number of childsprites
;	move.w	parent(a0),parent(a1)           ; parent is always sonic, this can probably go
	move.b	d2,invinc_obj_num(a1)           ; remember where in the chain this object is
	addq.w	#1,d2                           ; advance counter for next object
	move.l	(a2)+,invinc_anim(a1)
	move.w	(a2)+,$34(a1)
	lea	$40(a1),a1                      ; next object slot
	dbf	d1,@makestarparent

	move.b	#2,obRoutine(a0)		; => InvincibilityStars_Routine_2
	move.b	#4,$34(a0)

InvincibilityStars_Routine_2:
	movea.w	#v_player,a1                     ; a1=character
	tst.b	(v_invinc).w	                 ; does Sonic have invincibility?
	beq.w	Invinc_JmpTo_DeleteObject
	move.w	obX(a1),d0
	move.w	d0,obX(a0)
	move.w	obY(a1),d1
	move.w	d1,obY(a0)
	lea	sub2_x_pos(a0),a2                ; first child object RAM start
	lea	Invic_Anim0(pc),a3               ; list of animation frames
	moveq	#0,d5

@getframe:
	move.w	invinc_frame(a0),d2
	move.b	(a3,d2.w),d5                     ; put required frame in d5
	bpl.s	loc_1DA44                        ; if not $FF (the restart flag), branch
	clr.w	invinc_frame(a0)                 ; back to start of animation
	bra.s	@getframe                        ; try to get required frame again
; ===========================================================================

loc_1DA44:
	addq.w	#1,invinc_frame(a0)
	lea	ChildStarPositions(pc),a6
	move.b	$34(a0),d6
	jsr	loc_1DB2C(pc)
	move.w	d2,(a2)+	; sub2_x_pos
	move.w	d3,(a2)+	; sub2_y_pos
	move.w	d5,(a2)+	; sub2_mapframe
	addi.w	#$20,d6         ; position of opposite star in table
	jsr	loc_1DB2C(pc)
	move.w	d2,(a2)+	; sub3_x_pos
	move.w	d3,(a2)+	; sub3_y_pos
	move.w	d5,(a2)+	; sub3_mapframe
	moveq	#$12,d0
	btst	#0,obStatus(a1)
	beq.s	loc_1DA74
	neg.w	d0

loc_1DA74:
	add.b	d0,$34(a0)
	move.w	#$80,d0
	jmp	DisplaySprite3
; ===========================================================================

InvincibilityStars_Routine_4:
	movea.w	#v_player,a1                    ; a1=character
	tst.b	(v_invinc).w	                ; does Sonic have invincibility?
	beq.w	Invinc_JmpTo_DeleteObject

		bclr	#7,obGfx(a0)				; put on low plane
		btst	#7,(v_player+obGfx).w		; is sonic on the high plane?
		beq.s	@nothigh
		bset	#7,obGfx(a0)				; put on high plane
@nothigh:

	lea	(v_trackpos).w,a5
	lea	(v_tracksonic).w,a6
	move.b	invinc_obj_num(a0),d1           ; get where in the chain this object is
	lsl.b	#2,d1
	move.w	d1,d2
	add.w	d1,d1
	add.w	d2,d1
	move.w	(a5),d0
	sub.b	d1,d0
	lea	(a6,d0.w),a2
	move.w	(a2)+,d0
	move.w	(a2)+,d1
	move.w	d0,obX(a0)
	move.w	d1,obY(a0)
	lea	sub2_x_pos(a0),a2
	movea.l	invinc_anim(a0),a3

loc_1DAD4:
	move.w	invinc_frame(a0),d2
	move.b	(a3,d2.w),d5
	bpl.s	loc_1DAE4
	clr.w	invinc_frame(a0)
	bra.s	loc_1DAD4
; ===========================================================================

loc_1DAE4:
	swap	d5
	add.b	$35(a0),d2
	move.b	(a3,d2.w),d5
	addq.w	#1,invinc_frame(a0)
	lea	ChildStarPositions(pc),a6
	move.b	$34(a0),d6
	jsr	loc_1DB2C(pc)
	move.w	d2,(a2)+	; sub2_x_pos
	move.w	d3,(a2)+	; sub2_y_pos
	move.w	d5,(a2)+	; sub2_mapframe
	addi.w	#$20,d6
	swap	d5
	jsr	loc_1DB2C(pc)
	move.w	d2,(a2)+	; sub3_x_pos
	move.w	d3,(a2)+	; sub3_y_pos
	move.w	d5,(a2)+	; sub3_mapframe
	moveq	#2,d0
	btst	#0,obStatus(a1)
	beq.s	loc_1DB20
	neg.w	d0

loc_1DB20:
	add.b	d0,$34(a0)
	move.w	#$80,d0
	jmp	DisplaySprite3
; ===========================================================================

loc_1DB2C:
	andi.w	#$3E,d6
	move.b	(a6,d6.w),d2
	move.b	1(a6,d6.w),d3
	ext.w	d2
	ext.w	d3
	add.w	d0,d2
	add.w	d1,d3
	rts
; ===========================================================================
Invinc_JmpTo_DeleteObject:
 	jmp	DeleteObject
; ===========================================================================
; Star position relative to centre, first byte x, second is y
ChildStarPositions:	dc.w   $0F00,  $0F03,  $0E06,  $0D08,  $0B0B,  $080D,  $060E,  $030F
		        dc.w   $0010,  $FC0F, -$6F2, -$8F3, -$BF5, -$DF8, -$EFA, -$FFD
		        dc.w   $F000, -$F04,  $F1F9, -$D09, -$B0C, -$80E, -$60F, -$310
		        dc.w   $FFF0,  $03F0,  $06F1,  $08F2,  $0BF4,  $0DF7,  $0EF9,  $0FFC

Invic_Anim0:	dc.b   8,  5,  7,  6,  6,  7,  5,  8,  6,  7,  7,  6,$FF
Invic_Anim1:	dc.b   8,  7,  6,  5,  4,  3,  4,  5,  6,  7,$FF
		dc.b   3,  4,  5,  6,  7,  8,  7,  6,  5,  4
Invic_Anim2:	dc.b   8,  7,  6,  5,  4,  3,  2,  3,  4,  5,  6,  7,$FF
		dc.b   2,  3,  4,  5,  6,  7,  8,  7,  6,  5,  4,  3
Invic_Anim3:	dc.b   7,  6,  5,  4,  3,  2,  1,  2,  3,  4,  5,  6,$FF
		dc.b   1,  2,  3,  4,  5,  6,  7,  6,  5,  4,  3,  2