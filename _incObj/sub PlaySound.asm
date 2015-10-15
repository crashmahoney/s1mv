; ---------------------------------------------------------------------------
; Subroutine to	play a music track

; input:
;	d0 = track to play
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
       if z80SoundDriver=0


PlaySound:
		move.b	d0,(v_playsnd1).w
		rts

; End of function PlaySound

; ---------------------------------------------------------------------------
; Subroutine to	play a sound effect
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PlaySound_Special:
		move.b	d0,(v_playsnd2).w
		rts
; End of function PlaySound_Special

; ===========================================================================
; ---------------------------------------------------------------------------
; Unused sound/music subroutine
; ---------------------------------------------------------------------------
; This seems to queue up a sound, which gets played at the same time as the next normal PlaySound command
PlaySound_Unused:
		move.b	d0,(v_playnull).w
		rts
		


         else

; ---------------------------------------------------------------------------
; Z80 Driver PlaySound
; ---------------------------------------------------------------------------


PlaySound:
		cmpi.w	#$FB,d0
		blt.s	PlayNotSpecialFlag
		bhi.s	TestForNormalSpeed
		move	#8,d0
		jmp		SetTempo
 
TestForNormalSpeed:
		cmpi.w	#$FC,d0
		bne.s	PlayNotSpecialFlag
		clr.w	d0
		jmp		SetTempo
 
PlayNotSpecialFlag:
		stopZ80 
		waitZ80
		move.b	d0,($A01C0A).l
		startZ80
		rts
; End of function PlaySound
 

; ---------------------------------------------------------------------------
; Unused sound/music subroutine
; ---------------------------------------------------------------------------
 
PlaySound_Unk:
		nop
; ---------------------------------------------------------------------------
; Subroutine to	play a special sound/music (FB-FF)
; ---------------------------------------------------------------------------
 
PlaySound_Special:
		stopZ80 
		waitZ80
		cmp.b	($A01C0B).l,d0
		beq.s	PlaySound_Special1
		tst.b	($A01C0B).l
		bne.s	PlaySound_Special0
		move.b	d0,($A01C0B).l
		startZ80
		rts
 
PlaySound_Special0:
		move.b	d0,($A01C0C).l
 
PlaySound_Special1:
		startZ80

SkipPlaySound_Special:
		rts
; End of function PlaySound_Special
 
; ---------------------------------------------------------------------------
; Subroutine to change the music tempo
; ---------------------------------------------------------------------------
 
SetTempo:
		stopZ80 
		waitZ80
		move.b	D0,($A01C08).l
		startZ80
		rts

         endif
		
