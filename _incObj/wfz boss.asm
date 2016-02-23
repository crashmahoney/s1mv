; ===========================================================================
; ----------------------------------------------------------------------------
; Object C5 - WFZ boss
; ----------------------------------------------------------------------------
; Sprite_3C442:
ObjC5_Timer    = $2A    ;                                      word
objoff_2C      = $2C    ;                                      word
objoff_2E      = $2E    ;                                      word
objoff_2F      = $2F	; makes lazer wall "flash" if set it won't flash   byte
objoff_30      = $30    ; some timer                           word
objoff_34      = $34    ; Case Max Left position               word
objoff_36      = $36    ; Case Max Right position              word
objoff_38      = $38    ;                                      word
objoff_3C      = $3C    ;                                      word
objoff_3E      = $3E    ;                                      word
wfz_parent     = $3E
WFZBoss:
	moveq	#0,d0
	move.b	obRoutine(a0),d0
	move.w	ObjC5_Index(pc,d0.w),d1
	jmp	ObjC5_Index(pc,d1.w)
; ===========================================================================
ObjC5_Index:
		dc.w ObjC5_Init-ObjC5_Index			;   0 - Main loading sequence
		dc.w ObjC5_LaserCase-ObjC5_Index		;   2 - Laser case (inside is laser)
		dc.w ObjC5_LaserWall-ObjC5_Index		;   4 - Laser wall
		dc.w ObjC5_PlatformReleaser-ObjC5_Index	        ;   6 - Platform releaser
		dc.w ObjC5_Platform-ObjC5_Index		        ;   8 - Platform
		dc.w ObjC5_PlatformHurt-ObjC5_Index		;  $A - Invisible object that gets the platform's spikes to hurt sonic
		dc.w ObjC5_LaserShooter-ObjC5_Index		;  $C - Laser shooter
		dc.w ObjC5_Laser-ObjC5_Index			;  $E - Laser
; 		dc.w ObjC5_Robotnik-ObjC5_Index		        ; $10 - Robotnik
; 		dc.w ObjC5_RobotnikPlatform-ObjC5_Index	        ; $12 - Platform Robotnik's on
; ===========================================================================

ObjC5_Init:
	bsr.w	LoadSubObject
	move.b	obSubtype(a0),d0
;	subi.b	#$90,d0
	move.b	d0,obRoutine(a0)
	rts
; ===========================================================================

ObjC5_LaserCase:	; also the "mother" object
	moveq	#0,d0
	move.b	ob2ndRout(a0),d0
	move.w	ObjC5_CaseIndex(pc,d0.w),d1
	jsr	ObjC5_CaseIndex(pc,d1.w)
	bra.w	ObjC5_HandleHits
; ===========================================================================
ObjC5_CaseIndex:
		dc.w ObjC5_CaseBoundary-ObjC5_CaseIndex		;   0 - Sets up boundaries for movement and basic things
		dc.w ObjC5_CaseWaitStart-ObjC5_CaseIndex	;   2 - Waits for sonic to start
		dc.w ObjC5_CaseWaitDown-ObjC5_CaseIndex		;   4 - Waits to make the laser go down
		dc.w ObjC5_CaseDown-ObjC5_CaseIndex		;   6 - Moves the case down
		dc.w ObjC5_CaseXSpeed-ObjC5_CaseIndex		;   8 - Sets an X speed for the case
		dc.w ObjC5_CaseBoundaryChk-ObjC5_CaseIndex	;  $A - Checks to make sure the case doesn't go through the boundaries
		dc.w ObjC5_CaseAnimate-ObjC5_CaseIndex		;  $C - Animates the case (opening and closing)
		dc.w ObjC5_CaseLSLoad-ObjC5_CaseIndex		;  $E - Laser shooter loading
		dc.w ObjC5_CaseLSDown-ObjC5_CaseIndex		; $10 - Moves the laser shooter down
		dc.w ObjC5_CaseWaitLoadLaser-ObjC5_CaseIndex	; $12 - Waits to load the laser
		dc.w ObjC5_CaseWaitMove-ObjC5_CaseIndex		; $14 - Waits to move (checks if laser is completely loaded (as big as it gets))
		dc.w ObjC5_CaseBoundaryLaserChk-ObjC5_CaseIndex	; $16 - Checks boundaries when moving with the laser
		dc.w ObjC5_CaseLSUp-ObjC5_CaseIndex		; $18 - wait for laser shooter to go back up
		dc.w ObjC5_CaseAnimate-ObjC5_CaseIndex		; $1A - Animates the case (opening and closing)
		dc.w ObjC5_CaseStartOver-ObjC5_CaseIndex	; $1C - Sets secondary routine to 8
		dc.w ObjC5_CaseDefeated-ObjC5_CaseIndex		; $1E - When defeated goes here (explosions and stuff)
; ===========================================================================

ObjC5_CaseBoundary:
	addq.b	#2,ob2ndRout(a0)
	move.b	#0,obColType(a0)
	move.b	#8,obColProp(a0)	; Hit points
	move.w	obY(a0),d0
	subq    #8,d0                   ; set screen limit at just above boss object
	move.w	d0,(v_limitbtm1).w
	move.w	d0,(v_limittop1).w
	move.w	obX(a0),d0
	subi.w	#$60,d0			; Max Left position
	move.w	d0,objoff_34(a0)
	addi.w	#$C0,d0			; Max Right Position
	move.w	d0,objoff_36(a0)

	lea     (WFZBoss_Pal).l,a2
	lea		(v_pal1_wat+$20).w,a1
	moveq	#$F,d0                         ; move 16 colours
  @movecolour:
	move.w	(a2)+,(a1)+                    ; load colour stored in d0
    dbf     d0,@movecolour

	moveq	#plcid_WFZBoss,d0
	jsr		AddPLC		        ; load boss patterns

	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseWaitStart:
	bsr.w	Obj_GetOrientationToPlayer
	addi.w	#$20,d2
	cmpi.w	#$40,d2			; How far away sonic is to start the boss
	blo.s	ObjC5_CaseStart
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseStart:
	addq.b	#2,ob2ndRout(a0)
	move.w	#$40,obVelY(a0)		; Speed at which the laser carrier goes down
	lea	(ObjC5_LaserWallData).l,a2
	bsr.w	LoadChildObject
	subi.w	#$88,obX(a1)		; where to load the left laser wall (x)
	addi.w	#$60,obY(a1)		; left laser wall (y)
	lea	(ObjC5_LaserWallData).l,a2
	bsr.w	LoadChildObject
	addi.w	#$88,obX(a1)		; right laser wall (x)
	addi.w	#$60,obY(a1)		; right laser wall (y)
	lea	(ObjC5_LaserShooterData).l,a2
	bsr.w	LoadChildObject
	lea	(ObjC5_PlatformReleaserData).l,a2
	bsr.w	LoadChildObject
; 	lea	(ObjC5_RobotnikData).l,a2
; 	bsr.w	LoadChildObject
	move.w	#$5A,ObjC5_Timer(a0)	; How long for the boss music to start playing and the boss to start
	move.b	#musFadeOut,d0
	jsr	PlaySound_Special ; stop music
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseWaitDown:
	subq.w	#1,ObjC5_Timer(a0)
	bmi.s	ObjC5_CaseSpeedDown
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseSpeedDown:
	addq.b	#2,ob2ndRout(a0)
	move.w	#$60,ObjC5_Timer(a0)	; How long the laser carrier goes down
	moveq	#bgm_Boss,d0
	jsr	PlaySound
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseDown:
	subq.w	#1,ObjC5_Timer(a0)
	beq.s	ObjC5_CaseStopDown
	bsr.w	SpeedToPos
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseStopDown:
	addq.b	#2,ob2ndRout(a0)
	clr.w	obVelY(a0)		; stop the laser carrier from going down
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseXSpeed:
	addq.b	#2,ob2ndRout(a0)
	bsr.w	Obj_GetOrientationToPlayer
	move.w	#$100,d1		; Speed of carrier (when going back and forth before sending out laser)
	tst.w	d0
	bne.s	ObjC5_CasePMLoader
	neg.w	d1

