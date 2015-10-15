; ---------------------------------------------------------------------------
; Sprite mappings - GHZ, LZ and MZ swinging platforms
; ---------------------------------------------------------------------------
Map_Swing_GHZ:	dc.w @block-Map_Swing_GHZ
		dc.w @chain-Map_Swing_GHZ
		dc.w @anchor-Map_Swing_GHZ
@block:		dc.b 2
		dc.b $F8, 9, $20,	4, $E8
		dc.b $F8, 9, $28,	4, 0
@chain:		dc.b 1
		dc.b $F8, 5, $0,	0, $F8
@anchor:	dc.b 1
		dc.b $F8, 5, $20,	$A, $F8
		even
; +++ zone agnostic objects
Map_Swing_LZ:	dc.w @block2-Map_Swing_LZ
		dc.w @chain2-Map_Swing_LZ
		dc.w @anchor2-Map_Swing_LZ
@block2:	dc.b 1
		dc.b $F8, $D, 1, $26, $F0
@chain2:		dc.b 1
		dc.b $F8, 5, 0,	0, $F8
@anchor2:	dc.b 1
		dc.b $F8, 5, 0,	$14, $F8
		even