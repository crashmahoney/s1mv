; ---------------------------------------------------------------------------
; Object 8F - Hud Text Popup
; ---------------------------------------------------------------------------
hudVRAM:	macro loc
		move.l	#($40000000+((loc&$3FFF)<<16)+((loc&$C000)>>14)),d0
		endm

HudText:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	HudText_Index(pc,d0.w),d1
		jmp	HudText_Index(pc,d1.w)
; ===========================================================================
HudText_Index:	dc.w HudText_Main-HudText_Index
		dc.w HudText_Move-HudText_Index
		dc.w HudText_Delete-HudText_Index
; ===========================================================================

HudText_Main:	; Routine 0
		movea.l	$30(a0),a2			; load text
		move.b  (a2)+,obFrame(a0)		; set even or odd frame
		move.w	#$00,obX(a0)
		move.w	#$160,obScreenY(a0)
		move.l	#Map_HudText,obMap(a0)
		move.w	#$2570,obGfx(a0)
		move.b	#0,obRender(a0)
		move.w	#0,obPriority(a0)

		tst.b   (v_popuptimer).w		; has the previous popup finished?
		beq.s   DrawName			; if so, branch
		rts					; keep waiting

DrawName:
                move    #$2700, sr                    ; interrupt mask level 7
		lea	Art_HudText,a1
		lea     (vdp_data_port).l,a6
		hudVRAM	$BE80
                moveq   #11,d6               	; draw 12 letters
@mainloop:
                moveq   #0,d2
                move.b  (a2)+,d2            	; digit to draw
                cmpi.b  #$20,d2			; is it a space?
                bne.s   @convertascii		; if not, branch
                move.b  #$5B,d2			; make it into a "[" (cos our font uses that as space) 
        @convertascii:        
                sub.b   #$30,d2			; convert from ascii to place in font file
		lsl.w	#5,d2
		move.l	d0,4(a6)
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		addi.l	#$200000,d0
		dbf	d6,@mainloop

                move    #$2300, sr                    ; interrupt mask level 3
		addq.b	 #2,obRoutine(a0)
		move.b   #120,(v_popuptimer).w	

HudText_Move:	; Routine 2
		sub.b    #1,(v_popuptimer).w
		beq.s 	 @goaway
		move.w   obX(a0),d0
		add.w    #8,d0
		cmpi.w   #$98,d0
		bge.s    @display
		move.w   d0,obX(a0)
	@display:
		jmp	 DisplaySprite


@goaway:
		addq.b	 #2,obRoutine(a0)
		move.b   #$FF,(v_popuptimer).w
HudText_Delete:
		move.w   obX(a0),d0
		sub.w    #8,d0
		bmi.s    @delete
		move.w   d0,obX(a0)
		jmp	 DisplaySprite
	@delete:
		clr.b   (v_popuptimer).w
		jmp	DeleteObject


; ===========================================================================
; Create a popup
; a2 = rom location of text
; ===========================================================================
CreateHudPopup:
	jsr	FindFreeObj
	move.b	#id_HUDText,(a1) ; load HUD object
	move.l  a2,$30(a1)
	rts




HUD_Text_GameSaved:
		dc.b   0," GAME SAVED "		; 0+even alignment, 1-odd alignment
		even	
HUD_Text_Rings:
		dc.b   0,"  10 RINGS  "		; 0+even alignment, 1-odd alignment
		even	
HUD_Text_1up:
		dc.b   0,"   1 UP     "		; 0+even alignment, 1-odd alignment
		even	
