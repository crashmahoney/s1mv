;===============================================================================
; PAUSE MENU
;===============================================================================
;-------------------------------------------------------------------------------
Pause_Menu:
                jsr     PaletteFadeOutFast
                moveq   #0,d0
                move    #$2700, sr              ; interrupt mask level 7
                move.w  (v_vdp_buffer1).w, D0
                andi.b  #$BF, D0
                move.w  D0, ($00C00004)

		lea	($C00000).l,a6
		move.w	#0,(f_hbla_pal).w
;		move.w	#$8004,(a6)	; disable H-interrupts

;===============================================================================
; ClearScreen partial copy
;=============================

       		fillVRAM	$FF,$FFF,vram_fg ; clear foreground namespace
	@wait1:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	@wait1

		move.w	#$8F02,(a5)
		fillVRAM	$FF,$FFF,vram_bg ; clear background namespace
	@wait2:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	@wait2

		move.w	#$8F02,(a5)
		clr.l	(v_scrposy_dup).w
; --------------------------------------------------------------------------
		moveq	#0,d0
; --------------------------------------------------------------------------
		lea	(v_sprites).w,a1           ; clear sprite table (in RAM)
		move.w	#$A0,d1
	@clearsprites:
		move.l	d0,(a1)+
		dbf	d1,@clearsprites 
; --------------------------------------------------------------------------
                lea     (v_256x256).l, a1          ; clear all 256x256 tiles
                move.l  #$C00,d1
           @clrloop:
                move.l	d0,(a1)+         
		dbf	d1,@clrloop
; --------------------------------------------------------------------------
                lea     (v_16x16).w,a1             ; clear 16x16 tiles
                move.w  #$7FF,d1
@clr16x16loop:
                move.l  d0,(a1)+
                dbra    d1, @clr16x16loop
;===============================================================================
; load palette
                moveq   #palid_Menu_Palette, D0
                jsr     PalLoad1
                moveq   #palid_Menu_Palette, D0
		jsr	PalLoad4_Water
                lea     ($FFFFFB40).w, A1
                lea     ($FFFFFBC0).w, A2
                moveq   #$07, D1
@loop:
                move.l  (A1), (A2)+
                clr.l   (A1)+
                dbra    D1, @loop

                move.b  #$18, (v_vbla_routine).w
                jsr     WaitForVBla
                move.w  (v_vdp_buffer1).w, D0
                ori.b   #$40, D0
                move.w  D0, ($00C00004)
WaitForPLC:
                move.b	#$C,(v_vbla_routine).w
		jsr	WaitForVBla
                jsr	RunPLC
 		tst.l	(v_plc_buffer).w ; are there any items in the pattern load cue?
 		bne.s	WaitForPLC ; if yes, branch
; ---------------------------------------------------------------------------
; DMA uncompressed menu GFX
; ---------------------------------------------------------------------------
               writeVRAM Art_MenuFont, $54*$20, $B000
;               writeVRAM Art_MenuBG,   $0CA0, $D000

                bsr.w   RedrawFullMenu           ; Draw the menu
                jsr     PaletteFadeInFast

;========================================================================================================================
;
;  Menu Main Loop
;
;========================================================================================================================

PauseMenu_Main_Loop:
                moveq   #$00, D3                      ; d3 is used in calculating the VDP command for changing the palette of the highlighted item
                bsr     HighlightItem                 ; clear highlight
                bsr     MenuButtonHandling
                move.w  #$6000, D3                    ; palette line 3 will be set
                bsr     HighlightItem                 ; highlight item
                cmpi.b  #$4,(v_levselpage).w          ; viewing sound test?
                bne.s   @notsoundtest                 ; if not, branch
                bsr     DrawSoundTest
       @notsoundtest:
                bsr.w   PauseMenu_DeformLayers
                move.b  #$12, (v_vbla_routine).w
                jsr     WaitForVBla
                move    #$2300, SR                    ; interrupt mask level 3
                move.b  (v_jpadpress1).w, D0
		andi.b	#btnStart,d0	              ; is start pressed?
                bne.s   @startpressed
                bra     PauseMenu_Main_Loop
