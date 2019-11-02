; ---------------------------------------------------------------------------
; Subroutine to	update the HUD
; ---------------------------------------------------------------------------
rings_loc   =  $DE00
icons_loc   =  $DA80
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HUD_Update:
		tst.w	(f_debugmode).w	; is debug mode	on?
		bne.w	HudDebug	; if yes, branch
; ---------------------------------------------------------------------------
		lea	($C00000).l,a6			; vdp data port
		tst.b	(v_minimap_update).w
		beq.w	@chkscore
		locVRAM	$DC00
		lea	(v_minimap_buffer).l,a3 
		moveq	#3,d1				; number of 8x8 tiles to transfer
	@transfercolumn:
		movea.l	a3,a1
	rept 8*4
		move.l	(a1),(a6)
		lea	16(a1),a1						
	endr
		lea	4(a3),a3
		dbf	d1,@transfercolumn
		clr.b	(v_minimap_update).w		; clear update flag 
; ---------------------------------------------------------------------------

	@chkscore:
		tst.b	(f_scorecount).w ; does the score need updating?
		beq.s	@chkrings	; if not, branch
; 		clr.b	(f_scorecount).w
; 		move.l	#$5C800003,d0	; set VRAM address
; 		move.l	(v_score).w,d1	; load score
		bsr.w	Hud_Icons

	@chkrings:
		tst.b	(f_ringcount).w	; does the ring	counter	need updating?
		beq.s	Hud_ChkTime	; if not, branch
		bpl.s	loc_1C6E4
		bsr.w	Hud_LoadZero

loc_1C6E4:
		clr.b	(f_ringcount).w
		move.l	#($40000000+((rings_loc&$3FFF)<<16)+((rings_loc&$C000)>>14)),d0
		moveq	#0,d1
		move.w	(v_rings).w,d1	; load number of rings
		bsr.w	Hud_Rings

Hud_ChkTime:
		tst.b	(f_timecount).w	; does the time	need updating?
		beq.s	Hud_ChkLives	; if not, branch
		tst.w	(f_pause).w	; is the game paused?
		bne.s	Hud_ChkLives	; if yes, branch
		lea	(v_time).w,a1
		cmpi.l	#$93B3B,(a1)+	; is the time 9.59?
;		beq.s	TimeOver	; if yes, branch                   ; don't time over
		addq.b	#1,-(a1)        ; add 1 to centiseconds
		cmpi.b	#60,(a1)
		bcs.s	Hud_ChkLives
		move.b	#0,(a1)         ; reset centiseconds
		addq.b	#1,-(a1)        ; add 1 to seconds
		cmpi.b	#60,(a1)
		bcs.s	loc_1C734
		move.b	#0,(a1)         ; reset seconds
		addq.b	#1,-(a1)        ; add 1 to minutes
		cmpi.b	#60,(a1)
		bcs.s	loc_1C734
		move.b	#0,(a1)         ; reset minutes
		addq.b	#1,-(a1)        ; add 1 to hours
		cmpi.b	#99,(a1)        ; 99 hours?
		bcs.s	loc_1C734
		move.b	#9,(a1)

loc_1C734:
; 		move.l	#$5E400003,d0
; 		moveq	#0,d1
; 		move.b	(v_timemin).w,d1 ; load	minutes
; 		bsr.w	Hud_Mins
; 		move.l	#$5EC00003,d0
; 		moveq	#0,d1
; 		move.b	(v_timesec).w,d1 ; load	seconds
; 		bsr.w	Hud_Secs

Hud_ChkLives:
; 		tst.b	(f_lifecount).w ; does the lives counter need updating?
; 		beq.s	Hud_ChkBonus	; if not, branch
; 		clr.b	(f_lifecount).w
; 		bsr.w	Hud_Lives
; 
; Hud_ChkBonus:
; 		tst.b	(f_endactbonus).w ; do time/ring bonus counters need updating?
; 		beq.s	Hud_End		; if not, branch
; 		clr.b	(f_endactbonus).w
; 		locVRAM	$AE00
; 		moveq	#0,d1
; 		move.w	(v_timebonus).w,d1 ; load time bonus
; 		bsr.w	Hud_TimeRingBonus
; 		moveq	#0,d1
; 		move.w	(v_ringbonus).w,d1 ; load ring bonus
; 		bsr.w	Hud_TimeRingBonus

Hud_End:
		rts	
; ===========================================================================

TimeOver:				; XREF: Hud_ChkTime
		clr.b	(f_timecount).w
		lea	(v_objspace).w,a0
		movea.l	a0,a2
		bsr.w	KillSonic
		move.b	#1,(f_timeover).w
		rts	
; ===========================================================================

HudDebug:				; XREF: HUD_Update
		bsr.w	HudDb_XY
		bsr.w	Hud_LoadZero

HudDb_Rings:
		clr.b	(f_ringcount).w
		move.l	#($40000000+((rings_loc&$3FFF)<<16)+((rings_loc&$C000)>>14)),d0
		moveq	#0,d1
		move.b	(v_spritecount).w,d1 ; load "number of objects" counter
		bsr.w	Hud_Rings

HudDb_ObjCount:
; 		move.l	#$5EC00003,d0	; set VRAM address
; 		moveq	#0,d1
; 		move.b	(v_spritecount).w,d1 ; load "number of objects" counter
; 		bsr.w	Hud_Secs
; 		tst.b	(f_lifecount).w ; does the lives counter need updating?
; 		beq.s	HudDb_ChkBonus	; if not, branch
; 		clr.b	(f_lifecount).w
; 		bsr.w	Hud_Lives

