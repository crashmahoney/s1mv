v_roadxpos	=	$FFFFF000	; word
v_roadxoffset	=	$FFFFF002	; word
v_roadspeed	=	$FFFFF004	; long (fixed point)
v_roadzpos	=	$FFFFF008	; word
v_skyxpos	=	$FFFFF00A	; long (fixed point)
v_roadscanline	=	$FFFFF00E	; word
v_roadcurve	=	$FFFFF010	; long (fixed point)
v_stripetable	=	$FFFFF050	; array

dma_length	equ	$0010 		;length in bytes
dma_source	equ	Pal_Race2 	;source address
dma_target	equ	$0020 		;target address


GM_Race:

	;bra.s	@soundtest
		move.b	#musFadeOut,d0
	;	jsr	PlaySound_Special 		; stop music
		bsr.w	ClearPLC
		bsr.w	PaletteWhiteOut

		music	bgm_MZ

	; turn off display	
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l

		move	#$2700,sr			; Mask all interrupts
		lea	($C00004).l,a6
		move.w	#$8004,(a6)			; use 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6) 	; set foreground nametable address
		move.w	#$8400+($A000>>13),(a6) 	; set background nametable address
		move.w	#$8500+(vram_sprites>>9),(a6) 	; set sprite table address
		move.w	#$8710,(a6)			; set background colour (palette entry $10)
		move.w	#$8B03,(a6)			; line scroll mode
		move.w	#$9011,(a6)			; 128 x 32-cell plane size
		clr.w	(v_sgfx_buffer).w			; +++ ProcessDMAQueue crap
		move.w	#v_sgfx_buffer,(v_vdp_buffer_slot).w   ; +++
		clr.b	(f_wtr_state).w

		move.w	#0,(f_hbla_pal).w
		bsr.w	ClearScreen

; set starting values
	move.w	#0,(v_roadxpos).w		; starting x position
	move.w	#0,(v_roadxoffset).w		; starting x offset
	move.w	#0,(v_roadspeed).w		; starting speed


		jsr	InitDMAQueue

;load tile graphics
		lea	(KosM_RaceRoad).l,a1		; moduled art to load
		moveq	#$0000,d2			; vram location to load to
		jsr	(Queue_Kos_Module).l		; add to queue
		lea	(KosM_RaceSky).l,a1		; moduled art to load
	;	move.l	#$C0*$20,d2			; vram location to load to
		jsr	(Queue_Kos_Module).l		; add to queue
@loadgfx:
		move.b  #$1C, (v_vbla_routine).w
		jsr	(Process_Kos_Queue).l
		jsr     WaitForVBla
		jsr	(Process_Kos_Module_Queue).l
		tst.b	(Kos_modules_left).w
		bne.s	@loadgfx


		move	#$2700,sr			; interrupts off
; load sky mappings
		lea	($FF0000).l,a1
		lea	(Eni_RaceSky).l,a0 		; load road mappings
		move.w	#4,d0				; offset
		bsr.w	EniDec
; load road mappings		
		lea	($FF1000).l,a1
		lea	(Eni_RaceRoad).l,a0 		; load road mappings
		move.w	#0,d0
		bsr.w	EniDec

vram_loc_sky	=	$A000
vram_loc_road	=	$A800

; copy tilemap to vram
		lea	($FF0000).l,a1			; tilemap location
		move.l	#$40000000+((vram_loc_sky&$3FFF)<<16)+((vram_loc_sky&$C000)>>14),d0
		moveq	#64,d1				; width
		moveq	#47,d2				; height
		bsr.w	Race_DrawTilesStart


; load palette		
		moveq	#palid_Sonic,d0
  		bsr.w	PalLoad2			; load race stage palette
  		moveq	#palid_Race1,d0
  		add.w	(v_lastspecial).w,d0
  		bsr.w	PalLoad2			; load race stage palette

; turn on display			
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		move.w	#$8014,($C00004).l	; enable H-interrupts
	;	bsr.w	PaletteWhiteIn








