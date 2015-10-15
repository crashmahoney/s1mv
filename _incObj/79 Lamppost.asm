; ---------------------------------------------------------------------------
; Object 79 - lamppost
; ---------------------------------------------------------------------------

Lamppost:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Lamp_Index(pc,d0.w),d1
		jsr	Lamp_Index(pc,d1.w)
		jmp	RememberState
; ===========================================================================
Lamp_Index:	dc.w Lamp_Main-Lamp_Index
		dc.w Lamp_Blue-Lamp_Index
		dc.w Lamp_Finish-Lamp_Index
		dc.w Lamp_Twirl-Lamp_Index
		dc.w Obj79_Star-Lamp_Index

lamp_origX:	= $30		; original x-axis position
lamp_origY:	= $32		; original y-axis position
lamp_time:	= $36		; length of time to twirl the lamp
lamp_child1	= $38
lamp_child2	= $3A
lamp_child3	= $3C
lamp_child4	= $3D
star_parent	= $38
; ===========================================================================

Lamp_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Lamp,obMap(a0)
		move.w	#($D800/$20),obGfx(a0) ; +++ was #$7A0,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#8,obActWid(a0)
		move.w	#$280,obPriority(a0)
        if S3KObjectManager=1
                move.w	obRespawnNo(a0),d0	; get address in respawn table
	        movea.w	d0,a2	; load address into a2
	        ;bclr	#7,(a2)	; clear respawn table entry, so object can be loaded again
	        btst	#0,(a2)
        else
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		bclr	#7,2(a2,d0.w)
		btst	#0,2(a2,d0.w)
        endif
		bne.s	@red
		move.b	(v_lastlamp).w,d1
		andi.b	#$7F,d1
		move.b	obSubtype(a0),d2 ; get lamppost number
		andi.b	#$7F,d2
		cmp.b	d2,d1		; is this a "new" lamppost?
		bcs.s	Lamp_Blue	; if yes, branch

@red:
        if S3KObjectManager=1
	        bset	#0,(a2)
        else
		bset	#0,2(a2,d0.w)
        endif
		move.b	#4,obRoutine(a0) ; goto Lamp_Finish next
		move.b	#3,obFrame(a0)	; use red lamppost frame
		rts	
; ===========================================================================

Lamp_Blue:	; Routine 2
		tst.w	(v_debuguse).w	; is debug mode	being used?
		bne.w	@donothing	; if yes, branch
		tst.b	(f_lockmulti).w
		bmi.w	@donothing
		move.b	(v_lastlamp).w,d1
		andi.b	#$7F,d1
		move.b	obSubtype(a0),d2
		andi.b	#$7F,d2
		cmp.b	d2,d1		; is this a "new" lamppost?
		bcs.s	@chkhit		; if yes, branch
        if S3KObjectManager=1
                move.w	obRespawnNo(a0),d0	; get address in respawn table
	        movea.w	d0,a2	; load address into a2
	        bset	#0,(a2)
        else
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		bset	#0,2(a2,d0.w)
        endif
		move.b	#4,obRoutine(a0)
		move.b	#3,obFrame(a0)
		bra.w	@donothing
; ===========================================================================

@chkhit:
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		addq.w	#8,d0
		cmpi.w	#$10,d0
		bcc.w	@donothing
		move.w	(v_player+obY).w,d0
		sub.w	obY(a0),d0
		addi.w	#$40,d0
		cmpi.w	#$68,d0
		bcc.w	@donothing

		sfx	sfx_Lamppost	; play lamppost sound
		addq.b	#2,obRoutine(a0)
		jsr	(FindFreeObj).l
		bne.s	@fail
		move.b	#$79,0(a1)	; load twirling	lamp object
		move.b	#6,obRoutine(a1) ; goto Lamp_Twirl next
		move.w	obX(a0),lamp_origX(a1)
		move.w	obY(a0),lamp_origY(a1)
		subi.w	#$18,lamp_origY(a1)
		move.l	#Map_Lamp,obMap(a1)
		move.w	#($D800/$20),obGfx(a1) ; +++ was #$7A0,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#8,obActWid(a1)
		move.w	#$200,obPriority(a1)
		move.b	#2,obFrame(a1)	; use "ball only" frame
		move.w	#$20,lamp_time(a1)

		cmpi.w	#20,(v_rings).w
		blo.s	@fail
		bsr.w	Obj79_MakeSpecialStars

	@fail:
		move.b	#1,obFrame(a0)	; use "post only" frame
		bsr.w	Lamp_StoreInfo
        if S3KObjectManager=1
                move.w	obRespawnNo(a0),d0	; get address in respawn table
	        movea.w	d0,a2	; load address into a2
	        bset	#0,(a2)
        else
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		bset	#0,2(a2,d0.w)
        endif
	@donothing:
		rts	
