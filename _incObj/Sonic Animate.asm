; ---------------------------------------------------------------------------
; Subroutine to	animate	Sonic's sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Animate:				; XREF: Obj01_Control; et al
		lea		(Ani_Sonic).l,a1   ; load normal animation set
        tst.b   (f_supersonic).w   ; has sonic gone super?
        beq.s   @notsuper          ; if not, branch
		lea		(Ani_SuperSonic).l,a1   ; load super sonic animation set
    @notsuper:
		moveq	#0,d0
		move.b	obAnim(a0),d0
		cmp.b	obNextAni(a0),d0 ; is animation set to restart?
		beq.s	@do		; if not, branch
		move.b	d0,obNextAni(a0) ; set to "no restart"
		move.b	#0,obAniFrame(a0) ; reset animation
		move.b	#0,obTimeFrame(a0) ; reset frame duration

	@do:
		add.w	d0,d0
		adda.w	(a1,d0.w),a1	; jump to appropriate animation	script
		move.b	(a1),d0
		bmi.s	@walkrunroll	; if animation is walk/run/roll/jump, branch
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		subq.b	#1,obTimeFrame(a0) ; subtract 1 from frame duration
		bpl.s	@delay		; if time remains, branch
		move.b	d0,obTimeFrame(a0) ; load frame duration

@loadframe:
		moveq	#0,d1
		move.b	obAniFrame(a0),d1 ; load current frame number
		move.b	1(a1,d1.w),d0	; read sprite number from script
;		bmi.s	@end_FF		; if animation is complete, branch
                cmpi.b	#$F0,d0		; +++ changed to increase animation frames allowed
		bcc.s	@end_FF	        ; +++ if animation is complete, branch

	@next:
		move.b	d0,obFrame(a0)	; load sprite number
		addq.b	#1,obAniFrame(a0) ; next frame number

	@delay:
		rts	
; ===========================================================================

@end_FF:
		addq.b	#1,d0		; is the end flag = $FF	?
		bne.s	@end_FE		; if not, branch
		move.b	#0,obAniFrame(a0) ; restart the animation
		move.b	1(a1),d0	; read sprite number
		bra.s	@next
; ===========================================================================

@end_FE:
		addq.b	#1,d0		; is the end flag = $FE	?
		bne.s	@end_FD		; if not, branch
		move.b	2(a1,d1.w),d0	; read the next	byte in	the script
		sub.b	d0,obAniFrame(a0) ; jump back d0 bytes in the script
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0	; read sprite number
		bra.s	@next
; ===========================================================================

@end_FD:
		addq.b	#1,d0		; is the end flag = $FD	?
		bne.s	@end		; if not, branch
		move.b	2(a1,d1.w),obAnim(a0) ; read next byte, run that animation

	@end:
		rts	
; ===========================================================================

@walkrunroll:
		subq.b	#1,obTimeFrame(a0) ; subtract 1 from frame duration
		bpl.s	@delay		; if time remains, branch
		tst.b	flip_angle(a0)		; is sonic tumbling?
		bne.w	SAnim_Tumble		; if so, branch
		addq.b	#1,d0		; is the start flag = $FF ?
		bne.w	@rolljump	; if not, branch
		moveq	#0,d1
		move.b	obAngle(a0),d0	; get Sonic's angle
		move.b	obStatus(a0),d2
		andi.b	#1,d2		; is Sonic mirrored horizontally?
		bne.s	@flip		; if yes, branch
		not.b	d0		; reverse angle

	@flip:
		addi.b	#$10,d0		; add $10 to angle
		bpl.s	@noinvert	; if angle is $0-$7F, branch
		moveq	#3,d1

	@noinvert:
		andi.b	#$FC,obRender(a0)
		eor.b	d1,d2
		or.b	d2,obRender(a0)
		btst	#5,obStatus(a0)	; is Sonic pushing something?
		bne.w	@push		; if yes, branch

		lsr.b	#4,d0		; divide angle by $10
		andi.b	#6,d0		; angle	must be	0, 2, 4	or 6
		move.w	obInertia(a0),d2 ; get Sonic's speed
		bpl.s	@nomodspeed
		neg.w	d2		; modulus speed

	@nomodspeed:
		tst.b   (v_homingtimer).w ; currently light dashing?
                bne.s   @animatelightdash     ; if so, branch

                tst.b   (f_supersonic).w   ; has sonic gone super?
                bne.s   @animatesuper      ; if so, branch