ObjC5_CasePMLoader:
	move.w	d1,obVelX(a0)
	bset	#2,obStatus(a0)		; makes the platform maker load
	move.w	#$70,ObjC5_Timer(a0)	; how long to go back and forth before letting out laser
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseBoundaryChk:			; waits and makes sure the carrier does not go beyond the limit
	subq.w	#1,ObjC5_Timer(a0)
	bmi.s	ObjC5_CaseOpeningAnim
	move.w	obX(a0),d0
	tst.w	obVelX(a0)
	bmi.s	ObjC5_CaseBoundaryChk2
	cmp.w	objoff_36(a0),d0
	bhs.s	ObjC5_CaseNegSpeed
	bra.w	ObjC5_CaseMoveDisplay
; ===========================================================================

ObjC5_CaseBoundaryChk2:
	cmp.w	objoff_34(a0),d0
	bhs.s	ObjC5_CaseMoveDisplay

ObjC5_CaseNegSpeed:
	neg.w	obVelX(a0)

ObjC5_CaseMoveDisplay:
	bsr.w	SpeedToPos
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseOpeningAnim:
	addq.b	#2,ob2ndRout(a0)
	clr.b	obAnim(a0)
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseAnimate:
	lea	(Ani_objC5).l,a1
	jsr	AnimateSprite
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseLSLoad:		; loads up the laser shooter (LS)
	addq.b	#2,ob2ndRout(a0)
	move.w	#$E,ObjC5_Timer(a0)	; Time the laser shooter moves down
	movea.w	objoff_3C(a0),a1 ; a1=object (laser shooter)
	move.b	#4,ob2ndRout(a1)
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseLSDown:
	subq.w	#1,ObjC5_Timer(a0)
	beq.s	ObjC5_CaseAddCollision
	movea.w	objoff_3C(a0),a1 ; a1=object (laser shooter)
	addq.w	#1,obY(a1)	; laser shooter down speed
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseAddCollision:
	addq.b	#2,ob2ndRout(a0)
	move.w	#$40,ObjC5_Timer(a0)	; Length before shooting laser
	bset	#4,obStatus(a0)		; makes the hit sound and flashes happen only once when you hit it
	bset	#6,obStatus(a0)		; makes sure collision gets restored
	move.b	#6,obColType(a0)
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseWaitLoadLaser:
	subq.w	#1,ObjC5_Timer(a0)
	bmi.s	ObjC5_CaseLoadLaser
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseLoadLaser:
	addq.b	#2,ob2ndRout(a0)
	lea	(ObjC5_LaserData).l,a2	
	bsr.w	LoadChildObject		; loads laser
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseWaitMove:
	movea.w	wfz_parent(a0),a1 ; a1=object
	btst	#2,obStatus(a1)		; waits to check if laser fired
	bne.s	ObjC5_CaseLaserSpeed
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseLaserSpeed:
	addq.b	#2,ob2ndRout(a0)
	move.w	#$80,ObjC5_Timer(a0)	; how long to move the laser
	bsr.w	Obj_GetOrientationToPlayer	; tests if sonic is to the right or left
	move.w	#$80,d1		; Speed when moving with laser
	tst.w	d0
	bne.s	ObjC5_CaseLaserSpeedSet
	neg.w	d1

ObjC5_CaseLaserSpeedSet:
	move.w	d1,obVelX(a0)
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseBoundaryLaserChk:		; make sure you stay in range when firing laser
	subq.w	#1,ObjC5_Timer(a0)
	bmi.s	ObjC5_CaseStopLaserDelete
	move.w	obX(a0),d0
	tst.w	obVelX(a0)
	bmi.s	ObjC5_CaseBoundaryLaserChk2
	cmp.w	objoff_36(a0),d0
	bhs.s	ObjC5_CaseLaserStopMove
	bra.w	ObjC5_CaseLaserMoveDisplay
; ===========================================================================

ObjC5_CaseBoundaryLaserChk2:
	cmp.w	objoff_34(a0),d0
	bhs.s	ObjC5_CaseLaserMoveDisplay

ObjC5_CaseLaserStopMove:
	clr.w	obVelX(a0)	; stop moving

ObjC5_CaseLaserMoveDisplay:
	bsr.w	SpeedToPos
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseStopLaserDelete:		; stops collision and deletes laser
	addq.b	#2,ob2ndRout(a0)
	move.w	#$E,ObjC5_Timer(a0)	; time for laser shooter to move back up
	bclr	#3,obStatus(a0)
	bclr	#4,obStatus(a0)
	bclr	#6,obStatus(a0)
	clr.b	obColType(a0)	; no more collision
	movea.w	wfz_parent(a0),a1 		; a1=object (laser)
	bsr.w	DeleteChild	; delete the laser
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseLSUp:
	subq.w	#1,ObjC5_Timer(a0)
	beq.s	ObjC5_CaseClosingAnim
	movea.w	objoff_3C(a0),a1 ; a1=object (laser shooter)
	subq.w	#1,obY(a1)
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseClosingAnim: ;sets which animation to do 
	addq.b	#2,ob2ndRout(a0)
	move.b	#1,obAnim(a0)
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseStartOver:
	move.b	#8,ob2ndRout(a0)
	bsr.w	ObjC5_CaseXSpeed
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_CaseDefeated:
	clr.b	obColType(a0)
	st	obColProp(a0)
	bclr	#6,obStatus(a0)
	subq.w	#1,objoff_30(a0)	; timer
	bmi.s	ObjC5_End
	bsr.w	BossDefeated
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_End:	; play music and change camera speed
	moveq	#bgm_GHZ,d0
	jsr		PlaySound
;	move.w	#$720,d0
	move.w	#$0,(v_limittop1).w
	move.w	#$710,(v_limitbtm1).w
	bsr.w	DeleteObject
	addq.w	#4,sp
ObjC5_rts:
	rts
; ===========================================================================

ObjC5_LaserWall:
	tst.b	(a0)
	beq.w	ObjC5_rts
	move.b	#$C,obFrame(a0)	; loads the laser wall from the WFZ boss art
	move.w	#$13,d1          ; width
	move.w	#$40,d2          ; height1
	move.w	#$80,d3          ; height2
	move.w	obX(a0),d4
	bsr.w	SolidObject
;         move.w  (v_player+obX).w,d0
;         cmp.w   obX(a0),d0
;         blt.s   @checkdefeated
;         sub.w   obX(a0),d0              ; get difference between wall and sonic
;         cmpi.w  #$200,d0
;         blt.s   @drawwall               ; if it's less than $100 then keep wall
;         bra.w   DeleteObject            ; otherwise delete it
    @checkdefeated:
	movea.w	objoff_2C(a0),a1 ; a1=parent object
	btst	#5,obStatus(a1)
	bne.s	ObjC5_LaserWallDelete
        tst.b   objoff_34(a0)
        bne.s   ObjC5_LaserWallDelete
	move.b	#4,objoff_30(a0)        ; sets a small timer, doesn't count down until boss defeated
    @drawwall:
	bchg	#0,objoff_2F(a0)	; makes it "flash" if set it won't flash
	bne.w	ObjC5_rts
	bra.w	DisplaySprite
