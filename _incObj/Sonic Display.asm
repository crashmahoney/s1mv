; ---------------------------------------------------------------------------
; Subroutine to display Sonic and set music
; ---------------------------------------------------------------------------
flashtime:	= $30		; time between flashes after getting hit
invtime:	= $32		; time left for invincibility
shoetime:	= $34		; time left for speed shoes

Sonic_Display:
		tst.b   (v_homingtimer).w
		beq.s   @timeriszero
		subq.b  #1,(v_homingtimer).w  ; reduce timer
	@timeriszero:         
		move.w	flashtime(a0),d0
		beq.s	@display
		subq.w	#1,flashtime(a0)
		lsr.w	#3,d0
		bcc.s	@effects

	@display:
		tst.b   (v_teleportin).w
		bne.s   @effects
		jsr		(DisplaySprite).l
		
; --------------------------------------------------------------------------
@effects:
		lea     (v_activeeffects).w,a2   	; get the number of current effects
		moveq   #0,d1
		move.b	(a2)+,d1
		bra.s	@nextslot          		; if there are no effects, this will fall through
	@effectloop:
		tst.l   (a2)+            		; is there an active effect in this slot?
		beq.s   @effectloop   			; if not, branch
		subq.w  #1,-2(a2)       		; sub 1 from time left
		bne.s   @nextslot       		; if time left is not 0, branch
		cmpi.b  #eInvincibility,-4(a2) 	; is effect invincibility?
		beq.s   @chkinvincible  		; if so branch
	@returninvinc:
		clr.l  	-4(a2)         			; clear effect
		sub.b	#1,(v_activeeffects).w	; sub 1 from active effect count
		jsr     SetStatEffects  		; update stats
	@nextslot:
		dbf     d1,@effectloop  		; loop

; --------------------------------------------------------------------------
	@chkshoes:
		tst.b	(v_shoes).w	; does Sonic have speed	shoes?
		beq.s	@exit		; if not, branch
		tst.w	shoetime(a0)	; check	time remaining
		beq.s	@exit
		subq.w	#1,shoetime(a0)	; subtract 1 from time
		bne.s	@exit
		move.b	#0,(v_shoes).w	; cancel speed shoes
		jsr     SetStatEffects

	if z80SoundDriver=0
		move.w	#$E3,d0
		jmp	(PlaySound).l	; run music at normal speed
	else
		move.w	#0,d0
		jmp	(SetTempo).l	; run music at normal speed
         endif

	@exit:
	        rts

; =========================================================================
; Countdown effect timer, remove effect when expired
; =========================================================================

; =========================================================================
; Remove invincibility effect
; =========================================================================
	@chkinvincible:
		tst.b	(f_lockscreen).w
		bne.w	@removeinvincible
		cmpi.w	#$C,(v_air).w
		bcs.s	@removeinvincible
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lea		(MusicList1).l,a1	; load Music Playlist for Acts 1
		move.b	(a1,d0.w),d0
		jsr		(PlaySound).l	; play normal music

	@removeinvincible:
		move.b	#0,(v_invinc).w ; cancel invincibility
		bra.s   @returninvinc