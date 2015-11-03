; ===========================================================================
; ----------------------------------------------------------------------------
; Object 54 - MTZ boss
; ----------------------------------------------------------------------------
MTZBscreenX       = $2000                                                                         ;*
MTZBscreenY       = $C0                                                                          ;*
; ----------------------------------------------------------------------------
MtzBoss_FlashCounter = $14
boss_routine      = $26
objoff_28         = $28
orb_orbit_radius  = $29
MtzBoss_timer     = $29
orb_centre_Y      = $2A
objoff_2b         = $2B
bouncing_orb_count = $2C
Mtz_LazersLeftToFire  = $2D
Mtz_Pinch_Rout    = $2E
objoff_2f         = $2F
objoff_30         = $30
orb_timer         = $32        ; orb only
MtzBoss_health    = $32        ; robotnic only
objoff_33         = $33
MtzBoss_parent    = $34
orb_centre_X      = $38        ; orb only
orb_remove_flag   = $38        ; robotnic only
objoff_3a         = $3A
objoff_3b         = $3B
objoff_3c         = $3C
MtzBoss_health2   = $3E
objoff_3f         = $3F
; Sprite_32288:
MTZBoss:
;        rts
Obj54:
	moveq	#0,d0
	move.b	obRoutine(a0),d0
	move.w	Obj54_Index(pc,d0.w),d1
	jmp	Obj54_Index(pc,d1.w)
; ===========================================================================
; off_32296:
Obj54_Index:
		dc.w Obj54_Init-Obj54_Index	; 0
		dc.w MTZBoss_ShipObject-Obj54_Index	; 2
		dc.w MTZBoss_LazerObject-Obj54_Index	; 4
		dc.w MTZBoss_LazerGunObject-Obj54_Index	; 6
; ===========================================================================
; loc_3229E:
Obj54_Init:
    ; create main ship object
	move.l	#Map_MTZBoss,obMap(a0)
	move.w	#$0380,obGfx(a0)
	ori.b	#4,obRender(a0)
	move.w	#$180,obTimeFrame(a0)		; use this instead of obPriority, breaks with childsprites
	move.w	#MTZBscreenX+$A0,obX(a0)                                                                    ;*
	move.w	#MTZBscreenY-$20,obY(a0)                                                                     ;*
	move.b	#2,mainspr_mapframe(a0)        ; main ship sprite
	addq.b	#2,obRoutine(a0)
	bset	#6,obRender(a0)                ; enable childsprites
	move.b	#2,mainspr_childsprites(a0)    ; number of sprites to draw
	move.b	#$F,obColType(a0)
	move.b	#8,MtzBoss_health(a0)          ; 8 hits
	move.b	#7,MtzBoss_health2(a0)
	move.w	obX(a0),(Boss_X_pos).w
	move.w	obY(a0),(Boss_Y_pos).w
	move.w	#0,(Boss_X_vel).w
	move.w	#$100,(Boss_Y_vel).w           ; speed to fly down
	move.b	#$20,mainspr_width(a0)
	clr.b	objoff_2B(a0)
	clr.b	bouncing_orb_count(a0)
	move.b	#$40,obFrame(a0)
	move.b	#$27,objoff_33(a0)
	move.b	#$27,MtzBoss_timer(a0)
	move.w	obX(a0),sub2_x_pos(a0)         ; setup robotnik head sprite
	move.w	obY(a0),sub2_y_pos(a0)
	move.b	#$C,sub2_mapframe(a0)
	move.w	obX(a0),sub3_x_pos(a0)         ; setup flame sprite
	move.w	obY(a0),sub3_y_pos(a0)
	move.b	#0,sub3_mapframe(a0)

   ; create nose of ship that goes behind the lazer
	bsr.w	FindFreeObj                    ; find object ram slot
	bne.s	loc_3239C
	move.b	#id_MTZBoss,(a1)               ; load obj54
	move.b	#6,obRoutine(a1)
	move.b	#$13,obFrame(a1)
	move.l	#Map_MTZBoss,obMap(a1)
	move.w	#$0380,obGfx(a1)
	ori.b	#4,obRender(a1)
	move.w	#$300,obPriority(a1)		
	move.w	obX(a0),obX(a1)
	move.w	obY(a0),obY(a1)
	move.l	a0,MtzBoss_parent(a1)          ; remember parent object
	move.b	#$20,obActWid(a1)

    ; create orbs
	bsr.w	FindFreeObj                    ; find object ram slot
	bne.s	loc_3239C
	move.b	#id_MTZBossOrbs,(a1)           ; load obj53
	move.l	a0,MtzBoss_parent(a1)          ; remember parent object

loc_3239C:
	lea	(Boss_AnimationArray).w,a2
	move.b	#$10,(a2)+
	move.b	#0,(a2)+
	move.b	#3,(a2)+
	move.b	#0,(a2)+
	move.b	#1,(a2)+
	move.b	#0,(a2)+
	rts
; ===========================================================================

MTZBoss_ShipObject:
	moveq	#0,d0
	move.b	boss_routine(a0),d0
	move.w	MTZ_Boss_2nd_Index(pc,d0.w),d1
	jmp	MTZ_Boss_2nd_Index(pc,d1.w)
; ===========================================================================
MTZ_Boss_2nd_Index:
		dc.w MTZ_Boss_2nd_Rout_0-MTZ_Boss_2nd_Index	;   0
		dc.w MTZ_Boss_2nd_Rout_2-MTZ_Boss_2nd_Index	;   2
		dc.w MTZ_Boss_2nd_Rout_4-MTZ_Boss_2nd_Index	;   4
		dc.w MTZ_Boss_2nd_Rout_6-MTZ_Boss_2nd_Index	;   6
		dc.w MTZ_Boss_2nd_Rout_8-MTZ_Boss_2nd_Index	;   8
		dc.w MTZ_Boss_2nd_Rout_A-MTZ_Boss_2nd_Index	;  $A
		dc.w MTZ_Boss_2nd_Rout_C-MTZ_Boss_2nd_Index	;  $C
		dc.w MTZ_Boss_2nd_Rout_E-MTZ_Boss_2nd_Index	;  $E
		dc.w MTZ_Boss_10_Defeated-MTZ_Boss_2nd_Index	; $10
		dc.w MTZ_Boss_12_RunAway-MTZ_Boss_2nd_Index	; $12
; ===========================================================================

