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
		tst.b   (v_temp_teletest).w
		bne.s   @effects
		jsr	(DisplaySprite).l
		
; --------------------------------------------------------------------------
@effects:
                lea     (ItemEffects).w,a2   ; get the list of current effects
                moveq   #15,d1          ; loop through 16 items
        @effectloop:
                tst.b   (a2)            ; is there an active effect in this slot?
                bne.s   @activeeffect   ; if so, branch
            @nextslot:
                addq.w  #4,a2           ; go to next slot
                dbf     d1,@effectloop  ; loop


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
           @activeeffect:
                subq.w  #1,2(a2)        ; sub 1 from time left
                bne.s   @nextslot       ; if time left is not 0, branch
                cmpi.b  #eInvincibility,(a2) ; is effect invincibility?
                beq.s   @chkinvincible  ; if so branch
           @returninvinc:
                move.b  #0,(a2)         ; clear effect type
                move.b  #0,1(a2)        ; clear effect amount
                move.w  #0,2(a2)        ; clear effect time
                jsr     SetStatEffects  ; update stats
                bra.s   @nextslot
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

                cmpi.b	#$0,(v_act).w	; is this act 1?
		bne.s	@GetBgm2	; if not, branch
		lea	(MusicList1).l,a1	; load Music Playlist for Acts 1
		bra.s	@PlayMusic	; go to PlayMusic
 
         @GetBgm2:
		cmpi.b	#$1,(v_act).w	; is this act 2?
		bne.s	@GetBgm3	; if not, branch
		lea	(MusicList2).l,a1	; load Music Playlist for Acts 2
		bra.s	@PlayMusic	; go to PlayMusic
 
         @GetBgm3:
		cmpi.b	#$2,(v_act).w	; is this act 3?
		bne.s	@GetBgm4	; if not, branch
		lea	(MusicList3).l,a1	; load Music Playlist for Acts 3
		bra.s	@PlayMusic	; go to PlayMusic
 
         @GetBgm4:
		cmpi.b	#$3,(v_act).w	; is this act 4?
		bne.s	@PlayMusic	; if not, branch
		lea	(MusicList4).l,a1	; load Music Playlist for Acts 4
 
         @PlayMusic:
		move.b	(a1,d0.w),d0
		jsr	(PlaySound).l	; play normal music

	@removeinvincible:
		move.b	#0,(v_invinc).w ; cancel invincibility
		bra.s   @returninvinc