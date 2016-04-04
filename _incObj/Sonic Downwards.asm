; ---------------------------------------------------------------------------
; Downwards attack (and bounce version)
; ---------------------------------------------------------------------------

Sonic_DownAttack:
        ;       moveq   #aDownAttack,d0
        ;        jsr     CheckAbility
        ;        tst.b   d1
        ;       bne.s   @doattack
                cmp.b  #id_Stomp,obAnim(a0)  ; stomping?
                bne.s   @chkbuttons             ; if not, go back and attack
		clr.w	obVelX(a0)
		clr.w	obInertia(a0)
		move.w	#$1F,obLRLock(a0)	; don't let him turn around for a few frames
		bra.s	@skipothermoves
 @chkbuttons:               
        tst.b   (v_abil_down).w
        beq.s   @rts
	move.b	(v_jpadhold2).w,d1
	andi.b	#btnDn,d1	              ; is down held?
	beq.s	@rts
	move.b	(v_jpadpress2).w,d1
	andi.b	#btnABC,d1	              ; is AB or C pressed?
	bne.s	@doattack
@rts:
        rts
; --------------------------------------------------------------------------
        @doattack:
                sfx     $47

                move.w  #$900,obVelY(a0)
                move.b	#id_Stomp,obAnim(a0) ; use "stomp" animation
                move.b  #8,(v_dustobj+obRoutine).w     ; skid dust
                move.b  #$1E,(v_dustobj+obFrame).w     ; skid dust
; if not rolling (ie. sonic was going over the attack speed but wasn't attacking)
        @skipothermoves:
        	adda.w	#4,sp			; forget the bsr that got us here
                bra.w	Sonic_Skip_Jumpmoves	; skip past all other jump moves