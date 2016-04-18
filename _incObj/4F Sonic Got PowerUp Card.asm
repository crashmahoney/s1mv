; ---------------------------------------------------------------------------
; Object 4F - SONIC GOT POWERUP card
; ---------------------------------------------------------------------------
GotPowUpCard:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	GotPowUp_Index(pc,d0.w),d1
		jmp	GotPowUp_Index(pc,d1.w)
; ===========================================================================
GotPowUp_Index:	dc.w GotPowUp_ChkPLC-GotPowUp_Index         ;0
		dc.w GotPowUp_ChkPos-GotPowUp_Index           ;2
		dc.w GotPowUp_Wait-GotPowUp_Index           ;4
		dc.w GotPowUp_Move2-GotPowUp_Index          ;6

gotPowUp_mainX:	= $30		; position for card to display on
gotPowUp_finalX:= $32		; position for card to finish on
powup_bgtilesize= $34
; ===========================================================================

GotPowUp_ChkPLC:	; Routine 0
		tst.l	(v_plc_buffer).w ; are the pattern load cues empty?
		beq.s	GotPowUp_Main	; if yes, branch
		move.b	#$1A,(v_vbla_routine).w       		; vblank routune without loadtilesasyoumove         
		jsr	WaitForVBla

; ===========================================================================

GotPowUp_Main:
                writeVRAM Art_BigFont, $1000, $B000
; --------------------------------------------------------------------------
; Draw tilemap
                move.w  #5,d4
                lea     PowerupTilemap1,a1
                bsr.w   DrawStrip
                move.w  #6,d4
                lea     PowerupTilemap2,a1
                bsr.w   DrawStrip
                move.w  #7,d4
                lea     PowerupTilemap2,a1
                bsr.w   DrawStrip
                move.w  #8,d4
                lea     PowerupTilemap2,a1
                bsr.w   DrawStrip
                move.w  #9,d4
                lea     PowerupTilemap2,a1
                bsr.w   DrawStrip
                move.w  #10,d4
                lea     PowerupTilemap2,a1
                bsr.w   DrawStrip
                move.w  #11,d4
                lea     PowerupTilemap1,a1
                bsr.w   DrawStrip

                move.w  #19,d4                            ; draw lower description rows
                lea     PowerupTilemap2,a1
                bsr.w   DrawStrip
                move.w  #20,d4
                lea     PowerupTilemap2,a1
                bsr.w   DrawStrip
                move.w  #21,d4
                lea     PowerupTilemap2,a1
                bsr.w   DrawStrip

; --------------------------------------------------------------------------
		movea.l	a0,a1
		lea	(GotPowUp_Config).l,a2
		moveq	#2,d1         ; +++ was 6     the number of items to move (0=sonic got, 1=powerup name 2=oval)

GotPowUp_Loop:
		move.b	#id_GotPowUpCard,0(a1)
		move.w	(a2),obX(a1)	; load start x-position
		move.w	(a2)+,gotPowUp_finalX(a1) ; load finish x-position (same as start)
		move.w	(a2)+,gotPowUp_mainX(a1) ; load main x-position
		move.w	(a2)+,obScreenY(a1) ; load y-position
                move.w  (v_screenposy).w,d0
 	        andi.w	#$7,d0               ; round down
		neg.w	d0
		addi.w	#$8,d0
; 	        asl.w   #2,d0                ; double because table is stored as planes a,b,a,b,etc
;                add.w   #$80,d0              ; how far down the screen to start scrolling  (4 more tile rows * 8px per row * 2 because of the two planes)
                add.w   d0,obScreenY(a1)
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,d0
		
                cmpi.b	#0,d0    		; is this object "sonic got"
		beq.s	GotPowUp_MakeSprite	; if so, branch
		add.b	obSubtype(a0),d0	; add to frame number

	GotPowUp_MakeSprite:
		move.b	d0,obFrame(a1)
		move.l	#Map_PowerUpCard,obMap(a1)
		move.w	#$8580,obGfx(a1)
		move.b	#$78,obActWid(a1)
		move.b	#0,obRender(a1)
		move.w	#0,obPriority(a1)                   ;+++
		move.w	#120,obTimeFrame(a1) ; set time delay to 2 seconds  +++
		lea	$40(a1),a1
		dbf	d1,GotPowUp_Loop	; repeat 2 more times

; --------------------------------------------------------------------------
GotPowUp_ChkPos:	; Routine 2
		moveq	#$10,d1		; set horizontal speed
		move.w	gotPowUp_mainX(a0),d0
		cmp.w	obX(a0),d0	; has item reached its target position?
		beq.s	loc_PowUpC610 ;loc_PowUpC61A	; if yes, branch
		bge.s	GotPowUp_Move
		neg.w	d1

	GotPowUp_Move:
		add.w	d1,obX(a0)	; change item's position

	GotPowUp_NoMove:			; XREF: loc_PowUpC61A
		move.w	obX(a0),d0
		bmi.s	locret_PowUpC60E
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bcc.s	locret_PowUpC60E	; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

locret_PowUpC60E:

                rts

; ===========================================================================

loc_PowUpC610:				; XREF: loc_PowUpC61A
		move.b	#4,obRoutine(a0)
		bra.w	GotPowUp_Wait
;  ===========================================================================

