; ---------------------------------------------------------------------------
; Subroutine to	prevent	Sonic leaving the boundaries of	a level
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_LevelBound:			; XREF: Obj01_MdNormal; et al
		cmpi.b  #$0C,(v_gamemode).w
		bne.w   @rts
        move.l	obX(a0),d1
		smi.b	d2				; Set d2 if player on position > 32767
		add.w	d2,d2			; Move bit up
		move.w	obVelX(a0),d0
		spl.b	d2				; Set if speed is positive
		add.w	d2,d2			; Move bit up
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
		spl.b	d2				; Set if position+speed is < 32768
		move.w	(v_limitleft2).w,d0
		addi.w	#$10,d0
		tst.w	d2				; If d2 is zero, we had an underflow of position
		beq.w	@sideslocked
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
;		move.w	(v_limittop2).w,d0
;		addi.w	#$E0,d0
		cmp.w	#0,obY(a0)	; has Sonic touched the	top boundary?
		blt.w	@top		; if yes, branch
@rts:
		rts
; ===========================================================================

@bottom:
		move.w	($FFFFF726).w,d0	; +++ fix dying at bottom bug
		move.w	($FFFFF72E).w,d1	; +++
		cmp.w	d0,d1			; +++ screen still scrolling down?
		blt.w	@bottom_locret		; +++ if so, don't kill Sonic

		cmpi.w	#(id_SBZ<<8)+1,(v_zone).w ; is level SBZ2 ?
		bne.w	@NotSBZ2
		clr.b	(v_lastlamp).w	; clear	lamppost counter
		move.w	#(id_LZ<<8)+3,(v_zone).w ; set level to SBZ3 (LZ4)
		move.w	#1,(f_restart).w ; restart the level
		rts
@notSBZ2:
		cmpi.b	#2,(v_act).w	; is act number 02 (act 3)?
		bne.w	@nextact        ; if no, go to next act

		cmpi.w	#$2000,(v_player+obX).w
        ;        jmp     KillSonic
		move.w	#$0700,(v_zone).w	; first 2 digits are the zone number, second pair are act number
		move.w	#1,(f_restart).w ; restart level

@bottom_locret:
		rts


@nextact
		clr.b	(v_lastlamp).w					; clear	lamppost counter
		move.b  #1,(f_dontstopmusic).w     		; keep playing current song
		jsr     SaveState                       ; Save act's state to SRAM
	; +++ save the position you enter the next level at
		move.b	#$FF,(v_lastlamp).w 			; lamppost number
		move.b	(v_lastlamp).w,($FFFFFE31).w
		move.w	obX(a0),($FFFFFE32).w			; x-position
	;	move.w	obY(a0),($FFFFFE34).w			; y-position
		move.w	#$0001,($FFFFFE34).w			; y-position
		move.w	(v_rings).w,($FFFFFE36).w 		; rings
		move.b	(v_lifecount).w,($FFFFFE54).w 	; lives
		move.l	(v_time).w,($FFFFFE38).w 		; time
		move.w	(v_screenposx).w,($FFFFFE40).w 	; screen x-position
		move.w	(v_limitbtm1).w,(v_lamp_limitbtm).w
		move.w	($FFFFF708).w,($FFFFFE44).w 	; bg position
		move.w	($FFFFF70C).w,($FFFFFE46).w 	; bg position
		move.w	($FFFFF710).w,($FFFFFE48).w 	; bg position
		move.w	($FFFFF714).w,($FFFFFE4A).w 	; bg position
		move.w	($FFFFF718).w,($FFFFFE4C).w 	; bg position
		move.w	($FFFFF71C).w,($FFFFFE4E).w 	; bg position

		move.w  (v_player+obVelX).w,(v_lamp_xspeed).w
		move.w  (v_player+obVelY).w,(v_lamp_yspeed).w
		move.w	(v_player+obInertia).w,(v_lamp_inertia).w
		move.w  (v_player+obAnim).w,(v_lamp_anim).w

		move.b  #0,(v_lamp_dir).w               ; clear dir flag
		btst    #0,(v_player+obStatus).w         ; test which way sonic is facing
		beq.s   @chkroll                         ; if left, branch
		move.b  #1,(v_lamp_dir).w               ; set if facing right

	@chkroll:
		move.b  #0,(v_lamp_roll).w               ; clear roll flag
		btst    #2,(v_player+obStatus).w         ; test if sonic is rolling
		beq.s   @notrolling                      ; if not, branch
		move.b  #1,(v_lamp_roll).w               ; set roll flag

	@notrolling:

		add.w	#1,(v_zone).w ; set level to next    +++
		move.w	#1,(f_restart).w ; restart the level
		rts
@top:
		cmpi.b	#0,(v_act).w	; is act number 00 (act 1)?
		bne.w	@prevact        ; if no, go to next act
		rts

