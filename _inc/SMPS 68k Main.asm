SoundDriver:
SonicDriverVer  =  1
SourceDriver    =  1
; Go_SoundTypes:	dc.l SoundTypes		; XREF: Sound_Play    +++ changed to below for more music tracks
; Go_SoundD0:	dc.l ptr_sndD0	; XREF: Sound_D0toDF
; Go_MusicIndex:	dc.l MusicIndex		; XREF: Sound_81to9F
; Go_SoundIndex:	dc.l SoundIndex		; XREF: Sound_A0toCF
; Go_SpeedUpIndex:	dc.l byte_71A94		; XREF: Sound_81to9F
; Go_PSGIndex:	dc.l PSG_Index		; XREF: sub_72926
		align $10
Go_SoundTypes:	dc.l SoundTypes		; XREF: Sound_Play
Go_SoundD0:	dc.l ptr_sndD0;  +++was SoundD0Index	; XREF: Sound_D0toDF
Go_MusicIndex:	dc.l MusicIndex		; XREF: Sound_81to9F
Go_MusicIndex_E5toFF:	dc.l MusicIndex_E5plus		; XREF: Sound_81to9F
Go_SoundIndex:	dc.l SoundIndex		; XREF: Sound_A0toCF
Go_SpeedUpIndex:	dc.l byte_71A94		; XREF: Sound_81to9F
Go_PSGIndex:	dc.l PSG_Index		; XREF: sub_72926
; ---------------------------------------------------------------------------
; PSG instruments used in music
; ---------------------------------------------------------------------------
; PSG_Index:	dc.l PSG1, PSG2, PSG3
; 		dc.l PSG4, PSG5, PSG6
; 		dc.l PSG7, PSG8, PSG9
; 		dc.l PSG0A, PSG0B, PSG0C
; 		dc.l PSG0D, PSG1, PSG1
; 
; PSG1:		dc.b 0,	0, 0, 1, 1, 1, 2, 2, 2,	3, 3, 3, 4, 4, 4, 5, 5,	5, 6, 6, 6, 7, $80 ; ...
; PSG2:		dc.b 0,	2, 4, 6, 8, $10, $80 ; ...
; PSG3:		dc.b 0,	0, 1, 1, 2, 2, 3, 3, 4,	4, 5, 5, 6, 6, 7, 7, $80 ; ...
; PSG4:		dc.b 0,	0, 2, 3, 4, 4, 5, 5, 5,	6, $80 ; ...
; PSG6:		dc.b 3,	3, 3, 2, 2, 2, 2, 1, 1,	1, 0, 0, 0, 0, $80 ; ...
; PSG5:		dc.b 0,	0, 0, 0, 0, 0, 0, 0, 0,	0, 1, 1, 1, 1, 1, 1, 1,	1, 1, 1, 1 ; ...
; 		dc.b 1,	1, 1, 2, 2, 2, 2, 2, 2,	2, 2, 3, 3, 3, 3, 3, 3,	3, 3, 4, $80
; PSG7:		dc.b 0,	0, 0, 0, 0, 0, 1, 1, 1,	1, 1, 2, 2, 2 ;	...
; 		dc.b 2,	2, 3, 3, 3, 4, 4, 4, 5,	5, 5, 6, 7, $80
; PSG8:		dc.b 0,	0, 0, 0, 0, 1, 1, 1, 1,	1, 2, 2, 2, 2, 2, 2, 3,	3, 3, 3	; ...
; 		dc.b 3,	4, 4, 4, 4, 4, 5, 5, 5,	5, 5, 6, 6, 6, 6, 6, 7,	7, 7, $80
; PSG9:		dc.b 0,	1, 2, 3, 4, 5, 6, 7, 8,	9, $A, $B, $C, $D, $E, $F, $80 ; ...
; PSG0A:	        dc.b	0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1
; 		dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
; 		dc.b	1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2
; 		dc.b	2,2,3,3,3,3,3,3,3,3,3,3,4,$80
; PSG0B:	        dc.b	4,4,4,3,3,3,2,2,2,1,1,1,1,1,1,1
; 		dc.b	2,2,2,2,2,3,3,3,3,3,4,$80
; PSG0C:	        dc.b	4,4,3,3,2,2,1,1,1,1,1,1,1,1,1,1
; 		dc.b	1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2
; 		dc.b	2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3
; 		dc.b	3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
; 		dc.b	3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4
; 		dc.b	4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5
; 		dc.b	5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6
; 		dc.b	6,6,6,6,6,6,6,6,6,6,6,6,6,6,7,$80
; PSG0D:	        dc.b	$0E,$0D,$0C,$0B,$0A,9,8,7,6,5,4,3,2,1,0,$80
PSG_Index:
		dc.l		PSGTone_00,PSGTone_01,PSGTone_02,PSGTone_03,PSGTone_04,PSGTone_05
		dc.l		PSGTone_06,PSGTone_07,PSGTone_08,PSGTone_09,PSGTone_0A,PSGTone_0B
		dc.l		PSGTone_0C,PSGTone_0D,PSGTone_0E,PSGTone_0F,PSGTone_10,PSGTone_11
		dc.l		PSGTone_12,PSGTone_13,PSGTone_14,PSGTone_15,PSGTone_16,PSGTone_17
		dc.l		PSGTone_18,PSGTone_19,PSGTone_1A,PSGTone_1B,PSGTone_1C,PSGTone_1D
		dc.l		PSGTone_1E,PSGTone_1F,PSGTone_20,PSGTone_21,PSGTone_22,PSGTone_23
		dc.l		PSGTone_24,PSGTone_25,PSGTone_26,PSGTone_27,PSGTone_28,PSGTone_29
		dc.l		PSGTone_2A,PSGTone_2B,PSGTone_2C,PSGTone_2D,PSGTone_2E,PSGTone_2F
		dc.l		PSGTone_30,PSGTone_31,PSGTone_32,PSGTone_33


       ; $80 - loop flutter   $81 - hold last value    $83 - note off


PSGTone_00:		dc.b    2, $83
PSGTone_01:
PSGTone_0E:
PSGTone_28:		dc.b    0,   2,   4,   6,   8, $10, $83
PSGTone_02:		dc.b    2,   1,   0,   0,   1,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2
                        dc.b    2,   3,   3,   3,   4,   4,   4,   5, $81
PSGTone_03:		dc.b    0,   0,   2,   3,   4,   4,   5,   5,   5,   6,   6, $81
PSGTone_04:		dc.b    3,   0,   1,   1,   1,   2,   3,   4,   4,   5, $81
PSGTone_05:		dc.b    0,   0,   1,   1,   2,   3,   4,   5,   5,   6,   8,   7,   7,   6, $81
PSGTone_06:		dc.b    1, $0C,   3, $0F,   2,   7,   3, $0F, $80
PSGTone_07:		dc.b    0,   0,   0,   2,   3,   3,   4,   5,   6,   7,   8,   9, $0A, $0B, $0E, $0F
                        dc.b  $83
PSGTone_08:		dc.b    3,   2,   1,   1,   0,   0,   1,   2,   3,   4, $81
PSGTone_09:		dc.b    1,   0,   0,   0,   0,   1,   1,   1,   2,   2,   2,   3,   3,   3,   3,   4
                        dc.b    4,   4,   5,   5, $81
PSGTone_0A:		dc.b  $10, $20, $30, $40, $30, $20, $10,   0, $F0, $80
PSGTone_0B:		dc.b    0,   0,   1,   1,   3,   3,   4,   5, $83
PSGTone_0C:		dc.b    0, $81
PSGTone_0D:		dc.b    2, $83
PSGTone_0F:		dc.b    9,   9,   9,   8,   8,   8,   7,   7,   7,   6,   6,   6,   5,   5,   5,   4
                        dc.b    4,   4,   3,   3,   3,   2,   2,   2,   1,   1,   1,   0,   0,   0, $81
PSGTone_10:		dc.b    1,   1,   1,   0,   0,   0, $81
PSGTone_11:		dc.b    3,   0,   1,   1,   1,   2,   3,   4,   4,   5, $81
PSGTone_12:		dc.b    0,   0,   1,   1,   2,   3,   4,   5,   5,   6,   8,   7,   7,   6, $81
PSGTone_13:		dc.b  $0A,   5,   0,   4,   8, $83
PSGTone_14:		dc.b    0,   0,   0,   2,   3,   3,   4,   5,   6,   7,   8,   9, $0A, $0B, $0E, $0F
                        dc.b  $83
PSGTone_15:		dc.b    3,   2,   1,   1,   0,   0,   1,   2,   3,   4, $81
PSGTone_16:		dc.b    1,   0,   0,   0,   0,   1,   1,   1,   2,   2,   2,   3,   3,   3,   3,   4
                        dc.b    4,   4,   5,   5, $81
PSGTone_17:		dc.b  $10, $20, $30, $40, $30, $20, $10,   0, $80
PSGTone_18:		dc.b    0,   0,   1,   1,   3,   3,   4,   5, $83
PSGTone_19:		dc.b    0,   2,   4,   6,   8, $16, $83
PSGTone_1A:		dc.b    0,   0,   1,   1,   3,   3,   4,   5, $83
PSGTone_1B:		dc.b    4,   4,   4,   4,   3,   3,   3,   3,   2,   2,   2,   2,   1,   1,   1,   1
                        dc.b  $83
PSGTone_1C:		dc.b    0,   0,   0,   0,   1,   1,   1,   1,   2,   2,   2,   2,   3,   3,   3,   3
                        dc.b    4,   4,   4,   4,   5,   5,   5,   5,   6,   6,   6,   6,   7,   7,   7,   7
                        dc.b    8,   8,   8,   8,   9,   9,   9,   9, $0A, $0A, $0A, $0A, $81
PSGTone_1D:		dc.b    0, $0A, $83
PSGTone_1E:		dc.b    0,   2,   4, $81
PSGTone_1F:		dc.b  $30, $20, $10,   0,   0,   0,   0,   0,   8, $10, $20, $30, $81
PSGTone_20:		dc.b    0,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   6,   6,   6,   8,   8
                        dc.b  $0A, $83
PSGTone_21:		dc.b    0,   2,   3,   4,   6,   7, $81
PSGTone_22:		dc.b    2,   1,   0,   0,   0,   2,   4,   7, $81
PSGTone_23:		dc.b  $0F,   1,   5, $83
PSGTone_24:		dc.b    8,   6,   2,   3,   4,   5,   6,   7,   8,   9, $0A, $0B, $0C, $0D, $0E, $0F
                        dc.b  $10, $83
PSGTone_25:		dc.b    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   1,   1,   1,   1,   1,   1
                dc.b    1,   1,   1,   1,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   3,   3
                dc.b    3,   3,   3,   3,   3,   3,   3,   3,   4,   4,   4,   4,   4,   4,   4,   4
                dc.b    4,   4,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   6,   6,   6,   6
                dc.b    6,   6,   6,   6,   6,   6,   7,   7,   7,   7,   7,   7,   7,   7,   7,   7
                dc.b    8,   8,   8,   8,   8,   8,   8,   8,   8,   8,   9,   9,   9,   9,   9,   9
                dc.b    9,   9, $83
PSGTone_26:		dc.b    0,   2,   2,   2,   3,   3,   3,   4,   4,   4,   5,   5, $83
PSGTone_27:     dc.b	  0,   0,   0,   1,   1,   1,   2,   2,   2,   3,   3,   3,   4,   4,   4,   5
                dc.b	  5,   5,   6,   6,   6,   7, $81
PSGTone_29:     dc.b	  0,   0,   1,   1,   2,   2,   3,   3,   4,   4,   5,   5,   6,   6,   7,   7, $81
PSGTone_2A:     dc.b	  0,   0,   2,   3,   4,   4,   5,   5,   5,   6, $81
PSGTone_2C:     dc.b	  3,   3,   3,   2,   2,   2,   2,   1,   1,   1,   0,   0,   0,   0, $81
PSGTone_2B:     dc.b	  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   1,   1
                dc.b	  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   2,   2,   2,   2
                dc.b	  2,   2,   2,   2,   3,   3,   3,   3,   3,   3,   3,   3,   4, $81
PSGTone_33:     dc.b	$0E, $0D, $0C, $0B, $0A,   9,   8,   7,   6,   5,   4,   3,   2,   1,   0, $81



PSGTone_2D:     dc.b	  0,   0,   0,   0,   0,   0,   1,   1,   1,   1,   1,   2,   2,   2,   2,   2
                dc.b	  3,   3,   3,   4,   4,   4,   5,   5,   5,   6,   7, $81
PSGTone_2E:     dc.b	  0,   0,   0,   0,   0,   1,   1,   1,   1,   1,   2,   2,   2,   2,   2,   2
                dc.b	  3,   3,   3,   3,   3,   4,   4,   4,   4,   4,   5,   5,   5,   5,   5,   6
                dc.b	  6,   6,   6,   6,   7,   7,   7, $81
