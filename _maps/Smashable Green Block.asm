; ---------------------------------------------------------------------------
; Sprite mappings - smashable green block (MZ)
; ---------------------------------------------------------------------------
; Map_Smab:	dc.w @two-Map_Smab
; 		dc.w @four-Map_Smab
; @two:		dc.b 2
; 		dc.b $F0, $D, 0, 0, $F0	; two fragments, arranged vertically
; 		dc.b 0,	$D, 0, 0, $F0
; @four:		dc.b 4
; 		dc.b $F0, 5, $80, 0, $F0 ; four fragments
; 		dc.b 0,	5, $80,	0, $F0
; 		dc.b $F0, 5, $80, 0, 0
; 		dc.b 0,	5, $80,	0, 0
; 		even
Map_Smab:	dc.w @two-Map_Smab, @topleft-Map_Smab         ; +++ zone agnostic objects
		dc.w @bottomleft-Map_Smab, @topright-Map_Smab 
		dc.w @bottomright-Map_Smab
@two:		dc.b 2
		dc.b $F0, $D, 0, 0, $F0	; two fragments, arranged vertically
		dc.b 0,	$D, 0, 0, $F0
@topleft:		dc.b 1
		dc.b $F0, 5, $80, 0, $F0 ; four fragments
@bottomleft:	dc.b 1
		dc.b 0,	5, $80,	0, $F0
@topright:	dc.b 1
		dc.b $F0, 5, $80, 0, 0
@bottomright:	dc.b 1
		dc.b 0,	5, $80,	0, 0
		even
 
Map_Smab2:	dc.w @full-Map_Smab2, @topleft-Map_Smab2
		dc.w @bottomleft-Map_Smab2, @topright-Map_Smab2 
		dc.w @bottomright-Map_Smab2
@full:		dc.b 4
		dc.b $F0, 5, $80, 0, $F0 ; four fragments
		dc.b 0,	5, $80,	0, $F0
		dc.b $F0, 5, $80, 0, 0
		dc.b 0,	5, $80,	0, 0
@topleft:		dc.b 1
		dc.b $F0, 5, $80, 0, $F0 ; four fragments
@bottomleft:	dc.b 1
		dc.b 0,	5, $80,	0, $F0
@topright:	dc.b 1
		dc.b $F0, 5, $80, 0, 0
@bottomright:	dc.b 1
		dc.b 0,	5, $80,	0, 0
		even