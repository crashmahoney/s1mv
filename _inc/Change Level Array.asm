

RightData:
		dc.w	@ghz1-RightData
		dc.w	@ghz2-RightData
		dc.w	@ghz3-RightData
		dc.w	@ghz4-RightData
		dc.w	@lz1-RightData
		dc.w	@lz2-RightData
		dc.w	@lz3-RightData
		dc.w	@lz4-RightData
		dc.w	@mz1-RightData
		dc.w	@mz2-RightData
		dc.w	@mz3-RightData
		dc.w	@mz4-RightData
		dc.w	@slz1-RightData
		dc.w	@slz2-RightData
		dc.w	@slz3-RightData
		dc.w	@slz4-RightData
		dc.w	@syz1-RightData
		dc.w	@syz2-RightData
		dc.w	@syz3-RightData
		dc.w	@syz4-RightData
		dc.w	@sbz1-RightData
		dc.w	@sbz2-RightData
		dc.w	@sbz3-RightData
		dc.w	@sbz4-RightData
		dc.w	@end1-RightData
		dc.w	@end2-RightData
		dc.w	@end3-RightData
		dc.w	@end4-RightData
		dc.w	@hub1-RightData
		dc.w	@hub2-RightData
		dc.w	@hub3-RightData
		dc.w	@hub4-RightData
		dc.w	@intro1-RightData
		dc.w	@intro2-RightData
		dc.w	@intro3-RightData
		dc.w	@intro4-RightData
		dc.w	@tropz1-RightData
		dc.w	@tropz2-RightData
		dc.w	@tropz3-RightData
		dc.w	@tropz4-RightData

           			;max y pos	; dontstopmusic x-pos,  yoffset   bottom   routine new level
@ghz1:  	dc.w		$F355,		$0000,  	$0002,   $0220,   $07FF,    $0000,   $0200		; mz1
	 		dc.w		$FFFF,		$0000,  	$0002,   $0220,   $07FF,    $0000,   $0300		; slz1
@ghz2:
@ghz3:
@ghz4:
@lz1:
@lz2:
@lz3:
@lz4:
@mz1:     	dc.w 		$FFFF,		$0000,   	$0004,  -$0320,   $0720,    $0000,   $0100		; lz1
@mz2:
@mz3:
@mz4:
@slz1:
@slz2:
@slz3:
@slz4:
@syz1:
@syz2:
@syz3:
@syz4:
@sbz1:
@sbz2:
@sbz3:
@sbz4:
@end1:
@end2:
@end3:
@end4:
@hub1:
@hub2:
@hub3:
@hub4:
@intro1:
@intro2:
@intro3:
@intro4:
@tropz1:
@tropz2:
@tropz3:
@tropz4:  	dc.w		$FFFF,		$0000,  	$0002,   $0220,   $07FF,    $0000,   $0200		; mz1
; ===========================================================================

LeftData:
		dc.w	@ghz1-LeftData
		dc.w	@ghz2-LeftData
		dc.w	@ghz3-LeftData
		dc.w	@ghz4-LeftData
		dc.w	@lz1-LeftData
		dc.w	@lz2-LeftData
		dc.w	@lz3-LeftData
		dc.w	@lz4-LeftData
		dc.w	@mz1-LeftData
		dc.w	@mz2-LeftData
		dc.w	@mz3-LeftData
		dc.w	@mz4-LeftData
		dc.w	@slz1-LeftData
		dc.w	@slz2-LeftData
		dc.w	@slz3-LeftData
		dc.w	@slz4-LeftData
		dc.w	@syz1-LeftData
		dc.w	@syz2-LeftData
		dc.w	@syz3-LeftData
		dc.w	@syz4-LeftData
		dc.w	@sbz1-LeftData
		dc.w	@sbz2-LeftData
		dc.w	@sbz3-LeftData
		dc.w	@sbz4-LeftData
		dc.w	@end1-LeftData
		dc.w	@end2-LeftData
		dc.w	@end3-LeftData
		dc.w	@end4-LeftData
		dc.w	@hub1-LeftData
		dc.w	@hub2-LeftData
		dc.w	@hub3-LeftData
		dc.w	@hub4-LeftData
		dc.w	@intro1-LeftData
		dc.w	@intro2-LeftData
		dc.w	@intro3-LeftData
		dc.w	@intro4-LeftData
		dc.w	@tropz1-LeftData
		dc.w	@tropz2-LeftData
		dc.w	@tropz3-LeftData
		dc.w	@tropz4-LeftData

           			;max y pos	; dontstopmusic x-pos,  yoffset   bottom   routine new level
@ghz1:
@ghz2:
@ghz3:
@ghz4:
@lz1:     	dc.w 		$FFFF,		$0000,   	$1A7C,  $0320,   $07FF,    $0000,   $0200		; mz1
@lz2:
@lz3:
@lz4:
@mz1:     	dc.w 		$FFFF,		$0000,   	$25E0,  -$0220,   $07FF,    $0000,   $0000		; ghz1
@mz2:
@mz3:
@mz4:
@slz1:
@slz2:
@slz3:
@slz4:
@syz1:
@syz2:
@syz3:
@syz4:
@sbz1:
@sbz2:
@sbz3:
@sbz4:
@end1:
@end2:
@end3:
@end4:
@hub1:
@hub2:
@hub3:
@hub4:
@intro1:
@intro2:
@intro3:
@intro4:
@tropz1:
@tropz2:
@tropz3:
@tropz4:     	dc.w 		$FFFF,		$0000,   	$25E0,  -$0220,   $07FF,    $0000,   $0000