;========================================================================================================================
		include	"_inc\menu\Button Handling.asm"
		include	"_inc\menu\Highlight Item.asm"
		include	"_inc\menu\Draw Menu.asm"
		include	"_inc\menu\Draw Inventory.asm"
		include	"_inc\menu\Draw Description.asm"
		include	"_inc\menu\Draw Stats.asm"
		include	"_inc\menu\Draw Decimal.asm"
		include	"_inc\menu\Draw Hex.asm"
		include	"_inc\menu\Draw Backer.asm"
		include	"_inc\menu\Draw Generic Text.asm"
        include "_inc\menu\Draw Sound Test.asm"
        include "_inc\menu\Deform Layers.asm"

;-------------------------------------------------------------------------------
PauseMenu_Code_Test:
                move.w  ($FFFFFF0C).w, D0
                adda.w  D0, A0
                move.w  (v_levselsound).w, D0
                cmp.b   (A0), D0
                bne.s   PauseMenu_Reset_Debug_Mode_Code_Counter
                addq.w  #$01, ($FFFFFF0C).w
                tst.b   $0001(A0)
                bpl.s   PauseMenu_All_Emeralds_Code_Test 
                move.w  #$0101, (A1)
                bra     PauseMenu_Set_Debug_Flag 
PauseMenu_Reset_Debug_Mode_Code_Counter: 
                move.w  #$0000, ($FFFFFF0C).w
PauseMenu_All_Emeralds_Code_Test: 
                move.w  ($FFFFFF0E).w, D0
                adda.w  D0, A2
                move.w  (v_levselsound).w, D0
                cmp.b   (A2), D0
                bne.s   PauseMenu_Reset_All_Emerald_Code_Counter 
                addq.w  #$01, ($FFFFFF0E).w
                tst.b   $0001(A2)
                bpl.s   PauseMenu_Code_Not_0xFF 
                tst.w   D2
                bne.s   PauseMenu_Set_All_Emeralds 
PauseMenu_Set_Debug_Flag: 
                move.b  #$01, (Slow_Motion_Flag).w
                move.b  #$01, (Debug_Mode_Flag).w
                move.b  #Ring_Snd, D0
                jsr     PlaySound
                bra.s   PauseMenu_Reset_All_Emerald_Code_Counter 
PauseMenu_Set_All_Emeralds: 
                move.w  #$0006, ($FFFFFE56).w
                move.b  #Emerald_Snd2, D0
                jsr     PlaySound
PauseMenu_Reset_All_Emerald_Code_Counter: 
                move.w  #$0000, ($FFFFFF0E).w
PauseMenu_Code_Not_0xFF: 
                rts               




;===============================================================================
;
; Return to Game
;
;===============================================================================
ExitPauseMenu:
                move    #$2700, SR                    ; interrupt mask level 7
	        jsr     PaletteFadeOutFast
                move.b  #1,(f_scorecount)             ; set hud icons to update
;-------------------------------------------------------------------------------
; check if title card is on screen
;-------------------------------------------------------------------------------
FindTitleCard:
		lea	(v_objspace+$80).w,a1
		move.w	#3,d0
	@FCard_Loop:
		tst.b	(a1)	; is object there?
		beq.s	@continue; if not, branch
                writeVRAM Art_TitleCard, $1000, $B000
                bra.s   Loadeverythingelse
        @continue:
                lea	$40(a1),a1	; goto next object RAM slot
		dbf	d0,@FCard_Loop
; --------------------------------------------------------------------------
FindPowerUpCard:
		lea	(v_objspace+$5C0).w,a1
		move.w	#3,d0
	@FCard_Loop:
		tst.b	(a1)	; is object there?
		beq.s	@continue; if not, branch
                writeVRAM Art_BigFont, $1000, $B000
                bra.s   Loadeverythingelse
        @continue:
                lea	$40(a1),a1	; goto next object RAM slot
		dbf	d0,@FCard_Loop
;-------------------------------------------------------------------------------
; if no title card then load explosions and animals
;-------------------------------------------------------------------------------
                move    #$2700, SR                    ; interrupt mask level 7
		locVRAM	$B000
		lea	(Nem_Rabbit).l,a0 ; load animal 1
		jsr	NemDec
		lea	(Nem_Chicken).l,a0 ; load animal 2
		jsr	NemDec
		lea	(Nem_Explode).l,a0 ; load explosions
		jsr	NemDec
