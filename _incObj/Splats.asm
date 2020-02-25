; ---------------------------------------------------------------------------
; Object 9A - Splats enemy (GHZ)
; ---------------------------------------------------------------------------
splats_y_floor	= $36			; y pos of floor under splats
splats_jump_height = $3A		; how high to jump

Splats:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Splats_Index(pc,d0.w),d1
		jmp		Splats_Index(pc,d1.w)
; ===========================================================================
Splats_Index:	dc.w Splats_Main-Splats_Index
		dc.w Splats_Action-Splats_Index
		dc.w Splats_Animate-Splats_Index
		dc.w Splats_Delete-Splats_Index
; ===========================================================================

Splats_Main:	; Routine 0
		move.l	#Map_Splats,obMap(a0)
		move.w	#$2000+(VRAMloc_Splats/$20),obGfx(a0)
		move.b	#5,obRender(a0)
		move.w	#$200,obPriority(a0)
		move.b	#$14,obActWid(a0)
		move.b	#$E,obWidth(a0)
		move.b	#8,obHeight(a0)
		move.b	#$C,obColType(a0)
		jsr		ObjectFall
		jsr		ObjFloorDist
		tst.w	d1
		bpl.s	@notonfloor
		add.w	d1,obY(a0)	; match	object's position with the floor
		move.w	obY(a0),splats_y_floor(a0)
		move.w	#0,obVelY(a0)
		addq.b	#2,obRoutine(a0) ; goto Splats_Action next
		bchg	#0,obStatus(a0)

	@notonfloor:
		rts	

; ===========================================================================

Splats_Action:	; Routine 2
		jsr     FindHomingAttackTarget
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Splats_ActIndex(pc,d0.w),d1
		jsr		Splats_ActIndex(pc,d1.w)

		move.w	obVelY(a0),d0
		addi.w	#$38,obVelY(a0) ; apply gravity
		ext.l	d0
		lsl.l	#8,d0
		add.l	obY(a0),d0
		move.l	d0,obY(a0)
		cmp.l	splats_y_floor(a0),d0		; is obY higher than the floor?
		blt.s	@setframe					; if so, branch
		move.l	splats_y_floor(a0),obY(a0)
		move.w	splats_jump_height(a0),obVelY(a0)
	@setframe:
		move.b	#0,obFrame(a0)
		tst.w	obVelY(a0)
		beq.s	@nochange
		bpl.s	@frame1
		add.b	#1,obFrame(a0)
	@frame1:
		add.b	#1,obFrame(a0)
	@nochange:	
		jmp		RememberState

; ===========================================================================
Splats_ActIndex:	dc.w @move-Splats_ActIndex
					dc.w @findfloor-Splats_ActIndex

@time:		= $30
@smokedelay:	= $33

; ===========================================================================

@move:
		subq.w	#1,@time(a0)		; subtract 1 from pause	time
		bpl.s	@wait				; if time remains, branch
		addq.b	#2,ob2ndRout(a0)
		move.w	#-$B0,obVelX(a0) 	; move object to the left
		move.w	#-1300,splats_jump_height(a0)	; allow to jump
		bchg	#0,obStatus(a0)
		bne.s	@wait
		neg.w	obVelX(a0)			; change direction
	@wait:
		rts	
; ===========================================================================

@findfloor:
		move.w	obVelX(a0),d0
		ext.l	d0
		lsl.l	#8,d0
		add.l	d0,obX(a0)

		move.w	obX(a0),d3
		add.w	#16,d3					; check 16px to the right of centre
		btst	#0,obStatus(a0)			; check direction
		bne.s	@ok						; branch if facing right
		sub.w	#32,d3					; check 16px to the left of centre
	@ok:
		move.w	splats_y_floor(a0),d2
		jsr		ObjFloorDist3
		cmpi.w	#-8,d1
		blt.s	@pause
		cmpi.w	#$C,d1
		bge.s	@pause

		add.w	d1,splats_y_floor(a0)	; match	object's position with the floor
		rts	

@pause:
		subq.b	#2,ob2ndRout(a0)
		move.w	#119,@time(a0)	; set pause time to 2 seconds
		move.w	#0,obVelX(a0)	; stop the object moving
		move.w	#0,splats_jump_height(a0)	; stop jumping
		rts	
; ===========================================================================

Splats_Animate:	; Routine 4
		bclr	#0,obRender
		btst	#0,obStatus
		bne.s	@noflip
		bset	#0,obRender
	@noflip:
		jsr		DisplaySprite
; ===========================================================================

Splats_Delete:	; Routine 6
		jsr		DeleteObject

; ===========================================================================		
		include	"_maps\Splats.asm" ; Splats_Action terminates in this file