MTZ_Boss_2nd_Rout_0:
	bsr.w	Boss_MoveObject
	move.w	(Boss_Y_pos).w,obY(a0)
	cmpi.w	#MTZBscreenY+$A0,(Boss_Y_pos).w            ; is boss lowered into starting position?  ;*
	blo.s	loc_32426
	addq.b	#2,boss_routine(a0)
	move.w	#0,(Boss_Y_vel).w               ; stop lowering
	move.w	#-$100,(Boss_X_vel).w           ; start moving left
	bclr	#7,objoff_2B(a0)
	bclr	#0,obRender(a0)                 ; face left
	move.w	(v_player+obX).w,d0
	cmp.w	(Boss_X_pos).w,d0               ; compare boss' x position to sonic
	blo.s	loc_32426                       ; branch if on the right
	move.w	#$100,(Boss_X_vel).w            ; start moving right
	bset	#7,objoff_2B(a0)
	bset	#0,obRender(a0)                 ; face right

loc_32426:
	bsr.w	loc_3278E
	lea	(Anim_MTZBoss).l,a1
	bsr.w	AnimateBoss
	bsr.w	MtzBoss_UpdateChildspritePositions
	bra.w	JmpTo40_DisplaySprite
; ===========================================================================

loc_3243C:
	move.b	obFrame(a0),d0
	jsr	(CalcSine).l
	asr.w	#6,d0
	add.w	(Boss_Y_pos).w,d0
	move.w	d0,obY(a0)
	addq.b	#4,obFrame(a0)
	rts
; ===========================================================================

MTZ_Boss_2nd_Rout_2:
	bsr.w	Boss_MoveObject
	btst	#7,objoff_2B(a0)
	bne.s	loc_32490
	cmpi.w	#MTZBscreenX+$20,(Boss_X_pos).w                                                     ;*
	bhs.s	loc_324BC
	bchg	#7,objoff_2B(a0)
	move.w	#$100,(Boss_X_vel).w
	bset	#0,obRender(a0)
	bset	#6,objoff_2B(a0)
	beq.s	loc_324BC
	addq.b	#2,boss_routine(a0)
	move.w	#-$100,(Boss_Y_vel).w
	bra.s	loc_324BC
; ===========================================================================

loc_32490:
	cmpi.w	#MTZBscreenX+$120,(Boss_X_pos).w                                                    ;*
	blo.s	loc_324BC
	bchg	#7,objoff_2B(a0)
	move.w	#-$100,(Boss_X_vel).w
	bclr	#0,obRender(a0)
	bset	#6,objoff_2B(a0)
	beq.s	loc_324BC
	addq.b	#2,boss_routine(a0)
	move.w	#-$100,(Boss_Y_vel).w

loc_324BC:
	move.w	(Boss_X_pos).w,obX(a0)
	bsr.w	loc_3243C

loc_324C6:
	bsr.w	loc_3278E
	lea	(Anim_MTZBoss).l,a1
	bsr.w	AnimateBoss
	bsr.w	MtzBoss_UpdateChildspritePositions
	bra.w	JmpTo40_DisplaySprite
; ===========================================================================

MTZ_Boss_2nd_Rout_4:
	bsr.w	Boss_MoveObject
	cmpi.w	#MTZBscreenY+$70,(Boss_Y_pos).w                                               ;*
	bhs.s	loc_324EE
	move.w	#0,(Boss_Y_vel).w

loc_324EE:
	btst	#7,objoff_2B(a0)
	bne.s	loc_32506
	cmpi.w	#MTZBscreenX+$A0,(Boss_X_pos).w                                                ;*
	bhs.s	loc_32514
	move.w	#0,(Boss_X_vel).w
	bra.s	loc_32514
; ===========================================================================

loc_32506:
	cmpi.w	#MTZBscreenX+$A0,(Boss_X_pos).w                                                ;*
	blo.s	loc_32514
	move.w	#0,(Boss_X_vel).w

loc_32514:
	move.w	(Boss_X_vel).w,d0
	or.w	(Boss_Y_vel).w,d0
	bne.s	BranchTo_loc_324BC
	addq.b	#2,boss_routine(a0)

BranchTo_loc_324BC
	bra.s	loc_324BC
; ===========================================================================

MTZ_Boss_2nd_Rout_6:
	cmpi.b	#$68,objoff_33(a0)
	bhs.s	loc_32536
	addq.b	#1,objoff_33(a0)
	addq.b	#1,MtzBoss_timer(a0)
	bra.s	BranchTo2_loc_324BC
; ===========================================================================

loc_32536:
	subq.b	#1,MtzBoss_timer(a0)
	bne.s	BranchTo2_loc_324BC
	addq.b	#2,boss_routine(a0)

BranchTo2_loc_324BC 
	bra.w	loc_324BC
; ===========================================================================

MTZ_Boss_2nd_Rout_8:
	cmpi.b	#$27,objoff_33(a0)
	blo.s	loc_32552
	subq.b	#1,objoff_33(a0)
	bra.s	BranchTo3_loc_324BC
; ===========================================================================

loc_32552:
	addq.b	#1,MtzBoss_timer(a0)
	cmpi.b	#$27,MtzBoss_timer(a0)
	blo.s	BranchTo3_loc_324BC
	move.w	#$100,(Boss_Y_vel).w
	move.b	#0,boss_routine(a0)
	bclr	#6,objoff_2B(a0)

BranchTo3_loc_324BC 
	bra.w	loc_324BC
; ===========================================================================

MTZ_Boss_2nd_Rout_A:
	tst.b	MtzBoss_timer(a0)
	beq.s	loc_32580
	subq.b	#1,MtzBoss_timer(a0)
	bra.s	loc_32586
; ===========================================================================

loc_32580:
	move.b	#-1,objoff_3A(a0)

loc_32586:
	cmpi.b	#$27,objoff_33(a0)
	blo.s	loc_32592
	subq.b	#1,objoff_33(a0)

loc_32592:
	bsr.w	Boss_MoveObject
	cmpi.w	#MTZBscreenY+$2,(Boss_Y_pos).w     ; reached top of screen?                      ;*
	bhs.s	loc_325A4
	move.w	#0,(Boss_Y_vel).w                   ; stop moving up

loc_325A4:
	tst.b	bouncing_orb_count(a0)
	bne.s	BranchTo4_loc_324BC
	tst.b	objoff_3A(a0)
	beq.s	loc_325B6
	move.b	#$80,objoff_3A(a0)

loc_325B6:
	addq.b	#2,boss_routine(a0)

BranchTo4_loc_324BC 
	bra.w	loc_324BC
; ===========================================================================

MTZ_Boss_2nd_Rout_C:
	cmpi.b	#0,MtzBoss_health2(a0)
	bls.s	loc_325EC
	tst.b	objoff_3A(a0)
	bne.s	BranchTo5_loc_324BC
	cmpi.b	#$27,MtzBoss_timer(a0)
	bhs.s	loc_325D8
	addq.b	#1,MtzBoss_timer(a0)
	bra.s	BranchTo5_loc_324BC
