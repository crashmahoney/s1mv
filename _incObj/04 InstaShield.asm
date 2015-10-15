; ---------------------------------------------------------------------------
; Object 04 - shields and instashield
; ---------------------------------------------------------------------------
loaded_frame    = $30        ; frame that is currently in VRAM
used_flag       = $31        ; set flag so instashield can only be used once per jump
vram_address    = $3C        ; address DPLC writes to
; --------------------------------------------------------------------------
InstaShield:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Insta_Index(pc,d0.w),d1
		jmp	Insta_Index(pc,d1.w)
; ===========================================================================
Insta_Index:	dc.w Insta_Init-Insta_Index          ; $0
                dc.w Insta_Main-Insta_Index          ; $2
; ===========================================================================
Insta_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Insta,obMap(a0)
		move.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.w	#$54F,obGfx(a0)	; shield specific code
		move.w	#$A9E0,vram_address(a0)
		rts
; =========================================================================
Insta_Main:     
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.w	#$80,obPriority(a0)           ; put object in front of sonic
		cmpi.b  #1,obAnim(a0)               ; is instashield active?
		bne.s   @chk_invinc                 ; if not, branch
		cmpi.b  #7,obFrame(a0)              ; final frame of instashield animation?
                bne.s   @skip                       ; if not, branch
                bclr    #7,(v_invinc).w
	@skip:
		move.l	#Map_Insta,obMap(a0)        ; load instashield mappings
		lea	DynPLC_Insta,a2             ; load instashield dynamic plc
		lea	Anim_Insta,a1
		jsr	AnimateSprite
		bsr.w	InstaShieldLoadArt
		jmp	DisplaySprite
; --------------------------------------------------------------------------
        @chk_invinc:
                tst.b   (v_objspace+$200).w         ; is invincibility object active?
                beq.s   @getshieldtype              ; if not, branch
                rts                                 ; don't draw shield
        @getshieldtype:
		moveq	#0,d0
		move.b	(v_shield).w,d0
		add.w   d0,d0
		move.w	Shieldtype_Index(pc,d0.w),d1
		jmp	Shieldtype_Index(pc,d1.w)
; --------------------------------------------------------------------------
Shieldtype_Index:
                dc.w NoShield-Shieldtype_Index
                dc.w StandardShield-Shieldtype_Index
                dc.w ElectricShield-Shieldtype_Index
                dc.w FireShield-Shieldtype_Index
; --------------------------------------------------------------------------
NoShield:
		move.b	#0,obAnim(a0)
		move.l	#Map_Insta,obMap(a0)        ; load instashield mappings
		lea	DynPLC_Insta,a2             ; load instashield dynamic plc
		lea	Anim_Insta,a1
		jsr	AnimateSprite
		bsr.w	InstaShieldLoadArt
		jmp	DisplaySprite
; --------------------------------------------------------------------------
StandardShield:
		move.b	#2,obAnim(a0)
		move.l	#Map_SShield,obMap(a0)      ; load standard shield mappings
		lea	DynPLC_SShield,a2           ; load standard shield dynamic plc
		lea	Anim_Insta,a1
		jsr	AnimateSprite
		bsr.s	InstaShieldLoadArt
		jmp	DisplaySprite
; --------------------------------------------------------------------------
ElectricShield:
		move.b	#3,obAnim(a0)
		move.l	#Map_ElecShield,obMap(a0)   ; load electric shield mappings
		lea	DynPLC_ElecShield,a2        ; load electric shield dynamic plc
		lea	Anim_Insta,a1
		jsr	AnimateSprite
		move.w	#$80,obPriority(a0)           ; put object in front of sonic
                cmpi.b  #12,obFrame(a0)             ; frame 12 or higher?
                blt.s   @skip                       ; if not, branch
		move.w	#$200,obPriority(a0)           ; move object behind sonic
        @skip:
		bsr.s	InstaShieldLoadArt
		jmp	DisplaySprite
; --------------------------------------------------------------------------
FireShield:
		move.b	#4,obAnim(a0)
		move.l	#Map_FireShield,obMap(a0)   ; load standard shield mappings
		lea	DynPLC_FireShield,a2        ; load standard shield dynamic plc
		lea	Anim_Insta,a1
		jsr	AnimateSprite
		move.w	#$80,obPriority(a0)           ; put object in front of sonic
                cmpi.b  #14,obFrame(a0)             ; frame 14 or higher?
                blt.s   @skip                       ; if not, branch
		move.w	#$200,obPriority(a0)           ; move object behind sonic
        @skip:
		bsr.s	InstaShieldLoadArt
		jmp	DisplaySprite
