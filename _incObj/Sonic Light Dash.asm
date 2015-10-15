; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to light dash
; (this is mostly the homing attack code with a few alterations,
;  maybe I could combine the two???)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_LightDash:				; XREF: Obj01_MdNormal; Obj01_MdRoll
		tst.b   (v_homingtimer).w             ; already homing?
		bne.s   @FindHomingAttackTarget       ; jump straight to targeting
		moveq	#aLightDash,d0                ; which ability to check for (jumpdash)
                jsr     CheckAbility                  ; check if equppied
                tst.b   d1                            ; is ability equipped?
                bne.w   @FindHomingAttackTarget       ; if so, branch
                rts
; ===========================================================================

@FindHomingAttackTarget:

; d3 object x
; d4 object y

; d3 becomes distance between points
; d5 smallest distance found
                move.w  obX(a0),d1       ; save sonic's positions to registers
                move.w  obY(a0),d2
                moveq   #$FFFFFFFF,d5
                moveq   #0,d6
		lea	(v_objspace+$800).w,a1 ; start address for object RAM
		moveq	#$5F,d0                ; number of objects

 	@Loop:
		cmpi.b	#id_rings,(a1)
		bne.s	@nextobject	  ; if not a ring, skip object
                cmpi.b  #2,obRoutine(a1)
		bne.s	@nextobject	  ; if not collectable, skip object
        @findclosest:
           ; find distance between 2 points
           ; code is:
           ; xd = x2-x1
	   ; yd = y2-y1
	   ; Distance = SquareRoot(xd*xd + yd*yd) (ignore this line, i made it just xd + yd to make the code quicker)
          @getX:
		move.w  obX(a1),d3        ; object's x pos to d3
                sub.w   d1,d3             ; subtract sonic's x pos
                bmi.s   @negative         ; is the result a negative number? (ie sonic is to the right of the object) if so, branch
                btst    #0,obStatus(a0)   ; is sonic facing right? (i.e. not facing the object)
                bne.s   @nextobject       ; if so, branch
                bra.s   @getY
          @negative:
                btst    #0,obStatus(a0)   ; is sonic facing left? (i.e. not facing the object)
                beq.s   @nextobject       ; if so, branch
                neg     d3
          @getY:
		move.w  obY(a1),d4      ; object's y pos to d4
                sub.w   d2,d4           ; subtract sonic's y pos
                bpl.s   @dontnegateY    ; branch if positive
                neg     d4
          @dontnegateY:
                add.w   d4,d3           ; now d3 contains the distance between sonic and object

                cmp.w   #$50,d3         ; is the object out of homing attack range?
                bcc.s   @nextobject     ; if so, branch
                cmp.w   d3,d5           ; is the distance less than last closest object found?
                bcs.s   @nextobject     ; if not, branch
                move.w  d3,d5           ; save this distance as the shortest
		move.w  a1,d6           ; remember which object this was

        @nextobject:
                lea	$40(a1),a1	; goto next object RAM slot
		dbf	d0,@Loop	; repeat $5F times

                tst.w   d6              ; was anything found?
                beq.w   @dontdash       ; if not, branch
        ; Now d1 and d2 are the x and y position for sonic to target

; ===========================================================================
@finishedlooking:
                movea.w d6,a1           ; ram address for targeted object
		move.w	obX(a1),d1      ; send targeted object's position registers
		move.w	obY(a1),d2
;                beq.s   @dontdash       ; if no target, branch
		tst.b   (v_homingtimer).w    ; already homing?
		bne.s   @alreadyhoming            ; if so, don't set timer
 		move.b  #10,(v_homingtimer).w ; time to home for
 		bset	#1,obStatus(a0)      ; set in-air flag
		sfx     sfx_LightDash
 	@alreadyhoming:
		move.b	#id_SupRun,obAnim(a0)    ; set animation to super sonic

                moveq   #0,d0
                move.l  #$A00,d3        ; set normal jump dash speed
                btst    #6,obStatus(a0) ; is sonic underwater?
                beq.s   @homingattack   ; if not, branch
                move.w  #$500,d3        ; set underwater jump dash speed

@homingattack:
                sub.w   obX(a0),d1      ; (x2-x1)        result is in d1
                sub.w   obY(a0),d2      ; (y2-y1)        result is in d2
                jsr     CalcAngle
                move.b  d0,d5           ; save angle
                jsr     CalcSine
                muls.w  d3,d1           ; get X speed (dash speed * cos)
		asr.l	#8,d1
                move.w  d1,obVelX(a0)   ; move sonic horizontally
                muls.w  d3,d0           ; get Y speed (dash speed * sine)
		asr.l	#8,d0
                move.w  d0,obVelY(a0)   ; move sonic vertically
       ; fix angle
                bclr    #0,obStatus(a0) ; flip sonic right
                cmpi.w  #$8000,obVelX(a0); is sonic moving right?
		bcs.s	@notleft        ; if so, branch
                bset    #0,obStatus(a0) ; flip sonic left
                add.b	#$80,d5         ; reverse angle
        @notleft:
 		move.b	d5,obAngle(a0)  ; set angle
; ===========================================================================
 @dontdash:
		rts
; End of function Sonic_LightDash