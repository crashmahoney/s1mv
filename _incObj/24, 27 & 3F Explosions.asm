; ---------------------------------------------------------------------------
; Object 24 - buzz bomber missile vanishing (unused?)
; ---------------------------------------------------------------------------

GunstarExplosion:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	GExpl_Index(pc,d0.w),d1
		jmp	GExpl_Index(pc,d1.w)
; ===========================================================================
GExpl_Index:	dc.w GExpl_Main-GExpl_Index
		dc.w GExpl_Spawner-GExpl_Index
		dc.w GExpl_Animate-GExpl_Index
; ===========================================================================
;	dc.w	number of explosions, time between explosions, gravity
;	dc.w	xpos, ypos, xspeed, yspeed
GExplosion0:
	dc.w	5,	4,	0
	dc.w	0,	0,	300,	-500
	dc.w	3,	-20,	-300,	-500
	dc.w	-3,	-40,	100,	-500
	dc.w	0,	-60,	0,	-500
	dc.w	2,	-80,	-100,	-1000

GExplosion1:
	dc.w	8,	1,	1
	dc.w	0,	0,	600,	-900	
	dc.w	0,	-3,	400,	-1000	
	dc.w	0,	-6,	200,	-1400	
	dc.w	0,	-9,	-190,	-1300	
	dc.w	0,	-12,	-500,	-1100	
	dc.w	0,	-15,	-400,	-800	
	dc.w	0,	-18,	-300,	-500	
	dc.w	0,	-21,	-100,	-200	

GExplosion2:
	dc.w	5,	6,	1
	dc.w	0,	0,	100,	-700
	dc.w	10,	-20,	100,	-800
	dc.w	20,	-40,	100,	-1000
	dc.w	30,	-60,	100,	-1300
	dc.w	40,	-80,	100,	-1500	

GExplosion3:
	dc.w	5,	3,	1
	dc.w	0,	0,	300,	-800
	dc.w	3,	-20,	-300,	-800
	dc.w	-3,	-40,	100,	-1000
	dc.w	0,	-60,	0,	-1000
	dc.w	2,	-80,	-100,	-1500	

GExplosion4:
	dc.w	6,	3,	1
	dc.w	0,	0,	600,	-700	
	dc.w	-6,	-10,	400,	-800	
	dc.w	-16,	-20,	200,	-1200	
	dc.w	-30,	-40,	-190,	-1000	
	dc.w	-50,	-60,	-500,	-900	
	dc.w	-70,	-80,	-500,	-600	

GExplosion5:
	dc.w	10,	3,	0
	dc.w	0,	-10,	0,	-600	
	dc.w	0,	-30,	50,	-600	
	dc.w	-2,	-45,	100,	-700	
	dc.w	-2,	-55,	200,	-700	
	dc.w	-4,	-60,	50,	-800	
	dc.w	-4,	-62,	200,	-800		
	dc.w	-6,	-60,	300,	-700		
	dc.w	-6,	-55,	100,	-700		
	dc.w	-8,	-45,	400,	-600		
	dc.w	-8,	-30,	200,	-600		

GExplosion6:
	dc.w	10,	4,	0
	dc.w	0,	-10,	0,	-600	
	dc.w	10,	0,	50,	-600	
	dc.w	-5,	8,	-100,	-700	
	dc.w	20,	-5,	100,	-700	
	dc.w	10,	-20,	-50,	-800	
	dc.w	-17,	3,	-200,	-800		
	dc.w	-5,	-5,	0,	-700		
	dc.w	8,	-15,	150,	-700		
	dc.w	-8,	7,	400,	-600		
	dc.w	16,	-30,	-200,	-600	

Explosion_Index:
	dc.l	GExplosion0
	dc.l	GExplosion1
	dc.l	GExplosion2
	dc.l	GExplosion3
	dc.l	GExplosion4
	dc.l	GExplosion5
	dc.l	GExplosion6
	dc.l	GExplosion4
; ===========================================================================
gexpl_count	= $30
gexpl_timer1	= $32
gexpl_gravity	= $34
gexpl_address	= $36
gexpl_timer2	= $3A
gexpl_xflip	= $3C
; ===========================================================================

GExpl_Main:	; Routine 0
		move.b	#0,obColType(a0)
		sfx	sfx_Bomb
		addq.b	#2,obRoutine(a0)
		jsr	RandomNumber
		and.l	#$00010007,d0
		add.w	d0,d0
		add.w	d0,d0
		lea	Explosion_Index(pc,d0.w),a2
		movea.l	(a2),a2
		swap	d0
		move.w	d0,gexpl_xflip(a0)

		move.w	(a2)+,gexpl_count(a0)			; how many explosions to make
		move.w	(a2),gexpl_timer1(a0)			; timer value to reset to
		move.w	(a2)+,gexpl_timer2(a0)			; initialise actual timer
		move.w	(a2)+,gexpl_gravity(a0)			; 1 if gravity applied, 0 if not
		move.l	a2,gexpl_address(a0)			; address of first explosion data
		bra.s	CreateExplosion				; skip timer for first explosion

GExpl_Spawner:	; Routine 2
		sub.w	#1,gexpl_timer2(a0)			; count down timer
		bmi.s	@timerfinished				; if 0, branch
		rts

	@timerfinished:		
		move.w	gexpl_timer1(a0),gexpl_timer2(a0)	; reset timer
		movea.l	gexpl_address(a0),a2
