; ---------------------------------------------------------------------------
; Subroutine to	change sonic's abilities based on his stats
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SetStatEffects:
		move.w	#$80,(v_sonspeeddec).w  ; Sonic's deceleration

; ---------------------------------------------------------------------------
; Recalculate stats
; ---------------------------------------------------------------------------
		move.b  #0,(v_statspeed).w
		move.b  #0,(v_stataccel).w
		move.b  #0,(v_statjump).w

; apply equipped item effects
ShoeEffects:
				lea     (EquipShoesList),a3
				moveq   #0,d1
				move.b  (v_equippedshoes).w,d1
				bsr.w   GetEquippedItemEffects
Item1Effects:
				lea     (EquipItemsList),a3
				moveq   #0,d1
				move.b  (v_equippeditem1).w,d1
				bsr.w   GetEquippedItemEffects
Item2Effects:
				lea     (EquipItemsList),a3
				moveq   #0,d1
				move.b  (v_equippeditem2).w,d1
				bsr.w   GetEquippedItemEffects
; EmeraldEffects:
;                 lea     (EquipEmeraldList),a3
;                 moveq   #0,d1
;                 move.b  (v_equippedemerald).w,d1
;                 bsr.w   GetEquippedItemEffects

; apply temporary item effects
TempEffects:
				lea     (ItemEffects).w,a3  ; start of current effects table in ram
				moveq   #19,d4          ; loop through 20 items
		@effectloop:
				tst.b   (a3)            ; is there an active effect in this slot?
				beq.s   @skip           ; if not branch

				cmpi.b  #eMaxSpeed,(a3) ; max speed buff?
				bne.s   @chkAccel       ; if not, branch
				move.b  1(a3),d3        ; get effect amount
				add.b   d3,(v_statspeed).w ; add effect amount

		@chkAccel:
				cmpi.b  #eAcceleration,(a3); acceleration buff?
				bne.s   @chkJump         ; if not, branch
				move.b  1(a3),d3        ; get effect amount
				add.b   d3,(v_stataccel).w ; add effect amount

		@chkJump:
				cmpi.b  #eJumpheight,(a3) ; jump buff?
				bne.s   @skip           ; if not, branch
				move.b  1(a3),d3        ; get effect amount
				add.b   d3,(v_statjump).w ; add effect amount

		@skip:
				adda    #4,a3           ; go to next slot
				dbf     d4,@effectloop  ; loop


; ---------------------------------------------------------------------------
; add super sonic stats
; ---------------------------------------------------------------------------
			tst.b	(f_supersonic).w ; is Sonic Super?
			beq.s	@notsuper	 ; if no, branch

				add.b  #100,(v_statspeed).w  ;
				add.b  #100,(v_stataccel).w  ;
				add.b  #100,(v_statjump).w   ;
	   @notsuper:
; -------------------------------------------------------------------------------------
; set max speed and acceleration
; -------------------------------------------------------------------------------------
		move.w	#$600,(v_sonspeedmax).w ; det default speed
		move.w	#$C,(v_sonspeedacc).w   ; det default acceleration

		btst    #staBoost,(v_player+obStatus2).w	; is sonic boosting?
		beq.s   @notboosting		; if so, branch
		move.w  #$A00,(v_sonspeedmax).w ; change Sonic's top speed
		move.w	#$14,(v_sonspeedacc).w  ; change Sonic's acceleration
@notboosting:

		tst.b   (v_shoes).w		; is speed shoes powerup active?
		beq.s   @noshoes		; if not, skip shoes stuff
		move.w	#$C00,(v_sonspeedmax).w ; change Sonic's top speed
		move.w	#$18,(v_sonspeedacc).w	; change Sonic's acceleration
@noshoes:

		moveq   #$0,d6
		move.b  (v_statspeed).w,d6
		mulu    #10,d6                  ; multlply the speed stat by 10
		add.w	d6,(v_sonspeedmax).w    ; add to max speed


		moveq   #$0,d6
		move.b  (v_stataccel).w,d6
		divu    #3,d6                   ; divide acceleration stat by 3
		add.w	d6,(v_sonspeedacc).w    ; add to acceleration

; -------------------------------------------------------------------------------------
; set underwater stuff
; -------------------------------------------------------------------------------------
		cmpi.b	#1,(v_zone).w	; is level LZ?
		beq.s	@islabyrinth	; if yes, branch

	@exit:
		rts	

	@islabyrinth:
		move.w	(v_waterpos1).w,d0
		sub.w   #$F,d0
		cmp.w	obY(a0),d0	; is Sonic above the water?
		bge.s	@abovewater	; if yes, branch

				moveq   #$0,d6
				move.w  (v_sonspeedmax).w,d6
				divu    #$2,d6                  ; divide max speed by 2
		move.w	d6,(v_sonspeedmax).w    ; set max speed
				moveq   #$0,d6
				move.w  (v_sonspeedacc).w,d6
				divu    #$2,d6                  ; divide acceleration by 2
		move.w	d6,(v_sonspeedacc).w    ; set acceleration
		move.w	#$40,(v_sonspeeddec).w ; change Sonic's deceleration

@abovewater:
		rts

; ===========================================================================
; Subroutine to get the effects currently equipped item
; input: a3 -  item slot offset table address
;        d1 -  ram address that keeps track of what is equipped in that slot
;
; adds item's stats directly to sonic's stats
; ===========================================================================

GetEquippedItemEffects:
		add.w	d1,d1
		add.w	d1,d1
				adda.l  d1,a3                         ; get current inv item address
				movea.l (a3),a3                       ; move pointer to item data
				adda.l  #InvEffeOffset+1,a3           ; get effects
				moveq   #0,d1
				moveq   #2,d4                         ; check 3 effect slots
	   @effectloop:
				move.b  (a3)+,d1                      ; get effect type

				cmpi.b  #eMaxSpeed,d1                 ; max speed?
				bne.s   @chkaccel                     ; if not branch
				move.b  (a3)+,d1                      ; get effect amount
				add.b   d1,(v_statspeed).w            ; add to max speed stat
				dbf     d4,@effectloop

		@chkaccel:
				cmpi.b  #eAcceleration,d1             ; acceleration?
				bne.s   @chkjump                      ; if not branch
				move.b  (a3)+,d1                      ; get effect amount
				add.b   d1,(v_stataccel).w            ; add to acceleration stat
				dbf     d4,@effectloop

		@chkjump:
				cmpi.b  #eJumpHeight,d1               ; jump strength?
				bne.s   @end                          ; if not, stop checking
				move.b  (a3)+,d1                      ; get effect amount
				add.b   d1,(v_statjump).w             ; add to jump strength stat
				dbf     d4,@effectloop
		@end:   rts
; ===========================================================================


; 		move.w	#$C00,(v_sonspeedmax).w ; change Sonic's top speed
; 		move.w	#$18,(v_sonspeedacc).w	; change Sonic's acceleration
; 		move.w	#$80,(v_sonspeeddec).w	; change Sonic's deceleration

; 		move.w	#$300,(v_sonspeedmax).w ; change Sonic's top speed
; 		move.w	#6,(v_sonspeedacc).w ; change Sonic's acceleration
; 		move.w	#$40,(v_sonspeeddec).w ; change Sonic's deceleration


; End of function SetStatEffects