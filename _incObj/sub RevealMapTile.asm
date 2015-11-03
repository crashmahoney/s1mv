;========================================================================================================================
; reveal map screen tiles when sonic enters them
; each map tile is equal to 512x512 in level units
; map total size is 80 x 35 tiles
;========================================================================================================================
RevealMapTile:
		move.w	(v_player+obX).w,d0			; get player X position
		lsr.w	#8,d0						; divide by 512
		lsr.w	#1,d0						; divide by 512
		add.b	(v_worldmap_X).w,d0
		move.w	d0,d2						
		andi.w	#$F,d2						; get bit in byte
		lsr.w	#3,d0						; divide by 8

		move.w	(v_player+obY).w,d1			; get player Y position
		lsr.w	#8,d1						; divide by 512
		lsr.w	#1,d1						; divide by 512
		add.b	(v_worldmap_Y).w,d1
		move.w	d1,d3
		lsl.w	#3,d1						; multiply by 10 (80 rows divided by 8 bits)
		add.w	d3,d1						; multiply by 10 
		add.w	d3,d1						; multiply by 10 
		add.w	d1,d0						; add coulmn

		lea		(v_worldmap).w,a0
		lea		(a0,d0.w),a0

		bset	d2,(a0)

		rts

;========================================================================================================================
; called in level load sequence to get data for above routine
;========================================================================================================================
GetWorldMapCoOrds:
		lea		WorldMapTopLeft,a1
		moveq	#0,d3
		move.b	(v_zone).w,d3                    ; get zone number
		add.w   d3,d3                            ; mult by 4 to get index number of first act in zone
		add.w   d3,d3                            ; mult by 4 to get index number of first act in zone
		add.b   (v_act).w,d3                     ; add act number to get final index number
		add.w   d3,d3                            ; mutliply by 2 (number of bytes of data for each act)
		lea     (a1,d3),a1                       ; sets a3 to address of data
		move.w	(a1),(v_worldmap_X).w			 ; save x and y (each 1 byte) to memory for the reveal subroutine
		rts