; ===========================================================================
; ----------------------------------------------------------------------------
; Object 40 - Teleporter
; ----------------------------------------------------------------------------
Teleporter:
		btst	#6,obRender(a0)	; is this a child sprite object?
		bne.w	@child			; if yes, branch
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Teleporter_Index(pc,d0.w),d1
		jsr	Teleporter_Index(pc,d1.w)
    
		obRange	@delete
		jmp	DisplaySprite
; ---------------------------------------------------------------------------
@delete:	; delete subsprite object
		movea.l	tele_child(a0),a1 	; a1=object
		beq.s	@delparent		; if none, branch
		jsr	DeleteChild
@delparent:
	if S3KObjectManager=1
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		movea.w	d0,a2				; load address into a2
		bclr	#7,(a2)				; clear respawn table entry, so object can be loaded again
	endif
		jsr	(LoadAnimalExplosion).l ; load animal patterns
		jmp	DeleteObject
; ===========================================================================
@child:	; child sprite objects only need to be drawn
		btst	#0,(v_framecount+1).w
		beq.w	@rts
		move.w	#$80,d0
		jmp	DisplaySprite3
@rts:
		rts
; ===========================================================================
; ===========================================================================
Teleporter_Index:	
		dc.w Teleporter_Init-Teleporter_Index	; 0
		dc.w Teleporter_Main-Teleporter_Index	; 2
		dc.w Tele_Beam_Spawn-Teleporter_Index	; 4
		dc.w Tele_Beam_Wait-Teleporter_Index	; 6
		dc.w Tele_Beam_Expand-Teleporter_Index	; 8
; ---------------------------------------------------------------------------

; ===========================================================================
Teleporter_Init:						; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Teleporter,obMap(a0)
		move.w	#VRAMloc_Teleporter/$20,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$1C,obActWid(a0)
		move.w	#$200,obPriority(a0)
		bset	#7,obStatus(a0)
		lea	(KosM_Teleporter).l,a1
		move.w	#VRAMloc_Teleporter,d2
		jsr	(Queue_Kos_Module).l

Teleporter_Main:						; Routine 2
		bsr.s	Tele_Solid
		tst.b	obSolid(a0)				; is Sonic on top of the teleporter?
		bne.s	CheckTele				; if Yes, branch
		rts

Tele_Solid:		
		lea	Tele_Height_Array(pc),a2
		lea	(v_player).w,a1 			; a1=character
		move.w	#$23,d1
		move.w	#$8,d2
		move.w	#$8,d3
		move.w	obX(a0),d4
		bsr.w	SolidObjectSlope
		rts
; ===========================================================================
Tele_Height_Array:	dc.b    9,   9,   9,   9,   9,   9,   9,   9,   9,   9,   9,   9,  $B,  $D,  $F, $11, $11, $11, $11, $11
		dc.b  $11,  $F,  $D,  $B,   9,   9,   9,   9,   9,   9,   9,   9,   9,   9,   9,   9
		even
