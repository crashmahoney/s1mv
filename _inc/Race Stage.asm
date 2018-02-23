
GM_Race:

	;bra.s	@soundtest
		move.b	#musFadeOut,d0
		jsr	PlaySound_Special 		; stop music
		bsr.w	ClearPLC
		bsr.w	PaletteWhiteOut
	; turn off display	
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l

		move	#$2700,sr			; Mask all interrupts
		lea	($C00004).l,a6
		move.w	#$8004,(a6)			; use 8-colour mode
		move.w	#$8134,(a6)			; enable vblank
		move.w	#$8200+(vram_fg>>10),(a6) 	; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) 	; set background nametable address
		move.w	#$8500+(vram_sprites>>9),(a6) 	; set sprite table address
		move.w	#$8700,(a6)			; set background colour (palette entry 0)
		move.w	#$8B03,(a6)			; line scroll mode
		move.w	#$9011,(a6)			; 64 x 64-cell plane size
		clr.w	(v_sgfx_buffer).w			; +++ ProcessDMAQueue crap
		move.w	#v_sgfx_buffer,(v_vdp_buffer_slot).w   ; +++
		clr.b	(f_wtr_state).w


		move.w	#0,(f_hbla_pal).w
		bsr.w	ClearScreen
		andi.w	#btnABC,(v_Ctrl1Held).w ; is a button being held?
		beq.s	@nosoundtest	; if not, branch
	@soundtest:
                move.b  #$04, (v_levselpage).w  ; choose sound test menu
                move.b  #$01, (v_menupagestate).l  ; go straight to menu
                jmp     Pause_Menu               ; go to menu
       @nosoundtest:



		jsr	InitDMAQueue

		lea	(KosM_RaceRoad).l,a1		; moduled art to load
		moveq	#$0020,d2			; vram location to load to
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

		lea	($FF0000).l,a1
		lea	(Eni_RaceRoad).l,a0 		; load road mappings
		move.w	#0,d0
		bsr.w	EniDec

		copyTilemap	$FF0000,$C000,63,31

		move	#$2300,sr
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

	;	bsr.w	PaletteWhiteIn

; ---------------------------------------------------------------------------
; Main Loop ;)

Race_MainLoop:

		lea	($FFFF4000).l,a0
		moveq	#0,d0
		moveq	#0,d1
		moveq	#127,d2
	@loop:	
		move.w	d0,(a0)+
		add.w	#4,d1
		add.w	d1,d0
		dbf	d2,@loop




		move.b	#$1C,(v_vbla_routine).w
		jsr	(Process_Kos_Queue).l
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w		; add 1 to level timer
		jsr	(Process_Kos_Module_Queue).l

		move.w  (v_Ctrl1Press).w, D0
		andi.b	#btnStart,d0	              ; is start pressed?
		bne.s   @startpressed

		cmpi.b	#id_Race,(v_gamemode).w
		beq	Race_MainLoop
@startpressed:
		move.b	#id_Title,(v_gamemode).w ; set Game Mode to Sega Screen
		rts	; return to game mode select code





; ---------------------------------------------------------------------------

Pal_Race:
		incbin	"palette\Race Stage.bin"
		even