; ===========================================================================
ObjC5_LaserWallDelete:
        move.b  #1,objoff_34(a0)        ; set flag to delete
	subq.b	#1,obTimeFrame(a0)
	bpl.w	ObjC5_rts
	move.b	obTimeFrame(a0),d0
	move.b	obAniFrame(a0),d1
	addq.b	#2,d0
	bpl.s	ObjC5_LaserWallDisplay
	move.b	d1,obTimeFrame(a0)
	subq.b	#1,objoff_30(a0)
	bpl.s	ObjC5_LaserWallDisplay
	move.b	#$10,objoff_30(a0)
	addq.b	#1,d1
	cmpi.b	#5,d1
	bhs.w	ObjC5_LoadLvlGFXandDelete
	move.b	d1,obAniFrame(a0)
	move.b	d1,obTimeFrame(a0)

ObjC5_LaserWallDisplay:
	bclr	#0,objoff_2F(a0)
	bra.w	DisplaySprite

ObjC5_LoadLvlGFXandDelete:
	moveq	#plcid_GHZ2,d0
	jsr		NewPLC		        ; load level object patterns
	moveq	#plcid_Explode,d0
	jsr		(AddPLC).l			; load explosion patterns
	lea     (Pal_GHZ).l,a2
	lea		(v_pal1_wat+$20).w,a1
 	moveq	#$F,d0                         ; move 16 colours
    @movecolour:
 	move.w	(a2)+,(a1)+
	dbf     d0,@movecolour
	bra.w   DeleteObject
; ===========================================================================

ObjC5_PlatformReleaser:
	moveq	#0,d0
	move.b	ob2ndRout(a0),d0
	move.w	ObjC5_PlatformReleaserIndex(pc,d0.w),d1
	jmp	ObjC5_PlatformReleaserIndex(pc,d1.w)
; ===========================================================================
ObjC5_PlatformReleaserIndex:
	dc.w ObjC5_PlatformReleaserInit-ObjC5_PlatformReleaserIndex		; 0 - Load mappings and position
	dc.w ObjC5_PlatformReleaserWaitDown-ObjC5_PlatformReleaserIndex	        ; 2 - Waits for laser case to move down
	dc.w ObjC5_PlatformReleaserDown-ObjC5_PlatformReleaserIndex		; 4 - Goes down until time limit is up
	dc.w ObjC5_PlatformReleaserLoadWait-ObjC5_PlatformReleaserIndex	        ; 6 - Waits to load the platforms (the interval of time between each is from this) and makes sure only 3 are loaded
	dc.w ObjC5_PlatformReleaserDelete-ObjC5_PlatformReleaserIndex		; 8 - Explodes then deletes
; ===========================================================================

ObjC5_PlatformReleaserInit:
	addq.b	#2,ob2ndRout(a0)
	move.b	#5,obFrame(a0)
	addq.w	#8,obY(a0)		; Move down a little
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_PlatformReleaserWaitDown:
	movea.w	objoff_2C(a0),a1 ; a1=object laser case
	btst	#2,obStatus(a1)		; checks if laser case is done moving down (so it starts loading the platforms)
	bne.s	ObjC5_PlatformReleaserSetDown
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_PlatformReleaserSetDown:
	addq.b	#2,ob2ndRout(a0)
	move.w	#$40,ObjC5_Timer(a0)	; time to go down
	move.w	#$40,obVelY(a0)		; speed to go down
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_PlatformReleaserDown:
	subq.w	#1,ObjC5_Timer(a0)
	beq.s	ObjC5_PlatformReleaserStop
	bsr.w	SpeedToPos
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_PlatformReleaserStop:
	addq.b	#2,ob2ndRout(a0)
	clr.w	obVelY(a0)
	move.w	#$10,ObjC5_Timer(a0)
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_PlatformReleaserLoadWait:
	movea.w	objoff_2C(a0),a1 ; a1=object
	btst	#5,obStatus(a1)
	bne.s	ObjC5_PlatformReleaserDestroyP
	subq.w	#1,ObjC5_Timer(a0)
	bne.s	BranchTo8_DisplaySprite
	move.w	#$80,ObjC5_Timer(a0)	; Time between loading platforms
	moveq	#0,d0
	move.b	objoff_2E(a0),d0
	addq.b	#1,d0
	cmpi.b	#3,d0			; How many platforms to load
	blo.s	ObjC5_PlatformReleaserLoadP
	moveq	#0,d0

ObjC5_PlatformReleaserLoadP:	; P=Platforms
	move.b	d0,objoff_2E(a0)
	tst.b	$30(a0,d0.w)
	bne.s	BranchTo8_DisplaySprite
	st	$30(a0,d0.w)
	lea	(ObjC5_PlatformData).l,a2
	bsr.w	LoadChildObject
	move.b	objoff_2E(a0),objoff_2E(a1)

BranchTo8_DisplaySprite:
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_PlatformReleaserDestroyP: 	; P=Platforms
	addq.b	#2,ob2ndRout(a0)
	bset	#5,obStatus(a0)		; destroy platforms
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_PlatformReleaserDelete:
	movea.w	objoff_2C(a0),a1 ; a1=object
	cmpi.b	#$C5,(a1)
	bne.w	DeleteObject
	bsr.w	BossDefeated
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_Platform:          ; routine $8
	moveq	#0,d0
	move.b	ob2ndRout(a0),d0
	move.w	ObjC5_PlatformIndex(pc,d0.w),d1
	jsr	ObjC5_PlatformIndex(pc,d1.w)
	lea	(Ani_objC5).l,a1
	jsr	AnimateSprite
	tst.b	(a0)
	beq.w	ObjC5_rts
	bra.w	DisplaySprite
; ===========================================================================
ObjC5_PlatformIndex: 
	dc.w ObjC5_PlatformInit-ObjC5_PlatformIndex			; 0 - Selects mappings, anim ation, y speed and loads the object that hurts sonic (by spiky area)
	dc.w ObjC5_PlatformDownWait-ObjC5_PlatformIndex		        ; 2 - Wait till the platform goes down some
	dc.w ObjC5_PlatformTestChangeDirection-ObjC5_PlatformIndex	; 4 - checks if time limit is over and if so to change direction
; ===========================================================================

ObjC5_PlatformInit:
	addq.b	#2,ob2ndRout(a0)
	move.b	#3,obAnim(a0)
	move.b	#7,obFrame(a0)
	move.w	#$100,obVelY(a0)			; Y speed
	move.w	#$60,ObjC5_Timer(a0)
	lea	(ObjC5_PlatformHurtData).l,a2	; loads the invisible object that hurts sonic
	bra.w	LoadChildObject
; ===========================================================================

ObjC5_PlatformDownWait:		; waits for it to go down some
	bsr.w	ObjC5_PlatformCheckExplode
	subq.w	#1,ObjC5_Timer(a0)
	beq.s	ObjC5_PlatformLeft
	bra.w	ObjC5_PlatformMakeSolid
; ===========================================================================

ObjC5_PlatformLeft:			; goes left and makes a time limit (for going left)
	addq.b	#2,ob2ndRout(a0)
	move.w	#$60,ObjC5_Timer(a0)
	move.w	#-$100,obVelX(a0)		; X speed
	move.w	obY(a0),objoff_34(a0)
	bra.w	ObjC5_PlatformMakeSolid
