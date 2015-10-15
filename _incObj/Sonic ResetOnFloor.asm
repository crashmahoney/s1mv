; ---------------------------------------------------------------------------
; Subroutine to	reset Sonic's mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_ResetOnFloor:			; XREF: PlatformObject; et al
		btst	#4,obStatus(a0)
		beq.s	loc_137AE
		nop	
		nop	
		nop	

loc_137AE:
		bclr	#5,obStatus(a0)
		bclr	#1,obStatus(a0)
		bclr	#4,obStatus(a0)
		btst	#2,obStatus(a0)
		beq.s	@notrolling
		bclr	#2,obStatus(a0)
		move.b	#$13,obWidth(a0)
		move.b	#9,obHeight(a0)
		move.b	#id_Walk,obAnim(a0) ; use running/walking animation
		subq.w	#5,obY(a0)

@notrolling:
		move.b	#0,$3C(a0)
		move.b	#id_Walk,obAnim(a0) ; use running/walking animation (again, to reset leaping animation)
	;Mercury Wall Jump
		move.b	#0,obWallJump(a0)
	;end Wall Jump
		move.w	#0,(v_itembonus).w
 	move.b	#0,flip_angle(a0)
	move.b	#0,flip_turned(a0)
	move.b	#0,flips_remaining(a0)
	            move.b  #0,(v_airjumpcount).w   ; +++ reset airjump count
                move.b  #0,(v_jumpdashcount).w  ; +++ reset jump dash count
                move.b  #0,(v_shieldobj+$31).w  ; clear instashield flag
                lea     (v_homingattackobj).w,a2  ; homing attack object
		move.w	#0,obX(a2)              ; hide it
		move.w	#0,obY(a2)              ;   "  "
		rts
; End of function Sonic_ResetOnFloor