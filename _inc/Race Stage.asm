v_roadxpos	=	$FFFFF000	; word
v_roadxoffset	=	$FFFFF002	; word
v_roadspeed	=	$FFFFF004	; long (fixed point)
v_roadzpos	=	$FFFFF008	; word
v_skyxpos	=	$FFFFF00A	; long (fixed point)
v_roadscanline	=	$FFFFF00E	; word
v_roadcurve	=	$FFFFF010	; word

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
		move.w	#$8134,(a6)			; enable vblank
		move.w	#$8200+(vram_fg>>10),(a6) 	; set foreground nametable address
		move.w	#$8400+($A000>>13),(a6) 	; set background nametable address
		move.w	#$8500+(vram_sprites>>9),(a6) 	; set sprite table address
		move.w	#$8700,(a6)			; set background colour (palette entry 0)
		move.w	#$8B03,(a6)			; line scroll mode
		move.w	#$9003,(a6)			; 128 x 32-cell plane size
		clr.w	(v_sgfx_buffer).w			; +++ ProcessDMAQueue crap
		move.w	#v_sgfx_buffer,(v_vdp_buffer_slot).w   ; +++
		clr.b	(f_wtr_state).w

		move.w	#0,(f_hbla_pal).w
		bsr.w	ClearScreen

; set starting values
	move.w	#0,(v_roadxpos).l		; starting x position
	move.w	#0,(v_roadxoffset).l		; starting x offset
	move.w	#0,(v_roadspeed).l		; starting speed


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

		move	#$2300,sr			; interrupts on

		move.b  #$1C, (v_vbla_routine).w
		jsr	(Process_Kos_Queue).l
		jsr     WaitForVBla
	;	move	#$2700,sr			; interrupts off
; load road mappings		
		lea	($FF0000).l,a1
		lea	(Eni_RaceRoad).l,a0 		; load road mappings
		move.w	#0,d0
		bsr.w	EniDec
		copyTilemap	$FF0000,$A000,63,63
; load sky mappings
		move.b  #$1C, (v_vbla_routine).w
		jsr	(Process_Kos_Queue).l
		jsr     WaitForVBla
		lea	($FF0000).l,a1
		lea	(Eni_RaceSky).l,a0 		; load road mappings
		move.w	#4,d0				; offset
		bsr.w	EniDec
		copyTilemap	$FF0000,$C000,63,31


; load palette		
		moveq	#palid_Race,d0
  		bsr.w	PalLoad2			; load race stage palette

; turn on display			
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		move.w	#$8014,($C00004).l	; enable H-interrupts
		move.l	#HBlank_Road1,(H_int_addr).w  ; hblank code address to jump to
		move.w	#$8A00+48,(v_hbla_hreg).w ; set hblank trigger scanline /2
		move.w	(v_hbla_hreg).w,($C00004).l
		move.l	#$40000010,($C00004).l
		move.l	#$00200020,($C00000).l
	;	bsr.w	PaletteWhiteIn
; ---------------------------------------------------------------------------
; Main Loop ;)

Race_MainLoop:
	move.b	#$1C,(v_vbla_routine).w
	jsr	(Process_Kos_Queue).l
	bsr.w	WaitForVBla
	move.w	#$8014,($C00004).l	; enable H-interrupts

		

; add speed to road position
	moveq	#0,d0
	move.w	(v_roadzpos).w,d0
	add.w	(v_roadspeed).w,d0
	move.w	d0,(v_roadzpos).w
	move.w	d0,(v_roadscanline).w
; reset screen y position
	move.l	#$001F0020,(v_scrposy_dup).w
	bsr.w	DeformRoadLayers

	addq.w	#1,(v_framecount).w		; add 1 to level timer

; joypad
@move:
	move.b	(v_jpadhold1).w,d0

	btst	#bitA,d0			; is A pressed?
	beq.s	@chkB
	sub.l	#$0000C000,(v_roadcurve).w	; change road curve
@chkB:
	btst	#bitB,d0			; is B pressed?
	beq.s	@chkL
	add.l	#$0000C000,(v_roadcurve).w	; change road curve
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
; generate line scroll list
; ---------------------------------------------------------------------------
DeformRoadLayers:
	lea	(v_scrolltable).w,a1		; ($FFFFCC00)
	moveq	#0,d0
	move.l	(v_skyxpos).l,d0		; plane a x position
	add.l	#$00004000,(v_skyxpos).w	; add 0.4
	move.w	#0,d0				; clear for plane b			
	moveq	#96,d2				; # lines of sky
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
	sub.w	#352,d1				; centre on screen by subtracting (half of plane width - half of screen width) 

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
 	lea	Z_map,a0
	lea	(v_scrolltable+(96*4)).w,a1
@curveloop:
	move.w	(a0)+,d0			; get z map value
	muls.w	d1,d0				; multiply by curve amount
	lsr.w	#6,d0				; divide by 64
;	andi.w	#$2FF,d0			; restrict to 256 px
	add.l	d0,(a1)+
	dbf	d2,@curveloop

; 	moveq	#1,d0
; 	moveq	#0,d1
; 	lea	Z_map,a0
; @roadloop2:
; 	move.w	(a0)+,d1
; 	lsr.w	#4,d1

; @roadloop3:	
; 	add.l	d0,-(a1)	
; 	dbf	d1,@roadloop3

; 	addq	#1,d0

; 	cmpa.l	#v_scrolltable+96*4,a1
; 	bhi.s	@roadloop2

	rts

; ---------------------------------------------------------------------------
; hblank routine
; ---------------------------------------------------------------------------
HBlank_Road1:
		move.w	#$8A00,(v_hbla_hreg).w		; trigger hblank every line now
		move.w	(v_hbla_hreg).w,($C00004).l	; set next hblank trigger
		move.w	#HBlank_Road2,(H_int_addr+2).w	; hblank code address to jump to
		lea	Z_Map,a5
; a5 register should not be touched outside of this code / hblank code
		rte

HBlank_Road2:
		move.w	(v_roadscanline).w,d0
		add.w	(a5)+,d0
		move.w	d0,(v_roadscanline).w
		andi.w	#$400,d0
		bne.s	@stripe2

		move.l	#$40000010,($C00004).l
		move.l	#$001F0020,($C00000).l		; send screen y-axis pos. to VSRAM
		rte		
	@stripe2:
		move.l	#$40000010,($C00004).l
		move.l	#$001F00A0,($C00000).l		; send screen y-axis pos. to VSRAM
		rte	

; ---------------------------------------------------------------------------

Pal_Race:
		incbin	"palette\Race Stage.bin"
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

    even

