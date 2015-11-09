; ---------------------------------------------------------------------------
; Object 72 - teleporter (SBZ)
; ---------------------------------------------------------------------------
tele_coords_left = $3A		; number of coords left to go to *4 (2 bytes)
tele_list_pos	= $3C		; Rom address of x y coordinates (4 bytes)
tele_x_target	= $36		; target for sonic X (2 bytes)
tele_y_target	= $38		; target for sonic Y (2 bytes)
; ---------------------------------------------------------------------------

Teleport:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Tele_Index(pc,d0.w),d1
		jsr	Tele_Index(pc,d1.w)
		obRanges	@delete
		rts	

@delete:
        if S3KObjectManager=1
		obMarkGone
        endif
		jmp	DeleteObject
; ===========================================================================
Tele_Index:	dc.w Tele_Main-Tele_Index
			dc.w Tele_Idle-Tele_Index
			dc.w Tele_Charge-Tele_Index
			dc.w Tele_Move-Tele_Index
; ===========================================================================

Tele_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	obSubtype(a0),d0
		add.w	d0,d0
		andi.w	#$1E,d0
		lea	Tele_Data(pc),a2
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,tele_coords_left(a0)
		move.l	a2,tele_list_pos(a0)
		move.w	(a2)+,tele_x_target(a0)
		move.w	(a2)+,tele_y_target(a0)