; ===========================================================================


BottomData:
		dc.w	@ghz1-BottomData
		dc.w	@ghz2-BottomData
		dc.w	@ghz3-BottomData
		dc.w	@ghz4-BottomData
		dc.w	@lz1-BottomData
		dc.w	@lz2-BottomData
		dc.w	@lz3-BottomData
		dc.w	@lz4-BottomData
		dc.w	@mz1-BottomData
		dc.w	@mz2-BottomData
		dc.w	@mz3-BottomData
		dc.w	@mz4-BottomData
		dc.w	@slz1-BottomData
		dc.w	@slz2-BottomData
		dc.w	@slz3-BottomData
		dc.w	@slz4-BottomData
		dc.w	@syz1-BottomData
		dc.w	@syz2-BottomData
		dc.w	@syz3-BottomData
		dc.w	@syz4-BottomData
		dc.w	@sbz1-BottomData
		dc.w	@sbz2-BottomData
		dc.w	@sbz3-BottomData
		dc.w	@sbz4-BottomData
		dc.w	@end1-BottomData
		dc.w	@end2-BottomData
		dc.w	@end3-BottomData
		dc.w	@end4-BottomData
		dc.w	@hub1-BottomData
		dc.w	@hub2-BottomData
		dc.w	@hub3-BottomData
		dc.w	@hub4-BottomData
		dc.w	@intro1-BottomData
		dc.w	@intro2-BottomData
		dc.w	@intro3-BottomData
		dc.w	@intro4-BottomData
		dc.w	@tropz1-BottomData
		dc.w	@tropz2-BottomData
		dc.w	@tropz3-BottomData
		dc.w	@tropz4-BottomData

           			;max x pos	; dontstopmusic y-pos,  xoffset   bottom   routine new level
@ghz1:
@ghz2:		dc.w		$FFFF,		$FFFF,  	$0002,   $1600,   $0720,    $0000,   $0000		; ghz1
@ghz3:
@ghz4:
@lz1:
@lz2:
@lz3:
@lz4:
@mz1:
@mz2:
@mz3:
@mz4:
@slz1:
@slz2:
@slz3:
@slz4:
@syz1:
@syz2:
@syz3:
@syz4:
@sbz1:
@sbz2:
@sbz3:
@sbz4:
@end1:
@end2:
@end3:
@end4:
@hub1:
@hub2:
@hub3:
@hub4:
@intro1:
@intro2:
@intro3:
@intro4:
@tropz1:
@tropz2:
@tropz3:
@tropz4:  	dc.w		$FFFF,		$0000,  	$0002,   $0220,   $07FF,    $0000,   $0200		; mz1
; ===========================================================================



TopData:
		dc.w	@ghz1-TopData
		dc.w	@ghz2-TopData
		dc.w	@ghz3-TopData
		dc.w	@ghz4-TopData
		dc.w	@lz1-TopData
		dc.w	@lz2-TopData
		dc.w	@lz3-TopData
		dc.w	@lz4-TopData
		dc.w	@mz1-TopData
		dc.w	@mz2-TopData
		dc.w	@mz3-TopData
		dc.w	@mz4-TopData
		dc.w	@slz1-TopData
		dc.w	@slz2-TopData
		dc.w	@slz3-TopData
		dc.w	@slz4-TopData
		dc.w	@syz1-TopData
		dc.w	@syz2-TopData
		dc.w	@syz3-TopData
		dc.w	@syz4-TopData
		dc.w	@sbz1-TopData
		dc.w	@sbz2-TopData
		dc.w	@sbz3-TopData
		dc.w	@sbz4-TopData
		dc.w	@end1-TopData
		dc.w	@end2-TopData
		dc.w	@end3-TopData
		dc.w	@end4-TopData
		dc.w	@hub1-TopData
		dc.w	@hub2-TopData
		dc.w	@hub3-TopData
		dc.w	@hub4-TopData
		dc.w	@intro1-TopData
		dc.w	@intro2-TopData
		dc.w	@intro3-TopData
		dc.w	@intro4-TopData
		dc.w	@tropz1-TopData
		dc.w	@tropz2-TopData
		dc.w	@tropz3-TopData
		dc.w	@tropz4-TopData

           			;max x pos	; dontstopmusic y-pos,  xoffset   bottom   routine new level
@ghz1:		dc.w		$FFFF,		$FFFF,  	$07D0,   -$1600,   $0720,    $0000,   $0001		; ghz2
@ghz2:
@ghz3:
@ghz4:
@lz1:
@lz2:
@lz3:
@lz4:
@mz1:
@mz2:
@mz3:
@mz4:
@slz1:
@slz2:
@slz3:
@slz4:
@syz1:
@syz2:
@syz3:
@syz4:
@sbz1:
@sbz2:
@sbz3:
@sbz4:
@end1:
@end2:
@end3:
@end4:
@hub1:
@hub2:
@hub3:
@hub4:
@intro1:
@intro2:
@intro3:
@intro4:
@tropz1:
@tropz2:
@tropz3:
@tropz4:  	dc.w		$FFFF,		$0000,  	$0002,   $0220,   $07FF,    $0000,   $0200		; mz1
; ===========================================================================
