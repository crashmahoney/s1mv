; ---------------------------------------------------------------------------
; Object 25 - rings
; ---------------------------------------------------------------------------

Rings:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Ring_Index(pc,d0.w),d1
		jmp	Ring_Index(pc,d1.w)
; ===========================================================================
Ring_Index:	dc.w Ring_Main-Ring_Index                 ; 0
		dc.w Ring_Animate-Ring_Index              ; 2
		dc.w Ring_Collect-Ring_Index              ; 4
		dc.w Ring_Sparkle-Ring_Index              ; 6
		dc.w Ring_Delete-Ring_Index               ; 8
		dc.w Ring_Attract-Ring_Index              ; A
		dc.w Ring_Collect-Ring_Index              ; C
		dc.w Ring_Sparkle-Ring_Index              ; E
		dc.w Ring_Delete-Ring_Index               ; 10
; ---------------------------------------------------------------------------
; Distances between rings (format: horizontal, vertical)
; ---------------------------------------------------------------------------
Ring_PosData:	dc.b $10, 0		; horizontal tight
		dc.b $18, 0		; horizontal normal
		dc.b $20, 0		; horizontal wide
		dc.b 0,	$10		; vertical tight
		dc.b 0,	$18		; vertical normal
		dc.b 0,	$20		; vertical wide
		dc.b $10, $10		; diagonal
		dc.b $18, $18
		dc.b $20, $20
		dc.b $F0, $10
		dc.b $E8, $18
		dc.b $E0, $20
		dc.b $10, 8
		dc.b $18, $10
		dc.b $F0, 8
		dc.b $E8, $10
; ===========================================================================

Ring_Main:	; Routine 0
        if S3KObjectManager=1
                move.w	obRespawnNo(a0),d0
	        movea.w	d0,a2	; load address into a2
        else
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		lea	2(a2,d0.w),a2
	endif
		move.b	(a2),d4
		move.b	obSubtype(a0),d1
		moveq	#0,d0
		move.b	d1,d0
		andi.w	#7,d1
		cmpi.w	#7,d1
		bne.s	loc_9B80
		moveq	#6,d1

	loc_9B80:
		swap	d1
		move.w	#0,d1
		lsr.b	#4,d0
		add.w	d0,d0
		move.b	Ring_PosData(pc,d0.w),d5 ; load ring spacing data
		ext.w	d5
		move.b	Ring_PosData+1(pc,d0.w),d6
		ext.w	d6
		movea.l	a0,a1
		move.w	obX(a0),d2
		move.w	obY(a0),d3
		lsr.b	#1,d4
		bcs.s	loc_9C02
;		bclr	#7,(a2)           ; this makes the s3 object manager think it needs reloading
		bra.s	loc_9BBA
; ===========================================================================

Ring_MakeRings:
		swap	d1
		lsr.b	#1,d4
		bcs.s	loc_9C02
;		bclr	#7,(a2)           ; this makes the s3 object manager think it needs reloading
		bsr.w	FindFreeObj
		bne.s	loc_9C0E

loc_9BBA:				; XREF: Ring_Main
		move.b	#id_Rings,0(a1)	; load ring object
		addq.b	#2,obRoutine(a1)
		move.w	d2,obX(a1)	; set x-axis position based on d2
		move.w	obX(a0),$32(a1)
		move.w	d3,obY(a1)	; set y-axis position based on d3
		move.l	#Map_Ring,obMap(a1)
		move.w	#$27B2,obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#$100,obPriority(a1)
		move.b	#$47,obColType(a1)
		move.b	#8,obActWid(a1)
        if S3KObjectManager=1
		move.w	obRespawnNo(a0),obRespawnNo(a1)
        else
		move.b	obRespawnNo(a0),obRespawnNo(a1)
        endif
		move.b	d1,$34(a1)

loc_9C02:
		addq.w	#1,d1
		add.w	d5,d2		; add ring spacing value to d2
		add.w	d6,d3		; add ring spacing value to d3
		swap	d1
		dbf	d1,Ring_MakeRings ; repeat for	number of rings

