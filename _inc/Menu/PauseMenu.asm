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
		jsr		WaitForVBla
		jsr		RunPLC
 		tst.l	(v_plc_buffer).w ; are there any items in the pattern load cue?
 		bne.s	WaitForPLC ; if yes, branch
; ---------------------------------------------------------------------------
; Create Map Screen
; ---------------------------------------------------------------------------
; first buffer map graphics to ram
		lea	(v_worldmap).w,a0		; table of revealed tiles
		lea	WorldMap,a1			; 4 x 4 tile mappings
		lea	Art_MapTiles,a2			; 5 x 5 tile graphics
		lea	(v_mapbuffer).l,a3		; temp ram to write graphics to
		moveq	#34,d3				; number of 5x5 rows to draw

@dorow:
		move.w	#79,d2				; number of 5x5 tiles to draw
		moveq	#0,d4				; bit to check
@dotile:	
		moveq	#0,d0
		move.b	(a1)+,d0			; get tile id to draw
	;	beq.s	@nexttile			; if blank tile, skip

		btst	d4,(a0)				; test current bit
		beq.s	@nexttile			; if 0, branch

		lsl.w	#5,d0				; multiply d0 by 16 (size of an 8x8 tile)
		lea	(a2,d0.w),a4			; get tile gfx start
		movea.l	a3,a5				; copy tile ram start

		moveq	#4,d1				; draw 5 rows of pixels
	@buffertile:
		move.l	(a5),d0	
		andi.l	#$FFF,d0
		add.l	(a4)+,d0
		move.l	d0,(a5)
		lea	160(a5),a5			; next line
		dbf	d1,@buffertile

	@nexttile:
		addq.w	#1,d4				; add 1 to bit to check
		cmpi.w	#8,d4							
		bne.s	@ok
		moveq	#0,d4				; set bit to check to 0
		adda.w	#1,a0				; add 1 to byte to check
	@ok:	
		lea	2(a3),a3			; get next tile ram location
		dbf	d2,@dotile

		lea	480(a3),a3			; start of next row ram 			
		dbf	d3,@dorow

; now send it to Vram
		lea	($C00000).l,a6
		locVRAM	$00A0*$20
		lea	(v_mapbuffer).l,a0 

		moveq	#17,d2
@transferrow:
		moveq	#39,d1				; number of 8x8 tiles to transfer
	@transfertile:
		movea.l	a0,a1
		move.l	(a1),(a6)
		lea	160(a1),a1						
		move.l	(a1),(a6)
		lea	160(a1),a1				
		move.l	(a1),(a6)
		lea	160(a1),a1						
		move.l	(a1),(a6)
		lea	160(a1),a1					
		move.l	(a1),(a6)
		lea	160(a1),a1					
		move.l	(a1),(a6)
		lea	160(a1),a1					
		move.l	(a1),(a6)
		lea	160(a1),a1					
		move.l	(a1),(a6)
		lea	4(a0),a0
		dbf	d1,@transfertile

		lea	$460(a0),a0			; start of next row ram
		dbf	d2,@transferrow


; ---------------------------------------------------------------------------
; decompress and DMA KosM menu GFX
; ---------------------------------------------------------------------------
		jsr	InitDMAQueue
	;	writeVRAM Art_MenuFont, $74*$20, $0000
		lea	(KosM_MenuFont).l,a1
		moveq	#$0000,d2
		jsr	(Queue_Kos_Module).l

@loadgfx:
		move.b  #$1A, (v_vbla_routine).w
		jsr	(Process_Kos_Queue).l
		jsr     WaitForVBla
		jsr	(Process_Kos_Module_Queue).l
		tst.b	(Kos_modules_left).w
		bne.s	@loadgfx


		bsr.w   RedrawFullMenu           	; Draw the menu
		jsr     PaletteFadeInFast

;========================================================================================================================
;
;  Menu Main Loop
;
;========================================================================================================================