; ===========================================================================

loc_325D8:
	move.w	#$100,(Boss_Y_vel).w
	move.b	#0,boss_routine(a0)
	bclr	#6,objoff_2B(a0)
	bra.s	BranchTo5_loc_324BC
; ===========================================================================

loc_325EC:
	move.w	#-$190,(Boss_Y_vel).w
	move.w	#-$100,(Boss_X_vel).w
	bclr	#0,obRender(a0)
	btst	#7,objoff_2B(a0)
	beq.s	loc_32612
	move.w	#$100,(Boss_X_vel).w
	bset	#0,obRender(a0)

loc_32612:
	move.b	#$E,boss_routine(a0)
	move.b	#0,Mtz_Pinch_Rout(a0)
	bclr	#6,objoff_2B(a0)
	move.b	#0,objoff_2F(a0)

BranchTo5_loc_324BC 
	bra.w	loc_324BC
; ===========================================================================

MTZ_Boss_2nd_Rout_E:
	tst.b	objoff_2F(a0)
	beq.s	loc_3263C
	subq.b	#1,objoff_2F(a0)
	bra.w	loc_324C6
; ===========================================================================

loc_3263C:
	moveq	#0,d0
	move.b	Mtz_Pinch_Rout(a0),d0
	move.w	off_3264A(pc,d0.w),d1
	jmp	off_3264A(pc,d1.w)
; ===========================================================================
off_3264A:
		dc.w MTZBossPinch_Rout_0-off_3264A	; 0
		dc.w MTZBossPinch_Rout_2-off_3264A	; 2
		dc.w MTZBossPinch_Rout_4-off_3264A	; 4
; ===========================================================================

MTZBossPinch_Rout_0:                ;MTZBossPinch_Rout_0:
	bsr.w	Boss_MoveObject
	cmpi.w	#MTZBscreenY+$20,(Boss_Y_pos).w                                               ;*
	bhi.s	loc_32662
	bcs.s   @godown
	move.w	#$0,(Boss_Y_vel).w
	bra.s   loc_32662
@godown:
	move.w	#$80,(Boss_Y_vel).w

loc_32662:
	btst	#7,objoff_2B(a0)
	bne.s	loc_32690
	cmpi.w	#MTZBscreenX+$40,(Boss_X_pos).w                                               ;*
	bhs.s	BranchTo6_loc_324BC
	addq.b	#2,Mtz_Pinch_Rout(a0)
	move.w	#$180,(Boss_Y_vel).w
	move.b	#3,Mtz_LazersLeftToFire(a0)
	move.w	#$1E,(unk_F75C).w
	bset	#0,obRender(a0)
	bra.s	BranchTo6_loc_324BC
; ===========================================================================

loc_32690:
	cmpi.w	#MTZBscreenX+$100,(Boss_X_pos).w                                             ;*
	blo.s	BranchTo6_loc_324BC
	addq.b	#2,Mtz_Pinch_Rout(a0)
	move.w	#$180,(Boss_Y_vel).w
	move.b	#3,Mtz_LazersLeftToFire(a0)
	move.w	#$1E,(unk_F75C).w
	bclr	#0,obRender(a0)

BranchTo6_loc_324BC 
	bra.w	loc_324BC
; ===========================================================================

MTZBossPinch_Rout_2:             ;MTZBossPinch_Rout_2:
	bsr.w	Boss_MoveObject
	cmpi.w	#MTZBscreenY+$A0,(Boss_Y_pos).w                                              ;*
	blo.s	loc_326D6
	move.w	#-$180,(Boss_Y_vel).w
	addq.b	#2,Mtz_Pinch_Rout(a0)
	bchg	#7,objoff_2B(a0)
	bra.s	loc_326FC
; ===========================================================================

loc_326D6:
	btst	#7,objoff_2B(a0)
	bne.s	loc_326EE
	cmpi.w	#MTZBscreenX+$20,(Boss_X_pos).w                                              ;*
	bhs.s	loc_326FC
	move.w	#0,(Boss_X_vel).w
	bra.s	loc_326FC
; ===========================================================================

loc_326EE:
	cmpi.w	#MTZBscreenX+$120,(Boss_X_pos).w                                             ;*
	blo.s	loc_326FC
	move.w	#0,(Boss_X_vel).w

loc_326FC:
	bsr.w	loc_32740
	bra.w	loc_324BC
; ===========================================================================

MTZBossPinch_Rout_4:                    ;MTZBossPinch_Rout_4:
	bsr.w	Boss_MoveObject
	cmpi.w	#MTZBscreenY+$70,(Boss_Y_pos).w                                              ;*
	bhs.s	loc_32724
	move.w	#$100,(Boss_X_vel).w
	btst	#7,objoff_2B(a0)
	bne.s	loc_32724
	move.w	#-$100,(Boss_X_vel).w

loc_32724:
	cmpi.w	#MTZBscreenY+$20,(Boss_Y_pos).w                                              ;*
	bhs.s	loc_32738
	move.w	#0,(Boss_Y_vel).w
	move.b	#0,Mtz_Pinch_Rout(a0)

loc_32738:
	bsr.w	loc_32740
	bra.w	loc_324BC
; ===========================================================================

loc_32740:
	subi.w	#1,(unk_F75C).w
	bne.s	return_32772
	tst.b	Mtz_LazersLeftToFire(a0)
	beq.s	return_32772
	subq.b	#1,Mtz_LazersLeftToFire(a0)
	bsr.w	JmpTo17_FindFreeObj    ; find slot for a lazer object
	bne.s	return_32772
	move.b	#id_MTZBoss,(a1)       ; load obj54
	move.b	#4,obRoutine(a1)       ; lazer routine
	move.l	a0,MtzBoss_parent(a1)  ; remember parent
	move.w	#$1E,(unk_F75C).w
	move.b	#$10,objoff_2F(a0)

return_32772:
	rts
; ===========================================================================

MtzBoss_UpdateChildspritePositions:
	move.w	obX(a0),d0
	move.w	obY(a0),d1
	move.w	d0,sub2_x_pos(a0)
	move.w	d1,sub2_y_pos(a0)
	move.w	d0,sub3_x_pos(a0)
	move.w	d1,sub3_y_pos(a0)
	rts
; ===========================================================================

loc_3278E:
	bsr.w	MTZBoss_Flash
	cmpi.b	#$3F,MtzBoss_FlashCounter(a0)
	bne.s	MTZBoss_Laugh
	st	orb_remove_flag(a0)                    ; set flag for an orb to be removed
	lea	(Boss_AnimationArray).w,a1
	andi.b	#$F0,2(a1)                          ; play hurt animation
	ori.b	#5,2(a1)
	cmpi.b	#0,MtzBoss_health2(a0)
	bls.s	loc_327CA
	move.b	#$A,boss_routine(a0)
	move.w	#-$180,(Boss_Y_vel).w
	subq.b	#1,MtzBoss_health2(a0)
	move.w	#0,(Boss_X_vel).w