PSGTone_2F:     dc.b	  0,   1,   2,   3,   4,   5,   6,   7,   8,   9, $0A, $0B, $0C, $0D, $0E, $0F, $83
PSGTone_30:     dc.b	  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   1,   1,   1,   1,   1,   1
                dc.b	  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1
                dc.b	  1,   1,   1,   1,   1,   1,   1,   1,   2,   2,   2,   2,   2,   2,   2,   2
                dc.b	  2,   2,   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,   4, $81
PSGTone_31:     dc.b	  4,   4,   4,   3,   3,   3,   2,   2,   2,   1,   1,   1,   1,   1,   1,   1
                dc.b	  2,   2,   2,   2,   2,   3,   3,   3,   3,   3,   4, $81
PSGTone_32:     dc.b	  4,   4,   3,   3,   2,   2,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1
                dc.b	  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   2,   2,   2,   2,   2,   2
                dc.b	  2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   3,   3
                dc.b	  3,   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,   3
                dc.b	  3,   3,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4
                dc.b	  4,   4,   4,   4,   4,   4,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5
                dc.b	  5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   6,   6,   6,   6,   6,   6
                dc.b	  6,   6,   6,   6,   6,   6,   6,   6,   6,   6,   6,   6,   6,   6,   7, $81






byte_71A94:	dc.b 7,	$72, $73, $26, $15, 8, $FF, 5

; ---------------------------------------------------------------------------
; Type of sound	being played ($90 = music; $70 = normal	sound effect)
; ---------------------------------------------------------------------------
; SoundTypes:	dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
; 		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$80
; 		dc.b $70, $70, $70, $70, $70, $70, $70,	$70, $70, $68, $70, $70, $70, $60, $70,	$70
; 		dc.b $60, $70, $60, $70, $70, $70, $70,	$70, $70, $70, $70, $70, $70, $70, $7F,	$60
; 		dc.b $70, $70, $70, $70, $70, $70, $70,	$70, $70, $70, $70, $70, $70, $70, $70,	$80
; 		dc.b $80, $80, $80, $80, $80, $80, $80,	$80, $80, $80, $80, $80, $80, $80, $80,	$90
; 		dc.b $90, $90, $90, $90
SoundTypes:	dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90, $90
                even


; ---------------------------------------------------------------------------
; Subroutine to update music more than once per frame
; (Called by horizontal & vert. interrupts)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


UpdateMusic:				; XREF: VBlank; HBlank
		stopZ80
		nop
		nop                                        
		nop

loc_71B5A:
		btst	#0,($A11100).l
		bne.s	loc_71B5A

		btst	#7,($A01FFD).l
		beq.s	loc_71B82
		startZ80
		nop	
		nop
		nop
		nop
		nop
		bra.s	UpdateMusic
; ===========================================================================

loc_71B82:
		lea	($FFF000).l,a6
		clr.b	$E(a6)          ; clear voice selector
		tst.b	3(a6)		; is music paused?                     (f_stopmusic)
		bne.w	PauseMusic	; if yes, branch
		jsr	TempoWait(pc)

		move.b	4(a6),d0         ;
		beq.s	@skipfadeout
		jsr	sub_72504(pc)

@skipfadeout:
		tst.b	$24(a6)
		beq.s	@skipfadein
		jsr	sub_7267C(pc)

@skipfadein:
		tst.w	$A(a6)		; is music or sound being played?      (v_playsnd1)
		beq.s	loc_71BBC	; if not, branch
		jsr	Sound_Play(pc)

loc_71BBC:
		cmpi.b	#$80,9(a6)      ;                                      (v_playsnd0)
		beq.s	loc_71BC8
		jsr	Sound_ChkValue(pc)

; loc_71BC8:    ; +++ replaced below, spindash sfx rev up
; 		lea	$40(a6),a5
; 		tst.b	(a5)
; 		bpl.s	SkipDAC
; 		jsr	DACUpdateTrack(pc)

loc_71BC8:
		tst.b	(v_timersfxspindash).w
		beq.s	@cont
		subq.b	#1,(v_timersfxspindash).w

@cont:
		lea	$40(a6),a5     ;                                       a5 = FFFFF040
		tst.b	(a5)                      ; is dac channel playing?
		bpl.s	SkipDAC
		jsr	DACUpdateTrack(pc)            ; update channel


SkipDAC:
		clr.b	8(a6)
		moveq	#5,d7                     ; No. of FM channels

RunFMChannelLoop:
		adda.w	#$30,a5                   ; load next channel
		tst.b	(a5)                      ; is fm channel playing
		bpl.s	SkipFM
		jsr	FMUpdateTrack(pc)             ; update channel

SkipFM:
		dbf	d7,RunFMChannelLoop

		moveq	#2,d7                     ; no. of PSG channels

RunPSGChannelLoop:
		adda.w	#$30,a5                   ; load next channel
		tst.b	(a5)                      ; is psg track playing
		bpl.s	SkipPSG
		jsr	PSGUpdateTrack(pc)            ; update channel

SkipPSG:
		dbf	d7,RunPSGChannelLoop

		move.b	#$80,$E(a6)
		moveq	#2,d7

loc_71C04:
		adda.w	#$30,a5
		tst.b	(a5)                      ; is fm sfx playing?
		bpl.s	loc_71C10
		jsr	FMUpdateTrack(pc)             ; update channel

loc_71C10:
		dbf	d7,loc_71C04

		moveq	#2,d7

loc_71C16:
		adda.w	#$30,a5
		tst.b	(a5)                      ; is psg sfx plaing?
		bpl.s	loc_71C22
		jsr	PSGUpdateTrack(pc)            ; update channel

loc_71C22:
		dbf	d7,loc_71C16
		move.b	#$40,$E(a6)
		adda.w	#$30,a5
		tst.b	(a5)
		bpl.s	loc_71C38
		jsr	FMUpdateTrack(pc)

loc_71C38:
		adda.w	#$30,a5
		tst.b	(a5)
		bpl.s	loc_71C44
		jsr	PSGUpdateTrack(pc)

loc_71C44:
        	startZ80
    if PALMusicSpeedup=1
		btst	#6,(v_megadrive).w            ; is Megadrive PAL?
		beq.s	@end	                      ; if not, branch
                cmpi.b  #$5,(v_palmuscounter).w       ; 5th frame?
                bne.s   @end                          ; if not, branch
                move.b  #$0,(v_palmuscounter).w       ; reset counter
		bra.w	UpdateMusic                   ; run sound driver again
@end:
                addq.b  #$1,(v_palmuscounter).w       ; add 1 to frame count
     endif
		rts

; End of function UpdateMusic


; ---------------------------------------------------------------------------
; Subroutine to allow a DAC sample to be played
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

DACUpdateTrack:				; XREF: UpdateMusic
		subq.b	#1,sCurrentNotefill(a5) ; decrease timer
		bne.s	locret_71CAA            ; if not finished, branch
		move.b	#$80,8(a6)              ; set as DAC channel
		movea.l	sTrackPos(a5),a4        ; load note address ; (v_dac_ptr) DAC channel pointer (4 bytes)

@CheckFlagDAC:
		moveq	#0,d5                   ; clear d5
		move.b	(a4)+,d5                ; load note
		cmpi.b	#$E0,d5                 ; is it a flag?
		bcs.s	loc_71C6E               ; if not, branch
		jsr	FlagRoutine(pc)         ; run flag routine
		bra.s	@CheckFlagDAC           ; recheck
; ===========================================================================

loc_71C6E:
		tst.b	d5                      ; is the note a timer?
		bpl.s	loc_71C84               ; if so, branch
		move.b	d5,sFrequency(a5)       ; save as note
		move.b	(a4)+,d5                ; load next note
		bpl.s	loc_71C84               ; if it's a timer, branch
		subq.w	#1,a4                   ; go back for next cycle
		move.b	sLastNotefill(a5),sCurrentNotefill(a5) ; update timer
		bra.s	loc_71C88
; ===========================================================================

loc_71C84:
		jsr	TimerRoutine(pc)        ; run timer routine

loc_71C88:                                      
		move.l	a4,sTrackPos(a5)        ; save new note address ; (v_dac_ptr) DAC channel pointer (4 bytes)
		btst	#bitSFXOverride,(a5)    ; has channel been set to make a sound?
		bne.s	locret_71CAA            ; if not, branch
		moveq	#0,d0                   ; clear d0
		move.b	sFrequency(a5),d0       ; load note
		cmpi.b	#$80,d0                 ; is it 80 (rest)?
		beq.s	locret_71CAA            ; if so, branch
		move.b	d0,($A01FFF).l          ; put number of sample to play in z80 ram
                moveq   #0,d0
                move.b  (v_drumkit).w,d0        ; the drum kit being used
                mulu.w  #$80,d0                 ; each drumset is $80 bytes
                move.b  d0,($A01FFA).l          ; put drumset offset into z80 ram
                lsr.w   #8,d0                   ; get upper byte of offset
                move.b  d0,($A01FFB).l          ; put drumset offset into z80 ram


locret_71CAA:
		rts	
; ===========================================================================

loc_71CAC:
		subi.b	#$88,d0
		move.b	byte_71CC4(pc,d0.w),d0
		move.b	d0,($A000EA).l
		move.b	#$83,($A01FFF).l
		rts	
; End of function DACUpdateTrack

; ===========================================================================
byte_71CC4:	dc.b $12, $15, $1C, $1D, $FF, $FF

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; ---------------------------------------------------------------------------
; Subroutine to play an FM note
; ---------------------------------------------------------------------------

FMUpdateTrack:				; XREF: UpdateMusic
		subq.b	#1,sCurrentNotefill(a5) ; decrease timer
		bne.s	loc_71CE0               ; if not finished, branch
		bclr	#bitNoAttack,(a5)                 ; clear "no attack" flag
		jsr	sub_71CEC(pc)           ; get note to play
		jsr	sub_71E18(pc)
		bra.w	loc_726E2
; ===========================================================================

loc_71CE0:
		jsr	NoteFillUpdate(pc)
		jsr	DoModulation(pc)
		bra.w	FMUpdateFreq
; End of function FMUpdateTrack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_71CEC:				; XREF: FMUpdateTrack
		movea.l	sTrackPos(a5),a4        ; load note address
		bclr	#bitAtRest,(a5)                 ; clear "track at rest" flag

@CheckFlag:
		moveq	#0,d5                   ; clear d5
		move.b	(a4)+,d5                ; load note
		cmpi.b	#$E0,d5                 ; is it a flag?
		bcs.s	loc_71D04               ; if not, branch
		jsr	FlagRoutine(pc)         ; run flag routine
		bra.s	@CheckFlag              ; recheck
; ===========================================================================

loc_71D04:
		jsr	FMNoteOff(pc)
		tst.b	d5                      ; is the note a timer?
		bpl.s	JumpToTimer             ; if so, branch
		jsr	GetNotePitch(pc)        ; get the pitch of the note to play
		move.b	(a4)+,d5                ; load note
		bpl.s	JumpToTimer             ; if a timer, branch
		subq.w	#1,a4                   ; un-advance note address
		bra.w	FinishTrackUpdate
; ===========================================================================

JumpToTimer:
		jsr	TimerRoutine(pc)
		bra.w	FinishTrackUpdate
; End of function sub_71CEC


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


GetNotePitch:				; XREF: sub_71CEC
		subi.b	#$80,d5                 ; sub $80 to get note
		beq.s	FMRest                  ; if note is a rest, branch
		add.b	sTranspose(a5),d5       ; add channel pitch
		add.b   (v_musicpitch).w,d5
		andi.w	#$7F,d5
		lsl.w	#1,d5
		lea	FMPitchTable(pc),a0
		move.w	(a0,d5.w),d6            ; get pitch to send to YM2612
		move.w	d6,sFrequency(a5)
		rts
; End of function GetNotePitch


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


TimerRoutine:				; XREF: DACUpdateTrack; sub_71CEC; sub_72878
     ; set note length by multiplying by the tempo divider
		move.b	d5,d0                   ; move note length to d0
		move.b	sTimingDivisor(a5),d1   ; move tempo divider to d1

@multiply:
		subq.b	#1,d1                   ; sub 1 from tempo divider
		beq.s	SetNoteLength           ; if 0 then branch
		add.b	d5,d0                   ; add note length again
		bra.s	@multiply               ; loop
; ===========================================================================

SetNoteLength:
		move.b	d0,sLastNotefill(a5)    ; set saved note length
		move.b	d0,sCurrentNotefill(a5) ; set length of current note
		rts	
; End of function TimerRoutine

; ===========================================================================

