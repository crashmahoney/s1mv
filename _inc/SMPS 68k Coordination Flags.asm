; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FlagRoutine:				; XREF: DACUpdateTrack; sub_71CEC; sub_72878
		subi.w	#$E0,d5
		lsl.w	#2,d5
		jmp	CoordFlags(pc,d5.w)

CoordFlags:
; ===========================================================================
		bra.w	E0SetPanning
		bra.w	E1AlterNoteFreq
		bra.w	E2Unknown
		bra.w	E3Return
		bra.w	E4FadeIn
		bra.w	E5SetChanTempoDivider
		bra.w	E6AlterVolume
		bra.w	E7NoAttack
		bra.w	E8SetNoteFill
		bra.w	E9Transpose
		bra.w	EASetTempoModifier
		bra.w	EBSetTempoDivider
		bra.w	ECSetVolume
		bra.w	EDUnknown
		bra.w	EEUnknown    ; Something to do with voice selection
		bra.w	EFSetFMVoice
		bra.w	F0Modulation
		bra.w	F1ModulationOn
		bra.w	F2StopTrack
		bra.w	F5SetPSGNoise
		bra.w	F4ModulationOff
		bra.w	F5SetPSGVoice
		bra.w	F6Jump
		bra.w	F7Loop
		bra.w	F8JumpThenReturn
		bra.w	F9Unknown
; ===========================================================================
; ---------------------------------------------------------------------------
; Panning, AMS, FMS
; no panning - $00; right - $40; left - $80; centre - $C0
; ---------------------------------------------------------------------------

E0SetPanning:				; XREF: CoordFlags
		move.b	(a4)+,d1
		tst.b	sVoiceControl(a5)     ; is track PSG?
		bmi.s	locret_72AEA          ; if so, branch
		move.b	sPan(a5),d0
		andi.b	#$37,d0
		or.b	d0,d1
		move.b	d1,sPan(a5)
		move.b	#$B4,d0
		bra.w	loc_72716
locret_72AEA:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; E1xx - Alter note frequency by xx
; ---------------------------------------------------------------------------
E1AlterNoteFreq:				; XREF: CoordFlags
		move.b	(a4)+,sFreqAdjust(a5)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Okay, so here's the lowdown -- in Sonic 1 & 2, this sets an arbitrary value for no known purpose.  In Sonic 3, this value, if set as FF, is used as the fade-in routine
; ---------------------------------------------------------------------------
E2Unknown:				; XREF: CoordFlags
		move.b	(a4)+,7(a6)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; E3 - Return (generally used after F8)
; ---------------------------------------------------------------------------
E3Return:				; XREF: CoordFlags
		moveq	#0,d0
		move.b	sReturnLocation(a5),d0
		movea.l	(a5,d0.w),a4
		move.l	#0,(a5,d0.w)
		addq.w	#2,a4
		addq.b	#4,d0
		move.b	d0,sReturnLocation(a5)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Fade-in to previous song (ie. after 1-Up); put on DAC channel
; ---------------------------------------------------------------------------
E4FadeIn:				; XREF: CoordFlags
		movea.l	a6,a0                  ; load current music ram address
		lea	$3A0(a6),a1            ; load storage music address
		move.w	#$87,d0                ; set repeat times

loc_72B1E:
		move.l	(a1)+,(a0)+            ; restore last music
		dbf	d0,loc_72B1E           ; repeat til done

		bset	#2,$40(a6)
		movea.l	a5,a3
		move.b	#$28,d6
		sub.b	$26(a6),d6
		moveq	#5,d7                  ; set repeat times (6 FM channels)
		lea	$70(a6),a5

loc_72B3A:
		btst	#bitIsPlaying,(a5)     ; has the channel been stopped?
		beq.s	loc_72B5C              ; if so, branch
		bset	#bitAtRest,(a5)
		add.b	d6,sChannelVolume(a5)  ; add to reduce volume to it's lowest
		btst	#bitSFXOverride,(a5)
		bne.s	loc_72B5C
		moveq	#0,d0
		move.b	sCurrentVoice(a5),d0
		movea.l	$18(a6),a1
		jsr	sub_72C4E(pc)

loc_72B5C:
		adda.w	#$30,a5
		dbf	d7,loc_72B3A

		moveq	#2,d7