loc_327CA:
;	move.w	#0,(Boss_X_vel).w
	rts
; ===========================================================================
MTZBoss_Laugh:
	cmpi.b	#4,(v_player+obRoutine).w        ; is sonic hurt?
	bne.s	@rts                             ; if not, branch
	lea		(Boss_AnimationArray).w,a1
	move.b	2(a1),d0
	andi.b	#$F,d0
	cmpi.b	#4,d0
	beq.s	@rts
	andi.b	#$F0,2(a1)
	ori.b	#5,2(a1)
@rts:
	rts
; ===========================================================================

MTZ_Boss_10_Defeated:
	subq.w	#1,(unk_F75C).w
	cmpi.w	#$3C,(unk_F75C).w
	blo.s	loc_32846
	bmi.s	loc_32820
	bsr.w	BossDefeated
	lea		(Boss_AnimationArray).w,a1
	move.b	#7,2(a1)
	bra.s	loc_32846
; ===========================================================================

loc_32820:
	bset	#0,obRender(a0)
	clr.w	(Boss_X_vel).w
	clr.w	(Boss_Y_vel).w
	addq.b	#2,boss_routine(a0)
	move.w	#-$12,(unk_F75C).w
	lea		(Boss_AnimationArray).w,a1
	move.b	#3,2(a1)
	music	bgm_GHZ
;	bsr.w	JmpTo7_PlayLevelMusic

loc_32846:
	move.w	(Boss_Y_pos).w,obY(a0)
	move.w	(Boss_X_pos).w,obX(a0)
	lea		(Anim_MTZBoss).l,a1
	bsr.w	AnimateBoss
	bsr.w	MtzBoss_UpdateChildspritePositions
	bra.w	JmpTo40_DisplaySprite
; ===========================================================================

MTZ_Boss_12_RunAway:
	move.w	#$400,(Boss_X_vel).w
	move.w	#-$40,(Boss_Y_vel).w
; 	cmpi.w	#MTZBscreenX+$140,(v_limitright2).w                                         ;*
; 	bhs.s	loc_3287E
; 	addq.w	#2,(v_limitright2).w
; 	bra.s	loc_32884
; ===========================================================================

loc_3287E:
	tst.b	obRender(a0)
	bpl.s	JmpTo60_DeleteObject

loc_32884:
	tst.b	(v_bossstatus).w
	bne.s	loc_32894
	move.b	#1,(v_bossstatus).w
;	bsr.w	JmpTo7_LoadPLC_AnimalExplosion

loc_32894:
	bsr.w	Boss_MoveObject
	bsr.w	loc_328C0
	move.w	(Boss_Y_pos).w,obY(a0)
	move.w	(Boss_X_pos).w,obX(a0)
	lea		(Anim_MTZBoss).l,a1
	bsr.w	AnimateBoss
	bsr.w	MtzBoss_UpdateChildspritePositions
	bra.w	JmpTo40_DisplaySprite
; ===========================================================================

JmpTo60_DeleteObject
	moveq	#plcid_GHZ,d0
	jsr		NewPLC		        ; load level object patterns
	moveq	#plcid_GHZ2,d0
	jsr		AddPLC		        ; load level object patterns
	lea     (Pal_GHZ).l,a2
	lea		(v_pal1_wat+$20).w,a1
 	moveq	#$F,d0                         ; move 16 colours
    @movecolour:
 	move.w	(a2)+,(a1)+
	dbf     d0,@movecolour

	move.w	#$7FF,(v_limitbtm1).w
	move.w	#$7FF,(v_limitbtm2).w
 	move.w	#0,(v_limitleft2).w
 	move.w	#$25E0,(v_limitright1).w
 	move.w	#$25E0,(v_limitright2).w
	move.b	#0,(f_lockscreen).w     ; unlock screen
	move.b	#0,(v_bossstatus).w

	jmp	(DeleteObject).l
; ===========================================================================

loc_328C0:
	move.b	obFrame(a0),d0
	jsr	(CalcSine).l
	asr.w	#6,d0
	add.w	(Boss_Y_pos).w,d0
	move.w	d0,obY(a0)
	move.w	(Boss_X_pos).w,obX(a0)
	addq.b	#2,obFrame(a0)

MTZBoss_Flash:
	cmpi.b	#$10,boss_routine(a0)          ; is boss defeated
	bhs.s	@rts                           ; if so, branch
	tst.b	MtzBoss_health(a0)             ; does boss have health left?
	beq.s	loc_32926                      ; if not, branch
	tst.b	obColType(a0)                  ; is boss collision enabled?
	bne.s	@rts                           ; if so, branch
	tst.b	MtzBoss_FlashCounter(a0)       ; has flash timer already been set?
	bne.s	@flash                         ; if so branch
	move.b	#$40,MtzBoss_FlashCounter(a0)
	move.w	#sfx_HitBoss,d0
	jsr	(PlaySound).l
    @flash:
	lea	(v_pal1_wat+$22).w,a1
	moveq	#0,d0                          ; move 0 (black) to d0
	tst.w	(a1)
	bne.s	@setcolour
	move.w	#$EEE,d0                       ; move 0EEE (white) to d0
    @setcolour:
	move.w	d0,(a1)                        ; load colour stored in d0
	subq.b	#1,MtzBoss_FlashCounter(a0)    ; sub 1 from flash counter
	bne.s	@rts                           ; is timer finished
	move.b	#$F,obColType(a0)              ; restore boss collision
@rts:
	rts
; ===========================================================================

loc_32926:
	moveq	#100,d0
	bsr.w	JmpTo8_AddPoints
	move.w	#$EF,(unk_F75C).w
	move.b	#$10,boss_routine(a0)
; 	moveq	#PLCID_Capsule,d0             ; load capsule graphics
; 	bsr.w	JmpTo11_LoadPLC

	rts
; ===========================================================================
; ----------------------------------------------------------------------------
; Object 53 - Shield orbs that surround MTZ boss
; ----------------------------------------------------------------------------
; Sprite_32940:
MTZBossOrbs:
Obj53:
	moveq	#0,d0
	move.b	obRoutine(a0),d0
	move.w	Obj53_Index(pc,d0.w),d1
	jmp	Obj53_Index(pc,d1.w)
