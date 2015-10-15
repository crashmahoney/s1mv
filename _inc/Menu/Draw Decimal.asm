DrawDecimal:
       ; convert to decimal
       ; input  d5 = number to draw
       ;        d6 = no. of digits to draw (loop counter)
       ;        a2 = position to draw
       ;        a6 = amount to multiply digit by
		moveq	#0,d4                    ; clear d4

@mainloop:
		moveq	#0,d2                    ; clear d2 (carried digit)
		move.l	(a6)+,d3                 ; what to multiply digit by

@loopback:
		sub.l	d3,d5                    ; subtract from number of rings
		bcs.s	@carry                   ; branch on carry set
		addq.w	#1,d2                    ; add 1 to carried digit
		bra.s	@loopback                ; skip next bit
; ===========================================================================

@carry:                                          ; if no carried digit
		add.l	d3,d5                    ; add back to number of rings
		tst.w	d2                       ; is there a carried digit?
		beq.s	@nocarry                 ; if not, branch
		moveq	#1,d4                    ; put 1 in d4

@nocarry:
		tst.w	d4                       ; is there anything in d4?
		beq.s	@skipdraw                ; if not, dont't draw anything
;		lsl.w	#6,d2

                move.w  d2,(a2)                  ; draw it, move drawing position back a tile for next digit
                add.w   #FontLocation+$30,(a2)

@skipdraw:
                add.w  #2,a2                     ; move drawing position to next digit

		dbf	d6,@mainloop             ; loop function

		rts	
                even
; ===========================================================================
