; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

Map_HudText:	
		dc.w @even-Map_HudText, @odd-Map_HudText	
@even:	dc.b 7	
		dc.b $E4, $C, $81, $84, 9	
		dc.b $E4, $C, $81, $88, $29	
		dc.b $E4, $C, $81, $8C, $49	
		dc.b $E0, $D, $80, 0, $F8	
		dc.b $E0, $D, $80, 8, $58	
		dc.b $E0, $D, $80, 4, $18	
		dc.b $E0, $D, $80, 4, $38	
@odd:	dc.b 7	
		dc.b $E4, $C, $81, $84, $D	
		dc.b $E4, $C, $81, $88, $2D	
		dc.b $E4, 8, $81, $8C, $4D	
		dc.b $E0, $D, $80, 0, $F8	
		dc.b $E0, $D, $80, 8, $58	
		dc.b $E0, $D, $80, 4, $18	
		dc.b $E0, $D, $80, 4, $38	
		even