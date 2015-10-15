; ---------------------------------------------------------------------------
; Object 4B - giant ring for entry to special stage
; ---------------------------------------------------------------------------
GiantRing:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	GRing_Index(pc,d0.w),d1
		jmp	GRing_Index(pc,d1.w)
; ===========================================================================
GRing_Index:	dc.w GRing_Main-GRing_Index
		dc.w GRing_Animate-GRing_Index
		dc.w GRing_Collect-GRing_Index
		dc.w GRing_Delete-GRing_Index
; ===========================================================================

GRing_Main:	; Routine 0
                moveq   #0,d0
		move.b	obSubtype(a0),d0
		move.b	(v_actflags).w,d1
		btst	d0,d1
		beq.s	@notcollected		; only make the ring if it hasn't already been collected
		bra.w	GRing_Delete
       @notcollected:
		move.l	#Map_GRing,obMap(a0)
		move.w	#$2580,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$40,obActWid(a0)
		tst.b	obRender(a0)
		bpl.s	GRing_Animate
		cmpi.b	#6,(v_emeralds).w ; do you have 6 emeralds?
		beq.w	GRing_Delete	; if yes, branch
; 		cmpi.w	#00,(v_rings).w	; do you have at least 50 rings?
; 		bcc.s	GRing_Okay	; if yes, branch
; 		rts	
; ===========================================================================

GRing_Okay:
		addq.b	#2,obRoutine(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$52,obColType(a0)
		move.w	#$C40,(v_gfxbigring).w
;		moveq	#plcid_Warp,d0
;		jsr	(AddPLC).l	; load big ring flash patterns

GRing_Animate:	; Routine 2
		move.b	(v_ani1_frame).w,obFrame(a0)
		obRange	GRing_DeleteRange
		bra.w	DisplaySprite
; ===========================================================================

GRing_Collect:	; Routine 4
		subq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		bsr.w	FindFreeObj
		bne.w	GRing_PlaySnd
		move.b	#id_RingFlash,0(a1) ; load giant ring flash object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	a0,$3C(a1)
		move.w	(v_player+obX).w,d0
		cmp.w	obX(a0),d0	; has Sonic come from the left?
		bcs.s	GRing_PlaySnd	; if yes, branch
		bset	#0,obRender(a1)	; reverse flash	object

GRing_PlaySnd:
		sfx	sfx_GiantRing	; play giant ring sound
                moveq   #0,d0
		move.b	obSubtype(a0),d0
		move.b	(v_actflags).w,d1
		bset	d0,d1
		move.b	d1,(v_actflags).w	; Set the special stage ring as collected
                writeVRAM Art_BigRingFlash, $0D20, $B000
;		bra.s	GRing_Animate
; ===========================================================================

GRing_Delete:	; Routine 6
        if S3KObjectManager=1
                obMarkGone
        endif
		bra.w	DeleteObject

; ===========================================================================
GRing_DeleteRange:
        ; reload graphics replaced by ring when ring goes out of range
		moveq	#plcid_Explode,d0
		jsr	(AddPLC).l	; load explosion patterns
		jsr	(LoadAnimalPLC).l ; load animal patterns
		bra.s	GRing_Delete
