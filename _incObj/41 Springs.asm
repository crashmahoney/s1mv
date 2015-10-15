; ---------------------------------------------------------------------------
; Object 41 - springs
; ---------------------------------------------------------------------------

Springs:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Spring_Index(pc,d0.w),d1
		jsr		Spring_Index(pc,d1.w)
		jsr     FindHomingAttackTarget
        if S3KObjectManager=1
                bra.w   RememberState
        else
		obRange	DeleteObject
                bsr.w	DisplaySprite
	endif
		rts
; ===========================================================================
Spring_Index:	dc.w Spring_Main-Spring_Index
		dc.w Spring_Up-Spring_Index
		dc.w Spring_AniUp-Spring_Index
		dc.w Spring_ResetUp-Spring_Index
		dc.w Spring_LR-Spring_Index
		dc.w Spring_AniLR-Spring_Index
		dc.w Spring_ResetLR-Spring_Index
		dc.w Spring_Dwn-Spring_Index
		dc.w Spring_AniDwn-Spring_Index
		dc.w Spring_ResetDwn-Spring_Index
		dc.w Spring_DiagUp-Spring_Index
		dc.w Spring_AniDiagUp-Spring_Index
		dc.w Spring_ResetDiagUp-Spring_Index
		dc.w Spring_DiagDown-Spring_Index
		dc.w Spring_AniDiagDown-Spring_Index
		dc.w Spring_ResetDiagDown-Spring_Index

spring_pow:	= $30			; power of current spring

; ===========================================================================

Spring_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Spring,obMap(a0)
		move.w	#VRAMloc_HSpring/$20,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.w	#$200,obPriority(a0)
		move.b	obSubtype(a0),d0
	        lsr.w	#3,d0
	        andi.w	#$E,d0
	        move.w	Spring_Init_Subtypes(pc,d0.w),d0
	        jmp	Spring_Init_Subtypes(pc,d0.w)
; ===========================================================================
Spring_Init_Subtypes:
	        dc.w Spring_Init_Up-Spring_Init_Subtypes	        ; 0
	        dc.w Spring_Init_Horizontal-Spring_Init_Subtypes        ; 2
	        dc.w Spring_Init_Down-Spring_Init_Subtypes		; 4
	        dc.w Spring_Init_DiagonallyUp-Spring_Init_Subtypes	; 6
	        dc.w Spring_Init_DiagonallyDown-Spring_Init_Subtypes	; 8
; ===========================================================================
Spring_Init_Horizontal:
		move.b	#8,obRoutine(a0) ; use "Spring_LR" routine
		move.b	#1,obAnim(a0)
		move.b	#3,obFrame(a0)
		move.w	#VRAMloc_VSpring/$20,obGfx(a0)
		move.b	#8,obActWid(a0)
                bra.s   Spring_Init_Common

Spring_Init_Down:
		move.b	#$E,obRoutine(a0) ; use "Spring_Dwn" routine
		bset	#1,obStatus(a0)
                bra.s   Spring_Init_Common

Spring_Init_DiagonallyUp:
		move.b	#$14,obRoutine(a0) ; use "Spring_DiagUp" routine
		move.b	#2,obAnim(a0)
		move.b	#6,obFrame(a0)
		move.w	#VRAMloc_DSpring/$20,obGfx(a0)
                bra.s   Spring_Init_Common

Spring_Init_DiagonallyDown:
		move.b	#$1C,obRoutine(a0) ; use "Spring_DiagDown" routine
		move.b	#2,obAnim(a0)
		move.b	#6,obFrame(a0)
		move.w	#VRAMloc_DSpring/$20,obGfx(a0)
		bset	#1,obStatus(a0)    ; face down

Spring_Init_Up:
Spring_Init_Common:
		move.b	obSubtype(a0),d0
	        andi.w	#2,d0
		btst	#1,d0
		beq.s	loc_DB72
		bset	#5,obGfx(a0)

loc_DB72:
		andi.w	#$F,d0
		move.w	Spring_Powers(pc,d0.w),spring_pow(a0)
		rts	
; --------------------------------------------------------------------------
Spring_Powers:	dc.w -$1000		; power	of red spring
		dc.w -$A00		; power	of yellow spring
; ===========================================================================

Spring_Up:	; Routine 2
		move.w	#$1B,d1
		move.w	#8,d2
		move.w	#$10,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		tst.b	obSolid(a0)	; is Sonic on top of the spring?
		bne.s	Spring_BounceUp	; if yes, branch
		rts	
; ===========================================================================

