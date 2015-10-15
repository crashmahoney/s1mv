; --------------------------------------------------------------------------------
; Invincibility Stars Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

Map_Invinc:
		dc.w @invinc0-Map_Invinc, @invinc1-Map_Invinc
		dc.w @invinc2-Map_Invinc, @invinc3-Map_Invinc
		dc.w @invinc4-Map_Invinc, @invinc5-Map_Invinc
		dc.w @invinc6-Map_Invinc, @invinc7-Map_Invinc
		dc.w @invinc8-Map_Invinc
@invinc0:	dc.b 0
@invinc1:	dc.b 1
		dc.b $F8, 1, 0, 0, $FC	
@invinc2:	dc.b 1
		dc.b $F8, 1, 0, 2, $FC	
@invinc3:	dc.b 1
		dc.b $F8, 1, 0, 4, $FC	
@invinc4:	dc.b 1
		dc.b $F8, 1, 0, 6, $FC	
@invinc5:	dc.b 1
		dc.b $F8, 1, 0, 8, $FC	
@invinc6:	dc.b 1
		dc.b $F8, 5, 0, $A, $F8	
@invinc7:	dc.b 1
		dc.b $F8, 5, 0, $E, $F8	
@invinc8:	dc.b 1
		dc.b $F0, $F, 0, $12, $F0	
		even