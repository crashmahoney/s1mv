; ---------------------------------------------------------------------------
; Subroutine to	animate	level graphics
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AnimateLevelGfx:			; XREF: Demo_Time; VBla_0C_NoChg
		tst.w	(f_pause).w	; is the game paused?
		bne.s	@ispaused	; if yes, branch
		lea	($C00000).l,a6
		bsr.w	AniArt_GiantRing
		moveq	#0,d0
		move.b	(v_zone).w,d0
		add.w	d0,d0
		move.w	AniArt_Index(pc,d0.w),d0
		jmp	AniArt_Index(pc,d0.w)

	@ispaused:
		rts	

; ===========================================================================
AniArt_Index:	dc.w AniArt_GHZ-AniArt_Index, AniArt_LZ-AniArt_Index
		dc.w AniArt_MZ-AniArt_Index, AniArt_none-AniArt_Index
		dc.w AniArt_none-AniArt_Index, AniArt_SBZ-AniArt_Index
		dc.w AniArt_Ending-AniArt_Index, AniArt_MZ-AniArt_Index
		dc.w AniArt_none-AniArt_Index, AniArt_none-AniArt_Index
; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - Green Hill
; ---------------------------------------------------------------------------

AniArt_GHZ:				; XREF: AniArt_Index
		rts
;                 subq.b	#1,(v_lani0_time).w
; 		bpl.s	loc_1C08A
; 		move.b	#5,(v_lani0_time).w ; time to display each frame for
; 		lea	(Art_GhzWater).l,a1 ; load waterfall patterns
; 		move.b	(v_lani0_frame).w,d0
; 		addq.b	#1,(v_lani0_frame).w
; 		andi.w	#1,d0
; 		beq.s	loc_1C078
; 		lea	$100(a1),a1	; load next frame
; 
; loc_1C078:
; 		locVRAM	$6F00		; VRAM address
; 		move.w	#7,d1		; number of 8x8	tiles
; 		bra.w	LoadTiles
; ; ===========================================================================
; 
; loc_1C08A:
; 		subq.b	#1,(v_lani1_time).w
; 		bpl.s	loc_1C0C0
; 		move.b	#$F,(v_lani1_time).w
; 		lea	(Art_GhzFlower1).l,a1 ;	load big flower	patterns
; 		move.b	(v_lani1_frame).w,d0
; 		addq.b	#1,(v_lani1_frame).w
; 		andi.w	#1,d0
; 		beq.s	loc_1C0AE
; 		lea	$200(a1),a1
; 
; loc_1C0AE:
; 		locVRAM	$6B80
; 		move.w	#$F,d1
; 		bra.w	LoadTiles
; ; ===========================================================================
; 
; loc_1C0C0:
; 		subq.b	#1,(v_lani2_time).w
; 		bpl.s	locret_1C10C
; 		move.b	#7,(v_lani2_time).w
; 		move.b	(v_lani2_frame).w,d0
; 		addq.b	#1,(v_lani2_frame).w
; 		andi.w	#3,d0
; 		move.b	byte_1C10E(pc,d0.w),d0
; 		btst	#0,d0
; 		bne.s	loc_1C0E8
; 		move.b	#$7F,(v_lani2_time).w
; 
; loc_1C0E8:
; 		lsl.w	#7,d0
; 		move.w	d0,d1
; 		add.w	d0,d0
; 		add.w	d1,d0
; 		locVRAM	$6D80
; 		lea	(Art_GhzFlower2).l,a1 ;	load small flower patterns
; 		lea	(a1,d0.w),a1
; 		move.w	#$B,d1
; 		bsr.w	LoadTiles
; 
; locret_1C10C:
; 		rts	
; ; ===========================================================================
; byte_1C10E:	dc.b 0,	1, 2, 1




; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - Labyrinth
; ---------------------------------------------------------------------------
Vram_LZ_Waterline = $19B*$20

AniArt_LZ:
AnimateTiles_HCZ1:
;		tst.b	($FFFFEEE8).w
;		beq.s	loc_27888
;		rts
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; This section determines which	tiles to load at what position to simulate a
; waterline extending into the background
; ---------------------------------------------------------------------------

loc_27888:
		lea	(v_HCZ_tileanim).w,a3		

