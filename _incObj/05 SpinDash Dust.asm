; ---------------------------------------------------------------------------
; Object 05 - SpinDash Dust
; ---------------------------------------------------------------------------

SpinDash_dust:					; XREF: Obj_Index

Sprite_1DD20:				; DATA XREF: ROM:0001600C?o
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move	Dust_OffsetTable(pc,d0.w),d1
		jmp	Dust_OffsetTable(pc,d1.w)
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Dust_OffsetTable: dc SD_Dust_Init-Dust_OffsetTable; 0 ; DATA XREF: h+6DBA?o h+6DBC?o ...
		dc SD_Dust_Main-Dust_OffsetTable; 1
		dc SD_Dust_BranchTo16_DeleteObject-Dust_OffsetTable; 2
		dc SD_Dust_CheckSkid-Dust_OffsetTable; 3
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 
SD_Dust_Init:				; DATA XREF: h+6DBA?o
		addq.b	#2,obRoutine(a0)
		move.l	#SD_MapUnc,obMap(a0)         ; set mappings
		or.b	#4,obRender(a0)              ; set render flags
		move.w	#$80,obPriority(a0)            ; set object priority (to back, i think)
		move.b	#$10,obActWid(a0)            ; set width
		move	#$7A0,obGfx(a0)              ; is this in s2 diasm: move.w	#make_art_tile(ArtTile_ArtNem_SonicDust,0,0),art_tile(a0)
		move	#-$3000,$3E(a0)              ; move.w	#MainCharacter,parent(a0)
		move	#$F400,$3C(a0)               ; move.w	#tiles_to_bytes(ArtTile_ArtNem_SonicDust),objoff_3C(a0)
		cmp	#-$2E40,a0                   ; cmpa.w	#Sonic_Dust,a0
		beq.s	loc_1DD8C
		move.b	#1,$34(a0)
;		cmp	#2,($FFFFFF70).w
;		beq.s	loc_1DD8C
;		move	#$48C,obGfx(a0)              ; these lines are for s2, for tails' dust
;		move	#-$4FC0,$3E(a0)
;		move	#-$6E80,$3C(a0)
 
loc_1DD8C:				; CODE XREF: h+6DF6?j h+6E04?j
;		bsr.w	sub_16D6E
 
SD_Dust_Main:				; DATA XREF: h+6DBA?o
		movea.w	$3E(a0),a2                   ; puts sonic's address in a2 (i think)
		moveq	#0,d0
		move.b	obAnim(a0),d0                ; use current animation as a secondary routine counter
		add	d0,d0
		move	SD_Dust_DisplayModes(pc,d0.w),d1
		jmp	SD_Dust_DisplayModes(pc,d1.w)
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SD_Dust_DisplayModes:	dc SD_Dust_Display-SD_Dust_DisplayModes; 0 ; DATA XREF: h+6E30?o h+6E32?o ...
		dc SD_Dust_DisplaySplash-SD_Dust_DisplayModes; 1
		dc SD_Dust_DisplayDust-SD_Dust_DisplayModes; 2
		dc SD_Dust_DisplaySkidDust-SD_Dust_DisplayModes; 3
		dc SD_Dust_DisplayWaterSpray-SD_Dust_DisplayModes; 4
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

SD_Dust_DisplaySplash:				; DATA XREF: h+6E30?o
		move.w	(v_waterpos1).w,obY(a0)
		tst.b	obNextAni(a0)
		bne.w	SD_Dust_Display
		move.w	obX(a2),obX(a0)
		move.b	#0,obStatus(a0)
		andi.w	#$7FFF,obGfx(a0)
		bra.w	SD_Dust_Display
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 
SD_Dust_DisplayDust:				; DATA XREF: h+6E30?o
; 		cmp.b	#$C,$28(a2)             ; checks air left
; 		bcs.w	SD_Dust_ResetDisplayMode
		cmp.b	#4,obRoutine(a2)
		bcc.w	SD_Dust_ResetDisplayMode
		tst.b	SpinDashFlag(a2)
		beq.w	SD_Dust_ResetDisplayMode
		move	obX(a2),obX(a0)
		move	obY(a2),obY(a0)
	        cmp.b	#id_DashCharge,obAnim(a2)
	        bne.s   @notpeelout
                btst.b   #staFacing,obStatus(a2)
                bne.s   @left
                sub.w   #7,obX(a0)          ; adjust x pos
                bra.s   @notpeelout
          @left:
                add.w   #7,obX(a0)          ; adjust x pos
          @notpeelout:
		move.b	obStatus(a2),obStatus(a0)
		and.b	#1,obStatus(a0)
		tst.b	$34(a0)
		beq.s	loc_1DE06
		sub	#4,obY(a0)
 