Tele_Idle:	; Routine 2
		lea	(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		btst	#0,obStatus(a0)
		beq.s	loc_166E0
		addi.w	#$F,d0

loc_166E0:
		cmpi.w	#$10,d0
		bcc.s	locret_1675C
		move.w	obY(a1),d1
		sub.w	obY(a0),d1
		addi.w	#$20,d1
		cmpi.w	#$40,d1
		bcc.s	locret_1675C
		tst.b	(f_lockmulti).w
		bne.s	locret_1675C
		cmpi.b	#7,obSubtype(a0)
		bne.s	loc_1670E
		cmpi.w	#50,(v_rings).w
		bcs.s	locret_1675C

loc_1670E:
		addq.b	#2,obRoutine(a0)
		move.b	#$81,(f_lockmulti).w ; lock controls
		move.b	#id_Roll,obAnim(a1) ; use Sonic's rolling animation
		move.w	#$800,obInertia(a1)
		move.w	#0,obVelX(a1)
		move.w	#0,obVelY(a1)
		bclr	#5,obStatus(a0)
		bclr	#5,obStatus(a1)
		bset	#1,obStatus(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		clr.b	$32(a0)
		sfx	sfx_Roll	; play Sonic rolling sound

locret_1675C:
		rts	
; ===========================================================================

Tele_Charge:	; Routine 4
		lea		(v_player).w,a1
		ori.w	#$8000,obGfx(a1)
;		move.b	$32(a0),d0
;		addq.b	#2,$32(a0)
;		jsr		(CalcSine).l
;		asr.w	#5,d0
;		move.w	obY(a0),d2
;		sub.w	d0,d2
;		move.w	d2,obY(a1)
;		cmpi.b	#$80,$32(a0)
;		bne.s	locret_16796
		bsr.w	sub_1681C
		addq.b	#2,obRoutine(a0)
;		sfx	sfx_Teleport	; play teleport sound

locret_16796:
		rts	
; ===========================================================================

Tele_Move:	; Routine 6
		addq.l	#4,sp			; skip obrange check
		lea	(v_player).w,a1
		subq.b	#1,$2E(a0)
		bpl.s	Tele_SpeedToPos
		move.w	tele_x_target(a0),obX(a1)
		move.w	tele_y_target(a0),obY(a1)
		moveq	#0,d1
		move.b	tele_coords_left(a0),d1
		addq.b	#4,d1
		cmp.b	$3B(a0),d1
		bcs.s	loc_167C2
		moveq	#0,d1
		bra.s	loc_16800
; ===========================================================================

loc_167C2:
		move.b	d1,tele_coords_left(a0)
		movea.l	tele_list_pos(a0),a2
		move.w	(a2,d1.w),tele_x_target(a0)
		move.w	2(a2,d1.w),tele_y_target(a0)
		bra.w	sub_1681C
; ===========================================================================

Tele_SpeedToPos:
		move.l	obX(a1),d2
		move.l	obY(a1),d3
		move.w	obVelX(a1),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	obVelY(a1),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,obX(a1)
		move.l	d3,obY(a1)
		rts	
; ===========================================================================

loc_16800:
		andi.w	#$7FF,obY(a1)
		clr.b	obRoutine(a0)
		clr.b	(f_lockmulti).w
		move.w	#0,obVelX(a1)
		move.w	#-$800,obVelY(a1)
		sfx     sfx_Dash                ; Play launch sound
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_1681C:
		moveq	#0,d0
		move.w	#$800,d2
		move.w	tele_x_target(a0),d0
		sub.w	obX(a1),d0
		bge.s	loc_16830
		neg.w	d0
		neg.w	d2

loc_16830:
		moveq	#0,d1
		move.w	#$800,d3
		move.w	tele_y_target(a0),d1
		sub.w	obY(a1),d1
		bge.s	loc_16844
		neg.w	d1
		neg.w	d3

loc_16844:
		cmp.w	d0,d1
		bcs.s	loc_1687A
		moveq	#0,d1
		move.w	tele_y_target(a0),d1
		sub.w	obY(a1),d1
		swap	d1
		divs.w	d3,d1
		moveq	#0,d0
		move.w	tele_x_target(a0),d0
		sub.w	obX(a1),d0
		beq.s	loc_16866
		swap	d0
		divs.w	d1,d0

loc_16866:
		move.w	d0,obVelX(a1)
		move.w	d3,obVelY(a1)
		tst.w	d1
		bpl.s	loc_16874
		neg.w	d1

loc_16874:
		move.w	d1,$2E(a0)
		rts	
; ===========================================================================

loc_1687A:
		moveq	#0,d0
		move.w	tele_x_target(a0),d0
		sub.w	obX(a1),d0
		swap	d0
		divs.w	d2,d0
		moveq	#0,d1
		move.w	tele_y_target(a0),d1
		sub.w	obY(a1),d1
		beq.s	loc_16898
		swap	d1
		divs.w	d0,d1

loc_16898:
		move.w	d1,obVelY(a1)
		move.w	d2,obVelX(a1)
		tst.w	d0
		bpl.s	loc_168A6
		neg.w	d0

loc_168A6:
		move.w	d0,$2E(a0)
		rts	
; End of function sub_1681C

; ===========================================================================
Tele_Data:	dc.w @type00-Tele_Data, @type01-Tele_Data, @type02-Tele_Data
		dc.w @type03-Tele_Data, @type04-Tele_Data, @type05-Tele_Data
		dc.w @type06-Tele_Data, @type07-Tele_Data

@type00:	dc.w 4
		dc.w $794, $98C

@type01:	dc.w 20
		dc.w  $70, $580
		dc.w  $80, $590
		dc.w $330, $590
		dc.w $340, $5A0
		dc.w $340, $310

@type02:	dc.w $1C
		dc.w $794, $2E8
		dc.w $7A4, $2C0
		dc.w $7D0, $2AC
		dc.w $858, $2AC
		dc.w $884, $298
		dc.w $894, $270
		dc.w $894, $190

@type03:	dc.w 4
		dc.w $894, $690

@type04:	dc.w $1C, $1194, $470
		dc.w $1184, $498, $1158
		dc.w $4AC, $FD0, $4AC
		dc.w $FA4, $4C0, $F94
		dc.w $4E8, $F94, $590
@type05:	dc.w 4,	$1294, $490
@type06:	dc.w $1C, $1594, $FFE8
		dc.w $1584, $FFC0, $1560
		dc.w $FFAC, $14D0, $FFAC
		dc.w $14A4, $FF98, $1494
		dc.w $FF70, $1494, $FD90
@type07:	dc.w 4,	$894, $90
