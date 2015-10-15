; ---------------------------------------------------------------------------
; InstaShield Attack Activation
; ---------------------------------------------------------------------------

Sonic_InstaShield:
                tst.b   (v_shieldobj+$31).w              ; check flag
                bne.s   @skip
                moveq   #aInstaShield,d0
                jsr     CheckAbility
                tst.b   d1
                bne.s   @doattack
       @skip:
                rts
; --------------------------------------------------------------------------
        @doattack:
		move.b	#1,(v_shieldobj+obAnim).w        ; set to instashield animation
                move.b  #1,(v_shieldobj+$31).w           ; set flag
                bset    #7,(v_invinc).w                  ; make invincible
		bclr	#4,$22(a0)                       ; restore air control
		sfx     $42                              ; Instashield sound
                rts