; ===========================================================================

ObjC5_PlatformTestChangeDirection:
	bsr.w	ObjC5_PlatformCheckExplode
	subq.w	#1,ObjC5_Timer(a0)
	bne.s	ObjC5_PlatformTestLeftRight
	move.w	#$C0,ObjC5_Timer(a0)
	neg.w	obVelX(a0)

ObjC5_PlatformTestLeftRight:	; tests to see if a value should be added to go left or right
	moveq	#4,d0
	move.w	obY(a0),d1
	cmp.w	objoff_34(a0),d1
	blo.s	ObjC5_PlatformChangeY
	neg.w	d0

ObjC5_PlatformChangeY:	; give it that curving feel
	add.w	d0,obVelY(a0)
;	bra.w	ObjC5_PlatformMakeSolid
; --------------------------------------------------------------------------
ObjC5_PlatformMakeSolid:	; makes into a platform and moves
	lea	(v_player).w,a1
	move.w	#$10,d1
	btst	#3,obStatus(a0)       ; is sonic already on platform?
	beq.w	PlatformObject2       ; if not, branch

@exitplatform:
	move.w	d1,d2
	add.w	d2,d2
	btst	#1,obStatus(a1)       ; is sonic in the air?
	bne.s	@offplatform
	move.w	obX(a1),d0
	sub.w	obX(a0),d0
	add.w	d1,d0
	bmi.s	@offplatform
	cmp.w	d2,d0
	bcs.s	@movesonic
@offplatform:
	bclr	#3,obStatus(a1)
	bclr	#3,obStatus(a0)
;        rts

@movesonic:
	move.w	obX(a0),-(sp)
        bsr.w   SpeedToPos
	move.w	(sp)+,d2
        jmp     MvSonicOnPtfm2           ; make Sonic move with the platform
; --------------------------------------------------------------------------
    ; below is a copy of some of the PlatformObject routine.
    ; sonic 1's version messes with the platfom routines in
    ; a way which breaks this object
PlatformObject2:
        bsr.w   SpeedToPos
	tst.w	obVelY(a1)	; is Sonic moving up/jumping?
	bmi.w	@rts	; if yes, branch

;	perform x-axis range check
	move.w	obX(a1),d0
	sub.w	obX(a0),d0
	add.w	d1,d0
	bmi.w	@rts
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.w	@rts

	move.w	obY(a0),d0
	subq.w	#8,d0
;	perform y-axis range check
        move.w	obY(a1),d2
	move.b	obWidth(a1),d1                ; height
	ext.w	d1
	add.w	d2,d1
	addq.w	#4,d1
	sub.w	d1,d0
	bhi.w	@rts
	cmpi.w	#-$10,d0
	bcs.w	@rts

	tst.b	(f_lockmulti).w
	bmi.w	@rts
	cmpi.b	#6,obRoutine(a1)
	bcc.w	@rts
	add.w	d0,d2
	addq.w	#3,d2
	move.w	d2,obY(a1)
	btst	#3,obStatus(a1)
	bne.s	@skip
	jsr     loc_74DC          ; jump to the end of the proper platform routine
@skip:
	moveq	#0,d0
	move.b	$3D(a1),d0
	lsl.w	#6,d0
	addi.l	#v_objspace&$FFFFFF,d0
	movea.l	d0,a2
	bclr	#3,obStatus(a2)
	jsr     loc_74DC          ; jump to the end of the proper platform routine
@rts:
		rts
; ===========================================================================

ObjC5_PlatformCheckExplode:	; checks to see if platforms should explode
	movea.w	objoff_2C(a0),a1 ; a1=object
	btst	#5,obStatus(a1)
	bne.w	ObjC5_PlatformExplode
	rts
; ===========================================================================

ObjC5_PlatformExplode:
	bsr.w	loc_3B7BC
	move.b	#id_ExplosionBomb,(a0) ; load 0bj58 (explosion)
	clr.b	obRoutine(a0)
	movea.w	objoff_3C(a0),a1 ; a1=object (invisible hurting thing)
	bsr.w	DeleteChild
	addq.w	#4,sp
	rts
; ===========================================================================

ObjC5_PlatformHurt:      ; Routine $A
	moveq	#0,d0
	move.b	ob2ndRout(a0),d0
	move.w	ObjC5_PlatformHurtIndex(pc,d0.w),d1
	jmp	ObjC5_PlatformHurtIndex(pc,d1.w)
; ===========================================================================
ObjC5_PlatformHurtIndex:
	dc.w ObjC5_PlatformHurtCollision-ObjC5_PlatformHurtIndex		; 0 - Gives collision that hurts sonic
	dc.w ObjC5_PlatformHurtFollowPlatform-ObjC5_PlatformHurtIndex	        ; 2 - Follows around the platform and waits to be deleted
; ===========================================================================

ObjC5_PlatformHurtCollision:
	addq.b	#2,ob2ndRout(a0)
	move.b	#$98,obColType(a0)
	move.l  #ObjC5_Blank,obMap(a0)                   ; this had no frame in s2, but collision won't work without it here
	rts
; ===========================================================================

ObjC5_PlatformHurtFollowPlatform:
	movea.w	objoff_2C(a0),a1 ; a1=object (platform)
	btst	#5,obStatus(a1)
	bne.w	DeleteObject
	move.w	obX(a1),obX(a0)
	move.w	obY(a1),d0
	addi.w	#$C,d0
	move.w	d0,obY(a0)
	jsr     DisplaySprite                            ; this doesn't display anything but it's needed for collision to work
	rts
; ===========================================================================

ObjC5_LaserShooter:      ; Routine $C
	movea.w	objoff_2C(a0),a1 ; a1=object (laser case)
	btst	#5,obStatus(a1)
	bne.w	DeleteObject
	moveq	#0,d0
	move.b	ob2ndRout(a0),d0
	move.w	ObjC5_LaserShooterIndex(pc,d0.w),d1
	jmp	ObjC5_LaserShooterIndex(pc,d1.w)
; ===========================================================================
ObjC5_LaserShooterIndex: 
	dc.w ObjC5_LaserShooterInit-ObjC5_LaserShooterIndex	; 0 - Loads up mappings
	dc.w ObjC5_LaserShooterFollow-ObjC5_LaserShooterIndex	; 2 - Goes back and forth with the laser case
	dc.w ObjC5_LaserShooterDown-ObjC5_LaserShooterIndex	; 4 - Laser case sets it to this routine which then makes it go down
; ===========================================================================

ObjC5_LaserShooterInit:
	addq.b	#2,ob2ndRout(a0)
	move.b	#4,obFrame(a0)
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_LaserShooterFollow:
	movea.w	objoff_2C(a0),a1 ; a1=object (laser case)
	move.w	obX(a1),obX(a0)
	move.w	obY(a1),obY(a0)
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_LaserShooterDown:
	movea.w	objoff_2C(a0),a1 ; a1=object (laser case)
	move.w	obX(a1),obX(a0)
	bra.w	DisplaySprite
; ===========================================================================

ObjC5_Laser:
	movea.w	objoff_2C(a0),a1 ; a1=object
	btst	#5,obStatus(a1)
	bne.w	DeleteObject
	moveq	#0,d0
	move.b	ob2ndRout(a0),d0
	move.w	ObjC5_LaserIndex(pc,d0.w),d1
	jsr		ObjC5_LaserIndex(pc,d1.w)
	bchg	#0,objoff_2F(a0)
	bne.w	ObjC5_rts
	jmp		DisplaySprite