; ===========================================================================
; off_3294E:
Obj53_Index:
		dc.w Obj53_Init-Obj53_Index	; 0
		dc.w MTZBossOrb_Rout_2-Obj53_Index	; 2
		dc.w MTZBossOrb_Rout_4-Obj53_Index	; 4
		dc.w MTZBossOrb_Rout_6-Obj53_Index	; 6
		dc.w MTZBossOrb_8_Destroy-Obj53_Index	; 8
; ===========================================================================
; loc_32958:
Obj53_Init:
	movea.l	a0,a1
	moveq	#6,d3                          ; create 7 orbs
	moveq	#0,d2
	bra.s	@orb_init
; ===========================================================================

@orb_create:
	bsr.w	JmpTo17_FindFreeObj
	bne.s	@rts
@orb_init:
	move.b	#$20,obActWid(a1)
	move.l	MtzBoss_parent(a0),MtzBoss_parent(a1)
	move.b	#id_MTZBossOrbs,(a1) ; load obj53
	move.l	#Map_MTZBoss,obMap(a1)
	move.w	#$0380,obGfx(a1)
	ori.b	#4,obRender(a1)
	move.w	#$180,obTimeFrame(a1)
	addq.b	#2,obRoutine(a1)
	move.b	#5,obFrame(a1)
	move.b	byte_329CC(pc,d2.w),objoff_28(a1)
	move.b	byte_329CC(pc,d2.w),objoff_3B(a1)
	move.b	byte_329D3(pc,d2.w),objoff_3A(a1)
	move.b	#$40,orb_orbit_radius(a1)
	move.b	#$87,obColType(a1)
	move.b	#2,obColProp(a1)
	move.b	#0,objoff_3C(a1)
	addq.w	#1,d2
	dbf	d3,@orb_create                ; next orb
@rts:
	rts
; ===========================================================================
byte_329CC:
	dc.b $24
	dc.b $6C	; 1
	dc.b $B4	; 2
	dc.b $FC	; 3
	dc.b $48	; 4
	dc.b $90	; 5
	dc.b $D8	; 6
byte_329D3:
	dc.b   0
	dc.b   1	; 1
	dc.b   1	; 2
	dc.b   0	; 3
	dc.b   1	; 4
	dc.b   1	; 5
	dc.b   0	; 6
; ===========================================================================

MTZBossOrb_Rout_2:
	movea.l	MtzBoss_parent(a0),a1        ; a1= parent object (ship)
	move.w	obY(a1),orb_centre_Y(a0)
	subi.w	#4,orb_centre_Y(a0)
	move.w	obX(a1),orb_centre_X(a0)
	tst.b	orb_remove_flag(a1)          ; do we still need to remove an orb?
	beq.s	loc_32A56                    ; if not, branch
	move.b	#0,orb_remove_flag(a1)       ; clear flag
	addi.b	#1,bouncing_orb_count(a1)
	addq.b	#2,obRoutine(a0)
	move.b	#$3C,orb_timer(a0)
	move.b	#2,obAnim(a0)                ; orb morphing into fake eggman
	move.w	#-$400,obVelY(a0)            ; orb pops upwards
	move.w	#-$80,d1                     ; orb's horizontal momentum
	move.w	(v_player+obX).w,d0
	sub.w	obX(a0),d0
	bpl.s	@chkleftedge
	neg.w	d1

@chkleftedge:
	cmpi.w	#MTZBscreenX+$40,obX(a0)     ; at left edge of screen?                             ;*
	bhs.s	@chkrightedge
	move.w	#$80,d1                      ; move right

@chkrightedge:
	cmpi.w	#MTZBscreenX+$100,obX(a0)    ; at right edge of screen?                            ;*
	blo.s	@facedirection
	move.w	#-$80,d1                     ; move left

@facedirection:
	bclr	#0,obRender(a0)              ; face left
	tst.w	d1
	bmi.s	@setVelX                     ; branch if moving left
	bset	#0,obRender(a0)              ; face right

@setVelX:
	move.w	d1,obVelX(a0)
	bra.s	loc_32A64
; ===========================================================================

loc_32A56:
	cmpi.b	#2,obColProp(a0)
	beq.s	loc_32A64
	move.b	#0,obColType(a1)             ; set no standard collision

loc_32A64:
	bsr.w	loc_32A70
	bsr.w	loc_32B1A
	bra.w	JmpTo40_DisplaySprite
; ===========================================================================

loc_32A70:
	move.b	orb_orbit_radius(a0),d0
	jsr	(CalcSine).l
	move.w	d0,d3
	moveq	#0,d1
	move.b	objoff_33(a1),d1
	muls.w	d1,d0
	move.w	d0,d5
	move.w	d0,d4
	move.b	MtzBoss_timer(a1),d2
	tst.b	objoff_3A(a1)
	beq.s	loc_32A96
	move.w	#$10,d2

loc_32A96:
	muls.w	d3,d2
	move.w	orb_centre_X(a0),d6
	move.b	objoff_28(a0),d0
	jsr	(CalcSine).l
	muls.w	d0,d5
	swap	d5
	add.w	d6,d5
	move.w	d5,obX(a0)
	muls.w	d1,d4
	swap	d4
	move.w	d4,objoff_30(a0)
	move.w	orb_centre_Y(a0),d6
	move.b	objoff_3B(a0),d0
	tst.b	objoff_3A(a1)
	beq.s	loc_32ACA
	move.b	objoff_3C(a0),d0

loc_32ACA:
	jsr	(CalcSine).l
	muls.w	d0,d2
	swap	d2
	add.w	d6,d2
	move.w	d2,obY(a0)
	addq.b	#4,objoff_28(a0)
	tst.b	objoff_3A(a1)
	bne.s	loc_32AEA
	addq.b	#8,objoff_3B(a0)
	rts
; ===========================================================================

loc_32AEA:
	cmpi.b	#-1,objoff_3A(a1)
	beq.s	loc_32B0C
	cmpi.b	#$80,objoff_3A(a1)
	bne.s	loc_32B04
	subq.b	#2,objoff_3C(a0)
	bpl.s	return_32B18
	clr.b	objoff_3C(a0)

loc_32B04:
	move.b	#0,objoff_3A(a1)
	rts
; ===========================================================================

loc_32B0C:
	cmpi.b	#$40,objoff_3C(a0)
	bhs.s	return_32B18
	addq.b	#2,objoff_3C(a0)

return_32B18:
	rts
; ===========================================================================

loc_32B1A:
	move.w	objoff_30(a0),d0
	bmi.s	loc_32B42
	cmpi.w	#$C,d0
	blt.s	loc_32B34
	move.b	#3,obFrame(a0)
	move.w	#$80,obTimeFrame(a0)
	rts
; ===========================================================================

loc_32B34:
	move.b	#4,obFrame(a0)
	move.w	#$100,obTimeFrame(a0)
	rts
