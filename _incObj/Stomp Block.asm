; ---------------------------------------------------------------------------
; Object 51 - smashable	green block (MZ)
; ---------------------------------------------------------------------------

StompBlock:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	StompB_Index(pc,d0.w),d1
		jsr	StompB_Index(pc,d1.w)
		bra.w	RememberState
; ===========================================================================
StompB_Index:	dc.w StompB_Main-StompB_Index
		dc.w StompB_Solid-StompB_Index
		dc.w StompB_Points-StompB_Index
; ===========================================================================

StompB_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
        	move.l	#Map_StompBlock,obMap(a0)
		move.w	#$2000+(VRAMloc_StompBlock/$20),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.w	#$200,obPriority(a0) 

StompB_Solid:	; Routine 2


@sonic:		= $32		; Sonic's current animation number
@count:		= $34		; number of blocks hit + previous stuff
@yspeed		= $36		; remember sonic's y speed
@flashtimer:	= $38		;


		tst.w	@flashtimer(a0)			; is timer running?
		beq.s	@noflash			; if not, branch
		sub.w	#1,@flashtimer(a0)		; sub 1 from timer
		bchg	#5,obGfx(a0)			; toggle palette bit 1

	@noflash:
		move.w	(v_itembonus).w,@count(a0)
		move.b	(v_player+obAnim).w,@sonic(a0) ; load Sonic's animation number
		move.w	(v_player+obVelY).w,@yspeed(a0); remember sonic's y speed

		moveq	#$1B,d1
		moveq	#$10,d2
		moveq	#$11,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		btst	#3,obStatus(a0)	; has Sonic landed on the block?
		bne.s	@smash		; if yes, branch

	@notstomping:
		rts	
; ===========================================================================

@smash:
		tst.w	@flashtimer(a0)		; is block already flashing?
		bne.s	@notstomping		; if so, branch
		cmpi.b	#id_Roll,@sonic(a0) 	; is Sonic spinning?
		bne.s	@chk_stomp		; if not, branch
		move.w	#16,@flashtimer(a0)
		bra.s	@notstomping

	@chk_stomp:
		cmpi.b	#id_stomp,@sonic(a0) 	; is Sonic stomping?
		bne.s	@notstomping		; if not, branch
		add.w	#2,(v_shakeamount).w
		add.b	#1,(v_shaketime).w
		move.w	@count(a0),(v_itembonus).w
		move.w	@yspeed(a0),(v_player+obVelY).w
		move.b	#id_stomp,(v_player+obAnim).w

		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#2,obRoutine(a1)
		bclr	#3,obStatus(a0)
		clr.b	obSolid(a0)
		move.b	#1,obFrame(a0)
		lea	(StompB_Speeds).l,a4 ; load broken fragment speed data
		moveq	#1,d1		; set number of	fragments to 2
		move.w	#$38,d2
		bsr.w	SmashObject
		bsr.w	FindFreeObj
		bne.s	StompB_Points
		move.b	#id_Points,0(a1) ; load points object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	(v_itembonus).w,d2
		addq.w	#2,(v_itembonus).w ; increment bonus counter
		cmpi.w	#6,d2		; have fewer than 3 blocks broken?
		bcs.s	@bonus		; if yes, branch
		moveq	#6,d2		; set cap for points

	@bonus:
		moveq	#0,d0
		move.w	StompB_Scores(pc,d2.w),d0
		cmpi.w	#$20,(v_itembonus).w ; have 16 blocks been smashed?
		bcs.s	@givepoints	; if not, branch
		move.w	#1000,d0	; give higher points for 16th block
		moveq	#10,d2

	@givepoints:
		jsr	AddPoints
		lsr.w	#1,d2
		move.b	d2,obFrame(a1)

StompB_Points:	; Routine 4
		bsr.w	SpeedToPos
		addi.w	#$38,obVelY(a0)
		bsr.w	DisplaySprite
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		rts	
; ===========================================================================
StompB_Speeds:	dc.w -$200, -$200	; x-speed, y-speed
		dc.w $200, -$200

StompB_Scores:	dc.w 10, 20, 50, 100

		include	"_maps\Stomp Block.asm"
		even