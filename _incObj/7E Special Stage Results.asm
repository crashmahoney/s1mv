; ---------------------------------------------------------------------------
; Object 7E - special stage results screen
; ---------------------------------------------------------------------------
v_got_emerald = $FFFFA400

SSResult:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	SSR_Index(pc,d0.w),d1
		jmp	SSR_Index(pc,d1.w)
; ===========================================================================
SSR_Index:	dc.w SSR_ChkPLC-SSR_Index                    ; 0
		dc.w SSR_Move-SSR_Index                      ; $2
		dc.w SSR_Wait-SSR_Index                      ; $4
		dc.w SSR_RingBonus-SSR_Index                 ; $6
		dc.w SSR_Wait-SSR_Index                      ; $8
		dc.w SSR_Exit-SSR_Index                      ; $A
		dc.w SSR_Wait-SSR_Index                      ; $C
		dc.w SSR_Continue-SSR_Index                  ; $E
		dc.w SSR_Wait-SSR_Index                      ; $10
		dc.w SSR_Exit-SSR_Index                      ; $12
		dc.w SSR_ContFlash-SSR_Index                 ; $14
		dc.w SSR_Move2-SSR_Index                     ; $16             ; text leaves screen
		dc.w SSR_SuperMsg-SSR_Index                  ; $18             ; setup new text
		dc.w SSR_Move2-SSR_Index                     ; $1A             ; text comes back on screen
		dc.w SSR_Wait-SSR_Index                      ; $1C
		dc.w SSR_Exit2-SSR_Index                     ; $1E
		dc.w SSR_RingIdle-SSR_Index                  ; $20

ssr_mainX:	= $30		; position for card to display on
; ===========================================================================

SSR_ChkPLC:	; Routine 0
		tst.l	(v_plc_buffer).w ; are the pattern load cues empty?
		beq.s	SSR_Main	; if yes, branch
		rts	
; ===========================================================================

SSR_Main:
		movea.l	a0,a1
		lea	(SSR_Config).l,a2
		moveq	#4,d1
		cmpi.w	#50,(v_rings).w	      ; do you have 50 or more rings?
		bcs.s	SSR_Loop	      ; if no, branch
		addq.w	#1,d1		      ; if yes, add 1 to d1 (number of sprites)

	SSR_Loop:
		move.b	#id_SSResult,0(a1)
		move.w	(a2)+,obX(a1)	      ; load start x-position
		move.w	(a2)+,ssr_mainX(a1)   ; load main x-position
		move.w	(a2)+,obScreenY(a1)   ; load y-position
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,obFrame(a1)
		move.l	#Map_SSR,obMap(a1)
		move.w	#$8580,obGfx(a1)
		move.b	#0,obRender(a1)
		lea	$40(a1),a1
		dbf	d1,SSR_Loop	      ; repeat sequence 4 or 5 times

		moveq	#7,d0                 ; set text to "special stage"
		move.b	(v_emeralds).w,d1
		beq.s	loc_C842              ; if number of emeralds is 0, branch
		moveq	#0,d0                 ; set text to "chaos emeralds"
		tst.b   (v_got_emerald).w     ; check if emerald was collected
                beq.s   loc_C842              ; if not, branch
		moveq	#$C,d0		      ; load "Sonic got a" text
		move.b  #$D,obFrame+$40(a0)   ; set second line text to say "chaos emerald"
		clr.b   (v_got_emerald).w     ; clear flag
		cmpi.b	#6,d1		      ; do you have all chaos emeralds?
		bne.s	@adjusttextpos	      ; if not, branch
		moveq	#8,d0		      ; load "Sonic got them all" text
		move.b  #0,obFrame+$40(a0)    ; set second line text to say "chaos emeralds"
	@adjusttextpos:
		sub.w   #$9,obScreenY(a0)     ; Place first text line higher
		move.w	#$18,obX(a0)          ; adjust starting position of text
		sub.w	#$8,ssr_mainX(a0)     ; adjust end position of text

loc_C842:
		move.b	d0,obFrame(a0)
; ===========================================================================
SSR_Move:	; Routine 2
		moveq	#$10,d1		      ; set horizontal speed
		move.w	ssr_mainX(a0),d0
		cmp.w	obX(a0),d0	      ; has item reached its target position?
		beq.s	loc_C86C	      ; if yes, branch
		bge.s	SSR_ChgPos
		neg.w	d1

SSR_ChgPos:
		add.w	d1,obX(a0)	      ; change item's position

loc_C85A:				; XREF: loc_C86C
		move.w	obX(a0),d0
		bmi.s	locret_C86A
		cmpi.w	#$200,d0	      ; has item moved beyond	$200 on	x-axis?
		bcc.s	locret_C86A	      ; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

locret_C86A:
		rts	
; ===========================================================================

loc_C86C:				; XREF: SSR_Move
		cmpi.b	#2,obFrame(a0)        ; is this the ring bonus object
		bne.s	loc_C85A              ; if not, branch
		addq.b	#2,obRoutine(a0)
		move.w	#180,obTimeFrame(a0)  ; set time delay to 3 seconds
		move.b	#id_SSRChaos,(v_objspace+$800).w ; load chaos emerald object