; ===========================================================================

loc_32B42:
	cmpi.w	#-$C,d0
	blt.s	loc_32B56
	move.b	#4,obFrame(a0)
	move.w	#$300,obTimeFrame(a0)
	rts
; ===========================================================================

loc_32B56:
	move.b	#5,obFrame(a0)
	move.w	#$380,obTimeFrame(a0)
	rts
; ===========================================================================

MTZBossOrb_Rout_4:
	tst.b	orb_timer(a0)
	bmi.s	loc_32B76
	subq.b	#1,orb_timer(a0)
	bpl.s	loc_32B76
	move.b	#$DA,obColType(a0)

loc_32B76:
	bsr.w	loc_32C66
	bsr.w	JmpTo6_ObjectMoveAndFall
	subi.w	#$20,obVelY(a0)
	cmpi.w	#$180,obVelY(a0)
	blt.s	loc_32B8E
	move.w	#$180,obVelY(a0)

loc_32B8E:
	cmpi.w	#MTZBscreenY+$AC,obY(a0)                                                      ;*
	blo.s	loc_32BB0
	move.w	#MTZBscreenY+$AC,obY(a0)                                                      ;*
	move.w	#MTZBscreenY+$AC,Mtz_Pinch_Rout(a0)                                                ;*
	move.b	#1,bouncing_orb_count(a0)
	addq.b	#2,obRoutine(a0)
	bsr.w	loc_32C4C

loc_32BB0:
	bsr.w	loc_32BC2
	lea	(Anim_MTZBoss).l,a1
	bsr.w	JmpTo21_AnimateSprite
	bra.w	JmpTo40_DisplaySprite
; ===========================================================================

loc_32BC2:
	cmpi.b	#-2,obColProp(a0)
	bgt.s	return_32BDA
	move.b	#$14,obFrame(a0)
	move.b	#6,obAnim(a0)
	addq.b	#2,obRoutine(a0)

return_32BDA:
	rts
; ===========================================================================

MTZBossOrb_Rout_6:
	tst.b	orb_timer(a0)
	bmi.s	loc_32BEE
	subq.b	#1,orb_timer(a0)
	bpl.s	loc_32BEE
	move.b	#$DA,obColType(a0)

loc_32BEE:
	bsr.w	loc_32C66
	cmpi.b	#$B,obFrame(a0)
	bne.s	loc_32BB0
	move.b	bouncing_orb_count(a0),d0
	jsr	(CalcSine).l
	neg.w	d0
	asr.w	#2,d0
	add.w	Mtz_Pinch_Rout(a0),d0
	cmpi.w	#MTZBscreenY+$AC,d0                                                             ;*
	bhs.s	loc_32C38
	move.w	d0,obY(a0)
	addq.b	#1,bouncing_orb_count(a0)
	btst	#0,bouncing_orb_count(a0)
	beq.w	JmpTo40_DisplaySprite
	moveq	#-1,d0
	btst	#0,obRender(a0)
	beq.s	loc_32C30
	neg.w	d0

loc_32C30:
	add.w	d0,obX(a0)
	bra.w	JmpTo40_DisplaySprite
; ===========================================================================

loc_32C38:
	move.w	#MTZBscreenY+$AC,obY(a0)                                                       ;*
	bsr.w	loc_32C4C
	move.b	#1,bouncing_orb_count(a0)
	bra.w	JmpTo40_DisplaySprite
; ===========================================================================

loc_32C4C:
	move.w	(v_player+obX).w,d0
	sub.w	obX(a0),d0
	bpl.s	loc_32C5E
	bclr	#0,obRender(a0)
	rts
; ===========================================================================

loc_32C5E:
	bset	#0,obRender(a0)
	rts
; ===========================================================================

loc_32C66:
	cmpi.b	#4,(v_player+obRoutine).w         ; is sonic hurt?
	bne.s	loc_32C82

; loc_32C76:
	move.b	#$14,obFrame(a0)
	move.b	#6,obAnim(a0)

loc_32C82:
	cmpi.b	#-1,obColProp(a0)
	bgt.s	return_32C96
	move.b	#$14,obFrame(a0)
	move.b	#6,obAnim(a0)

return_32C96:
	rts
; ===========================================================================

MTZBossOrb_8_Destroy:
	move.b	#sfx_Bomb,d0
	bsr.w	JmpTo10_PlaySound
	movea.l	MtzBoss_parent(a0),a1 ; a1=object
	subi.b	#1,bouncing_orb_count(a1)
	bra.w	JmpTo61_DeleteObject
; ===========================================================================

MTZBoss_LazerObject:           ; Main boss object Routine $4
	moveq	#0,d0
	move.b	ob2ndRout(a0),d0
	move.w	MTZBoss_Lazer_2ndIndex(pc,d0.w),d0
	jmp	MTZBoss_Lazer_2ndIndex(pc,d0.w)
; ===========================================================================
MTZBoss_Lazer_2ndIndex:
		dc.w MTZBoss_Lazer_Init-MTZBoss_Lazer_2ndIndex	; 0
		dc.w MTZBoss_Lazer_Move-MTZBoss_Lazer_2ndIndex	; 2
; ===========================================================================

MTZBoss_Lazer_Init:
	move.l	#Map_MTZBoss,obMap(a0)
	move.w	#$0380,obGfx(a0)
	ori.b	#4,obRender(a0)
	move.w	#$280,obTimeFrame(a0)
	move.b	#$12,obFrame(a0)
	addq.b	#2,ob2ndRout(a0)
	movea.l	MtzBoss_parent(a0),a1 ; a1= parent object
	move.b	#$50,obActWid(a0)
	move.w	obX(a1),obX(a0)
	move.w	obY(a1),obY(a0)
	addi.w	#7,obY(a0)
	subi.w	#4,obX(a0)
	move.w	#-$400,d0
	btst	#0,obRender(a1)
	beq.s	@firelazer
	neg.w	d0
	addi.w	#8,obX(a0)

@firelazer:
	move.w	d0,obVelX(a0)
	move.b	#$99,obColType(a0)
	move.b	#sfx_Saw,d0
	bsr.w	JmpTo10_PlaySound

MTZBoss_Lazer_Move:
	bsr.w	JmpTo24_ObjectMove
	cmpi.w	#MTZBscreenX,obX(a0)                                                    ;*
	blo.w	JmpTo61_DeleteObject
	cmpi.w	#MTZBscreenX+$140,obX(a0)                                               ;*
	bhs.w	JmpTo61_DeleteObject
	bra.w	JmpTo40_DisplaySprite
; ===========================================================================