; ===========================================================================
ObjC5_LaserIndex:
	dc.w ObjC5_LaserInit-ObjC5_LaserIndex	        ; 0 - Loads mappings and collision and such
	dc.w ObjC5_LaserFlash-ObjC5_LaserIndex	        ; 2 - Makes the laser flash (gives the charging up effect)
	dc.w ObjC5_LaseWaitShoot-ObjC5_LaserIndex	; 4 - Waits a little to launch the laser when it's done flickering (charging)
	dc.w ObjC5_LaserShoot-ObjC5_LaserIndex	        ; 6 - Shoots down the laser untill it's fully shot out
	dc.w ObjC5_LaserMove-ObjC5_LaserIndex	        ; 8 - Moves with laser case and shooter
; ===========================================================================

ObjC5_LaserInit:
	addq.b	#2,ob2ndRout(a0)
	move.b	#$D,obFrame(a0)
	move.w	#$200,obPriority(a0)
	move.b	#0,obColType(a0)
	addi.w	#$10,obY(a0)
	move.b	#$C,obAniFrame(a0)
	subq.w	#3,obY(a0)
	rts
; ===========================================================================

ObjC5_LaserFlash:
	bset	#0,objoff_2F(a0)
	subq.b	#1,obTimeFrame(a0)
	bpl.s	ObjC5_LaserNoLaser
	move.b	obTimeFrame(a0),d0
	addq.b	#2,d0
	bpl.s	ObjC5_LaserFlicker
	move.b	obAniFrame(a0),d0
	subq.b	#1,d0
	beq.s	ObjC5_LaseNext
	move.b	d0,obAniFrame(a0)
	move.b	d0,obTimeFrame(a0)

ObjC5_LaserFlicker:	; this is what makes the laser flicker before being fully loaded (covering laser shooter)
	bclr	#0,objoff_2F(a0)

ObjC5_LaserNoLaser: ; without this the laser would just stay on the shooter not going down
	rts
; ===========================================================================

ObjC5_LaseNext:		; just sets up a time to wait for the laser to shoot when it's loaded and done flickering
	addq.b	#2,ob2ndRout(a0)
	move.w	#$40,ObjC5_Timer(a0)
	rts
; ===========================================================================

ObjC5_LaseWaitShoot:
	subq.w	#1,ObjC5_Timer(a0)
	bmi.s	ObjC5_LaseStartShooting
	rts
; ===========================================================================

ObjC5_LaseStartShooting:
	addq.b	#2,ob2ndRout(a0)
	addi.w	#$10,obY(a0)
	rts
; ===========================================================================

ObjC5_LaserShoot:
	moveq	#0,d0
	move.b	objoff_2E(a0),d0
	addq.b	#1,d0
	cmpi.b	#5,d0
	bhs.s	ObjC5_LaseShotOut
	addi.w	#$10,obY(a0)
	move.b	d0,objoff_2E(a0)
	move.b	ObjC5_LaserMappingsData(pc,d0.w),obFrame(a0)
	move.b	ObjC5_LaserCollisionData(pc,d0.w),obColType(a0)
	rts
; ===========================================================================

ObjC5_LaseShotOut:	; laser is fully shot out and lets the laser case know so it moves
	addq.b	#2,ob2ndRout(a0)
	move.w	#$80,ObjC5_Timer(a0)
	bset	#2,obStatus(a0)
	movea.w	objoff_2C(a0),a1 ; a1=object (laser case)
	bset	#3,obStatus(a1)
	rts
; ===========================================================================
ObjC5_LaserMappingsData:
	dc.b  $E
	dc.b  $F	; 1
	dc.b $10	; 2
	dc.b $11	; 3
	dc.b $12	; 4
	dc.b   0	; 5
ObjC5_LaserCollisionData:
	dc.b $86
	dc.b $AB	; 1
	dc.b $AC	; 2
	dc.b $AD	; 3
	dc.b $AE	; 4
	dc.b   0	; 5
; ===========================================================================

ObjC5_LaserMove:
	movea.w	objoff_2C(a0),a1 ; a1=object
	move.w	obX(a1),obX(a0)
	rts
; ===========================================================================
; 
; ObjC5_Robotnik:
; 	moveq	#0,d0
; 	move.b	ob2ndRout(a0),d0
; 	move.w	ObjC5_RobotnikIndex(pc,d0.w),d1
; 	jmp	ObjC5_RobotnikIndex(pc,d1.w)
; ; ===========================================================================
; ObjC5_RobotnikIndex: 
; 	dc.w ObjC5_RobotnikInit-ObjC5_RobotnikIndex		; 0 - Loads art, animation and position
; 	dc.w ObjC5_RobotnikAnimate-ObjC5_RobotnikIndex	        ; 2 - Animates Robotnik and waits till the case is defeated
; 	dc.w ObjC5_RobotnikDown-ObjC5_RobotnikIndex		; 4 - Goes down until timer is up
; ; ===========================================================================
; 
; ObjC5_RobotnikInit:
; 	addq.b	#2,ob2ndRout(a0)
; 	move.b	#0,obFrame(a0)
; 	move.b	#1,obAnim(a0)
; 	move.w	#$2C60,obX(a0)
; 	move.w	#$4E6,obY(a0)
; 	lea	(ObjC5_RobotnikPlatformData).l,a2
; 	bsr.w	LoadChildObject
; 	bra.w	DisplaySprite
; ; ===========================================================================
; 
; ObjC5_RobotnikAnimate:
; 	movea.w	objoff_2C(a0),a1 ; a1=object (laser case)
; 	btst	#5,obStatus(a1)
; 	bne.s	ObjC5_RobotnikTimer
; 	lea	(Ani_objC5).l,a1;(Ani_objC5_objC6).l,a1
; 	jsr	AnimateSprite
; 	bra.w	DisplaySprite
; ; ===========================================================================
; 
; ObjC5_RobotnikTimer:		; Increase routine and set timer
; 	addq.b	#2,ob2ndRout(a0)
; 	move.w	#$C0,ObjC5_Timer(a0)
; 	bra.w	DisplaySprite
; ; ===========================================================================
; 
; ObjC5_RobotnikDown:
; 	subq.w	#1,ObjC5_Timer(a0)
; 	bmi.s	ObjC5_RobotnikDelete
; 	addq.w	#1,obY(a0)
; 	bra.w	DisplaySprite
; ; ===========================================================================
; 
; ObjC5_RobotnikDelete:		; Deletes robotnik and the platform he's on
; 	movea.w	wfz_parent(a0),a1 ; a1=object (Robotnik Platform)
; 	bsr.w	DeleteChild
; 	bra.w	DeleteObject
; ; ===========================================================================
; 
; ObjC5_RobotnikPlatform:	; Just displays the platform and move accordingly to the robotnik object
; 	movea.w	objoff_2C(a0),a1 ; a1=object (robotnik)
; 	move.w	obY(a1),d0
; 	addi.w	#$26,d0
; 	move.w	d0,obY(a0)
; 	bra.w	DisplaySprite
; ; ===========================================================================
; 	; some unused/dead code, At one point it appears a section of the platform was solid
; 	move.w	obX(a0),-(sp)
; 	bsr.w	SpeedToPos
; 	move.w	#$F,d1
; 	move.w	#8,d2
; 	move.w	#8,d3
; 	move.w	(sp)+,d4
; 	jmp	PlatformObject
; ===========================================================================

