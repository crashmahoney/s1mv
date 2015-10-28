; ---------------------------------------------------------------------------
; Obj97 - Distant Island Object (GHZ)
; ---------------------------------------------------------------------------

Island:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Isle_Index(pc,d0.w),d1
		jmp		Isle_Index(pc,d1.w)
; ===========================================================================
Isle_Index:		dc.w Isle_Main-Isle_Index
				dc.w Isle_Display-Isle_Index
; ===========================================================================

Isle_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Island,obMap(a0)
		move.w	#$4000+(VRAMloc_Island/$20),obGfx(a0)
		move.b	#$10,obActWid(a0)
		move.w	#$380,obPriority(a0)

Isle_Display:	; Routine 2
        moveq   #0,d1
		move.l	(v_screenposx).w,d1
		asr.l	#3,d1                         ; divide by $28 (40)
		move.l	d1,d0                         ;        ""
		asr.l	#3,d1                         ;        ""
		add.l	d0,d1                         ;        ""
		neg.l	d1
		sub.l	#$00B00000,d1
		move.l	d1,obX(a0)

		move.w	(v_bgposy_dup).w,d1
		neg.w 	d1
		add.w	#246,d1
		move.w	d1,obScreenY(a0)
		jmp		DisplaySprite


; ===========================================================================
@dontshow:		
		rts


		include	"_maps\Island.asm"
		even