; =========================================================================
; Use Dynamic PLC's to load the correct art
; =========================================================================
InstaShieldLoadArt:
		moveq	#0,d0
		move.b	obFrame(a0),d0
		cmp.b	loaded_frame(a0),d0
		beq.s	@return
		move.b	d0,loaded_frame(a0)
		add.w	d0,d0
		adda.w	(a2,d0.w),a2          ; a2 is dynamic plc
		move.w	(a2)+,d5              ; move dplc flag to d5
		subq.w	#1,d5                 ; if nothing to load
		bmi.s	@return               ; then branch
		move.w  vram_address(a0),d4   ; was set to $A820 in init stage
@loadartloop:
		moveq	#0,d1
		move.w	(a2)+,d1              ; dplc value to d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		addi.l	#Art_Instashield,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	QueueDMATransfer
		dbf	d5,@loadartloop
@return:
		rts
; =========================================================================
; Animations
; =========================================================================
Anim_Insta:
                dc.w @instaNull-Anim_Insta        ;0
                dc.w @instaAnim-Anim_Insta        ;1
                dc.w @shieldAnim-Anim_Insta       ;2
                dc.w @elecAnim-Anim_Insta         ;3
                dc.w @fireAnim-Anim_Insta         ;4
; --------------------------------------------------------------------------
@instaNull:	dc.b   $1F, 0, afEnd
@instaAnim:	dc.b   $0, 1, 2, 3, 4, 5, 6, 0, 0, 0, 0, 0, 0, 0, 7, afChange, 0
@shieldAnim:    dc.b   $0, 0, 1, 2, 1, 3, 1, 4, 1, 5, 1, afEnd
@elecAnim:      dc.b   $0, 0,12, 0,12, 1,13, 1,13, 2,14, 2,14, 3,15, 3,15, 4,16, 4,16
                dc.b       5,17, 5,17, 6,18, 6,18, 7,19, 7,19, 8,20, 8,20
                dc.b       9, 9,10,10,11,11, afEnd
@fireAnim:      dc.b   $0, 0,14, 0,14, 1,15, 1,15, 2,16, 2,16, 3,17, 3,17, 4,18, 4,18
                dc.b       5,19, 5,19, 6,20, 6,20, 7,21, 7,21, 8,22, 8,22, afEnd
                even
; =========================================================================
; Mappings
; =========================================================================
Map_Insta:
	dc.w @instaNull-Map_Insta          ;0
	dc.w @insta1-Map_Insta             ;1
	dc.w @insta2-Map_Insta             ;2
	dc.w @insta3-Map_Insta             ;3
	dc.w @insta4-Map_Insta             ;4
	dc.w @insta5-Map_Insta             ;5
	dc.w @insta6-Map_Insta             ;6
	dc.w @instaNull-Map_Insta          ;7          ; frame 7 clears the 7th bit in invincibility byte
; --------------------------------------------------------------------------
@instaNull:	dc.b	0
@insta1:	dc.b	1
	SpriteMap	-16, -24, 3, 3, 0, 0, 0, 0, 0x0000
@insta2:	dc.b	1
	SpriteMap	 0,  -16, 3, 3, 0, 0, 0, 0, 0x0000
@insta3:	dc.b	1
	SpriteMap	 -8,   0, 4, 3, 0, 0, 0, 0, 0x0000
@insta4:	dc.b	2
	SpriteMap	-24, -16, 4, 2, 0, 0, 0, 0, 0x0000
	SpriteMap	-24,   0, 2, 3, 0, 0, 0, 0, 0x0008
@insta5:	dc.b	3
	SpriteMap	-16, -24, 2, 1, 0, 0, 0, 0, 0x0000
	SpriteMap	  0, -24, 3, 4, 0, 0, 0, 0, 0x0002
	SpriteMap	   8,  8, 2, 1, 0, 0, 0, 0, 0x000E
@insta6:	dc.b	3
	SpriteMap	  0,  16, 2, 1, 1, 1, 0, 0, 0x0000
	SpriteMap	-24,  -8, 3, 4, 1, 1, 0, 0, 0x0002
	SpriteMap	-24, -16, 2, 1, 1, 1, 0, 0, 0x000E
        even