@prevact:
		clr.b	(v_lastlamp).w	; clear	lamppost counter
		move.b  #1,(f_dontstopmusic).w     ; keep playing current song
		jsr     SaveState                        ; Save act's state to SRAM
	; +++ save the position you enter the next level at
		move.b	#$FF,(v_lastlamp).w 	; lamppost number
		move.b	(v_lastlamp).w,($FFFFFE31).w
		move.w	obX(a0),($FFFFFE32).w		; x-position
	;	move.w	obY(a0),($FFFFFE34).w		; y-position
		move.w	#$0250,($FFFFFE34).w		; y-position
		move.w	(v_rings).w,($FFFFFE36).w 	; rings
		move.b	(v_lifecount).w,($FFFFFE54).w 	; lives
		move.l	(v_time).w,($FFFFFE38).w 	; time
		move.w	(v_screenposx).w,($FFFFFE40).w 	; screen x-position
		move.w	#$0300,($FFFFFE42).w 	; screen y-position
		move.w	(v_limitbtm1).w,(v_lamp_limitbtm).w
		move.w	($FFFFF708).w,($FFFFFE44).w 	; bg position
		move.w	($FFFFF70C).w,($FFFFFE46).w 	; bg position
		move.w	($FFFFF710).w,($FFFFFE48).w 	; bg position
		move.w	($FFFFF714).w,($FFFFFE4A).w 	; bg position
		move.w	($FFFFF718).w,($FFFFFE4C).w 	; bg position
		move.w	($FFFFF71C).w,($FFFFFE4E).w 	; bg position

                move.w  (v_player+obVelX).w,(v_lamp_xspeed).w
                move.w  (v_player+obVelY).w,(v_lamp_yspeed).w
		move.w	(v_player+obInertia).w,(v_lamp_inertia).w
                move.w  (v_player+obAnim).w,(v_lamp_anim).w

                move.b  #0,(v_lamp_dir).w               ; clear dir flag
                btst    #0,(v_player+obStatus).w         ; test which way sonic is facing
                beq.s   @chkroll2                        ; if left, branch
                move.b  #1,(v_lamp_dir).w               ; set if facing right

         @chkroll2:
                move.b  #0,(v_lamp_roll).w               ; clear roll flag
                btst    #2,(v_player+obStatus).w         ; test if sonic is rolling
                beq.s   @notrolling2                     ; if not, branch
                move.b  #1,(v_lamp_roll).w               ; set roll flag

         @notrolling2:

		sub.w	#1,(v_zone).w ; set level to prev    +++
		move.w	#1,(f_restart).w ; restart the level
		rts

; ===========================================================================

@rightside:
                lea     RightData,a3
                bra.s   @load

@leftside:

                cmpi.b  #$02,(v_act).w                   ; act 3?
                bne.s   @loadleftdata                    ;
                move.w  #$1000,d0                        ; ***(this bit is a hack to stop level from changing at the wrong point in act 3)
 		move.w  obX(a0),d1                       ;
                cmp.w   d0,d1                            ; is sonic far enough into the level that going off the left doesn't matter? (d1 is sonic's pos)
                ble.s   @loadleftdata
                rts

          @loadleftdata:
                lea     LeftData,a3
          
          @load:
		clr.b	(v_lastlamp).w	                 ; clear lamppost counter
		move.b  #1,(f_dontstopmusic).w           ; keep playing current song
		move.b	#$FF,(v_lastlamp).w 	         ; lamppost number
		move.b	(v_lastlamp).w,($FFFFFE31).w
                jsr     SaveState                        ; Save act's state to SRAM
                moveq	#0,d3
		move.b	(v_zone).w,d3                    ; get zone number
		mulu    #4,d3                            ; mult by 4 to get index number of first act in zone
		add.b   (v_act).w,d3                     ; add act number to get final index number
		mulu    #6,d3                           ; mutliply by number of words ofdata saved in each act
                add.w   d3,d3                            ; double (cos they're stored as words)
                lea     (a3,d3),a3                       ; sets a3 to address of data
		move.b  (a3),(f_dontstopmusic).w        ; load graphics/change music?
                adda    #2,a3                           ; advance data location
		move.w	(a3)+,($FFFFFE32).w		; x-position
		move.w	obY(a0),d1
		add.w	(a3)+,d1         		; put y offset in d1
		andi.w	#$FFF,d1
		move.w	d1,($FFFFFE34).w                ; add offset to y position
		move.w	(a3)+,(v_lamp_limitbtm).w       ; screen bottom limit
		move.b	(a3),($FFFFFE3C).w              ; routine counter for dynamic level mod
                adda    #2,a3                           ; advance data location
		move.w	(a3),d0                         ; set level

		move.w	(v_rings).w,($FFFFFE36).w 	; rings
		move.b	(v_lifecount).w,($FFFFFE54).w 	; lives
		move.l	(v_time).w,($FFFFFE38).w 	; time
		move.w	(v_screenposx).w,($FFFFFE40).w 	; screen x-position
		move.w	(v_screenposy).w,($FFFFFE42).w 	; screen y-position

                move.w  (v_player+obVelX).w,(v_lamp_xspeed).w
                move.w  (v_player+obVelY).w,(v_lamp_yspeed).w
		move.w	(v_player+obInertia).w,(v_lamp_inertia).w
                move.w  (v_player+obAnim).w,(v_lamp_anim).w

                move.b  #0,(v_lamp_dir).w               ; clear dir flag
                btst    #0,(v_player+obStatus).w        ; test which way sonic is facing
                beq.s   @chkroll4                       ; if left, branch
                move.b  #1,(v_lamp_dir).w               ; set if facing right

         @chkroll4:
                move.b  #0,(v_lamp_roll).w               ; clear roll flag
                btst    #2,(v_player+obStatus).w         ; test if sonic is rolling
                beq.s   @notrolling4                     ; if not, branch
                move.b  #1,(v_lamp_roll).w               ; set roll flag

         @notrolling4:
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

