; ---------------------------------------------------------------------------
; Object 44 - edge walls (GHZ)
; ---------------------------------------------------------------------------

EdgeWalls:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Edge_Index(pc,d0.w),d1
		jmp		Edge_Index(pc,d1.w)
; ===========================================================================
Edge_Index:	dc.w Edge_Main-Edge_Index
		dc.w Edge_Solid-Edge_Index
		dc.w Edge_Display-Edge_Index
; ===========================================================================

Edge_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Edge,obMap(a0)
		move.w	#$C000,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#8,obActWid(a0)
		moveq   #0,d0
		move.b	obSubtype(a0),d0  ; get subtype
		bclr	#4,d0	          ; clear 4th bit (deduct $10)
		add.w   d0,d0
		lea		Edgewall_Priority,a2
		adda.l	d0,a2				
		move.w	(a2),obPriority(a0)
		move.b	obSubtype(a0),obFrame(a0) ; copy object type number to frame number
		bclr	#4,obFrame(a0)	          ; clear 4th bit (deduct $10)
		beq.s	Edge_Solid	          ; make object solid if 4th bit = 0
		addq.b	#2,obRoutine(a0)
		bra.s	Edge_Display	          ; don't make it solid if 4th bit = 1
; ===========================================================================

Edge_Solid:	; Routine 2
		move.w	#$13,d1
		move.w	#$28,d2
		bsr.w	Obj44_SolidWall

Edge_Display:	; Routine 4
        if S3KObjectManager=1
                bra.w   RememberState
        else
                bsr.w	DisplaySprite
		obRange	DeleteObject
	endif
		rts

Edgewall_Priority:
		dc.w	$300, $300, $300, $300, $300, $300, $300			; walls priority
		dc.w    $80, $80, $80, $80, $80, $80, $80, $80, $80			; leaves priority