; ---------------------------------------------------------------------------
; Main Loop ;)

Race_MainLoop:
	move.l	#$00000020,(v_scrposy_dup).w
	move.b	#$1C,(v_vbla_routine).w
	jsr	(Process_Kos_Queue).l
	bsr.w	WaitForVBla
	addq.w	#1,(v_framecount).w		; add 1 to level timer

	move.w	#$8A00+47,(v_hbla_hreg).w ; set hblank trigger scanline /2
	move.w	(v_hbla_hreg).w,($C00004).l
	lea	($C00000).l,a6
	move.w	#$8014,4(a6)	; enable H-interrupts
; ; set up dma
; 	move.w	#$8F02,(a6)
; 	move.w	#$9300+((dma_length>>1)&$FF),4(a6)
; 	move.w	#$9400+(((dma_length>>1)&$FF00)>>8),4(a6)
; 	move.w	#$9500+((dma_source>>1)&$FF),4(a6)
; 	move.w	#$9600+(((dma_source>>1)&$FF00)>>8),4(a6)
; 	move.w	#$9700+(((dma_source>>1)&$7F0000)>>16),4(a6)

; add speed to road position
	moveq	#0,d0
	move.w	(v_roadzpos).w,d0
	add.w	(v_roadspeed).w,d0
	move.w	d0,(v_roadzpos).w
	move.w	d0,(v_roadscanline).w

	bsr.w	Build_StripeTable

; move sky according to road curve
	moveq	#0,d0
	moveq	#0,d1
	move.l	(v_roadspeed).w,d0
	neg.l	d0
	lsr.l	#5,d0
	move.l	d0,($FF0000).l			; debug
	move.l	(v_roadcurve).w,d1
	neg.l	d1
	lsr.l	#1,d1
	move.l	d1,($FF0004).l			; debug
	swap	d0
	swap	d1
	muls.w	d0,d1
;	swap	d0
	swap	d1	
	add.l	d1,(v_skyxpos).w
	move.l	d1,($FF0008).l			; debug
	move.l	(v_skyxpos).w,($FF000C).l	; debug
;	

	bsr.w	DeformRoadLayers


; joypad
@move:
	move.b	(v_jpadhold1).w,d0

	btst	#bitA,d0			; is A pressed?
	beq.s	@chkB
	sub.l	#$0000C000,(v_roadcurve).w	; change road curve
@chkB:
	btst	#bitB,d0			; is B pressed?
	beq.s	@chkC
	add.l	#$0000C000,(v_roadcurve).w	; change road curve

@chkC:
	btst	#bitC,(v_jpadpress1).w			; is C pressed?
	beq.s	@chkL
	add.w	#1,(v_lastspecial).w
	cmpi.w	#2,(v_lastspecial).w
	bne.s	@loadpal
	move.w	#0,(v_lastspecial).w
@loadpal:
	move.b	d0,-(sp)
  	moveq	#palid_Race1,d0
  	add.w	(v_lastspecial).w,d0
  	bsr.w	PalLoad2			; load race stage palette
	move.b	(sp)+,d0

@chkL:
	btst	#bitL,d0			; is left pressed?
	beq.s	@chkR
	cmpi.w	#80,(v_roadxoffset).w		
	bge.s	@chkR
	add.w	#1,(v_roadxoffset).w		; add to x position
@chkR:
	btst	#bitR,d0			; is left pressed?
	beq.s	@accel
	cmpi.w	#-80,(v_roadxoffset).w		
	ble.s	@accel
	sub.w	#1,(v_roadxoffset).w		; sub from x position
@accel:
	btst	#bitUp,d0			; is up pressed?
	beq.s	@decel
	sub.l	#$00008000,(v_roadspeed).w	; add to speed
@decel:
	btst	#bitDn,d0			; is down pressed?
	beq.s	@chkStart
	add.l	#$00008000,(v_roadspeed).w	; sub from speed