FMRest:				; XREF: GetNotePitch
		bset	#bitAtRest,(a5)                 ; set "track at rest" flag
		clr.w	sFrequency(a5)          ; clear note to play

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FinishTrackUpdate:				; XREF: sub_71CEC; sub_72878; sub_728AC
		move.l	a4,sTrackPos(a5)        ; save new note address
		move.b	sLastNotefill(a5),sCurrentNotefill(a5) ; set current note length to last saved note length
		btst	#bitNoAttack,(a5)                 ; is "no attack" flag set
		bne.s	@end                    ; if so, branch
		move.b	sLastDuration(a5),sCurrentDuration(a5) ; reset note fill to last valve
		clr.b	sPSGFlutter(a5)         ; reset PSG flutter
		btst	#bitModulation,(a5)                 ; is modulation on?
		beq.s	@end                    ; if not branch
		movea.l	sModWait(a5),a0         ; point to modulation stored data
		move.b	(a0)+,sModWaitWork(a5)  ; modulation wait time
		move.b	(a0)+,sModSpeedWork(a5) ; modulation speed
		move.b	(a0)+,sModDeltaWork(a5) ; modulation change per step
		move.b	(a0)+,d0                ; get number of steps in modulation
		lsr.b	#1,d0                   ; divide by 2
		move.b	d0,sModStepsWork(a5)    ; set
		clr.w	$1C(a5)                 ; clear modulation value

@end:
		rts
; End of function FinishTrackUpdate


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


NoteFillUpdate:				; XREF: FMUpdateTrack; PSGUpdateTrack
		tst.b	sCurrentDuration(a5)    ; is note fill value 0
		beq.s	@end                    ; if so, branch
		subq.b	#1,sCurrentDuration(a5) ; sub 1 from note fill value
		bne.s	@end                    ; if 0, branch
		bset	#bitAtRest,(a5)         ; set 'track at rest' flag
		tst.b	sVoiceControl(a5)       ; is current channel PSG?
		bmi.w	@psgtrack               ; if so, branch
		jsr	FMNoteOff(pc)
		addq.w	#4,sp
		rts

@psgtrack:
		jsr	PSGNoteOff(pc)
		addq.w	#4,sp

@end:
		rts
; End of function NoteFillUpdate


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DoModulation:				; XREF: FMUpdateTrack; PSGUpdateTrack
		addq.w	#4,sp
		btst	#bitModulation,(a5)                 ; is modulation on?
		beq.s	locret_71E16            ; if not, branch
		tst.b	sModWaitWork(a5)        ; is modulation wait time 0?
		beq.s	loc_71DDA               ; if so, branch
		subq.b	#1,sModWaitWork(a5)     ; sub 1 from wait time
		rts	                        ; keep waiting
; ===========================================================================

loc_71DDA:
		subq.b	#1,sModSpeedWork(a5)    ; sub 1 from modulation speed
		beq.s	loc_71DE2               ; if now 0, branch
		rts	                        ; return
; ===========================================================================

loc_71DE2:
		movea.l	sModWait(a5),a0         ; point to modulation stored data
		move.b	1(a0),sModSpeedWork(a5) ; restore modulation speed
		tst.b	sModStepsWork(a5)       ; if number of steps is not 0
		bne.s	loc_71DFE               ; branch
		move.b	3(a0),sModStepsWork(a5) ; restore the number of steps
		neg.b	sModDeltaWork(a5)       ; negate the change per step
		rts	
; ===========================================================================

loc_71DFE:
		subq.b	#1,sModStepsWork(a5)    ; decrement the step
		move.b	sModDeltaWork(a5),d6    ; get change per step
		ext.w	d6                      ; sign extend
		add.w	$1C(a5),d6              ; add modulation value
		move.w	d6,$1C(a5)              ; set new modulation value
		add.w	sFrequency(a5),d6       ; add current note frequency
		subq.w	#4,sp

locret_71E16:
		rts
; End of function DoModulation


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_71E18:				; XREF: FMUpdateTrack
		btst	#bitAtRest,(a5)
		bne.s	locret_71E48
		move.w	sFrequency(a5),d6
		beq.s	loc_71E4A

FMUpdateFreq:				; XREF: FMUpdateTrack
		move.b	sFreqAdjust(a5),d0
		ext.w	d0                      ; sign extend
		add.w	d0,d6                   ; add 
		btst	#bitSFXOverride,(a5)
		bne.s	locret_71E48
		move.w	d6,d1
		lsr.w	#8,d1
		move.b	#-$5C,d0
		jsr	sub_72722(pc)
		move.b	d6,d1
		move.b	#-$60,d0
		jsr	sub_72722(pc)

locret_71E48:
		rts	
; ===========================================================================

loc_71E4A:
		bset	#bitAtRest,(a5)
		rts	
; End of function sub_71E18

; ===========================================================================

PauseMusic:				; XREF: UpdateMusic
		bmi.s	loc_71E94
		cmpi.b	#2,3(a6)
		beq.w	loc_71EFE
		move.b	#2,3(a6)
		moveq	#2,d3
		move.b	#-$4C,d0
		moveq	#0,d1

loc_71E6A:
		jsr	YM2612_Save01(pc)
		jsr	YM2612_Save02(pc)
		addq.b	#1,d0
		dbf	d3,loc_71E6A

		moveq	#2,d3
		moveq	#$28,d0

loc_71E7C:
		move.b	d3,d1
		jsr	YM2612_Save01(pc)
		addq.b	#4,d1
		jsr	YM2612_Save01(pc)
		dbf	d3,loc_71E7C

		jsr	sub_729B6(pc)
		bra.w	loc_71C44
; ===========================================================================

loc_71E94:				; XREF: PauseMusic
		clr.b	3(a6)
		moveq	#$30,d3
		lea	$40(a6),a5
		moveq	#6,d4

loc_71EA0:
		btst	#bitIsPlaying,(a5)
		beq.s	loc_71EB8
		btst	#bitSFXOverride,(a5)
		bne.s	loc_71EB8
		move.b	#-$4C,d0
		move.b	sPan(a5),d1
		jsr	sub_72722(pc)

loc_71EB8:
		adda.w	d3,a5
		dbf	d4,loc_71EA0

		lea	$220(a6),a5
		moveq	#2,d4

loc_71EC4:
		btst	#bitIsPlaying,(a5)
		beq.s	loc_71EDC
		btst	#bitSFXOverride,(a5)
		bne.s	loc_71EDC
		move.b	#-$4C,d0
		move.b	sPan(a5),d1
		jsr	sub_72722(pc)

loc_71EDC:
		adda.w	d3,a5
		dbf	d4,loc_71EC4

		lea	$340(a6),a5
		btst	#bitIsPlaying,(a5)
		beq.s	loc_71EFE
		btst	#bitSFXOverride,(a5)
		bne.s	loc_71EFE
		move.b	#-$4C,d0
		move.b	sPan(a5),d1
		jsr	sub_72722(pc)

loc_71EFE:
		bra.w	loc_71C44

; ---------------------------------------------------------------------------
; Subroutine to	play a sound or	music track
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sound_Play:				; XREF: UpdateMusic
		movea.l	(Go_SoundTypes).l,a0
		lea	$A(a6),a1	; load music track number
		move.b	0(a6),d3
		moveq	#2,d4

loc_71F12:
		move.b	(a1),d0		; move track number to d0
		move.b	d0,d1
		clr.b	(a1)+
		subi.b	#$81,d0
		bcs.s	loc_71F3E
		cmpi.b	#$80,9(a6)
		beq.s	loc_71F2C
		move.b	d1,$A(a6)
		bra.s	loc_71F3E
; ===========================================================================

loc_71F2C:
		andi.w	#$7F,d0
		move.b	(a0,d0.w),d2
		cmp.b	d3,d2
		bcs.s	loc_71F3E
		move.b	d2,d3
		move.b	d1,9(a6)	; set music flag

loc_71F3E:
		dbf	d4,loc_71F12

		tst.b	d3
		bmi.s	locret_71F4A
		move.b	d3,0(a6)

locret_71F4A:
		rts	
; End of function Sound_Play


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sound_ChkValue:				; XREF: UpdateMusic
		moveq	#0,d7
		move.b	9(a6),d7
		beq.w	Sound_E4
		bpl.s	locret_71F8C
		move.b	#$80,9(a6)	; reset	music flag
		cmpi.b	#$9F,d7
		bls.w	Sound_81to9F	; music	$81-$9F
		cmpi.b	#$A0,d7
		bcs.w	locret_71F8C
		cmpi.b	#$CF,d7
		bls.w	Sound_A0toCF	; sound	$A0-$CF
		cmpi.b	#$D0,d7
		bcs.w	locret_71F8C
		cmpi.b	#$D1,d7         ; +++ was #$E0,d7
		bcs.w	Sound_D0toDF	; sound	$D0
		cmp.b	#$DF,d7
		ble	Sound_D1toDF    ; +++ sound $D1-$DF
		cmpi.b	#$E4,d7
		bls.s	Sound_E0toE4	; sound	$E0-$E4
		cmpi.b	#$FF,d7         ; +++ extend music
		bls.w	Sound_E5toFF    ; +++ $E5-$FF

locret_71F8C:
		rts
; ===========================================================================

Sound_E0toE4:				; XREF: Sound_ChkValue
		subi.b	#$E0,d7
		lsl.w	#2,d7
		jmp	Sound_ExIndex(pc,d7.w)
; ===========================================================================

Sound_ExIndex:
		bra.w	Sound_E0
; ===========================================================================
		bra.w	Sound_E1
; ===========================================================================
		bra.w	Sound_E2
; ===========================================================================
		bra.w	Sound_E3
; ===========================================================================
		bra.w	Sound_E4
; ===========================================================================
; ---------------------------------------------------------------------------
; Play "Say-gaa" PCM sound
; ---------------------------------------------------------------------------

;Sound_E1:				; XREF: Sound_ExIndex
;		move.b	#$88,($A01FFF).l
;		startZ80
;		move.w	#$11,d1
; +++ fix the sega sound
Sound_E1:
		lea	(SegaPCM).l,a2			; Load the SEGA PCM sample into a2. It's important that we use a2 since a0 and a1 are going to be used up ahead when reading the joypad ports
		move.l	#$6978,d3			; Load the size of the SEGA PCM sample into d3 
		move.b	#$2A,($A04000).l		; $A04000 = $2A -> Write to DAC channel	  
PlayPCM_Loop:	  
		move.b	(a2)+,($A04001).l		; Write the PCM data (contained in a2) to $A04001 (YM2612 register D0)
		move.w	#$2,d0				; Write the pitch ($14 in this case) to d0  +++ change this to make it sound funny
		dbf	d0,*				; Decrement d0; jump to itself if not 0. (for pitch control, avoids playing the sample too fast)
		sub.l	#1,d3				; Subtract 1 from the PCM sample size 
		beq.s	return_PlayPCM			; If d3 = 0, we finished playing the PCM sample, so stop playing, leave this loop, and unfreeze the 68K 
		lea	($FFFFF604).w,a0		; address where JoyPad states are written
		lea	($A10003).l,a1			; address where JoyPad states are read from
		jsr	(ReadJoypads).w			; Read only the first joypad port. It's important that we do NOT do the two ports, we don't have the cycles for that
		btst	#7,($FFFFF604).w		; Check for Start button 
		bne.s	return_PlayPCM			; If start is pressed, stop playing, leave this loop, and unfreeze the 68K 
		bra.s	PlayPCM_Loop			; Otherwise, continue playing PCM sample
return_PlayPCM: 
		addq.w	#4,sp 
		rts

loc_71FC0:
		move.w	#-1,d0

loc_71FC4:
		nop	
		dbf	d0,loc_71FC4

		dbf	d1,loc_71FC0

		addq.w	#4,sp
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Play music track $81-$9F
; ---------------------------------------------------------------------------
Sound_E5toFF:              ; +++ added music tracks
		clr.b	$27(a6)
		clr.b	$26(a6)
		jsr	InitMusicPlayback(pc)
		movea.l	(Go_SpeedUpIndex).l,a4
		subi.b	#$E5,d7
		move.b	(a4,d7.w),$29(a6)
		movea.l	(Go_MusicIndex_E5toFF).l,a4
		move.b  d7,(v_currentsong).w
                jmp Music_Continue

Sound_81to9F:				; XREF: Sound_ChkValue
                           ; +++ shortcut to stop music
		cmpi.b	#$80,d7                 ; is track $80 played?
		bne.s	@not80	                ; if not, branch
		move.b  #$E4,d7                 ; set music to stop

      @not80:
		cmpi.b	#bgm_ExtraLife,d7       ; is "extra life" music	played?
		bne.s	loc_72024	        ; if not, branch
		tst.b	$27(a6)
		bne.w	loc_721B6
		lea	$40(a6),a5
		moveq	#9,d0