PauseMenu_Main_Loop:
		move.b  #$1A, (v_vbla_routine).w
		jsr	(Process_Kos_Queue).l	
		jsr     WaitForVBla 
		moveq   #$00, D3                      ; d3 is used in calculating the VDP command for changing the palette of the highlighted item
		bsr     HighlightItem                 ; clear highlight
		bsr     MenuButtonHandling
		move.w  #$6000, D3                    ; palette line 3 will be set
		bsr     HighlightItem                 ; highlight item
		cmpi.b  #$4,(v_levselpage).w          ; viewing sound test?
		bne.s   @notsoundtest                 ; if not, branch
		bsr     DrawSoundTest
	@notsoundtest:
		lea	(v_objspace).w,a0 ; set address for object RAM
		bsr.w	MapPointerObject			  ; run 'you are here' object
		jsr	BuildSprites
		bsr.w   PauseMenu_DeformLayers
		jsr	(Process_Kos_Module_Queue).l

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


MapPointerObject:
        cmpi.b  #$1,(v_levselpage).w          ; viewing map?
        beq.s	@show_pointer
        rts
    @show_pointer:
		lea		(v_mappointerobj).l,a0
		tst.b	(a0)							; is object set up?
		bne.s	@pointer_display				; if so, branch

		move.b	#2,(a0)							; give it an id
		move.l	#Map_Pointer,obMap(a0)
		move.w	#$2000,obGfx(a0)
		move.b	#0,obRender(a0)
		move.w	#0,obPriority(a0)

		lea		WorldMapTopLeft,a1
		moveq	#0,d3
		move.b	(v_zone).w,d3                    ; get zone number
		lsl.w   #2,d3                            ; mult by 4 to get index number of first act in zone
		add.b   (v_act).w,d3                     ; add act number to get final index number
		lsl.w   #1,d3                            ; mutliply by 2 (number of bytes of data for each act)
		lea     (a1,d3),a1                       ; sets a3 to address of data		

		move.w	(v_player+obX).w,d0			; get player X position
		lsr.w	#8,d0						; divide by 512
		lsr.w	#1,d0						; divide by 512
		add.b	(a1)+,d0
		lsl.w	#2,d0						; multiply by 4 (pixels)
		add.w	#$83,d0						; add top corner of map display position
		move.w	d0,obX(a0)

		move.w	(v_player+obY).w,d1			; get player Y position
		lsr.w	#8,d1						; divide by 512
		lsr.w	#1,d1						; divide by 512
		add.b	(a1),d1
		lsl.w	#2,d1						; multiply by 4 (pixels)
		add.w	#$A3,d1						; add top corner of map display position
		move.w	d1,obScreenY(a0)

@pointer_display:
		lea		(Ani_Pointer).l,a1
		jsr		AnimateSprite
		jmp		DisplaySprite
; ===========================================================================
; Sprite mappings - generated by Flex - Sonic 1 format

Map_Pointer:
	dc.w AMY_Frame0-Map_Pointer, ZPE_Frame1-Map_Pointer
	dc.w ECI_Frame2-Map_Pointer, WRJ_Frame3-Map_Pointer
	dc.w RGO_Frame4-Map_Pointer, LSV_Frame5-Map_Pointer
	dc.w ALL_Frame6-Map_Pointer, NFL_Frame7-Map_Pointer

AMY_Frame0: dc.b  $1
	dc.b  $FC, $0, $0, $1, $FC
ZPE_Frame1: dc.b  $1
	dc.b  $F8, $5, $0, $2, $F8
ECI_Frame2: dc.b  $1
	dc.b  $F8, $5, $0, $6, $F8
WRJ_Frame3: dc.b  $1
	dc.b  $F8, $5, $0, $A, $F8
RGO_Frame4: dc.b  $1
	dc.b  $F8, $5, $0, $E, $F8
LSV_Frame5: dc.b  $1
	dc.b  $FC, $0, $0, $12, $FC
ALL_Frame6: dc.b  $1
	dc.b  $FC, $0, $0, $13, $FC
NFL_Frame7: dc.b  $1
	dc.b  $FC, $0, $0, $14, $FC
;-------------------------------------------------------------------------------
Ani_Pointer:
	dc.w @idle-Ani_Pointer
@idle:	dc.b $2, 0,0,0,0,0,0,1,2,3,4,5,6,7,afEnd
	even

; ===========================================================================
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

		lea		(v_mappointerobj).l,a0			; delete 'you are here' object
		moveq	#9,d0
	@delete_obj:
		clr.l	(a0)+
		dbf		d0,@delete_obj	

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

