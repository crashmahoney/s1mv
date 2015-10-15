; ---------------------------------------------------------------------------
; Object 15 - swinging platforms (GHZ, MZ, SLZ)
;	    - spiked ball on a chain (SBZ)
; ---------------------------------------------------------------------------

SwingingPlatform:			; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Swing_Index(pc,d0.w),d1
		jmp	Swing_Index(pc,d1.w)
; ===========================================================================
Swing_Index:	dc.w Swing_Main-Swing_Index, Swing_SetSolid-Swing_Index
		dc.w Swing_Action2-Swing_Index,	Swing_Delete-Swing_Index
		dc.w Swing_Delete-Swing_Index, Swing_Display-Swing_Index
		dc.w Swing_Action-Swing_Index

origX:		= $3A		; original x-axis position
origY:		= $38		; original y-axis position
; ===========================================================================

Swing_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Swing_GHZ,obMap(a0) ; GHZ and MZ specific code
		move.w	#VRAMloc_Swing/$20,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$180,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#8,obWidth(a0)
; 		move.w	obY(a0),origY(a0)
; 		move.w	obX(a0),origX(a0)
; 		cmpi.b	#id_SLZ,(v_zone).w ; check if level is SLZ
; 		bne.s	@notSLZ
                move.w	obY(a0),origY(a0)      ; +++ zone agnostic objects
		move.w	obX(a0),origX(a0)
 
		cmpi.b	#id_LZ,(v_zone).w
		bne.s	@notLZ
		move.w	#$4310,obGfx(a0)
		move.l	#Map_Swing_LZ,obMap(a0)
		move.b	#$10,obActWid(a0)
 
	@notLZ:
		cmpi.b	#id_SLZ,(v_zone).w ; check if level is SLZ
		bne.s	@notSLZ

		move.l	#Map_Swing_SLZ,obMap(a0) ; SLZ specific code
		move.w	#$43DC,obGfx(a0)
		move.b	#$20,obActWid(a0)
		move.b	#$10,obWidth(a0)
		move.b	#$99,obColType(a0)

	@notSLZ:
		cmpi.b	#id_SBZ,(v_zone).w ; check if level is SBZ
		bne.s	@length

		move.l	#Map_BBall,obMap(a0) ; SBZ specific code
		move.w	#$391,obGfx(a0)
		move.b	#$18,obActWid(a0)
		move.b	#$18,obWidth(a0)
		move.b	#$86,obColType(a0)
		move.b	#$C,obRoutine(a0) ; goto Swing_Action next

@length:
		move.b	0(a0),d4         ; copy object number do d4 ($15)
		moveq	#0,d1
		lea	obSubtype(a0),a2 ; subtype byte is equal to chain length
		move.b	(a2),d1		 ; copy subtype to d1
		move.w	d1,-(sp)         ; put subtype on stack
		andi.w	#$F,d1           ; make sure chain length is 15 or less
		move.b	#0,(a2)+         ; set subtype to 0 and increment a2 into scratch ram
		move.w	d1,d3            ; copy chain length
		lsl.w	#4,d3            ; multiply length by 16(diameter of chain piece in pixels)
		addq.b	#8,d3            ; raise platform position by 8 pixels
		move.b	d3,$3C(a0)       ; copy result into scratch ram
		subq.b	#8,d3            ; reset position
		tst.b	obFrame(a0)
		beq.s	@makechain       ; if frame is 0 (the platform), then create chain
		addq.b	#8,d3            ; add 8
		subq.w	#1,d1            ; sub 1 from chain length to give correct loop amount

@makechain:
		bsr.w	FindFreeObj
		bne.s	@fail
		addq.b	#1,obSubtype(a0) ; subtype is number of pieces created
		move.w	a1,d5            ; set d5 to the ram address of the free object
		subi.w	#$D000,d5
		lsr.w	#6,d5            ; divide by $40
		andi.w	#$7F,d5
		move.b	d5,(a2)+         ; put new chain link's object slot into a list in main object's ram
		move.b	#$A,obRoutine(a1) ; new link to goto Swing_Display next
		move.b	d4,0(a1)	 ; load link object
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		bclr	#6,obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#$200,obPriority(a1)
		move.b	#8,obActWid(a1)
		move.b	#1,obFrame(a1)     ; set frame to link
		move.b	d3,$3C(a1)         ; set link's distance from platform
		subi.b	#$10,d3            ; get distance of next link
		bcc.s	@notanchor         ; if not less than 0, leave graphics as a chain link
		move.b	#2,obFrame(a1)
		move.w	#$180,obPriority(a1)
	;	bset	#6,obGfx(a1)
    ;    cmpi.b	#id_LZ,(v_zone).w      ; +++ zone agnostic objects
	;	beq.s	@notanchor             ;
	;	bset	#6,obGfx(a1)           ;
	@notanchor:
		dbf	d1,@makechain ; repeat d1 times (chain length)

	@fail:
		move.w	a0,d5
		subi.w	#$D000,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.w	#$4080,obAngle(a0)
		move.w	#-$200,$3E(a0)
		move.w	(sp)+,d1
		btst	#4,d1		; is object type $8X ?
		beq.s	@not8X	; if not, branch
		move.l	#Map_GBall,obMap(a0) ; use GHZ ball mappings
		move.w	#$43AA,obGfx(a0)
		move.b	#1,obFrame(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$81,obColType(a0) ; make object hurt when touched

	@not8X:
		cmpi.b	#id_SBZ,(v_zone).w ; is zone SBZ?
		beq.s	Swing_Action	; if yes, branch

Swing_SetSolid:	; Routine 2
		moveq	#0,d1
		move.b	obActWid(a0),d1
		moveq	#0,d3
		move.b	obWidth(a0),d3
		bsr.w	Swing_Solid

Swing_Action:	; Routine $C
		bsr.w	Swing_Move
		bsr.w	DisplaySprite
		bra.w	Swing_ChkDel
; ===========================================================================

Swing_Action2:	; Routine 4
		moveq	#0,d1
		move.b	obActWid(a0),d1
		bsr.w	ExitPlatform
		move.w	obX(a0),-(sp)
		bsr.w	Swing_Move
		move.w	(sp)+,d2
		moveq	#0,d3
		move.b	obWidth(a0),d3
		addq.b	#1,d3
		bsr.w	MvSonicOnPtfm
		bsr.w	DisplaySprite
		bra.w	Swing_ChkDel

		rts