loc_9C0E:
		btst	#0,(a2)
		bne.w	DeleteObject
; --------------------------------------------------------------------------
Ring_Animate:	; Routine 2
                cmpi.b  #2,(v_shield).w              ; have electric shield?
                bne.s   @noattract
; --------------------------------------------------------------------------
		move.w	(v_player+obX).w,d0          ; sonic x pos
		sub.w	obX(a0),d0                   ; subtract ring x pos
		bcc.s	@compareX                    ; branch if result is positive
		neg.w	d0
@compareX:
                cmpi.w  #$40,d0                      ; within $20 pixels?
                bcc.s   @noattract                   ; if not, branch
; --------------------------------------------------------------------------
		move.w	(v_player+obY).w,d0          ; sonic Y pos
		sub.w	obY(a0),d0                   ; subtract ring Y pos
		bcc.s	@compareY                    ; branch if result is positive
		neg.w	d0
@compareY:
                cmpi.w  #$40,d0                      ; within $20 pixels?
                bcc.s   @noattract                   ; if not, branch
; --------------------------------------------------------------------------
        if S3KObjectManager=1
		moveq	#0,d0
                move.w	obRespawnNo(a0),d0	; get address in respawn table
	        movea.w	d0,a2	                ; load address into a2
		move.b	$34(a0),d1
		bset	d1,(a2)
        else
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		move.b	$34(a0),d1
		bset	d1,2(a2,d0.w)
	endif
                addq.b  #8,obRoutine(a0)        ; change to attracted ring routine
; --------------------------------------------------------------------------
      @noattract:
		move.b	(v_ani1_frame).w,obFrame(a0) ; set frame
		bsr.w	DisplaySprite
		obRanges	Ring_Delete,$32(a0)
		rts	
; ===========================================================================

Ring_Collect:	; Routine 4
		addq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		move.w	#$80,obPriority(a0)
		bsr.w	CollectRing
        if S3KObjectManager=1
		moveq	#0,d0
                move.w	obRespawnNo(a0),d0	; get address in respawn table
	        movea.w	d0,a2	                ; load address into a2
		move.b	$34(a0),d1
		bset	d1,(a2)
        else
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		move.b	$34(a0),d1
		bset	d1,2(a2,d0.w)
	endif

Ring_Sparkle:	; Routine 6
		lea	(Ani_Ring).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

Ring_Delete:	; Routine 8
        if S3KObjectManager=1
                obMarkGone
        endif
		bra.w	DeleteObject
; ===========================================================================
Ring_Attract:
		move.w	#$30,d1                     ; speed to add
		move.w	(v_player+obX).w,d0
		cmp.w	obX(a0),d0
		bcc.s	@moveleft                   ; branch if to the right of sonic
		neg.w	d1
		tst.w	obVelX(a0)
		bmi.s	@addXspeed                  ; branch if ring is already moving left
		add.w	d1,d1
		add.w	d1,d1                       ; multiply speed to add
		bra.s	@addXspeed
; ---------------------------------------------------------------------------
@moveleft:
		tst.w	obVelX(a0)
		bpl.s	@addXspeed                  ; branch if ring is already moving right
		add.w	d1,d1
		add.w	d1,d1
@addXspeed:
		add.w	d1,obVelX(a0)
; --------------------------------------------------------------------------
		move.w	#$30,d1                     ; speed to add
		move.w	(v_player+obY).w,d0
		cmp.w	obY(a0),d0
		bcc.s	@movedown
		neg.w	d1
		tst.w	obVelY(a0)
		bmi.s	@addYspeed
		add.w	d1,d1
		add.w	d1,d1
		bra.s	@addYspeed
; ---------------------------------------------------------------------------
@movedown:
		tst.w	obVelY(a0)
		bpl.s	@addYspeed
		add.w	d1,d1
		add.w	d1,d1
