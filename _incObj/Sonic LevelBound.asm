; ---------------------------------------------------------------------------
; Subroutine to	prevent	Sonic leaving the boundaries of	a level
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_LevelBound:			; XREF: Obj01_MdNormal; et al
		cmpi.b  #$0C,(v_gamemode).w
		bne.w   @rts
	move.l	obX(a0),d1
;		smi.b	d2				; Set d2 if player on position > 32767
;		add.w	d2,d2			; Move bit up
		move.w	obVelX(a0),d0
;		spl.b	d2				; Set if speed is positive
;		add.w	d2,d2			; Move bit up
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
;		spl.b	d2				; Set if position+speed is < 32768
;		move.w	(v_limitleft2).w,d0
;		addi.w	#$10,d0
;		tst.w	d2				; If d2 is zero, we had an underflow of position
;		beq.w	@sideslocked
		swap	d1
		tst.b	(f_lockscreen).w    ; is screen locked?
		beq.s	@chkleft            ; if not, branch
		move.w	(v_limitleft2).w,d0
		addi.w	#$10,d0
		cmp.w	d1,d0		; has Sonic touched the	side boundary?
		bhi.w	@sideslocked		; if yes, branch     was bhi.s
		move.w	(v_limitright2).w,d0
		addi.w	#$128,d0        ; was $128
		cmp.w	d1,d0		; has Sonic touched the	side boundary?
		bls.w	@sideslocked		; if yes, branch    was bls.s
	bra.s   @chkbottom
    @chkleft:
	move.w	(v_limitleft2).w,d0
	subi.w  #$10,d0
	cmp.w   d1,d0
		bls.w	@leftside		; if yes, branch
    @chkright:
	move.w	(v_limitright2).w,d0
	addi.w  #$138,d0
	cmp.w   d1,d0
		bls.w	@rightside		; if yes, branch

	@chkbottom:
		move.w	(v_limitbtm2).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0	; has Sonic touched the	bottom boundary?
		blt.s	@bottom		; if yes, branch

	@chktop:
		move.w	(v_limittop2).w,d0
		cmp.w	obY(a0),d0	; has Sonic touched the	top boundary?
		bgt.w	@top		; if yes, branch
@rts:
		rts
; ===========================================================================

@bottom:
		move.w	($FFFFF726).w,d0	; +++ fix dying at bottom bug
		move.w	($FFFFF72E).w,d1	; +++
		cmp.w	d0,d1				; +++ screen still scrolling down?
		bge.w	@bottom_cont		; +++ if not, continue
		rts
@bottom_cont:
		lea     (BottomData).l,a3
		bra.s   @load1
@top:
		lea     (TopData).l,a3
	@load1:
		move.w	(v_zone).w,d3
		lsl.b	#6,d3
		lsr.w	#5,d3
		adda.w	(a3,d3.w),a3			; load the pointer to the current act
	@chk_x:
		move.w	(a3)+,d1			; get max x pos for this transition
		sub.w	obX(a0),d1			; subtract sonic's y pos
		bcc.s	@x_ok				; if still greater than 0, branch
		adda.w	#12,a3				; advance to next transition
		bra.w	@chk_x				; loop
	@x_ok:
		move.w  (a3)+,(f_dontstopmusic).w       ; load graphics/change music?
		move.w	(a3)+,($FFFFFE34).w		; y-position
		move.w	obX(a0),d1
		add.w	(a3)+,d1         		; put x offset in d1
		move.w	d1,($FFFFFE32).w                ; add offset to y position
		move.w	(a3)+,(v_lamp_limitbtm).w       ; screen bottom limit
		move.b	(a3),($FFFFFE3C).w              ; routine counter for dynamic level mod
		adda    #2,a3                           ; advance data location
		move.w	(a3),d0                         ; set level

		bra.w	@load_finish			; branch to common level load routine
; ===========================================================================

@rightside:
		lea     RightData,a3
		bra.s   @load2
@leftside:
		lea     LeftData,a3
	@load2:
		move.w	(v_zone).w,d3
		lsl.b	#6,d3
		lsr.w	#5,d3
		adda.w	(a3,d3.w),a3			; load the pointer to the current act
	@chk_y:
		move.w	(a3)+,d1			; get max y pos for this transition
		sub.w	obY(a0),d1			; subtract sonic's y pos
		bcc.s	@y_ok				; if still greater than 0, branch
		adda.w	#12,a3				; advance to next transition
		bra.w	@chk_y				; loop
	@y_ok:
		move.w  (a3)+,(f_dontstopmusic).w	; load graphics/change music?
		move.w	(a3)+,($FFFFFE32).w		; x-position
		move.w	obY(a0),d1
		add.w	(a3)+,d1         		; put y offset in d1
		andi.w	#$FFF,d1
		move.w	d1,($FFFFFE34).w                ; add offset to y position
		move.w	(a3)+,(v_lamp_limitbtm).w       ; screen bottom limit
		move.b	(a3),($FFFFFE3C).w              ; routine counter for dynamic level mod
		adda    #2,a3                           ; advance data location
		move.w	(a3),d0                         ; set level
; ===========================================================================
@load_finish:
		move.b	#$FF,(v_lastlamp).w 	         ; lamppost number
		move.b	(v_lastlamp).w,($FFFFFE31).w
		move.w	(v_rings).w,($FFFFFE36).w 	; rings
		move.b	(v_lifecount).w,($FFFFFE54).w 	; lives
		move.l	(v_time).w,($FFFFFE38).w 	; time
		move.w	(v_screenposx).w,($FFFFFE40).w 	; screen x-position
		move.w	(v_screenposy).w,($FFFFFE42).w 	; screen y-position

		move.w  (v_player+obVelX).w,(v_lamp_xspeed).w
		move.w  (v_player+obVelY).w,(v_lamp_yspeed).w
		move.w	(v_player+obInertia).w,(v_lamp_inertia).w
		move.w  (v_player+obAnim).w,(v_lamp_anim).w

		move.b	(v_player+obStatus2).w,(v_lamp_status2).w
		move.b  #0,(v_lamp_dir).w               ; clear dir flag
		btst    #0,(v_player+obStatus).w        ; test which way sonic is facing
		beq.s   @chkroll                       ; if left, branch
		move.b  #1,(v_lamp_dir).w               ; set if facing right

	 @chkroll:
		move.b  #0,(v_lamp_roll).w               ; clear roll flag
		btst    #2,(v_player+obStatus).w         ; test if sonic is rolling
		beq.s   @notrolling                     ; if not, branch
		move.b  #1,(v_lamp_roll).w               ; set roll flag

	 @notrolling:
		move.w	d0,(v_zone).w                    ; set level     +++
		move.w	#1,(f_restart).w                 ; restart the level
		rts

@sideslocked:
		move.w	d0,obX(a0)
		move.w	#0,obX+2(a0)
		move.w	#0,obVelX(a0)	; stop Sonic moving
		move.w	#0,obInertia(a0)
		rts
; End of function Sonic_LevelBound

