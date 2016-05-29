


ShakeScreen:
		move.w	(v_shakeamount).w,d0
		beq.s	@rts

		btst	#0,(v_framebyte).w
		beq.s	@shake
		neg.w	d0				; negate shake amount on odd frames
		subq.b	#1,(v_shaketime).w		; sub 1 from timer
		bpl.s	@shake				; if time left, branch
		move.b	#0,(v_shaketime).w
		asr.w	#1,d0				; halve shake amount
@shake:
		move.w	d0,(v_shakeamount).w		; store new value in ram
		sub.w	d0,(v_scrposy_dup).w
		sub.w	d0,(v_bgposy_dup).w

@rts:
		rts