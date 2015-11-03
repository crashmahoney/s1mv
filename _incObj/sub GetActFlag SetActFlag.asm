; ---------------------------------------------------------------------------
; input:
; d0 - bit you want to read (31-0)
; d1 - zone + act you want to read from (optional, use GetActFlag_d1)
;
; output:
; d0 - $0 if bit is clear, or $FF if set
; ---------------------------------------------------------------------------

GetActFlag:							; jump here to get data from the current act
		move.w	(v_zone).w,d1
GetActFlag_d1:						; jump here to get another act's data, put the number in d1
		lsl.b	#6,d1
		lsr.w	#4,d1
		lea		(v_actstates).w,a2
		adda.w	d1,a2

		move.l	(a2),d1				; put 4 bytes of act flags in d1
		btst	d0,d1				; test bit number stored in d0
		sne.b	d0					; if bit is set, move $FF to d0

		rts

; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
; input:
; d0 - bit you want to set (31-0)
; d1 - zone + act you want to read from (optional, use GetActFlag_d1)
; ---------------------------------------------------------------------------

SetActFlag:							; jump here to get data from the current act
		move.w	(v_zone).w,d1
SetActFlag_d1:						; jump here to get another act's data, put the number in d1
		lsl.b	#6,d1
		lsr.w	#4,d1
		lea		(v_actstates).w,a2
		adda.w	d1,a2

		move.l	(a2),d1				; put 4 bytes of act flags in d1
		bset	d0,d1				; set bit number stored in d0
		move.l	d1,(a2)				; save back to memory
		rts

; ---------------------------------------------------------------------------



