; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

Map_LampStars:
		dc.w Map_LampStars_6-Map_LampStars, Map_LampStars_C-Map_LampStars	
		dc.w Map_LampStars_12-Map_LampStars	
Map_LampStars_6:	dc.b 1	
		dc.b $F8, 5, 0, $8, $F8	
Map_LampStars_C:	dc.b 1	
		dc.b $FC, 0, 0, $C, $FC
Map_LampStars_12:	dc.b 1
		dc.b $FC, 0, 0, $D, $FC
		even