; --------------------------------------------------------------------------
Map_SShield:
	dc.w @shield1-Map_SShield            ;0          ; small inside
	dc.w @shield2-Map_SShield            ;1          ; large outside
	dc.w @shield1-Map_SShield            ;2          ; same as frame 1
	dc.w @shield1-Map_SShield            ;3          ;   "       "
	dc.w @shield1-Map_SShield            ;4          ;   "       "
	dc.w @shield1-Map_SShield            ;5          ;   "       "
@shield1:       dc.b	4
	SpriteMap	-16, -16, 2, 2, 0, 0, 0, 0, 0x0000
	SpriteMap	  0, -16, 2, 2, 1, 0, 0, 0, 0x0000
	SpriteMap	-16,   0, 2, 2, 0, 1, 0, 0, 0x0000
	SpriteMap	  0,   0, 2, 2, 1, 1, 0, 0, 0x0000
@shield2:       dc.b	4
	SpriteMap	-24, -32, 3, 4, 0, 0, 0, 0, 0x0000
	SpriteMap	  0, -32, 3, 4, 1, 0, 0, 0, 0x0000
	SpriteMap	-24,   0, 3, 4, 0, 1, 0, 0, 0x0000
	SpriteMap	  0,   0, 3, 4, 1, 1, 0, 0, 0x0000
        even
; --------------------------------------------------------------------------
Map_ElecShield:
	dc.w @elec1-Map_ElecShield              ;0
	dc.w @elec2-Map_ElecShield              ;1
	dc.w @elec3-Map_ElecShield              ;2
	dc.w @elec4-Map_ElecShield              ;3
	dc.w @elec5-Map_ElecShield              ;4
	dc.w @elec6-Map_ElecShield              ;5
	dc.w @elec7-Map_ElecShield              ;6
	dc.w @elec8-Map_ElecShield              ;7
	dc.w @elec9-Map_ElecShield              ;8
	dc.w @elec10-Map_ElecShield             ;9          ; part flash
	dc.w @elec11-Map_ElecShield             ;10         ; part flash 2
	dc.w @elec12-Map_ElecShield             ;11         ; full flash
	dc.w @elec9-Map_ElecShield              ;12
	dc.w @elec8-Map_ElecShield              ;13
	dc.w @elec7-Map_ElecShield              ;14
	dc.w @elec6-Map_ElecShield              ;15
	dc.w @elec5-Map_ElecShield              ;16
	dc.w @elec4-Map_ElecShield              ;17
	dc.w @elec3-Map_ElecShield              ;18
	dc.w @elec2-Map_ElecShield              ;19
	dc.w @elec1-Map_ElecShield              ;20
@elec1:	dc.b	3
	SpriteMap	 -8, -24, 4, 1, 0, 0, 0, 0, 0x0000
	SpriteMap	  8, -16, 2, 4, 0, 0, 0, 0, 0x0004
	SpriteMap	 -8,  16, 4, 1, 0, 0, 0, 0, 0x000C
@elec2:	dc.b	2
	SpriteMap	  0, -24, 3, 3, 0, 0, 0, 0, 0x0000
	SpriteMap	  0,   0, 3, 3, 0, 0, 0, 0, 0x0009
@elec3:	dc.b	3
	SpriteMap	 -8, -24, 3, 1, 0, 0, 0, 0, 0x0000
	SpriteMap	  0, -16, 3, 4, 0, 0, 0, 0, 0x0003
	SpriteMap	 -8,  16, 3, 1, 0, 0, 0, 0, 0x000F
@elec4:	dc.b	3
	SpriteMap	 -8, -24, 3, 1, 0, 0, 0, 0, 0x0000
	SpriteMap	 -8, -16, 4, 3, 0, 0, 0, 0, 0x0003
	SpriteMap	 -8,   8, 3, 2, 0, 0, 0, 0, 0x000F
@elec5:	dc.b	2
	SpriteMap	 -8, -24, 2, 3, 0, 0, 0, 0, 0x0000
	SpriteMap	 -8,   0, 2, 3, 0, 0, 0, 0, 0x0006
@elec6:	dc.b	3                                                   ; elec4 reversed
	SpriteMap	-16, -24, 3, 1, 1, 0, 0, 0, 0x0000
	SpriteMap	-24, -16, 4, 3, 1, 0, 0, 0, 0x0003
	SpriteMap	-16,   8, 3, 2, 1, 0, 0, 0, 0x000F
