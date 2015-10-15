; ---------------------------------------------------------------------------
; Sprite mappings - GHZ	platforms
; ---------------------------------------------------------------------------
Map_Plat_GHZ:	dc.w @small-Map_Plat_GHZ
		dc.w @large-Map_Plat_GHZ
@small:	        dc.b 2
		dc.b $F4, $F, 0, 0, $E0
		dc.b $F4, $F, 8, 0, $0
@large:		dc.b $A
		dc.b $F4, $F, 0, $C5, $E0 ; large column platform
		dc.b 4,	$F, 0, $D5, $E0
		dc.b $24, $F, 0, $D5, $E0
		dc.b $44, $F, 0, $D5, $E0
		dc.b $64, $F, 0, $D5, $E0
		dc.b $F4, $F, 8, $C5, 0
		dc.b 4,	$F, 8, $D5, 0
		dc.b $24, $F, 8, $D5, 0
		dc.b $44, $F, 8, $D5, 0
		dc.b $64, $F, 8, $D5, 0
		even