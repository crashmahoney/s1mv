; ===========================================================================
; ----------------------------------------------------------------------------
; Object 40 - Pressure spring from CPZ, ARZ, and MCZ (the red "diving board" springboard)
; ----------------------------------------------------------------------------
; Sprite_26370:
Springboard:
	moveq	#0,d0
	move.b	obRoutine(a0),d0
	move.w	Springboard_Index(pc,d0.w),d1
	jsr		Springboard_Index(pc,d1.w)
    
        if S3KObjectManager=1
                bra.w   RememberState
        else
		obRange	DeleteObject
                bsr.w	DisplaySprite
				rts
		endif
; ===========================================================================
; off_26382:
Springboard_Index:	
		dc.w Springboard_Init-Springboard_Index	; 0
		dc.w Springboard_Main-Springboard_Index	; 2
; ---------------------------------------------------------------------------
word_26386:
	dc.w $FC00	; 0
	dc.w $F600	; 1
	dc.w $F800	; 2
; ===========================================================================
; loc_2638C:
Springboard_Init:
	addq.b	#2,obRoutine(a0)
	move.l	#Map_Springboard,obMap(a0)
	move.w	#VRAMloc_Springboard/$20,obGfx(a0)
	ori.b	#4,obRender(a0)
	move.b	#$1C,obActWid(a0)
	move.w	#$200,obPriority(a0)
	bset	#7,obStatus(a0)
	move.b	obSubtype(a0),d0
	andi.w	#2,d0
	move.w	word_26386(pc,d0.w),objoff_30(a0)

Springboard_Main:
	lea		(Ani_Springboard).l,a1
	jsr		AnimateSprite
	lea		SB_TopArray_Up(pc),a2
	tst.b	obFrame(a0)
	beq.s	@next
	lea		SB_TopArray_Down(pc),a2
@next:
	lea		(v_player).w,a1 ; a1=character
	move.w	#$27,d1
	move.w	#$8,d2
	move.w	#$8,d3
	move.w	obX(a0),d4
	bsr.w	SolidObjectSlope
	tst.b	obSolid(a0)		; is Sonic on top of the spring?
	bne.s	Springboard_ChkFlip		; if Yes, branch
	rts

; ===========================================================================
Springboard_ChkFlip:
	btst	#0,obStatus(a0)					; is board facing right
	bne.s	loc_26436						; if not branch
	move.w	obX(a0),d0
	subi.w	#$10,d0
	cmp.w	obX(a1),d0
	blo.s	Springboard_SetAnim
	rts
; ===========================================================================

loc_26436:
	move.w	obX(a0),d0
	addi.w	#$10,d0
	cmp.w	obX(a1),d0
	bhs.s	Springboard_SetAnim
	rts
; ===========================================================================

Springboard_SetAnim:
	cmpi.b	#1,obAnim(a0)
	beq.s	Springboard_ChkFrame
	move.w	#$100,obAnim(a0)					; set anim to 1, nextani to 0
	rts
; ===========================================================================

Springboard_ChkFrame:
	tst.b	obFrame(a0)
	beq.s	Springboard_Bounce
	rts
; ===========================================================================

Springboard_Bounce:
	move.w	obX(a0),d0
	subi.w	#$1C,d0
	sub.w	obX(a1),d0
	neg.w	d0
	btst	#0,obStatus(a0)
	beq.s	loc_2647A
	not.w	d0
	addi.w	#$27,d0

loc_2647A:
	tst.w	d0
	bpl.s	loc_26480
	moveq	#0,d0

loc_26480:
	lea		(SB_BounceHeight_Array).l,a3
	move.b	(a3,d0.w),d0
	move.w	#-$400,obVelY(a1)
	sub.b	d0,obVelY(a1)
	bset	#0,obStatus(a1)
	btst	#0,obStatus(a0)
	bne.s	loc_264AA
	bclr	#0,obStatus(a1)
	neg.b	d0

loc_264AA:
	move.w	obVelX(a1),d1
	bpl.s	@skip
	neg.w	d1
   @skip:
	cmpi.w	#$400,d1
	blo.s	loc_264BC
	sub.b	d0,obVelX(a1)

loc_264BC:
	bset	#1,obStatus(a1)
	bclr	#3,obStatus(a1)
	move.b	#id_Spring,obAnim(a1)				; sonic bounce animation
	move.b	#2,obRoutine(a1)
	bclr	#staSpinDash,obStatus2(a0)			; clear Spin Dash flag
	move.b	obSubtype(a0),d0
	btst	#0,d0
	beq.s	loc_2651E
	move.w	#1,obInertia(a1)
	move.b	#1,flip_angle(a1)
	move.b	#id_Walk,obAnim(a1)
	move.b	#1,flips_remaining(a1)
	move.b	#8,flip_speed(a1)
	btst	#1,d0
	bne.s	loc_2650E
	move.b	#3,flips_remaining(a1)

loc_2650E:
	btst	#0,obStatus(a1)
	beq.s	loc_2651E
	neg.b	flip_angle(a1)
	neg.w	obInertia(a1)

loc_2651E:
	andi.b	#$C,d0
	cmpi.b	#4,d0
	bne.s	loc_26534
;	move.b	#$C,layer(a1)
;	move.b	#$D,layer_plus(a1)
	move.b	#$00,(v_layer).w

loc_26534:
	cmpi.b	#8,d0
	bne.s	loc_26546
;	move.b	#$E,layer(a1)
;	move.b	#$F,layer_plus(a1)
	move.b	#$01,(v_layer).w

loc_26546:
		sfx	sfx_Spring, 1	; play spring sound
; ===========================================================================
SB_BounceHeight_Array:
	dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	dc.b   0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  1,  1,  1; 16
	dc.b   1,  1,  1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2,  2,  2; 32
	dc.b   3,  3,  3,  3,  3,  3,  4,  4,  0,  0,  0,  0,  0,  0,  0,  0; 48
	dc.b   0,  0,  0,  0,  0,  0,  0,  0; 64
SB_TopArray_Up:
	dc.b   8,  8,  8,  8,  8,  8,  8,  9, $A, $B, $C, $D, $E, $F,$10,$10
	dc.b $11,$12,$13,$14,$14,$15,$15,$16,$17,$18,$18,$18,$18,$18,$18,$18; 16
	dc.b $18,$18,$18,$18,$18,$18,$18,$18; 32
SB_TopArray_Down:
	dc.b   8,  8,  8,  8,  8,  8,  8,  9, $A, $B, $C, $C, $C, $C, $D, $D
	dc.b  $D, $D, $D, $D, $E, $E, $F, $F,$10,$10,$10,$10, $F, $F, $E, $E; 16
	dc.b  $D, $D, $D, $D, $D, $D, $D, $D; 32
	even
; ===========================================================================
; animation script
Ani_Springboard:		dc.w @stopped-Ani_Springboard	; 0
				dc.w @springing-Ani_Springboard	; 1

@stopped:	dc.b  $F,	0,	$FF
@springing:	dc.b   3,	1,	0,	$FD,	0
	even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
	include "_maps\Springboard.asm"
; ===========================================================================
