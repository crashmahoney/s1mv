; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to roll when he's moving
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Roll:				; XREF: Obj01_MdNormal

; this bit restores Sonic's animation after level transitions
		cmpi.b  #$FF,(v_lastlamp).w        ; was last lamp no.FF (did we switch acts)
		bne.w   @skipaddspeed              ; if not, branch
		move.w  (v_lamp_xspeed).w,(v_player+obVelX).w
		move.w  (v_lamp_yspeed).w,(v_player+obVelY).w
		move.w	(v_lamp_inertia).w,(v_player+obInertia).w
;		bset	#1,obStatus(a1)            ; set in air bit
; 		bclr	#3,obStatus(a1)            ; clear 'shouldn't fall' bit
		move.w	(v_lamp_anim).w,(v_player+obAnim).w
		bclr    #0,(v_player+obStatus).w
		tst.b   (v_lamp_dir).w             ; was sonic facing right at level transition?
		beq.s   @skipchangedir             ; if not, branch
		bset	#0,(v_player+obStatus).w   ; face right

	@skipchangedir:
		tst.b   (v_lamp_roll).w            ; was sonic rolling at level transition?
		beq.s   @skipaddspeed              ; if not, branch
		bsr     roll                       ; make sonic roll

	@skipaddspeed:
		tst.b	(f_jumponly).w
		bne.s	@noroll
		move.w	obInertia(a0),d0
		bpl.s	@ispositive
		neg.w	d0

	@ispositive:
		cmpi.w	#$100,d0		; is Sonic moving at $80 speed or faster?    ; +++ changed
		bcs.s	@noroll			; if not, branch
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0		; is left/right	being pressed?
		bne.s	@noroll			; if yes, branch
		btst	#bitDn,(v_jpadhold2).w 	; is down being pressed?
		bne.s	Sonic_ChkRoll		; if yes, branch


	@noroll:
		cmpi.b	#id_Crouch,obAnim(a0) 
		beq.s	@noduck	
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0		; is left/right	being pressed?
		bne.s	@noduck			; if yes, branch
		btst	#bitDn,(v_jpadhold2).w 	; is down being pressed?
		bne.s	@duck			; if yes, branch
	@noduck:
		cmpi.b  #$FF,(v_lastlamp).w   	; was last lamp no.FF (did we switch acts)
		beq.s   ismoving              	; if so, branch
		rts

	@duck:
	
		move.b	#id_Duck,obAnim(a0)	; use "ducking"	animation
		rts
; ===========================================================================

Sonic_ChkRoll:
		btst	#2,obStatus(a0)	; is Sonic already rolling?
		beq.s	roll		; if not, branch
		rts
; ===========================================================================

roll:
		bset	#2,obStatus(a0)
		move.b	#$E,obWidth(a0)
		move.b	#7,obHeight(a0)
		move.b	#id_Roll,obAnim(a0) ; use "rolling" animation
		addq.w	#5,obY(a0)
		cmpi.b  #$FF,(v_lastlamp).w   ; was last lamp no.FF (did we switch acts)
		beq.s   ismoving              ; if so, branch
		sfx	sfx_Roll	; play rolling sound
		tst.w	obInertia(a0)
		bne.s	ismoving
		move.w	#$200,obInertia(a0) ; set inertia if 0

	ismoving:
;                clr.b   (v_lastlamp).w
		rts	
; End of function Sonic_Roll