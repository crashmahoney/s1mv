; ===========================================================================
; ----------------------------------------------------------------------------
; Object 2C - Sprite that makes leaves fly off when you hit it from ARZ
; ----------------------------------------------------------------------------
LeafGenerator:
	moveq	#0,d0
	move.b	obRoutine(a0),d0
	move.w	Obj2C_Index(pc,d0.w),d1
	jmp		Obj2C_Index(pc,d1.w)
; ===========================================================================
Obj2C_Index:	
		dc.w Obj2C_Init-Obj2C_Index	; 0
		dc.w Obj2C_Main-Obj2C_Index	; 2
		dc.w Leaf_Main-Obj2C_Index	; 4
; ===========================================================================
Obj2C_CollisionFlags:
		dc.b $20
		dc.b $40	; 1
		dc.b $60	; 2
		dc.b   0	; 3
; ===========================================================================
Obj2C_Init:
	addq.b	#2,obRoutine(a0)
	moveq	#0,d0
	move.b	obSubtype(a0),d0
	move.b	Obj2C_CollisionFlags(pc,d0.w),objoff_30(a0)
	move.l	#Map_LTag,obMap(a0)
	move.w	#$680,obGfx(a0)
	move.b	#$84,obRender(a0)
	move.b	#$80,obActWid(a0)
	move.w	#$200,obPriority(a0)
	move.b	obSubtype(a0),obFrame(a0)

Obj2C_Main:
	obRange Mark_ChkGone					; delete if out of range
; ----------------------------------------------------------------------------
; don't check collision every frame	
	move.b	d7,d0
	add.b	(v_vbla_byte).w,d0
	andi.b	#7,d0
	bne.s	@no_collision
; ----------------------------------------------------------------------------
; check y range	
	lea		(v_player).w,a2 				; a2=character
	move.w	obY(a0),d0						; get object's Y pos
	sub.w	#$20,d0							; get top of object
	sub.w   obY(a2),d0						; subtract sonic's Y pos
	bcc.s	@reset_counter					; sonic is above it, so branch
	add.w	#$40,d0							; get bottom of object
	bcc.s	@reset_counter					; sonic is below, so branch
; check X range
	moveq	#0,d1
	move.b  objoff_30(a0),d1				; X size
	move.w	obX(a0),d0						; get object's X pos
	sub.w   d1,d0							; get left side
	sub.w	obX(a2),d0						; subtract sonic's X pos
	bcc.s	@reset_counter					; sonic is to the left, so branch
	add.w	d1,d1
	add.w	d1,d0
	bcc.s	@reset_counter					; sonic is to the right, so branch
; ----------------------------------------------------------------------------
	sub.w	#1,objoff_2E(a0)				; subtract from counter
	bpl.s	@no_collision					; if not below 0, branch
	bsr.s	@chk_speed						; create leaves
	move.w	#2,objoff_2E(a0)				; set counter
@no_collision:
	rts
; ===========================================================================

@reset_counter:
	clr.w	objoff_2E(a0)					; reset counter
	rts
; ===========================================================================

@chk_speed:
	mvabs.w	obVelX(a2),d0
	cmpi.w	#$100,d0
	bhs.s	@leaf_setup
	mvabs.w	obVelY(a2),d0
	cmpi.w	#$100,d0
	blo.s	@reset_counter

@leaf_setup:
	lea		(Obj2C_Speeds).l,a3
	moveq	#3,d6

@create_leaf:
	jsr		FindFreeObj
	bne.w	@create_leaf_end
	move.b	#id_Leaf,(a1) 					; load leaf
	move.w	obX(a2),obX(a1)
	move.w	obY(a2),obY(a1)
	jsr		RandomNumber					; get random number
	andi.w	#$F,d0
	subq.w	#8,d0
	add.w	d0,obX(a1)						; randomize x pos
	swap	d0
	andi.w	#$F,d0
	subq.w	#8,d0
	add.w	d0,obY(a1)						; randomize y pos
	move.w	(a3)+,obVelX(a1)
	move.w	(a3)+,obVelY(a1)
	btst	#0,obStatus(a2)					; is sonic facing 
	beq.s	@notset
	neg.w	obVelX(a1)
  @notset:
	move.w	obX(a1),objoff_30(a1)
	move.w	obY(a1),objoff_34(a1)
	andi.b	#1,d0
	move.b	d0,obFrame(a1)
	move.l	#Map_Leaf,obMap(a1)
	move.w	#(VRAMloc_Leaves/$20)+$8000,obGfx(a1)
	move.b	#$84,obRender(a1)
	move.b	#8,obActWid(a1)
	move.w	#$80,obPriority(a1)
	move.b	#4,objoff_38(a1)
	move.b	d1,obAngle(a0)
@create_leaf_end:
	dbf		d6,@create_leaf

	move.w	#sfx_Leaf,d0
	jmp		(PlaySound).l
; ===========================================================================
Obj2C_Speeds:
		dc.w -$80,-$80	; 0
		dc.w  $C0,-$40	; 1
		dc.w -$C0, $40	; 2
		dc.w  $80, $80	; 3
; ===========================================================================
; The Leaf Object
; ===========================================================================
Leaf_Main:
	move.b	objoff_38(a0),d0
	add.b	d0,obAngle(a0)
	add.b	(v_vbla_byte).w,d0
	andi.w	#$1F,d0
	bne.s	@ok
	add.b	d7,d0
	andi.b	#1,d0
	beq.s	@ok
	neg.b	objoff_38(a0)
  @ok:
  	lea		objoff_30(a0),a2
  	lea		objoff_34(a0),a3  	
	move.l	(a2),d2
	move.l	(a3),d3
	move.w	obVelX(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d2
	move.w	obVelY(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d3
	move.l	d2,(a2)
	move.l	d3,(a3)
	swap	d2
	andi.w	#3,d3
	addq.w	#4,d3
	add.w	d3,obVelY(a0)
	move.b	obAngle(a0),d0
	jsr		CalcSine
	asr.w	#6,d0
	add.w	(a2),d0
	move.w	d0,obX(a0)
	asr.w	#6,d1
	add.w	(a3),d1
	move.w	d1,obY(a0)
	subq.b	#1,obTimeFrame(a0)
	bpl.s	@frameok
	move.b	#$B,obTimeFrame(a0)
	bchg	#1,obFrame(a0)
  @frameok:
	tst.b	obRender(a0)
	bpl.w	JmpTo29_DeleteObject
	jmp		DisplaySprite
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
; Sprite mappings - generated by Flex - Sonic 1 format

Map_Leaf:
	dc.w @Frame0-Map_Leaf, @Frame1-Map_Leaf
	dc.w @Frame2-Map_Leaf, @Frame3-Map_Leaf


@Frame0: dc.b  $1
	dc.b  $FC, $0, $40, $0, $FC
@Frame1: dc.b  $1
	dc.b  $FC, $4, $40, $1, $F8
@Frame2: dc.b  $1
	dc.b  $FC, $4, $40, $3, $F8
@Frame3: dc.b  $1
	dc.b  $FC, $4, $40, $5, $F8

; ===========================================================================
	even


JmpTo29_DeleteObject 
	jmp	(DeleteObject).l
; ===========================================================================

	align 4