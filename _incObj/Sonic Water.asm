; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Water:				; XREF: loc_12C7E
		cmpi.b	#1,(v_zone).w	; is level LZ?
		beq.s	@islabyrinth	; if yes, branch

	@exit:
		rts	
; ===========================================================================

	@islabyrinth:
		move.w	(v_waterpos1).w,d0
		sub.w   #$12,d0
		cmp.w	obY(a0),d0	; is Sonic above the water?
		bgt.w	@abovewater	; if yes, branch

	        tst.w	obVelY(a0)	; check if player is moving upward (i.e. from jumping)
                bmi.s	@exit	        ; if yes, skip routine (fixing the bug where sonic jumps really low near the surface of the water)

                move.w  (v_player+obVelX).w,d1
                tst.w	d1			; is his speed positive? (is he running to the right?)
		bpl.s	@runonwater	        ; if yes, branch
                neg.w	d1			; otherwise negate it

        @runonwater:
		move.w	obY(a0),d0		; move sonic's Y-position to d0
		sub.w	($FFFFF646).w,d0	; sub the water height from it
		cmpi.w	#$F,d0			; is Sonic slightly in the water?
		bgt.s	@goinwater		; if not, branch
		cmpi.w	#$9FF,d1		; if Sonic speed less than $250?
		blt.s	@goinwater		; if yes, branch
        	btst	#2,obStatus(a0)         ; is Sonic rolling?
        	bne.s   @goinwater              ; if so, branch
		move.w	(v_waterpos1).w,d0
                sub.w   #$12,d0                  ;
                move.w  d0,obY(a0)              ; set Sonic's Y pos to water height
		move.w	#$0,obVelY(a0)            ; set Sonic's Y velocity to 0
;		bsr.w   Sonic_ResetOnFloor
		bclr	#2,obStatus(a0)
;        	bset	#3,obStatus(a0)
		move.b	#0,$3C(a0)
		move.w	#0,(v_itembonus).w
                move.b  #0,(v_airjumpcount).w   ; +++ reset airjump count
                move.b  #0,(v_jumpdashcount).w  ; +++ reset jump dash count
; 		move.b	(v_vbla_byte).w,d0 ; get low byte of VBlank counter
; 		andi.b	#$3F,d0
; 		bne.s	@skipsfx
		sfx	sfx_WaterRunning	 ; play splash sound
	@skipsfx:
		cmpi.b	#4,(v_dustobj+obAnim).w	; is the water spraying?
		beq.s   @alreadyspraying
		move.b	#4,(v_dustobj+obAnim).w	; Set the Spin Dash dust animation to $4 (water spray)
        @alreadyspraying:
		bra.w	@exit

	@goinwater:
        	bset	#6,obStatus(a0)
		bne.w	@exit
		bsr.w	ResumeMusic
		move.b	#$A,(v_objspace+$340).w ; load bubbles object from Sonic's mouth
		move.b	#$81,(v_objspace+$340+obSubtype).w
                jsr     SetStatEffects
		asr	obVelX(a0)
		asr	obVelY(a0)
		asr	obVelY(a0)	; slow Sonic
		beq.w	@exit		; branch if Sonic stops moving
		move.b	#1,(v_dustobj+obAnim).w	; Set the Spin Dash dust animation to $1 (splash)
		sfx	sfx_Splash,1	 ; play splash sound and end subroutine
; ===========================================================================

@abovewater:
		bclr	#6,obStatus(a0)
		beq.w	@exit
		bsr.w	ResumeMusic
                jsr     SetStatEffects
		asl	obVelY(a0)
		beq.w	@exit
		move.b	#1,(v_dustobj+obAnim).w	; Set the Spin Dash dust animation to $1 (splash)
		cmpi.w	#-$1000,obVelY(a0)
		bgt.s	@belowmaxspeed
		move.w	#-$1000,obVelY(a0) ; set maximum speed on leaving water

	@belowmaxspeed:
		sfx	sfx_Splash,1	 ; play splash sound and end subroutine
; End of function Sonic_Water