@elec7:	dc.b	3                                                   ; elec3 reversed
	SpriteMap	-16, -24, 3, 1, 1, 0, 0, 0, 0x0000
	SpriteMap	-24, -16, 3, 4, 1, 0, 0, 0, 0x0003
	SpriteMap	-16,  16, 3, 1, 1, 0, 0, 0, 0x000F
@elec8:	dc.b	2                                                   ; elec2 reversed
	SpriteMap	-24, -24, 3, 3, 1, 0, 0, 0, 0x0000
	SpriteMap	-24,   0, 3, 3, 1, 0, 0, 0, 0x0009
@elec9:	dc.b	3                                                   ; elec1 reversed
	SpriteMap	-24, -24, 4, 1, 1, 0, 0, 0, 0x0000
	SpriteMap	-24, -16, 2, 4, 1, 0, 0, 0, 0x0004
	SpriteMap	-24,  16, 4, 1, 1, 0, 0, 0, 0x000C
@elec10	dc.b	4
	SpriteMap	-24, -24, 3, 3, 0, 0, 0, 0, 0x0000
	SpriteMap	-24,   0, 3, 3, 0, 0, 0, 0, 0x0009
	SpriteMap	  0, -24, 3, 3, 1, 1, 0, 0, 0x0009
	SpriteMap	  0,   0, 3, 3, 1, 1, 0, 0, 0x0000
@elec11	dc.b	4
	SpriteMap	-24, -24, 3, 3, 0, 0, 0, 0, 0x0000
	SpriteMap	  0, -24, 3, 3, 0, 0, 0, 0, 0x0009
	SpriteMap	-24,   0, 3, 3, 1, 1, 0, 0, 0x0009
	SpriteMap	  0,   0, 3, 3, 1, 1, 0, 0, 0x0000
@elec12	dc.b	4
	SpriteMap	-24, -24, 3, 3, 0, 0, 0, 0, 0x0000
	SpriteMap	  0, -24, 3, 3, 1, 0, 0, 0, 0x0000
	SpriteMap	-24,   0, 3, 3, 0, 1, 0, 0, 0x0000
	SpriteMap	  0,   0, 3, 3, 1, 1, 0, 0, 0x0000
        even
; --------------------------------------------------------------------------
Map_FireShield:
	dc.w @fire0-Map_FireShield              ;0       fire in front
	dc.w @fire1-Map_FireShield              ;1
	dc.w @fire2-Map_FireShield              ;2
	dc.w @fire3-Map_FireShield              ;3
	dc.w @fire4-Map_FireShield              ;4
	dc.w @fire5-Map_FireShield              ;5
	dc.w @fire6-Map_FireShield              ;6
	dc.w @fire7-Map_FireShield              ;7
	dc.w @fire8-Map_FireShield              ;8
	dc.w @fire9-Map_FireShield              ;9      fire dash
	dc.w @fire10-Map_FireShield             ;10
	dc.w @fire11-Map_FireShield             ;11
	dc.w @fire12-Map_FireShield             ;12
	dc.w @fire13-Map_FireShield             ;13
	dc.w @fire14-Map_FireShield             ;14     fire behind
	dc.w @fire15-Map_FireShield             ;15
	dc.w @fire16-Map_FireShield             ;16
	dc.w @fire17-Map_FireShield             ;17
	dc.w @fire18-Map_FireShield             ;18
	dc.w @fire19-Map_FireShield             ;19
	dc.w @fire20-Map_FireShield             ;20
	dc.w @fire21-Map_FireShield             ;21
	dc.w @fire22-Map_FireShield             ;22
@fire0:	dc.b	3
	SpriteMap	-16,   8, 2, 1, 0, 0, 0, 0, 0x0000
	SpriteMap	-16,  16, 2, 1, 0, 0, 0, 0, 0x0002
	SpriteMap	  0,   8, 3, 2, 0, 0, 0, 0, 0x0004
@fire1:	dc.b	3
	SpriteMap	-16,   0, 2, 1, 0, 0, 0, 0, 0x0000
	SpriteMap	-24,   8, 3, 2, 0, 0, 0, 0, 0x0002
	SpriteMap	  0,   8, 3, 2, 0, 0, 0, 0, 0x0008
