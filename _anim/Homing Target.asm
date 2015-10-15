; ---------------------------------------------------------------------------
; Animation script - signpost
; ---------------------------------------------------------------------------
Ani_Homing:	dc.w @start-Ani_Homing
                dc.w @normal-Ani_Homing
@start:	 dc.b $1, 0, 1, 2, 3, 4, 5, 6, afChange, 1
@normal: dc.b $F, 6, afBack, 1
		even