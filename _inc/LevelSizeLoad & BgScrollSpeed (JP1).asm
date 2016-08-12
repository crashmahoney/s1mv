; ---------------------------------------------------------------------------
; Subroutine to	load level boundaries and start	locations
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevelSizeLoad:				; XREF: GM_Title; GM_Level; GM_Ending
		moveq	#0,d0
		move.b	d0,($FFFFF740).w
		move.b	d0,($FFFFF741).w
		move.b	d0,($FFFFF746).w
		move.b	d0,($FFFFF748).w
		move.b	d0,(v_dle_routine).w
		move.w	(v_zone).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		lea	LevelSizeArray(pc,d0.w),a0 ; load level	boundaries
		move.w	(a0)+,d0
		move.w	d0,($FFFFF730).w
		move.l	(a0)+,d0
		move.l	d0,(v_limitleft2).w
		move.l	d0,(v_limitleft1).w
		move.l	(a0)+,d0
		move.l	d0,(v_limittop2).w
		move.l	d0,(v_limittop1).w
		move.w	(v_limitleft2).w,d0
		addi.w	#$240,d0
		move.w	d0,(v_limitleft3).w
		move.w	#$1010,($FFFFF74A).w
		move.w	(a0)+,d0
		move.w	d0,(v_lookshift).w
		bra.w	LevSz_ChkLamp
; ===========================================================================
; ---------------------------------------------------------------------------
; Level size array and ending start location array
; ---------------------------------------------------------------------------
LevelSizeArray:	include	"misc\Level Size Array.asm"
		even

EndingStLocArray:
		incbin	"misc\Start Location Array - Ending.bin"
		even

; ===========================================================================

LevSz_ChkLamp:				; XREF: LevelSizeLoad
		tst.b	(v_lastlamp).w	; have any lampposts been hit?
		beq.s	LevSz_StartLoc	; if not, branch

		jsr	Lamp_LoadInfo
		move.w	(v_player+obX).w,d1
		move.w	(v_player+obY).w,d0
		bra.s	LevSz_SkipStartPos
; ===========================================================================

LevSz_StartLoc:
		move.w	(v_zone).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea	StartLocArray(pc,d0.w),a1 ; load Sonic's start location
		tst.w	(f_demo).w	; is ending demo mode on?
		bpl.s	LevSz_SonicPos	; if not, branch

		move.w	(v_creditsnum).w,d0
		subq.w	#1,d0
		lsl.w	#2,d0
		lea	EndingStLocArray(pc,d0.w),a1 ; load Sonic's start location

LevSz_SonicPos:
		moveq	#0,d1
		move.w	(a1)+,d1
		move.w	d1,(v_player+obX).w ; set Sonic's position on x-axis
		moveq	#0,d0
		move.w	(a1),d0
		move.w	d0,(v_player+obY).w ; set Sonic's position on y-axis

SetScreen:
; ===========================================================================
	clr.w	(v_trackpos).w		; reset Sonic's position tracking index          This will fix the issue which causes
                                                                                   ;     weird camera movements if the player performs
	lea	(v_tracksonic).w,a2	; load the tracking array into a2                a Spin Dash at the very beginning of a level 
	moveq	#63,d2				; begin a 64-step loop                   since the camera will try to follow bad data
@looppoint:                                                                        ;     from the array of Sonic's previous positions.
	move.w	d1,(a2)+			; fill in X                              This code therefore clears the aforementioned
	move.w	d0,(a2)+			; fill in Y                              array.
	dbf	d2,@looppoint		; loop
; ===========================================================================
 	LevSz_SkipStartPos:
		subi.w	#160,d1		; is Sonic more than 160px from left edge?
		bcc.s	SetScr_WithinLeft ; if yes, branch
		moveq	#0,d1

	SetScr_WithinLeft:
		move.w	(v_limitright2).w,d2
		cmp.w	d2,d1		; is Sonic inside the right edge?
		bcs.s	SetScr_WithinRight ; if yes, branch
		move.w	d2,d1

	SetScr_WithinRight:
		move.w	d1,(v_screenposx).w ; set horizontal screen position

		subi.w	#96,d0		; is Sonic within 96px of upper edge?
		bcc.s	SetScr_WithinTop ; if yes, branch
		moveq	#0,d0

	SetScr_WithinTop:
		cmp.w	(v_limitbtm2).w,d0 ; is Sonic above the bottom edge?
		blt.s	SetScr_WithinBottom ; if yes, branch
		move.w	(v_limitbtm2).w,d0

	SetScr_WithinBottom:
		move.w	d0,(v_screenposy).w ; set vertical screen position
		bsr.w	BgScrollSpeed
;		moveq	#0,d0
;		move.b	(v_zone).w,d0
;		lsl.b	#2,d0
;		lea		LoopTileNums,a0
;		move.l	(a0,d0.w),(v_256loop1).w      ;
		move.w	#0000,(v_limitleft2).w ; +++ move left boundary to far left, this is a hack because the limit was in the wrong place when transitioning between acts from the top or bottom
        rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic	start location array
; ---------------------------------------------------------------------------
StartLocArray:	incbin	"misc\Start Location Array - Levels.bin"
		even
; ---------------------------------------------------------------------------
; Which	256x256	tiles contain loops or roll-tunnels
; ---------------------------------------------------------------------------

LoopTileNums:

; 		loop	loop	tunnel	tunnel

	dc.b	$7F,	$7F,	$7F,	$7F	; Green Hill
	dc.b	$7F,	$7F,	$7F,	$7F	; Labyrinth
	dc.b	$7F,	$7F,	$7F,	$7F	; Marble
	dc.b	$AA,	$B4,	$7F,	$7F	; Star Light
	dc.b	$7F,	$7F,	$7F,	$7F	; Spring Yard
	dc.b	$7F,	$7F,	$7F,	$7F	; Scrap Brain
	dc.b	$7F,	$7F,	$7F,	$7F	; Ending (Green Hill)
	dc.b	$7F,	$7F,	$7F,	$7F	; Hub
	dc.b	$7F,	$7F,	$7F,	$7F	; Intro
	dc.b	$7F,	$7F,	$7F,	$7F	; Tropic

		even

; ---------------------------------------------------------------------------
; Subroutine to	set scroll speed of some backgrounds
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BgScrollSpeed:				; XREF: LevelSizeLoad
		tst.b	(v_lastlamp).w
		bne.s	loc_6206
		move.w	d0,($FFFFF70C).w
		move.w	d0,($FFFFF714).w
		move.w	d1,($FFFFF708).w
		move.w	d1,($FFFFF710).w
		move.w	d1,($FFFFF718).w

loc_6206:
		moveq	#0,d2
		move.b	(v_zone).w,d2
		add.w	d2,d2
		move.w	BgScroll_Index(pc,d2.w),d2
		jmp	BgScroll_Index(pc,d2.w)
; End of function BgScrollSpeed

; ===========================================================================
BgScroll_Index:	dc.w BgScroll_GHZ-BgScroll_Index, BgScroll_LZ-BgScroll_Index
		dc.w BgScroll_MZ-BgScroll_Index, BgScroll_SLZ-BgScroll_Index
		dc.w BgScroll_SYZ-BgScroll_Index, BgScroll_SBZ-BgScroll_Index
		dc.w BgScroll_End-BgScroll_Index, BgScroll_HUBZ-BgScroll_Index
		dc.w BgScroll_IntroZ-BgScroll_Index, BgScroll_Tropic-BgScroll_Index
; ===========================================================================

BgScroll_GHZ:				; XREF: BgScroll_Index
		clr.l	($FFFFF708).w
		clr.l	($FFFFF70C).w
		clr.l	($FFFFF714).w
		clr.l	($FFFFF71C).w
		lea	($FFFFA800).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		rts
; ===========================================================================

BgScroll_LZ:				; XREF: BgScroll_Index
; 		asr.l	#1,d0
; 		move.w	d0,($FFFFF70C).w
; 		rts	
		clr.l	($FFFFF708).w
		clr.l	($FFFFF70C).w
		clr.l	($FFFFF714).w
		clr.l	($FFFFF71C).w
		lea	($FFFFA800).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		rts
; ===========================================================================

BgScroll_MZ:				; XREF: BgScroll_Index
		move.w	#$80,($FFFFF708).w		; force X position to 2nd chunk's position (So redraw always occurs at beginning correctly...)
		asr.w	#$03,d0					; divide by 8
		move.w	d0,($FFFFF70C).w		; save as BG Y position
		rts	
; ===========================================================================

BgScroll_SLZ:				; XREF: BgScroll_Index
		asr.l	#1,d0
		addi.w	#$C0,d0
		move.w	d0,($FFFFF70C).w
		clr.l	($FFFFF708).w
		rts	
; ===========================================================================

BgScroll_SYZ:				; XREF: BgScroll_Index
		asl.l	#4,d0
		move.l	d0,d2
		asl.l	#1,d0
		add.l	d2,d0
		asr.l	#8,d0
		addq.w	#1,d0
		move.w	d0,($FFFFF70C).w
		clr.l	($FFFFF708).w
		rts	
; ===========================================================================

BgScroll_SBZ:				; XREF: BgScroll_Index
		andi.w	#$7F8,d0
		asr.w	#3,d0
		addq.w	#1,d0
		move.w	d0,($FFFFF70C).w
		rts
; ===========================================================================

BgScroll_End:				; XREF: BgScroll_Index
		move.w	(v_screenposx).w,d0
		asr.w	#1,d0
		move.w	d0,($FFFFF708).w
		move.w	d0,($FFFFF710).w
		asr.w	#2,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		move.w	d0,($FFFFF718).w
		clr.l	($FFFFF70C).w
		clr.l	($FFFFF714).w
		clr.l	($FFFFF71C).w
		lea	($FFFFA800).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		rts
; ===========================================================================

BgScroll_HUBZ:				; XREF: BgScroll_Index
		clr.l	($FFFFF708).w
		clr.l	($FFFFF70C).w
		clr.l	($FFFFF714).w
		clr.l	($FFFFF71C).w
		lea	($FFFFA800).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
; 		asr.l	#1,d0
; 		move.w	d0,($FFFFF70C).w
		rts
; ===========================================================================

BgScroll_IntroZ:				; XREF: BgScroll_Index
; 		asr.l	#1,d0
; 		move.w	d0,($FFFFF70C).w
		rts
; ===========================================================================
BgScroll_Tropic:				; XREF: BgScroll_Index
		clr.l	($FFFFF708).w
		clr.l	($FFFFF70C).w
		clr.l	($FFFFF714).w
		clr.l	($FFFFF71C).w
		lea	($FFFFA800).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		rts