@fire2:	dc.b	3
	SpriteMap	 -8,  -8, 1, 1, 0, 0, 0, 0, 0x0000
	SpriteMap	-24,   0, 3, 3, 0, 0, 0, 0, 0x0001
	SpriteMap	  0,   0, 3, 3, 0, 0, 0, 0, 0x000A
@fire3:	dc.b	3
	SpriteMap	-16, -16, 3, 1, 0, 0, 0, 0, 0x0000
	SpriteMap	-24,  -8, 3, 3, 0, 0, 0, 0, 0x0003
	SpriteMap	  0,  -8, 3, 3, 0, 0, 0, 0, 0x000C
@fire4:	dc.b	4
	SpriteMap	-24, -16, 3, 2, 0, 0, 0, 0, 0x0000
	SpriteMap	  0, -16, 3, 2, 0, 0, 0, 0, 0x0006
	SpriteMap	-24,   0, 3, 2, 0, 1, 0, 0, 0x0000
	SpriteMap	  0,   0, 3, 2, 0, 1, 0, 0, 0x0006
@fire5:	dc.b	3                                             ; fire3 flipped
	SpriteMap	-16,   8, 3, 1, 0, 1, 0, 0, 0x0000
	SpriteMap	-24, -16, 3, 3, 0, 1, 0, 0, 0x0003
	SpriteMap	  0, -16, 3, 3, 0, 1, 0, 0, 0x000C
@fire6:	dc.b	3                                             ; fire2 flipped
	SpriteMap	 -8,   0, 1, 1, 0, 1, 0, 0, 0x0000
	SpriteMap	-24, -24, 3, 3, 0, 1, 0, 0, 0x0001
	SpriteMap	  0, -24, 3, 3, 0, 1, 0, 0, 0x000A
@fire7:	dc.b	3                                             ; fire1 flipped
	SpriteMap	-16,  -8, 2, 1, 0, 1, 0, 0, 0x0000
	SpriteMap	-24, -24, 3, 2, 0, 1, 0, 0, 0x0002
	SpriteMap	  0, -24, 3, 2, 0, 1, 0, 0, 0x0008
@fire8:	dc.b	3                                             ; fire0 flipped
	SpriteMap	-16, -16, 2, 1, 0, 1, 0, 0, 0x0000
	SpriteMap	-16, -24, 2, 1, 0, 1, 0, 0, 0x0002
	SpriteMap	  0, -24, 3, 2, 0, 1, 0, 0, 0x0004
@fire9: dc.b    0
@fire10:dc.b    0
@fire11:dc.b    0
@fire12:dc.b    0
@fire13:dc.b    0
@fire14:dc.b	2
	SpriteMap	-24, -24, 3, 2, 0, 0, 0, 0, 0x0000
	SpriteMap	  0, -24, 3, 2, 0, 0, 0, 0, 0x0006
@fire15:dc.b	2
	SpriteMap	-24, -24, 3, 3, 0, 0, 0, 0, 0x0000
	SpriteMap	  0, -24, 3, 3, 0, 0, 0, 0, 0x0009
@fire16:dc.b	3
	SpriteMap	-24, -24, 3, 4, 0, 0, 0, 0, 0x0000
	SpriteMap	  0, -24, 3, 3, 0, 0, 0, 0, 0x000C
	SpriteMap	  8,   0, 1, 1, 0, 0, 0, 0, 0x0015
@fire17:dc.b	3
	SpriteMap	-24, -24, 3, 4, 0, 0, 0, 0, 0x0000
	SpriteMap	  0, -24, 3, 4, 0, 0, 0, 0, 0x000C
	SpriteMap	  8,   8, 2, 1, 0, 0, 0, 0, 0x0018
@fire18:dc.b	4
	SpriteMap	-24, -24, 3, 3, 0, 0, 0, 0, 0x0000
	SpriteMap	  0, -24, 3, 3, 0, 0, 0, 0, 0x0009
	SpriteMap	-24,   0, 3, 3, 0, 1, 0, 0, 0x0000
	SpriteMap	  0,   0, 3, 3, 0, 1, 0, 0, 0x0009
@fire19:dc.b	3                                                ; fire17 flipped
	SpriteMap	-24,  -8, 3, 4, 0, 1, 0, 0, 0x0000
	SpriteMap	  0,  -8, 3, 4, 0, 1, 0, 0, 0x000C
	SpriteMap	  8, -16, 2, 1, 0, 1, 0, 0, 0x0018
