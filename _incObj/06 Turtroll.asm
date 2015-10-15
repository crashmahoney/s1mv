; ---------------------------------------------------------------------------
; _____  _     ___  _____  ___   ___   _     _    
;  | |  | | | | |_)  | |  | |_) / / \ | |   | |   
;  |_|  \_\_/ |_| \  |_|  |_| \ \_\_/ |_|__ |_|__  
; Object 06 - Turtroll enemy (GHZ)
; ---------------------------------------------------------------------------
Turtroll:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Turtroll_Index(pc,d0.w),d1
		jmp	Turtroll_Index(pc,d1.w)
; ===========================================================================
Turtroll_Index:	dc.w Turtroll_Main-Turtroll_Index
		dc.w Turtroll_Action-Turtroll_Index
		dc.w Turtroll_Animate-Turtroll_Index
		dc.w Turtroll_Delete-Turtroll_Index
; ===========================================================================
Turtroll_Main:	; Routine 0
		move.l	#Map_Turtroll,obMap(a0)
		move.w	#VRAMloc_Turtroll/$20,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$200,obPriority(a0)
		move.b	#$8,obActWid(a0)
		move.b	#$8,obWidth(a0)
		move.b	#$8,obHeight(a0)
		move.b	#$B,obColType(a0)
		move.b	#0,obAnim(a0)
		move.w	#60,$30(a0)	  		; set pause time
		bsr.w	ObjectFall
		jsr	ObjFloorDist
		tst.w	d1
		bpl.s	@notonfloor
		add.w	d1,obY(a0)			; match	object's position with the floor
		move.w	#0,obVelY(a0)
		addq.b	#2,obRoutine(a0) 		; goto Turtroll_Action next
		bchg	#0,obStatus(a0)
    
	@notonfloor:
		rts	
; ===========================================================================
Turtroll_Action:	; Routine 2
		jsr     FindHomingAttackTarget
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Turtroll_ActIndex(pc,d0.w),d1
 		jsr	Turtroll_ActIndex(pc,d1.w)
		lea	(Ani_Turtroll).l,a1
		bsr.w	AnimateSprite
		bra.w	RememberState
; ===========================================================================
Turtroll_ActIndex:	dc.w @standing-Turtroll_ActIndex
                        dc.w @wait-Turtroll_ActIndex
		        dc.w @roll-Turtroll_ActIndex
		        dc.w @dizzy-Turtroll_ActIndex
		        dc.w @reset-Turtroll_ActIndex
@time:		= $30
@stardelay:	= $32
; ===========================================================================
@standing:      ; routine 0
		bset	#0,obStatus(a0)
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	@sonicisright
		neg.w	d0
		bclr	#0,obStatus(a0)
	@sonicisright:
		subq.w	#1,@time(a0)	  ; subtract 1 from pause time
		bpl.s	@wait	  	  ; if time remains, branch
		addq.b	#2,ob2ndRout(a0)
 		move.b	#1,obAnim(a0)     ; go to crouching animation
		move.w	#40,@time(a0)	  ; set roll time
		move.w	#-$120,obVelX(a0) ; set velocity to the left
		move.w	#0,obVelY(a0)
		btst	#0,obStatus(a0)
		beq.s	@wait             ; if facing ledt
		neg.w	obVelX(a0)	  ; change velocity direction
; ===========================================================================
@wait:          ; routine 2, 6
		rts	
; =========================================================================
@roll:          ; routine 4
 		move.b	#2,obAnim(a0)     ; go to rolling animation
		move.b	#$8B,obColType(a0); make invincible
		bsr.w	SpeedToPos
                ; check for hitting a wall
		move.w	obX(a0),d3
		addi.w	#$8,d3            ; get right edge of srite
		btst	#0,obStatus(a0)   ; facing left?
		bne.s	@facingright
		subi.w	#$10,d3           ; get left edge
        @facingright:
		jsr	ObjFloorDist2
		cmpi.w	#-12,d1            ; is floor is more than 12 pixels above bottom of sprite (i.e is a wall there?)
		bge.s	@nohitwall        ; if not, branch
		bchg	#0,obStatus(a0)   ; flip sprite direction
		neg.w	obVelX(a0)	  ; change velocity direction
		move.w	#-250,obVelY(a0)  ; bounce slightly upwards
;		sfx     $8B
		sub.w   #2,obY(a0)        ; lift so don't collide with floor
		rts
                ; check if falling
	@nohitwall:	
                jsr	ObjFloorDist
		tst.w	d1
 		bpl.s	@fall             ; if distance to floor is positive, fall down
		add.w	d1,obY(a0)	  ; match object's position with the floor
		move.w	#0,obVelY(a0)
		subq.w	#1,@time(a0)	  ; subtract 1 from roll time
		bpl.s   @fall
		move.w	#0,obVelX(a0)	  ; stop the object moving
 		move.b	#3,obAnim(a0)     ; go to standing up animation
		move.b	#$B,obColType(a0)
 		move.b  #20,@stardelay(a0)
		addq.b	#2,ob2ndRout(a0)
        @fall:
		bsr.w	ObjectFall
		rts
@dizzy:         ; routine 6
 		subi.b  #1,@stardelay(a0)
        	bcc.s   @fail
 		move.b  #20,@stardelay(a0)
		bsr.w   FindFreeObj
		bne.s	@fail
		move.b  #id_RingLoss,(a1)    ; create ring
        	move.b	#6,obRoutine(a1)     ; go straight to sparkle
		move.b	#8,obWidth(a1)
		move.b	#8,obHeight(a1)
		move.l	#Map_Ring,obMap(a1)
		move.w	#$27B2,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#0,obColType(a1)
		move.b	#1,obPriority(a1)
        	move.w  obX(a0),obX(a1)
		jsr	RandomNumber
		lsr.b	#4,d0
		btst	#0,obStatus(a0)   ; facing left?
		bne.s	@notleft
		subi.b	#16,d0
    @notleft:
		add.b	d0,obX+1(a1)
        	move.w  obY(a0),obY(a1)
        	subi.w  #$10,obY(a1)
	@fail:
        	rts
; ===========================================================================
@reset:         ; routine 8
 		move.b	#0,obAnim(a0)     ; go to standing animation
		move.w	#40,@time(a0)	  ; set pause time
		move.b	#0,ob2ndRout(a0)  ; go back to start of behaviour
                rts
; ===========================================================================
Turtroll_Animate:	; Routine 4
		lea		(Ani_Turtroll).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================
Turtroll_Delete:	; Routine 6
		bra.w	DeleteObject