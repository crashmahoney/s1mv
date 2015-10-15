
; ---------------------------------------------------------------------------
; Subroutine called at the peak of a jump that transforms Sonic into Super Sonic
; if he has enough rings and emeralds
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Sonic_CheckGoSuper:
	tst.b	(f_supersonic).w ; is Sonic already Super?
	bne.s	@rts		; if yes, branch
; 	cmpi.b	#7,(Emerald_count).w	; does Sonic have exactly 7 emeralds?
; 	bne.s	@rts		; if not, branch
;         tst.b   (f_debug).w     ; is debug mode on?
;         beq.s   @gosuper        ; if so, branch
	cmpi.w	#50,(v_rings).w	; does Sonic have at least 50 rings?
	blo.s	@rts		; if not, branch
@gosuper:
	move.b	#1,(v_supersonicpal).w
	move.b	#$F,(v_supersonicpaltimer).w
	move.b	#1,(f_supersonic).w
	move.b	#1,(f_lockmulti).w        ;lock controls
	move.b	#id_Transform,obAnim(a0)  ; use transformation animation
	move.b	#1,(v_invinc).w           ; make Sonic invincible
	jsr     SetStatEffects
; 	move.b	#ObjID_SuperSonicStars,(SuperSonicStars+id).w ; load Obj7E (super sonic stars object) at $FFFFD040
; 	move.w	#$A00,(Sonic_top_speed).w
; 	move.w	#$30,(Sonic_acceleration).w
; 	move.w	#$100,(Sonic_deceleration).w
; 	move.w	#SndID_SuperTransform,d0
; 	jsr	(PlaySound).l	          ; Play transformation sound effect.
	music	bgm_SuperSonic

; ---------------------------------------------------------------------------
@rts:
	rts
; End of subroutine Sonic_CheckGoSuper

; ---------------------------------------------------------------------------
; Subroutine doing the extra logic for Super Sonic
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1ABA6:
Sonic_Super:
	tst.b	(f_supersonic).w	; Ignore all this code if not Super Sonic
	beq.w	return_1AC3C
	tst.b	(f_timecount).w         ; is level timer going?
	beq.s	Sonic_RevertToNormal    ; if not, branch (revert to normal)
	subq.b	#1,(v_supersonicframecount).w
	bpl.w	return_1AC3C
	move.b	#60,(v_supersonicframecount).w	; Reset frame counter to 60
	tst.w	(v_rings).w             ; test for rings
	beq.s	Sonic_RevertToNormal    ; if 0, branch
	ori.b	#1,(f_ringcount).w
	cmpi.w	#1,(v_rings).w
	beq.s	@losering1
	cmpi.w	#10,(v_rings).w
	beq.s	@losering1
	cmpi.w	#100,(v_rings).w
	bne.s	@losering2
@losering1:
	ori.b	#$80,(f_ringcount).w
@losering2:
	subq.w	#1,(v_rings).w
	bne.s	return_1AC3C
; loc_1ABF2:
Sonic_RevertToNormal:
	move.b	#2,(v_supersonicpal).w	; Remove rotating palette
	move.w	#$28,(v_supersonicpalframe).w
	move.b	#0,(f_supersonic).w
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


; 		cmpi.w	#(id_LZ<<8)+3,(v_zone).w ; check if level is SBZ3
; 		bne.s	@music
; 		moveq	#5,d0		; play SBZ music
; 
; 	@music:
; 		lea	(MusicList2).l,a1
; 		move.b	(a1,d0.w),d0
; 		jsr	(PlaySound).l	; play normal music

	@removeinvincible:
		move.b	#0,(v_invinc).w ; cancel invincibility
	jsr     SetStatEffects
		rts
;	move.b	#1,next_anim(a0)	; Change animation back to normal ?
; 	move.w	#1,invincibility_time(a0)	; Remove invincibility
; 	move.w	#$600,(Sonic_top_speed).w
; 	move.w	#$C,(Sonic_acceleration).w
; 	move.w	#$80,(Sonic_deceleration).w
; 	btst	#6,status(a0)	; Check if underwater, return if not
; 	beq.s	return_1AC3C
; 	move.w	#$300,(Sonic_top_speed).w
; 	move.w	#6,(Sonic_acceleration).w
; 	move.w	#$40,(Sonic_deceleration).w

return_1AC3C:
	rts
; End of subroutine Sonic_Super
