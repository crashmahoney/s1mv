; ---------------------------------------------------------------------------
; Object 10 - blank
; ---------------------------------------------------------------------------

HomingTarget:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Homing_Index(pc,d0.w),d1
		jmp	Homing_Index(pc,d1.w)
; ===========================================================================
Homing_Index:	dc.w Homing_Main-Homing_Index
		dc.w Homing_NoTarget-Homing_Index
		dc.w Homing_Animate-Homing_Index
		dc.w Homing_Display-Homing_Index
; ===========================================================================

Homing_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#$00,obX(a0)
		move.w	#$00,obY(a0)
		move.l	#Map_HomingTarget,obMap(a0)
		move.w	#$6F6,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#0,obPriority(a0)
; --------------------------------------------------------------------------
Homing_Notarget:; Routine 2
                tst.w   obX(a0)         ; does homing attack have a target?
		bne.s	@gottarget	; if so, branch
		rts
@gottarget:
		addq.b	#2,obRoutine(a0)
; ===========================================================================
Homing_Animate: ; Routine 4
;		sfx	$5B
                clr.b   obAnim(a0)      ; go to starting animation
;                sfx     sfx_switch
		addq.b	#2,obRoutine(a0)
; ===========================================================================
Homing_Display: ; Routine 6

		cmpi.b   #aHoming,(v_a_ability).w
                beq.s    @equipped
		cmpi.b   #aHoming,(v_b_ability).w
                beq.s    @equipped
		cmpi.b   #aHoming,(v_c_ability).w
                beq.s    @equipped
                bra.s    @notarget      ; homing attack not equipped, don't display
        @equipped:
                tst.w   obX(a0)         ; does homing attack have a target?
		beq.s	@notarget	; if not, branch
		move.b  $29(a0),d0
                cmp.b   $30(a0),d0      ; has target changed?
                beq.s   @nochange
		subq.b	#2,obRoutine(a0); go back to animation routine
        @nochange:
                move.b  d0, $30(a0)     ; remember which object is being targeted
                move.w  #0, obX(a0)     ; reset target
                move.w  #0, obY(a0)
		lea	(Ani_Homing).l,a1
		jsr	AnimateSprite
		jmp	DisplaySprite
; --------------------------------------------------------------------------
@notarget:
                clr.b   $29(a0)         ; clear both current and previous targets
                clr.b   $30(a0)
		subq.b	#4,obRoutine(a0)
		rts