@addYspeed:
		add.w	d1,obVelY(a0)
		bsr.w	SpeedToPos
		move.b	(v_ani1_frame).w,obFrame(a0) ; set frame
		bsr.w	DisplaySprite
		rts
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CollectRing:				; XREF: Ring_Collect
		addq.w	#1,(v_rings).w	; add 1 to rings
		ori.b	#1,(f_ringcount).w ; update the rings counter
		move.w	#sfx_Ring,d0	; play ring sound
		tst.b   (v_homingtimer).w    ; performing a light dash?
		beq.s   @notdashing     ; if so, don't set timer
		move.b  #10,(v_homingtimer).w ; reset timer so we look for the next ring
	@notdashing:
		cmpi.w	#100,(v_rings).w ; do you have < 100 rings?
		bcs.s	@playsnd	; if yes, branch
		bset	#1,(v_lifecount).w ; update lives counter
		beq.s	@got100
		cmpi.w	#200,(v_rings).w ; do you have < 200 rings?
		bcs.s	@playsnd	; if yes, branch
		bset	#2,(v_lifecount).w ; update lives counter
		bne.s	@playsnd

	@got100:
		addq.b	#1,(v_lives).w	; add 1 to the number of lives you have
		addq.b	#1,(f_lifecount).w ; update the lives counter
		move.w	#bgm_ExtraLife,d0 ; play extra life music

	@playsnd:
		jmp	(PlaySound_Special).l
; End of function CollectRing

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 37 - rings flying out of Sonic	when he's hit
; ---------------------------------------------------------------------------

RingLoss:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	RLoss_Index(pc,d0.w),d1
		jmp	RLoss_Index(pc,d1.w)
; ===========================================================================
RLoss_Index:	dc.w RLoss_Count-RLoss_Index
		dc.w RLoss_Bounce-RLoss_Index
		dc.w RLoss_Collect-RLoss_Index
		dc.w RLoss_Sparkle-RLoss_Index
		dc.w RLoss_Delete-RLoss_Index
; ===========================================================================

RLoss_Count:	; Routine 0
		movea.l	a0,a1
		moveq	#0,d5
		move.w	(v_rings).w,d5	; check number of rings you have
		moveq	#32,d0
		cmp.w	d0,d5		; do you have 32 or more?
		bcs.s	@belowmax	; if not, branch
		move.w	d0,d5		; if yes, set d5 to 32

	@belowmax:
		subq.w	#1,d5
; 		move.w	#$288,d4            ; we're changing this, we're going to precalculate the ring angles (thanks to SpirituInsanum)
		lea	SpillingRingData,a3 ; load the address of the array in a3
		bra.s	@makerings
; ===========================================================================

	@loop:
		bsr.w	FindFreeObj
		bne.w	@resetcounter

@makerings:
		move.b	#id_RingLoss,0(a1) ; load bouncing ring object
		addq.b	#2,obRoutine(a1)
		move.b	#8,obWidth(a1)
		move.b	#8,obHeight(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#Map_Ring,obMap(a1)
		move.w	#$27B2,obGfx(a1)
		move.b	#4,obRender(a1)
;		move.b	#3,obPriority(a1)     ; deleted for rhs's speedup
		move.b	#$47,obColType(a1)
		move.b	#8,obActWid(a1)
 		move.b	#-1,(v_ani3_time).w
		move.l	(a3)+,obVelX(a1) ; move the data contained in the array to the x & y velocities (each a word) and increment the address in a3
		dbf	d5,@loop	; repeat for number of rings (max 31)

@resetcounter:
		move.w	#0,(v_rings).w	; reset number of rings to zero
		move.b	#$80,(f_ringcount).w ; update ring counter
		move.b	#0,(v_lifecount).w
		sfx	sfx_RingLoss	; play ring loss sound