loc_2788C:
		moveq	#0,d1
		move.w	(v_waterline_difference).w,d1
		cmp.w	(a3),d1
		beq.w	loc_2797A
		move.w	d1,(a3)
		tst.w	d1
		beq.w	loc_2797E
		bpl.w	loc_27912
		addi.w	#$60,d1
		bcc.w	loc_2797A
		move.w	d1,d0
		add.w	d1,d1
		add.w	d0,d1
		lsl.w	#5,d1
		lea	(v_LZ_Waterline_Buffer).l,a4
		lea	(HCZ_WaterlineScroll_Data).l,a5
		adda.w	d1,a5
		move.w	#$5F,d1

loc_278C6:
		moveq	#0,d0
		move.b	(a5)+,d0
		add.w	d0,d0
		add.w	d0,d0
		lea	(ArtUnc_AniHCZ1_WaterlineBelow).l,a0
		adda.w	d0,a0
		move.l	(a0),(a4)
		lea	$600(a0),a0
		lea	$180(a4),a4
		move.l	(a0),(a4)
		lea	-$17C(a4),a4
		dbf	d1,loc_278C6
		move.l	#v_LZ_Waterline_Buffer,d1
		move.w	#Vram_LZ_Waterline,d2
		move.w	#$180,d3
		jsr	(Add_To_DMA_Queue).l
		tst.w	2(a3)
		bmi.s	loc_2790E
		move.w	#-1,2(a3)
		bsr.w	AniHCZ_FixLowerBG

loc_2790E:
		bra.w	loc_2797A
; ---------------------------------------------------------------------------

loc_27912:
		neg.w	d1
		addi.w	#$60,d1
		bcc.s	loc_2797A
		move.w	d1,d0
		add.w	d1,d1
		add.w	d0,d1
		lsl.w	#5,d1
		lea	(v_LZ_Waterline_Buffer).l,a4
		lea	(HCZ_WaterlineScroll_Data).l,a5
		adda.w	d1,a5
		move.w	#$5F,d1

loc_27934:
		moveq	#0,d0
		move.b	(a5)+,d0
		add.w	d0,d0
		add.w	d0,d0
		lea	(ArtUnc_AniHCZ1_WaterlineAbove).l,a0
		adda.w	d0,a0
		move.l	(a0),(a4)
		lea	$600(a0),a0
		lea	$180(a4),a4
		move.l	(a0),(a4)
		lea	-$17C(a4),a4
		dbf	d1,loc_27934
		move.l	#v_LZ_Waterline_Buffer,d1
		move.w	#Vram_LZ_Waterline+$300,d2
		move.w	#$180,d3
		jsr	(Add_To_DMA_Queue).l
		tst.w	2(a3)
		beq.s	loc_2797A
		move.w	#0,2(a3)
		bsr.s	AniHCZ_FixUpperBG
loc_2797A:
		rts
;		bra.w	AnimateTiles_DoAniPLC
; ---------------------------------------------------------------------------

loc_2797E:

		move.w	#1,(a3)
		bsr.s	AniHCZ_FixLowerBG

; ---------------------------------------------------------------------------
; When the special waterline goes below	water, this routine loads tiles	to
; fix the background area that was affected when the waterline was above
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================


AniHCZ_FixUpperBG:

		move.l	#ArtUnc_FixHCZ1_UpperBG1,d1
		move.w	#Vram_LZ_Waterline,d2
		move.w	#$C0,d3
		jsr	(Add_To_DMA_Queue).l
		move.l	#ArtUnc_FixHCZ1_UpperBG2,d1
		move.w	#Vram_LZ_Waterline+$180,d2
		move.w	#$C0,d3
		jmp	(Add_To_DMA_Queue).l
; End of function AniHCZ_FixUpperBG

; ---------------------------------------------------------------------------
; When the special waterline goes above	water, this routine loads tiles	to
; fix the background area that was affected when the waterline was below
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================


AniHCZ_FixLowerBG:

		move.l	#ArtUnc_FixHCZ1_LowerBG1,d1
		move.w	#Vram_LZ_Waterline+$300,d2
		move.w	#$C0,d3
		jsr	(Add_To_DMA_Queue).l
		move.l	#ArtUnc_FixHCZ1_LowerBG2,d1
		move.w	#Vram_LZ_Waterline+$480,d2
		move.w	#$C0,d3
		jmp	(Add_To_DMA_Queue).l
; End of function AniHCZ_FixLowerBG


; =============== S U B R O U T I N E =======================================


sub_279D4:
;		lea	(AniPLC_HCZ1).l,a2
		lea	(v_HCZ_tileanim).w,a3
		move.w	(v_waterline_difference).w,d1
		beq.s	loc_2797E
		bpl.s	loc_27A1C
		addi.w	#$60,d1
		bcc.s	loc_279F2
		bsr.s	AniHCZ_FixLowerBG
		bra.w	loc_2788C