loc_72B66:
		btst	#bitIsPlaying,(a5)
		beq.s	loc_72B78
		bset	#bitAtRest,(a5)
		jsr	PSGNoteOff(pc)
		add.b	d6,sChannelVolume(a5)

loc_72B78:
		adda.w	#$30,a5
		dbf	d7,loc_72B66
		movea.l	a3,a5
		move.b	#$80,$24(a6)
		move.b	#$28,$26(a6)
		clr.b	$27(a6)
		startZ80
		addq.w	#8,sp
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Set this track's tempo divider
; ---------------------------------------------------------------------------
E5SetChanTempoDivider:				; XREF: CoordFlags
		move.b	(a4)+,sTimingDivisor(a5)
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; E6xx - Alter Track Volume by xx
; ---------------------------------------------------------------------------
E6AlterVolume:				; XREF: CoordFlags
		move.b	(a4)+,d0
		add.b	d0,sChannelVolume(a5)
		bra.w	SendVoiceTL
; ===========================================================================
; ---------------------------------------------------------------------------
; Prevent next note from attacking
; ---------------------------------------------------------------------------
E7NoAttack:				; XREF: CoordFlags
		bset	#bitNoAttack,(a5)
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Set note fill amount to byte
; ---------------------------------------------------------------------------
E8SetNoteFill:				; XREF: CoordFlags
		move.b	(a4),sCurrentDuration(a5)
		move.b	(a4)+,sLastDuration(a5)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Add transposition to channel key (S1/S2 ONLY)
; ---------------------------------------------------------------------------
E9Transpose:				; XREF: CoordFlags
		move.b	(a4)+,d0
		add.b	d0,sTranspose(a5)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Change song tempo to unsigned byte
; ---------------------------------------------------------------------------
EASetTempoModifier:				; XREF: CoordFlags
		move.b	(a4),2(a6)
		move.b	(a4)+,1(a6)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Set ALL per-track tempo dividers
; ---------------------------------------------------------------------------
EBSetTempoDivider:				; XREF: CoordFlags
		lea	$40(a6),a0
		move.b	(a4)+,d0
		moveq	#$30,d1
		moveq	#9,d2

loc_72BDA:
		move.b	d0,2(a0)
		adda.w	d1,a0
		dbf	d2,loc_72BDA

		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Like CF_CHANGEVOLUME, except for FM tracks, volume change does not occur until next voice change
; ---------------------------------------------------------------------------
ECSetVolume:				; XREF: CoordFlags
		move.b	(a4)+,d0
		add.b	d0,sChannelVolume(a5)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; ED - Unknown
; ---------------------------------------------------------------------------
EDUnknown:				; XREF: CoordFlags
		clr.b	$2C(a6)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; EE - Unknown (Something to do with voice selection)
; ---------------------------------------------------------------------------
EEUnknown:				; XREF: CoordFlags
		bclr	#bitIsPlaying,(a5)
		bclr	#bitNoAttack,(a5)
		jsr	FMNoteOff(pc)
		tst.b	$250(a6)
		bmi.s	loc_72C22
		movea.l	a5,a3
		lea	$100(a6),a5
		movea.l	$18(a6),a1
		bclr	#bitSFXOverride,(a5)
		bset	#bitAtRest,(a5)
		move.b	sCurrentVoice(a5),d0
		jsr	sub_72C4E(pc)
		movea.l	a3,a5

loc_72C22:
		addq.w	#8,sp
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Change FM voice (NOT PSG tone!)
; ---------------------------------------------------------------------------
EFSetFMVoice:				; XREF: CoordFlags
		moveq	#0,d0
		move.b	(a4)+,d0
		move.b	d0,sCurrentVoice(a5)
		btst	#bitSFXOverride,(a5)
		bne.w	locret_72CAA
		movea.l	$18(a6),a1
		tst.b	$E(a6)
		beq.s	sub_72C4E
		movea.l	$20(a5),a1
		tst.b	$E(a6)
		bmi.s	sub_72C4E
		movea.l	$20(a6),a1

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_72C4E:				; XREF: Snd_FadeOut1; et al
		subq.w	#1,d0
		bmi.s	loc_72C5C
		move.w	#$19,d1

loc_72C56:
		adda.w	d1,a1
		dbf	d0,loc_72C56

