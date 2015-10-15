; ---------------------------------------------------------------------------
; Subroutine to	make Sonic run around loops (GHZ/SLZ)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Loops:				; XREF: Obj01_Control
	;	cmpi.b	#id_SLZ,(v_zone).w ; is level SLZ ?   ; MJ: Commented out, we don't want SLZ having any rolling chunks =P
	;	beq.s	@isstarlight	; if yes, branch
		tst.b	(v_zone).w	; is level GHZ ?
		bne.w	@noloops	; if not, branch

	@isstarlight:
; 		move.w	obY(a0),d0
; 		lsr.w	#1,d0
; 		andi.w	#$380,d0
; 		move.b	obX(a0),d1
; 		andi.w	#$7F,d1
; 		add.w	d1,d0
; 		lea	(v_lvllayout).w,a1
; 		move.b	(a1,d0.w),d1	; d1 is	the 256x256 tile Sonic is currently on
; 
; 		cmp.b	(v_256roll1).w,d1 ; is Sonic on a "roll tunnel" tile?
; 		beq.w	Sonic_ChkRoll	; if yes, branch
; 		cmp.b	(v_256roll2).w,d1
; 		beq.w	Sonic_ChkRoll
		move.w	$0C(a0),d0				; MJ: Load Y position
		move.w	$08(a0),d1				; MJ: Load X position
		and.w	#$0780,d0				; MJ: keep Y position within 800 pixels (in multiples of 80)
		lsl.w	#$01,d0					; MJ: multiply by 2 (Because every 80 bytes switch from FG to BG..)
		lsr.w	#$07,d1					; MJ: divide X position by 80 (00 = 0, 80 = 1, etc)
		and.b	#$7F,d1					; MJ: keep within 4000 pixels (4000 / 80 = 80)
		add.w	d1,d0					; MJ: add together
		movea.l	(v_lvllayout).w,a1			; MJ: Load address of layout
		move.b	(a1,d0.w),d1				; MJ: collect correct 128x128 chunk ID based on the position of Sonic

		cmp.b	#$75,d1					; MJ: is the chunk 75 (Top top left S Bend)
		beq.w	Sonic_ChkRoll				; MJ: if so, branch
		cmp.b	#$76,d1					; MJ: is the chunk 76 (Top top right S Bend)
		beq.w	Sonic_ChkRoll				; MJ: if so, branch
		cmp.b	#$77,d1					; MJ: is the chunk 77 (Top bottom left S Bend)
		beq.w	Sonic_ChkRoll				; MJ: if so, branch
		cmp.b	#$78,d1					; MJ: is the chunk 78 (Top bottom right S Bend)
		beq.w	Sonic_ChkRoll				; MJ: if so, branch
		cmp.b	#$79,d1					; MJ: is the chunk 79 (Bottom top left S Bend)
		beq.w	Sonic_ChkRoll				; MJ: if so, branch
		cmp.b	#$7A,d1					; MJ: is the chunk 7A (Bottom top right S Bend)
		beq.w	Sonic_ChkRoll				; MJ: if so, branch
		cmp.b	#$7B,d1					; MJ: is the chunk 7B (Bottom bottom left S Bend)
		beq.w	Sonic_ChkRoll				; MJ: if so, branch
		cmp.b	#$7C,d1					; MJ: is the chunk 7C (Bottom bottom right S Bend)
		beq.w	Sonic_ChkRoll				; MJ: if so, branch

; 		cmp.b	(v_256loop1).w,d1 ; is Sonic on a loop tile?  ; MJ: this shite is commented out as it's used for loops (Which will be delt with by pathswappers)
; 		beq.s	@chkifleft	; if yes, branch
; 		cmp.b	(v_256loop2).w,d1
; 		beq.s	@chkifinair
 		bclr	#6,obRender(a0) ; return Sonic to high plane
		rts
; ===========================================================================

@chkifinair:
		btst	#1,obStatus(a0)	; is Sonic in the air?
		beq.s	@chkifleft	; if not, branch

		bclr	#6,obRender(a0)	; return Sonic to high plane
		rts	
; ===========================================================================

@chkifleft:
		move.w	obX(a0),d2
		cmpi.b	#$2C,d2
		bcc.s	@chkifright

		bclr	#6,obRender(a0)	; return Sonic to high plane
		rts	
; ===========================================================================

@chkifright:
		cmpi.b	#$E0,d2
		bcs.s	@chkangle1

		bset	#6,obRender(a0)	; send Sonic to	low plane
		rts	
; ===========================================================================

@chkangle1:
		btst	#6,obRender(a0) ; is Sonic on low plane?
		bne.s	@chkangle2	; if yes, branch

		move.b	obAngle(a0),d1
		beq.s	@done
		cmpi.b	#$80,d1		; is Sonic upside-down?
		bhi.s	@done		; if yes, branch
		bset	#6,obRender(a0)	; send Sonic to	low plane
		rts	
; ===========================================================================

@chkangle2:
		move.b	obAngle(a0),d1
		cmpi.b	#$80,d1		; is Sonic upright?
		bls.s	@done		; if yes, branch
		bclr	#6,obRender(a0)	; send Sonic to	high plane

@noloops:
@done:
		rts	
; End of function Sonic_Loops
