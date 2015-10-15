; ---------------------------------------------------------------------------
; Object 0E - Sonic on the title screen
; ---------------------------------------------------------------------------

TitleSonic:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	TSon_Index(pc,d0.w),d1
		jmp	TSon_Index(pc,d1.w)
; ===========================================================================
TSon_Index:	dc.w TSon_Main-TSon_Index
		dc.w TSon_Delay-TSon_Index
		dc.w TSon_Move-TSon_Index
		dc.w TSon_Animate-TSon_Index
; ===========================================================================

TSon_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#$F0,obX(a0)
		move.w	#$DE,obScreenY(a0)
		move.l	#Map_TSon,obMap(a0)
		move.w	#$2300,obGfx(a0)
		move.w	#$80,obPriority(a0)
		move.b	#29,obDelayAni(a0) ; set time delay to 0.5 seconds
		lea	(An_TSon).l,a1
		bsr.w	AnimateSprite

TSon_Delay:	;Routine 2
		subq.b	#1,obDelayAni(a0) ; subtract 1 from time delay
		bpl.s	TSon_Wait	; if time remains, branch
		addq.b	#2,obRoutine(a0) ; go to next routine
		bra.w	DisplaySprite

TSon_Wait:
		rts	
; ===========================================================================

TSon_Move:	; Routine 4
		subq.w	#8,obScreenY(a0)
		cmpi.w	#$96,obScreenY(a0)
		bne.s	TSon_Display
		addq.b	#2,obRoutine(a0)

TSon_Display:
		bra.w	DisplaySprite
; ===========================================================================
		rts	
; ===========================================================================

TSon_Animate:	; Routine 6
		lea	(An_TSon).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================
		rts	