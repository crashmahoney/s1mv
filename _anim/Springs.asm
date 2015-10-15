; ---------------------------------------------------------------------------
; Animation script - springs
; ---------------------------------------------------------------------------
Ani_Spring:	dc.w @flat-Ani_Spring
		dc.w @horiz-Ani_Spring
		dc.w @diag-Ani_Spring
@flat:	dc.b 0,	1, 0, 0, 2, 2, 2, 2, 2,	2, 0, afRoutine
@horiz:	dc.b 0,	4, 3, 3, 5, 5, 5, 5, 5,	5, 3, afRoutine
@diag:	dc.b 0,	7, 6, 6, 8, 8, 8, 8, 8,	8, 6, afRoutine
		even