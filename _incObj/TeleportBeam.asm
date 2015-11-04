; ---------------------------------------------------------------------------
; Object ?? - teleporter
;
; $2A byte - beam create loop number/beam segment y pos
; $2B byte - beam segment life time in frames
; $2C byte - screen shake array position
; $2D byte - timer for sonic display/control unlock
; ---------------------------------------------------------------------------

TeleportBeam:					
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	TeleBeam_Index(pc,d0.w),d1
		jmp		TeleBeam_Index(pc,d1.w)
; ===========================================================================
TeleBeam_Index:	dc.w TeleBeam_Main-TeleBeam_Index				;0
				dc.w TeleBeam_BeamDown-TeleBeam_Index			;2
				dc.w TeleBeam_BeamDownWait-TeleBeam_Index		;4			
				dc.w TeleBeam_Shake-TeleBeam_Index				;6
				dc.w TeleBeam_Finish-TeleBeam_Index				;8				
				dc.w TeleBeam_BeamSegMain-TeleBeam_Index		;A
				dc.w TeleBeam_BeamDisplay-TeleBeam_Index		;C

; ===========================================================================
; Setup Object, is not displayed
; ===========================================================================

TeleBeam_Main:																									; Routine 0
		addq.b	#2,obRoutine(a0)
        writeVRAM Art_TeleBeam, $200, $F2E0		; DMA beam art to VRAM (overwrites destroyed enemy points gfx)
		lea		(v_player).w,a1
		move.w	obX(a1),obX(a0)					; set position of main beam object at sonic
		move.w	obY(a1),obY(a0)
		move.b  #7,$2A(a0)					    ; create 8 beam segments

TeleBeam_BeamDown:  																							; Routine 2
		addq.b	#2,obRoutine(a0)
		move.w	#120,(v_player+flashtime).w	; set temp invincible time to 2 seconds
		jsr		FindFreeObj
		bne.s	@next							; branch if no free object slots
		move.b	#id_TeleportBeam,0(a1)			; create beam segment
		move.b	#$A,obRoutine(a1)				; set it to the segment routine
		move.b  #44,$2B(a1)						; set beam life timer to 44 frames
		move.w	obX(a0),obX(a1)					; set x position to same as main beam object
		move.w	obY(a0),obY(a1)					; set y position to same as main beam object
		moveq   #0,d0
		move.b  $2A(a0),d0						; get beam piece number
		lsl.b   #5,d0							; multiply by 32 to get y pos for new beam piece
		sub.w	d0,obY(a1)						; move y position upwards as required
		bcc.s   @next							; if position doesn't wrap over top of screen, branch
		move.w  #0,obY(a1)						; set y position to 0		
@next:
		sub.b   #1,$2A(a0)					    ; subtract from counter
		bcc.s   @rts							; if not below 0, branch
		move.b  #6,obRoutine(a0)				; go to screenshake routine
@rts:		
		rts	

; ===========================================================================

TeleBeam_BeamDownWait:  																						; Routine 4
		move.w	#120,(v_player+flashtime).w	; set temp invincible time to 2 seconds
		subq.b	#2,obRoutine(a0)
		rts

; ===========================================================================

TeleBeam_Shake:																									; Routine 6		
		move.w	#120,(v_player+flashtime).w	; set temp invincible time to 2 seconds
		move.w	#$54,d0							; s3k teleport sound effect
		jsr		(PlaySound).l		
		moveq   #0,d0
		move.b  $2C(a0),d0						; get current location in array
		add.w   d0,d0							; double cos it's stored as a word
		lea		TeleBeam_ShakeAmount,a2			
		adda.w  d0,a2
		move.w  (a2),d0							; move amount to shift screen to d0
		beq.s   @next							; if it reads 0, it's the end of the array
		add.w	d0,(v_lookshift).w				; add shift amount 
		add.b   #1,$2C(a0)						; advance array position
		rts
	@next:	
		move.w	#30,(v_player+flashtime).w		; set temp invincible time to .5 seconds
		addq.b	#2,obRoutine(a0)
		rts

TeleBeam_ShakeAmount:
		dc.w	-8, 8, -8, 8, -4, 4, -4, 4, -2, 2, 0
		even


; ===========================================================================
TeleBeam_Finish:					; Routine 8
		add.b   #1,$2D(a0)						; increase timer
		cmpi.b  #40,$2D(a0)
		bne.s	@rts
		move.b  #0,(f_lockctrl).w				; unlock controls
		moveq	#plcid_Main,d0
		jsr		NewPLC							; restore gfx overwritten by beam gfx
		jmp   	DeleteObject					; delete main beam object

	@rts:
		rts	



; ===========================================================================
; Displayed Object
; ===========================================================================

TeleBeam_BeamSegMain:																							; Routine A
		addq.b	#2,obRoutine(a0)
		move.l	#Map_TeleportBeam,obMap(a0)
		move.w	#($F2E0/$20)+$8000,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$0,obPriority(a0)

TeleBeam_BeamDisplay:																							; Routine C
		subq.b  #1,$2B(a0)						; subtract 1 from timer
		bcs.s   @delete							; if 0 then delete object
		btst    #0,$2B(a0)						; is it an even frame?
		beq.s   @display						; if yes, branch
		rts

	@display:	
		jmp		DisplaySprite

	@delete:
		jmp   	DeleteObject	


; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

Map_TeleportBeam:	
		dc.w TeleportBeam1-Map_TeleportBeam
TeleportBeam1:	dc.b 1	
		dc.b $F4, $0F, $80, 0, $F0	
		even

; --------------------------------------------------------------------------------
; Art
; --------------------------------------------------------------------------------

Art_TeleBeam:
		incbin "artunc\teleport.bin"


; ===========================================================================
; Subroutine to check on level load if beam is required
; ===========================================================================

Check_TeleportIntro:	
		tst.b   (v_teleportin).w				; is sonic supposed to teleport in?
		beq.s	@nobeam							; if not, branch
		move.w	#120,(v_player+flashtime).w		; set temp invincible time to 2 seconds
		jsr		FindFreeObj
		bne.s	@nobeam							; branch if no free object slots
		move.b	#id_TeleportBeam,0(a1)			; create beam
		move.b  #1,(f_lockctrl).w				; lock controls
		move.b  #1,(v_teleportin).w				; set teleport flag
		rts							
@nobeam:
		move.b  #0,(v_teleportin).w				; clear teleport flag
		rts