ObjC5_HandleHits:
	tst.b	obColProp(a0)                           ; test hit points
	beq.s	ObjC5_NoHitPointsLeft
	tst.b	obColType(a0)
	bne.s	return_3CC3A
	tst.b	objoff_30(a0)
	bne.s	ObjC5_FlashSetUp
	btst	#6,obStatus(a0)
	beq.s	return_3CC3A
	move.b	#$20,objoff_30(a0)
	move.w	#sfx_HitBoss,d0
	jsr	(PlaySound).l

ObjC5_FlashSetUp:
	lea	(v_pal1_wat+$22).w,a1                   ;$FFFFB22, normal palette
	moveq	#0,d0
	tst.w	(a1)
	bne.s	ObjC5_FlashCollisionRestore
	move.w	#$EEE,d0

ObjC5_FlashCollisionRestore:
	move.w	d0,(a1)
	subq.b	#1,objoff_30(a0)
	bne.s	return_3CC3A
	btst	#4,obStatus(a0)	; makes sure the boss doesn't need collision
	beq.s	return_3CC3A
	move.b	#6,obColType(a0)	; restore collision

return_3CC3A:
	rts

; ===========================================================================

ObjC5_NoHitPointsLeft:	; when the boss is defeated this tells it what to do
	moveq	#100,d0
	jsr	AddPoints
	clr.b	obColType(a0)
	move.w	#$EF,objoff_30(a0)
	move.b	#$1E,ob2ndRout(a0)
	bset	#5,obStatus(a0)
	bclr	#6,obStatus(a0)
	rts
; ===========================================================================
ObjC5_LaserWallData:
	dc.w ObjC5_Timer
	dc.b id_WFZBoss
	dc.b $4;94
ObjC5_PlatformData:
	dc.w objoff_3E
	dc.b id_WFZBoss
	dc.b $8;98
ObjC5_PlatformHurtData:
	dc.w objoff_3C
	dc.b id_WFZBoss
	dc.b $a;9A
ObjC5_LaserShooterData:
	dc.w objoff_3C
	dc.b id_WFZBoss
	dc.b $c;9C
ObjC5_PlatformReleaserData:
	dc.w objoff_3A
	dc.b id_WFZBoss
	dc.b $6;96
ObjC5_LaserData:
	dc.w objoff_3E
	dc.b id_WFZBoss
	dc.b $e;9E
; ObjC5_RobotnikData:
; 	dc.w objoff_38
; 	dc.b id_WFZBoss
; 	dc.b $10;A0
; ObjC5_RobotnikPlatformData:
; 	dc.w objoff_3E
; 	dc.b id_WFZBoss
; 	dc.b $12;A2
; --------------------------------------------------------------------------
; off_3CC80:
ObjC5_SubObjData:		; Laser Case
	dc.l ObjC5_MapA                         ; mappings
        dc.w VRAMloc_WFZBoss/$20                        ; vram     make_art_tile(ArtTile_ArtNem_WFZBoss,0,0)
        dc.b 4,4,$20,0                                  ; renderflags, obPriority, width, collision
; off_3CC8A:
ObjC5_SubObjData2:		; Laser Walls
	dc.l ObjC5_MapA                         ; mappings
        dc.w VRAMloc_WFZBoss/$20                        ; vram     make_art_tile(ArtTile_ArtNem_WFZBoss,0,0)
        dc.b 4,1,8,0                                    ; renderflags, obPriority, width, collision
; off_3CC94:
ObjC5_SubObjData3:		; Platforms, platform releaser, laser and laser shooter
	dc.l ObjC5_MapA                         ; mappings
        dc.w VRAMloc_WFZBoss/$20                        ; vram     make_art_tile(ArtTile_ArtNem_WFZBoss,0,0)
        dc.b 4,5,$10,0                                  ; renderflags, obPriority, width, collision
; off_3CC9E:
; ObjC6_SubObjData2:		; Robotnik
; 	dc.l ObjC5_MapA ;ObjC6_MapUnc_3D0EE                         ; mappings
;         dc.w $0000                                      ; vram     make_art_tile(ArtTile_ArtKos_LevelArt,0,0)
;         dc.b 4,5,$20,0                                  ; renderflags, obPriority, width, collision
; ; off_3CCA8:
; ObjC5_SubObjData4:		; Robotnik platform
; 	dc.l ObjC5_MapB                         ; mappings
;         dc.w $046D                                      ; vram     make_art_tile(ArtTile_ArtNem_WfzFloatingPlatform,1,1)
;         dc.b 4,5,$20,0                                  ; renderflags, obPriority, width, collision

; animation script
; off_3CCB2:
Ani_objC5:	
		dc.w byte_3CCBA-Ani_objC5	; 0
		dc.w byte_3CCC4-Ani_objC5	; 1
		dc.w byte_3CCCC-Ani_objC5	; 2
		dc.w byte_3CCD0-Ani_objC5	; 3
byte_3CCBA:	dc.b   5,  0,  1,  2,  3,  3,  3,  3,$FA,  0
byte_3CCC4:	dc.b   3,  3,  2,  1,  0,  0,$FA,  0
byte_3CCCC:	dc.b   3,  5,  6,$FF
byte_3CCD0:	dc.b   3,  7,  8,  9, $A, $B,$FF
		even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjC5_MapA:
	dc.w	ObjC5_MapA_0026-ObjC5_MapA
	dc.w	ObjC5_MapA_0048-ObjC5_MapA
	dc.w	ObjC5_MapA_006A-ObjC5_MapA
	dc.w	ObjC5_MapA_008C-ObjC5_MapA
	dc.w	ObjC5_MapA_00AE-ObjC5_MapA
	dc.w	ObjC5_MapA_00C0-ObjC5_MapA
	dc.w	ObjC5_MapA_00D2-ObjC5_MapA
	dc.w	ObjC5_MapA_00DC-ObjC5_MapA
	dc.w	ObjC5_MapA_00E6-ObjC5_MapA
	dc.w	ObjC5_MapA_00F0-ObjC5_MapA
	dc.w	ObjC5_MapA_00FA-ObjC5_MapA
	dc.w	ObjC5_MapA_0104-ObjC5_MapA
	dc.w	ObjC5_MapA_010E-ObjC5_MapA
	dc.w	ObjC5_MapA_0130-ObjC5_MapA
	dc.w	ObjC5_MapA_013A-ObjC5_MapA
	dc.w	ObjC5_MapA_014C-ObjC5_MapA
	dc.w	ObjC5_MapA_0166-ObjC5_MapA
	dc.w	ObjC5_MapA_0188-ObjC5_MapA
	dc.w	ObjC5_MapA_01B2-ObjC5_MapA

ObjC5_MapA_0026:	dc.b 4
	dc.b $F8, $C, $20, 0, $E0
	dc.b $F8, $C, $20, 4, 0
	dc.b 0, 9, $20, 8, $E8
	dc.b 0, 9, $28, 8, 0

ObjC5_MapA_0048:	dc.b 4
	dc.b $F8, $C, $20, 0, $E0
	dc.b $F8, $C, $28, 0, 0
	dc.b 0, 9, $20, $E, $E8
	dc.b 0, 9, $28, $E, 0

ObjC5_MapA_006A:	dc.b 4
	dc.b $F8, $C, $20, 0, $E0
	dc.b $F8, $C, $28, 0, 0
	dc.b 0, 9, $20, $14, $E8
	dc.b 0, 9, $28, $14, 0