MTZBoss_LazerGunObject:       ; Main boss object Routine $6
	movea.l	MtzBoss_parent(a0),a1     ; a1= parent object
	cmpi.b	#id_MTZBoss,(a1)
	bne.w	DeleteObject              ; delete if main boss object is gone
	move.w	obX(a1),obX(a0)           ; match position of parent object
	move.w	obY(a1),obY(a0)
	bclr	#0,obRender(a0)           ; match direction of parent object
	btst	#0,obRender(a1)
	beq.w	DisplaySprite
	bset	#0,obRender(a0)
	bra.w	DisplaySprite
; ===========================================================================
; animation script
; off_32D7A:
Anim_MTZBoss:
		dc.w @ship-Anim_MTZBoss	        ; 0
		dc.w @flame-Anim_MTZBoss	; 1
		dc.w @orb_morph-Anim_MTZBoss	; 2
		dc.w @face_normal-Anim_MTZBoss	; 3
		dc.w @face_laugh-Anim_MTZBoss	; 4
		dc.w @face_hit-Anim_MTZBoss	; 5
		dc.w @orb_pop-Anim_MTZBoss	; 6
		dc.w @face_defeated-Anim_MTZBoss; 7
		dc.w @face_hit2-Anim_MTZBoss	; 8
		dc.w @face_hit3-Anim_MTZBoss	; 9
@ship:	        dc.b  $F,  2,$FF
@flame:	        dc.b   1,  0,  1,$FF
@orb_morph:	dc.b   3,  5,  5,  5,  5,  5,  5,  5,  5,  6,  7,  6,  7,  6,  7,  8
		dc.b   9, $A, $B,$FE,  1; 16
@face_normal:	dc.b   7, $C, $D,$FF
@face_laugh:	dc.b   7, $E, $F, $E, $F, $E, $F, $E, $F,$FD,  3
@face_hit:	dc.b   7,$10,$10,$10,$10,$10,$10,$10,$10,$FD,  3
@orb_pop:	dc.b   1,$14,$FC
@face_defeated:	dc.b   7,$11,$FF
@face_hit2:	dc.b   7,$10,$14,$FD,  3
@face_hit3:	dc.b   7,$10,$14,$13,$FD,  3
		even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Map_MTZBoss:	
		dc.w MTZ_Frame_00-Map_MTZBoss, MTZ_Frame_01-Map_MTZBoss
		dc.w MTZ_Frame_02-Map_MTZBoss, MTZ_Frame_03-Map_MTZBoss
		dc.w MTZ_Frame_04-Map_MTZBoss, MTZ_Frame_05-Map_MTZBoss
		dc.w MTZ_Frame_06-Map_MTZBoss, MTZ_Frame_07-Map_MTZBoss
		dc.w MTZ_Frame_08-Map_MTZBoss, MTZ_Frame_09-Map_MTZBoss
		dc.w MTZ_Frame_0A-Map_MTZBoss, MTZ_Frame_0B-Map_MTZBoss
		dc.w MTZ_Frame_0C-Map_MTZBoss, MTZ_Frame_0D-Map_MTZBoss
		dc.w MTZ_Frame_0E-Map_MTZBoss, MTZ_Frame_0F-Map_MTZBoss
		dc.w MTZ_Frame_10-Map_MTZBoss, MTZ_Frame_11-Map_MTZBoss
		dc.w MTZ_Frame_12-Map_MTZBoss, MTZ_Frame_13-Map_MTZBoss
		dc.w MTZ_Frame_14-Map_MTZBoss
MTZ_Frame_00:	dc.b 1                               ; exhaust flame
		dc.b 0, 5, 0, $E0, $1C
MTZ_Frame_01:	dc.b 1                               ; exhaust flame 2
		dc.b 0, 5, 0, $E4, $1C
MTZ_Frame_02:	dc.b 5                               ; egg pod
		dc.b $D8, 5, 0, $A0, 2
		dc.b $E8, 5, 0, $A4, $10
		dc.b $F8, $F, $20, $88, $F0
		dc.b $F8, 7, $20, $98, $10
		dc.b $F8, 2, $20, 3, $E8	
MTZ_Frame_03:	dc.b 1                               ; Orb Close
		dc.b $F4, $A, $20, $E, $F4
MTZ_Frame_04:	dc.b 1                               ; Orb Mid
		dc.b $F4, $A, $20, $6F, $F4	
MTZ_Frame_05:	dc.b 1                               ; Orb Far
		dc.b $F8, 5, $20, $78, $F8	
MTZ_Frame_06:	dc.b 1                               ; yellow blob
		dc.b $F4, 6, $20, $17, $F8	
MTZ_Frame_07:	dc.b 1                               ; green blob
		dc.b $F8, 9, $20, $1D, $F4	
MTZ_Frame_08:	dc.b 1                               ; white blob
		dc.b $F4, 6, $20, $23, $F8	
MTZ_Frame_09:	dc.b 1                               ; smallest fake eggman
		dc.b $F4, $A, 0, $29, $F4	
MTZ_Frame_0A:	dc.b 1                               ; mid fake eggman
		dc.b $F0, $F, 0, $32, $F0	     
MTZ_Frame_0B:	dc.b 4                               ; big fake eggman
		dc.b $E8, $A, 0, $42, $E8	
		dc.b $E8, $A, 0, $4B, 0	
		dc.b 0, $A, 0, $54, $E8	
		dc.b 0, $A, 0, $5D, 0	
MTZ_Frame_0C:	dc.b 2                               ; robotnik face normal
		dc.b $E8, $D, 0, $B0, $F0
		dc.b $E8, 5, 0, $A8, $E0
MTZ_Frame_0D:	dc.b 2                               ; robotnik face normal 2
		dc.b $E8, $D, 0, $B8, $F0
		dc.b $E8, 5, 0, $A8, $E0
MTZ_Frame_0E:	dc.b 2                               ; robotnik face laugh
		dc.b $E8, $D, 0, $C0, $F0
		dc.b $E8, 5, 0, $AC, $E0
MTZ_Frame_0F:	dc.b 2                               ; robotnik face laugh 2
		dc.b $E8, $D, 0, $C8, $F0
		dc.b $E8, 5, 0, $AC, $E0
MTZ_Frame_10:	dc.b 2                               ; robotnik face hit
		dc.b $E8, $D, 0, $D0, $F0
		dc.b $E8, 5, 0, $AC, $E0
MTZ_Frame_11:	dc.b 2                               ; robotnik face defeated
		dc.b $E8, $D, 0, $D8, $F0
		dc.b $E8, 5, 0, $AC, $E0
MTZ_Frame_12:	dc.b 2                               ; lazer beam
		dc.b $F8, $D, $20, 6, $E0	
		dc.b $F8, $D, $28, 6, 0	