loc_1DE06:				; CODE XREF: h+6E8A?j
		tst.b	obNextAni(a0)
		bne.w	SD_Dust_Display
		and	#$7FFF,obGfx(a0)
		tst	obGfx(a2)
		bpl.s	SD_Dust_Display
		or	#-$8000,obGfx(a0)
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 
SD_Dust_DisplaySkidDust:				; DATA XREF: h+6E30?o
                bra.w   SD_Dust_Display
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

SD_Dust_DisplayWaterSpray:				; DATA XREF: h+6E30?o
		move.w	#0,obPriority(a0)            ; set object priority (to front, i think)
		cmp.b	#4,obRoutine(a2)
		bcc.s	SD_Dust_ResetDisplayMode
		move.w	(v_waterpos1).w,d6
                sub.w   #$12,d6
                sub.w   obY(a2),d6
                cmpi.w  #2,d6             ; is sonic within 2 px of water level?
                bcc.s   SD_Dust_ResetDisplayMode
		move	obX(a2),obX(a0)
		move	obY(a2),obY(a0)
		move.b	obStatus(a2),obStatus(a0)
		and.b	#1,obStatus(a0)
		bclr    #0,obStatus(a0)
                move.w  (v_player+obVelX).w,d1
                tst.w	d1			; is his speed positive? (is he running to the right?)
		bpl.s	@dontflip	        ; if yes, branch
		bset    #0,obStatus(a0)
       @dontflip:
		tst.b	$34(a0)
		beq.s	loc_1DE06Spray
		sub	#4,obY(a0)
 
loc_1DE06Spray:				; CODE XREF: h+6E8A?j
		tst.b	obNextAni(a0)
		bne.s	SD_Dust_Display
		and	#$7FFF,obGfx(a0)
		tst	obGfx(a2)
		bpl.s	SD_Dust_Display
		or	#-$8000,obGfx(a0)
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SD_Dust_Display:				; CODE XREF: h+6E42?j h+6E56?j ...
		lea	(SD_Dust_Animations).l,a1
		jsr	(AnimateSprite).l
		bsr.w	SD_Dust_LoadArt
		jmp	DisplaySprite
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 
SD_Dust_ResetDisplayMode:				; CODE XREF: h+6E5E?j h+6E66?j ...
		move.b	#0,obAnim(a0)
		rts	
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 
SD_Dust_BranchTo16_DeleteObject:				; DATA XREF: h+6DBA?o
		bra.w	DeleteObject
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 
 
 
SD_Dust_CheckSkid:
	movea.w	$3E(a0),a2         ; move sonic's address to a2
	moveq	#$10,d1
	cmp.b	#id_Stop,obAnim(a2)
	beq.s	SD_Dust_SkidDust
	moveq	#$6,d1
	cmp.b	#$3,obColProp(a2)
	beq.s	SD_Dust_SkidDust   ; if not, branch
	move.b	#2,obRoutine(a0)
	move.b	#0,$32(a0)
	rts
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 
SD_Dust_SkidDust:				; CODE XREF: h+6EE0?j
		subq.b	#1,$32(a0)
		bpl.s	loc_1DEE0
		move.b	#3,$32(a0)
		jsr	(FindFreeObj).l ; was SingleObjLoad, I think it was renamed to this
		bne.s	loc_1DEE0
		move.b	0(a0),0(a1)             ; load dust obj
		move	obX(a2),obX(a1)
		move	obY(a2),obY(a1)
		tst.b	$34(a0)
		beq.s	loc_1DE9A
		sub	#4,d1
 