; ===========================================================================
; Sonic normal amimations
		lea	(SonAni_Dash).l,a1 ; use Dashing animation
		cmpi.w	#$A00,d2	; is Sonic at Dashing speed?
		bcc.s	@running	; if yes, branch

		lea	(SonAni_Run).l,a1 ; use	running	animation
		cmpi.w	#$600,d2	; is Sonic at running speed?
		bcc.s	@running	; if yes, branch

		lea	(SonAni_Walk).l,a1 ; use walking animation
		move.b	d0,d1
		lsr.b	#1,d1
		add.b	d1,d0

	@running:
		add.b	d0,d0
		move.b	d0,d3
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	@belowmax
		moveq	#0,d2		; max animation speed

	@belowmax:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0) ; modify frame duration
		bsr.w	@loadframe
		add.b	d3,obFrame(a0)	; modify frame number
	@rts:
		rts	
; ===========================================================================
; Super Sonic animations
@animatesuper:
		lea	(SonAni_SupRun).l,a1 ; use running animation
		cmpi.w	#$800,d2	; is Sonic below running speed?
		bcs.s	@superwalk	; if yes, branch
	        lsr.b	#1,d0
                bra.s   @superrunning
        @superwalk:
		lea	(SonAni_SupWalk).l,a1 ; use walking animation
		add.b	d0,d0
		add.b	d0,d0

	@superrunning:
		move.b	d0,d3
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	@belowmax
		moveq	#0,d2		; max animation speed
                bra.s   @belowmax       ;
; ===========================================================================
; light dash animations
@animatelightdash:
		lea	(SonAni_SupRun).l,a1 ; use super sonic running animation
	        lsr.b	#1,d0
		move.b	d0,d3
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	@belowmax
		moveq	#0,d2		; max animation speed
                bra.s   @belowmax       ;
; ===========================================================================

@rolljump:
		addq.b	#1,d0		; is animation rolling/jumping?
		bne.s	@push		; if not, branch
		move.w	obInertia(a0),d2 ; get Sonic's speed
		bpl.s	@nomodspeed2
		neg.w	d2

	@nomodspeed2:
		lea	(SonAni_Roll2).l,a1 ; use fast animation
		cmpi.w	#$600,d2	; is Sonic moving fast?
		bcc.s	@rollfast	; if yes, branch
		lea	(SonAni_Roll).l,a1 ; use slower	animation

	@rollfast:
		neg.w	d2
		addi.w	#$400,d2
		bpl.s	@belowmax2
		moveq	#0,d2

	@belowmax2:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0) ; modify frame duration
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	@loadframe
; ===========================================================================

@push:
		move.w	obInertia(a0),d2 ; get Sonic's speed
		bmi.s	@negspeed
		neg.w	d2

	@negspeed:
		addi.w	#$800,d2
		bpl.s	@belowmax3	
		moveq	#0,d2

	@belowmax3:
		lsr.w	#6,d2
		move.b	d2,obTimeFrame(a0) ; modify frame duration
		lea		(SonAni_Push).l,a1
        tst.b   (f_supersonic).w   ; has sonic gone super?
        beq.s   @notsuperpush          ; if not, branch
		lea		(SonAni_SupPush).l,a1   ; load super sonic animation
    @notsuperpush:
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	@loadframe


; ===========================================================================
; loc_1B520:
SAnim_Tumble:
	move.b	flip_angle(a0),d0
	moveq	#0,d1
	move.b	obStatus(a0),d2
	andi.b	#1,d2
	bne.s	SAnim_Tumble_Left

	andi.b	#$FC,obRender(a0)			; remove flipped flags
	addi.b	#$B,d0
	bra.s	loc_1B572
; ===========================================================================
; loc_1B54E:
SAnim_Tumble_Left:
	andi.b	#$FC,obRender(a0)			; remove flipped flags
	tst.b	flip_turned(a0)
	beq.s	loc_1B566
	ori.b	#1,obRender(a0)				; set horiz flipped flag
	addi.b	#$B,d0
	bra.s	loc_1B572
; ===========================================================================

loc_1B566:
	ori.b	#3,obRender(a0)				; set horiz and vert flipped flags
	neg.b	d0
	addi.b	#$8F,d0

loc_1B572:
	divu.w	#$16,d0
	addi.b	#fr_Flip1,d0
	move.b	d0,obFrame(a0)
	move.b	#0,obTimeFrame(a0)
	rts
; End of function Sonic_Animate