@chkStart:
	andi.b	#btnStart,d0			; is start pressed?
	bne.s   @startpressed

	jsr	(Process_Kos_Module_Queue).l
	cmpi.b	#id_Race,(v_gamemode).w
	beq	Race_MainLoop
@startpressed:
	move.b	#id_Sega,(v_gamemode).w 	; set Game Mode to Sega Screen
	rts					; return to game mode select code














; ---------------------------------------------------------------------------
; write tilemap to vram
; ---------------------------------------------------------------------------
Race_DrawTilesStart:
		lea	($C00000).l,a6
		move.l	#$800000,d4

		move.w	(v_roadxoffset).w,d3
		add.w	#256,d3			; centre on screen by subtracting (half of plane width - half of screen width) 
		lsr.w	#2,d3				; divide by 4
		adda.w	d3,a1

	@tilemap_line:
		move.l	d0,4(a6)
		move.w	d1,d3

	@tilemap_cell:
		move.w	(a1)+,(a6)		; write cell info to vram
		dbf	d3,@tilemap_cell
		add.l	d4,d0			; next line vram	
		adda.w	#126,a1			; next line tilemap ram
		dbf	d2,@tilemap_line
		rts
























; ---------------------------------------------------------------------------
; generate line scroll list
; ---------------------------------------------------------------------------
DeformRoadLayers:
	lea	(v_scrolltable).w,a1		; ($FFFFCC00)
	moveq	#0,d0
	move.w	(v_skyxpos).l,d0		; plane b x position
	moveq	#95,d2				; # lines of sky
@skyloop:	
	move.l	d0,(a1)+			
	dbf	d2,@skyloop

	moveq	#127,d2				; # lines of road
	moveq	#0,d1				 
	moveq	#0,d3
	move.w	(v_roadxpos).w,d0			
	move.w	(v_roadxoffset).w,d3		; distance offset
	swap	d3				; extend to fixed point
	lsr.l	#4,d3				; divide it
	move.w	d0,d1				; copy of main x position
	sub.w	#256-160,d1				; centre on screen by subtracting half of screen width

@roadloop:	

	move.w	d0,(a1)+			; plane a
	move.w	d1,(a1)+			; plane b

	swap	d1				; make fixed point
	add.l	d3,d1				; add offset
	swap	d1				; make integer again

	dbf	d2,@roadloop

; curve
	moveq	#0,d0
	move.w	(v_roadcurve).w,d1
	moveq	#127,d2
 	lea	Z_map+32,a0
	lea	(v_scrolltable+(96*4)).w,a1
@curveloop:
	move.w	(a0)+,d0			; get z map value
	muls.w	d1,d0				; multiply by curve amount
	lsr.w	#5,d0				; divide by 32
;	andi.w	#$2FF,d0			; restrict to 256 px
	add.l	d0,(a1)+
	dbf	d2,@curveloop
	rts


















; ---------------------------------------------------------------------------
; hblank routine
; ---------------------------------------------------------------------------
HBlank_Road1:
	move.w	#HBlank_Roadstart,(H_int_addr+2).w	; hblank code address to jump to
	move.w	#$8A00,(v_hbla_hreg).w		; setup hblank counter
	move.w	(v_hbla_hreg).w,4(a6)		; send to vdp
	rte

HBlank_Roadstart:
	lea	(v_stripetable).w,a5
	tst.b	(a5)+
	beq.s	HBlank_Road3

HBlank_Road2:
	move.l	#$40000010,4(a6)		; VSRAM write mode
	move.l	#$00000020,(a6)			; send screen y-axis pos. to VSRAM
	move.w	#HBlank_Road3,(H_int_addr+2).w	; hblank code address to jump to
	bra.s	HBlank_SetHBlaCount

HBlank_Road3:
	move.l	#$40000010,4(a6)		; VSRAM write mode
	move.l	#$000000A0,(a6)			; send screen y-axis pos. to VSRAM
	move.w	#HBlank_Road2,(H_int_addr+2).w	; hblank code address to jump to