loc_71FE6:
		bclr	#bitSFXOverride,(a5)
		adda.w	#$30,a5
		dbf	d0,loc_71FE6

		lea	$220(a6),a5
		moveq	#5,d0

loc_71FF8:
		bclr	#bitIsPlaying,(a5)
		adda.w	#$30,a5
		dbf	d0,loc_71FF8
		clr.b	0(a6)
		movea.l	a6,a0
		lea	$3A0(a6),a1
		move.w	#$87,d0

loc_72012:
		move.l	(a0)+,(a1)+
		dbf	d0,loc_72012

		move.b	#$80,$27(a6)
		clr.b	0(a6)
		bra.s	Snd_LoadMusic
; ===========================================================================

loc_72024:
		clr.b	$27(a6)
		clr.b	$26(a6)

; Snd_LoadMusic:              ;  +++
; 		jsr	InitMusicPlayback(pc)
; 		movea.l	(Go_SpeedUpIndex).l,a4
; 		subi.b	#$81,d7
; 		move.b	(a4,d7.w),$29(a6)
; 		movea.l	(Go_MusicIndex).l,a4
; 		lsl.w	#2,d7
; 		movea.l	(a4,d7.w),a4
; 		moveq	#0,d0
; 		move.w	(a4),d0		; load voice pointer
; 		add.l	a4,d0
; 		move.l	d0,$18(a6)
; 		move.b	5(a4),d0	; load tempo
; 		move.b	d0,$28(a6)
; 		tst.b	$2A(a6)
; 		beq.s	loc_72068
; 		move.b	$29(a6),d0

Snd_LoadMusic:
		jsr	InitMusicPlayback(pc)
		movea.l	(Go_SpeedUpIndex).l,a4
		subi.b	#$81,d7
		move.b	(a4,d7.w),$29(a6)
		movea.l	(Go_MusicIndex).l,a4
		move.b  d7,(v_currentsong).w

Music_Continue:
		lsl.w	#2,d7
		movea.l	(a4,d7.w),a4
		moveq	#0,d0
		move.w	(a4),d0
		add.l	a4,d0
		move.l	d0,$18(a6)
		move.b	5(a4),d0         ; load tempo modulator
		move.b	d0,$28(a6)
		tst.b	$2A(a6)
		beq.s	loc_72068
		move.b	$29(a6),d0
		move.b	d0,$28(a6)      ; (v_tempo_mod)
		tst.b	$2A(a6)
		beq.s	loc_72068
		move.b	$29(a6),d0
loc_72068:
		move.b	d0,2(a6)
		move.b	d0,1(a6)
		moveq	#0,d1
		movea.l	a4,a3
		addq.w	#6,a4
		moveq	#0,d7
		move.b	2(a3),d7	; load number of FM channels
		beq.w	loc_72114	; branch if zero
		subq.b	#1,d7
		move.b	#-$40,d1
		move.b	4(a3),d4	; load tempo dividing timing
		moveq	#$30,d6
		move.b	#1,d5
		lea	$40(a6),a1
		lea	byte_721BA(pc),a2

Snd_FMLoadLoop:
		bset	#bitIsPlaying,(a1)                 ; set channel as valid (unstopped)
		move.b	(a2)+,sVoiceControl(a1)             ; store YM2612 data
		move.b	d4,sTimingDivisor(a1)   ; set the tempo divider
		move.b	d6,sReturnLocation(a1)               ; set 30
		move.b	d1,sPan(a1)             ; set panning
		move.b	d5,sCurrentNotefill(a1) ; set default time delay
		moveq	#0,d0                   ; clear d0
		move.w	(a4)+,d0	        ; load channel address ; load DAC/FM pointer
		add.l	a3,d0                   ; add music offset
		move.l	d0,sTrackPos(a1)                ; set note address
		move.w	(a4)+,sTranspose(a1)	        ; save pitch/volume ; load FM channel modifier
		adda.w	d6,a1                   ; advance to next channel
		dbf	d7,Snd_FMLoadLoop
		cmpi.b	#7,2(a3)
		bne.s	loc_720D8
		moveq	#$2B,d0
		moveq	#0,d1
		jsr	YM2612_Save01(pc)
		bra.w	loc_72114
; ===========================================================================

loc_720D8:
		moveq	#$28,d0
		moveq	#6,d1
		jsr	YM2612_Save01(pc)
		move.b	#$42,d0
		moveq	#$7F,d1
		jsr	YM2612_Save02(pc)
		move.b	#$4A,d0
		moveq	#$7F,d1
		jsr	YM2612_Save02(pc)
		move.b	#$46,d0
		moveq	#$7F,d1
		jsr	YM2612_Save02(pc)
		move.b	#$4E,d0
		moveq	#$7F,d1
		jsr	YM2612_Save02(pc)
		move.b	#$B6,d0
		move.b	#$C0,d1
		jsr	YM2612_Save02(pc)

loc_72114:
		moveq	#0,d7
		move.b	3(a3),d7
		beq.s	loc_72154
		subq.b	#1,d7
		lea	$190(a6),a1
		lea	byte_721C2(pc),a2

Snd_PSGLoadLoop:
		bset	#bitIsPlaying,(a1)
		move.b	(a2)+,sVoiceControl(a1)
		move.b	d4,2(a1)
		move.b	d6,sReturnLocation(a1)
		move.b	d5,sCurrentNotefill(a1)
		moveq	#0,d0
		move.w	(a4)+,d0	; load PSG channel pointer
		add.l	a3,d0
		move.l	d0,sTrackPos(a1)
		move.w	(a4)+,sTranspose(a1)	; load PSG modifier
		move.b	(a4)+,d0	; load redundant byte
		move.b	(a4)+,sCurrentVoice(a1)
		adda.w	d6,a1
		dbf	d7,Snd_PSGLoadLoop

loc_72154:
		lea	$220(a6),a1
		moveq	#5,d7

loc_7215A:
		tst.b	(a1)
		bpl.w	loc_7217C
		moveq	#0,d0
		move.b	1(a1),d0
		bmi.s	loc_7216E
		subq.b	#2,d0
		lsl.b	#2,d0
		bra.s	loc_72170
; ===========================================================================

loc_7216E:
		lsr.b	#3,d0

loc_72170:
		lea	ChannelRAM(pc),a0
		movea.l	(a0,d0.w),a0
		bset	#bitSFXOverride,(a0)

loc_7217C:
		adda.w	d6,a1
		dbf	d7,loc_7215A

		tst.w	$340(a6)
		bpl.s	loc_7218E
		bset	#2,$100(a6)

loc_7218E:
		tst.w	$370(a6)
		bpl.s	loc_7219A
		bset	#2,$1F0(a6)

loc_7219A:
		lea	$70(a6),a5
		moveq	#5,d4

Snd_RunFMLoop:
                moveq   #0,d1
;                move.b  (v_musicpitch).l,d1
;                add.b	d1,sTranspose(a5)                ; +++ shift note pitch
		jsr	FMNoteOff(pc)
		adda.w	d6,a5
                dbf	d4,Snd_RunFMLoop	; run all FM channels
		moveq	#2,d4

Snd_RunPSGLoop:
                moveq   #0,d1
;                 move.b  (v_musicpitch).l,d1
;                 tst.b   d4                      ; +++ if doing noise channel
;                 beq.s   @nopitch                ; +++ don't shift pitch
; 		add.b	d1,sTranspose(a5)                ; +++ shift note pitch
;        @nopitch:
		jsr	PSGNoteOff(pc)
		adda.w	d6,a5
		dbf	d4,Snd_RunPSGLoop	; run all PSG channels

loc_721B6:
		addq.w	#4,sp
		rts	
; ===========================================================================
byte_721BA:	dc.b 6,	0, 1, 2, 4, 5, 6, 0
		even
byte_721C2:	dc.b $80, $A0, $C0, 0
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Play normal sound effect
; ---------------------------------------------------------------------------

; Sound_D1toDF:                                        ; +++ code for added sound slots
; 		tst.b	$27(a6)                      ;
; 		bne.w	loc_722C6                    ;
; 		tst.b	4(a6)                        ;
; 		bne.w	loc_722C6                    ;
; 		tst.b	$24(a6)                      ;
; 		bne.w	loc_722C6                    ;
; 		movea.l	(Go_SoundIndex).l,a0         ;
; 		sub.b	#$A1,d7                      ;
; 		bra	SoundEffects_Common          ;

Sound_D1toDF:
		tst.b	$27(a6)
		bne.w	loc_722C6
		tst.b	4(a6)
		bne.w	loc_722C6
		tst.b	$24(a6)
		bne.w	loc_722C6
		clr.b	(v_wassfxspindash).w
		cmp.b	#sfx_spindash,d7		; is this the Spin Dash sound?
		bne.s	@cont3	; if not, branch
		move.w	d0,-(sp)
		move.b	(v_pitchsfxspindash).w,d0	; store extra frequency
		tst.b	(v_timersfxspindash).w	; is the Spin Dash timer active?
		bne.s	@cont1		; if it is, branch
		move.b	#-1,d0		; otherwise, reset frequency (becomes 0 on next line)
 
@cont1:
		addq.b	#1,d0
		cmp.b	#$C,d0		; has the limit been reached?
		bcc.s	@cont2		; if it has, branch
		move.b	d0,(v_pitchsfxspindash).w	; otherwise, set new frequency
 
@cont2:
		move.b	#1,(v_wassfxspindash).w	; set flag
		move.b	#60,(v_timersfxspindash).w	; set timer
		move.w	(sp)+,d0
 
@cont3:
		movea.l	(Go_SoundIndex).l,a0
		sub.b	#$A1,d7
		bra	SoundEffects_Common


Sound_A0toCF:				; XREF: Sound_ChkValue
		tst.b	$27(a6)
		bne.w	loc_722C6
		tst.b	4(a6)
		bne.w	loc_722C6
		tst.b	$24(a6)
		bne.w	loc_722C6
		clr.b   (v_wassfxspindash).w   ; +++ clear spin dash as last sfx flag
		cmpi.b	#$B5,d7		; is ring sound	effect played?
		bne.s	Sound_notB5	; if not, branch
		tst.b	$2B(a6)
		bne.s	loc_721EE
		move.b	#$CE,d7		; play ring sound in left speaker

loc_721EE:
		bchg	#0,$2B(a6)	; change speaker

Sound_notB5:
		cmpi.b	#$A7,d7		; is "pushing" sound played?
		bne.s	Sound_notA7	; if not, branch
		tst.b	$2C(a6)
		bne.w	locret_722C4
		move.b	#$80,$2C(a6)

Sound_notA7:
		movea.l	(Go_SoundIndex).l,a0
		subi.b	#$A0,d7
SoundEffects_Common:                                  ; +++ added label to avoid duplicating code in the added sound slot code
		lsl.w	#2,d7
		movea.l	(a0,d7.w),a3
		movea.l	a3,a1
		moveq	#0,d1
		move.w	(a1)+,d1
		add.l	a3,d1
		move.b	(a1)+,d5
		move.b	(a1)+,d7
		subq.b	#1,d7
		moveq	#$30,d6

loc_72228:
		moveq	#0,d3
		move.b	1(a1),d3
		move.b	d3,d4
		bmi.s	loc_72244
		subq.w	#2,d3
		lsl.w	#2,d3
		lea	ChannelRAM(pc),a5
		movea.l	(a5,d3.w),a5
		bset	#bitSFXOverride,(a5)
		bra.s	loc_7226E
; ===========================================================================

loc_72244:
		lsr.w	#3,d3
		lea	ChannelRAM(pc),a5
		movea.l	(a5,d3.w),a5
		bset	#bitSFXOverride,(a5)
		cmpi.b	#$C0,d4
		bne.s	loc_7226E
		move.b	d4,d0
		ori.b	#$1F,d0
		move.b	d0,($C00011).l
		bchg	#5,d0
		move.b	d0,($C00011).l

loc_7226E:
	;	movea.l	dword_722EC(pc,d3.w),a5
	        lea	dword_722EC(pc),a5        ; +++   something to do with spin dash revving
		movea.l	(a5,d3.w),a5              ; +++
		movea.l	a5,a2
		moveq	#$B,d0

loc_72276:
		clr.l	(a2)+
		dbf	d0,loc_72276

		move.w	(a1)+,(a5)
		move.b	d5,sTimingDivisor(a5)
		moveq	#0,d0
		move.w	(a1)+,d0
		add.l	a3,d0
		move.l	d0,sTrackPos(a5)
	;	move.w	(a1)+,sTranspose(a5)
	;	move.b	#1,sCurrentNotefill(a5)
	        move.w	(a1)+,sTranspose(a5)     ; +++
		tst.b	(v_wassfxspindash).w	; is the Spin Dash sound playing?
		beq.s	@cont		; if not, branch
		move.w	d0,-(sp)        ;
		move.b	(v_pitchsfxspindash).w,d0;
		add.b	d0,sTranspose(a5)        ;
		move.w	(sp)+,d0         ;
                                         ;