; ===========================================================================

Lamp_Finish:	; Routine 4
		rts	
; ===========================================================================

Lamp_Twirl:	; Routine 6
		subq.w	#1,lamp_time(a0) ; decrement timer
		bpl.s	@continue	; if time remains, keep twirling
		move.b	#4,obRoutine(a0) ; goto Lamp_Finish next

	@continue:
		move.b	obAngle(a0),d0
		subi.b	#$10,obAngle(a0)
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	#$C00,d1
		swap	d1
		add.w	lamp_origX(a0),d1
		move.w	d1,obX(a0)
		muls.w	#$C00,d0
		swap	d0
		add.w	lamp_origY(a0),d0
		move.w	d0,obY(a0)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	store information when you hit a lamppost
; ---------------------------------------------------------------------------

Lamp_StoreInfo:
		move.b	obSubtype(a0),(v_lastlamp).w 	; lamppost number
Lamp_StoreInfo2:
		move.b	(v_lastlamp).w,($FFFFFE31).w
		move.w	obX(a0),($FFFFFE32).w		; x-position
		move.w	obY(a0),($FFFFFE34).w		; y-position
	;	cmpi.b  #1,(v_lastlamp).w
	;	bne.s   @skip
		move.w	(v_rings).w,($FFFFFE36).w 	; rings
		move.b	(v_lifecount).w,($FFFFFE54).w 	; lives
		move.l	(v_time).w,($FFFFFE38).w 	; time
		move.b	(v_dle_routine).w,($FFFFFE3C).w ; routine counter for dynamic level mod
		move.w	(v_limitbtm2).w,($FFFFFE3E).w 	; lower y-boundary of level
		move.w	(v_screenposx).w,($FFFFFE40).w 	; screen x-position
		move.w	(v_screenposy).w,($FFFFFE42).w 	; screen y-position
; 		move.w	($FFFFF708).w,($FFFFFE44).w 	; bg position
; 		move.w	($FFFFF70C).w,($FFFFFE46).w 	; bg position
; 		move.w	($FFFFF710).w,($FFFFFE48).w 	; bg position
; 		move.w	($FFFFF714).w,($FFFFFE4A).w 	; bg position
; 		move.w	($FFFFF718).w,($FFFFFE4C).w 	; bg position
; 		move.w	($FFFFF71C).w,($FFFFFE4E).w 	; bg position
		move.w	(v_waterpos2).w,($FFFFFE50).w 	; water height
		move.b	(v_wtr_routine).w,($FFFFFE52).w ; rountine counter for water
		move.b	(f_wtr_state).w,($FFFFFE53).w 	; water direction
		jsr     SaveState
	@skip:
                rts

; ---------------------------------------------------------------------------
; Subroutine to	load stored info when you start	a level	from a lamppost
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Lamp_LoadInfo:				; XREF: LevelSizeLoad
		move.b	($FFFFFE31).w,(v_lastlamp).w
		move.w	($FFFFFE32).w,(v_player+obX).w
		move.w	($FFFFFE34).w,(v_player+obY).w
		move.w	($FFFFFE36).w,(v_rings).w
		move.b	($FFFFFE54).w,(v_lifecount).w
;		clr.w	(v_rings).w
                move.w  (v_lamp_rings).w,(v_rings).w ; +++ restore number of rings
