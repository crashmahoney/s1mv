; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump dash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpDash:				; XREF: Obj01_MdNormal; Obj01_MdRoll
                moveq   #0,d1
                moveq   #0,d2
		tst.b	(v_justwalljumped).w 	      ; just wall jumped?
		bne.w	@dontdash                     ; if so, don't double jump
		tst.b   (v_jumpdashcount).w
 		bne.w	@dontdash	              ; if already jump dashed, branch

		moveq	#aJumpDash,d0                 ; which ability to check for (jumpdash)
                jsr     CheckAbility                  ; check if equppied
                tst.b   d1                            ; is ability equipped?
                beq.s   @CheckHoming                  ; if not, branch
                moveq   #0,d0
                moveq   #0,d1
                bra.w   @jumpdashsetup                ; if so, branch
        @CheckHoming:
		moveq	#aHoming,d0                   ; which ability to check for (homing)
                jsr     CheckAbility                  ; check if homing attack button pressed
                tst.b   d1                            ; is button pressed?
                beq.w   @dontdash                     ; if not, branch
                lea     (v_homingattackobj).w,a2        ; ram address for homing target object
		move.w	obX(a2),d1                    ; set the x and y targets
		move.w	obY(a2),d2
		moveq	#0,d3
@jumpdashsetup:
		move.b  #1,(v_jumpdashcount).w  ; +++ set jump dash flag
		sfx	sfx_Dash	; play sound
                move.w  #$A00,d3        ; set normal jump dash speed
        @speedshoeschk:
                tst.b   (v_shoes).w     ; speed shoes enabled?
                beq.s   @waterchk       ; if not, branch
                move.w  #$B00,d3        ; set speed shoe dump dash speed
        @waterchk:
                btst    #6,obStatus(a0) ; is sonic underwater?
                beq.s   @dirchk         ; if not, branch
                move.w  #$600,d3        ; set underwater jump dash speed
        @dirchk:

@jumpdash:
                moveq   #0,d0
                tst.b   d1              ; is there a target for the homing attack?
                bne.s   @homingattack   ; if so branch
                bsr.w   CreateSparks
                btst    #0,obStatus(a0) ; is sonic facing left?
                beq.s   @dontnegate3    ; if not, branch
                neg.w   d3
        @dontnegate3:
                move.w  d3,obVelX(a0)   ; move sonic forward
                clr.w   obVelY(a0)      ; set sonic's Y velocity to 0
                bra.s   @roll           ; skip the homing attack
@homingattack:
                sub.w   #$10,d2         ; aim slightly higher, at roughly top of object
                sub.w   obX(a0),d1      ; (x2-x1)        result is in d1
                sub.w   obY(a0),d2      ; (y2-y1)        result is in d2
                jsr     CalcAngle
                jsr     CalcSine
                muls.w  d3,d1           ; get X speed (dash speed * cos)
		asr.l	#8,d1
                move.w  d1,obVelX(a0)   ; move sonic horizontally
                muls.w  d3,d0           ; get Y speed (dash speed * sine)
		asr.l	#8,d0
                move.w  d0,obVelY(a0)   ; move sonic vertically
        @roll:
		move.b	#$E,obWidth(a0)
		move.b	#7,obHeight(a0)
                move.b	#id_Roll,obAnim(a0) ; use "jumping" animation
		bset	#2,obStatus(a0)     ; set status to rolling
		addq.w	#5,obY(a0)          ; move sonic down, cos of changed size
@dontdash:
                rts

; =========================================================================
FindHomingAttackTarget:
                btst    #1,(v_player+obStatus).w  ; is sonic in the air?
                beq.s   DontTarget                ; if not, branch
	        moveq   #0,d0
	        moveq   #0,d1
          @getX:
		move.w  obX(a0),d0                ; object's x pos to d0
                sub.w   (v_player+obX).w,d0       ; subtract sonic's x pos
                bmi.s   @negative                 ; is the result a negative number? (ie sonic is to the right of the object) if so, branch
                btst    #0,(v_player+obStatus).w  ; is sonic facing right? (i.e. not facing the object)
                bne.s   DontTarget                ; if so, branch
                bra.s   @getY
          @negative:
                btst    #0,(v_player+obStatus).w  ; is sonic facing left? (i.e. not facing the object)
                beq.s   DontTarget                ; if so, branch
                neg     d0
          @getY:
		move.w  obY(a0),d1                ; object's y pos to d1
                sub.w   (v_player+obY).w,d1       ; subtract sonic's y pos
                bpl.s   @dontnegateY              ; branch if positive
                neg     d1
          @dontnegateY:
                add.w   d1,d0                     ; now d0 contains the distance between sonic and object

                cmp.w   #$C0,d0                   ; is the object out of homing attack range?
                bcc.s   DontTarget                ; if so, branch
                cmp.w   (v_homingdistance).w,d0   ; is the distance less than last closest object found?
                bcc.s   DontTarget                ; if not, branch
                move.w  d0,(v_homingdistance).w   ; save this distance as the new shortest distance
		move.b  d7,(v_homingtarget).w     ; remember which object this was
                lea     (v_homingattackobj).w,a2    ; ram address for homing target object
		move.w	obX(a0),(v_homingattackobj+obX).w ; send targeted object's position to homing target object
		move.w	obY(a0),(v_homingattackobj+obY).w
		move.b  d7,(v_homingattackobj+$29).w ; tell target object which object is being targeted

DontTarget:
                rts
; End of function Sonic_Jump