@cont:                                   ;
		move.b	#1,sCurrentNotefill(a5)        ;
		move.b	d6,sReturnLocation(a5)
		tst.b	d4
		bmi.s	loc_722A8
		move.b	#$C0,sPan(a5)
		move.l	d1,$20(a5)       

loc_722A8:
		dbf	d7,loc_72228

		tst.b	$250(a6)
		bpl.s	loc_722B8
		bset	#2,$340(a6)

loc_722B8:
		tst.b	$310(a6)
		bpl.s	locret_722C4
		bset	#2,$370(a6)

locret_722C4:
		rts	
; ===========================================================================

loc_722C6:
		clr.b	0(a6)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; RAM addresses for FM and PSG channel variables
; ---------------------------------------------------------------------------
ChannelRAM:	dc.l $FFF0D0
		dc.l 0
		dc.l $FFF100
		dc.l $FFF130
		dc.l $FFF190
		dc.l $FFF1C0
		dc.l $FFF1F0
		dc.l $FFF1F0
dword_722EC:	dc.l $FFF220
		dc.l 0
		dc.l $FFF250
		dc.l $FFF280
		dc.l $FFF2B0
		dc.l $FFF2E0
		dc.l $FFF310
		dc.l $FFF310
; ===========================================================================
; ---------------------------------------------------------------------------
; Play GHZ waterfall sound
; ---------------------------------------------------------------------------

Sound_D0toDF:				; XREF: Sound_ChkValue
		tst.b	$27(a6)
		bne.w	locret_723C6
		tst.b	4(a6)
		bne.w	locret_723C6
		tst.b	$24(a6)
		bne.w	locret_723C6
		movea.l	(Go_SoundD0).l,a0
		subi.b	#$D0,d7
		lsl.w	#2,d7
		movea.l	(a0,d7.w),a3
		movea.l	a3,a1
		moveq	#0,d0
		move.w	(a1)+,d0
		add.l	a3,d0
		move.l	d0,$20(a6)
		move.b	(a1)+,d5
		move.b	(a1)+,d7
		subq.b	#1,d7
		moveq	#$30,d6

loc_72348:
		move.b	1(a1),d4
		bmi.s	loc_7235A
		bset	#2,$100(a6)
		lea	$340(a6),a5
		bra.s	loc_72364
; ===========================================================================

loc_7235A:
		bset	#2,$1F0(a6)
		lea	$370(a6),a5

loc_72364:
		movea.l	a5,a2
		moveq	#$B,d0

loc_72368:
		clr.l	(a2)+
		dbf	d0,loc_72368

		move.w	(a1)+,(a5)
		move.b	d5,sTimingDivisor(a5)
		moveq	#0,d0
		move.w	(a1)+,d0
		add.l	a3,d0
		move.l	d0,sTrackPos(a5)
		move.w	(a1)+,sTranspose(a5)
		move.b	#1,sCurrentNotefill(a5)
		move.b	d6,sReturnLocation(a5)
		tst.b	d4
		bmi.s	loc_72396
		move.b	#$C0,sPan(a5)

loc_72396:
		dbf	d7,loc_72348

		tst.b	$250(a6)
		bpl.s	loc_723A6
		bset	#2,$340(a6)

loc_723A6:
		tst.b	$310(a6)
		bpl.s	locret_723C6
		bset	#2,$370(a6)
		ori.b	#$1F,d4
		move.b	d4,($C00011).l
		bchg	#5,d4
		move.b	d4,($C00011).l

locret_723C6:
		rts	
; End of function Sound_ChkValue

; ===========================================================================
		dc.l $FFF100
		dc.l $FFF1F0
		dc.l $FFF250
		dc.l $FFF310
		dc.l $FFF340
		dc.l $FFF370

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Snd_FadeOut1:				; XREF: Sound_E0
		clr.b	0(a6)
		lea	$220(a6),a5
		moveq	#5,d7

loc_723EA:
		tst.b	(a5)
		bpl.w	loc_72472
		bclr	#bitIsPlaying,(a5)
		moveq	#0,d3
		move.b	sVoiceControl(a5),d3    ; is track PSG?
		bmi.s	loc_7243C               ; if so, branch
		jsr	FMNoteOff(pc)
		cmpi.b	#4,d3
		bne.s	loc_72416
		tst.b	$340(a6)
		bpl.s	loc_72416
		lea	$340(a6),a5
		movea.l	$20(a6),a1
		bra.s	loc_72428
; ===========================================================================

loc_72416:
		subq.b	#2,d3
		lsl.b	#2,d3
		lea	ChannelRAM(pc),a0
		movea.l	a5,a3
		movea.l	(a0,d3.w),a5
		movea.l	$18(a6),a1

loc_72428:
		bclr	#bitSFXOverride,(a5)
		bset	#bitAtRest,(a5)
		move.b	sCurrentVoice(a5),d0
		jsr	sub_72C4E(pc)
		movea.l	a3,a5
		bra.s	loc_72472
; ===========================================================================

loc_7243C:
		jsr	PSGNoteOff(pc)
		lea	$370(a6),a0
		cmpi.b	#$E0,d3
		beq.s	loc_7245A
		cmpi.b	#$C0,d3
		beq.s	loc_7245A
		lsr.b	#3,d3
		lea	ChannelRAM(pc),a0
		movea.l	(a0,d3.w),a0

loc_7245A:
		bclr	#bitSFXOverride,(a0)
		bset	#bitAtRest,(a0)
		cmpi.b	#$E0,sVoiceControl(a0)
		bne.s	loc_72472
		move.b	$1F(a0),($C00011).l

loc_72472:
		adda.w	#$30,a5
		dbf	d7,loc_723EA

		rts	
; End of function Snd_FadeOut1


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Snd_FadeOut2:				; XREF: Sound_E0
		lea	$340(a6),a5
		tst.b	(a5)
		bpl.s	loc_724AE
		bclr	#bitIsPlaying,(a5)
		btst	#bitSFXOverride,(a5)
		bne.s	loc_724AE
		jsr	loc_7270A(pc)
		lea	$100(a6),a5
		bclr	#bitSFXOverride,(a5)
		bset	#bitAtRest,(a5)
		tst.b	(a5)
		bpl.s	loc_724AE
		movea.l	$18(a6),a1
		move.b	sCurrentVoice(a5),d0
		jsr	sub_72C4E(pc)

loc_724AE:
		lea	$370(a6),a5
		tst.b	(a5)
		bpl.s	locret_724E4
		bclr	#bitIsPlaying,(a5)
		btst	#bitSFXOverride,(a5)
		bne.s	locret_724E4
		jsr	loc_729A6(pc)
		lea	$1F0(a6),a5
		bclr	#bitSFXOverride,(a5)
		bset	#bitAtRest,(a5)
		tst.b	(a5)
		bpl.s	locret_724E4
		cmpi.b	#-$20,sVoiceControl(a5)
		bne.s	locret_724E4
		move.b	sPSGNoise(a5),($C00011).l

locret_724E4:
		rts	
; End of function Snd_FadeOut2

; ===========================================================================
; ---------------------------------------------------------------------------
; Fade out music
; ---------------------------------------------------------------------------

Sound_E0:				; XREF: Sound_ExIndex
		jsr	Snd_FadeOut1(pc)
		jsr	Snd_FadeOut2(pc)
		move.b	#3,6(a6)
		move.b	#$28,4(a6)
		clr.b	$40(a6)
		clr.b	$2A(a6)
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_72504:				; XREF: UpdateMusic
		move.b	6(a6),d0
		beq.s	loc_72510
		subq.b	#1,6(a6)
		rts	
; ===========================================================================

loc_72510:
		subq.b	#1,4(a6)
		beq.w	Sound_E4
		move.b	#3,6(a6)
		lea	$70(a6),a5
		moveq	#5,d7

loc_72524:
		tst.b	(a5)
		bpl.s	loc_72538
		addq.b	#1,sChannelVolume(a5)
		bpl.s	loc_72534
		bclr	#bitIsPlaying,(a5)
		bra.s	loc_72538
; ===========================================================================

loc_72534:
		jsr	SendVoiceTL(pc)

loc_72538:
		adda.w	#$30,a5
		dbf	d7,loc_72524

		moveq	#2,d7

loc_72542:
		tst.b	(a5)
		bpl.s	loc_72560
		addq.b	#1,sChannelVolume(a5)
		cmpi.b	#$10,sChannelVolume(a5)
		bcs.s	loc_72558
		bclr	#bitIsPlaying,(a5)
		bra.s	loc_72560
; ===========================================================================

loc_72558:
		move.b	sChannelVolume(a5),d6
		jsr	SetPSGVolume(pc)

loc_72560:
		adda.w	#$30,a5
		dbf	d7,loc_72542

		rts	
; End of function sub_72504


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_7256A:				; XREF: Sound_E4; InitMusicPlayback
		moveq	#2,d3
		moveq	#$28,d0

loc_7256E:
		move.b	d3,d1
		jsr	YM2612_Save01(pc)
		addq.b	#4,d1
		jsr	YM2612_Save01(pc)
		dbf	d3,loc_7256E

		moveq	#$40,d0
		moveq	#$7F,d1
		moveq	#2,d4

loc_72584:
		moveq	#3,d3

loc_72586:
		jsr	YM2612_Save01(pc)
		jsr	YM2612_Save02(pc)
		addq.w	#4,d0
		dbf	d3,loc_72586

		subi.b	#$F,d0
		dbf	d4,loc_72584

		rts	
; End of function sub_7256A

; ===========================================================================
; ---------------------------------------------------------------------------
; Stop music
; ---------------------------------------------------------------------------

Sound_E4:				; XREF: Sound_ChkValue; Sound_ExIndex; sub_72504
		moveq	#$2B,d0
		move.b	#$80,d1
		jsr	YM2612_Save01(pc)
		moveq	#$27,d0
		moveq	#0,d1
		jsr	YM2612_Save01(pc)
		movea.l	a6,a0
		move.w	#$E3,d0

loc_725B6:
		clr.l	(a0)+
		dbf	d0,loc_725B6

		move.b	#$80,9(a6)	; set music to $80 (silence)
		jsr	sub_7256A(pc)
		bra.w	sub_729B6

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


InitMusicPlayback:				; XREF: Sound_ChkValue
		movea.l	a6,a0
		move.b	0(a6),d1
		move.b	$27(a6),d2
		move.b	$2A(a6),d3
		move.b	$26(a6),d4
		move.w	$A(a6),d5
		move.w	#$87,d0

loc_725E4:
		clr.l	(a0)+
		dbf	d0,loc_725E4

		move.b	d1,0(a6)
		move.b	d2,$27(a6)
		move.b	d3,$2A(a6)
		move.b	d4,$26(a6)
		move.w	d5,$A(a6)
		move.b	#$80,9(a6)
		jsr	sub_7256A(pc)
		bra.w	sub_729B6
; End of function InitMusicPlayback


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


TempoWait:				; XREF: UpdateMusic
               cmpi.b  #$20,2(a6)                ; is tempo below $20 (i.e. a Sonic 1 tempo)
               bcs.s   TempoS1                   ; if so, branch

      ; Sonic 2 style tempo
TempoS2:
                moveq   #0,d2
		move.b	2(a6),d2
		add.b   1(a6),d2
		bcs.s   @end
		lea	$4E(a6),a0                ; first track (dac) note timer
		moveq	#$30,d0                   ; track size
		moveq	#9,d1                     ; number of tracks

@tempoloop:
		addq.b	#1,(a0)                   ; delay note by 1 frame
		adda.w	d0,a0                     ; advance to next track
		dbf	d1,@tempoloop
@end:
		move.b  d2,1(a6)
		rts

       ; Sonic 1 Style Tempo
TempoS1:
		subq.b	#1,1(a6)                  ; is timer 0?
		bne.s	@end                      ; if not 0, branch
		move.b	2(a6),1(a6)               ; reset main tempo
		lea	$4E(a6),a0                ; first track (dac) note timer
		moveq	#$30,d0                   ; track size
		moveq	#9,d1                     ; number of tracks

@tempoloop:
		addq.b	#1,(a0)                   ; delay note by 1 frame
		adda.w	d0,a0                     ; advance to next track
		dbf	d1,@tempoloop
@end:
		rts


; End of function TempoWait

; ===========================================================================
; ---------------------------------------------------------------------------
; Speed	up music
; ---------------------------------------------------------------------------

Sound_E2:				; XREF: Sound_ExIndex
		tst.b	$27(a6)
		bne.s	loc_7263E
		move.b	$29(a6),2(a6)
		move.b	$29(a6),1(a6)
		move.b	#$80,$2A(a6)
		rts	

