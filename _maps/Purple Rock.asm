; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

Map_PRock:
		dc.w Map_PRock_A-Map_PRock, Map_PRock_1F-Map_PRock	
		dc.w Map_PRock_25-Map_PRock, Map_PRock_2B-Map_PRock	
		dc.w Map_PRock_31-Map_PRock	
Map_PRock_A:	dc.b 4	
		dc.b $F0, 9, 0, 0, $E8
		dc.b $0, 9, 0, 6, $E8
		dc.b $F0, 9, 0, $C, $0
		dc.b $0, 9, 0, $12, $0
Map_PRock_1F:	dc.b 1	
		dc.b $F0, 9, 0, 0, $E8
Map_PRock_25:	dc.b 1	
		dc.b $0, 9, 0, 6, $E8
Map_PRock_2B:	dc.b 1	
		dc.b $F0, 9, 0, $C, $0
Map_PRock_31:	dc.b 1
		dc.b $0, 9, 0, $12, $0
		even