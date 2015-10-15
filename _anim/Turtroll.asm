; ---------------------------------------------------------------------------
; Animation script - Turtroll enemy
; ---------------------------------------------------------------------------
Ani_Turtroll:	dc.w @stand-Ani_Turtroll, @crouch-Ani_Turtroll, @roll-Ani_Turtroll
		dc.w @standup-Ani_Turtroll
@stand:		dc.b $F, 0, afEnd
		even
@crouch:	dc.b $C, 0, 1, 2, 2, 3, 3, 3, af2ndRoutine
		even
@roll:	        dc.b $2, 4, 5, 6, afEnd
		even
@standup:	dc.b $F, 2, 1, 7, 7, 8, 7, 7, 8, 8, 8, 7, af2ndRoutine
		even