RLoss_Bounce:	; Routine 2
		move.b	(v_ani3_frame).w,obFrame(a0)
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)
		bmi.s	@chkdel
		move.b	(v_vbla_byte).w,d0
		add.b	d7,d0
		andi.b	#3,d0
		bne.s	@chkdel
		jsr	ObjFloorDist
		tst.w	d1
		bpl.s	@chkdel
		add.w	d1,obY(a0)
		move.w	obVelY(a0),d0
		asr.w	#2,d0
		sub.w	d0,obVelY(a0)
		neg.w	obVelY(a0)

	@chkdel:
		tst.b	(v_ani3_time).w
		beq.s	RLoss_Delete
		move.w	(v_limitbtm2).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0	; has object moved below level boundary?
		bcs.s	RLoss_Delete	; if yes, branch
;		bra.w	DisplaySprite   ; rhs's speedup, modified version of DisplaySprite inlined below
		lea	(v_spritequeue).w,a1
		adda.w	#$180,a1	; jump to position in queue
		cmpi.w	#$7E,(a1)	; is this part of the queue full?
		bcc.s	@DSpr_Full	; if yes, branch
		addq.w	#2,(a1)		; increment sprite count
		adda.w	(a1),a1		; jump to empty position
		move.w	a0,(a1)		; insert RAM address for object

	@DSpr_Full:
		rts	

; ===========================================================================

RLoss_Collect:	; Routine 4
		addq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		move.w	#$80,obPriority(a0)
		bsr.w	CollectRing

RLoss_Sparkle:	; Routine 6
		lea	(Ani_Ring).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

RLoss_Delete:	; Routine 8
		bra.w	DeleteObject
		even
		
; SpillingRingData:
; 		dc.w	-1000, 0
; 		dc.w	 -981, 195
; 		dc.w	 -981,-195
; 		dc.w	 -924, 383
; 		dc.w	 -924,-383
; 		dc.w	 -831, 556
; 		dc.w	 -831,-556
; 		dc.w	 -707, 707
; 		dc.w	 -707,-707
; 		dc.w	 -556, 831
; 		dc.w	 -556,-831
; 		dc.w	 -383, 924
; 		dc.w	 -383,-924
; 		dc.w	 -195, 981
; 		dc.w	 -195,-981
; 		dc.w	    0,1000
; 		dc.w	    0,-1000
; 		dc.w	  195, 981
; 		dc.w	  195,-981
; 		dc.w	  383, 924
; 		dc.w	  383,-924
; 		dc.w	  556, 831
; 		dc.w	  556,-831
; 		dc.w	  707, 707
; 		dc.w	  707,-707
; 		dc.w	  831, 556
; 		dc.w	  831,-556
; 		dc.w	  924, 383
; 		dc.w	  924,-383
; 		dc.w	  981, 195
; 		dc.w	  981,-195
; 		dc.w	 1000, 0
; 	even
	
SpillingRingData:       ; These are the x & y values that the original routine calculated
		dc.w	$FF3C, $FC14
		dc.w    $00C4, $FC14
		dc.w	$FDC8, $FCB0
		dc.w	$0238, $FCB0
		dc.w	$FCB0, $FDC8
		dc.w	$0350, $FDC8
		dc.w	$FC14, $FF3C
		dc.w	$03EC, $FF3C
		dc.w	$FC14, $00C4
		dc.w	$03EC, $00C4
		dc.w	$FCB0, $0238
		dc.w	$0350, $0238
		dc.w	$FDC8, $0350
		dc.w	$0238, $0350
		dc.w	$FF3C, $03EC
		dc.w	$00C4, $03EC
		dc.w	$FF9E, $FE0A
		dc.w	$0062, $FE0A
		dc.w	$FEE4, $FE58
		dc.w    $011C, $FE58
		dc.w	$FE58, $FEE4
		dc.w	$01A8, $FEE4
		dc.w	$FE0A, $FF9E
		dc.w	$01F6, $FF9E
		dc.w    $FE0A, $0062
		dc.w	$01F6, $0062
		dc.w	$FE58, $011C
		dc.w	$01A8, $011C
		dc.w	$FEE4, $01A8
		dc.w	$011C, $01A8
		dc.w	$FF9E, $01F6
		dc.w	$0062, $01F6
	even