loc_1DE9A:				; CODE XREF: h+6F1E?j
		add	d1,obY(a1)
		move.b	#0,obStatus(a1)
		move.b	#3,obAnim(a1)
		addq.b	#2,obRoutine(a1)
		move.l	obMap(a0),obMap(a1)
		move.b	obRender(a0),obRender(a1)
		move.w	#$80,obPriority(a1)
		move.b	#4,obActWid(a1)
		move	obGfx(a0),obGfx(a1)
		move	$3E(a0),$3E(a1)
		and	#$7FFF,obGfx(a1)
		tst	obGfx(a2)
		bpl.s	loc_1DEE0
		or	#-$8000,obGfx(a1)
 
loc_1DEE0:				; CODE XREF: h+6EF4?j h+6F00?j ...
		bsr.s	SD_Dust_LoadArt
		rts	
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 
SD_Dust_LoadArt:				; CODE XREF: h+6EC0?p h+6F6C?p
		moveq	#0,d0
		move.b	obFrame(a0),d0
		cmp.b	$30(a0),d0
		beq.w	@return
		move.b	d0,$30(a0)
		lea	(SD_DynPLC).l,a2      ; dynamic plc
		add	d0,d0                 ; use current frame as a secondary routine counter
		add	(a2,d0.w),a2
		move	(a2)+,d5              ; move dplc flag to d5
		subq	#1,d5                 ; if nothing to load
		bmi.w	@return               ; then branch
		move    $3C(a0),d4            ; was set to $F400 in init stage
 
@loadartloop:				; CODE XREF: h+6FBE?j
		moveq	#0,d1
		move	(a2)+,d1              ; dplc value to d1
		move	d1,d3
		lsr.w	#8,d3
		and	#$F0,d3	; 'ğ'
		add	#$10,d3
		and	#$FFF,d1
		lsl.l	#5,d1
		add.l	#Art_Dust,d1
		move	d4,d2
		add	d3,d4
		add	d3,d4
		jsr	(QueueDMATransfer).l   ; +++ replaced line jsr	(DMA_68KtoVRAM).l
		dbf	d5,@loadartloop
    rts
 
@return:				; CODE XREF: h+6F7A?j h+6F90?j
		rts
                
                even
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SD_Dust_Animations:	dc SD_Dust_AnimNull-SD_Dust_Animations; 0 ; DATA XREF: h+6EB4?o h+6FC4?o ...                     ; blank animation
		dc SD_Dust_AnimSplash-SD_Dust_Animations; 1                                                        ; water splash animation
		dc SD_Dust_AnimDash-SD_Dust_Animations; 2                                                        ; spin dash animation
                dc SD_Dust_AnimSkid-SD_Dust_Animations; 3
                dc SD_Dust_AnimSpray-SD_Dust_Animations; 3
SD_Dust_AnimNull:	        dc.b $1F,  0,$FF                                      ; blank animation frames
SD_Dust_AnimSplash:	        dc.b   3,  1,  2,  3,  4,  5,  6,  7,  8,  9,$FD,  0  ; water splash animation frames
SD_Dust_AnimDash:	        dc.b   1, $A, $B, $C, $D, $E, $F,$10,$FF              ; spin dash animation frames
SD_Dust_AnimSkid:	        dc.b   3,$11,$12,$13,$14,$FC                          ; skid dust animation frames
;SD_Dust_AnimSpray:	        dc.b   1, $A, $B, $C, $D, $E, $F,$10,$FF                 ; spin dash animation frames
SD_Dust_AnimSpray:	        dc.b   2, $16, $17, $18, $19, $1A, $FF                ; Water spray animation frames
                even