ObjC5_MapA_008C:	dc.b 4
	dc.b $F8, $C, $20, 0, $E0
	dc.b $F8, $C, $28, 0, 0
	dc.b 0, 8, $20, $1A, $E8
	dc.b 0, 8, $28, $1A, 0

ObjC5_MapA_00AE:	dc.b 2
	dc.b $F8, 5, $00, $1D, $F0
	dc.b $F8, 5, $08, $1D, 0

ObjC5_MapA_00C0:	dc.b 2
	dc.b $F8, $D, $20, $21, $E0
	dc.b $F8, $D, $28, $21, 0

ObjC5_MapA_00D2:	dc.b 1
	dc.b $F8, $E, $20, $29, $F0

ObjC5_MapA_00DC:	dc.b 1
	dc.b $F8, $E, $20, $35, $F0

ObjC5_MapA_00E6:	dc.b 1
	dc.b $F8, $E, $20, $41, $F0

ObjC5_MapA_00F0:	dc.b 1
	dc.b $F8, $E, $20, $4D, $F0

ObjC5_MapA_00FA:	dc.b 1
	dc.b $F8, $E, $28, $41, $F0

ObjC5_MapA_0104:	dc.b 1
	dc.b $F8, $E, $28, $35, $F0

ObjC5_MapA_010E:	dc.b 4
	dc.b $C0, 7, $20, $59, $F8
	dc.b $E0, 7, $20, $59, $F8
	dc.b 0, 7, $20, $59, $F8
	dc.b $20, 7, $20, $59, $F8

ObjC5_MapA_0130:	dc.b 1
	dc.b 0, $C, $40, $71, $F0

ObjC5_MapA_013A:	dc.b 2
	dc.b $F0, $F, $40, $61, $F0
	dc.b $10, $C, $40, $71, $F0

ObjC5_MapA_014C:	dc.b 3
	dc.b $E0, $F, $40, $61, $F0
	dc.b 0, $F, $40, $61, $F0
	dc.b $20, $C, $40, $71, $F0

ObjC5_MapA_0166:	dc.b 4
	dc.b $D0, $F, $40, $61, $F0
	dc.b $F0, $F, $40, $61, $F0
	dc.b $10, $F, $40, $61, $F0
	dc.b $30, $C, $40, $71, $F0

ObjC5_MapA_0188:	dc.b 5
	dc.b $C0, $F, $40, $61, $F0
	dc.b $E0, $F, $40, $61, $F0
	dc.b 0, $F, $40, $61, $F0
	dc.b $20, $F, $40, $61, $F0
	dc.b $40, $C, $40, $71, $F0

ObjC5_MapA_01B2:	dc.b 6
	dc.b $B0, $F, $40, $61, $F0
	dc.b $D0, $F, $40, $61, $F0
	dc.b $F0, $F, $40, $61, $F0
	dc.b $10, $F, $40, $61, $F0
	dc.b $30, $F, $40, $61, $F0
	dc.b $50, $C, $40, $71, $F0

	even

; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjC5_MapB:
	dc.w	ObjC5_MapB_0002-ObjC5_MapB

ObjC5_MapB_0002:	dc.b 2
	dc.b $F4, $E, 0, 0, $E0
	dc.b $F4, $E, 8, 0, 0

	even
; --------------------------------------------------------------------------
; enmpty frame for platform hurt area
ObjC5_Blank:
	dc.w	ObjC5_Blank_Frame-ObjC5_Blank
ObjC5_Blank_Frame:	dc.b 0
        even

; ----------------------------------------------------------------------------
; palette
; ----------------------------------------------------------------------------
WFZBoss_Pal:
	incbin "palette\WFZ Boss.bin"
	even



; ---------------------------------------------------------------------------
; LoadSubObject
; loads information from a sub-object into this object a0
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_365F4:
LoadSubObject:
	moveq	#0,d0
	move.b	obSubtype(a0),d0
; loc_365FA:
LoadSubObject_Part2:
	move.w	SubObjData_Index(pc,d0.w),d0
	lea	SubObjData_Index(pc,d0.w),a1
; loc_36602:
LoadSubObject_Part3:
	move.l	(a1)+,obMap(a0)
	move.w	(a1)+,obGfx(a0)
;	jsr	(Adjust2PArtPointer).l
	move.b	(a1)+,d0
	or.b	d0,obRender(a0)
	move.b	(a1)+,obPriority(a0)
		move.w 	obpriority(a0),d0
		lsr.w 	#1,d0
		andi.w 	#$380,d0
		move.w 	d0,obpriority(a0)
	move.b	(a1)+,obActWid(a0)
	move.b	(a1),obColType(a0)
	addq.b	#2,obRoutine(a0)
	rts

; ===========================================================================
; table that maps from the subtype ID to which address to load the data from
; the format of the data there is
;	dc.l Pointer_To_Sprite_Mappings
;	dc.w VRAM_Location
;	dc.b render_flags, obPriority, width_pixels, obColType
; 
; for whatever reason, only Obj8C and later have entries in this table

