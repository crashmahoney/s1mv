; ---------------------------------------------------------------------------
; Subroutine to	make Sonic walk/run
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Move:				; XREF: Obj01_MdNormal
                move.w	(v_sonspeedmax).w,d6
		move.w	(v_sonspeedacc).w,d5
		move.w	(v_sonspeeddec).w,d4
		tst.b	(f_jumponly).w
		bne.w	loc_12FEE
		tst.w	$3E(a0)
		bne.w	Sonic_ResetScr
		btst	#bitL,(v_jpadhold2).w ; is left being pressed?
		beq.s	@notleft	; if not, branch
		bsr.w	Sonic_MoveLeft

	@notleft:
		btst	#bitR,(v_jpadhold2).w ; is right being pressed?
		beq.s	@notright	; if not, branch
		bsr.w	Sonic_MoveRight

	@notright:
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0		; is Sonic on a	slope?
		bne.w	Sonic_ResetScr	; if yes, branch
		tst.w	obInertia(a0)	; is Sonic moving?
		bne.w	Sonic_ResetScr	; if yes, branch
		bclr	#5,obStatus(a0)
		move.b	#id_Wait,obAnim(a0) ; use "standing" animation
		btst	#3,obStatus(a0)
		beq.w	Sonic_Balance
		moveq	#0,d0
		move.b	$3D(a0),d0
		lsl.w	#6,d0
		lea	(v_objspace).w,a1
		lea	(a1,d0.w),a1
		tst.b	obStatus(a1)
		bmi.w	Sonic_LookUp
		moveq	#0,d1
		move.b	obActWid(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#2,d2
		add.w	obX(a0),d1
		sub.w	obX(a1),d1
	        tst.b	(f_supersonic).w
	        bne.w	SuperSonic_Balance
		cmpi.w	#2,d1
		blt.s	Sonic_BalanceOnObjLeft
		cmp.w	d2,d1
		bge.s	Sonic_BalanceOnObjRight
		bra.w	Sonic_LookUp
; ---------------------------------------------------------------------------
SuperSonic_Balance:
	        cmpi.w	#2,d1
	        blt.w	SuperSonic_BalanceOnObjLeft
	        cmp.w	d2,d1
	        bge.w	SuperSonic_BalanceOnObjRight
	        bra.w	Sonic_Lookup
; ---------------------------------------------------------------------------
; balancing checks for when you're on the right edge of an object
Sonic_BalanceOnObjRight:
		btst	#staFacing,obStatus(a0)	      ; is Sonic facing left?	;Mercury Constants
		bne.s	@backwards	              ; if so, balance backward
		move.b	#id_BalanceForward,obAnim(a0) ; use forward balancing animation
	        addq.w	#6,d2
	        cmp.w	d2,d1
	        blt.w	Sonic_ResetScr
	        move.b	#id_BalanceFar,obAnim(a0)
         	bra.w	Sonic_ResetScr
	; on right edge but facing left:
	@backwards:
		move.b	#id_BalanceBack,obAnim(a0) ; use backward balancing animation
	        addq.w	#6,d2
	        cmp.w	d2,d1
	        blt.w	Sonic_ResetScr
	        move.b	#id_BalanceFar,obAnim(a0)
	        bclr	#staFacing,obStatus(a0)
         	bra.w	Sonic_ResetScr
; ---------------------------------------------------------------------------
; balancing checks for when you're on the left edge of an object
; loc_1A44E:
Sonic_BalanceOnObjLeft:
		btst	#staFacing,obStatus(a0)	      ; is Sonic facing right?	;Mercury Constants
		beq.s	@backwards	              ; if so, balance backward
		move.b	#id_BalanceForward,obAnim(a0) ; use forward balancing animation
        	cmpi.w	#-4,d1
         	bge.w	Sonic_ResetScr
	        move.b	#id_BalanceFar,obAnim(a0)
         	bra.w	Sonic_ResetScr
	; on left edge of object but facing right:
	@backwards:
		move.b	#id_BalanceBack,obAnim(a0) ; use backward balancing animation
	        cmpi.w	#-4,d1
	        bge.w	Sonic_ResetScr
	        move.b	#id_BalanceFar,obAnim(a0)
	        bset	#staFacing,obStatus(a0)
         	bra.w	Sonic_ResetScr
; ---------------------------------------------------------------------------
; balancing checks for when you're on the edge of part of the level
Sonic_Balance:
		jsr	ObjFloorDist
		cmpi.w	#$C,d1
		blt.w	Sonic_LookUp
	        tst.b	(f_supersonic).w
	        bne.w	SuperSonic_Balance2
		cmpi.b	#3,obFrontAngle(a0)	;Mercury Constants
		bne.s	Sonic_BalanceLeft
Sonic_BalanceRight:
		btst	#staFacing,obStatus(a0)	      ; is Sonic facing left?	;Mercury Constants
		bne.s	@backwards	              ; if so, balance backward
		move.b	#id_BalanceForward,obAnim(a0) ; use forward balancing animation
	        move.w	obX(a0),d3
	        subq.w	#6,d3
	        jsr	ObjFloorDist2
	        cmpi.w	#$C,d1
	        blt.w	Sonic_ResetScr
	        move.b	#id_BalanceFar,obAnim(a0)
		bra.w	Sonic_ResetScr	; branch
	; on right edge but facing left:
	@backwards:
		move.b	#id_BalanceBack,obAnim(a0) ; use backward balancing animation
	        move.w	obX(a0),d3
	        subq.w	#6,d3
	        jsr	ObjFloorDist2
	        cmpi.w	#$C,d1
	        blt.w	Sonic_ResetScr
	        move.b	#id_BalanceFar,obAnim(a0)
	        bclr	#staFacing,obStatus(a0)
		bra.w	Sonic_ResetScr	; branch
; --------------------------------------------------------------------------
Sonic_BalanceLeft:
		cmpi.b	#3,obRearAngle(a0)	;Mercury Constants
		bne.s	Sonic_LookUp
		btst	#staFacing,obStatus(a0)	; is Sonic facing left?	;Mercury Constants
		beq.s	@backwards        	; if not, balance backward
		move.b	#id_BalanceForward,obAnim(a0) ; use forward balancing animation
	        move.w	obX(a0),d3
	        addq.w	#6,d3
	        jsr	ObjFloorDist2
	        cmpi.w	#$C,d1
	        blt.w	Sonic_ResetScr
	        move.b	#id_BalanceFar,obAnim(a0)
		bra.w	Sonic_ResetScr	; branch
	; on left edge but facing right:
	@backwards:
		move.b	#id_BalanceBack,obAnim(a0) ; use backward balancing animation
	        move.w	obX(a0),d3
	        addq.w	#6,d3
	        jsr	ObjFloorDist2
	        cmpi.w	#$C,d1
	        blt.w	Sonic_ResetScr
	        move.b	#id_BalanceFar,obAnim(a0)
	        bset	#staFacing,obStatus(a0)
		bra.w	Sonic_ResetScr	; branch
; ---------------------------------------------------------------------------
SuperSonic_Balance2:
	        cmpi.b	#3,obFrontAngle(a0)
	        bne.s	loc_1A56E

SuperSonic_BalanceOnObjRight:
	        bclr	#staFacing,obStatus(a0)
	        bra.s	loc_1A57C
; ---------------------------------------------------------------------------
loc_1A56E:
	        cmpi.b	#3,obRearAngle(a0)
	        bne.s	Sonic_Lookup

SuperSonic_BalanceOnObjLeft:
	        bset	#staFacing,obStatus(a0)

loc_1A57C:
	        move.b	#id_BalanceForward,obAnim(a0)
	        bra.s	Sonic_ResetScr
; ---------------------------------------------------------------------------; ===========================================================================

; Sonic_LookUp:
; 		btst	#bitUp,(v_jpadhold2).w ; is up being pressed?
; 		beq.s	Sonic_Duck	; if not, branch
; 		move.b	#id_LookUp,obAnim(a0) ; use "looking up" animation
; 		cmpi.w	#$C8,(v_lookshift).w
; 		beq.s	loc_12FC2
; 		addq.w	#2,(v_lookshift).w
; 		bra.s	loc_12FC2
; ; ===========================================================================
; 
; Sonic_Duck:
; 		btst	#bitDn,(v_jpadhold2).w ; is down being pressed?
; 		beq.s	Sonic_ResetScr	; if not, branch
; 		move.b	#id_Duck,obAnim(a0) ; use "ducking" animation
; 		cmpi.w	#8,(v_lookshift).w
; 		beq.s	loc_12FC2
; 		subq.w	#2,(v_lookshift).w
; 		bra.s	loc_12FC2
; ; ===========================================================================
; 
; Sonic_ResetScr:
; 		cmpi.w	#$60,(v_lookshift).w ; is screen in its default position?
; 		beq.s	loc_12FC2	; if yes, branch
; 		bcc.s	loc_12FBE
; 		addq.w	#4,(v_lookshift).w ; move screen back to default
; 
; loc_12FBE:
; 		subq.w	#2,(v_lookshift).w ; move screen back to default
Sonic_LookUp:
		btst	#bitUp,(v_jpadhold2).w  ; is up being pressed?
		beq.s	Sonic_Duck	        ; if not, branch
		move.b	#id_LookUp,obAnim(a0)	; use "looking up" animation
		addq.b	#1,(v_vscrolldelay).w
		cmp.b	#$78,(v_vscrolldelay).w
		bcs.s	Sonic_ResetScr_Part2
		move.b	#$78,(v_vscrolldelay).w
		cmpi.w	#$C8,(v_lookshift).w
		beq.s	loc_12FC2
		addq.w	#2,(v_lookshift).w
		bra.s	loc_12FC2
; ===========================================================================
 
Sonic_Duck:
		btst	#bitDn,(v_jpadhold2).w  ; is down being pressed?
		beq.s	Sonic_ResetScr	        ; if not, branch
		move.b	#id_Duck,obAnim(a0)	; use "ducking"	animation
		addq.b	#1,(v_vscrolldelay).w
		cmpi.b	#$78,(v_vscrolldelay).w
		bcs.s	Sonic_ResetScr_Part2
		move.b	#$78,(v_vscrolldelay).w
		cmpi.w	#8,(v_lookshift).w
		beq.s	loc_12FC2
		subq.w	#2,(v_lookshift).w
		bra.s	loc_12FC2
; ===========================================================================
 
Sonic_ResetScr:
		move.b	#0,(v_vscrolldelay).w
 
Sonic_ResetScr_Part2:
		cmpi.w	#$60,(v_lookshift).w ; is	screen in its default position?
		beq.s	loc_12FC2	; if yes, branch
		bcc.s	loc_12FBE
		addq.w	#4,(v_lookshift).w ; move	screen back to default
 
loc_12FBE:
		subq.w	#2,(v_lookshift).w ; move	screen back to default +++ end of new code
; ---------------------------------------------------------------------------
; updates Sonic's speed on the ground
; ---------------------------------------------------------------------------
loc_12FC2:
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0	; is left/right	pressed?
		bne.s	loc_12FEE	; if yes, branch
		move.w	obInertia(a0),d0
		beq.s	loc_12FEE
		bmi.s	loc_12FE2
; slow down when facing right and not pressing a direction
		sub.w	d5,d0
		bcc.s	loc_12FDC
		move.w	#0,d0

loc_12FDC:
		move.w	d0,obInertia(a0)
		bra.s	loc_12FEE
; ---------------------------------------------------------------------------
; slow down when facing left and not pressing a direction
loc_12FE2:
		add.w	d5,d0
		bcc.s	loc_12FEA
		move.w	#0,d0

loc_12FEA:
		move.w	d0,obInertia(a0)

; increase or decrease speed on the ground
loc_12FEE:
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)