Spring_BounceUp:
		addq.b	#2,obRoutine(a0)
		addq.w	#8,obY(a1)
		move.w	spring_pow(a0),obVelY(a1) ; move Sonic upwards
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#id_Spring,obAnim(a1) ; use "bouncing" animation
		move.b	#2,obRoutine(a1)
		bclr	#3,obStatus(a0)
        clr.b	ob2ndRout(a0)
		sfx	sfx_Spring	; play spring sound

Spring_AniUp:	; Routine 4
		lea		(Ani_Spring).l,a1
		bra.w	AnimateSprite
; ===========================================================================

Spring_ResetUp:	; Routine 6
		move.b	#1,obNextAni(a0) ; reset animation
		subq.b	#4,obRoutine(a0) ; goto "Spring_Up" routine
		rts	
; ===========================================================================

Spring_LR:	; Routine 8
		move.w	#$13,d1
		move.w	#$E,d2
		move.w	#$F,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		cmpi.b	#2,obRoutine(a0)
		bne.s	loc_DC0C
		move.b	#8,obRoutine(a0)

loc_DC0C:
; 		btst	#5,obStatus(a0)
; 		bne.s	Spring_BounceLR
        cmpi.b  #1,d4             ; side collision
        beq.s   Spring_BounceLR
		rts	
; ===========================================================================

Spring_BounceLR:
		addq.b	#2,obRoutine(a0)
		move.w	spring_pow(a0),obVelX(a1) ; move Sonic to the left
		addq.w	#8,obX(a1)
		btst	#0,obStatus(a0)	; is object flipped?
		bne.s	Spring_Flipped	; if yes, branch
		subi.w	#$10,obX(a1)
		neg.w	obVelX(a1)	; move Sonic to	the right

	Spring_Flipped:
		move.w	#$F,$3E(a1)
		move.w	obVelX(a1),obInertia(a1)
		bchg	#0,obStatus(a1)
		btst	#2,obStatus(a1)
		bne.s	loc_DC56
		move.b	#0,obAnim(a1)	; use running animation

loc_DC56:
		bclr	#5,obStatus(a0)
		bclr	#5,obStatus(a1)
		sfx	sfx_Spring	; play spring sound

Spring_AniLR:	; Routine $A
		lea	(Ani_Spring).l,a1
		bra.w	AnimateSprite
; ===========================================================================

Spring_ResetLR:	; Routine $C
		move.b	#2,obNextAni(a0) ; reset animation
		subq.b	#4,obRoutine(a0) ; goto "Spring_LR" routine
		rts	
; ===========================================================================

Spring_Dwn:	; Routine $E
		move.w	#$1B,d1
		move.w	#8,d2
		move.w	#$10,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		cmpi.b	#2,obRoutine(a0)
		bne.s	loc_DCA4
		move.b	#$E,obRoutine(a0)

loc_DCA4:
		tst.b	ob2ndRout(a0)
		bne.s	locret_DCAE
		tst.w	d4
		bmi.s	Spring_BounceDwn

locret_DCAE:
		rts	
; ===========================================================================

Spring_BounceDwn:			; XREF: Spring_Dwn
		addq.b	#2,obRoutine(a0)
		subq.w	#8,obY(a1)
		move.w	spring_pow(a0),obVelY(a1)
		neg.w	obVelY(a1)	; move Sonic downwards
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#2,obRoutine(a1)
		bclr	#3,obStatus(a0)
		clr.b	ob2ndRout(a0)
		sfx	sfx_Spring	; play spring sound

Spring_AniDwn:	; Routine $10
		lea	(Ani_Spring).l,a1
		bra.w	AnimateSprite
; ===========================================================================

Spring_ResetDwn:
		; Routine $12
		move.b	#1,obNextAni(a0) ; reset animation
		subq.b	#4,obRoutine(a0) ; goto "Spring_Dwn" routine
		rts	

; ===========================================================================

Spring_DiagUp:	; Routine 14
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	#$10,d3
		move.w	obX(a0),d4
		lea		byte_18FAA(pc),a2
		bsr.w	SolidObject;Slope
		tst.b	ob2ndRout(a0)	        ; is Sonic on top of the spring?
		bne.s	Spring_ChkFlipDiagUp	; if yes, branch
        cmpi.b  #1,d4                   ; side collision?
        beq.s   Spring_ChkFlipDiagUp
		rts

; ===========================================================================
Spring_ChkFlipDiagUp:
		btst	#0,obStatus(a0)	; is object flipped?
	        bne.s	loc_18DCA
	        move.w	obX(a0),d0
	        subq.w	#4,d0
	        cmp.w	obX(a1),d0
	        blo.s	Spring_BounceDiagUp
	        rts