loc_7263E:
		move.b	$3C9(a6),$3A2(a6)
		move.b	$3C9(a6),$3A1(a6)
		move.b	#$80,$3CA(a6)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Change music back to normal speed
; ---------------------------------------------------------------------------

Sound_E3:				; XREF: Sound_ExIndex
		tst.b	$27(a6)
		bne.s	loc_7266A
		move.b	$28(a6),2(a6)    ; move v_tempo_mod
		move.b	$28(a6),1(a6)    ; move v_tempo_mod
		clr.b	$2A(a6)
		rts	

loc_7266A:
		move.b	$3C8(a6),$3A2(a6)
		move.b	$3C8(a6),$3A1(a6)
		clr.b	$3CA(a6)
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_7267C:				; XREF: UpdateMusic
		tst.b	$25(a6)
		beq.s	loc_72688
		subq.b	#1,$25(a6)
		rts	
; ===========================================================================

loc_72688:
		tst.b	$26(a6)
		beq.s	loc_726D6
		subq.b	#1,$26(a6)
		move.b	#2,$25(a6)
		lea	$70(a6),a5
		moveq	#5,d7

loc_7269E:
		tst.b	(a5)
		bpl.s	loc_726AA
		subq.b	#1,sChannelVolume(a5)
		jsr	SendVoiceTL(pc)

loc_726AA:
		adda.w	#$30,a5
		dbf	d7,loc_7269E
		moveq	#2,d7

loc_726B4:
		tst.b	(a5)
		bpl.s	loc_726CC
		subq.b	#1,sChannelVolume(a5)
		move.b	sChannelVolume(a5),d6
		cmpi.b	#$10,d6
		bcs.s	loc_726C8
		moveq	#$F,d6

loc_726C8:
		jsr	SetPSGVolume(pc)

loc_726CC:
		adda.w	#$30,a5
		dbf	d7,loc_726B4
		rts	
; ===========================================================================

loc_726D6:
		bclr	#2,$40(a6)
		clr.b	$24(a6)
		rts	
; End of function sub_7267C

; ===========================================================================

loc_726E2:				; XREF: FMUpdateTrack
		btst	#bitAtRest,(a5)
		bne.s	locret_726FC
		btst	#bitSFXOverride,(a5)
		bne.s	locret_726FC
		moveq	#$28,d0
		move.b	sVoiceControl(a5),d1
		ori.b	#-$10,d1
		bra.w	YM2612_Save01
; ===========================================================================

locret_726FC:
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FMNoteOff:				; XREF: sub_71CEC; NoteFillUpdate; Sound_ChkValue; Snd_FadeOut1
		btst	#bitNoAttack,(a5)
		bne.s	locret_72714
		btst	#bitSFXOverride,(a5)
		bne.s	locret_72714

loc_7270A:				; XREF: Snd_FadeOut2
		moveq	#$28,d0
		move.b	sVoiceControl(a5),d1
		bra.w	YM2612_Save01
; ===========================================================================

locret_72714:
		rts	
; End of function FMNoteOff

; ===========================================================================

loc_72716:				; XREF: FlagRoutine
		btst	#bitSFXOverride,(a5)
		bne.s	locret_72720
		bra.w	sub_72722
; ===========================================================================

locret_72720:
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_72722:				; XREF: sub_71E18; sub_72C4E; SendVoiceTL
		btst	#bitFM1,sVoiceControl(a5)
		bne.s	loc_7275A
		add.b	sVoiceControl(a5),d0
; End of function sub_72722


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


YM2612_Save01:				; XREF: loc_71E6A
; 		move.b	($A04000).l,d2
; 		btst	#7,d2
; 		bne.s	YM2612_Save01
; 		move.b	d0,($A04000).l
; 		nop	
; 		nop	
; 		nop	
; 
; loc_72746:
; 		move.b	($A04000).l,d2
; 		btst	#7,d2
; 		bne.s	loc_72746
; 
; 		move.b	d1,($A04001).l
; 		rts
        stopZ80
        waitz80
        waitYM
        move.b    d0,($A04000).l
        waitYM
        move.b    d1,($A04001).l
        waitYM
        move.b    #$2A,($A04000).l
        startZ80
        rts
; End of function YM2612_Save01

; ===========================================================================

loc_7275A:				; XREF: sub_72722
		move.b	sVoiceControl(a5),d2
		bclr	#bitFM1,d2
		add.b	d2,d0

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


YM2612_Save02:				; XREF: loc_71E6A; Sound_ChkValue; sub_7256A; YM2612_Save02
; 		move.b	($A04000).l,d2
; 		btst	#7,d2
; 		bne.s	YM2612_Save02
; 		move.b	d0,($A04002).l
; 		nop	
; 		nop	
; 		nop	
; 
; loc_7277C:
; 		move.b	($A04000).l,d2
; 		btst	#7,d2
; 		bne.s	loc_7277C
; 
; 		move.b	d1,($A04003).l
;		rts
        stopZ80
        waitz80
        waitYM
        move.b    d0,($A04002).l
        waitYM
        move.b    d1,($A04003).l
        waitYM
        move.b    #$2A,($A04000).l
        startZ80
        rts
; End of function YM2612_Save02

; ===========================================================================
FMPitchTable:	dc.w $25E, $284, $2AB, $2D3, $2FE, $32D, $35C, $38F, $3C5
		dc.w $3FF, $43C, $47C, $A5E, $A84, $AAB, $AD3, $AFE, $B2D
		dc.w $B5C, $B8F, $BC5, $BFF, $C3C, $C7C, $125E,	$1284
		dc.w $12AB, $12D3, $12FE, $132D, $135C,	$138F, $13C5, $13FF
		dc.w $143C, $147C, $1A5E, $1A84, $1AAB,	$1AD3, $1AFE, $1B2D
		dc.w $1B5C, $1B8F, $1BC5, $1BFF, $1C3C,	$1C7C, $225E, $2284
		dc.w $22AB, $22D3, $22FE, $232D, $235C,	$238F, $23C5, $23FF
		dc.w $243C, $247C, $2A5E, $2A84, $2AAB,	$2AD3, $2AFE, $2B2D
		dc.w $2B5C, $2B8F, $2BC5, $2BFF, $2C3C,	$2C7C, $325E, $3284
		dc.w $32AB, $32D3, $32FE, $332D, $335C,	$338F, $33C5, $33FF
		dc.w $343C, $347C, $3A5E, $3A84, $3AAB,	$3AD3, $3AFE, $3B2D
		dc.w $3B5C, $3B8F, $3BC5, $3BFF, $3C3C,	$3C7C

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGUpdateTrack:				; XREF: UpdateMusic
		subq.b	#1,sCurrentNotefill(a5)               ; sub 1 from timer
		bne.s	loc_72866               ; if timer not 0, branch
		bclr	#bitNoAttack,(a5)
		jsr	sub_72878(pc)           ; get note to play
		jsr	sub_728DC(pc)
		bra.w	loc_7292E
; ===========================================================================

loc_72866:
		jsr	NoteFillUpdate(pc)
		jsr	sub_72926(pc)
		jsr	DoModulation(pc)
		jsr	sub_728E2(pc)
		rts
; End of function PSGUpdateTrack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_72878:				; XREF: PSGUpdateTrack
		bclr	#bitAtRest,(a5)
		movea.l	sTrackPos(a5),a4

@PSGCheckFlag:
		moveq	#0,d5
		move.b	(a4)+,d5
		cmpi.b	#$E0,d5
		bcs.s	loc_72890
		jsr	FlagRoutine(pc)
		bra.s	@PSGCheckFlag
; ===========================================================================

loc_72890:
		tst.b	d5
		bpl.s	loc_728A4
		jsr	sub_728AC(pc)
		move.b	(a4)+,d5
		tst.b	d5
		bpl.s	loc_728A4
		subq.w	#1,a4
		bra.w	FinishTrackUpdate
; ===========================================================================

loc_728A4:
		jsr	TimerRoutine(pc)
		bra.w	FinishTrackUpdate
; End of function sub_72878


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_728AC:				; XREF: sub_72878
		subi.b	#$81,d5                 ; sub $81 to get note
		bcs.s	loc_728CA               ; branch if a rest
		add.b	sTranspose(a5),d5       ; add channel pitch
		add.b   (v_musicpitch).w,d5
		andi.w	#$7F,d5
		lsl.w	#1,d5
		lea	PSGPitchTable(pc),a0
		move.w	(a0,d5.w),sFrequency(a5)
		bra.w	FinishTrackUpdate
; ===========================================================================

loc_728CA:
		bset	#bitAtRest,(a5)
		move.w	#-1,sFrequency(a5)
		jsr	FinishTrackUpdate(pc)
		bra.w	PSGNoteOff
; End of function sub_728AC


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_728DC:				; XREF: PSGUpdateTrack
		move.w	sFrequency(a5),d6
		bmi.s	loc_72920
; End of function sub_728DC


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_728E2:				; XREF: PSGUpdateTrack
		move.b	sFreqAdjust(a5),d0
		ext.w	d0
		add.w	d0,d6
		btst	#bitSFXOverride,(a5)
		bne.s	locret_7291E
		btst	#bitAtRest,(a5)
		bne.s	locret_7291E
		move.b	sVoiceControl(a5),d0
		cmpi.b	#$E0,d0
		bne.s	loc_72904
		move.b	#$C0,d0

loc_72904:
		move.w	d6,d1
		andi.b	#$F,d1
		or.b	d1,d0
		lsr.w	#4,d6
		andi.b	#$3F,d6
		move.b	d0,($C00011).l
		move.b	d6,($C00011).l

locret_7291E:
		rts	
; End of function sub_728E2

; ===========================================================================

loc_72920:				; XREF: sub_728DC
		bset	#bitAtRest,(a5)
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_72926:				; XREF: PSGUpdateTrack
		tst.b	sCurrentVoice(a5)
		beq.w	locret_7298A

loc_7292E:				; XREF: PSGUpdateTrack
		move.b	sChannelVolume(a5),d6
		moveq	#0,d0
		move.b	sCurrentVoice(a5),d0
		beq.s	SetPSGVolume
		movea.l	(Go_PSGIndex).l,a0
		subq.w	#1,d0
		lsl.w	#2,d0
		movea.l	(a0,d0.w),a0
		move.b	sPSGFlutter(a5),d0     ; Get flutter index
		move.b	(a0,d0.w),d0           ; Flutter value
		addq.b	#1,sPSGFlutter(a5)     ; Increment flutter index
		btst	#7,d0                  ; Is flutter value negative?
		beq.s	loc_72960              ; Branch if not
		cmpi.b	#$83,d0		;
		beq.s	FlutterFullRest	; Note off
		cmpi.b	#$81,d0		;
		beq.s	FlutterDone	; Hold last value
		cmpi.b	#$80,d0
		beq.s	FlutterRestart     ; restart flutter

loc_72960:
		add.w	d0,d6           ; Add flutter to volume
		cmpi.b	#$10,d6         ; Is volume $10 or higher?
		bcs.s	SetPSGVolume    ; Branch if not
		moveq	#$F,d6          ; Limit to silence and fall through
; End of function sub_72926


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SetPSGVolume:				; XREF: sub_72504; sub_7267C; sub_72926
		btst	#bitAtRest,(a5)
		bne.s	locret_7298A
		btst	#bitSFXOverride,(a5)
		bne.s	locret_7298A
		btst	#bitNoAttack,(a5)
		bne.s	loc_7298C

loc_7297C:
		or.b	sVoiceControl(a5),d6
		addi.b	#$10,d6
		move.b	d6,($C00011).l

locret_7298A:
		rts	
; ===========================================================================

loc_7298C:
		tst.b	sLastDuration(a5)
		beq.s	loc_7297C
		tst.b	sCurrentDuration(a5)
		bne.s	loc_7297C
		rts	
; End of function SetPSGVolume

; ===========================================================================

FlutterFullRest:
		bset	#1,(a5)		; Set "track is resting" bit
                bra.s   PSGNoteOff      ; Note off
; ===========================================================================

FlutterDone:				; XREF: sub_72926
;		bset	#1,(a5)		; Set "track is resting" bit
		subq.b	#1,sPSGFlutter(a5)
		rts	
; ===========================================================================

FlutterRestart:				; XREF: sub_72926
		move.b	#0,sPSGFlutter(a5)
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGNoteOff:				; XREF: NoteFillUpdate; Sound_ChkValue; Snd_FadeOut1; sub_728AC
		btst	#bitSFXOverride,(a5)
		bne.s	locret_729B4

loc_729A6:				; XREF: Snd_FadeOut2
		move.b	sVoiceControl(a5),d0
		ori.b	#$1F,d0
		move.b	d0,($C00011).l

