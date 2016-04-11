; ---------------------------------------------------------------------------
; Object 04 - shields and instashield
; ---------------------------------------------------------------------------
loaded_frame    = $30        ; frame that is currently in VRAM
sparkle_timer	= $31
origY:		= $32
pow_ActBit	= $34		; which bit in the act flags this monitor is mapped to
vram_address    = $3C        ; address DPLC writes to
; --------------------------------------------------------------------------
PowerUp2:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	PowUp_Index(pc,d0.w),d1
		jmp	PowUp_Index(pc,d1.w)
; ===========================================================================
PowUp_Index:	dc.w PowUp_Init-PowUp_Index          ; $0
                dc.w PowUp_Main-PowUp_Index          ; $2
                dc.w PowUp_Collect-PowUp_Index       ; $4
                dc.w PowUp_Star-PowUp_Index          ; $6
                dc.w PowUp_StarDelete-PowUp_Index    ; $8
              
; ===========================================================================
PowUp_Init:
		lea     (v_monitorlocations).w,a3
		moveq   #23,d0                ; number of loops
	@x_pos_loop:
		move.w  (a3)+,d1              ; put x postion out of table into d3
		cmp.w   obX(a0),d1            ; is it equal to monitor's x position?
		beq.s   @checkbit             ; if so, check if bit is set
		dbf     d0,@x_pos_loop

@checkbit:
		move.b	d0,pow_ActBit(a0)	; remember which bit this is saved to
		jsr	GetActFlag		; check bit number in d0 is set
		tst.b	d0			; is it set?
		bne.w	PowUp_StarDelete	; if yes, branch


		addq.b	#2,obRoutine(a0)
		move.l	#Map_PowerUp,obMap(a0)
		move.b	#4,obRender(a0)
		move.w	#$80,obPriority(a0)         ; put object in front of sonic
		move.b	#$10,obActWid(a0)
		move.w	#$5E4,obGfx(a0)	
		move.w	#$BC80,vram_address(a0)
		move.w	obY(a0),origY(a0)
		move.b	#$47,obColType(a0)
		move.b	obSubtype(a0),obAnim(a0)
		rts
	
; =========================================================================
PowUp_Main:     
		lea	Anim_Powup,a1
		jsr	AnimateSprite
		lea	PowerUpDPLC,a2             ; load instashield dynamic plc
		bsr.w	PowUp_LoadArt

		moveq	#0,d0
		move.b	(v_oscillate+$16).w,d0
		btst	#3,obSubtype(a0)
		move.w	origY(a0),d1
		sub.w	d0,d1
		move.w	d1,obY(a0)	; update the block's position to make it wobble

;		bra.s	@rts

		tst.b	obRender(a0)
		bpl.s	@rts
; create sparkles
		subq.b	#1,sparkle_timer(a0)
		bpl.s	@rts
		move.b	#8,sparkle_timer(a0)
		jsr	FindFreeObj
		bne.s	@rts			
		move.b	(a0),(a1)						
		move.b	#6,obRoutine(a1)
		move.w	obX(a0),obX(a1)						; Get X position from Sonic
		move.w	obY(a0),obY(a1)						; Get Y position from Sonic

		move.w	(v_framecount).w,d0					; semi randomise y position
		andi.w	#$F,d0
		subq.w	#8,d0
		add.w	d0,obX(a1)

		move.l	#Map_Spark,obMap(a1)
		move.w	#$26C0,obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#$180,obPriority(a1)
		move.b	#8,obWidth(a1)
		move.b	#8,obHeight(a1)
		move.b	#1,obAnim(a1)
		move.w	#-400,obVelY(a1)					
@rts:
		jsr	DisplaySprite
		jmp	RememberState
; ===========================================================================
PowUp_Collect:
		music   bgm_extralife
		move.b	#id_GotPowUpCard,(v_objspace+$5C0).w   ; load PowerUp Card
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		move.b	d0,(v_objspace+$5C0+obSubtype).w 	; tell it what this pickup was
		lsl.w	#2,d0
		movea.l	PowUp_Types(pc,d0.w),a2
		move.b	#1,(a2)
; ---------------------------------------------------------------------------
; Save the fact that powerup is gone
; ---------------------------------------------------------------------------
		moveq	#0,d0
		move.b	pow_ActBit(a0),d0
		jsr	SetActFlag	
; ---------------------------------------------------------------------------
		jmp	DeleteObject


PowUp_Types:
	dc.l	v_abil_spindash		;0
	dc.l	v_abil_doublejump1
	dc.l	v_abil_jumpdash
	dc.l	v_abil_homing
	dc.l	v_abil_lightdash
	dc.l	v_abil_insta
	dc.l	v_abil_down
	dc.l	v_abil_peelout
; ===========================================================================
; Sparkle object (routine $6)
; ===========================================================================
PowUp_Star:

		jsr		SpeedToPos			; move object
		lea		(Spark_Animation).l,a1	
		jsr		AnimateSprite			; run animation
		jmp		DisplaySprite
; ---------------------------------------------------------------------------
PowUp_StarDelete:	; when animation finishes, it goes to this routine
		jmp		DeleteObject

















; =========================================================================
; Use Dynamic PLC's to load the correct art
; =========================================================================
PowUp_LoadArt:
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
		addi.l	#Art_PowerUps,d1
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
Anim_Powup:
                dc.w @Spindash-Anim_Powup	;0
                dc.w @doublejump-Anim_Powup	;1
                dc.w @jumpdash-Anim_Powup	;2
                dc.w @homing-Anim_Powup		;3
                dc.w @ldash-Anim_Powup		;4
                dc.w @insta-Anim_Powup		;5
                dc.w @stomp-Anim_Powup		;6
                dc.w @peelout-Anim_Powup	;7


; --------------------------------------------------------------------------

@Spindash:	dc.b   $1, 1, 2, afEnd
@doublejump:	dc.b   $1, 3, 4, afEnd
@jumpdash:	dc.b   $1, 5, 6, afEnd
@homing:	dc.b   $1, 7, 8, afEnd
@ldash:		dc.b   $1, $F, $10, afEnd
@insta:		dc.b   $1, 9, $A, afEnd
@stomp:		dc.b   $1, $B, $C, afEnd
@peelout:	dc.b   $1, $D, $E, afEnd


	even


	include "_maps/Power Up.asm"
	even
	include "_maps/Power Up DPLC.asm"
	even