GotPowUp_Wait:	; Routine 4
		tst.w	obTimeFrame(a0)	; is time remaining zero?
		bne.w	@countdown	; if no, branch
                move.b  (v_jpadpress1).w, d1
                andi.b  #btnABCStart,d1      ; is a button pressed?
                beq.s   @displaysprite  ; if not, wait for button press
                addq.b  #2,obRoutine(a0)
		bra.s   GotPowUp_Move2
	@countdown:
		subq.w	#1,obTimeFrame(a0) ; subtract 1 from time delay
;                 btst.b  #0,(v_framecount+1).w  ; check if frame is even
;                 beq.s   @displaysprite       ; if so, branch
;                 cmpi.b	#0,obFrame(a0)
; 		bne.s   @not0
;                 add.w	#1,obX(a0)	; add to x-position
;                 bra.s   @displaysprite
;          @not0:
;                 cmpi.b	#1,obFrame(a0)
; 		bne.s   @displaysprite
;                 sub.w	#1,obX(a0)	; add to x-position
          @displaysprite:
		bra.w	DisplaySprite
; ===========================================================================

GotPowUp_Move2:	; Routine 6
                moveq	#$20,d1		; set horizontal speed
		move.w	gotPowUp_finalX(a0),d0
		cmp.w	obX(a0),d0	; has item reached its finish position?
		beq.s	GotPowUp_Delete ; if yes, branch
		bge.s	GotPowUp_ChgPos2
		neg.w	d1

	GotPowUp_ChgPos2:
		add.w	d1,obX(a0)	; change item's position
		move.w	obX(a0),d0
		bmi.s	locret_PowUpC748
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bcc.s	locret_PowUpC748	; if yes, branch
		bra.w	DisplaySprite
		rts
; ===========================================================================

locret_PowUpC748:
               	bsr.s	GotPowUp_Delete
		rts
; ===========================================================================


GotPowUp_Delete:
		clr.b	(f_lockctrl).w	; unlock controls
                bsr.w	DeleteObject
FindCardObj:                                  ; check to see if the card is left onscreen
		lea	(v_objspace).w,a1 ; start address for object RAM
		move.w	#$80,d0

	FCard_Loop:
		cmpi.b	#$4F,(a1)	; is object got through card
		beq.s	dontloadgfx	        ; if yes, branch
        @continue:
                lea	$40(a1),a1	; goto next object RAM slot
		dbf	d0,FCard_Loop	; repeat $80 times
GotPowUp_ChangeArt:
		jsr	(LoadAnimalExplosion).l ; load animal patterns
		move.w	#$2700,sr
		jsr     LoadTilesFromStart
		move.w	#$2300,sr

dontloadgfx:
                rts
; ===========================================================================
GotPowUp_Config:dc.w 0,	$110, $B2	; x-start, x-main, y-main                     ;sonic got
		dc.b 2,	0		; routine number, frame	number (changes)
		dc.w $210, $130, $C6                                                 ; powerup name
		dc.b 2,	1
		dc.w $210, $120, $11C                                                  ; instruction text
		dc.b 2,	$1B
; --------------------------------------------------------------------------
DrawStrip:
; Draw strip across screen
; calculate start vram location		
;               move.l	#$40000000+((loc&$3FFF)<<16)+((loc&$C000)>>14),d0
 		move.l	#$40000000,d0
                moveq   #0,d2
                move.w  (v_screenposy).w,d2
	        andi.w	#$FF,d2              ; get last byte of screen pos
	        asr.w   #3,d2                ; divide by 8 to get number of tiles the screen is from the top of plane
	        add.w   d4,d2                ; add number of tiles from top of screen to start drawing from
	        asl.w   #6,d2                ; multiply by number of tiles in a row (64)
	        asl.w   #1,d2                ; multiply by 2 to get tiles in words
	        and.w   #$FFF,d2              ; make sure it doesn't go past the end of the nametable
	        add.w   #$C000,d2            ; add A plane vram start location
	        move.l  d2,d3
         ; (loc&$3FFF)<<16)
 		and.w   #$3FFF,d2
 		asl.l   #8,d2
 		asl.l   #8,d2
 		add.l   d2,d0
 	; (loc&$C000)>>14)
 		and.w   #$C000,d3
 		asr.l   #8,d3
 		asr.l   #6,d3
 		add.l   d3,d0
 		
		lea	($C00000).l,a6
		move.l	#$800000,d4

	@Tilemap_Line:
		move.l	d0,4(a6)
		move.w	#63,d3

	@Tilemap_Cell:
		move.w	(a1)+,(a6)	; write value to namespace

		dbf	d3,@Tilemap_Cell
                rts
; --------------------------------------------------------------------------
PowerupTilemap1:dc.w $A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9
                dc.w $A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9
                dc.w $A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9
                dc.w $A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9,$A5F9,$BDF9
PowerupTilemap2:dc.w $A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB
                dc.w $A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB
                dc.w $A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB
                dc.w $A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB,$A5FB
                even
; copyTilemap:	macro source,loc,width,height
; 		lea	(source).l,a1
; 		move.l	#$40000000+((loc&$3FFF)<<16)+((loc&$A000)>>14),d0
; 		moveq	#width,d1
; 		moveq	#height,d2
; 		bsr.w	TilemapToVRAM
; 		endm


		include "_maps/PowerUp Card.asm"
		even