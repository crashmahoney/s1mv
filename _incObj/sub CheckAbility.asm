; ---------------------------------------------------------------------------
; Subroutine to see if an ability is equipped

; input:
;	d0 = ability to check for

; output:
;	d1 = 0 if not equipped, 1 if equipped
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

CheckAbility:
		moveq	#0,d1
		moveq	#0,d2
		move.b	(v_jpadpress2).w,d1
	@chka:
                move.b  d1,d2
        	andi.b	#btnA,d2	              ; is A pressed?
		beq.s	@chkb	                      ; if not, branch
		cmp.b   (v_a_ability).w,d0            ; is ability in this slot the same as the one we're looking for?
		bne.s   @chkb                         ; if not, branch
		moveq	#1,d1                         ; set d1 to 1 to pass back to main script
		rts
	@chkb:
                move.b  d1,d2
        	andi.b	#btnB,d2	              ; is B pressed?
		beq.s	@chkc	                      ; if not, branch
		cmp.b   (v_b_ability).w,d0            ; is ability in this slot the same as the one we're looking for?
		bne.s   @chkc                         ; if not, branch
		moveq	#1,d1                         ; set d1 to 1 to pass back to main script
		rts
	@chkc:
                move.b  d1,d2
        	andi.b	#btnC,d2	              ; is C pressed?
		beq.s	@notequipped	                      ; if not, branch
		cmp.b   (v_c_ability).w,d0            ; is ability in this slot the same as the one we're looking for?
		bne.s   @notequipped                          ; if not, branch
		moveq	#1,d1                         ; set d1 to 1 to pass back to main script
		rts
	@notequipped:
		moveq	#0,d1
                rts
; End of function CheckAbility

; ===========================================================================
