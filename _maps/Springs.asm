; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

Map_Spring:
		dc.w Map_Spring_12-Map_Spring, Map_Spring_22-Map_Spring	
		dc.w Map_Spring_28-Map_Spring, Map_Spring_33-Map_Spring	
		dc.w Map_Spring_43-Map_Spring, Map_Spring_49-Map_Spring	
		dc.w Map_Spring_54-Map_Spring, Map_Spring_6E-Map_Spring	
		dc.w Map_Spring_83-Map_Spring	
Map_Spring_12:	dc.b 3	
		dc.b $F8, $C, 0, 0, $F0	
		dc.b 0, 0, 0, 4, $F8	
		dc.b 0, 0, 8, 4, 0	
Map_Spring_22:	dc.b 1	
		dc.b 0, $C, 0, 0, $F0	
Map_Spring_28:	dc.b 2	
		dc.b $E8, $C, 0, 0, $F0	
		dc.b $F0, 6, 0, 5, $F8	
Map_Spring_33:	dc.b 3
		dc.b $F0, 3, 0, $0, 0
		dc.b $F8, 0, 0, $4, $F8
		dc.b 0, 0, $10, $4, $F8
Map_Spring_43:	dc.b 1	
		dc.b $F0, 3, 0, $0, $F8
Map_Spring_49:	dc.b 2	
		dc.b $F0, 3, 0, $0, $10
		dc.b $F8, 9, 0, $5, $F8
Map_Spring_54:	dc.b 5	
		dc.b $F0, 8, 0, $0, $F0
		dc.b $F8, 8, 0, $3, $F8
		dc.b $0, 5, 0, $6, 0
		dc.b $FB, 5, 0, $A, $F5
		dc.b $0, 5, 0, $12, $F0
Map_Spring_6E:	dc.b 4	
		dc.b $F8, 8, 0, $0, $E8
		dc.b $0, 8, 0, $3, $F0
		dc.b $8, 5, 0, $6, $F8
		dc.b $0, 5, 0, $12, $F0
Map_Spring_83:	dc.b 6
		dc.b $E8, 8, 0, $0, $F8
		dc.b $F0, 8, 0, $3, 0
		dc.b $F8, 5, 0, $6, 8
		dc.b $0, 5, 0, $12, $F0
		dc.b $FE, 4, 0, $10, $F5
		dc.b $F6, 4, 0, $E, $FD
		even