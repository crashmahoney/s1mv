; ---------------------------------------------------------------------------
; Object 33 - pushable blocks (MZ, LZ)
; ---------------------------------------------------------------------------

PushBlock:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	PushB_Index(pc,d0.w),d1
		jmp	PushB_Index(pc,d1.w)
; ===========================================================================
PushB_Index:	dc.w PushB_Main-PushB_Index
		dc.w loc_BF6E-PushB_Index
		dc.w loc_C02C-PushB_Index

; PushB_Var:	dc.b $10, 0	; object width,	frame number  +++ commented out for zone agnostic code
; 		dc.b $40, 1
; ===========================================================================

PushB_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	#$F,obWidth(a0)
		move.b	#$F,obHeight(a0)
; 		move.l	#Map_Push,obMap(a0)
; 		move.w	#$42B8,obGfx(a0) ; MZ specific code
; 		cmpi.b	#1,(v_zone).w
; 		bne.s	@notLZ
; 		move.w	#$43DE,obGfx(a0) ; LZ specific code
; 
; 	@notLZ:
; 		move.b	#4,obRender(a0)
; 		move.w	#$180,obPriority(a0)
		move.l	#Map_Push,obMap(a0)                  ; +++ zone agnostic objects code
		move.w	#$42B8,obGfx(a0) ; MZ specific code
		cmpi.b	#1,(v_zone).w
		bne.s	@notLZ
		move.w	#$43DE,obGfx(a0) ; LZ specific code
 
	@notLZ:
		cmpi.b	#id_GHZ,(v_zone).w
		bne.s	@notGHZ
		move.l	#Map_PRock,obMap(a0)
		move.w	#$4000+(VRAMloc_PplRock/$20),obGfx(a0)
 
	@notGHZ:
		cmpi.b	#id_SLZ,(v_zone).w
		bne.s	@notSLZ
		move.l	#Map_Stair,obMap(a0)
		move.w	#$4000,obGfx(a0) ; SLZ specific code
 
	@notSLZ:
		cmpi.b	#id_SBZ,(v_zone).w
		bne.s	@notSBZ
		move.l	#Map_Push,obMap(a0)
		move.w	#$44BB,obGfx(a0) ; SBZ specific code
 
	@notSBZ:
		cmpi.b	#id_SYZ,(v_zone).w
		bne.s	@notSYZ
		move.l	#Map_FBlock,obMap(a0)
		move.w	#$4000,obGfx(a0) ; SYZ specific code
 
	@notSYZ:
		move.b	#4,obRender(a0)
		move.w	#$180,obPriority(a0)
;  		move.w	obX(a0),$34(a0)
; 		move.w	obY(a0),$36(a0)
; 		moveq	#0,d0
; 		move.b	obSubtype(a0),d0
; 		add.w	d0,d0
; 		andi.w	#$E,d0
; 		lea	PushB_Var(pc,d0.w),a2
; 		move.b	(a2)+,obActWid(a0)
; 		move.b	(a2)+,obFrame(a0)
; 		tst.b	obSubtype(a0)
; 		beq.s	@chkgone
; 		move.w	#$C2B8,obGfx(a0)
		move.w	obX(a0),$34(a0)             ; +++ zone agnostic objects code
		move.w	obY(a0),$36(a0)
		move.b	#$10,obActWid(a0)
		move.b	#0,obFrame(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		andi.b	#$F,d0
		tst.b	d0
		beq.s	@notsetoffour
		move.b	#$40,obActWid(a0)
		move.b	#$01,obFrame(a0)
 
	@notsetoffour:
		tst.b	obSubtype(a0)
		beq.s	@chkgone
		move.w	#$C2B8,obGfx(a0)

	@chkgone:
        if S3KObjectManager=1
                move.w	obRespawnNo(a0),d0	; get address in respawn table
	        beq.s	loc_BF6E		; if it's zero, don't remember object
	        movea.w	d0,a2	                ; load address into a2
	        bclr	#7,(a2)	                ; clear respawn table entry, so object can be loaded again
	        bset	#0,(a2)
        else
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	loc_BF6E
		bclr	#7,2(a2,d0.w)
		bset	#0,2(a2,d0.w)
        endif
		bne.w	DeleteObject
                cmpi.w  #$0A78,obX(a0)          ; is it the block on the stomper in MZ1?
                bne.s   loc_BF6E                ; if not, branch
		btst    #0,(v_actflags).w       ; is flag set
		beq.s   loc_BF6E                ; if not, branch
		move.w	#$0AD0,obX(a0)          ; move block onto switch
		move.w	#$03F0,obY(a0)          ;   "    "     "    "