@fire20:dc.b	3                                                ; fire16 flipped
	SpriteMap	-24,  -8, 3, 4, 0, 1, 0, 0, 0x0000
	SpriteMap	  0,   0, 3, 3, 0, 1, 0, 0, 0x000C
	SpriteMap	  8,  -8, 1, 1, 0, 1, 0, 0, 0x0015
@fire21:dc.b	2                                                ; fire15 flipped
	SpriteMap	-24,   0, 3, 3, 0, 1, 0, 0, 0x0000
	SpriteMap	  0,   0, 3, 3, 0, 1, 0, 0, 0x0009
@fire22:dc.b	2                                                ; fire14 flipped
	SpriteMap	-24,   8, 3, 2, 0, 1, 0, 0, 0x0000
	SpriteMap	  0,   8, 3, 2, 0, 1, 0, 0, 0x0006
        even
; =========================================================================
; Dynamic PLCs
; =========================================================================
DynPLC_Insta:
	dc.w @instaNull-DynPLC_Insta       ;0
	dc.w @insta1-DynPLC_Insta          ;1
	dc.w @insta2-DynPLC_Insta          ;2
	dc.w @insta3-DynPLC_Insta          ;3
	dc.w @insta4-DynPLC_Insta          ;4
	dc.w @insta5-DynPLC_Insta          ;5
	dc.w @insta6-DynPLC_Insta          ;6
	dc.w @instaNull-DynPLC_Insta       ;7
@instaNull:	dc.w 0
@insta1:	dc.w 1
  	        dc.w $8000                  ; $8 = tiles-1, 000 = offset in tiles
@insta2:	dc.w 1
	        dc.w $8009
@insta3:	dc.w 1
	        dc.w $B012
@insta4:	dc.w 1
	        dc.w $D01E
@insta5:	dc.w 2
	        dc.w $F02C
@insta6:	dc.w 2
	        dc.w $F02C
                even
; --------------------------------------------------------------------------
DynPLC_SShield:
	dc.w @shield1-DynPLC_SShield         ;0
	dc.w @shield2-DynPLC_SShield         ;1
	dc.w @shield3-DynPLC_SShield         ;2
	dc.w @shield4-DynPLC_SShield         ;3
	dc.w @shield5-DynPLC_SShield         ;4
	dc.w @shield6-DynPLC_SShield         ;5
@shield1:	dc.w 1
  	        dc.w $403C
@shield2:	dc.w 1
  	        dc.w $C050
@shield3:	dc.w 1
  	        dc.w $4040
@shield4:	dc.w 1
  	        dc.w $4044
@shield5:	dc.w 1
  	        dc.w $4048
@shield6:	dc.w 1
  	        dc.w $404C
                even
; --------------------------------------------------------------------------
DynPLC_ElecShield:
	dc.w @elec1-DynPLC_ElecShield           ;0
	dc.w @elec2-DynPLC_ElecShield           ;1
	dc.w @elec3-DynPLC_ElecShield           ;2
	dc.w @elec4-DynPLC_ElecShield           ;3
	dc.w @elec5-DynPLC_ElecShield           ;4
	dc.w @elec4-DynPLC_ElecShield           ;5
	dc.w @elec3-DynPLC_ElecShield           ;6
	dc.w @elec2-DynPLC_ElecShield           ;7
	dc.w @elec1-DynPLC_ElecShield           ;8
	dc.w @elec10-DynPLC_ElecShield          ;9
	dc.w @elec11-DynPLC_ElecShield          ;10
	dc.w @elec12-DynPLC_ElecShield          ;11
	dc.w @elec1-DynPLC_ElecShield           ;12
	dc.w @elec2-DynPLC_ElecShield           ;13
	dc.w @elec3-DynPLC_ElecShield           ;14
	dc.w @elec4-DynPLC_ElecShield           ;15
	dc.w @elec5-DynPLC_ElecShield           ;16
	dc.w @elec4-DynPLC_ElecShield           ;17
	dc.w @elec3-DynPLC_ElecShield           ;18
	dc.w @elec2-DynPLC_ElecShield           ;19
	dc.w @elec1-DynPLC_ElecShield           ;20
@elec1:	        dc.w 3
		dc.w $3000+$5C
		dc.w $7004+$5C
		dc.w $300C+$5C
@elec2:	        dc.w 2
		dc.w $8010+$5C
		dc.w $8019+$5C
@elec3:	        dc.w 3
		dc.w $2022+$5C
		dc.w $B025+$5C
		dc.w $2031+$5C