; --------------------------------------------------------------------------
loc_18DCA:
	        move.w	obX(a0),d0
	        addq.w	#4,d0
	        cmp.w	obX(a1),d0
	        bhs.s	Spring_BounceDiagUp
	        rts

; ===========================================================================
Spring_BounceDiagUp:
        	addq.b	#2,obRoutine(a0)
		move.w	spring_pow(a0),obVelY(a1) ; move Sonic up
		move.w	spring_pow(a0),obVelX(a1) ; move Sonic to the left
		addq.w	#6,obX(a1)
		addq.w	#6,obY(a1)
		btst	#0,obStatus(a0)	; is object flipped?
		bne.s	@flipped	; if yes, branch
		subi.w	#$C,obX(a1)
		neg.w	obVelX(a1)	; move Sonic to	the right

	@flipped:
		move.w	#$F,$3E(a1)
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#id_Spring,obAnim(a1) ; use "bouncing" animation
		move.b	#2,obRoutine(a1)
		bclr	#3,obStatus(a0)
		bclr	#5,obStatus(a0)
		bclr	#5,obStatus(a1)
        	clr.b	ob2ndRout(a0)
		sfx	sfx_Spring	; play spring sound

Spring_AniDiagUp:	; Routine $A
		lea	(Ani_Spring).l,a1
		bra.w	AnimateSprite
; ===========================================================================

Spring_ResetDiagUp:	; Routine $C
		move.b	#3,obNextAni(a0) ; reset animation
		subq.b	#4,obRoutine(a0) ; goto "Spring_DiagUp" routine
		rts	




; ===========================================================================
Spring_DiagDown:	; Routine 1C
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	#$10,d3
		move.w	obX(a0),d4
		lea		byte_18FC6(pc),a2
		bsr.w	SolidObject;Slope
		cmpi.b	#2,obRoutine(a0)
		bne.s	@routineok
		move.b	#$1C,obRoutine(a0)
@routineok:
		tst.b	ob2ndRout(a0)
		bne.s	@nothittingbottom
		tst.w	d4
		bmi.s	Spring_BounceDiagDown

@nothittingbottom:
                cmpi.b  #1,d4                   ; side collision?
                beq.s   Spring_ChkFlipDiagDown
		rts

; ===========================================================================
Spring_ChkFlipDiagDown:
		btst	#0,obStatus(a0)	; is object flipped?
	        bne.s	@noflip
	        move.w	obX(a0),d0
	        subq.w	#4,d0
	        cmp.w	obX(a1),d0
	        blo.s	Spring_BounceDiagDown
	        rts
; --------------------------------------------------------------------------
@noflip:
	        move.w	obX(a0),d0
	        addq.w	#4,d0
	        cmp.w	obX(a1),d0
	        bhs.s	Spring_BounceDiagDown
	        rts

; ===========================================================================
Spring_BounceDiagDown:
        	addq.b	#2,obRoutine(a0)
		move.w	spring_pow(a0),obVelY(a1)
		neg.w	obVelY(a1)
		move.w	spring_pow(a0),obVelX(a1) ; move Sonic to the left
		addq.w	#6,obX(a1)
		subq.w	#6,obY(a1)
		btst	#0,obStatus(a0)	; is object flipped?
		bne.s	@flipped	; if yes, branch
		subi.w	#$C,obX(a1)
		neg.w	obVelX(a1)	; move Sonic to	the right

	@flipped:
		move.w	#$F,$3E(a1)
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#id_Spring,obAnim(a1) ; use "bouncing" animation
		move.b	#2,obRoutine(a1)
		bclr	#3,obStatus(a0)
		bclr	#5,obStatus(a0)
		bclr	#5,obStatus(a1)
        	clr.b	ob2ndRout(a0)
		sfx	sfx_Spring	; play spring sound

Spring_AniDiagDown:	; Routine $A
		lea	(Ani_Spring).l,a1
		bra.w	AnimateSprite
; ===========================================================================

Spring_ResetDiagDown:	; Routine $C
		move.b	#3,obNextAni(a0) ; reset animation
		subq.b	#4,obRoutine(a0) ; goto "Spring_DiagUp" routine
		rts	
; ===========================================================================
byte_18FAA:
	dc.b $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10, $E, $C, $A,  8
	dc.b   6,  4,  2,  0,$FE,$FC,$FC,$FC,$FC,$FC,$FC,$FC; 16
byte_18FC6:
	dc.b $F4,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F2,$F4,$F6,$F8
	dc.b $FA,$FC,$FE,  0,  2,  4,  4,  4,  4,  4,  4,  4; 16