SSR_Wait:	; Routine 4, 8, $C, $10, $1C
		subq.w	#1,obTimeFrame(a0)    ; subtract 1 from time delay
		bne.s	SSR_Display
		addq.b	#2,obRoutine(a0)

SSR_Display:
		bra.w	DisplaySprite
; ===========================================================================

SSR_RingBonus:	; Routine 6
		bsr.w	DisplaySprite
		move.b	#1,(f_endactbonus).w  ; set ring bonus update flag
		tst.w	(v_ringbonus).w	      ; is ring bonus	= zero?
		beq.s	loc_C8C4	      ; if yes, branch
		subi.w	#10,(v_ringbonus).w   ; subtract 10 from ring bonus
		moveq	#10,d0		      ; add 10 to score
		jsr	AddPoints
		move.b	(v_vbla_byte).w,d0
		andi.b	#3,d0
		bne.s	locret_C8EA
		sfx	sfx_Switch,1	      ; play "blip" sound
; ===========================================================================

loc_C8C4:
		sfx	sfx_Cash	      ; play "ker-ching" sound
		addq.b	#2,obRoutine(a0)
		move.w	#180,obTimeFrame(a0)  ; set time delay to 3 seconds
		cmpi.w	#50,(v_rings).w	      ; do you have at least 50 rings?
		bcs.s	locret_C8EA	      ; if not, branch
		move.w	#60,obTimeFrame(a0)   ; set time delay to 1 second
		addq.b	#4,obRoutine(a0)      ; goto "SSR_Continue" routine

locret_C8EA:
		rts
; ===========================================================================

SSR_Exit:	; Routine $A, $12
;		move.b  #1,(v_teleportin).w			; set teleport flag

		cmpi.b	#6,(v_emeralds).w                   ; do you have all chaos emeralds?
		bne.s	@exit	                            ; if not, branch
		move.w	#$418,(v_objspace+$5C0+ssr_mainX).w ; change end position of text
		move.w	#$410,(v_objspace+$600+ssr_mainX).w ; change end position of text
		move.b	#$16,(v_objspace+$5C0+obRoutine).w
		move.b	#$16,(v_objspace+$600+obRoutine).w
		move.b	#$20,(v_objspace+$680+obRoutine).w  ; set Ring Tally object to do nothing
		rts

       @exit:
		move.w	#1,(f_restart).w ; restart level
		bra.w	DisplaySprite
; ===========================================================================

SSR_Continue:	; Routine $E
		move.b	#4,(v_objspace+$700+obFrame).w
		move.b	#$14,(v_objspace+$700+obRoutine).w
		sfx	sfx_Continue	                    ; play continues jingle
		addq.b	#2,obRoutine(a0)
		move.w	#360,obTimeFrame(a0)                ; set time delay to 6 seconds
		bra.w	DisplaySprite
; ===========================================================================

SSR_ContFlash:	; Routine $14
		move.b	(v_vbla_byte).w,d0
		andi.b	#$F,d0
		bne.s	SSR_Display2
		bchg	#0,obFrame(a0)

SSR_Display2:
		bra.w	DisplaySprite
; ===========================================================================
SSR_Move2:	; Routine $16, $1A
		moveq	#$10,d1		; set horizontal speed
		move.w	ssr_mainX(a0),d0
		cmp.w	obX(a0),d0	; has item reached its target position?
		beq.w	SSR_Move2_Next	; if yes, branch
		add.w	d1,obX(a0)	; change item's position
		cmpi.w	#$200,obX(a0)	; has item moved beyond	$200 on	x-axis?
		bcc.w	SSR_hidetext	; if yes, branch
		bra.w	DisplaySprite
SSR_Move2_Next:
		addq.b	#2,obRoutine(a0)
        SSR_hidetext:
		rts
; ===========================================================================
SSR_SuperMsg:	; Routine $18
		move.w	#$20,obX(a0)                       ; reset position of text
		move.w	#$120,ssr_mainX(a0)                ; change end position of text
		move.b	#$A,(v_objspace+$5C0+obFrame).w    ; Sonic Can Be
		move.b	#$B,(v_objspace+$600+obFrame).w    ; Super Sonic
		addq.b	#2,obRoutine(a0)
		move.w	#180,obTimeFrame(a0)               ; set time delay to 3 seconds
		rts
; ===========================================================================
SSR_Exit2:	; Routine $1E
		move.w	#1,(f_restart).w ; restart level
; --------------------------------------------------------------------------
SSR_RingIdle:	; Routine $20
		bra.w	DisplaySprite
; ===========================================================================
SSR_Config:	dc.w $20, $120,	$C4	; start	x-pos, main x-pos, y-pos
		dc.b 2,	0		; rountine number, frame number
         	dc.w $20, $120,	$CD         ; second line of text
		dc.b 2,	9
		dc.w $320, $120, $118       ; score
		dc.b 2,	1
		dc.w $360, $120, $128       ; ring bonus
		dc.b 2,	2
		dc.w $1EC, $11C, $C4        ; oval
		dc.b 2,	3
		dc.w $3A0, $120, $138       ; continue
		dc.b 2,	6