HudDb_ChkBonus:
; 		tst.b	(f_endactbonus).w ; does the ring/time bonus counter need updating?
; 		beq.s	HudDb_End	; if not, branch
; 		clr.b	(f_endactbonus).w
; 		locVRAM	$AE00		; set VRAM address
; 		moveq	#0,d1
; 		move.w	(v_timebonus).w,d1 ; load time bonus
; 		bsr.w	Hud_TimeRingBonus
; 		moveq	#0,d1
; 		move.w	(v_ringbonus).w,d1 ; load ring bonus
; 		bsr.w	Hud_TimeRingBonus

HudDb_End:
		rts	
; End of function HUD_Update

; ---------------------------------------------------------------------------
; Subroutine to	load "0" on the	HUD
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Base:				; XREF: GM_Level; SS_EndLoop; GM_Ending
Hud_LoadZero:				; XREF: HUD_Update
		lea	($C00000).l,a6
		locVRAM	rings_loc
		lea	Hud_TilesZero(pc),a2
		move.w	#2,d2
		bra.s	loc_1C83E
; End of function Hud_LoadZero

; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed HUD patterns ("E", "0", colon)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

;Hud_Base:	; old hud version			; XREF: GM_Level; SS_EndLoop; GM_Ending
		lea	($C00000).l,a6
		bsr.w	Hud_Lives
		locVRAM	$DCC0
		lea	Hud_TilesBase(pc),a2
		move.w	#$E,d2

loc_1C83E:				; XREF: Hud_LoadZero
		lea	Art_Hud(pc),a1

loc_1C842:
		move.w	#$F,d1
		move.b	(a2)+,d0
		bmi.s	loc_1C85E
		ext.w	d0
		lsl.w	#5,d0
		lea	(a1,d0.w),a3

loc_1C852:
		move.l	(a3)+,(a6)
		dbf	d1,loc_1C852

loc_1C858:
		dbf	d2,loc_1C842

		rts	
; ===========================================================================

loc_1C85E:
		move.l	#0,(a6)
		dbf	d1,loc_1C85E

		bra.s	loc_1C858
; End of function Hud_Base

; ===========================================================================
Hud_TilesBase:	dc.b $16, $FF, $FF, $FF, $FF, $FF, $FF,	0, 0, $14, 0, 0
Hud_TilesZero:	dc.b $FF, $FF, 0, 0
; ---------------------------------------------------------------------------
; Subroutine to	load debug mode	numbers	patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HudDb_XY:				; XREF: HudDebug
		locVRAM	icons_loc		; set VRAM address
		move.w	(v_screenposx).w,d1 ; load camera x-position
		swap	d1
		move.w	(v_player+obX).w,d1 ; load Sonic's x-position
		bsr.s	HudDb_XY2
		move.w	(v_screenposy).w,d1 ; load camera y-position
		swap	d1
		move.w	(v_player+obY).w,d1 ; load Sonic's y-position
; End of function HudDb_XY


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HudDb_XY2:
		moveq	#7,d6
		lea	(Art_Text).l,a1

HudDb_XYLoop:
		rol.w	#4,d1
		move.w	d1,d2
		andi.w	#$F,d2
		cmpi.w	#$A,d2
		bcs.s	loc_1C8B2
		addq.w	#7,d2

loc_1C8B2:
		lsl.w	#5,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		swap	d1
		dbf	d6,HudDb_XYLoop	; repeat 7 more	times

		rts	
; End of function HudDb_XY2

; ---------------------------------------------------------------------------
; Subroutine to	load rings numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Rings:				; XREF: HUD_Update
		lea	(Hud_100).l,a2
		moveq	#2,d6
		bra.s	Hud_LoadArt
; End of function Hud_Rings

; ---------------------------------------------------------------------------
; Subroutine to	load score numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Score:				; XREF: HUD_Update
		lea	(Hud_100000).l,a2
		moveq	#5,d6

Hud_LoadArt:
		moveq	#0,d4
		lea	Art_Hud(pc),a1

Hud_ScoreLoop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C8EC:
		sub.l	d3,d1
		bcs.s	loc_1C8F4
		addq.w	#1,d2
		bra.s	loc_1C8EC
; ===========================================================================

loc_1C8F4:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1C8FE
		move.w	#1,d4

loc_1C8FE:
		tst.w	d4
		beq.s	loc_1C92C
		lsl.w	#6,d2
		move.l	d0,4(a6)
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1C92C:
		addi.l	#$400000,d0
		dbf	d6,Hud_ScoreLoop

		rts	

; End of function Hud_Score

Hud_Icons:
		locVRAM	icons_loc, 4(a6)		; set VRAM address

                lea     (EquipAbilitiesList),a1
                moveq   #0,d1
                move.b  (v_a_ability).l,d1
                bsr.s   @LoadIcon
; --------------------------------------------------------------------------
                lea     (EquipAbilitiesList),a1
                moveq   #0,d1
                move.b  (v_b_ability).l,d1
                bsr.s   @LoadIcon
; --------------------------------------------------------------------------
                lea     (EquipAbilitiesList),a1
                moveq   #0,d1
                move.b  (v_c_ability).l,d1
                bsr.s   @LoadIcon
; --------------------------------------------------------------------------
;                moveq   #32, d1
;          @cleartiles:
;		move.l	#0,(a6)
;		dbf     d1,@cleartiles
                rts

; --------------------------------------------------------------------------
        @LoadIcon:
                add.b   d1,d1
                add.b   d1,d1
                adda.l  d1,a1
                movea.l (a1),a1
                adda.l  #InvSIconOffset,a1

                movea.l (a1),a1
                moveq   #0,d1                           ; clear d1
	@LoadIconGFX:
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
                rts
