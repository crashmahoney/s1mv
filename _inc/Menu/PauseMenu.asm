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
		move.l  #$23FF,d1
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
		jsr		PalLoad4_Water
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
		writeVRAM Art_MenuFont, $54*$20, $0020*$20
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
                move.b  #$1A, (v_vbla_routine).w
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
        jsr	    (InitDMAQueue).l
		clr.w	(v_sgfx_buffer).w              ; +++ ProcessDMAQueue crap
		move.w	#v_sgfx_buffer,(v_vdp_buffer_slot).w   ; +++
		clr.b   (v_levelselnofade).w

@loadLZ
 		cmpi.b	#id_LZ,(v_zone).w 		; is level LZ?
 		bne.s	@endload				; if not, branch
		move.b	#1,(f_water).w			; enable water
		moveq	#palid_LZSonWater,d0 	; palette number $F (LZ)
		cmpi.b	#3,(v_act).w			; is act number 3?
		bne.s	@Level_ChkWaterPal		; if not, branch
		moveq	#palid_SBZ3SonWat,d0 	; palette number $10 (SBZ3)
    @Level_ChkWaterPal:
		moveq	#palid_LZWater,d0 		; palette $B (LZ underwater)
		cmpi.b	#3,(v_act).w			; is level SBZ3?
		bne.s	@Level_WtrNotSbz		; if not, branch
		moveq	#palid_SBZ3Water,d0 	; palette $D (SBZ3 underwater)

	@Level_WtrNotSbz:
		jsr     PalLoad4_Water
		move.b	($FFFFFE53).w,(f_wtr_state).w
        moveq	#palid_LZ,d0
 		jsr	     PalLoad1

@endload:
        jsr		DeformLayers
		bset	#2,(v_bgscroll1).w
		jsr		ExecuteObjects
		jsr		BuildSprites
		moveq	#palid_Sonic,d0
		jsr		PalLoad1				; load Sonic's palette
        jsr     LoadZoneTiles   			; load level art
        jsr     LevelDataLoad
		jsr		LoadTilesFromStart
        move.b  #1,(f_scorecount)             ; set hud icons to update
		jsr     HUD_Update      		; update the hud gfx
        move    #$2300, SR              ; interrupt mask level 3
 		jsr     PaletteFadeInFast
 		move.w	#0,(f_pause).w			; unpause the game
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