; ===========================================================================
CheckTele:
		move.w	obY(a0),d0
		sub.w	obY(a1),d0
		sub.w	#$20,d0
		bcs.s	@dontteleport

		addq.b	#2,obRoutine(a0)
		jsr	FindNextFreeObj
		bne.s	@dontteleport
		move.l	a1,tele_child(a0)
		move.b	#id_Teleporter,(a1)
		;move.w	a0,parent2(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		ori.b	#4,obRender(a1)
		bset	#6,obRender(a1)                		; enable childsprites
		move.b	#-$80,mainspr_height(a1)
		move.b	#$18,mainspr_width(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.l	obMap(a0),obMap(a1)
		move.b	#1,mainspr_childsprites(a1)    		; number of sprites to draw
		move.w	obY(a0),tele_orig_y(a0)	
		subi.w	#$88,tele_orig_y(a0)
		move.b	#$10,tele_timer(a0)			; Wait 16 frames
		sfx	$53					; play teleport sound
	@dontteleport:
		rts

; ===========================================================================
tele_child = $30
tele_timer = $3A ;($47)
tele_last_sprite = $3B ;($46)
tele_orig_y = $3C ;($44)
; ===========================================================================

Tele_Beam_Spawn:						; Routine 4
		bsr.w	Tele_Solid
		tst.b	tele_timer(a0)
		beq.s	@timerdone
		subq.b	#1,tele_timer(a0)
		bra.s	@rts
@timerdone:
		btst	#0,(v_framecount+1).w
		beq.s	@rts					; Do a flickering effect
		movea.l	tele_child(a0),a1
		lea	sub2_x_pos(a1),a2			; Sprite attribute table to a1
		move.w	obY(a0),d0
		moveq	#0,d1
		move.b	mainspr_childsprites(a1),d1
		subq.b	#1,d1
@add_childsprite_loop:
		move.w	obX(a0),(a2)				; Same X coordinate for all sprites
		move.w	d0,2(a2)				; Different Y coordinate offset from base
		tst.b	d1
		bne.s	@loc_45960
		eori.b	#-1,tele_last_sprite(a0)		; If the last listed sprite
		beq.s	@loc_45954
		move.b	#1,5(a2)				; Use mapping 1 on the first frame
		bra.s	@loc_4596C
; ---------------------------------------------------------------------------
@loc_45954:
		move.b	#2,5(a2)				; Mapping 2 on the second frame + add new sprite
		addq.b	#1,mainspr_childsprites(a1)
		bra.s	@loc_4596C
; ---------------------------------------------------------------------------
@loc_45960:
		move.b	#2,5(a2)
		subi.w	#$20,d0
		addq.w	#6,a2
@loc_4596C:
		dbf	d1,@add_childsprite_loop
		cmpi.b	#7,mainspr_childsprites(a1)
		bcs.s	@rts
		tst.b	tele_last_sprite(a0)			; When seven sprites have been made, test $46
		bne.s	@rts
		addq.b	#2,obRoutine(a0)			; When last sprite uses mapping frame 2, go to next phase
		move.b	#$10,tele_timer(a0)
@rts:
		rts
; ===========================================================================

Tele_Beam_Wait:						; Routine 6
		bsr.w	Tele_Solid
		subq.b	#1,tele_timer(a0)
		beq.s	@timerover
		rts
; ---------------------------------------------------------------------------

@timerover:
		addq.b	#2,obRoutine(a0)
		movea.l	tele_child(a0),a1
		move.b	#2,mainspr_childsprites(a1)		; Use two large sprites for the beam
		move.b	#$48,tele_timer(a0)

; ===========================================================================

Tele_Beam_Expand:					; Routine 8
		bsr.w	Tele_Solid

		btst	#0,(v_framecount+1).w
		beq.w	locret_45A64
		movea.l	tele_child(a0),a1
		move.w	tele_orig_y(a0),d0
		move.w	d0,d1
		sub.w	(v_screenposy).w,d1
		cmpi.w	#$68,d1
		ble.s	loc_459D6
		move.w	(v_screenposy).w,d0
		addi.w	#$68,d0					; Ensure that object base Y is always centered or above the screen

loc_459D6:
		move.w	d0,obY(a1)
		move.w	obX(a1),d1
		moveq	#0,d2
		move.b	tele_last_sprite(a0),d2			; $46 should be 0 starting out
		move.w	d2,d3
		cmpi.w	#$12,d2					; Maximum of $12
		bcs.s	loc_459EE
		moveq	#$12,d2

loc_459EE:
		addq.w	#6,d2
		lsl.w	#3,d3
		lea	word_46734(pc),a3			; Use if in SSZ or HPZ

loc_45A0A:

		adda.w	d3,a3
		lea	sub2_x_pos(a1),a2
		move.w	d1,(a2)
		sub.w	d2,(a2)+
		move.w	(a3)+,(a2)
		add.w	d0,(a2)+
		move.w	(a3)+,(a2)+
		move.w	d1,(a2)
		add.w	d2,(a2)+
		move.w	(a3)+,(a2)
		add.w	d0,(a2)+
		move.w	(a3)+,(a2)+
		subq.b	#1,tele_timer(a0)
		bpl.s	loc_45A4A
		subq.b	#1,tele_last_sprite(a0)			; Contract beam
		bpl.s	loc_45A5E				; Branch if beam is still in effect
		move.b	#9,mainspr_mapframe(a1)			; Change main mapping
		clr.b	mainspr_childsprites(a1)		; No more sprites
		jsr	DeleteChild
		move.b	#2,obRoutine(a0)				; Set flag to parent indicating completion
		bra.s	loc_45A5E
; ---------------------------------------------------------------------------

loc_45A4A:
		btst	#1,(v_framecount+1).w
		beq.s	loc_45A5E
		cmpi.b	#$18,tele_last_sprite(a0)
		bcc.s	loc_45A5E
		addq.b	#1,tele_last_sprite(a0)				; Expand beam

loc_45A5E:

	;	jsr	(Draw_Sprite).l

locret_45A64:
		rts
; ---------------------------------------------------------------------------

; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
	include "_maps\Teleporter.asm"
	even
; ===========================================================================
word_46734:	dc.w  $FFFA,	 3,    $FFFA,	 4
		dc.w  $FFFA,	 3,    $FFFA,	 4
		dc.w  $FFFB,	 3,    $FFFB,	 4
		dc.w  $FFFC,	 3,    $FFFC,	 6
		dc.w  $FFFE,	 3,    $FFFE,	 6
		dc.w	  0,	 3,    	  0,	 6
		dc.w	  0,	 3,    	  0,	 6
		dc.w	  0,	 5,    	  0,	 6
		dc.w	  0,	 5,    0,	 6
		dc.w	  0,	 5,    0,	 6
		dc.w	  0,	 5,    0,	 6
		dc.w	  0,	 5,    0,	 8
		dc.w	  0,	 5,    0,	 8
		dc.w	  0,	 5,    0,	 8
		dc.w	  0,	 5,    0,	 8
		dc.w	  0,	 7,    0,	 8
		dc.w	  0,	 7,    0,	 8
		dc.w	  0,	 7,    0,	 8
		dc.w	  0,	 7,    0,	 8
		dc.w	  0,	 7,    0,	 8
		dc.w	  0,	 7,    0,	 8
		dc.w	  0,	 7,    0,	 8
		dc.w	  0,	 7,    0,	 8
		dc.w	  0,	 7,    0,	 8
		dc.w	  0,	 7,    0,	 8