locret_729B4:
		rts	
; End of function PSGNoteOff


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_729B6:				; XREF: loc_71E7C
		lea	($C00011).l,a0
		move.b	#$9F,(a0)
		move.b	#$BF,(a0)
		move.b	#$DF,(a0)
		move.b	#$FF,(a0)
		rts	
; End of function sub_729B6

; ===========================================================================
PSGPitchTable:	dc.w $356, $326, $2F9, $2CE, $2A5, $280, $25C, $23A, $21A
		dc.w $1FB, $1DF, $1C4, $1AB, $193, $17D, $167, $153, $140
		dc.w $12E, $11D, $10D, $FE, $EF, $E2, $D6, $C9,	$BE, $B4
		dc.w $A9, $A0, $97, $8F, $87, $7F, $78,	$71, $6B, $65
		dc.w $5F, $5A, $55, $50, $4B, $47, $43,	$40, $3C, $39
		dc.w $36, $33, $30, $2D, $2B, $28, $26,	$24, $22, $20
		dc.w $1F, $1D, $1B, $1A, $18, $17, $16,	$15, $13, $12
		dc.w $11, 0

	        include "_inc\SMPS 68k Coordination Flags.asm"

; Kos_Z80:	incbin	sound\z80_1.bin                               ; Default driver
; 		dc.w ((SegaPCM&$FF)<<8)+((SegaPCM&$FF00)>>8)
; 		dc.b $21
; 		dc.w (((EndOfRom-SegaPCM)&$FF)<<8)+(((EndOfRom-SegaPCM)&$FF00)>>8)
; 		incbin	sound\z80_2.bin
; 		even


Kos_Z80:        incbin    "sound/z80.bin"                            ; S1HL Driver
                even
; ===========================================================================

	        include "sound\_s1smps2asm_inc.asm"
; ---------------------------------------------------------------------------
; Music Pointers
; ---------------------------------------------------------------------------
MusicIndex:
ptr_mus81:	dc.l Music81
ptr_mus82:	dc.l Music82
ptr_mus83:	dc.l Music83
ptr_mus84:	dc.l Music84
ptr_mus85:	dc.l Music85
ptr_mus86:	dc.l Music86
ptr_mus87:	dc.l Music87
ptr_mus88:	dc.l Music88
ptr_mus89:	dc.l Music89
ptr_mus8A:	dc.l Music8A
ptr_mus8B:	dc.l Music8B
ptr_mus8C:	dc.l Music8C
ptr_mus8D:	dc.l Music8D
ptr_mus8E:	dc.l Music8E
ptr_mus8F:	dc.l Music8F
ptr_mus90:	dc.l Music90
ptr_mus91:	dc.l Music91
ptr_mus92:	dc.l Music92
ptr_mus93:	dc.l Music93
ptr_mus94:	dc.l Music94
ptr_mus95:	dc.l Music95
ptr_mus96:	dc.l Music96
ptr_mus97:	dc.l Music97
ptr_mus98:	dc.l Music98
ptr_mus99:	dc.l Music99
ptr_mus9A:	dc.l Music9A
ptr_mus9B:	dc.l Music9B
ptr_mus9C:	dc.l Music9C
ptr_mus9D:	dc.l Music9D
ptr_mus9E:	dc.l Music9E
ptr_mus9F:	dc.l Music9F
; ===========================================================================
Music81:        include "sound\Mus81 - Splash Hill.asm"
                even
Music82:        include "sound\Mus82 - Skull Land.asm"
                even
Music83:	include	"sound\Mus83 - MZ.asm"
		even
Music84:	include	"sound\Mus84 - SLZ.asm"
		even
Music85:	include	"sound\Mus85 - SYZ.asm"
		even
Music86:	incbin	"sound\Mus86 - SBZ.bin"
		even
Music87:	include	"sound\Mus87 - Invincibility.asm"
		even
Music88:	include	"sound\Mus88 - Extra Life.asm"
		even
Music89:	include	"sound\Mus89 - Special Stage.asm"
		even
Music8A:	incbin	"sound\Mus8A - Title Screen.bin"
		even
Music8B:	include	"sound\Mus8B - Ending.asm"
		even
Music8C:	include	"sound\Mus8C - Boss.asm"
		even
Music8D:	include	"sound\Mus8D - FZ.asm"
		even
Music8E:	incbin	"sound\Mus8E - Sonic Got Through.bin"
		even
Music8F:	include	"sound\Mus8F - Game Over.asm"
		even
Music90:	include	"sound\Mus90 - Continue Screen.asm"
		even
Music91:	include	"sound\Mus91 - Credits.asm"
		even
Music92:	include	"sound\Mus92 - Drowning.asm"
		even
Music93:	include	"sound\Mus93 - Get Emerald.asm"
		even
Music94:	include	"sound\Mus94 - GHZ.asm"
		even
Music95:	include	"sound\Mus95 - Emerald Hill.asm"
		even
Music96:	include	"sound\Mus96 - Ending.asm"
		even
Music97:	include	"sound\Mus97 - Game Complete.asm"
		even
Music98:	include	"sound\Mus98 - S3D Boss.asm"
		even
Music99:	include	"sound\Mus99 - S3D Boss2.asm"
		even
Music9A:	include	"sound\Mus9A - Chrome Gadget.asm"
		even
Music9B:	include	"sound\Mus9B - SSZ.asm"
		even
Music9C:	include	"sound\Mus9C - S3D Credits.asm"
		even
Music9D:	include	"sound\Mus9D - AIZ2.asm"
		even
Music9E:	include	"sound\Mus9E - FBZ1.asm"
		even
Music9F:	include	"sound\Mus9F - FBZ2.asm"
		even

MusicE6:	include	"sound\MusE6 - Continue.asm"
 		even

; ===========================================================================
; PSG Universial Voice Bank
; ===========================================================================

UniVoiceBank:
	; Synth Bass 2
		dc.b  $3C,   1,   0,   0,   0, $1F, $1F, $15, $1F, $11, $0D, $12,   5
		dc.b         7,   4,   9,   2, $55, $3A, $25, $1A, $1A, $80,   7, $80				; 0
	; Trumpet 1
	    dc.b  $3D,   1,   1,   1,   1, $94, $19, $19, $19, $0F, $0D, $0D, $0D
		dc.b         7,   4,   4,   4, $25, $1A, $1A, $1A, $15, $80, $80, $80				; 25
	; Slap Bass 2
	    dc.b    3,   0, $D7, $33,   2, $5F, $9F, $5F, $1F, $13, $0F, $0A, $0A
		dc.b       $10, $0F,   2,   9, $35, $15, $25, $1A, $13, $16, $15, $80				; 50
	; Synth Bass 1
	    dc.b  $34, $70, $72, $31, $31, $1F, $1F, $1F, $1F, $10,   6,   6,   6
		dc.b         1,   6,   6,   6, $35, $1A, $15, $1A, $10, $83, $18, $83				; 75
	; Bell Synth 1
	    dc.b  $3E, $77, $71, $32, $31, $1F, $1F, $1F, $1F, $0D,   6,   0,   0
		dc.b         8,   6,   0,   0, $15, $0A, $0A, $0A, $1B, $80, $80, $80				; 100
	; Bell Synth 2
	    dc.b  $34, $33, $41, $7E, $74, $5B, $9F, $5F, $1F,   4,   7,   7,   8
		dc.b         0,   0,   0,   0, $FF, $FF, $EF, $FF, $23, $80, $29, $87				; 125
	; Synth Brass 1
	    dc.b  $3A,   1,   7, $31, $71, $8E, $8E, $8D, $53, $0E, $0E, $0E,   3
		dc.b         0,   0,   0,   7, $1F, $FF, $1F, $0F, $18, $28, $27, $80				; 150
	; Synth like Bassoon
	    dc.b  $3C, $32, $32, $71, $42, $1F, $18, $1F, $1E,   7, $1F,   7, $1F
		dc.b         0,   0,   0,   0, $1F, $0F, $1F, $0F, $1E, $80, $0C, $80				; 175
	; Bell Horn type thing
	    dc.b  $3C, $71, $72, $3F, $34, $8D, $52, $9F, $1F,   9,   0,   0, $0D
		dc.b         0,   0,   0,   0, $23,   8,   2, $F7, $15, $80, $1D, $87				; 200
	; Synth Bass 3
	    dc.b  $3D,   1,   1,   0,   0, $8E, $52, $14, $4C,   8,   8, $0E,   3
		dc.b         0,   0,   0,   0, $1F, $1F, $1F, $1F, $1B, $80, $80, $9B				; 225
	; Synth Trumpet
	    dc.b  $3A,   1,   1,   1,   2, $8D,   7,   7, $52,   9,   0,   0,   3
		dc.b         1,   2,   2,   0, $52,   2,   2, $28, $18, $22, $18, $80				; 250
	; Wood Block
	    dc.b  $3C, $36, $31, $76, $71, $94, $9F, $96, $9F, $12,   0, $14, $0F
		dc.b         4, $0A,   4, $0D, $2F, $0F, $4F, $2F, $33, $80, $1A, $80				; 275
	; Tubular Bell
	    dc.b  $34, $33, $41, $7E, $74, $5B, $9F, $5F, $1F,   4,   7,   7,   8
		dc.b         0,   0,   0,   0, $FF, $FF, $EF, $FF, $23, $90, $29, $97				; 300
	; Strike Bass
	    dc.b  $38, $63, $31, $31, $31, $10, $13, $1A, $1B, $0E,   0,   0,   0
		dc.b         0,   0,   0,   0, $3F, $0F, $0F, $0F, $1A, $19, $1A, $80				; 325
	; Elec Piano
	    dc.b  $3A, $31, $25, $73, $41, $5F, $1F, $1F, $9C,   8,   5,   4,   5
		dc.b         3,   4,   2,   2, $2F, $2F, $1F, $2F, $29, $27, $1F, $80				; 350
	; Bright Piano
	    dc.b    4, $71, $41, $31, $31, $12, $12, $12, $12,   0,   0,   0,   0
		dc.b         0,   0,   0,   0, $0F, $0F, $0F, $0F, $23, $80, $23, $80				; 375
	; Church Bell
	    dc.b  $14, $75, $72, $35, $32, $9F, $9F, $9F, $9F,   5,   5,   0, $0A
		dc.b         5,   5,   7,   5, $2F, $FF, $0F, $2F, $1E, $80, $14, $80				; 400
	; Synth Brass 2
	    dc.b  $3D,   1,   0,   1,   2, $12, $1F, $1F, $14,   7,   2,   2, $0A
		dc.b         5,   5,   5,   5, $2F, $2F, $2F, $AF, $1C, $80, $82, $80				; 425
	; Bell Piano
	    dc.b  $1C, $73, $72, $33, $32, $94, $99, $94, $99,   8, $0A,   8, $0A
		dc.b         0,   5,   0,   5, $3F, $4F, $3F, $4F, $1E, $80, $19, $80				; 450
	; Wet Wood Bass
	    dc.b  $31, $33,   1,   0,   0, $9F, $1F, $1F, $1F, $0D, $0A, $0A, $0A
		dc.b       $0A,   7,   7,   7, $FF, $AF, $AF, $AF, $1E, $1E, $1E, $80				; 475
	; Silent Bass
	    dc.b  $3A, $70, $76, $30, $71, $1F, $95, $1F, $1F, $0E, $0F,   5, $0C
		dc.b         7,   6,   6,   7, $2F, $4F, $1F, $5F, $21, $12, $28, $80				; 500
	; Picked Bass
	    dc.b  $28, $71,   0, $30,   1, $1F, $1F, $1D, $1F, $13, $13,   6,   5
		dc.b         3,   3,   2,   5, $4F, $4F, $2F, $3F, $0E, $14, $1E, $80				; 525
	; Xylophone
	    dc.b  $3E, $38,   1, $7A, $34, $59, $D9, $5F, $9C, $0F,   4, $0F, $0A
		dc.b         2,   2,   5,   5, $AF, $AF, $66, $66, $28, $80, $A3, $80				; 550
	; Sine Flute
	    dc.b  $39, $32, $31, $72, $71, $1F, $1F, $1F, $1F,   0,   0,   0,   0
		dc.b         0,   0,   0,   0, $0F, $0F, $0F, $0F, $1B, $32, $28, $80				; 575
	; Pipe Organ
	    dc.b    7, $34, $74, $32, $71, $1F, $1F, $1F, $1F, $0A, $0A,   5,   3
		dc.b         0,   0,   0,   0, $3F, $3F, $2F, $2F, $8A, $8A, $80, $80				; 600
	; Synth Brass 2
	    dc.b  $3A, $31, $37, $31, $31, $8D, $8D, $8E, $53, $0E, $0E, $0E,   3
		dc.b         0,   0,   0,   0, $1F, $FF, $1F, $0F, $17, $28, $26, $80				; 625
	; Harpischord
	    dc.b  $3B, $3A, $31, $71, $74, $DF, $1F, $1F, $DF,   0, $0A, $0A,   5
		dc.b         0,   5,   5,   3, $0F, $5F, $1F, $5F, $32, $1E, $0F, $80				; 650
	; Metallic Bass
	    dc.b    5,   4,   1,   2,   4, $8D, $1F, $15, $52,   6,   0,   0,   4
		dc.b         2,   8,   0,   0, $1F, $0F, $0F, $2F, $16, $90, $84, $8C				; 675
	; Alternate Metallic Bass
	    dc.b  $2C, $71, $74, $32, $32, $1F, $12, $1F, $12,   0, $0A,   0, $0A
		dc.b         0,   0,   0,   0, $0F, $1F, $0F, $1F, $16, $80, $17, $80				; 700
	; Backdropped Metallic Bass
	    dc.b  $3A,   1,   7,   1,   1, $8E, $8E, $8D, $53, $0E, $0E, $0E,   3
		dc.b         0,   0,   0,   7, $1F, $FF, $1F, $0F, $18, $28, $27, $8F				; 725
	; Sine like Bell
	    dc.b  $36, $7A, $32, $51, $11, $1F, $1F, $59, $1C, $0A, $0D,   6, $0A
		dc.b         7,   0,   2,   2, $AF, $5F, $5F, $5F, $1E, $8B, $81, $80				; 750
	; Synth like Metallic with Small Bell
	    dc.b  $3C, $71, $72, $3F, $34, $8D, $52, $9F, $1F,   9,   0,   0, $0D
		dc.b         0,   0,   0,   0, $23,   8,   2, $F7, $15, $85, $1D, $8A				; 775
	; Nice Synth like lead
	    dc.b  $3E, $77, $71, $32, $31, $1F, $1F, $1F, $1F, $0D,   6,   0,   0
		dc.b         8,   6,   0,   0, $15, $0A, $0A, $0A, $1B, $8F, $8F, $8F				; 800
	; Rock Organ
	    dc.b    7, $34, $74, $32, $71, $1F, $1F, $1F, $1F, $0A, $0A,   5,   3
		dc.b         0,   0,   0,   0, $3F, $3F, $2F, $2F, $8A, $8A, $8A, $8A				; 825
	; Strike like Slap Bass
	    dc.b  $20, $36, $35, $30, $31, $DF, $DF, $9F, $9F,   7,   6,   9,   6
		dc.b         7,   6,   6,   8, $20, $10, $10, $F8, $19, $37, $13, $80				; 850

	even