;		clr.b	(v_lifecount).w
		move.b	($FFFFFE54).w,(v_lifecount).w 	; lives
		move.l	($FFFFFE38).w,(v_time).w
		move.b	#59,(v_timecent).w
		subq.b	#1,(v_timesec).w
		move.b	($FFFFFE3C).w,(v_dle_routine).w
		move.b	($FFFFFE52).w,(v_wtr_routine).w
		move.w	($FFFFFE3E).w,(v_limitbtm2).w
		move.w	($FFFFFE3E).w,(v_limitbtm1).w
		move.w	($FFFFFE40).w,(v_screenposx).w
		move.w	($FFFFFE42).w,(v_screenposy).w
;		move.w	($FFFFFE44).w,($FFFFF708).w
;		move.w	($FFFFFE46).w,($FFFFF70C).w
;		move.w	($FFFFFE48).w,($FFFFF710).w
;		move.w	($FFFFFE4A).w,($FFFFF714).w
;		move.w	($FFFFFE4C).w,($FFFFF718).w
;		move.w	($FFFFFE4E).w,($FFFFF71C).w
		cmpi.b	#1,(v_zone).w	; is this Labyrinth Zone?
		bne.s	@notlabyrinth	; if not, branch

; 		move.w	($FFFFFE50).w,(v_waterpos2).w
; 		move.b	($FFFFFE52).w,(v_wtr_routine).w
; 		move.b	($FFFFFE53).w,(f_wtr_state).w
                nop
	@notlabyrinth:
; 		tst.b	(v_shield).w	        ; does Sonic have shield?
; 		beq.s	@notshield		; if not, branch
; 		move.b	#1,(v_shield).w	        ; give Sonic a shield
; 		move.b	#2,(v_shieldobj+obAnim).w ; load shield object

           @notshield:
		tst.b	(v_invinc).w	; does Sonic have invincibility?
		beq.s	@notinvinc		; if not, branch
		move.b	#1,(v_invinc).w	; make Sonic invincible
		tst.b	(f_supersonic).w	; is Sonic super?
		bne.s	@notinvinc		; if so, branch
		move.w	#$258,(v_player+$32).w ; time limit for the power-up
		move.b	#id_InvincibilityStars,(v_objspace+$200).w ; load stars object ($3801)

          @notinvinc:
                tst.b	(v_shoes).w	          ; does Sonic have speed shoes?
		beq.s	@notshoes		  ; if not, branch
          	move.b	#1,(v_shoes).w	          ; speed up the BG music
		move.w	#$258,(v_player+$34).w	  ; time limit for the power-up
                jsr     SetStatEffects
; 		move.w	#$C00,(v_sonspeedmax).w   ; change Sonic's top speed
; 		move.w	#$18,(v_sonspeedacc).w	  ; change Sonic's acceleration
; 		move.w	#$80,(v_sonspeeddec).w	  ; change Sonic's deceleration
		music	$E2,1		          ; Speed up the music

          @notshoes:
		tst.b	(v_lastlamp).w
		bpl.s	locret_170F6
		move.w	($FFFFFE32).w,d0
		subi.w	#$A0,d0
		move.w	d0,(v_limitleft2).w
                
	@skip:

locret_170F6:
		rts	


; loc_1F4C4:
Obj79_MakeSpecialStars:
	moveq	#4-1,d1 		; execute the loop 4 times (1 for each star)
	moveq	#0,d2
	lea     lamp_child1(a0),a3

@starloop:
	jsr	FindFreeObj
	bne.s	@rts			; rts
	move.b	0(a0),0(a1) 		; load obj79
	move.w  a0,star_parent(a1)	; make child remember parent object
	move.w  a1,(a3)+		; remember child object
	move.l	#Map_LampStars,obMap(a1)
	move.w	#$26C0,obGfx(a1)
	move.b	#4,obRender(a1)
	move.b	#8,obRoutine(a1) 	; => Obj79_Star
	move.w	obX(a0),d0
	move.w	d0,obX(a1)
	move.w	d0,objoff_30(a1)
	move.w	obY(a0),d0
	subi.w	#$30,d0
	move.w	d0,obY(a1)
	move.w	d0,objoff_32(a1)
	move.w	obPriority(a0),obPriority(a1)
	move.b	#8,obActWid(a1)
	move.b	#1,obFrame(a1)
	move.w	#-$400,obVelX(a1)
	move.w	#0,obVelY(a1)
	move.w	d2,objoff_34(a1) ; set the angle
	addi.w	#$40,d2 ; increase the angle for next time
	dbf	d1,@starloop ; loop