; ---------------------------------------------------------------------------

loc_279F2:
		bsr.s	AniHCZ_FixLowerBG
		move.l	#ArtUnc_AniHCZ1_WaterlineBelow,d1
		move.w	#Vram_LZ_Waterline,d2
		move.w	#$C0,d3
		jsr	(Add_To_DMA_Queue).l
		move.l	#ArtUnc_AniHCZ1_WaterlineBelow2,d1
		move.w	#Vram_LZ_Waterline+$180,d2
		move.w	#$C0,d3
		jmp	(Add_To_DMA_Queue).l
; ---------------------------------------------------------------------------

loc_27A1C:
		neg.w	d1
		addi.w	#$60,d1
		bcc.s	loc_27A2C
		bsr.w	AniHCZ_FixUpperBG
		bra.w	loc_2788C
; ---------------------------------------------------------------------------

loc_27A2C:
		bsr.w	AniHCZ_FixUpperBG
		move.l	#ArtUnc_AniHCZ1_WaterlineAbove,d1
		move.w	#Vram_LZ_Waterline+$300,d2
		move.w	#$C0,d3
		jsr	(Add_To_DMA_Queue).l
		move.l	#ArtUnc_AniHCZ1_WaterlineAbove2,d1
		move.w	#Vram_LZ_Waterline+$400,d2
		move.w	#$C0,d3
		jmp	(Add_To_DMA_Queue).l
; End of function sub_279D4


; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - Marble
; ---------------------------------------------------------------------------
AniArt_MZ:				; XREF: AniArt_Index
		subq.b	#1,(v_lani0_time).w
		bpl.s	loc_1C150
		move.b	#$13,(v_lani0_time).w
		lea		(Art_MzLava1).l,a1 ; load lava surface patterns
		moveq	#0,d0
		move.b	(v_lani0_frame).w,d0
		addq.b	#1,d0
		cmpi.b	#6,d0
		bne.s	loc_1C134
		moveq	#0,d0

loc_1C134:
		move.b	d0,(v_lani0_frame).w
		mulu.w	#$600,d0
		adda.w	d0,a1
		locVRAM	$2640
		move.w	#47,d1
		bsr.w	LoadTiles
		rts




loc_1C150:
		rts

		
		subq.b	#1,(v_lani1_time).w
		bpl.s	loc_1C1AE
		move.b	#1,(v_lani1_time).w
		moveq	#0,d0
		move.b	(v_lani0_frame).w,d0
		lea		(Art_MzLava2).l,a4 ; load lava patterns
		ror.w	#7,d0
		adda.w	d0,a4
		locVRAM	$5A40
		moveq	#0,d3
		move.b	(v_lani1_frame).w,d3
		addq.b	#1,(v_lani1_frame).w
		move.b	(v_oscillate+$A).w,d3
		move.w	#3,d2

loc_1C188:
		move.w	d3,d0
		add.w	d0,d0
		andi.w	#$1E,d0
		lea		(AniArt_MZextra).l,a3
		move.w	(a3,d0.w),d0
		lea		(a3,d0.w),a3
		movea.l	a4,a1
		move.w	#$1F,d1
		jsr		(a3)
		addq.w	#4,d3
		dbf		d2,loc_1C188
		rts	
; ===========================================================================

loc_1C1AE:
		subq.b	#1,(v_lani2_time).w
		bpl.w	locret_1C1EA
		move.b	#7,(v_lani2_time).w
		lea	(Art_MzTorch).l,a1 ; load torch	patterns
		moveq	#0,d0
		move.b	(v_lani3_frame).w,d0
		addq.b	#1,(v_lani3_frame).w
		andi.b	#3,(v_lani3_frame).w
		mulu.w	#$C0,d0
		adda.w	d0,a1
		locVRAM	$5E40
		move.w	#5,d1
		bra.w	LoadTiles
; ===========================================================================

locret_1C1EA:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - Scrap Brain
; ---------------------------------------------------------------------------

AniArt_SBZ:				; XREF: AniArt_Index
		tst.b	(v_lani2_frame).w
		beq.s	loc_1C1F8
		subq.b	#1,(v_lani2_frame).w
		bra.s	loc_1C250
; ===========================================================================