;-------------------------------------------------------------------------------
; load remaining replaced gfx
;-------------------------------------------------------------------------------
Loadeverythingelse:
                move    #$2700, SR                    ; interrupt mask level 7
		locVRAM	$D000
		lea	(Nem_Monitors).l,a0
		jsr	NemDec

		locVRAM	$D800
		lea	(Nem_Lamp).l,a0
		jsr	NemDec

		locVRAM	$D9C0
		lea	(Nem_Hud).l,a0
		jsr	NemDec

		locVRAM	$DD40
		lea	(Nem_Homing).l,a0
		jsr	NemDec

                jsr     LevelDataLoad
; 		lea	($C00004).l,a6
; 		move.w	#$8B03,(a6)	; line scroll mode
; 		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
; 		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
; 		move.w	#$8500+(vram_sprites>>9),(a6) ; set sprite table address
; 		move.w	#$9001,(a6)		; 64-cell hscroll size
; 		move.w	#$8004,(a6)		; 8-colour mode
; 		move.w	#$8720,(a6)		; set background colour (line 3; colour 0)
; 		move.w	#$8A00+223,(v_hbla_hreg).w ; set palette change position (for water)
; 		move.w	(v_hbla_hreg).w,(a6)

;                 lea     (v_sgfx_buffer).w,a0
;                 move.l  #$100,d0
;          @clearDMAqueue:
;                 move.b  #0,(a0)+
;                 dbf     d0,@clearDMAqueue

                jsr	(InitDMAQueue).l
		clr.w	(v_sgfx_buffer).w              ; +++ ProcessDMAQueue crap
		move.w	#v_sgfx_buffer,(v_vdp_buffer_slot).w   ; +++
		clr.b   (v_levelselnofade).w

@loadLZ
 		cmpi.b	#id_LZ,(v_zone).w ; is level LZ?
 		bne.s	@endload	; if not, branch
;  		move.w	(v_hbla_hreg).w,(a6)
;  		move.w	#$8A00+223,(v_hbla_hreg).w ; set palette change position (for water)
; 		move.w	#$8014,(a6)	; enable H-interrupts
		move.b	#1,(f_water).w	; enable water
		moveq	#palid_LZSonWater,d0 ; palette number $F (LZ)
		cmpi.b	#3,(v_act).w	; is act number 3?
		bne.s	@Level_WaterPal	; if not, branch
		moveq	#palid_SBZ3SonWat,d0 ; palette number $10 (SBZ3)

	@Level_WaterPal:
;		jsr	PalLoad3_Water	; load underwater palette

        @Level_ChkWaterPal:
		moveq	#palid_LZWater,d0 ; palette $B (LZ underwater)
		cmpi.b	#3,(v_act).w	; is level SBZ3?
		bne.s	@Level_WtrNotSbz	; if not, branch
		moveq	#palid_SBZ3Water,d0 ; palette $D (SBZ3 underwater)

	@Level_WtrNotSbz:
		jsr	PalLoad4_Water
		move.b	($FFFFFE53).w,(f_wtr_state).w
                moveq	#palid_LZ,d0
 		jsr	PalLoad1

@endload:
         	jsr	DeformLayers
		bset	#2,(v_bgscroll1).w
		jsr	LoadTilesFromStart
		jsr	ExecuteObjects
		jsr	BuildSprites
		moveq	#palid_Sonic,d0
		jsr	PalLoad1	; load Sonic's palette
		jsr     HUD_Update      ; update the hud gfx
                move    #$2300, SR                    ; interrupt mask level 3
 		jsr     PaletteFadeInFast
 		move.w	#0,(f_pause).w	; unpause the game
                rts

; --------------------------------------------------------------------------
		include	"_inc\menu\Pause Menu Text.asm"
		even
		include	"_inc\menu\Inventory Items.asm"
		even
		include	"_inc\menu\AbilitiesEquippable.asm"
		even
		include	"_inc\menu\AbilitiesAlwaysOn.asm"
		even
		include	"_inc\menu\Equippable Items.asm"
		even
		include	"_inc\menu\Shoes.asm"
		even