MTZ_Frame_13:	dc.b 1                               ; lazer gun ship part
		dc.b $F8, 2, $20, 0, $E0	
MTZ_Frame_14:	dc.b 4                               ; fake eggman burst
		dc.b $E8, $A, 0, $66, $E8	
		dc.b $E8, $A, 8, $66, 0	
		dc.b 0, $A, $10, $66, $E8	
		dc.b 0, $A, $18, $66, 0	
		even
; ===========================================================================

JmpTo40_DisplaySprite
	move.w	obTimeFrame(a0),d0
	jmp	(DisplaySprite3).l
; ===========================================================================

JmpTo61_DeleteObject 
	jmp	(DeleteObject).l
; ===========================================================================

JmpTo17_FindFreeObj 
	jmp	(FindFreeObj).l
; ===========================================================================

JmpTo10_PlaySound 
	jmp	(PlaySound).l
; ===========================================================================

JmpTo21_AnimateSprite 
	jmp	(AnimateSprite).l
; ===========================================================================

JmpTo11_LoadPLC
 	jmp	(AddPLC).l
; ===========================================================================

JmpTo8_AddPoints 
	jmp	(AddPoints).l
; ===========================================================================

JmpTo7_PlayLevelMusic 
	jmp	(PlaySound).l
; ===========================================================================

;JmpTo7_LoadPLC_AnimalExplosion 
;	jmp	(LoadAnimalPLC).l
; ===========================================================================

JmpTo6_ObjectMoveAndFall 
	jmp	(ObjectFall).l
; ===========================================================================
; loc_32F88:
JmpTo24_ObjectMove 
	jmp	(SpeedToPos).l
; ===========================================================================
	align 4
; --------------------------------------------------------------------------
; =========================================================================
;
; =========================================================================

Boss_MoveObject:
	move.l	(Boss_X_pos).w,d2
	move.l	(Boss_Y_pos).w,d3
	move.w	(Boss_X_vel).w,d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d2
	move.w	(Boss_Y_vel).w,d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d3
	move.l	d2,(Boss_X_pos).w
	move.l	d3,(Boss_Y_pos).w
	rts
; ===========================================================================
; a1 = animation script pointer
;AnimationArray: up to 8 2-byte entries:
	; 4-bit: anim_ID (1)
	; 4-bit: anim_ID (2) - the relevant one
	; 4-bit: anim_frame
	; 4-bit: anim_timer until next anim_frame
; if anim_ID (1) & (2) are not equal, new animation data is loaded

;loc_2D604:
AnimateBoss:
	moveq	#0,d6
	movea.l	a1,a4		; address of animation script
	lea	(Boss_AnimationArray).w,a2
	lea	mainspr_mapframe(a0),a3	; mapframe 1 (main object)
	tst.b	(a3)
	bne.s	@skip1
	addq.w	#2,a2
	bra.s	@skip2
; ----------------------------------------------------------------------------
@skip1:
	bsr.w	AnimateBoss_Loop

@skip2:
	moveq	#0,d6
	move.b	mainspr_childsprites(a0),d6	; number of child sprites
	subq.w	#1,d6		; = amount of iterations to run the code from AnimateBoss_Loop
	bmi.s	return_2D690	; if was 0, don't run
	lea	sub2_mapframe(a0),a3	; mapframe 2
; ----------------------------------------------------------------------------
;loc_2D62A:
AnimateBoss_Loop:	; increases a2 (AnimationArray) by 2 each iteration
	movea.l	a4,a1
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d4
	move.b	(a2)+,d0
	move.b	d0,d1
	lsr.b	#4,d1		; anim_ID (1)
	andi.b	#$F,d0		; anim_ID (2)
	move.b	d0,d2
	cmp.b	d0,d1
	beq.s	@skip1
	st	d4		; anim_IDs not equal
@skip1:
	move.b	d0,d5
	lsl.b	#4,d5
	or.b	d0,d5		; anim_ID (2) in both nybbles
	move.b	(a2)+,d0
	move.b	d0,d1
	lsr.b	#4,d1		; anim_frame
	tst.b	d4		; are the anim_IDs equal?
	beq.s	@skip2
	moveq	#0,d0
	moveq	#0,d1		; reset d0,d1 if anim_IDs not equal
@skip2:
	andi.b	#$F,d0		; timer until next anim_frame
	subi.b	#1,d0
	bpl.s	loc_2D67C	; timer not yet at 0, and anim_IDs are equal

	add.w	d2,d2		; anim_ID (2)
	adda.w	(a1,d2.w),a1	; address of animation data with this ID
	move.b	(a1),d0		; animation speed
	move.b	1(a1,d1.w),d2	; mapping_frame of first/next anim_frame
	bmi.s	AnimateBoss_CmdParam	; if animation command parameter, branch

loc_2D672:
	andi.b	#$7F,d2
	move.b	d2,(a3)		; store mapping_frame to OST of object
	addi.b	#1,d1		; anim_frame

loc_2D67C:
	lsl.b	#4,d1
	or.b	d1,d0
	move.b	d0,-1(a2)	; (2nd byte) anim_frame and anim_timer
	move.b	d5,-2(a2)	; (1st byte) anim_ID (both nybbles)
	adda.w	#6,a3		; mapping_frame of next subobject
	dbf	d6,AnimateBoss_Loop

return_2D690:
	rts
; ----------------------------------------------------------------------------
;loc_2D692:
AnimateBoss_CmdParam:	; parameter $FF - reset animation to first frame
	addq.b	#1,d2
	bne.s	@incrementroutine
	move.b	#0,d1
	move.b	1(a1),d2
	bra.s	loc_2D672
; ----------------------------------------------------------------------------
@incrementroutine:		; parameter $FE - increase boss routine
	addq.b	#1,d2
	bne.s	@changeanim
	addi.b	#2,obAngle(a0)	; boss routine
	rts
; ----------------------------------------------------------------------------
@changeanim:		; parameter $FD - change anim_ID to byte after parameter
	addq.b	#1,d2
	bne.s	@jumpbackframe
	andi.b	#$F0,d5		; keep anim_ID (1)
	or.b	2(a1,d1.w),d5	; set anim_ID (2)
	bra.s	loc_2D67C
; ----------------------------------------------------------------------------
@jumpbackframe:		; parameter $FC - jump back to anim_frame d1
	addq.b	#1,d2
	bne.s	@end	; rts
	moveq	#0,d3
	move.b	2(a1,d1.w),d1	; anim_frame
	move.b	1(a1,d1.w),d2	; mapping_frame
	bra.s	loc_2D672
; ----------------------------------------------------------------------------
@end:		; parameter $80-$FB
	rts
; ===========================================================================
	
