; ---------------------------------------------------------------------------
; Subroutine to	pause the game
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PauseGame:				; XREF: Level_MainLoop; et al
		nop	
		tst.b	(v_lives).w			; do you have any lives	left?
		beq.w	Unpause				; if not, branch
		tst.w	(f_pause).w			; is game already paused?
		bne.s	Pause_StopGame			; if yes, branch
	@chkMode:
		btst	#JbM,(v_Ctrl1Press).w		; is mode button pressed?
		bne.s	Pause_StopGame			; if so, pause
	@chkX:
		btst	#JbX,(v_Ctrl1Press).w
		beq.s	@chkY
		move.b  #0,(v_levselpage).w  		; choose status menu
		bra.s   Pause_StartPressed              ; go to menu			
	@chkY:
		btst	#JbY,(v_Ctrl1Press).w
		beq.s	@chkZ
		move.b  #1,(v_levselpage).w  		; choose status menu
		bra.s   Pause_StartPressed              ; go to menu
	@chkZ:
		btst	#JbZ,(v_Ctrl1Press).w
		beq.s	@chkStart
		move.b  #2,(v_levselpage).w  		; choose status menu
		bra.s   Pause_StartPressed              ; go to menu
	@chkStart:
		btst	#bitStart,(v_Ctrl1Press+1).w	; is Start button pressed?
		beq.s	Pause_DoNothing			; if not, branch

Pause_StartPressed:		
		move.w	#1,(f_pause).w	   		; freeze time
		cmpi.b  #$0C,(v_gamemode).w		; are we in a level?
		bne.s   Pause_Loop         		; if not, branch
		jmp	Pause_Menu        		; Bring up in-game menu

Pause_StopGame:
		move.w	#1,(f_pause).w	   		; freeze time
;		move.b	#1,(f_stopmusic).w 		; pause music



Pause_Loop:
		move.b	#$10,(v_vbla_routine).w
		bsr.w	WaitForVBla
		tst.b	(f_slomocheat).w 		; is slow-motion cheat on?
		beq.s	Pause_ChkStart			; if not, branch
		btst	#bitA,(v_Ctrl1Press+1).w 	; is button A pressed?
		beq.s	Pause_ChkBC			; if not, branch
		move.b	#id_Title,(v_gamemode).w 	; set game mode to 4 (title screen)
		nop	
		bra.s	Pause_EndMusic
; ===========================================================================

Pause_ChkBC:
		btst	#bitB,(v_Ctrl1Held+1).w ; is button B pressed?
		bne.s	Pause_SlowMo	; if yes, branch
		btst	#bitC,(v_Ctrl1Press+1).w ; is button C pressed?
		bne.s	Pause_SlowMo	; if yes, branch

Pause_ChkStart:
		btst	#JbM,(v_Ctrl1Press).w		; is mode button pressed?
		bne.s	Pause_EndMusic			; if so, unpause
		btst	#bitStart,(v_Ctrl1Press+1).w ; is Start button pressed?
		beq.s	Pause_Loop	; if not, branch

Pause_EndMusic:
;		move.b	#$80,(f_stopmusic).w

Unpause:
		move.w	#0,(f_pause).w	; unpause the game

Pause_DoNothing:
		rts	
; ===========================================================================

Pause_SlowMo:
; 		move.w	#1,(f_pause).w
; 		move.b	#$80,(f_stopmusic).w
		rts
; End of function PauseGame