; -------------------------------------------------------------------------------
; Sprite Mappings
; -------------------------------------------------------------------------------
SD_MapUnc:
	dc SD_Null-SD_MapUnc; 0
	dc SD_Splash1-SD_MapUnc; 1
	dc SD_Splash2-SD_MapUnc; 2
	dc SD_Splash3-SD_MapUnc; 3
	dc SD_Splash4-SD_MapUnc; 4
	dc SD_Splash5-SD_MapUnc; 5
	dc SD_Splash6-SD_MapUnc; 6
	dc SD_Splash7-SD_MapUnc; 7
	dc SD_Splash8-SD_MapUnc; 8
	dc SD_Splash9-SD_MapUnc; 9
	dc SD_Dust1-SD_MapUnc; 10 A
	dc SD_Dust2-SD_MapUnc; 11 B
	dc SD_Dust3-SD_MapUnc; 12 C
	dc SD_Dust4-SD_MapUnc; 13 D
	dc SD_Dust5-SD_MapUnc; 14 E
	dc SD_Dust6-SD_MapUnc; 15 F
	dc SD_Dust7-SD_MapUnc; 16 10
	dc SD_Skid1-SD_MapUnc; 17 11
	dc SD_Skid2-SD_MapUnc; 18 12
	dc SD_Skid3-SD_MapUnc; 19 13
	dc SD_Skid4-SD_MapUnc; 20 14
     	dc SD_Null-SD_MapUnc; 21
	dc SD_MapUnc_A-SD_MapUnc ; 16
        dc SD_MapUnc_18-SD_MapUnc ; 17
	dc SD_MapUnc_26-SD_MapUnc  ;18
        dc SD_MapUnc_34-SD_MapUnc  ; 19
	dc SD_MapUnc_42-SD_MapUnc   ;20
	even
SD_Null:	dc.b 0
SD_Splash1:	dc.b 1
	dc.b $F2, $0D, $0, 0,$F0; 0
SD_Splash2:	dc.b 1
	dc.b $E2, $0F, $0, 0,$F0; 0
SD_Splash3:	dc.b 1
	dc.b $E2, $0F, $0, 0,$F0; 0
SD_Splash4:	dc.b 1
	dc.b $E2, $0F, $0, 0,$F0; 0
SD_Splash5:	dc.b 1
	dc.b $E2, $0F, $0, 0,$F0; 0
SD_Splash6:	dc.b 1
	dc.b $E2, $0F, $0, 0,$F0; 0
SD_Splash7:	dc.b 1
	dc.b $F2, $0D, $0, 0,$F0; 0
SD_Splash8:	dc.b 1
	dc.b $F2, $0D, $0, 0,$F0; 0
SD_Splash9:	dc.b 1
	dc.b $F2, $0D, $0, 0,$F0; 0
SD_Dust1:	dc.b 1
	dc.b $4, $0D, $0, 0,$E0; 0
SD_Dust2:	dc.b 1
	dc.b $4, $0D, $0, 0,$E0; 0
SD_Dust3:	dc.b 1
	dc.b $4, $0D, $0, 0,$E0; 0
SD_Dust4:	dc.b 2
	dc.b $F4, $01, $0, 0,$E8; 0
	dc.b $4, $0D, $0, 2,$E0; 4
SD_Dust5:	dc.b 2
	dc.b $F4, $05, $0, 0,$E8; 0
	dc.b $4, $0D, $0, 4,$E0; 4
SD_Dust6:	dc.b 2
	dc.b $F4, $09, $0, 0,$E0; 0
	dc.b $4, $0D, $0, 6,$E0; 4
SD_Dust7:	dc.b 2
	dc.b $F4, $09, $0, 0,$E0; 0
	dc.b $4, $0D, $0, 6,$E0; 4
SD_Skid1:	dc.b 1
	dc.b $F8, $05, $0, 0,$F8; 0
SD_Skid2:	dc.b 1
	dc.b $F8, $05, $0, 4,$F8; 0
SD_Skid3:	dc.b 1
	dc.b $F8, $05, $0, 8,$F8; 0
SD_Skid4:	dc.b 1
	dc.b $F8, $05, $0, $C,$F8; 0
SD_MapUnc_A:	dc.b 2
		dc.b $4, $D, $80, $0, $C0
		dc.b $4, 5, $80, $8, $E0
SD_MapUnc_18:	dc.b 2
		dc.b $4, $D, $80, $0, $C0
		dc.b $4, 5, $80, $8, $E0
