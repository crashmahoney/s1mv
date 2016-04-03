; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to Spin Dash
; ---------------------------------------------------------------------------
; 
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

SpinDashFlag    = $39
SpinDashCount   = $3A

Sonic_SpinDash:
		btst	#staSpinDash,obStatus2(a0); already Spin Dashing?
		bne.s	loc2_1AC8E				; if set, branch
		tst.b   (v_abil_spindash).w     ; is spin dash allowed?
		beq.s   @end                    ; if you can't spin dash, return
		cmpi.b	#id_Duck,obAnim(a0)		; is anim duck
		beq.s	@ckhbuttons		        ; if so, continue
		cmpi.b	#id_Crouch,obAnim(a0)	; is anim crouch
		bne.s   @end                    ; if not, branch
		move.b	(v_jpadhold2).w,d0		; read controller
		andi.b	#btnDn,d0				; pressing down ?
		beq.w	@end        			; if not, return
	@ckhbuttons:
		move.b	(v_jpadpress2).w,d0	; read controller
		andi.b	#btnABC,d0		; pressing A/B/C ?
		beq.w	@end        		; if not, return
		move.b	#id_SpinDash,obAnim(a0)	; set Spin Dash anim
		sfx	sfx_SpinDash    	; play SpinDash sound
		addq.l	#4,sp			; increment stack ptr
		bset	#staSpinDash,obStatus2(a0); set Spin Dash flag
		move.w	#0,SpinDashCount(a0)	; set charge count to 0
		cmpi.b	#$C,$28(a0)		; ??? oxygen remaining?
		move.b	#2,(v_dustobj+obAnim).w	; Set the Spin Dash dust animation to $2

		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos

@end:
		rts
; ---------------------------------------------------------------------------
 
loc2_1AC8E:
		move.b	#id_SpinDash,obAnim(a0)
		move.b	(v_jpadhold2).w,d0	; read controller
		btst	#1,d0			; check down button
		bne.w	loc2_1AD30		; if set, branch
		move.b	#$E,$16(a0)		; $16(a0) is height/2
		move.b	#7,$17(a0)		; $17(a0) is width/2
		move.b	#id_Roll,obAnim(a0)	; set animation to roll
		addq.w	#5,$C(a0)		; $C(a0) is Y coordinate
		bclr	#staSpinDash,obStatus2(a0); clear Spin Dash flag
		moveq	#0,d0
		move.b	SpinDashCount(a0),d0	; copy charge count
		add.w	d0,d0			; double it
		move.w	spdsh_norm(pc,d0.w),obInertia(a0) ; get normal speed
		tst.b	(f_supersonic).w		; is sonic super?
		beq.s	loc2_1ACD0		; if no, branch
		move.w	spdsh_super(pc,d0.w),obInertia(a0) ; get super speed
 
loc2_1ACD0:					; TODO: figure this out
		move.w	obInertia(a0),d0		; get inertia
		subi.w	#$800,d0		; subtract $800
		add.w	d0,d0			; double it
		andi.w	#$1F00,d0		; mask it against $1F00
		neg.w	d0			; negate it
		addi.w	#$2000,d0		; add $2000
                move.w  (v_limitright2).w,d1
                sub.w   #$128,d1
                cmp.w   obX(a0),d1              ; if sonic is within $128 of right edge
                ble.s   @nodelay                ; then branch (stops a bug when spindashing into the next act)
		move.w	d0,(v_hscrolldelay).w	; move to v_hscrolldelay
        @nodelay:
		btst	#staFacing,obStatus(a0)	; is sonic facing right?
		beq.s	loc2_1ACF4		; if not, branch
		neg.w	obInertia(a0)			; negate inertia
 
loc2_1ACF4:
		bset	#2,$22(a0)		; set unused (in s1) flag
		move.b	#0,(v_dustobj+obAnim).w	; clear Spin Dash dust animation
		sfx     sfx_Dash                ; Play launch sound

		move.b	obAngle(a0),d0          ; spindash screen edge bug fix
		jsr	(CalcSine).l            ; |
		muls.w	obInertia(a0),d1        ; |
		asr.l	#8,d1                   ; |
		move.w	d1,obVelX(a0)           ; |
		muls.w	obInertia(a0),d0        ; |
		asr.l	#8,d0                   ; |
		move.w	d0,obVelY(a0)           ; V

		bra.s	loc2_1AD78
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
spdsh_norm:
		dc.w  $800		; 0         how much power the spindash has after this many presses
		dc.w  $880		; 1
		dc.w  $900		; 2
		dc.w  $980		; 3
		dc.w  $A00		; 4
		dc.w  $A80		; 5
		dc.w  $B00		; 6
		dc.w  $B80		; 7
		dc.w  $C00		; 8
 
spdsh_super:
		dc.w  $B00		; 0
		dc.w  $B80		; 1
		dc.w  $C00		; 2
		dc.w  $C80		; 3
		dc.w  $D00		; 4
		dc.w  $D80		; 5
		dc.w  $E00		; 6
		dc.w  $E80		; 7
		dc.w  $F00		; 8
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
 
loc2_1AD30:				; If still charging the dash...
		tst.w	SpinDashCount(a0)	; check charge count
		beq.s	loc2_1AD48	        ; if zero, branch
		move.w	SpinDashCount(a0),d0	; otherwise put it in d0
		lsr.w	#5,d0		        ; shift right 5 (divide it by 32)
		sub.w	d0,SpinDashCount(a0)	; subtract from charge count
		bcc.s	loc2_1AD48	        ; ??? branch if carry clear
		move.w	#0,SpinDashCount(a0)	; set charge count to 0
 
loc2_1AD48:
		move.b	(v_jpadpress2).w,d0	; read controller
		andi.b	#btnABC,d0		; pressing A/B/C?
		beq.w	loc2_1AD78		; if not, branch
		move.w	#(id_SpinDash<<8),obAnim(a0)	; reset sonic spdsh animation
		move.w	#$D1,d0			; was $E0 in sonic 2
		move.b	#2,(v_dustobj+obAnim).w	; Set the Spin Dash dust animation to $2
		sfx	sfx_SpinDash    	; play charge sound
		addi.w	#$200,SpinDashCount(a0)	; increase charge count
		cmpi.w	#$800,SpinDashCount(a0)	; check if it's maxed
		bcs.s	loc2_1AD78		; if not, then branch
		move.w	#$800,$3A(a0)		; reset it to max
 
loc2_1AD78:
		addq.l	#4,sp			; increase stack ptr
		cmpi.w	#$60,(v_lookshift).w
		beq.s	loc2_1AD8C
		bcc.s	loc2_1AD88
		addq.w	#4,(v_lookshift).w
 
loc2_1AD88:
		subq.w	#2,(v_lookshift).w
 
loc2_1AD8C:
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos
		;move.w	#$60,(v_lookshift).w	; reset looking up/down
		rts

; End of subroutine Sonic_SpinDash
