v_roadxpos	=	$FFFF5000
v_roadxoffset	=	$FFFF5002
v_roadspeed	=	$FFFF5004
v_roadspeedmult	=	$FFFF5006

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
	move.w	#200,(v_roadspeed).l		; starting speed

	; generate hblank scroll list
		lea	($FFFF4000).l,a0	; buffer location
		move.w	#127,d2			; 127 list entries
		moveq	#0,d1			
		move.w	#$7F00,d0
	@loop:	
		move.w	d0,(a0)+
		add.l	#$00053000,d1
		swap	d1
		sub.w	d1,d0
		swap	d1
		dbf	d2,@loop

		jsr	InitDMAQueue

;load tile graphics
		lea	(KosM_RaceRoad).l,a1		; moduled art to load
		moveq	#$0000,d2			; vram location to load to
		jsr	(Queue_Kos_Module).l		; add to queue
		lea	(KosM_RaceSky).l,a1		; moduled art to load
		move.l	#$C0*$20,d2			; vram location to load to
		jsr	(Queue_Kos_Module).l		; add to queue
@loadgfx:
		move.b  #$1C, (v_vbla_routine).w
		jsr	(Process_Kos_Queue).l
		jsr     WaitForVBla
		jsr	(Process_Kos_Module_Queue).l
		tst.b	(Kos_modules_left).w
		bne.s	@loadgfx

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
		move.w	#0,d0
		bsr.w	EniDec
		copyTilemap	$FF0000,$C000,63,31

	;	move	#$2300,sr			; interrupts on

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

; reset screen y position
	lea	($FFFF4100).l,a5
	moveq	#0,d0
	move.w	(v_framecount).w,d0
	muls.w	(v_roadspeed).l,d0		; multiply by speed
	move.w	d0,(v_roadspeedmult).l
	move.l	#$00200020,(v_scrposy_dup).w
	bsr.w	DeformRoadLayers

	addq.w	#1,(v_framecount).w		; add 1 to level timer

;	move.w	#$0648,(v_pal1_wat+$24).w	; flicker road colour
;	btst	#0,(v_framecount+1).w
;	beq.s	@odd
;	move.w	#$0848,(v_pal1_wat+$24).w	; flicker road colour
;@odd:

; joypad
@move:
	move.b	(v_jpadhold1).w,d0

	btst	#bitL,d0			; is left pressed?
	beq.s	@chkR
	add.w	#1,(v_roadxoffset).l		; add to x position
@chkR:
	btst	#bitR,d0			; is left pressed?
	beq.s	@accel
	sub.w	#1,(v_roadxoffset).l		; sub from x position
@accel:
	btst	#bitUp,d0			; is up pressed?
	beq.s	@decel
	add.w	#2,(v_roadspeed).l		; add to speed
@decel:
	btst	#bitDn,d0			; is down pressed?
	beq.s	@chkStart
	sub.w	#2,(v_roadspeed).l		; sub from speed
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
;	move.w	(v_roadxpos).l,d0		; x position plane b (road)
;	swap	d0
;	move.w	(v_roadxpos).l,d0		; x position plane a	
	moveq	#96,d2				; # lines of sky
@skyloop:	
	move.l	d0,(a1)+			
	dbf	d2,@skyloop

	moveq	#127,d2				; # lines of road
	moveq	#0,d1				 
	moveq	#0,d3
	move.w	(v_roadxoffset).l,d3		; distance offset
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
	rts

; ---------------------------------------------------------------------------
; hblank routine
; ---------------------------------------------------------------------------



HBlank_Road1:
		move.w	#$8A00,(v_hbla_hreg).w		; trigger hblank every line now
		move.w	(v_hbla_hreg).w,($C00004).l	; set next hblank trigger
		move.w	#HBlank_Road2,(H_int_addr+2).w	; hblank code address to jump to
		rte

HBlank_Road2:
		move.w	d0,-(sp)			; push d0 to stack
		move.w	-(a5),d0
		sub.w	(v_roadspeedmult).l,d0
		btst	#12,d0
		beq.s	@road2
	@road1:
		move.l	#$40000010,($C00004).l
		move.l	#$00200020,($C00000).l		; send screen y-axis pos. to VSRAM
		move.w	(sp)+,d0			; pull d0 from stack
		rte		

	@road2:
		move.l	#$40000010,($C00004).l
		move.l	#$002000A0,($C00000).l		; send screen y-axis pos. to VSRAM
		move.w	(sp)+,d0			; pull d0 from stack
		rte	





; ---------------------------------------------------------------------------

Pal_Race:
		incbin	"palette\Race Stage.bin"
		even