; ===========================================================================
MusicIndex_E5plus:
ptr_musE5:      dc.l MusicE5
ptr_musE6:      dc.l MusicE6
ptr_musE7:      dc.l MusicE7
ptr_musE8:      dc.l MusicE8
ptr_musE9:      dc.l MusicE9
ptr_musEA:      dc.l MusicEA
ptr_musEB:      dc.l MusicEB
ptr_musEC:      dc.l MusicEC
ptr_musED:      dc.l MusicED
ptr_musEE:      dc.l MusicEE
ptr_musEF:      dc.l MusicEF
ptr_musF0:      dc.l MusicF0
ptr_musF1:      dc.l MusicF1
ptr_musF2:      dc.l MusicF2
ptr_musF3:      dc.l MusicF3
ptr_musF4:      dc.l MusicF4
ptr_musF5:      dc.l MusicF5
ptr_musF6:      dc.l MusicF6
ptr_musF7:      dc.l MusicF7
ptr_musF8:      dc.l MusicF8
ptr_musF9:      dc.l MusicF9
ptr_musFA:      dc.l MusicFA
ptr_musFB:      dc.l MusicFB
ptr_musFC:      dc.l MusicFC
ptr_musFD:      dc.l MusicFD
ptr_musFE:      dc.l MusicFE
ptr_musFF:      dc.l MusicFF
                even
; ===========================================================================
MusicE5:	include	"sound\MusE5 - ARZ.asm"
 		even
MusicE7:	incbin	"sound\MusE7 - Unused.bin"
		even
MusicE8:	incbin	"sound\MusE8 - Unused SYZ remix.bin"
 		even
MusicE9:	incbin	"sound\MusE9 - Unused.bin"
 		even
MusicEA:	incbin	"sound\MusEA - Unused.bin"
 		even
MusicEB:	incbin	"sound\MusEB - Unused.bin"
 		even
MusicEC:	incbin	"sound\MusEC - cheesy too.bin"
 		even
MusicED:	incbin	"sound\MusED - Crystal Egg.bin"
 		even
MusicEE:	include	"sound\MusEE - Nyan.asm"
 		even
MusicEF:	include	"sound\MusEF - Super Sonic.asm"
		even
MusicF0:	include	"sound\MusF0 - Unuseds3k.asm"
 		even
MusicF1:	incbin 	"sound\MusF1 - GHZ.bin"
		even
MusicF2:	incbin 	"sound\MusF2 - GHZ.bin"
		even
MusicF3:	include	"sound\MusF3 - MCZ.asm"
		even
MusicF4:	include	"sound\MusF4 - HPZ.asm"
		even
MusicF5:	include	"sound\MusF5 - OOZ.asm"
		even
MusicF6:	include	"sound\MusF6 - Sparkster.asm"
		even
MusicF7:	include	"sound\Door Into Summer.asm"
 		even
MusicF8:	include	"sound\SEgg.asm"
		even
MusicF9:	include	"sound\beginning.asm"
		even
MusicFA:	include	"sound\aqua lake.asm"
 		even
MusicFB:	include	"sound\SilverSurfer.asm"
 		even
MusicFC:	include	"sound\Pacman.asm"
 		even
MusicFD:	include	"sound\Misty Rain.asm"
		even
MusicFE:	include	"sound\alexkidd.asm"
		even
MusicFF:	include	"sound\battle.asm"
 		even

; ---------------------------------------------------------------------------
; Sound	effect pointers
; ---------------------------------------------------------------------------
SoundIndex:
ptr_sndA0:	dc.l SoundA0
ptr_sndA1:	dc.l SoundA1
ptr_sndA2:	dc.l SoundA2
ptr_sndA3:	dc.l SoundA3
ptr_sndA4:	dc.l SoundA4
ptr_sndA5:	dc.l SoundA5
ptr_sndA6:	dc.l SoundA6
ptr_sndA7:	dc.l SoundA7
ptr_sndA8:	dc.l SoundA8
ptr_sndA9:	dc.l SoundA9
ptr_sndAA:	dc.l SoundAA
ptr_sndAB:	dc.l SoundAB
ptr_sndAC:	dc.l SoundAC
ptr_sndAD:	dc.l SoundAD
ptr_sndAE:	dc.l SoundAE
ptr_sndAF:	dc.l SoundAF
ptr_sndB0:	dc.l SoundB0
ptr_sndB1:	dc.l SoundB1
ptr_sndB2:	dc.l SoundB2
ptr_sndB3:	dc.l SoundB3
ptr_sndB4:	dc.l SoundB4
ptr_sndB5:	dc.l SoundB5
ptr_sndB6:	dc.l SoundB6
ptr_sndB7:	dc.l SoundB7
ptr_sndB8:	dc.l SoundB8
ptr_sndB9:	dc.l SoundB9
ptr_sndBA:	dc.l SoundBA
ptr_sndBB:	dc.l SoundBB
ptr_sndBC:	dc.l SoundBC
ptr_sndBD:	dc.l SoundBD
ptr_sndBE:	dc.l SoundBE
ptr_sndBF:	dc.l SoundBF
ptr_sndC0:	dc.l SoundC0
ptr_sndC1:	dc.l SoundC1
ptr_sndC2:	dc.l SoundC2
ptr_sndC3:	dc.l SoundC3
ptr_sndC4:	dc.l SoundC4
ptr_sndC5:	dc.l SoundC5
ptr_sndC6:	dc.l SoundC6
ptr_sndC7:	dc.l SoundC7
ptr_sndC8:	dc.l SoundC8
ptr_sndC9:	dc.l SoundC9
ptr_sndCA:	dc.l SoundCA
ptr_sndCB:	dc.l SoundCB
ptr_sndCC:	dc.l SoundCC
ptr_sndCD:	dc.l SoundCD
ptr_sndCE:	dc.l SoundCE
ptr_sndCF:	dc.l SoundCF
ptr_sndD0:	dc.l SoundD0
ptr_sndD2:      dc.l SoundD2
ptr_sndD3:      dc.l SoundD3

SoundA0:	incbin	"sound\SndA0 - Jump.bin"
		even
SoundA1:	incbin	"sound\SndA1 - Lamppost.bin"
		even
SoundA2:	incbin	"sound\SndA2.bin"
		even
SoundA3:	incbin	"sound\SndA3 - Death.bin"
		even
SoundA4:	incbin	"sound\SndA4 - Skid.bin"
		even
SoundA5:	incbin	"sound\SndA5.bin"
		even
SoundA6:	incbin	"sound\SndA6 - Hit Spikes.bin"
		even
SoundA7:	incbin	"sound\SndA7 - Push Block.bin"
		even
SoundA8:	incbin	"sound\SndA8 - SS Goal.bin"
		even
SoundA9:	incbin	"sound\SndA9 - SS Item.bin"
		even
SoundAA:	incbin	"sound\SndAA - Splash.bin"
		even
SoundAB:	incbin	"sound\SndAB.bin"
		even
SoundAC:	incbin	"sound\SndAC - Hit Boss.bin"
		even
SoundAD:	incbin	"sound\SndAD - Get Bubble.bin"
		even
SoundAE:	incbin	"sound\SndAE - Fireball.bin"
		even
SoundAF:	incbin	"sound\SndAF - Shield.bin"
		even
SoundB0:	incbin	"sound\SndB0 - Saw.bin"
		even
SoundB1:	incbin	"sound\SndB1 - Electric.bin"
		even
SoundB2:	incbin	"sound\SndB2 - Drown Death.bin"
		even
SoundB3:	incbin	"sound\SndB3 - Flamethrower.bin"
		even
SoundB4:	incbin	"sound\SndB4 - Bumper.bin"
		even
SoundB5:	incbin	"sound\SndB5 - Ring.bin"
		even
SoundB6:	incbin	"sound\SndB6 - Spikes Move.bin"
		even
SoundB7:	incbin	"sound\SndB7 - Rumbling.bin"
		even
SoundB8:	incbin	"sound\SndB8.bin"
		even
SoundB9:	incbin	"sound\SndB9 - Collapse.bin"
		even
SoundBA:	incbin	"sound\SndBA - SS Glass.bin"
		even
SoundBB:	incbin	"sound\SndBB - Door.bin"
		even
SoundBC:	incbin	"sound\SndBC - Teleport.bin"
		even
SoundBD:	incbin	"sound\SndBD - ChainStomp.bin"
		even
SoundBE:	incbin	"sound\SndBE - Roll.bin"
		even
SoundBF:	incbin	"sound\SndBF - Get Continue.bin"
		even
SoundC0:	incbin	"sound\SndC0 - Basaran Flap.bin"
		even
SoundC1:	incbin	"sound\SndC1 - Break Item.bin"
		even
SoundC2:	incbin	"sound\SndC2 - Drown Warning.bin"
		even
SoundC3:	incbin	"sound\SndC3 - Giant Ring.bin"
		even
SoundC4:	incbin	"sound\SndC4 - Bomb.bin"
		even
SoundC5:	incbin	"sound\SndC5 - Cash Register.bin"
		even
SoundC6:	incbin	"sound\SndC6 - Ring Loss.bin"
		even
SoundC7:	incbin	"sound\SndC7 - Chain Rising.bin"
		even
SoundC8:	incbin	"sound\SndC8 - Burning.bin"
		even
SoundC9:	incbin	"sound\SndC9 - Hidden Bonus.bin"
		even
SoundCA:	incbin	"sound\SndCA - Enter SS.bin"
		even
SoundCB:	incbin	"sound\SndCB - Wall Smash.bin"
		even
SoundCC:	incbin	"sound\SndCC - Spring.bin"
		even
SoundCD:	incbin	"sound\SndCD - Switch.bin"
		even
SoundCE:	incbin	"sound\SndCE - Ring Left Speaker.bin"
		even
SoundCF:	incbin	"sound\SndCF - Signpost.bin"
		even
SoundD0:	incbin	"sound\SndD0 - Waterfall.bin"
		even
SoundD2:        incbin  "sound\SndD2 - SpinDash.bin"    ; +++
                even
SoundD3:        include "sound\SndD3 - Water Running.asm"    ; +++
                even


SegaPCM:	incbin	sound\segapcm.bin
		even
		
		
