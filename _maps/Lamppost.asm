; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

Map_Lamp:	
		dc.w @blue-Map_Lamp, @poleonly-Map_Lamp	
		dc.w @redballonly-Map_Lamp, @red-Map_Lamp	
@blue:		dc.b 5	
		dc.b $E4, 1, $0, 0, $FC	
		dc.b $F4, 3, $0, 2, $F8	
		dc.b $F4, 3, $8, 2, 0	
		dc.b $D4, 1, 0, 6, $F8	
		dc.b $D4, 1, 8, 6, 0	
@poleonly:	dc.b 3	
		dc.b $E4, 1, $0, 0, $FC	
		dc.b $F4, 3, $0, 2, $F8	
		dc.b $F4, 3, $8, 2, 0	
@redballonly:	dc.b 2	
		dc.b $F8, 1, $20, 6, $F8	
		dc.b $F8, 1, $28, 6, 0	
@red:		dc.b 5	
		dc.b $E4, 1, $0, 0, $FC	
		dc.b $F4, 3, $0, 2, $F8	
		dc.b $F4, 3, $8, 2, 0	
		dc.b $D4, 1, $20, 6, $F8	
		dc.b $D4, 1, $28, 6, 0	
		even