; stops Sonic from running through walls that meet the ground
loc_1300C:
		move.b	obAngle(a0),d0
		addi.b	#$40,d0
		bmi.s	locret_1307C
		move.b	#$40,d1                               
		tst.w	obInertia(a0)
		beq.s	locret_1307C
		bmi.s	loc_13024
		neg.w	d1

loc_13024:
		move.b	obAngle(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		bsr.w	Sonic_WalkSpeed
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	locret_1307C
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_13078
		cmpi.b	#$40,d0
		beq.s	loc_13066
		cmpi.b	#$80,d0
		beq.s	loc_13060
		add.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obInertia(a0)
		rts	
; ===========================================================================

loc_13060:
		sub.w	d1,obVelY(a0)
		rts	
; ===========================================================================

loc_13066:
		sub.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obInertia(a0)
		rts	
; ===========================================================================

loc_13078:
		add.w	d1,obVelY(a0)

locret_1307C:
		rts	
; End of function Sonic_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveLeft:				; XREF: Sonic_Move
		move.w	obInertia(a0),d0
		beq.s	loc_13086
		bpl.s	loc_130B2       ; if Sonic is already moving to the right, branch

loc_13086:
		bset	#0,obStatus(a0)
		bne.s	loc_1309A
		bclr	#5,obStatus(a0)
		move.b	#1,obNextAni(a0)

loc_1309A:
		sub.w	d5,d0           ; add acceleration to the left
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0           ; compare new speed with top speed
		bgt.s	loc_130A6       ; if new speed is less than the maximum, branch
		add.w	d5,d0           ; remove this frame's acceleration change
		cmp.w	d1,d0           ; compare speed with top speed
		ble.s	loc_130A6       ; if speed was already greater than the maximum, branch
		move.w	d1,d0           ; limit speed on ground going left

loc_130A6:
		move.w	d0,obInertia(a0)
		move.b	#id_Walk,obAnim(a0) ; use walking animation
		rts	
; ===========================================================================

loc_130B2:				; XREF: Sonic_MoveLeft
		sub.w	d4,d0
		bcc.s	loc_130BA
		move.w	#-$80,d0

loc_130BA:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_130E8
		cmpi.w	#$400,d0
		blt.s	locret_130E8
		move.b	#id_Stop,obAnim(a0) ; use "stopping" animation
		bclr	#0,obStatus(a0)
		sfx	sfx_Skid	; play stopping sound
        	btst	#6,obStatus(a0)
                bne.s   locret_130E8	; if he's underwater, branch to not make dust
        	btst	#1,obStatus(a0)
                bne.s   locret_130E8	; if he's in the air, branch to not make dust
         	move.b	#6,(v_dustobj+obRoutine).w     ; skid dust
	        move.b	#$15,(v_dustobj+obFrame).w     ; skid dust

locret_130E8:
		rts	
; End of function Sonic_MoveLeft


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveRight:			; XREF: Sonic_Move
		move.w	obInertia(a0),d0
		bmi.s	loc_13118
		bclr	#0,obStatus(a0)
		beq.s	loc_13104
		bclr	#5,obStatus(a0)
		move.b	#1,obNextAni(a0)

loc_13104:
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_1310C
		sub.w	d5,d0              ; +++ remove ground speed cap
		cmp.w	d6,d0              ; +++
		bge.s	loc_1310C          ; +++

		move.w	d6,d0

loc_1310C:
		move.w	d0,obInertia(a0)
		move.b	#id_Walk,obAnim(a0) ; use walking animation

		rts	
; ===========================================================================

loc_13118:				; XREF: Sonic_MoveRight
		add.w	d4,d0
		bcc.s	loc_13120
		move.w	#$80,d0

loc_13120:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_1314E
		cmpi.w	#-$400,d0
		bgt.s	locret_1314E
		move.b	#id_Stop,obAnim(a0) ; use "stopping" animation
		bset	#0,obStatus(a0)
		sfx	sfx_Skid	; play stopping sound
        	btst	#6,obStatus(a0)
                bne.s   locret_1314E	; if he's underwater, branch to not make dust
        	btst	#1,obStatus(a0)
                bne.s   locret_1314E	; if he's in the air, branch to not make dust
         	move.b	#6,(v_dustobj+obRoutine).w   ; skid dust
	        move.b	#$15,(v_dustobj+obFrame).w   ; skid dust

locret_1314E:
		rts
; End of function Sonic_MoveRight