; off_36628:
SubObjData_Index:
; 	dc.w Obj8C_SubObjData-SubObjData_Index	; $0
; 	dc.w Obj8D_SubObjData-SubObjData_Index	; $2
; 	dc.w Obj90_SubObjData-SubObjData_Index	; $4
; 	dc.w Obj90_SubObjData2-SubObjData_Index	; $6
; 	dc.w Obj91_SubObjData-SubObjData_Index	; $8
; 	dc.w Obj92_SubObjData-SubObjData_Index	; $A
; 	dc.w Invalid_SubObjData-SubObjData_Index; $C
; 	dc.w Obj94_SubObjData-SubObjData_Index	; $E
; 	dc.w Obj94_SubObjData2-SubObjData_Index	; $10
; 	dc.w Obj99_SubObjData2-SubObjData_Index	; $12
; 	dc.w Obj99_SubObjData-SubObjData_Index	; $14
; 	dc.w Obj9A_SubObjData-SubObjData_Index	; $16
; 	dc.w Obj9B_SubObjData-SubObjData_Index	; $18
; 	dc.w Obj9C_SubObjData-SubObjData_Index	; $1A
; 	dc.w Obj9A_SubObjData2-SubObjData_Index	; $1C
; 	dc.w Obj9D_SubObjData-SubObjData_Index	; $1E
; 	dc.w Obj9D_SubObjData2-SubObjData_Index	; $20
; 	dc.w Obj9E_SubObjData-SubObjData_Index	; $22
; 	dc.w Obj9F_SubObjData-SubObjData_Index	; $24
; 	dc.w ObjA0_SubObjData-SubObjData_Index	; $26
; 	dc.w ObjA1_SubObjData-SubObjData_Index	; $28
; 	dc.w ObjA2_SubObjData-SubObjData_Index	; $2A
; 	dc.w ObjA3_SubObjData-SubObjData_Index	; $2C
; 	dc.w ObjA4_SubObjData-SubObjData_Index	; $2E
; 	dc.w ObjA4_SubObjData2-SubObjData_Index	; $30
; 	dc.w ObjA5_SubObjData-SubObjData_Index	; $32
; 	dc.w ObjA6_SubObjData-SubObjData_Index	; $34
; 	dc.w ObjA7_SubObjData-SubObjData_Index	; $36
; 	dc.w ObjA7_SubObjData2-SubObjData_Index	; $38
; 	dc.w ObjA8_SubObjData-SubObjData_Index	; $3A
; 	dc.w ObjA8_SubObjData2-SubObjData_Index	; $3C
; 	dc.w ObjA7_SubObjData3-SubObjData_Index	; $3E
; 	dc.w ObjAC_SubObjData-SubObjData_Index	; $40
; 	dc.w ObjAD_SubObjData-SubObjData_Index	; $42
; 	dc.w ObjAD_SubObjData2-SubObjData_Index	; $44
; 	dc.w ObjAD_SubObjData3-SubObjData_Index	; $46
; 	dc.w ObjAF_SubObjData2-SubObjData_Index	; $48
; 	dc.w ObjAF_SubObjData-SubObjData_Index	; $4A
; 	dc.w ObjB0_SubObjData-SubObjData_Index	; $4C
; 	dc.w ObjB1_SubObjData-SubObjData_Index	; $4E
; 	dc.w ObjB2_SubObjData-SubObjData_Index	; $50
; 	dc.w ObjB2_SubObjData-SubObjData_Index	; $52
; 	dc.w ObjB2_SubObjData-SubObjData_Index	; $54
; 	dc.w ObjBC_SubObjData2-SubObjData_Index	; $56
; 	dc.w ObjBC_SubObjData2-SubObjData_Index	; $58
; 	dc.w ObjB3_SubObjData-SubObjData_Index	; $5A
; 	dc.w ObjB2_SubObjData2-SubObjData_Index	; $5C
; 	dc.w ObjB3_SubObjData-SubObjData_Index	; $5E
; 	dc.w ObjB3_SubObjData-SubObjData_Index	; $60
; 	dc.w ObjB3_SubObjData-SubObjData_Index	; $62
; 	dc.w ObjB4_SubObjData-SubObjData_Index	; $64
; 	dc.w ObjB5_SubObjData-SubObjData_Index	; $66
; 	dc.w ObjB5_SubObjData-SubObjData_Index	; $68
; 	dc.w ObjB6_SubObjData-SubObjData_Index	; $6A
; 	dc.w ObjB6_SubObjData-SubObjData_Index	; $6C
; 	dc.w ObjB6_SubObjData-SubObjData_Index	; $6E
; 	dc.w ObjB6_SubObjData-SubObjData_Index	; $70
; 	dc.w ObjB7_SubObjData-SubObjData_Index	; $72
; 	dc.w ObjB8_SubObjData-SubObjData_Index	; $74
; 	dc.w ObjB9_SubObjData-SubObjData_Index	; $76
; 	dc.w ObjBA_SubObjData-SubObjData_Index	; $78
; 	dc.w ObjBB_SubObjData-SubObjData_Index	; $7A
; 	dc.w ObjBC_SubObjData2-SubObjData_Index	; $7C
; 	dc.w ObjBD_SubObjData-SubObjData_Index	; $7E
; 	dc.w ObjBD_SubObjData-SubObjData_Index	; $80
; 	dc.w ObjBE_SubObjData-SubObjData_Index	; $82
; 	dc.w ObjBE_SubObjData2-SubObjData_Index	; $84
; 	dc.w ObjC0_SubObjData-SubObjData_Index	; $86
; 	dc.w ObjC1_SubObjData-SubObjData_Index	; $88
; 	dc.w ObjC2_SubObjData-SubObjData_Index	; $8A
; 	dc.w Invalid_SubObjData2-SubObjData_Index	; $8C
; 	dc.w ObjB8_SubObjData2-SubObjData_Index	; $8E
; 	dc.w ObjC3_SubObjData-SubObjData_Index	; $90
        dc.w 0
	dc.w ObjC5_SubObjData-SubObjData_Index	; $92
	dc.w ObjC5_SubObjData2-SubObjData_Index	; $94
	dc.w ObjC5_SubObjData3-SubObjData_Index	; $96
	dc.w ObjC5_SubObjData3-SubObjData_Index	; $98
	dc.w ObjC5_SubObjData3-SubObjData_Index	; $9A
	dc.w ObjC5_SubObjData3-SubObjData_Index	; $9C
	dc.w ObjC5_SubObjData3-SubObjData_Index	; $9E
; 	dc.w ObjC6_SubObjData2-SubObjData_Index	; $A0
; 	dc.w ObjC5_SubObjData4-SubObjData_Index	; $A2
; 	dc.w ObjAF_SubObjData3-SubObjData_Index	; $A4
; 	dc.w ObjC6_SubObjData3-SubObjData_Index	; $A6
; 	dc.w ObjC6_SubObjData4-SubObjData_Index	; $A8
; 	dc.w ObjC6_SubObjData-SubObjData_Index	; $AA
; 	dc.w ObjC8_SubObjData-SubObjData_Index	; $AC

; ===========================================================================
; ---------------------------------------------------------------------------
; Get Orientation To Player
; Returns the horizontal and vertical distances of the closest player object.
;
; input variables:
;  a0 = object
;
; returns:
;  a1 = address of closest player character
;  d0 = 0 if right from player, 2 if left
;  d1 = 0 if above player, 2 if under
;  d2 = horizontal distance to closest character
;  d3 = vertical distance to closest character
;
; writes:
;  d0, d1, d2, d3, d4, d5
;  a1
;  a2 = sidekick
; ---------------------------------------------------------------------------
;loc_366D6:
Obj_GetOrientationToPlayer:
	moveq	#0,d0
	moveq	#0,d1
	lea	(v_player).w,a1 ; a1=character
	move.w	obX(a0),d2
	sub.w	obX(a1),d2
;	move.w	d2,d4	; absolute horizontal distance to main character
; 	lea	(Sidekick).w,a2 ; a2=character
; 	move.w	obX(a0),d3
; 	sub.w	obX(a2),d3
; 	move.w	d3,d5	; absolute horizontal distance to sidekick
; 	cmp.w	d5,d4	; get shorter distance
; 	bls.s	+	; branch, if main character is closer
; 	; if sidekick is closer
; 	movea.l	a2,a1
; 	move.w	d3,d2
; +
	tst.w	d2	        ; is player to enemy's left?
	bpl.s	@notleft	; if not, branch
	addq.w	#2,d0
@notleft:
	move.w	obY(a0),d3
	sub.w	obY(a1),d3	; vertical distance to closest character
	bhs.s	@end	        ; branch, if enemy is under
	addq.w	#2,d1
@end:
	rts
	
; ===========================================================================

;loc_367D0:
LoadChildObject:
	jsr	(FindNextFreeObj).l
	bne.s	@end	; rts
	move.w	(a2)+,d0
	move.w	a1,(a0,d0.w) ; store pointer to child in parent's SST
	move.b	(a2)+,0(a1) ; load obj
	move.b	(a2)+,obSubtype(a1)
	move.w	a0,objoff_2C(a1) ; store pointer to parent in child's SST
	move.w	obX(a0),obX(a1)
	move.w	obY(a0),obY(a1)
@end:
	rts
; ===========================================================================
loc_3B7BC:
	move.b	obStatus(a0),d0
	andi.b	#$08,d0
	beq.s	return_3B7F6
	bclr	#3,obStatus(a0)
	beq.s	loc_3B7DE
	lea	(v_player).w,a1 ; a1=character
	bclr	#3,obStatus(a1)
	bset	#1,obStatus(a1)

loc_3B7DE:
; 	bclr	#p2_standing_bit,obStatus(a0)
; 	beq.s	return_3B7F6
; 	lea	(Sidekick).w,a1 ; a1=character
; 	bclr	#4,obStatus(a1)
; 	bset	#1,obStatus(a1)

return_3B7F6:
	rts