loc_BF6E:	; Routine 2
		tst.b	$32(a0)
		bne.w	loc_C046
		moveq	#0,d1
		move.b	obActWid(a0),d1
		addi.w	#$B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	obX(a0),d4
		bsr.w	loc_C186
	; +++	cmpi.w	#(id_MZ<<8)+0,(v_zone).w ; is the level MZ act 1?
	;	bne.s	loc_BFC6	; if not, branch
		bclr	#7,obSubtype(a0)
		move.w	obX(a0),d0
		cmpi.w	#$A20,d0
		bcs.s	loc_BFC6
		cmpi.w	#$AA1,d0
		bcc.s	loc_BFC6
		move.w	(v_obj31ypos).w,d0
		subi.w	#$1C,d0
		move.w	d0,obY(a0)
		bset	#7,(v_obj31ypos).w
		bset	#7,obSubtype(a0)

	loc_BFC6:
		obRanges	loc_ppppp
		bra.w	DisplaySprite
; ===========================================================================

loc_ppppp:
		obRanges	loc_C016,$34(a0)
		move.w	$34(a0),obX(a0)
		move.w	$36(a0),obY(a0)
		move.b	#4,obRoutine(a0)
		bra.s	loc_C02C
; ===========================================================================

loc_C016:
        if S3KObjectManager=1
                move.w	obRespawnNo(a0),d0	; get address in respawn table
	        movea.w	d0,a2	                ; load address into a2
	        bclr	#0,(a2)                 
        else
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	loc_C028
		bclr	#0,2(a2,d0.w)
        endif

loc_C028:
		bra.w	DeleteObject
; ===========================================================================

loc_C02C:	; Routine 4
		bsr.w	ChkPartiallyVisible
		beq.s	locret_C044
		move.b	#2,obRoutine(a0)
		clr.b	$32(a0)
		clr.w	obVelX(a0)
		clr.w	obVelY(a0)

locret_C044:
		rts	
; ===========================================================================

loc_C046:				; XREF: loc_BF6E
		move.w	obX(a0),-(sp)
		cmpi.b	#4,ob2ndRout(a0)
		bcc.s	loc_C056
		bsr.w	SpeedToPos

loc_C056:
		btst	#1,obStatus(a0)
		beq.s	loc_C0A0
		addi.w	#$18,obVelY(a0)
		jsr	ObjFloorDist
		tst.w	d1
		bpl.w	loc_C09E
		add.w	d1,obY(a0)
		clr.w	obVelY(a0)
		bclr	#1,obStatus(a0)
		move.w	(a1),d0
		andi.w	#$3FF,d0
		cmpi.w	#$16A,d0
		bcs.s	loc_C09E
		move.w	$30(a0),d0
		asr.w	#3,d0
		move.w	d0,obVelX(a0)
		move.b	#1,$32(a0)
		clr.w	$E(a0)

loc_C09E:
		bra.s	loc_C0E6
; ===========================================================================

loc_C0A0:
		tst.w	obVelX(a0)
		beq.w	loc_C0D6
		bmi.s	loc_C0BC
		moveq	#0,d3
		move.b	obActWid(a0),d3
		jsr	ObjHitWallRight
		tst.w	d1		; has block touched a wall?
		bmi.s	PushB_StopPush	; if yes, branch
		bra.s	loc_C0E6
; ===========================================================================

loc_C0BC:
		moveq	#0,d3
		move.b	obActWid(a0),d3
		not.w	d3
		jsr	ObjHitWallLeft
		tst.w	d1		; has block touched a wall?
		bmi.s	PushB_StopPush	; if yes, branch
		bra.s	loc_C0E6
; ===========================================================================

PushB_StopPush:
		clr.w	obVelX(a0)		; stop block moving
		bra.s	loc_C0E6
; ===========================================================================

loc_C0D6:
		addi.l	#$2001,obY(a0)
		cmpi.b	#$A0,obY+3(a0)
		bcc.s	loc_C104

loc_C0E6:
		moveq	#0,d1
		move.b	obActWid(a0),d1
		addi.w	#$B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	(sp)+,d4
		bsr.w	loc_C186
		bsr.s	PushB_ChkLava
		bra.w	loc_BFC6
; ===========================================================================

loc_C104:
		move.w	(sp)+,d4
		lea	(v_player).w,a1
		bclr	#3,obStatus(a1)
		bclr	#3,obStatus(a0)
		bra.w	loc_ppppp
; ===========================================================================

PushB_ChkLava:
		cmpi.w	#(id_MZ<<8)+1,(v_zone).w ; is the level MZ act 2?
		bne.s	PushB_ChkLava2	; if not, branch
		move.w	#-$20,d2
		cmpi.w	#$DD0,obX(a0)
		beq.s	PushB_LoadLava
		cmpi.w	#$CC0,obX(a0)
		beq.s	PushB_LoadLava
		cmpi.w	#$BA0,obX(a0)
		beq.s	PushB_LoadLava
		rts	