CreateExplosion:
		bsr.w	FindFreeObj				; find free object slot
		beq.s	@ok					; if ok, branch
		rts
	@ok:
		move.b	#id_GunstarExplosion,(a1)		; create new object

		tst.w	gexpl_xflip(a0)				; check if explosion pattern should be flipped
		bne.s	@xflip					; branch if so

		move.w	obX(a0),d0
		add.w	(a2)+,d0
		move.w	d0,obX(a1)
		move.w	obY(a0),d0
		add.w	(a2)+,d0
		move.w	d0,obY(a1)
		move.w	(a2)+,obVelX(a1)
		move.w	(a2)+,obVelY(a1)
		bra.s	@continue				; skip over the flipped version
	@xflip:
		move.w	obX(a0),d0
		sub.w	(a2)+,d0
		move.w	d0,obX(a1)
		move.w	obY(a0),d0
		add.w	(a2)+,d0
		move.w	d0,obY(a1)
		move.w	(a2)+,obVelX(a1)
		neg.w	obVelX(a1)
		move.w	(a2)+,obVelY(a1)

	@continue:
		move.l	a2,gexpl_address(a0)			; remember next explosion address
		move.w	gexpl_gravity(a0),gexpl_gravity(a1)
		move.l	#Map_GunstarExplosion,obMap(a1)
		move.w	#$2580,obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#$100,obPriority(a1)
		move.b	#0,obColType(a1)
		move.b	#$C,obActWid(a1)
		move.b	#3,obTimeFrame(a1)
		move.b	#1,obFrame(a1)
		move.b	#4,obRoutine(a1)

		sub.w	#1,gexpl_count(a0)			; sub 1 from explosions remaining
		beq.w	DeleteObject				; if 0, delete object
		bmi.w	DeleteObject
		bra.w	GExpl_Spawner

; ===========================================================================
GExpl_Animate:	; Routine 4
		tst.w	gexpl_gravity(a0)
		beq.s	@nogravity
		bsr.w	ObjectFall
		bra.s	@animate
	@nogravity:	
		bsr.w	SpeedToPos
	@animate:
		subq.b	#1,obTimeFrame(a0) ; subtract 1 from frame duration
		bpl.s	@display
		move.b	#3,obTimeFrame(a0) ; set frame duration to 9 frames
		addq.b	#1,obFrame(a0)	; next frame
		cmpi.b	#9,obFrame(a0)	; has animation completed?
		beq.w	DeleteObject	; if yes, branch


	@display:
		bra.w	DisplaySprite

; ===========================================================================
Map_GunstarExplosion:
	include	"_maps/Gunstar Explosion.asm"
	even
; ===========================================================================

; ---------------------------------------------------------------------------
; Object 27 - explosion	from a destroyed enemy or monitor
; ---------------------------------------------------------------------------

ExplosionItem:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	ExItem_Index(pc,d0.w),d1
		jmp	ExItem_Index(pc,d1.w)
; ===========================================================================
ExItem_Index:	dc.w ExItem_Animal-ExItem_Index
		dc.w ExItem_Main-ExItem_Index
		dc.w ExItem_Animate-ExItem_Index
; ===========================================================================

ExItem_Animal:	; Routine 0
		addq.b	#2,obRoutine(a0)
; 		cmpi.b	#id_Tropic,(v_zone).w ; +++ check if level is HUBZ
; 		beq.s	ExItem_Main	; if so, branch
                bsr.w	FindFreeObj
		bne.s	ExItem_Main
		move.b	#id_Animals,0(a1) ; load animal object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	$3E(a0),$3E(a1)

ExItem_Main:	; Routine 2
		addq.b	#2,obRoutine(a0)
		move.l	#Map_ExplodeItem,obMap(a0)
		move.w	#$5A0,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$80,obPriority(a0)
		move.b	#0,obColType(a0)
		move.b	#$C,obActWid(a0)
		move.b	#3,obTimeFrame(a0) ; set frame duration to 7 frames
		move.b	#0,obFrame(a0)
		sfx	sfx_BreakItem	; play breaking enemy sound

ExItem_Animate:	; Routine 4 (2 for ExplosionBomb)
		subq.b	#1,obTimeFrame(a0) ; subtract 1 from frame duration
		bpl.s	@display
		move.b	#5,obTimeFrame(a0) ; set frame duration to 7 frames
		addq.b	#1,obFrame(a0)	; next frame
		cmpi.b	#5,obFrame(a0)	; is the final frame (05) displayed?
		beq.w	DeleteObject	; if yes, branch

	@display:
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3F - explosion	from a destroyed boss, bomb or cannonball
; ---------------------------------------------------------------------------

ExplosionBomb:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	ExBom_Index(pc,d0.w),d1
		jmp	ExBom_Index(pc,d1.w)
; ===========================================================================
ExBom_Index:	dc.w ExBom_Main-ExBom_Index
		dc.w ExBom_Animate-ExBom_Index
; ===========================================================================

ExBom_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_ExplodeBomb,obMap(a0)
		move.w	#$5A0,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#0,obColType(a0)
		move.b	#$C,obActWid(a0)
		move.b	#2,obTimeFrame(a0)
		move.b	#0,obFrame(a0)
		sfx	sfx_Bomb,1	; play exploding bomb sound
ExBom_Animate:	; Routine 4 (2 for ExplosionBomb)
		subq.b	#1,obTimeFrame(a0) ; subtract 1 from frame duration
		bpl.s	@display
		move.b	#4,obTimeFrame(a0) ; set frame duration to 7 frames
		addq.b	#1,obFrame(a0)	; next frame
		cmpi.b	#6,obFrame(a0)	; is the final frame (05) displayed?
		beq.w	DeleteObject	; if yes, branch

	@display:
		bra.w	DisplaySprite
