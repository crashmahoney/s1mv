; ---------------------------------------------------------------------------
; Downwards attack (and bounce version)
; ---------------------------------------------------------------------------

Sonic_DownAttack:
                moveq   #aDownAttack,d0
                jsr     CheckAbility
                tst.b   d1
                bne.s   @doattack
                rts
; --------------------------------------------------------------------------
        @doattack:
                cmp.w   #$600,obVelY(a0)    ; already attacking?
                bgt.s   @testanim           ; if so, branch
        @attack:
                sfx     sfx_Teleport
                move.w  #$600,obVelY(a0)
        @roll:
		move.b	#$E,obWidth(a0)
		move.b	#7,obHeight(a0)
                move.b	#id_Roll,obAnim(a0) ; use "jumping" animation
		bset	#2,obStatus(a0)     ; set status to rolling
		addq.w	#5,obY(a0)          ; move sonic down, cos of changed size
; if not rolling (ie. sonic was going over the attack speed but wasn't attacking)
        @testanim:
                cmp.b  #id_roll,obAnim(a0)  ; rolling?
                bne.s   @attack             ; if not, go back and attack
                rts