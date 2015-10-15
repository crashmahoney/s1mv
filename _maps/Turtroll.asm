; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

Map_Turtroll:
		dc.w @stand-Map_Turtroll, @crouch1-Map_Turtroll
		dc.w @crouch2-Map_Turtroll, @crouch3-Map_Turtroll	
		dc.w @roll1-Map_Turtroll, @roll2-Map_Turtroll	
		dc.w @roll3-Map_Turtroll, @dizzy1-Map_Turtroll	
		dc.w @dizzy2-Map_Turtroll
@stand:	        dc.b 3
		dc.b $F2, 5, $20, 0, $F4
		dc.b $2, 4, $20, 4, $F4
		dc.b $F2, 2, $20, 6, 4
@crouch1:	dc.b 3
		dc.b $F2, 5, $20, 9, $F4
		dc.b $2, 4, $20, $11, $F4
		dc.b $F2, 2, $20, 6, 4
@crouch2:	dc.b 3
		dc.b $F2, 5, $20, $D, $F4
		dc.b $2, 4, $20, $11, $F4
		dc.b $F2, 2, $20, 6, 4
@crouch3:	dc.b 1
		dc.b $F2, $A, $20, $13, $F4
@roll1:	        dc.b 1
		dc.b $F2, $A, $20, $1C, $F4
@roll2:	        dc.b 1
		dc.b $F2, $A, $20, $25, $F4
@roll3:   	dc.b 1
		dc.b $F2, $A, $20, $2E, $F4
@dizzy1:	dc.b 3
		dc.b $F2, 5, $20, $37, $F4
		dc.b $2, 4, $20, 4, $F4
		dc.b $F2, 2, $20, 6, 4
@dizzy2:	dc.b 3
		dc.b $F2, 5, $20, $3B, $F4
		dc.b $2, 4, $20, 4, $F4
		dc.b $F2, 2, $20, 6, 4
		even