HBlank_SetHBlaCount:
	move.w	#$8A00,(v_hbla_hreg).w		; setup hblank counter
	move.b	(a5)+,(v_hbla_hreg+1).w		; add in lines to next hblank
	move.w	(v_hbla_hreg).w,4(a6)		; send to vdp
	rte


; ---------------------------------------------------------------------------
Build_StripeTable:
	lea	(v_stripetable).w,a0
	lea	Z_Map+4,a1
	move.w	(v_roadscanline).w,d0
	moveq	#0,d3			; 0 or 1, current stripe type
	moveq	#0,d4			; working register for math
ST_Start_stripe:
	add.w	(a1)+,d0		; add xmap
	move.w	d0,d4			; copy to a working register
	andi.w	#$400,d4
	lsr.w	#5,d4
	lsr.w	#5,d4			; shift remaining bit to bit 0
	move.w	d4,d3
	move.b	d3,(a0)+		; write bit to table

	moveq	#127,d1			; how many lines left to check
	moveq	#0,d2			; how many lines since last stripe change

@lineloop:
	add.w	(a1)+,d0		; add xmap
	move.w	d0,d4			; copy to a working register
	andi.w	#$400,d4
	lsr.w	#5,d4
	lsr.w	#5,d4			; shift bit to bit 0	
	cmp.w	d3,d4			; is stripe same as last time?
	bne.s	@changestripe		; if not, branch
	addq	#1,d2
	dbf	d1,@lineloop
	bra.s	@return
@changestripe:
	move.w	d4,d3
	move.b	d2,(a0)+
	moveq	#0,d2
	dbf	d1,@lineloop

@return:
	move.b	d2,(a0)
	rts

; ---------------------------------------------------------------------------
Pal_Race1:
		incbin	"palette\Race Stage 1.bin"
		even
Pal_Race2:
		incbin	"palette\Race Stage 2.bin"
		even
Z_map:
    dc.w    4096, 2048, 1365, 1024, 819, 683, 585, 512, 455, 410, 372, 341, 315, 293, 273, 256
    dc.w    241, 228, 216, 205, 195, 186, 178, 171, 164, 158, 152, 146, 141, 137, 132, 128
    dc.w    124, 120, 117, 114, 111, 108, 105, 102, 100, 98, 95, 93, 91, 89, 87, 85
    dc.w    84, 82, 80, 79, 77, 76, 74, 73, 72, 71, 69, 68, 67, 66, 65, 64
    dc.w    63, 62, 61, 60, 59, 59, 58, 57, 56, 55, 55, 54, 53, 53, 52, 51
    dc.w    51, 50, 49, 49, 48, 48, 47, 47, 46, 46, 45, 45, 44, 44, 43, 43
    dc.w    42, 42, 41, 41, 41, 40, 40, 39, 39, 39, 38, 38, 38, 37, 37, 37
    dc.w    36, 36, 36, 35, 35, 35, 34, 34, 34, 34, 33, 33, 33, 33, 32, 32
    dc.w    32, 32, 31, 31, 31, 31, 30, 30, 30, 30, 29, 29, 29, 29, 29, 28
    dc.w    28, 28, 28, 28, 27, 27, 27, 27, 27, 27, 26, 26, 26, 26, 26, 26
    dc.w    25, 25, 25, 25, 25, 25, 25, 24, 24, 24, 24, 24, 24, 24, 23, 23
    dc.w    23, 23, 23, 23, 23, 23, 22, 22, 22, 22, 22, 22, 22, 22, 21, 21
    dc.w    21, 21, 21, 21, 21, 21, 21, 20, 20, 20, 20, 20, 20, 20, 20, 20
    dc.w    20, 20, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 18, 18, 18
    dc.w    18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 17, 17, 17, 17, 17, 17
    dc.w    17, 17, 17, 17, 17, 17, 17, 17, 16, 16, 16, 16, 16, 16, 16, 16

    even




; old hblank versions below





