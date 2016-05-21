; ---------------------------------------------------------------------------
; Object ?? - sonic high speed trail object
; ---------------------------------------------------------------------------

SonicTrail:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	SonicTrail_Index(pc,d0.w),d1
		jmp	SonicTrail_Index(pc,d1.w)

; ===========================================================================
SonicTrail_Index:
		dc.w SonicTrail_Init-SonicTrail_Index	        ; 0
		dc.w SonicTrail_Main-SonicTrail_Index		; 2
		dc.w SonicTrail_Routine_4-SonicTrail_Index	; 4
; ===========================================================================

SonicTrail_Init:
		addq.b	#2,obRoutine(a0)
		move.b	#$13,obWidth(a0)
		move.b	#9,obHeight(a0)
		move.l	#Map_Sonic,obMap(a0)
		move.w	#$780,obGfx(a0)
		move.w	#$180,obPriority(a0)			; $80 higher than sonic
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)

SonicTrail_Main:	
		btst	#staBoost,(v_player+obStatus2).w	; test boost flag
		beq.s	@rts					; if not, branch

		moveq	#0,d0
		move.w	(v_trackpos).w,d0 ; get index value for tracking data
		move.b	obAnim(a0),d1
		subq.b	#1,d1
		move.b	(v_framebyte).w,d3
		and.b	#3,d3
		cmp.b	d1,d3
		bne.s	@rts
		lsl.b	#2,d1		; multiply animation number by 4
		move.b	d1,d2
		add.b	d1,d1
		add.b	d2,d1		; multiply by 3
		addq.b	#4,d1
		sub.b	d1,d0
		move.b	$30(a0),d1
		sub.b	d1,d0		; use earlier tracking data to create trail
		addq.b	#4,d1
		cmpi.b	#$18,d1
		bcs.s	@a
		moveq	#0,d1

	@a:
		move.b	d1,$30(a0)
		lea	(v_tracksonic).w,a1
		lea	(a1,d0.w),a1
		move.w	(a1)+,obX(a0)
		move.w	(a1)+,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		move.b	(v_player+obRender).w,obRender(a0)		
		move.b	(v_player+obFrame).w,obFrame(a0)		
		jmp	DisplaySprite
; ===========================================================================

@rts:
		rts

; ===========================================================================

SonicTrail_Routine_4:	
		jmp	DeleteObject