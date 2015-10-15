; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to double jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_DoubleJump:				; XREF: Obj01_MdNormal; Obj01_MdRoll
		tst.b	(v_justwalljumped).w 	      ; just wall jumped?
		bne.s	@dontjump                     ; if so, don't double jump

		tst.b   (v_airjumpcount).w
 		bne.s	@dontjump	              ; if air jump flag set, branch


                moveq   #0,d3                         ; clear flag to make sonic spin when he jumps
                moveq	#aDoubleJump2,d0              ; which ability to check for  (Level 2 Double Jump)
                jsr     CheckAbility                  ; check if equppied
                tst.b   d1                            ; is ability equipped?
                beq.s   @notlvl2                      ; if not, branch
                moveq   #1,d3                         ; set flag to make sonic spin when he jumps
		move.b  #1,(v_airjumpcount).w         ; set air jump flag
		move.w	#$680,d2                      ; set jump strength
		btst	#6,obStatus(a0)               ; underwater?
		beq.s	@doublejump                   ; if not, branch
		move.w	#$380,d2                      ; set lower jump strength
		bra.s   @doublejump
@notlvl2:
		moveq	#aDoubleJump1,d0              ; which ability to check for (Level 1 double jump)
                jsr     CheckAbility                  ; check if equppied
                tst.b   d1                            ; is ability equipped?
                beq.s   @dontjump                     ; if not, branch
		move.b  #1,(v_airjumpcount).w         ; set air jump flag
		move.w	#$580,d2                      ; set jump strength
		btst	#6,obStatus(a0)               ; underwater?
		beq.s	@doublejump                   ; if not, branch
		move.w	#$280,d2                      ; set lower jump strength
		bra.s   @doublejump
@dontjump:
                rts
@doublejump:
		moveq	#0,d0
;		move.b	obAngle(a0),d0
 		subi.b	#$40,d0
 		jsr	(CalcSine).l
; 		muls.w	d2,d1
; 		asr.l	#8,d1
; 		add.w	d1,obVelX(a0)	       ; make Sonic jump
 		muls.w	d2,d0
		asr.l	#8,d0
	        move.w  #0,obVelY(a0)
		add.w	d0,obVelY(a0)	       ; make Sonic jump
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		addq.l	#4,sp
		move.b	#1,$3C(a0)
		clr.b	$38(a0)
		sfx	sfx_Jump	       ; play jumping sound
		move.b	#$13,obWidth(a0)
		move.b	#9,obHeight(a0)
		bclr	#2,obStatus(a0)        ; clear "is rolling" flag
		move.b	#id_Leap2,obAnim(a0)   ; use leaping animation
		tst.b   d3                     ; is level 2 flag set
                beq.s   @finish                ; if not, branch
		move.b	#$E,obWidth(a0)
		move.b	#7,obHeight(a0)
		addq.w	#5,obY(a0)
		move.b	#id_Roll,obAnim(a0)    ; use rolling animation
		bset	#2,obStatus(a0)        ; set "is rolling" flag
@finish:
                bsr.w   CreateSparks

                rts
; ===========================================================================
; End of function Sonic_Jump