; ; ---------------------------------------------------------------------------
; ; hblank routine (dma palette version)
; ; ---------------------------------------------------------------------------
; HBlank_RoadPal1:
; 	move.w	#$8134,4(a6); turn off display	
; 	move.l	#$C0000080+(dma_target<<16),4(a6)
; 	move.w	#$8174,4(a6); turn on display

; 	move.w	#$9300+((dma_length>>1)&$FF),4(a6)
; 	move.w	#$9400+(((dma_length>>1)&$FF00)>>8),4(a6)
; 	move.w	#$9500+((Pal_Race1>>1)&$FF),4(a6)
; 	move.w	#$9600+(((Pal_Race1>>1)&$FF00)>>8),4(a6)
; 	move.w	#$9700+(((Pal_Race1>>1)&$7F0000)>>16),4(a6)

; 	move.w	#$8A00,(v_hbla_hreg).w		; trigger hblank every line now
; 	move.w	(v_hbla_hreg).w,4(a6)		; set next hblank trigger
; 	move.w	#HBlank_RoadPal2,(H_int_addr+2).w	; hblank code address to jump to
; 	rte

; HBlank_RoadPal2:
; 	move.w	#$8134,4(a6); turn off display	
; 	move.l	#$C0000080+(dma_target<<16),4(a6)
; 	move.w	#$8174,4(a6); turn on display
; 	move.w	#$9300+((dma_length>>1)&$FF),4(a6)
; 	move.w	#$9400+(((dma_length>>1)&$FF00)>>8),4(a6)
; 	move.w	#$9500+((Pal_Race2>>1)&$FF),4(a6)
; 	move.w	#$9600+(((Pal_Race2>>1)&$FF00)>>8),4(a6)
; 	move.w	#$9700+(((Pal_Race2>>1)&$7F0000)>>16),4(a6)
; 	move.w	#HBlank_RoadPal3,(H_int_addr+2).w	; hblank code address to jump to
; 	rte	

; HBlank_RoadPal3:
; 	move.w	#$8134,4(a6); turn off display	
; 	move.l	#$C0000080+(dma_target<<16),4(a6)
; 	move.w	#$8174,4(a6); turn on display
; 	move.w	#$9300+((dma_length>>1)&$FF),4(a6)
; 	move.w	#$9400+(((dma_length>>1)&$FF00)>>8),4(a6)
; 	move.w	#$9500+((Pal_Race1>>1)&$FF),4(a6)
; 	move.w	#$9600+(((Pal_Race1>>1)&$FF00)>>8),4(a6)
; 	move.w	#$9700+(((Pal_Race1>>1)&$7F0000)>>16),4(a6)
; 	move.w	#HBlank_RoadPal2,(H_int_addr+2).w	; hblank code address to jump to
; 	rte	

; ; ---------------------------------------------------------------------------
; ; hblank routine (hblank every line version)
; ; ---------------------------------------------------------------------------
; HBlank_oldRoad1:
; 	move.w	#$8A00,(v_hbla_hreg).w		; trigger hblank every line now
; 	move.w	(v_hbla_hreg).w,4(a6)		; set next hblank trigger
; 	move.w	#HBlank_oldRoad2,(H_int_addr+2).w	; hblank code address to jump to
; 	lea	Z_Map,a5
; ; a5 register should not be touched outside of this code / hblank code
; 	rte	

; HBlank_oldRoad2:
; 	move.l	d0,-(sp)
; 	move.l	#$40000010,4(a6)	; VSRAM write mode
; 	move.w	(v_roadscanline).w,d0
; 	add.w	(a5)+,d0
; 	move.w	d0,(v_roadscanline).w
; 	andi.w	#$400,d0
; 	bne.s	@stripe2
; 	move.l	#$001F0020,(a6)		; send screen y-axis pos. to VSRAM
; 	move.l	(sp)+,d0
; 	rte		
; @stripe2:
; 	move.l	#$001F00A0,(a6)		; send screen y-axis pos. to VSRAM
; 	move.l	(sp)+,d0
; 	rte

