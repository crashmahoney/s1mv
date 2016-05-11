
Sonic_BoostMode:

; clear boost if too slow
		mvabs	obInertia(a0),d0			; get sonic's absolute inertia
		cmpi.w	#$400,d0				; under $400?
		blt.s	@clearboost				; if so, end boost mode

; if already boosting, all good
		btst	#staBoost,obStatus2(a0)			; is sonic already boosting?
		bne.s	@resettimer				; if so, branch

; check if going fast enough
		cmpi.w	#$700,d0				; is speed under $A00?
		blt.s	@resettimer				; if so, branch

; calculate timer required based on number of held rings
		move.w	#250,d0					; 330 frames
		move.w	(v_rings).w,d1				; get rings
		cmpi.w	#200,d1					; rings over 300?
		blo.s	@ringsok
		move.w	#200,d1					; clamp to 300
	@ringsok:
		sub.w	d1,d0					; subtract ring bonus
		moveq	#0,d1
		move.b	obBoostTimer(a0),d1
		sub.w	d1,d0					; subtract timer
		beq.s	@enterboost				; if 0, branch

		addq.b	#1,obBoostTimer(a0)			; add to timer
		rts
	@enterboost:	
		bset	#staBoost,obStatus2(a0)			; set boost flag
		sfx	sfx_SpeedBoost	 			; spring boing sound
		jmp	SetStatEffects				; reset stats
; ================================================================================
@clearboost:
	
		bclr	#staBoost,obStatus2(a0)			; clear boost flag
		beq.s	@resettimer				; if it was already clear, branch
		jsr	SetStatEffects				; reset stats
@resettimer:
		clr.b	obBoostTimer(a0)			; reset timer
@rts:		
		rts