loc_1C1F8:
		subq.b	#1,(v_lani0_time).w
		bpl.s	loc_1C250
		move.b	#7,(v_lani0_time).w
		lea	(Art_SbzSmoke).l,a1 ; load smoke patterns
		locVRAM	$8900
		move.b	(v_lani0_frame).w,d0
		addq.b	#1,(v_lani0_frame).w
		andi.w	#7,d0
		beq.s	loc_1C234
		subq.w	#1,d0
		mulu.w	#$180,d0
		lea	(a1,d0.w),a1
		move.w	#$B,d1
		bra.w	LoadTiles
; ===========================================================================

loc_1C234:
		move.b	#$B4,(v_lani2_frame).w

loc_1C23A:
		move.w	#5,d1
		bsr.w	LoadTiles
		lea	(Art_SbzSmoke).l,a1
		move.w	#5,d1
		bra.w	LoadTiles
; ===========================================================================

loc_1C250:
		tst.b	(v_lani2_time).w
		beq.s	loc_1C25C
		subq.b	#1,(v_lani2_time).w
		bra.s	locret_1C2A0
; ===========================================================================

loc_1C25C:
		subq.b	#1,(v_lani1_time).w
		bpl.s	locret_1C2A0
		move.b	#7,(v_lani1_time).w
		lea	(Art_SbzSmoke).l,a1
		locVRAM	$8A80
		move.b	(v_lani1_frame).w,d0
		addq.b	#1,(v_lani1_frame).w
		andi.w	#7,d0
		beq.s	loc_1C298
		subq.w	#1,d0
		mulu.w	#$180,d0
		lea	(a1,d0.w),a1
		move.w	#$B,d1
		bra.w	LoadTiles
; ===========================================================================

loc_1C298:
		move.b	#$78,(v_lani2_time).w
		bra.s	loc_1C23A
; ===========================================================================

locret_1C2A0:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - ending sequence
; ---------------------------------------------------------------------------

AniArt_Ending:				; XREF: AniArt_Index
		subq.b	#1,(v_lani1_time).w
		bpl.s	loc_1C2F4
		move.b	#7,(v_lani1_time).w
		lea	(Art_GhzFlower1).l,a1 ;	load big flower	patterns
		lea	($FFFF9400).w,a2
		move.b	(v_lani1_frame).w,d0
		addq.b	#1,(v_lani1_frame).w
		andi.w	#1,d0
		beq.s	loc_1C2CE
		lea	$200(a1),a1
		lea	$200(a2),a2

loc_1C2CE:
		locVRAM	$6B80
		move.w	#$F,d1
		bsr.w	LoadTiles
		movea.l	a2,a1
		locVRAM	$7200
		move.w	#$F,d1
		bra.w	LoadTiles
; ===========================================================================

loc_1C2F4:
		subq.b	#1,(v_lani2_time).w
		bpl.s	loc_1C33C
		move.b	#7,(v_lani2_time).w
		move.b	(v_lani2_frame).w,d0
		addq.b	#1,(v_lani2_frame).w
		andi.w	#7,d0
		move.b	byte_1C334(pc,d0.w),d0
		lsl.w	#7,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		locVRAM	$6D80
		lea	(Art_GhzFlower2).l,a1 ;	load small flower patterns
		lea	(a1,d0.w),a1
		move.w	#$B,d1
		bra.w	LoadTiles
; ===========================================================================
byte_1C334:	dc.b 0,	0, 0, 1, 2, 2, 2, 1
; ===========================================================================

loc_1C33C:
		subq.b	#1,(v_lani4_time).w
		bpl.s	loc_1C37A
		move.b	#$E,(v_lani4_time).w
		move.b	(v_lani4_frame).w,d0
		addq.b	#1,(v_lani4_frame).w
		andi.w	#3,d0
		move.b	byte_1C376(pc,d0.w),d0
		lsl.w	#8,d0
		add.w	d0,d0
		locVRAM	$7000
		lea	($FFFF9800).w,a1 ; load	special	flower patterns	(from RAM)
		lea	(a1,d0.w),a1
		move.w	#$F,d1
		bra.w	LoadTiles
; ===========================================================================
byte_1C376:	dc.b 0,	1, 2, 1
; ===========================================================================

loc_1C37A:
		subq.b	#1,(v_lani5_time).w
		bpl.s	locret_1C3B4
		move.b	#$B,(v_lani5_time).w
		move.b	(v_lani5_frame).w,d0
		addq.b	#1,(v_lani5_frame).w
		andi.w	#3,d0
		move.b	byte_1C376(pc,d0.w),d0
		lsl.w	#8,d0
		add.w	d0,d0
		locVRAM	$6800
		lea	($FFFF9E00).w,a1 ; load	special	flower patterns	(from RAM)
		lea	(a1,d0.w),a1
		move.w	#$F,d1
		bra.w	LoadTiles