; ===========================================================================

PushB_ChkLava2:
		cmpi.w	#(id_MZ<<8)+2,(v_zone).w ; is the level MZ act 3?
		bne.s	PushB_NoLava	; if not, branch
		move.w	#$20,d2
		cmpi.w	#$560,obX(a0)
		beq.s	PushB_LoadLava
		cmpi.w	#$5C0,obX(a0)
		beq.s	PushB_LoadLava

PushB_NoLava:
		rts	
; ===========================================================================

PushB_LoadLava:
		bsr.w	FindFreeObj
		bne.s	locret_C184
		move.b	#id_GeyserMaker,0(a1) ; load lava geyser object
		move.w	obX(a0),obX(a1)
		add.w	d2,obX(a1)
		move.w	obY(a0),obY(a1)
		addi.w	#$10,obY(a1)
		move.l	a0,$3C(a1)

locret_C184:
		rts	
; ===========================================================================

loc_C186:				; XREF: loc_BF6E
		move.b	ob2ndRout(a0),d0
		beq.w	loc_C218
		subq.b	#2,d0
		bne.s	loc_C1AA
		bsr.w	ExitPlatform
		btst	#3,obStatus(a1)
		bne.s	loc_C1A4
		clr.b	ob2ndRout(a0)
		rts	
; ===========================================================================

loc_C1A4:
		move.w	d4,d2
		bra.w	MvSonicOnPtfm
; ===========================================================================

loc_C1AA:
		subq.b	#2,d0
		bne.s	loc_C1F2
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)
		jsr	ObjFloorDist
		tst.w	d1
		bpl.w	locret_C1F0
		add.w	d1,obY(a0)
		clr.w	obVelY(a0)
		clr.b	ob2ndRout(a0)
		move.w	(a1),d0
		andi.w	#$3FF,d0
		cmpi.w	#$16A,d0
		bcs.s	locret_C1F0
		move.w	$30(a0),d0
		asr.w	#3,d0
		move.w	d0,obVelX(a0)
		move.b	#1,$32(a0)
		clr.w	obY+2(a0)

locret_C1F0:
		rts	
; ===========================================================================

loc_C1F2:
		bsr.w	SpeedToPos
		move.w	obX(a0),d0
		andi.w	#$C,d0
		bne.w	locret_C2E4
		andi.w	#-$10,obX(a0)
		move.w	obVelX(a0),$30(a0)
		clr.w	obVelX(a0)
		subq.b	#2,ob2ndRout(a0)
		rts	
; ===========================================================================

loc_C218:
		bsr.w	Solid_ChkEnter
		tst.w	d4
		beq.w	locret_C2E4
		bmi.w	locret_C2E4
		tst.b	$32(a0)
		beq.s	loc_C230
		bra.w	locret_C2E4
; ===========================================================================

loc_C230:
		tst.w	d0
		beq.w	locret_C2E4
		bmi.s	loc_C268
		btst	#0,obStatus(a1)
		bne.w	locret_C2E4
		move.w	d0,-(sp)
		moveq	#0,d3
		move.b	obActWid(a0),d3
		jsr	ObjHitWallRight
		move.w	(sp)+,d0
		tst.w	d1
		bmi.w	locret_C2E4
		addi.l	#$10000,obX(a0)
		moveq	#1,d0
		move.w	#$40,d1
		bra.s	loc_C294
; ===========================================================================

loc_C268:
		btst	#0,obStatus(a1)
		beq.s	locret_C2E4
		move.w	d0,-(sp)
		moveq	#0,d3
		move.b	obActWid(a0),d3
		not.w	d3
		jsr	ObjHitWallLeft
		move.w	(sp)+,d0
		tst.w	d1
		bmi.s	locret_C2E4
		subi.l	#$10000,obX(a0)
		moveq	#-1,d0
		move.w	#-$40,d1

loc_C294:
		lea	(v_player).w,a1
		add.w	d0,obX(a1)
		move.w	d1,obInertia(a1)
		move.w	#0,obVelX(a1)
		move.w	d0,-(sp)
		sfx	sfx_Push	 ; play pushing sound
		move.w	(sp)+,d0
		tst.b	obSubtype(a0)
		bmi.s	locret_C2E4
		move.w	d0,-(sp)
		jsr	ObjFloorDist
		move.w	(sp)+,d0
		cmpi.w	#4,d1
		ble.s	loc_C2E0
		move.w	#$400,obVelX(a0)
		tst.w	d0
		bpl.s	loc_C2D8
		neg.w	obVelX(a0)

loc_C2D8:
		move.b	#6,ob2ndRout(a0)
		bra.s	locret_C2E4
; ===========================================================================

loc_C2E0:
		add.w	d1,obY(a0)

locret_C2E4:
		rts	
