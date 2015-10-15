; ---------------------------------------------------------------------------
; Object 12 - lamp (SYZ)
; ---------------------------------------------------------------------------

Torch:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Torch_Index(pc,d0.w),d1
		jmp		Torch_Index(pc,d1.w)
; ===========================================================================
Torch_Index:	dc.w Torch_Main-Torch_Index
				dc.w Torch_Animate-Torch_Index
; ===========================================================================

Torch_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Torch,obMap(a0)
		move.w	#$7580/$20,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$8,obActWid(a0)
		move.w	#$300,obPriority(a0)
	@randomize:	
		jsr	    RandomNumber
		and.w   #$7,d0
;		beq.s   @randomize				; if 0 try again
		move.b  d0,obFrame(a0)			; start on random frame number

Torch_Animate:	; Routine 2
		subq.b	#1,obTimeFrame(a0)
		bpl.s	@chkdel
		move.b	#3,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#8,obFrame(a0)
		bcs.s	@chkdel
		move.b	#0,obFrame(a0)

	@chkdel:
        if S3KObjectManager=1
		bra.w	RememberState
        else
		obRange	DeleteObject
		bra.w	DisplaySprite
        endif
; ===========================================================================

	include		"_maps\Torch.asm"