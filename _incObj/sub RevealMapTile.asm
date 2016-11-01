

;========================================================================================================================
; called in level load sequence to get data for RevealMapTile routine
;========================================================================================================================
GetWorldMapCoOrds:
		lea	WorldMapTopLeft,a1
		moveq	#0,d3
		move.b	(v_zone).w,d3                    ; get zone number
		add.w   d3,d3                            ; mult by 4 to get index number of first act in zone
		add.w   d3,d3                            ; mult by 4 to get index number of first act in zone
		add.b   (v_act).w,d3                     ; add act number to get final index number
		add.w   d3,d3                            ; mutliply by 2 (number of bytes of data for each act)
		lea     (a1,d3),a1                       ; sets a3 to address of data
		move.w	(a1),(v_worldmap_X).w			 ; save x and y (each 1 byte) to memory for the reveal subroutine
		rts

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
		andi.w	#$7,d2						; get bit in byte
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

		lea	(v_worldmap).w,a0
		lea	(a0,d0.w),a0
		bset	d2,(a0)					; set map square as revealed

		lsl.w	#3,d0					; multiply by 8
		add.w	d2,d0					; add bit count
		move.w	(v_worldmap_last).w,d1
		cmp.w	d0,d1
		bne.s	DrawMiniMap
		rts
;========================================================================================================================
DrawMiniMap:
		move.w	d0,(v_worldmap_last).w			; update last known position

; Draw the minimap into a buffer in ram

		move.w	#$2700,sr
		move.l	#$89998999,d2			; horizontal line to draw
		move.l	#$90009000,d3			; vertical line to draw
		lea	(v_minimap_buffer).l,a3		; temp ram to write graphics to
		moveq	#8-1,d1
	@clearbuffer:	
		move.l	d2,(a3)+
		move.l	d2,(a3)+
		move.l	d2,(a3)+
		move.l	d2,(a3)+

		move.l	d3,(a3)+
		move.l	d3,(a3)+
		move.l	d3,(a3)+
		move.l	d3,(a3)+

		move.l	d3,(a3)+
		move.l	d3,(a3)+
		move.l	d3,(a3)+
		move.l	d3,(a3)+

		move.l	d3,(a3)+
		move.l	d3,(a3)+
		move.l	d3,(a3)+
		move.l	d3,(a3)+
		dbf	d1,@clearbuffer

		lea	WorldMap,a1			; 4 x 4 tile mappings
		sub.w	#323,d0				
		lea	(a1,d0.l),a1			; first tile to draw
		lea	(v_worldmap).w,a0
		moveq	#0,d4
		move.w	d0,d4				; copy
		and.w	#$7,d4				; get bit to check
		lsr.w	#3,d0				; divide by by 8
		lea	(a0,d0.l),a0			; get byte to check

		lea	Art_MapTiles,a2			; 5 x 5 tile graphics
		lea	(v_minimap_buffer).l,a3		; temp ram to write graphics to
		move.l	#$FFF,d1			; value to and
		moveq	#8-1,d3				; number of 5x5 rows to draw
@dorow:
; the most confusing way to do loop unrolling :P
DoMapTile:	macro	
		moveq	#0,d0
		move.b	(a1)+,d0			; get tile id to draw
		beq.s	@\@nexttile			; if blank tile, skip

		btst	d4,(a0)				; test current bit
		beq.s	@\@nexttile			; if 0, branch

		lsl.w	#5,d0				; multiply d0 by 16 (size of an 8x8 tile)
		lea	(a2,d0.w),a4			; get tile gfx start
		movea.l	a3,a5				; copy tile ram start

; draw 5 rows of pixels
	rept 5
		move.l	(a5),d0	
		and.l	d1,d0
		add.l	(a4)+,d0
		move.l	d0,(a5)
		lea	16(a5),a5			; next line
	endr

@\@nexttile:
		addq.w	#1,d4				; add 1 to bit to check
		and.w	#7,d4							
		bne.s	@\@ok
		adda.w	#1,a0				; add 1 to byte to check
	@\@ok:	
		lea	2(a3),a3			; get next tile ram location
	endm
		; insert macro 7 times
		DoMapTile
		DoMapTile
		DoMapTile
		DoMapTile
		DoMapTile
		DoMapTile
		DoMapTile
		; now do a modified version for the last column
		moveq	#0,d0
		move.b	(a1)+,d0			; get tile id to draw
		beq.s	@nexttile			; if blank tile, skip

		btst	d4,(a0)				; test current bit
		beq.s	@nexttile			; if 0, branch

		lsl.w	#5,d0				; multiply d0 by 16 (size of an 8x8 tile)
		lea	(a2,d0.w),a4			; get tile gfx start
		movea.l	a3,a5				; copy tile ram start

; draw 5 rows of pixels
	rept 5
		move.l	(a4)+,d0			; get 8 new pixels
		swap	d0				; we only want the first 4		
		move.w	d0,(a5)				; send to ram
		lea	16(a5),a5			; next line
	endr
@nexttile:
		addq.w	#1,d4				; add 1 to bit to check
		and.w	#7,d4							
		bne.s	@ok
		adda.w	#1,a0				; add 1 to byte to check
	@ok:	
		lea	$32(a3),a3			; start of next row ram
		lea	72(a1),a1	
		lea	9(a0),a0		
		dbf	d3,@dorow


	;	move.l	#v_minimap_buffer,d1
	;	move.l	#$DC00,d2
	;	move.l	#$100,d3
	;	jmp	QueueDMATransfer

		move.b	#-1,(v_minimap_update).w	; set vram update flag
		move.w	#$2300,sr
		rts