loc_72C5C:
		move.b	(a1)+,d1
		move.b	d1,sPSGNoise(a5)
		move.b	d1,d4
		move.b	#$B0,d0
		jsr	sub_72722(pc)
		lea	byte_72D18(pc),a2
		moveq	#$13,d3

loc_72C72:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		jsr	sub_72722(pc)
		dbf	d3,loc_72C72
		moveq	#3,d5
		andi.w	#7,d4
		move.b	byte_72CAC(pc,d4.w),d4
		move.b	sChannelVolume(a5),d3

loc_72C8C:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		lsr.b	#1,d4
		bcc.s	loc_72C96
		add.b	d3,d1

loc_72C96:
		jsr	sub_72722(pc)
		dbf	d5,loc_72C8C
		move.b	#$B4,d0
		move.b	sPan(a5),d1
		jsr	sub_72722(pc)

locret_72CAA:
		rts	
; End of function sub_72C4E

; ===========================================================================
byte_72CAC:	dc.b 8,	8, 8, 8, $A, $E, $E, $F

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SendVoiceTL:				; XREF: sub_72504; sub_7267C; E6AlterVolume
		btst	#bitSFXOverride,(a5)
		bne.s	locret_72D16
		moveq	#0,d0
		move.b	sCurrentVoice(a5),d0
		movea.l	$18(a6),a1
		tst.b	$E(a6)
		beq.s	loc_72CD8
		movea.l	$20(a6),a1
		tst.b	$E(a6)
		bmi.s	loc_72CD8
		movea.l	$20(a6),a1

loc_72CD8:
		subq.w	#1,d0
		bmi.s	loc_72CE6
		move.w	#$19,d1

loc_72CE0:
		adda.w	d1,a1
		dbf	d0,loc_72CE0

loc_72CE6:
		adda.w	#$15,a1
		lea	byte_72D2C(pc),a2
		move.b	sPSGNoise(a5),d0
		andi.w	#7,d0
		move.b	byte_72CAC(pc,d0.w),d4
		move.b	sChannelVolume(a5),d3
		bmi.s	locret_72D16
		moveq	#3,d5

loc_72D02:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		lsr.b	#1,d4
		bcc.s	loc_72D12
		add.b	d3,d1
		bcs.s	loc_72D12
		jsr	sub_72722(pc)

loc_72D12:
		dbf	d5,loc_72D02

locret_72D16:
		rts	
; End of function SendVoiceTL

; ===========================================================================
byte_72D18:	dc.b $30, $38, $34, $3C, $50, $58, $54,	$5C, $60, $68
		dc.b $64, $6C, $70, $78, $74, $7C, $80,	$88, $84, $8C
byte_72D2C:	dc.b $40, $48, $44, $4C
; ===========================================================================
; ---------------------------------------------------------------------------
; F0wwxxyyzz - Set up modulation
; ww: wait time - xx: modulation speed - yy: change per step - zz: number of steps
; ---------------------------------------------------------------------------
F0Modulation:				; XREF: CoordFlags
		bset	#bitModulation,(a5)
		move.l	a4,sModWait(a5)
		move.b	(a4)+,sModWaitWork(a5)
		move.b	(a4)+,sModSpeedWork(a5)
		move.b	(a4)+,sModDeltaWork(a5)
		move.b	(a4)+,d0
		lsr.b	#1,d0
		move.b	d0,sModStepsWork(a5)
		clr.w	$1C(a5)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Turn on modulation
; ---------------------------------------------------------------------------
F1ModulationOn:				; XREF: CoordFlags
		bset	#bitModulation,(a5)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Stops this track from playing (non-looping BGMs only)
; ---------------------------------------------------------------------------
F2StopTrack:				; XREF: CoordFlags
		bclr	#bitIsPlaying,(a5)   ; set channel as stopped
		bclr	#bitNoAttack,(a5)
		tst.b	sVoiceControl(a5)    ; is the channel a PSG channel?
		bmi.s	loc_72D74            ; if so, branch
		tst.b	8(a6)                ; is the channel a DAC channel?
		bmi.w	loc_72E02            ; if so, branch
		jsr	FMNoteOff(pc)
		bra.s	loc_72D78
; ===========================================================================

loc_72D74:
		jsr	PSGNoteOff(pc)