@elec4:	        dc.w 3
		dc.w $2034+$5C
		dc.w $B037+$5C
		dc.w $5043+$5C
@elec5:	        dc.w 2
		dc.w $5049+$5C
		dc.w $504F+$5C
@elec10:	dc.w 2
		dc.w $8055+$5C
		dc.w $805E+$5C
@elec11:	dc.w 2
		dc.w $8067+$5C
		dc.w $8070+$5C
@elec12:	dc.w 1
		dc.w $8079+$5C
                even
; --------------------------------------------------------------------------
DynPLC_FireShield:
	dc.w @fire0-DynPLC_FireShield              ;0
	dc.w @fire1-DynPLC_FireShield              ;1
	dc.w @fire2-DynPLC_FireShield              ;2
	dc.w @fire3-DynPLC_FireShield              ;3
	dc.w @fire4-DynPLC_FireShield              ;4
	dc.w @fire3-DynPLC_FireShield              ;5
	dc.w @fire2-DynPLC_FireShield              ;6
	dc.w @fire1-DynPLC_FireShield              ;7
	dc.w @fire0-DynPLC_FireShield              ;8
	dc.w @fire9-DynPLC_FireShield              ;9
	dc.w @fire10-DynPLC_FireShield             ;10
	dc.w @fire11-DynPLC_FireShield             ;11
	dc.w @fire12-DynPLC_FireShield             ;12
	dc.w @fire13-DynPLC_FireShield             ;13
	dc.w @fire14-DynPLC_FireShield             ;14
	dc.w @fire15-DynPLC_FireShield             ;15
	dc.w @fire16-DynPLC_FireShield             ;16
	dc.w @fire17-DynPLC_FireShield             ;17
	dc.w @fire18-DynPLC_FireShield             ;18
	dc.w @fire17-DynPLC_FireShield             ;19
	dc.w @fire16-DynPLC_FireShield             ;20
	dc.w @fire15-DynPLC_FireShield             ;21
	dc.w @fire14-DynPLC_FireShield             ;22
@fire0:	        dc.w 1
		dc.w $9000+((Art_FireShield-Art_InstaShield)/32)
@fire1:	        dc.w 1
		dc.w $D00A+((Art_FireShield-Art_InstaShield)/32)
@fire2:	        dc.w 3
		dc.w $0018+((Art_FireShield-Art_InstaShield)/32)
		dc.w $8019+((Art_FireShield-Art_InstaShield)/32)
		dc.w $8022+((Art_FireShield-Art_InstaShield)/32)
@fire3:	        dc.w 3
		dc.w $202B+((Art_FireShield-Art_InstaShield)/32)
		dc.w $802E+((Art_FireShield-Art_InstaShield)/32)
		dc.w $8037+((Art_FireShield-Art_InstaShield)/32)
@fire4:	        dc.w 1
		dc.w $C040+((Art_FireShield-Art_InstaShield)/32)
@fire9:	        dc.w 0
		dc.w $0000+((Art_FireShield-Art_InstaShield)/32)
@fire10:        dc.w 0
		dc.w $0000+((Art_FireShield-Art_InstaShield)/32)
@fire11:        dc.w 0
		dc.w $0000+((Art_FireShield-Art_InstaShield)/32)
@fire12:        dc.w 0
		dc.w $0000+((Art_FireShield-Art_InstaShield)/32)
@fire13:        dc.w 0
		dc.w $0000+((Art_FireShield-Art_InstaShield)/32)
@fire14:        dc.w 1
		dc.w $B0AD+((Art_FireShield-Art_InstaShield)/32)
@fire15:        dc.w 2
		dc.w $80B9+((Art_FireShield-Art_InstaShield)/32)
		dc.w $80C2+((Art_FireShield-Art_InstaShield)/32)
@fire16:        dc.w 2
		dc.w $B0CB+((Art_FireShield-Art_InstaShield)/32)
		dc.w $90D7+((Art_FireShield-Art_InstaShield)/32)
@fire17:        dc.w 2
		dc.w $F0E1+((Art_FireShield-Art_InstaShield)/32)
		dc.w $90F1+((Art_FireShield-Art_InstaShield)/32)
@fire18:        dc.w 2
		dc.w $80FB+((Art_FireShield-Art_InstaShield)/32)
		dc.w $8104+((Art_FireShield-Art_InstaShield)/32)
                even