; ===========================================================================

locret_1C3B4:
		rts	
; ===========================================================================

AniArt_none:				; XREF: AniArt_Index
		rts	

; ---------------------------------------------------------------------------
; Subroutine to	load (d1 - 1) 8x8 tiles
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTiles:
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		dbf	d1,LoadTiles
		rts	
; End of function LoadTiles

; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - more Marble Zone
; ---------------------------------------------------------------------------
AniArt_MZextra:	dc.w loc_1C3EE-AniArt_MZextra, loc_1C3FA-AniArt_MZextra
		dc.w loc_1C410-AniArt_MZextra, loc_1C41E-AniArt_MZextra
		dc.w loc_1C434-AniArt_MZextra, loc_1C442-AniArt_MZextra
		dc.w loc_1C458-AniArt_MZextra, loc_1C466-AniArt_MZextra
		dc.w loc_1C47C-AniArt_MZextra, loc_1C48A-AniArt_MZextra
		dc.w loc_1C4A0-AniArt_MZextra, loc_1C4AE-AniArt_MZextra
		dc.w loc_1C4C4-AniArt_MZextra, loc_1C4D2-AniArt_MZextra
		dc.w loc_1C4E8-AniArt_MZextra, loc_1C4FA-AniArt_MZextra
; ===========================================================================

loc_1C3EE:				; XREF: AniArt_MZextra
		move.l	(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C3EE
		rts	
; ===========================================================================

loc_1C3FA:				; XREF: AniArt_MZextra
		move.l	2(a1),d0
		move.b	1(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C3FA
		rts	
; ===========================================================================

loc_1C410:				; XREF: AniArt_MZextra
		move.l	2(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C410
		rts	
; ===========================================================================

loc_1C41E:				; XREF: AniArt_MZextra
		move.l	4(a1),d0
		move.b	3(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C41E
		rts	
; ===========================================================================

loc_1C434:				; XREF: AniArt_MZextra
		move.l	4(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C434
		rts	
; ===========================================================================

loc_1C442:				; XREF: AniArt_MZextra
		move.l	6(a1),d0
		move.b	5(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C442
		rts	
; ===========================================================================

loc_1C458:				; XREF: AniArt_MZextra
		move.l	6(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C458
		rts	
; ===========================================================================

loc_1C466:				; XREF: AniArt_MZextra
		move.l	8(a1),d0
		move.b	7(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C466
		rts	
; ===========================================================================

loc_1C47C:				; XREF: AniArt_MZextra
		move.l	8(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C47C
		rts	
; ===========================================================================

loc_1C48A:				; XREF: AniArt_MZextra
		move.l	$A(a1),d0
		move.b	9(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C48A
		rts	
; ===========================================================================

loc_1C4A0:				; XREF: AniArt_MZextra
		move.l	$A(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4A0
		rts	
; ===========================================================================

loc_1C4AE:				; XREF: AniArt_MZextra
		move.l	$C(a1),d0
		move.b	$B(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4AE
		rts	
; ===========================================================================

loc_1C4C4:				; XREF: AniArt_MZextra
		move.l	$C(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4C4
		rts	
; ===========================================================================

loc_1C4D2:				; XREF: AniArt_MZextra
		move.l	$C(a1),d0
		rol.l	#8,d0
		move.b	0(a1),d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4D2
		rts	
; ===========================================================================

loc_1C4E8:				; XREF: AniArt_MZextra
		move.w	$E(a1),(a6)
		move.w	0(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4E8
		rts	
; ===========================================================================

loc_1C4FA:				; XREF: AniArt_MZextra
		move.l	0(a1),d0
		move.b	$F(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4FA
		rts	

; ---------------------------------------------------------------------------
; Animated pattern routine - giant ring
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AniArt_GiantRing:			; XREF: AnimateLevelGfx
		tst.w	(v_gfxbigring).w
		bne.s	loc_1C518
		rts	
; ===========================================================================

loc_1C518:
		subi.w	#$1C0,(v_gfxbigring).w
		lea	(Art_BigRing).l,a1 ; load giant	ring patterns
		moveq	#0,d0
		move.w	(v_gfxbigring).w,d0
		lea	(a1,d0.w),a1
		addi.w	#$B000,d0
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,4(a6)
		move.w	#$D,d1
		bra.w	LoadTiles

; End of function AniArt_GiantRing