loc_72D78:
		tst.b	$E(a6)
		bpl.w	loc_72E02
		clr.b	0(a6)
		moveq	#0,d0
		move.b	sVoiceControl(a5),d0 ; is it a PSG channel?
		bmi.s	loc_72DCC            ; if so, branch
		lea	ChannelRAM(pc),a0
		movea.l	a5,a3
		cmpi.b	#4,d0
		bne.s	loc_72DA8
		tst.b	$340(a6)
		bpl.s	loc_72DA8
		lea	$340(a6),a5
		movea.l	$20(a6),a1
		bra.s	loc_72DB8
; ===========================================================================

loc_72DA8:
		subq.b	#2,d0
		lsl.b	#2,d0
		movea.l	(a0,d0.w),a5
		tst.b	(a5)
		bpl.s	loc_72DC8
		movea.l	$18(a6),a1

loc_72DB8:
		bclr	#bitSFXOverride,(a5)
		bset	#bitAtRest,(a5)
		move.b	sCurrentVoice(a5),d0
		jsr	sub_72C4E(pc)

loc_72DC8:
		movea.l	a3,a5
		bra.s	loc_72E02
; ===========================================================================

loc_72DCC:
		lea	$370(a6),a0
		tst.b	(a0)
		bpl.s	loc_72DE0
		cmpi.b	#$E0,d0
		beq.s	loc_72DEA
		cmpi.b	#$C0,d0
		beq.s	loc_72DEA

loc_72DE0:
		lea	ChannelRAM(pc),a0
		lsr.b	#3,d0
		movea.l	(a0,d0.w),a0

loc_72DEA:
		bclr	#bitSFXOverride,(a0)
		bset	#bitAtRest,(a0)
		cmpi.b	#$E0,sVoiceControl(a0)
		bne.s	loc_72E02
		move.b	$1F(a0),($C00011).l

loc_72E02:
		addq.w	#8,sp
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Set current PSG noise (effects noise channel only)
; ---------------------------------------------------------------------------
F5SetPSGNoise:				; XREF: CoordFlags
		move.b	#$E0,sVoiceControl(a5)
		move.b	(a4)+,sPSGNoise(a5)
		btst	#bitSFXOverride,(a5)
		bne.s	locret_72E1E
		move.b	-1(a4),($C00011).l

locret_72E1E:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Turn off modulation
; ---------------------------------------------------------------------------
F4ModulationOff:				; XREF: CoordFlags
		bclr	#bitModulation,(a5)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Change PSG tone (NOT FM voice!)
; ---------------------------------------------------------------------------
F5SetPSGVoice:				; XREF: CoordFlags
		move.b	(a4)+,sCurrentVoice(a5)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; F6xxxx - Jump to xxxx
; ---------------------------------------------------------------------------
F6Jump:				; XREF: CoordFlags
		move.b	(a4)+,d0
		lsl.w	#8,d0
		move.b	(a4)+,d0
		adda.w	d0,a4
		subq.w	#1,a4
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; F7xxyyzzzz - Loop back to zzzz yy times, xx being the loop index for loop recursion fixing
; ---------------------------------------------------------------------------
F7Loop:				; XREF: CoordFlags
		moveq	#0,d0
		move.b	(a4)+,d0
		move.b	(a4)+,d1
		tst.b	$24(a5,d0.w)
		bne.s	loc_72E48
		move.b	d1,$24(a5,d0.w)

loc_72E48:
		subq.b	#1,$24(a5,d0.w)
		bne.s	F6Jump
		addq.w	#2,a4
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; F8xxxx - Call pattern at xxxx, saving return point
; ---------------------------------------------------------------------------
F8JumpThenReturn:				; XREF: CoordFlags
		moveq	#0,d0
		move.b	sReturnLocation(a5),d0
		subq.b	#4,d0
		move.l	a4,(a5,d0.w)
		move.b	d0,sReturnLocation(a5)
		bra.s	F6Jump
; ===========================================================================
; ---------------------------------------------------------------------------
; Return from CF_GOSUB (S3/S&K/3K ONLY)
; ---------------------------------------------------------------------------
F9Unknown:				; XREF: CoordFlags
		move.b	#$88,d0
		move.b	#$F,d1
		jsr	YM2612_Save01(pc)
		move.b	#$8C,d0
		move.b	#$F,d1
		bra.w	YM2612_Save01
; ===========================================================================