@rts:
	rts
; ===========================================================================
; loc_1F536:
objoff_32  =  $32

Obj79_Star:
	move.b	obColProp(a0),d0
	beq.w	loc_1F554
	andi.b	#1,d0
	beq.s	@no_coll

	sfx	$66

	movea.w star_parent(a0),a2		; get parent object
	lea     lamp_child1(a2),a2		; get first child star
	moveq   #3,d2				; delete 4 star objects
@deletestar:
	movea.w (a2)+,a1			; move star object's address into a1
	jsr   	DeleteChild			; delete object
	dbf     d2,@deletestar			; loop

        movem.l	d0-a6,-(sp)                   	; save registers to stack
	jsr	PaletteWhiteOut
        jsr     SaveState			; save level's state	
        moveq   #0,d0                      	; save slot 1
        jsr     SaveGame			; save game
	jsr	BuildSprites
	jsr	PaletteWhiteIn
	movem.l	(sp)+,d0-a6                 	; restore registers from stack

	lea	HUD_Text_GameSaved,a2
	jmp	CreateHudPopup

@no_coll:
	clr.b	obColProp(a0)

loc_1F554:
	addi.w	#$A,objoff_34(a0)
	move.w	objoff_34(a0),d0
	andi.w	#$FF,d0
	jsr	(CalcSine).l
	asr.w	#5,d0
	asr.w	#3,d1
	move.w	d1,d3
	move.w	objoff_34(a0),d2
	andi.w	#$3E0,d2
	lsr.w	#5,d2
	moveq	#2,d5
	moveq	#0,d4
	cmpi.w	#$10,d2
	ble.s	@skip
	neg.w	d1
@skip:
	andi.w	#$F,d2
	cmpi.w	#8,d2
	ble.s	loc_1F594
	neg.w	d2
	andi.w	#7,d2

loc_1F594:
	lsr.w	#1,d2
	beq.s	@skip
	add.w	d1,d4
@skip:
	asl.w	#1,d1
	dbf	d5,loc_1F594

	asr.w	#4,d4
	add.w	d4,d0
	addq.w	#1,objoff_36(a0)
	move.w	objoff_36(a0),d1
	cmpi.w	#$80,d1
	beq.s	loc_1F5BE
	bgt.s	loc_1F5C4

loc_1F5B4:
	muls.w	d1,d0
	muls.w	d1,d3
	asr.w	#7,d0
	asr.w	#7,d3
	bra.s	loc_1F5D6
; ===========================================================================

loc_1F5BE:
	move.b	#$D8,obColType(a0)

loc_1F5C4:
	cmpi.w	#$180,d1
	ble.s	loc_1F5D6
	neg.w	d1
	addi.w	#$200,d1
	bmi.w	JmpTo10_DeleteObject
	bra.s	loc_1F5B4
; ===========================================================================

loc_1F5D6:
	move.w	objoff_30(a0),d2
	add.w	d3,d2
	move.w	d2,obX(a0)
	move.w	objoff_32(a0),d2
	add.w	d0,d2
	move.w	d2,obY(a0)
	addq.b	#1,obAniFrame(a0)
	move.b	obAniFrame(a0),d0
	andi.w	#6,d0
	lsr.w	#1,d0
	cmpi.b	#3,d0
	bne.s	@skip
	moveq	#1,d0
@skip:
	move.b	d0,obFrame(a0)
	rts
; ===========================================================================
JmpTo10_DeleteObject 
	jmp	(DeleteObject).l
; ===========================================================================
	include  "_maps/Lamppost Stars.asm"

	align 4