SD_MapUnc_26:	dc.b 2
		dc.b $4, $D, $80, $0, $C0
		dc.b $4, 5, $80, $8, $E0
SD_MapUnc_34:	dc.b 2
		dc.b $4, $D, $80, $0, $C0
		dc.b $4, 5, $80, $8, $E0
SD_MapUnc_42:	dc.b 2
		dc.b $4, $D, $80, $0, $C0
		dc.b $4, 5, $80, $8, $E0
	dc.b 0
	even
; -------------------------------------------------------------------------------
; dynamic pattern loading cues
; -------------------------------------------------------------------------------
SD_DynPLC:	dc SDPLC_Null-SD_DynPLC; 0
	dc SDPLC_Splash1-SD_DynPLC; 1
	dc SDPLC_Splash2-SD_DynPLC; 2
	dc SDPLC_Splash3-SD_DynPLC; 3
	dc SDPLC_Splash4-SD_DynPLC; 4
	dc SDPLC_Splash5-SD_DynPLC; 5
	dc SDPLC_Splash6-SD_DynPLC; 6
	dc SDPLC_Splash7-SD_DynPLC; 7
	dc SDPLC_Splash8-SD_DynPLC; 8
	dc SDPLC_Splash9-SD_DynPLC; 9
	dc SDPLC_Dust1-SD_DynPLC; 10
	dc SDPLC_Dust2-SD_DynPLC; 11
	dc SDPLC_Dust3-SD_DynPLC; 12
	dc SDPLC_Dust4-SD_DynPLC; 13
	dc SDPLC_Dust5-SD_DynPLC; 14
	dc SDPLC_Dust6-SD_DynPLC; 15
	dc SDPLC_Dust7-SD_DynPLC; 16
	dc SDPLC_Skid-SD_DynPLC; 17
	dc SDPLC_Skid-SD_DynPLC; 18
	dc SDPLC_Skid-SD_DynPLC; 19
	dc SDPLC_Skid-SD_DynPLC; 20
	dc SDPLC_Null2-SD_DynPLC; 21
	dc SDPLC_MapUnc_A-SD_DynPLC ; 15
        dc SDPLC_MapUnc_18-SD_DynPLC ; 16
	dc SDPLC_MapUnc_26-SD_DynPLC  ;17
        dc SDPLC_MapUnc_34-SD_DynPLC  ; 18
	dc SDPLC_MapUnc_42-SD_DynPLC   ;19
	even
SDPLC_Null:	dc 0
SDPLC_Splash1:	dc 1
	dc $7000
SDPLC_Splash2:	dc 1
	dc $F008
SDPLC_Splash3:	dc 1
	dc $F018
SDPLC_Splash4:	dc 1
	dc $F028
SDPLC_Splash5:	dc 1
	dc $F038
SDPLC_Splash6:	dc 1
	dc $F048
SDPLC_Splash7:	dc 1
	dc $7058
SDPLC_Splash8:	dc 1
	dc $7060
SDPLC_Splash9:	dc 1
	dc $7068
SDPLC_Dust1:	dc 1
	dc $7070
SDPLC_Dust2:	dc 1
	dc $7078
SDPLC_Dust3:	dc 1
	dc $7080
SDPLC_Dust4:	dc 2
	dc $1088
	dc $708A
SDPLC_Dust5:	dc 2
	dc $3092
	dc $7096
SDPLC_Dust6:	dc 2
	dc $509E
	dc $70A4
SDPLC_Dust7:	dc 2
	dc $50AC
	dc $70B2
SDPLC_Skid:	dc 0
SDPLC_Null2:	dc 1
	dc $F0BA
SDPLC_MapUnc_A:	dc 2
	dc $70CA
	dc $30D2
SDPLC_MapUnc_18:dc 2
	dc $70D6
	dc $30DE
SDPLC_MapUnc_26:	dc 2
	dc $70E2
	dc $30EA
SDPLC_MapUnc_34:	dc 2
	dc $70EE
	dc $30F6
SDPLC_MapUnc_42:	dc 2
	dc $70FA
	dc $3102
	even