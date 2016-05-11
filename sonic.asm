;  =========================================================================
; |           Sonic the Hedgehog Disassembly for Sega Mega Drive            |
;  =========================================================================
;
; Disassembly created by Hivebrain
; thanks to drx, Stealth and Esrael L.G. Neto

; ===========================================================================

; --------------------------------------------------------------------------
; Build Options
; --------------------------------------------------------------------------
S3KObjectManager= 1      ; use the Sonic 3 style object manager?
z80SoundDriver  = 1      ; use the z80 sound driver?
PALWait         = 0      ; loop #$700 in vblank?
PALMusicSpeedup = 1      ; run sound driver twice every 5th frame to fix music speed (68k sound driver only)
StartupSoundtest= 1      ; enable cheat, hold a b or c before the sega screen appears to go straight to soundtest
SkipChecksum    = 1      ; skip checksum check at startup
DebugPathSwappers: = 0
VladDebug 		= 0		; 0 for flamewing debugger. 1 for vladikcomper
; --------------------------------------------------------------------------

	include	"Variables.asm"
	include	"Constants.asm"
	include	"Macros.asm"
    if z80SoundDriver=0
	include "sound\_s1smps2asm_inc.asm"
    else
    endif

EnableSRAM:	= 1	; change to 1 to enable SRAM
BackupSRAM:	= 1
AddressSRAM:	= 3	; 0 = odd+even; 2 = even only; 3 = odd only

Revision:	= 1	; change to 1 for JP1 revision

; ===========================================================================

StartOfRom:

	if VladDebug = 0
Vectors:	dc.l $FFFE00, EntryPoint, BusError, AddressError
                dc.l IllegalInstrError, ZeroDivideError, CHKExceptionError, TRAPVError
                dc.l PrivilegeViolation, TraceError, LineAEmulation, LineFEmulation
                dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
                dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
                dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
                dc.l SpuriousException, ErrorTrap, ErrorTrap, ErrorTrap
                dc.l H_int_jump, ErrorTrap, VBlank, ErrorTrap
                dc.l TrapVector, TrapVector, TrapVector, TrapVector
                dc.l TrapVector, TrapVector, TrapVector, TrapVector
                dc.l TrapVector, TrapVector, TrapVector, TrapVector
                dc.l TrapVector, TrapVector, TrapVector, TrapVector
                dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
                dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
                dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
                dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
    else
Vectors:    dc.l $FFFE00, EntryPoint, BusError, AddressError
        dc.l IllegalInstr, ZeroDivide, ChkInstr, TrapvInstr
        dc.l PrivilegeViol, Trace, Line1010Emu, Line1111Emu
        dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept
        dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept
        dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept
        dc.l ErrorExcept, ErrorTrap, ErrorTrap, ErrorTrap
        dc.l H_int_jump, ErrorTrap, VBlank, ErrorTrap
        dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
        dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
        dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
        dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
        dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
        dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
        dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
        dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
    endif
Console:		dc.b "SEGA MEGA DRIVE " ; Hardware system ID
ReleaseDate:	dc.b "(C)SEGA 1991.APR" ; Release date
Title_Local:	dc.b "Sonic the Hedgehog Metroidvania, by Crash       " ; Domestic name
Title_Int:		dc.b "Sonic the Hedgehog Metroidvania, by Crash       " ; International name
Serial:         dc.b "GM 00004049-01"
Checksum:		dc.w 0
				dc.b "J               " ; I/O support
RomStartLoc:	dc.l StartOfRom		; ROM start
RomEndLoc:		dc.l EndOfRom-1		; ROM end
RamStartLoc:	dc.l $FF0000		; RAM start
RamEndLoc:		dc.l $FFFFFF		; RAM end
SRAMSupport:	if EnableSRAM=1
		dc.b $52, $41, $A0+(BackupSRAM<<6)+(AddressSRAM<<3), $20
		else
		dc.l $20202020
		endif
		dc.l $200001		; SRAM start ($200001)
		dc.l $200B01		; SRAM end ($20xxxx)
Notes:			dc.b "                                                    "
Region:			dc.b "JUE             " ; Region

; ===========================================================================
	if VladDebug = 0
	else
 ErrorTrap:
 		nop	
 		nop	
 		bra.s	ErrorTrap
 	endif	
; ===========================================================================

EntryPoint:
		tst.l	($A10008).l	; test port A & B control registers
		bne.s	PortA_Ok
		tst.w	($A1000C).l	; test port C control register
	PortA_Ok:
		bne.s	SkipSetup

		lea	SetupValues(pc),a5
		movem.w	(a5)+,d5-d7
		movem.l	(a5)+,a0-a4
		move.b	-$10FF(a1),d0	; get hardware version (from $A10001)
		andi.b	#$F,d0
		beq.s	SkipSecurity
		move.l	#'SEGA',$2F00(a1) ; move "SEGA" to TMSS register ($A14000)

SkipSecurity:
		move.w	(a4),d0
		moveq	#0,d0
		movea.l	d0,a6
		move.l	a6,usp		; set usp to 0

		moveq	#$17,d1
VDPInitLoop:
		move.b	(a5)+,d5	; add $8000 to value
		move.w	d5,(a4)		; move value to	VDP register
		add.w	d7,d5		; next register
		dbf	d1,VDPInitLoop
		move.l	(a5)+,(a4)
		move.w	d0,(a3)		; clear	the VRAM
		move.w	d7,(a1)		; stop the Z80
		move.w	d7,(a2)		; reset	the Z80

	WaitForZ80:
		btst	d0,(a1)		; has the Z80 stopped?
		bne.s	WaitForZ80	; if not, branch

		moveq	#$25,d2
Z80InitLoop:
		move.b	(a5)+,(a0)+
		dbf	d2,Z80InitLoop
		move.w	d0,(a2)
		move.w	d0,(a1)		; start	the Z80
		move.w	d7,(a2)		; reset	the Z80

ClrRAMLoop:
		move.l	d0,-(a6)
		dbf	d6,ClrRAMLoop	; clear	the entire RAM
		move.l	(a5)+,(a4)	; set VDP display mode and increment
		move.l	(a5)+,(a4)	; set VDP to CRAM write

		moveq	#$1F,d3
ClrCRAMLoop:
		move.l	d0,(a3)
		dbf	d3,ClrCRAMLoop	; clear	the CRAM
		move.l	(a5)+,(a4)

		moveq	#$13,d4
ClrVSRAMLoop:
		move.l	d0,(a3)
		dbf	d4,ClrVSRAMLoop ; clear the VSRAM
		moveq	#3,d5

PSGInitLoop:
		move.b	(a5)+,$11(a3)	; reset	the PSG
		dbf	d5,PSGInitLoop
		move.w	d0,(a2)
		movem.l	(a6),d0-a6	; clear	all registers
		move	#$2700,sr	; set the sr

SkipSetup:
		bra.s	GameProgram	; begin game

; ===========================================================================
SetupValues:	dc.w $8000		; VDP register start number
		dc.w $3FFF		; size of RAM/4
		dc.w $100		; VDP register diff

		dc.l $A00000		; start	of Z80 RAM
		dc.l $A11100		; Z80 bus request
		dc.l $A11200		; Z80 reset
		dc.l $C00000		; VDP data port
		dc.l $C00004		; VDP control port

		dc.b 4			; VDP $80 - 8-colour mode
		dc.b $14		; VDP $81 - Megadrive mode, DMA enable
		dc.b ($C000>>10)	; VDP $82 - foreground nametable address
		dc.b ($F000>>10)	; VDP $83 - window nametable address
		dc.b ($E000>>13)	; VDP $84 - background nametable address
		dc.b ($D800>>9)		; VDP $85 - sprite table address
		dc.b 0			; VDP $86 - unused
		dc.b 0			; VDP $87 - background colour
		dc.b 0			; VDP $88 - unused
		dc.b 0			; VDP $89 - unused
		dc.b 255		; VDP $8A - HBlank register
		dc.b 0			; VDP $8B - full screen scroll
		dc.b $81		; VDP $8C - 40 cell display
		dc.b ($DC00>>10)	; VDP $8D - hscroll table address
		dc.b 0			; VDP $8E - unused
		dc.b 1			; VDP $8F - VDP increment
		dc.b 1			; VDP $90 - 64 cell hscroll size
		dc.b 0			; VDP $91 - window h position
		dc.b 0			; VDP $92 - window v position
		dc.w $FFFF		; VDP $93/94 - DMA length
		dc.w 0			; VDP $95/96 - DMA source
		dc.b $80		; VDP $97 - DMA fill VRAM
		dc.l $40000080		; VRAM address 0

		dc.b $AF, 1, $D9, $1F, $11, $27, 0, $21, $26, 0, $F9, $77 ; Z80	instructions
		dc.b $ED, $B0, $DD, $E1, $FD, $E1, $ED,	$47, $ED, $4F
		dc.b $D1, $E1, $F1, 8, $D9, $C1, $D1, $E1, $F1,	$F9, $F3
		dc.b $ED, $56, $36, $E9, $E9

		dc.w $8104		; VDP display mode
		dc.w $8F02		; VDP increment
		dc.l $C0000000		; CRAM write mode
		dc.l $40000010		; VSRAM address 0

		dc.b $9F, $BF, $DF, $FF	; values for PSG channel volumes
; ===========================================================================

GameProgram:
		move.w	#$4EF9,(H_int_jump).w   ;"jmp" in machine code (h-int runs this)
		move.l	#HBlank,(H_int_addr).w  ; hblank code address to jump to
           if SkipChecksum=1
           else
		tst.w	($C00004).l
		btst	#6,($A1000D).l
		beq.s	CheckSumCheck
		cmpi.l	#'init',(v_init).w ; has checksum routine already run?
		beq.w	GameInit	; if yes, branch

CheckSumCheck:
		movea.l	#ErrorTrap,a0	; start	checking bytes after the header	($200)
		movea.l	#RomEndLoc,a1	; stop at end of ROM
		move.l	(a1),d0
		moveq	#0,d1

	@loop:
		add.w	(a0)+,d1
		cmp.l	a0,d0
		bcc.s	@loop
		movea.l	#Checksum,a1	; read the checksum
		cmp.w	(a1),d1		; compare checksum in header to ROM
		bne.w	CheckSumError	; if they don't match, branch

	CheckSumOk:
		lea	($FFFFFE00).w,a6
		moveq	#0,d7
		move.w	#$7F,d6
	@clearRAM:
		move.l	d7,(a6)+
		dbf	d6,@clearRAM	; clear RAM ($FE00-$FFFF)

		move.b	($A10001).l,d0
		andi.b	#$C0,d0
		move.b	d0,(v_megadrive).w ; get region setting
		move.l	#'init',(v_init).w ; set flag so checksum won't run again
        endif
GameInit:
		lea	($FF0000).l,a6
		moveq	#0,d7
		move.w	#$3F7F,d6
	@clearRAM:
		move.l	d7,(a6)+
		dbf	d6,@clearRAM	; clear RAM ($0000-$FDFF)

		move.w	#$4EF9,(H_int_jump).w   ;"jmp" in machine code (h-int runs this)
		move.l	#HBlank,(H_int_addr).w  ; hblank code address to jump to

	        jsr	(InitDMAQueue).l
        	bsr.w	VDPSetupGame
		bsr.w	SoundDriverLoad
		bsr.w	JoypadInit
		move.b	#id_Sega,(v_gamemode).w ; set Game Mode to Sega Screen

MainGameLoop:
		move.b	(v_gamemode).w,d0 ; load Game Mode
		andi.w	#$3C,d0
		jsr	GameModeArray(pc,d0.w) ; jump to apt location in ROM
		bra.s	MainGameLoop
; ===========================================================================
; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------

GameModeArray:

ptr_GM_Sega:	bra.w	GM_Sega		; Sega Screen ($00)

ptr_GM_Title:	bra.w	GM_Title	; Title	Screen ($04)

ptr_GM_Demo:	bra.w	GM_Level	; Demo Mode ($08)

ptr_GM_Level:	bra.w	GM_Level	; Normal Level ($0C)

ptr_GM_Special:	bra.w	GM_Special	; Special Stage	($10)

ptr_GM_Cont:	bra.w	GM_Continue	; Continue Screen ($14)

ptr_GM_Ending:	bra.w	GM_Ending	; End of game sequence ($18)

ptr_GM_Credits:	bra.w	GM_Credits	; Credits ($1C)

ptr_GM_SSRG:    bra.w   GM_SSRGScreen   ; CreditsSSRG Screen ($20)

		rts	
; ===========================================================================

CheckSumError:
	        jsr	(InitDMAQueue).l
        	bsr.w	VDPSetupGame
		move.l	#$C0000000,($C00004).l ; set VDP to CRAM write
		moveq	#$3F,d7

	@fillred:
		move.w	#cRed,($C00000).l ; fill palette with red
		dbf	d7,@fillred	; repeat $3F more times

	@endlessloop:
		bra.s	@endlessloop
; ===========================================================================
                include "_inc\Error Handling.asm"
; ===========================================================================

Art_Text:	incbin	"artunc\menutext.bin" ; text used in level select and debug mode
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Vertical interrupt
; ---------------------------------------------------------------------------

VBlank:					; XREF: Vectors

        movem.l	d0-a6,-(sp)                   ; save registers to stack

		tst.b	(v_vbla_routine).w
		beq		VBla_00
		move.w	($C00004).l,d0
		move.l	#$40000010,($C00004).l
		move.l	(v_scrposy_dup).w,($C00000).l ; send screen y-axis pos. to VSRAM
		move.l	(v_scrposy_dup).w,(v_screenYstretch).w ; send screen y-axis pos.
		move.w	#$8720,($C00004).l	      ; set background colour (line 3, palette entry 0)
    if PALWait=1
		btst	#6,(v_megadrive).w ; is Megadrive PAL?
		beq.s	VBla_NotPAL	; if not, branch

		move.w	#$700,d0
	VBla_WaitPAL:
		dbf	d0,VBla_WaitPAL

	VBla_NotPAL:
    endif
		move.b	(v_vbla_routine).w,d0
		move.b	#0,(v_vbla_routine).w
		move.w	#1,(f_hbla_pal).w
		andi.w	#$3E,d0
		move.w	VBla_Index(pc,d0.w),d0
		jsr	VBla_Index(pc,d0.w)

VBla_Music:				; XREF: VBla_00
	
        if z80SoundDriver=0
                jsr	(UpdateMusic).l
        endif

VBla_Exit:				; XREF: VBla_08
		addq.l	#1,(v_vbla_count).w         ; add 1 to frame count
   		movem.l	(sp)+,d0-a6                 ; restore registers from stack
		rte	                            ; return from vblank interrupt
; ===========================================================================
VBla_Index:	dc.w VBla_00-VBla_Index, VBla_02-VBla_Index
		dc.w VBla_04-VBla_Index, VBla_06-VBla_Index
		dc.w VBla_08-VBla_Index, VBla_0A-VBla_Index
		dc.w VBla_0C-VBla_Index, VBla_0E-VBla_Index
		dc.w VBla_10-VBla_Index, VBla_12-VBla_Index
		dc.w VBla_14-VBla_Index, VBla_16-VBla_Index
		dc.w VBla_0C-VBla_Index, VBla_1A-VBla_Index
; ===========================================================================

VBla_00:				; XREF: VBlank; VBla_Index
		cmpi.b	#$80+id_Level,(v_gamemode).w
		beq.s	@islevel
		cmpi.b	#id_Level,(v_gamemode).w ; is game on a level?
		bne.w	VBla_Music	; if not, branch

	@islevel:
		cmpi.b	#id_LZ,(v_zone).w ; is level LZ ?
		bne.w	VBla_Music	; if not, branch

		move.w	($C00004).l,d0
    if PALWait=1
		btst	#6,(v_megadrive).w ; is Megadrive PAL?
		beq.s	@notPAL		; if not, branch

		move.w	#$700,d0
	@waitPAL:
		dbf	d0,@waitPAL

	@notPAL:
    endif
        	move.w	#1,(f_hbla_pal).w ; set HBlank flag
; 		stopZ80
; 		waitZ80
		tst.b	(f_wtr_state).w	; is water above top of screen?
		bne.s	@waterabove 	; if yes, branch

		writeCRAM	v_pal1_wat,$80,0
		bra.s	@waterbelow

@waterabove:
		writeCRAM	v_pal0_dry,$80,0

	@waterbelow:
		move.w	(v_hbla_hreg).w,(a5)
; 		startZ80
		bra.w	VBla_Music
; ===========================================================================

VBla_02:				; XREF: VBla_Index
		bsr.w	sub_106E

VBla_14:				; XREF: VBla_Index
		tst.w	(v_demolength).w
		beq.w	@end
		subq.w	#1,(v_demolength).w

	@end:
		rts	
; ===========================================================================

VBla_04:				; XREF: VBla_Index
		bsr.w	sub_106E
		jsr	sub_6886
		bsr.w	sub_1642
		tst.w	(v_demolength).w
		beq.w	@end
		subq.w	#1,(v_demolength).w

	@end:
		rts	
; ===========================================================================

VBla_06:				; XREF: VBla_Index actually (loc_C5E)
		bsr.w	sub_106E
		rts	
; ===========================================================================

VBla_10:				; XREF: VBla_Index  actually (loc_C64E)
		cmpi.b	#id_Special,(v_gamemode).w ; is game on special stage?
		beq.w	VBla_0A		; if yes, branch

VBla_08:				; XREF: VBla_Index
; 		stopZ80                               ; actually (loc_C6E)
; 		waitZ80                               ; actually (loc_C76)
		bsr.w	ReadJoypads
		tst.b	(f_wtr_state).w
		bne.s	@waterabove

		writeCRAM	v_pal1_wat,$80,0
		bra.s	@waterbelow

@waterabove:                                     ; actually (loc_CB0)
		writeCRAM	v_pal0_dry,$80,0

	@waterbelow:                             ; actually (loc_CD4)
		move.w	(v_hbla_hreg).w,(a5)

		writeVRAM	v_scrolltable,$380,vram_hscroll
		writeVRAM	v_sprites,$280,vram_sprites
		jsr	(ProcessDMAQueue).l          ; +++ replaced code above, gfx crap
;                 startZ80
		movem.l	(v_screenposx).w,d0-d7
		movem.l	d0-d7,($FFFFFF10).w
		movem.l	(v_bgscroll1).w,d0-d1
		movem.l	d0-d1,($FFFFFF30).w
	;	cmpi.b	#40,(v_hbla_line).w          ; was 96
	;	bcc.s	Demo_Time
		bra.s	Demo_Time
		move.b	#1,($FFFFF64F).w
		addq.l	#4,sp
		bra.w	VBla_Exit

; ---------------------------------------------------------------------------
; Subroutine to	run a demo for an amount of time
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Demo_Time:				; XREF: VBlank; HBlank
		jsr	LoadTilesAsYouMove
		jsr	AnimateLevelGfx
		jsr	HUD_Update
		bsr.w	sub_165E
		tst.w	(v_demolength).w ; is there time left on the demo?
		beq.w	@end		; if not, branch
		subq.w	#1,(v_demolength).w ; subtract 1 from time left

	@end:
		jmp	(Set_Kos_Bookmark).l
	;	rts	
; End of function Demo_Time

; ===========================================================================

VBla_0A:				; XREF: VBla_Index      
; 		stopZ80                                    ;     actually loc_DA6
; 		waitZ80                                    ;     actually loc_DAE
		bsr.w	ReadJoypads
		writeCRAM	v_pal1_wat,$80,0
		writeVRAM	v_sprites,$280,vram_sprites
		writeVRAM	v_scrolltable,$380,vram_hscroll
; 		startZ80
		bsr.w	PalCycle_SS
                jsr	(ProcessDMAQueue).l              ; +++ as above, replaced code
		tst.w	(v_demolength).w
		beq.w	@end
		subq.w	#1,(v_demolength).w
                                                        ; actually locret_E70
	@end:
		rts	
; ===========================================================================

VBla_0C:				; XREF: VBla_Index     
; 		stopZ80                                        ; actually loc_E72
; 		waitZ80                                        ; actually loc_E7A
		bsr.w	ReadJoypads
		tst.b	(f_wtr_state).w
		bne.s	@waterabove

		writeCRAM	v_pal1_wat,$80,0
		bra.s	@waterbelow

@waterabove:
		writeCRAM	v_pal0_dry,$80,0

	@waterbelow:                                            ; loc_EEE
		move.w	(v_hbla_hreg).w,(a5)
		writeVRAM	v_scrolltable,$380,vram_hscroll
		writeVRAM	v_sprites,$280,vram_sprites
                jsr	(ProcessDMAQueue).l                  ; +++ again, as above
; 		startZ80                                     ; actually loc_F54
		movem.l	(v_screenposx).w,d0-d7
		movem.l	d0-d7,($FFFFFF10).w
		movem.l	(v_bgscroll1).w,d0-d1
		movem.l	d0-d1,($FFFFFF30).w
		jsr	LoadTilesAsYouMove
		jsr	AnimateLevelGfx
		jsr	HUD_Update
		bsr.w	sub_1642
		rts	
; ===========================================================================

VBla_0E:				; XREF: VBla_Index     actually loc_F8A
		bsr.w	sub_106E
		addq.b	#1,($FFFFF628).w
		move.b	#$E,(v_vbla_routine).w
		rts	
; ===========================================================================

VBla_12:				; XREF: VBla_Index      actually loc_F9A
		bsr.w	sub_106E
		move.w	(v_hbla_hreg).w,(a5)
		bra.w	sub_1642
; ===========================================================================

VBla_16:				; XREF: VBla_Index
; 		stopZ80                                         ; actually loc_FA6
; 		waitZ80                                         ; actually loc_FAE
		bsr.w	ReadJoypads
		writeCRAM	v_pal1_wat,$80,0
		writeVRAM	v_sprites,$280,vram_sprites
		writeVRAM	v_scrolltable,$380,vram_hscroll
; 		startZ80
                jsr	(ProcessDMAQueue).l                  ; +++ same gfx crap as before
		tst.w	(v_demolength).w
		beq.w	@end
		subq.w	#1,(v_demolength).w

	@end:
		rts	

; ===========================================================================
; Pause Menu Vblank routine
VBla_1A:
		bsr.w	ReadJoypads
		writeCRAM	v_pal1_wat,$80,0
		writeVRAM	v_scrolltable,$380,vram_hscroll
		writeVRAM	v_sprites,$280,vram_sprites
                jsr	(ProcessDMAQueue).l
		move.w	(v_hbla_hreg).w,(a5)
		bra.w	sub_1642

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

sub_106E:				; XREF: VBla_02; et al
; 		stopZ80
; 		waitZ80
		bsr.w	ReadJoypads
		tst.b	(f_wtr_state).w ; is water above top of screen?
		bne.s	@waterabove	; if yes, branch
		writeCRAM	v_pal1_wat,$80,0
		bra.s	@waterbelow

	@waterabove:
		writeCRAM	v_pal0_dry,$80,0

	@waterbelow:
		writeVRAM	v_sprites,$280,vram_sprites
		writeVRAM	v_scrolltable,$380,vram_hscroll
; 		startZ80
		jmp	(Set_Kos_Bookmark).l
; End of function sub_106E

; ---------------------------------------------------------------------------
; Horizontal interrupt
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HBlank:
                move	#$2700,sr
		tst.w	(f_hbla_pal).w	; is palette set to change?
		beq.s	@nochg		; if not, branch
		move.w	#0,(f_hbla_pal).w
		movem.l	a0-a1,-(sp)
		lea	($C00000).l,a1
		lea	(v_pal0_dry).w,a0 ; get palette from RAM
		move.l	#$C0000000,4(a1) ; set VDP to CRAM write
		move.l	(a0)+,(a1)	; move palette to CRAM
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.w	#$8A00+223,4(a1) ; reset HBlank register
		movem.l	(sp)+,a0-a1
		tst.b	($FFFFF64F).w
		bne.s	loc_119E

	@nochg:
		rte
; ===========================================================================

loc_119E:
		clr.b	($FFFFF64F).w
		movem.l	d0-a6,-(sp)
		bsr.w	Demo_Time
        if z80SoundDriver=0
                jsr	(UpdateMusic).l
        endif
		movem.l	(sp)+,d0-a6
		rte
; End of function HBlank

HBlank2:        ; background colour gradient
;                move	#$2700,sr
;		move.w	#$C040,($C00004).l            ; set VDP to CRAM write
; 		movem.l	d0,-(sp)
; @wait:
; 		move.w	($C00004).l,d0;(v_waterpos2).w
; 		btst	#2,d0;(v_waterpos2).w
; 		beq.s	@wait	                      ; wait until hblank
; 		move.w  (v_waterpos1).w,($C00000).l   ; send colour to data port
;		addi.w  #$21,(v_waterpos1).w
; 		movem.l	(sp)+,d0

;		move.w	#$8730,($C00004).l	; set background colour (line 3, palette entry 0)
		move.l	#$40000010,($C00004).l
		add.w	#2,(v_screenYstretch+2).w
		move.l	(v_screenYstretch).w,($C00000).l ; send screen y-axis pos. to VSRAM		tst.b	($FFFFF64F).w
	;	tst.b	($FFFFF64F).w
	;	bne.s	loc_119E
		rte
; ---------------------------------------------------------------------------
; Subroutine to	initialise joypads
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


JoypadInit:				; XREF: GameClrRAM
		stopZ80
		waitZ80
		moveq	#$40,d0
		move.b	d0,($A10009).l	; init port 1 (joypad 1)
		move.b	d0,($A1000B).l	; init port 2 (joypad 2)
		move.b	d0,($A1000D).l	; init port 3 (expansion)
		startZ80
		rts	
; End of function JoypadInit

; ---------------------------------------------------------------------------
; Subroutine to	read joypad input, and send it to the RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ReadJoypads:				; XREF: VBlank, HBlank
		lea	(v_jpadhold1).w,a0 ; address where joypad states are written
		lea	($A10003).l,a1	; first	joypad port
		bsr.s	@read		; do the first joypad
		addq.w	#2,a1		; do the second	joypad

	@read:
		move.b	#0,(a1)
		nop	
		nop	
		move.b	(a1),d0
		lsl.b	#2,d0
		andi.b	#$C0,d0
		move.b	#$40,(a1)
		nop	
		nop	
		move.b	(a1),d1
		andi.b	#$3F,d1
		or.b	d1,d0
		not.b	d0
		move.b	(a0),d1
		eor.b	d0,d1
		move.b	d0,(a0)+
		and.b	d0,d1
		move.b	d1,(a0)+
		rts	
; End of function ReadJoypads


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


VDPSetupGame:				; XREF: GameClrRAM; ChecksumError
		lea	($C00004).l,a0
		lea	($C00000).l,a1
		lea	(VDPSetupArray).l,a2
		moveq	#$12,d7

	@setreg:
		move.w	(a2)+,(a0)
		dbf	d7,@setreg	; set the VDP registers

		move.w	(VDPSetupArray+2).l,d0
		move.w	d0,(v_vdp_buffer1).w
		move.w	#$8A00+223,(v_hbla_hreg).w
		moveq	#0,d0
		move.l	#$C0000000,($C00004).l ; set VDP to CRAM write
		move.w	#$3F,d7

	@clrCRAM:
		move.w	d0,(a1)
		dbf	d7,@clrCRAM	; clear	the CRAM

		clr.l	(v_scrposy_dup).w
		clr.l	(v_scrposx_dup).w
		move.l	d1,-(sp)
		fillVRAM	0,$FFFF,0

	@waitforDMA:
		move.w	(a5),d1
		btst	#1,d1		; is DMA (fillVRAM) still running?
		bne.s	@waitforDMA	; if yes, branch

		move.w	#$8F02,(a5)	; set VDP increment size
		move.l	(sp)+,d1
		rts	
; End of function VDPSetupGame

; ===========================================================================
VDPSetupArray:	dc.w $8004		; 8-colour mode
		dc.w $8134		; enable V.interrupts, enable DMA
		dc.w $8200+(vram_fg>>10) ; set foreground nametable address
		dc.w $8300+($A000>>10)	; set window nametable address
		dc.w $8400+(vram_bg>>13) ; set background nametable address
		dc.w $8500+(vram_sprites>>9) ; set sprite table address
		dc.w $8600		; unused
		dc.w $8700		; set background colour (palette entry 0)
		dc.w $8800		; unused
		dc.w $8900		; unused
		dc.w $8A00		; default H.interrupt register
		dc.w $8B00		; full-screen vertical scrolling
		dc.w $8C81		; 40-cell display mode
		dc.w $8D00+(vram_hscroll>>10) ; set background hscroll address
		dc.w $8E00		; unused
		dc.w $8F02		; set VDP increment size
		dc.w $9001		; 64-cell hscroll size
		dc.w $9100		; window horizontal position
		dc.w $9200		; window vertical position

; ---------------------------------------------------------------------------
; Subroutine to	clear the screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ClearScreen:
		fillVRAM	0,$FFF,vram_fg ; clear foreground namespace

	@wait1:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	@wait1

		move.w	#$8F02,(a5)
		fillVRAM	0,$FFF,vram_bg ; clear background namespace

	@wait2:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	@wait2

		move.w	#$8F02,(a5)
		if Revision=0
		move.l	#0,(v_scrposy_dup).w
		move.l	#0,(v_scrposx_dup).w
		else
		clr.l	(v_scrposy_dup).w
		clr.l	(v_scrposx_dup).w
		endc

		lea	(v_sprites).w,a1
		moveq	#0,d0
		move.w	#$A0,d1

	@clearsprites:
		move.l	d0,(a1)+
		dbf	d1,@clearsprites ; clear sprite table (in RAM)

		lea	(v_scrolltable).w,a1
		moveq	#0,d0
		move.w	#$100,d1

	@clearhscroll:
		move.l	d0,(a1)+
		dbf	d1,@clearhscroll ; clear hscroll table (in RAM)
		rts	
; End of function ClearScreen

; ---------------------------------------------------------------------------
; Subroutine to	load the sound driver
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SoundDriverLoad:			; XREF: GameClrRAM; GM_Title

        if z80SoundDriver=0
; ===========================================================================
		nop
		stopZ80
		resetZ80
		lea	(Kos_Z80).l,a0	; load sound driver
		lea	($A00000).l,a1	; target Z80 RAM
		bsr.w	KosDec		; decompress
		resetZ80a
		nop
		nop	
		nop	
		nop	
		resetZ80
		startZ80
		rts
; ===========================================================================
        else

		nop
		stopZ80
		resetZ80
		lea		(RomEndLoc).l,a0
		move.l	(a0),d0
		addq.l	#1,d0
		movea.l	d0,a0
		lea	($A00000).l,a1
		bsr.w   KosDec
; 		lea	(DriverResetData).l,a0
;		lea	($A01C8A).l,a1									; z80 ram start of variables (A01C00 in older version)
;		move.w	#DriverResetDataEnd-DriverResetData,d0
 
;DriverResetDataLoadLoop:
;		move.b	(a0)+,(a1)+
;		dbf	d0,DriverResetDataLoadLoop
	btst	#0,($C00005).l	; check video mode
		sne		($A01C02).l          					; set PAL mode flag 

		resetZ80a
		nop
		nop	
		nop	
		nop	
		resetZ80
		startZ80
		rts
; End of function SoundDriverLoad
 
DriverResetData:
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DriverResetDataEnd:
        endif
;End of function SoundDriverLoad

		include	"_incObj\sub PlaySound.asm"
; ; ---------------------------------------------------------------------------
;                 jsr	LoadZ80drv
; 	        jsr	UpdateMusic
; ---------------------------------------------------------------------------
		include	"_inc\PauseGame.asm"

; ---------------------------------------------------------------------------
; Subroutine to	copy a tile map from RAM to VRAM namespace
; Known as ShowVDPGraphics in other disassamblies

; input:
;	a1 = tile map address
;	d0 = VRAM address
;	d1 = width (cells)
;	d2 = height (cells)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


TilemapToVRAM:				; XREF: GM_Sega; GM_Title; SS_BGLoad
		lea	($C00000).l,a6
		move.l	#$800000,d4

	Tilemap_Line:
		move.l	d0,4(a6)
		move.w	d1,d3

	Tilemap_Cell:
		move.w	(a1)+,(a6)	; write value to namespace
		dbf	d3,Tilemap_Cell
		add.l	d4,d0		; goto next line
		dbf	d2,Tilemap_Line
		rts	
; End of function TilemapToVRAM

		include	"_inc\Nemesis Decompression.asm"
		
; ---------------------------------------------------------------------------
; Flamewing's DMA queue optimisations:
; http://forums.sonicretro.org/index.php?showtopic=33275
; Subroutine for queueing VDP commands (seems to only queue transfers to VRAM),
; to be issued the next time ProcessDMAQueue is called.
; Can be called a maximum of 18 times before the queue needs to be cleared
; by issuing the commands (this subroutine DOES check for overflow)
; ---------------------------------------------------------------------------
; Input:
; 	d1	Source address
; 	d2	Destination address
; 	d3	Transfer length
; Output:
; 	d0,d1,d2,d3,a1	trashed
;
; ---------------------------------------------------------------------------
; This option breaks DMA transfers that crosses a 128kB block into two. It is
; disabled by default because you can simply align the art in ROM and avoid the
; issue altogether. It is here so that you have a high-performance routine to do
; the job in situations where you can't align it in ROM. It beats the equivalent
; functionality in the S&K disassembly with Sonic3_Complete flag set by a lot,
; especially since that version breaks up DMA transfers when they cross *32*kB
; boundaries instead of the problematic 128kB boundaries.
Use128kbSafeDMA = 0
; ---------------------------------------------------------------------------
; Option to mask interrupts while updating the DMA queue. This fixes many race
; conditions in the DMA funcion, but it costs 46(6/1) cycles. The better way to
; handle these race conditions would be to make unsafe callers (such as S3&K's
; KosM decoder) prevent these by masking off interrupts before calling and then
; restore interrupts after.
UseVIntSafeDMA = 0

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_144E: DMA_68KtoVRAM: QueueCopyToVRAM: QueueVDPCommand:
Add_To_DMA_Queue:
QueueDMATransfer:
	if UseVIntSafeDMA=1
	move.w	sr,-(sp)						; Save current interrupt mask
	move.w	#$2700,sr						; Mask off interrupts
	endif ; UseVIntSafeDMA=1
	movea.w	(v_vdp_buffer_slot).w,a1
	cmpa.w	#v_vdp_buffer_slot,a1
	beq.s	@done							; return if there's no more room in the queue

	lsr.l	#1,d1							; Source address is in words for the VDP registers
	if Use128kbSafeDMA=1
	move.w	d1,d0							; d0 = (src_address >> 1) & $FFFF
	; Note: unless you modded your Genesis for 128kB of VRAM, then d3 can be at
	; most $7FFF here in a valid call; we will assume this is the case
	add.w	d3,d0							; d0 = ((src_address >> 1) & $FFFF) + (xfer_len >> 1)
	bcs.s	@double_transfer				; Carry set = ($10000 << 1) = $20000, or new 128kB block
	endif ; Use128kbSafeDMA=1

	; Store VDP commands for specifying DMA into the queue
	swap	d1								; Want the high byte first
	move.w	#$977F,d0						; Command to specify source address & $FE0000, plus bitmask for the given byte
	and.b	d1,d0							; Mask in source address & $FE0000, stripping high bit in the process
	move.w	d0,(a1)+						; Store command
	move.w	d3,d1							; Put length together with (source address & $01FFFE) >> 1...
	movep.l	d1,1(a1)						; ... and stuff them all into RAM in their proper places (movep for the win)
	lea	8(a1),a1							; Skip past all of these commands

	lsl.l	#2,d2							; Move high bits into (word-swapped) position, accidentally moving everything else
	addq.w	#1,d2							; Add write bit...
	ror.w	#2,d2							; ... and put it into place, also moving all other bits into their correct (word-swapped) places
	swap	d2								; Put all bits in proper places
	andi.w	#3,d2							; Strip whatever junk was in upper word of d2
	tas.b	d2								; Add in the DMA bit -- tas fails on memory, but works on registers
	move.l	d2,(a1)+						; Store command

	clr.w	(a1)							; Put a stop token at the end of the used part of the queue
	move.w	a1,(v_vdp_buffer_slot).w	; Set the next free slot address, potentially undoing the above clr (this is intentional!)

@done:
	if UseVIntSafeDMA=1
	move.w	(sp)+,sr						; Restore interrupts to previous state
	endif ;UseVIntSafeDMA=1
	rts
; ---------------------------------------------------------------------------
	if Use128kbSafeDMA=1
@double_transfer:
	; Hand-coded version to break the DMA transfer into two smaller transfers
	; that do not cross a 128kB boundary. This is done much faster (at the cost
	; of space) than by the method of saving parameters and calling the normal
	; DMA function twice, as Sonic3_Complete does.
	; If we got here, d0 now has bit 15 clear
	; d0 is the number of words that got over the end of the 128kB boundary
	sub.w	d0,d3							; First transfer will use only up to the end of the 128kB boundary
	; Store VDP commands for specifying DMA into the queue
	swap	d1								; Want the high byte first
	; Sadly, all registers we can spare are in use right now, so we can't use
	; no-cost RAM source safety.
	andi.w	#$7F,d1							; Strip high bit
	ori.w	#$9700,d1						; Command to specify source address & $FE0000
	move.w	d1,(a1)+						; Store command
	addq.b	#1,d1							; Advance to next 128kB boundary (**)
	move.w	d1,12(a1)						; Store it now (safe to do in all cases, as we will overwrite later if queue got filled) (**)
	move.w	d3,d1							; Put length together with (source address & $01FFFE) >> 1...
	movep.l	d1,1(a1)						; ... and stuff them all into RAM in their proper places (movep for the win)
	lea	8(a1),a1							; Skip past all of these commands

	move.w	d2,d3							; Save for later
	lsl.l	#2,d2							; Move high bits into (word-swapped) position, accidentally moving everything else
	addq.w	#1,d2							; Add write bit...
	ror.w	#2,d2							; ... and put it into place, also moving all other bits into their correct (word-swapped) places
	swap	d2								; Put all bits in proper places
	andi.w	#3,d2							; Strip whatever junk was in upper word of d2
	tas.b	d2								; Add in the DMA bit -- tas fails on memory, but works on registers
	move.l	d2,(a1)+						; Store command

	cmpa.w	#v_vdp_buffer_slot,a1		; Did this command fill the queue?
	beq.s	@skip_second_transfer			; Branch if so

	; Store VDP commands for specifying DMA into the queue
	; The source address high byte was done above already in the comments marked
	; with (**)
	ext.l	d0								; Since d0 was at most $7FFF, fills high word with 0: this corresponds to a 128kB block start
	movep.l	d0,3(a1)						; ... and stuff them all into RAM in their proper places (movep for the win)
	lea	10(a1),a1							; Skip past all of these commands
	; d1 contains length up to the end of the 128kB boundary
	add.w	d1,d1							; Convert it into byte length...
	add.w	d1,d3							; ... and offset destination by the correct amount
	lsl.l	#2,d3							; Move high bits into (word-swapped) position, accidentally moving everything else
	addq.w	#1,d3							; Add write bit...
	ror.w	#2,d3							; ... and put it into place, also moving all other bits into their correct (word-swapped) places
	swap	d3								; Put all bits in proper places
	andi.w	#3,d3							; Strip whatever junk was in upper word of d3
	tas.b	d3								; Add in the DMA bit -- tas fails on memory, but works on registers
	move.l	d3,(a1)+						; Store command

	clr.w	(a1)							; Put a stop token at the end of the used part of the queue
	move.w	a1,(v_vdp_buffer_slot).w	; Set the next free slot address, potentially undoing the above clr (this is intentional!)

	if UseVIntSafeDMA=1
	move.w	(sp)+,sr						; Restore interrupts to previous state
	endif ;UseVIntSafeDMA=1
	rts
; ---------------------------------------------------------------------------
@skip_second_transfer:
	move.w	a1,(a1)							; Set the next free slot address, overwriting what the second (**) instruction did

	if UseVIntSafeDMA=1
	move.w	(sp)+,sr						; Restore interrupts to previous state
	endif ;UseVIntSafeDMA=1
	rts
	endif ; Use128kbSafeDMA=1
; End of function QueueDMATransfer
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine for issuing all VDP commands that were queued
; (by earlier calls to QueueDMATransfer)
; Resets the queue when it's done
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_14AC: CopyToVRAM: IssueVDPCommands: Process_DMA:
Process_DMA_Queue:
ProcessDMAQueue:
	lea	(VDP_control_port).l,a5
	lea	(v_sgfx_buffer).w,a1
	move.w	a1,(v_vdp_buffer_slot).w

	rept (v_vdp_buffer_slot-v_sgfx_buffer)/(7*2)
	move.w	(a1)+,d0
	beq.w	@done		; branch if we reached a stop token
	; issue a set of VDP commands...
	move.w	d0,(a5)
	move.l	(a1)+,(a5)
	move.l	(a1)+,(a5)
	move.w	(a1)+,(a5)
	move.w	(a1)+,(a5)
	endr
	moveq	#0,d0

@done:
	move.w	d0,(v_sgfx_buffer).w
	rts
; End of function ProcessDMAQueue
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine for initializing the DMA queue.
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

InitDMAQueue:
	lea	(v_sgfx_buffer).w,a1
	move.w	#0,(a1)
	move.w	a1,(v_vdp_buffer_slot).w
	move.l	#$96959493,d1
	rept (v_vdp_buffer_slot-v_sgfx_buffer)/(7*2)
	movep.l	d1,2(a1)
	lea	14(a1),a1
	endr
	rts
; End of function ProcessDMAQueue
; ===========================================================================


; ---------------------------------------------------------------------------
; Subroutines to load pattern load cues

; input:
;	d0 = pattern load cue number
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Subroutine to load the art for the animals for the current zone
; ---------------------------------------------------------------------------
 
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
LoadAnimalExplosion:
 		moveq	#0,d0
		move.b	(v_zone).w,d0
		add.w	d0,d0
		add.w	d0,d0
		lea	ZoneAnimals(pc,d0.w),a3
		movea.l	(a3)+,a1
		move.w	#$B000,d2
		jsr	(Queue_Kos_Module).l
		movea.l	(a3),a1
		move.w	#$B240,d2
		jsr	(Queue_Kos_Module).l	
		lea	(KosM_Explode).l,a1
		move.w	#$B400,d2
		jsr	(Queue_Kos_Module).l
		rts	

ZoneAnimals:
		dc.l	KosM_Rabbit, KosM_Flicky	; GHZ
		dc.l	KosM_BlackBird, KosM_Seal	; LZ
		dc.l	KosM_Squirrel, KosM_Seal	; MZ
		dc.l	KosM_Pig, KosM_Flicky		; SLZ
		dc.l	KosM_Pig, KosM_Chicken		; SYZ
		dc.l	KosM_Rabbit, KosM_Chicken	; SBZ
		dc.l	KosM_Rabbit, KosM_Flicky	; GHZ
		dc.l	KosM_Rabbit, KosM_Flicky	; GHZ
		dc.l	KosM_Rabbit, KosM_Flicky	; GHZ
		dc.l	KosM_Rabbit, KosM_Flicky	; GHZ
		dc.l	KosM_Rabbit, KosM_Flicky	; GHZ
		even

; End of function LoadAnimalPLC
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AddPLC:
		movem.l	a1-a2,-(sp)
		lea	(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1	; jump to relevant PLC
		lea	(v_plc_buffer).w,a2 ; PLC buffer space

	@findspace:
		tst.l	(a2)		; is space available in RAM?
		beq.s	@copytoRAM	; if yes, branch
		addq.w	#6,a2		; if not, try next space
		bra.s	@findspace
; ===========================================================================

@copytoRAM:
		move.w	(a1)+,d0	; get length of PLC
		bmi.s	@skip

	@loop:
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+	; copy PLC to RAM
		dbf	d0,@loop	; repeat for length of PLC

	@skip:
		movem.l	(sp)+,a1-a2
		rts	
; End of function AddPLC


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


NewPLC:
		movem.l	a1-a2,-(sp)
		lea	(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1	; jump to relevant PLC
		bsr.s	ClearPLC	; erase any data in PLC buffer space
		lea	(v_plc_buffer).w,a2
		move.w	(a1)+,d0	; get length of PLC
		bmi.s	@skip

	@loop:
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+	; copy PLC to RAM
		dbf	d0,@loop	; repeat for length of PLC

	@skip:
		movem.l	(sp)+,a1-a2
		rts	
; End of function NewPLC

; ---------------------------------------------------------------------------
; Subroutine to	clear the pattern load cues
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ClearPLC:				; XREF: NewPLC
		lea	(v_plc_buffer).w,a2 ; PLC buffer space in RAM
		moveq	#$1F,d0

	@loop:
		clr.l	(a2)+
		dbf	d0,@loop
		rts	
; End of function ClearPLC

; ---------------------------------------------------------------------------
; Subroutine to	use graphics listed in a pattern load cue
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


RunPLC:					; XREF: GM_Level; et al
		tst.l	(v_plc_buffer).w
		beq.s	Rplc_Exit
		tst.w	(f_plc_execute).w
		bne.s	Rplc_Exit
		movea.l	(v_plc_buffer).w,a0
		lea	(loc_1502).l,a3
		lea	(v_ngfx_buffer).w,a1
		move.w	(a0)+,d2
		bpl.s	loc_160E
		adda.w	#$A,a3

loc_160E:
		andi.w	#$7FFF,d2
		bsr.w	NemDec4
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		moveq	#$10,d6
		moveq	#0,d0
		move.l	a0,(v_plc_buffer).w
		move.l	a3,(v_ptrnemcode).w
		move.l	d0,($FFFFF6E4).w
		move.l	d0,($FFFFF6E8).w
		move.l	d0,($FFFFF6EC).w
		move.l	d5,($FFFFF6F0).w
		move.l	d6,($FFFFF6F4).w
		move.w	d2,(f_plc_execute).w
Rplc_Exit:
		rts	
; End of function RunPLC


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_1642:				; XREF: VBla_04; VBla_12
		tst.w	(f_plc_execute).w
		beq.w	locret_16DA
		move.w	#9,($FFFFF6FA).w
		moveq	#0,d0
		move.w	($FFFFF684).w,d0
		addi.w	#$120,($FFFFF684).w
		bra.s	loc_1676
; End of function sub_1642


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_165E:				; XREF: Demo_Time
		tst.w	(f_plc_execute).w
		beq.s	locret_16DA
		move.w	#3,($FFFFF6FA).w
		moveq	#0,d0
		move.w	($FFFFF684).w,d0
		addi.w	#$60,($FFFFF684).w

loc_1676:				; XREF: sub_1642
		lea	($C00004).l,a4
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,(a4)
		subq.w	#4,a4
		movea.l	(v_plc_buffer).w,a0
		movea.l	(v_ptrnemcode).w,a3
		move.l	($FFFFF6E4).w,d0
		move.l	($FFFFF6E8).w,d1
		move.l	($FFFFF6EC).w,d2
		move.l	($FFFFF6F0).w,d5
		move.l	($FFFFF6F4).w,d6
		lea	(v_ngfx_buffer).w,a1

loc_16AA:				; XREF: sub_165E
		movea.w	#8,a5
		bsr.w	NemDec3
		subq.w	#1,(f_plc_execute).w
		beq.s	loc_16DC
		subq.w	#1,($FFFFF6FA).w
		bne.s	loc_16AA
		move.l	a0,(v_plc_buffer).w
		move.l	a3,(v_ptrnemcode).w
		move.l	d0,($FFFFF6E4).w
		move.l	d1,($FFFFF6E8).w
		move.l	d2,($FFFFF6EC).w
		move.l	d5,($FFFFF6F0).w
		move.l	d6,($FFFFF6F4).w

locret_16DA:				; XREF: sub_1642
		jmp	(Set_Kos_Bookmark).l
; ===========================================================================

loc_16DC:				; XREF: sub_165E
		lea	(v_plc_buffer).w,a0
		moveq	#$15,d0

loc_16E2:				; XREF: sub_165E
		move.l	6(a0),(a0)+
		dbf	d0,loc_16E2
		jmp	(Set_Kos_Bookmark).l
; End of function sub_165E

; ---------------------------------------------------------------------------
; Subroutine to	execute	the pattern load cue
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


QuickPLC:
		lea	(ArtLoadCues).l,a1 ; load the PLC index
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		move.w	(a1)+,d1	; get length of PLC

	Qplc_Loop:
		movea.l	(a1)+,a0	; get art pointer
		moveq	#0,d0
		move.w	(a1)+,d0	; get VRAM address
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,($C00004).l	; converted VRAM address to VDP format
		bsr.w	NemDec		; decompress
		dbf	d1,Qplc_Loop	; repeat for length of PLC
		rts	
; End of function QuickPLC

		include	"_inc\Enigma Decompression.asm"
		include	"_inc\Kosinski Decompression.asm"

		include	"_inc\PaletteCycle.asm"

Pal_TitleCyc:	incbin	"palette\Cycle - Title Screen Water.bin"
Pal_GHZCyc:	incbin	"palette\Cycle - GHZ.bin"
Pal_MZCyc:	incbin	"palette\Cycle - MZ.bin"
Pal_LZCyc1:	incbin	"palette\Cycle - LZ Waterfall.bin"
Pal_LZCyc2:	incbin	"palette\Cycle - LZ Conveyor Belt.bin"
Pal_LZCyc3:	incbin	"palette\Cycle - LZ Conveyor Belt Underwater.bin"
Pal_LZCyc4:	incbin	"palette\Cycle - LZ Sea.bin"
Pal_SBZ3Cyc1:	incbin	"palette\Cycle - SBZ3 Waterfall.bin"
Pal_SLZCyc:	incbin	"palette\Cycle - SLZ.bin"
Pal_SYZCyc1:	incbin	"palette\Cycle - SYZ1.bin"
Pal_SYZCyc2:	incbin	"palette\Cycle - SYZ2.bin"

		include	"_inc\SBZ Palette Scripts.asm"

Pal_SBZCyc1:	incbin	"palette\Cycle - SBZ 1.bin"
Pal_SBZCyc2:	incbin	"palette\Cycle - SBZ 2.bin"
Pal_SBZCyc3:	incbin	"palette\Cycle - SBZ 3.bin"
Pal_SBZCyc4:	incbin	"palette\Cycle - SBZ 4.bin"
Pal_SBZCyc5:	incbin	"palette\Cycle - SBZ 5.bin"
Pal_SBZCyc6:	incbin	"palette\Cycle - SBZ 6.bin"
Pal_SBZCyc7:	incbin	"palette\Cycle - SBZ 7.bin"
Pal_SBZCyc8:	incbin	"palette\Cycle - SBZ 8.bin"
Pal_SBZCyc9:	incbin	"palette\Cycle - SBZ 9.bin"
Pal_SBZCyc10:	incbin	"palette\Cycle - SBZ 10.bin"

; ===========================================================================

PalCycle_SuperSonic:
	move.b	(v_supersonicpal).w,d0
	beq.s	@rts	; return, if Sonic isn't super
	bmi.w	PalCycle_SuperSonic_normal	; branch, if fade-in is done
	subq.b	#1,d0
	bne.s	PalCycle_SuperSonic_revert	; branch for values greater than 1

	; fade from Sonic's to Super Sonic's palette
	; run frame timer
	subq.b	#1,(v_supersonicpaltimer).w
	bpl.s	@rts
	move.b	#3,(v_supersonicpaltimer).w

	; increment palette frame and update Sonic's palette
	lea	(CyclingPal_SSTransformation).l,a0
	move.w	(v_supersonicpalframe).w,d0
	addq.w	#8,(v_supersonicpalframe).w	; 1 palette entry = 1 word, Sonic uses 4 shades of blue
	cmpi.w	#$30,(v_supersonicpalframe).w	; has palette cycle reached the 6th frame?
	blo.s	@changepal			; if not, branch
	move.b	#-1,(v_supersonicpal).w	; mark fade-in as done
	move.b	#0,(f_lockmulti).w	; restore Sonic's movement

@changepal:
	lea	(v_pal1_wat+4).w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)
	; note: the fade in for Sonic's underwater palette is missing.
	; branch to the code below (*) to fix this
@rts:	rts

; ===========================================================================
PalCycle_SuperSonic_revert:	; runs the fade in transition backwards
	; run frame timer
	subq.b	#1,(v_supersonicpaltimer).w
	bpl.s	@rts
	move.b	#3,(v_supersonicpaltimer).w

	; decrement palette frame and update Sonic's palette
	lea	(CyclingPal_SSTransformation).l,a0
	move.w	(v_supersonicpalframe).w,d0
	subq.w	#8,(v_supersonicpalframe).w	; previous frame
	bcc.s	@changepal			; branch, if it isn't the first frame
	move.b	#0,(v_supersonicpalframe).w
	move.b	#0,(v_supersonicpal).w	; stop palette cycle
@changepal:
	lea	(v_pal1_wat+4).w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)
	; underwater palettes (*)
; 	lea	(CyclingPal_CPZUWTransformation).l,a0
; 	cmpi.b	#chemical_plant_zone,(Current_Zone).w
; 	beq.s	+
; 	cmpi.b	#aquatic_ruin_zone,(Current_Zone).w
; 	bne.s	-	; rts
; 	lea	(CyclingPal_ARZUWTransformation).l,a0
; +	lea	(Underwater_palette+4).w,a1
; 	move.l	(a0,d0.w),(a1)+
; 	move.l	4(a0,d0.w),(a1)
@rts:	rts
; ===========================================================================
; loc_21E6:
PalCycle_SuperSonic_normal:
	; run frame timer
	subq.b	#1,(v_supersonicpaltimer).w
	bpl.s	@rts
	move.b	#7,(v_supersonicpaltimer).w

	; increment palette frame and update Sonic's palette
	lea	(CyclingPal_SSTransformation).l,a0
	move.w	(v_supersonicpalframe).w,d0
	addq.w	#8,(v_supersonicpalframe).w	; next frame
	cmpi.w	#$78,(v_supersonicpalframe).w	; is it the last frame?
	blo.s	@changepal			; if not, branch
	move.w	#$30,(v_supersonicpalframe).w	; reset frame counter (Super Sonic's normal palette cycle starts at $30. Everything before that is for the palette fade)
@changepal:
	lea	(v_pal1_wat+4).w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)
	; underwater palettes
; 	lea	(CyclingPal_CPZUWTransformation).l,a0
; 	cmpi.b	#chemical_plant_zone,(Current_Zone).w
; 	beq.s	+
; 	cmpi.b	#aquatic_ruin_zone,(Current_Zone).w
; 	bne.w	-	; rts
; 	lea	(CyclingPal_ARZUWTransformation).l,a0
; +	lea	(Underwater_palette+4).w,a1
; 	move.l	(a0,d0.w),(a1)+
; 	move.l	4(a0,d0.w),(a1)
@rts: 	rts
; End of function PalCycle_SuperSonic

; ===========================================================================
;----------------------------------------------------------------------------
;Palette for transformation to Super Sonic
;----------------------------------------------------------------------------
CyclingPal_SSTransformation:
	incbin	"palette/Super Sonic transformation.bin"
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	fade in from black
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeIn:
		move.w	#$003F,(v_pfade_start).w ; set start position = 0; size = $40

PalFadeIn_Alt:				; start position and size are already set
		moveq	#0,d0
		lea	(v_pal1_wat).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		moveq	#cBlack,d1
		move.b	(v_pfade_size).w,d0

	@fill:
		move.w	d1,(a0)+
		dbf	d0,@fill 	; fill palette with black

		move.w	#$15,d4

	@mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	FadeIn_FromBlack
		bsr.w	RunPLC
		dbf	d4,@mainloop
		rts	
; End of function PaletteFadeIn

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeInFast:
		move.w	#$003F,(v_pfade_start).w ; set start position = 0; size = $40

PalFadeIn_AltFast:				; start position and size are already set
		moveq	#0,d0
		lea	(v_pal1_wat).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		moveq	#cBlack,d1
		move.b	(v_pfade_size).w,d0

	@fill:
		move.w	d1,(a0)+
		dbf	d0,@fill 	; fill palette with black

		move.w	#$7,d4

	@mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	FadeIn_FromBlack
		bsr.s	FadeIn_FromBlack
		bsr.s	FadeIn_FromBlack
		bsr.w	RunPLC
		dbf	d4,@mainloop
		rts	
; End of function PaletteFadeIn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeIn_FromBlack:			; XREF: PaletteFadeIn
		moveq	#0,d0
		lea	(v_pal1_wat).w,a0
		lea	(v_pal1_dry).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

	@addcolour:
		bsr.s	FadeIn_AddColour ; increase colour
		dbf	d0,@addcolour	; repeat for size of palette

		cmpi.b	#1,(v_zone).w	; is level Labyrinth?
		bne.s	@exit		; if not, branch

		moveq	#0,d0
		lea	(v_pal0_dry).w,a0
		lea	(v_pal0_wat).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

	@addcolour2:
		bsr.s	FadeIn_AddColour ; increase colour again
		dbf	d0,@addcolour2 ; repeat

@exit:
		rts	
; End of function FadeIn_FromBlack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeIn_AddColour:			; XREF: FadeIn_FromBlack
@addblue:
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3		; is colour already at threshold level?
		beq.s	@next		; if yes, branch
		move.w	d3,d1
		addi.w	#$200,d1	; increase blue	value
		cmp.w	d2,d1		; has blue reached threshold level?
		bhi.s	@addgreen	; if yes, branch
		move.w	d1,(a0)+	; update palette
		rts	
; ===========================================================================

@addgreen:
		move.w	d3,d1
		addi.w	#$20,d1		; increase green value
		cmp.w	d2,d1
		bhi.s	@addred
		move.w	d1,(a0)+	; update palette
		rts	
; ===========================================================================

@addred:
		addq.w	#2,(a0)+	; increase red value
		rts	
; ===========================================================================

@next:
		addq.w	#2,a0		; next colour
		rts	
; End of function FadeIn_AddColour


; ---------------------------------------------------------------------------
; Subroutine to fade out to black
; ---------------------------------------------------------------------------


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeOut:
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40
		move.w	#$15,d4

	@mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	FadeOut_ToBlack
		bsr.w	RunPLC
		dbf	d4,@mainloop
		rts	
; End of function PaletteFadeOut

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeOutFast:
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40
		move.w	#$7,d4

	@mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	FadeOut_ToBlack
		bsr.s	FadeOut_ToBlack
		bsr.s	FadeOut_ToBlack
		bsr.w	RunPLC
		dbf	d4,@mainloop
		rts	
; End of function PaletteFadeOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeOut_ToBlack:			; XREF: PaletteFadeOut
		moveq	#0,d0
		lea	(v_pal1_wat).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

	@decolour:
		bsr.s	FadeOut_DecColour ; decrease colour
		bsr.s	FadeOut_DecColour ; decrease colour
		dbf	d0,@decolour	; repeat for size of palette

		moveq	#0,d0
		lea	(v_pal0_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

	@decolour2:
		bsr.s	FadeOut_DecColour
		bsr.s	FadeOut_DecColour
		dbf	d0,@decolour2
		rts
; End of function FadeOut_ToBlack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeOut_DecColour:			; XREF: FadeOut_ToBlack
@dered:
		move.w	(a0),d2
		beq.s	@next
		move.w	d2,d1
		andi.w	#$E,d1
		beq.s	@degreen
		subq.w	#2,(a0)+	; decrease red value
		rts	
; ===========================================================================

@degreen:
		move.w	d2,d1
		andi.w	#$E0,d1
		beq.s	@deblue
		subi.w	#$20,(a0)+	; decrease green value
		rts	
; ===========================================================================

@deblue:
		move.w	d2,d1
		andi.w	#$E00,d1
		beq.s	@next
		subi.w	#$200,(a0)+	; decrease blue	value
		rts	
; ===========================================================================

@next:
		addq.w	#2,a0
		rts	
; End of function FadeOut_DecColour

; ---------------------------------------------------------------------------
; Subroutine to	fade in from white (Special Stage)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteWhiteIn:				; XREF: GM_Special
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40
		moveq	#0,d0
		lea	(v_pal1_wat).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.w	#cWhite,d1
		move.b	(v_pfade_size).w,d0

	@fill:
		move.w	d1,(a0)+
		dbf	d0,@fill 	; fill palette with white

		move.w	#$15,d4

	@mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	WhiteIn_FromWhite
		bsr.w	RunPLC
		dbf	d4,@mainloop
		rts	
; End of function PaletteWhiteIn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteIn_FromWhite:			; XREF: PaletteWhiteIn
		moveq	#0,d0
		lea	(v_pal1_wat).w,a0
		lea	(v_pal1_dry).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

	@decolour:
		bsr.s	WhiteIn_DecColour ; decrease colour
		dbf	d0,@decolour	; repeat for size of palette

		cmpi.b	#1,(v_zone).w	; is level Labyrinth?
		bne.s	@exit		; if not, branch
		moveq	#0,d0
		lea	(v_pal0_dry).w,a0
		lea	(v_pal0_wat).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

	@decolour2:
		bsr.s	WhiteIn_DecColour
		dbf	d0,@decolour2

	@exit:
		rts	
; End of function WhiteIn_FromWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteIn_DecColour:			; XREF: WhiteIn_FromWhite
@deblue:
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3
		beq.s	@next
		move.w	d3,d1
		subi.w	#$200,d1	; decrease blue	value
		bcs.s	@degreen
		cmp.w	d2,d1
		bcs.s	@degreen
		move.w	d1,(a0)+
		rts	
; ===========================================================================

@degreen:
		move.w	d3,d1
		subi.w	#$20,d1		; decrease green value
		bcs.s	@dered
		cmp.w	d2,d1
		bcs.s	@dered
		move.w	d1,(a0)+
		rts	
; ===========================================================================

@dered:
		subq.w	#2,(a0)+	; decrease red value
		rts	
; ===========================================================================

@next:
		addq.w	#2,a0
		rts	
; End of function WhiteIn_DecColour

; ---------------------------------------------------------------------------
; Subroutine to fade to white (Special Stage)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteWhiteOut:			; XREF: GM_Special
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40
		move.w	#$15,d4

	@mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	WhiteOut_ToWhite
		bsr.w	RunPLC
		dbf	d4,@mainloop
		rts	
; End of function PaletteWhiteOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteOut_ToWhite:			; XREF: PaletteWhiteOut
		moveq	#0,d0
		lea	(v_pal1_wat).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

	@addcolour:
		bsr.s	WhiteOut_AddColour
		dbf	d0,@addcolour

		moveq	#0,d0
		lea	(v_pal0_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

	@addcolour2:
		bsr.s	WhiteOut_AddColour
		dbf	d0,@addcolour2
		rts	
; End of function WhiteOut_ToWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteOut_AddColour:			; XREF: WhiteOut_ToWhite
@addred:
		move.w	(a0),d2
		cmpi.w	#cWhite,d2
		beq.s	@next
		move.w	d2,d1
		andi.w	#$E,d1
		cmpi.w	#cRed,d1
		beq.s	@addgreen
		addq.w	#2,(a0)+	; increase red value
		rts	
; ===========================================================================

@addgreen:
		move.w	d2,d1
		andi.w	#$E0,d1
		cmpi.w	#cGreen,d1
		beq.s	@addblue
		addi.w	#$20,(a0)+	; increase green value
		rts	
; ===========================================================================

@addblue:
		move.w	d2,d1
		andi.w	#$E00,d1
		cmpi.w	#cBlue,d1
		beq.s	@next
		addi.w	#$200,(a0)+	; increase blue	value
		rts	
; ===========================================================================

@next:
		addq.w	#2,a0
		rts	
; End of function WhiteOut_AddColour

; ---------------------------------------------------------------------------
; Palette cycling routine - Sega logo
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_Sega:				; XREF: GM_Sega
		tst.b	(v_pcyc_time+1).w
		bne.s	loc_206A
		lea	(v_pal1_wat+$20).w,a1
		lea	(Pal_Sega1).l,a0
		moveq	#5,d1
		move.w	(v_pcyc_num).w,d0

loc_2020:
		bpl.s	loc_202A
		addq.w	#2,a0
		subq.w	#1,d1
		addq.w	#2,d0
		bra.s	loc_2020
; ===========================================================================

loc_202A:				; XREF: PalCycle_Sega
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_2034
		addq.w	#2,d0

loc_2034:
		cmpi.w	#$60,d0
		bcc.s	loc_203E
		move.w	(a0)+,(a1,d0.w)

loc_203E:
		addq.w	#2,d0
		dbf	d1,loc_202A

		move.w	(v_pcyc_num).w,d0
		addq.w	#2,d0
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_2054
		addq.w	#2,d0

loc_2054:
		cmpi.w	#$64,d0
		blt.s	loc_2062
		move.w	#$401,(v_pcyc_time).w
		moveq	#-$C,d0

loc_2062:
		move.w	d0,(v_pcyc_num).w
		moveq	#1,d0
		rts	
; ===========================================================================

loc_206A:				; XREF: loc_202A
		subq.b	#1,(v_pcyc_time).w
		bpl.s	loc_20BC
		move.b	#4,(v_pcyc_time).w
		move.w	(v_pcyc_num).w,d0
		addi.w	#$C,d0
		cmpi.w	#$30,d0
		bcs.s	loc_2088
		moveq	#0,d0
		rts	
; ===========================================================================

loc_2088:				; XREF: loc_206A
		move.w	d0,(v_pcyc_num).w
		lea	(Pal_Sega2).l,a0
		lea	(a0,d0.w),a0
		lea	(v_pal1_wat+$04).w,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0)+,(a1)
		lea	(v_pal1_wat+$20).w,a1
		moveq	#0,d0
		moveq	#$2C,d1

loc_20A8:
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_20B2
		addq.w	#2,d0

loc_20B2:
		move.w	(a0),(a1,d0.w)
		addq.w	#2,d0
		dbf	d1,loc_20A8

loc_20BC:
		moveq	#1,d0
		rts	
; End of function PalCycle_Sega

; ===========================================================================

Pal_Sega1:	incbin	"palette\Sega1.bin"
Pal_Sega2:	incbin	"palette\Sega2.bin"

; ---------------------------------------------------------------------------
; Subroutines to load palettes

; input:
;	d0 = index number for palette
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad1:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2	; get palette data address
		movea.w	(a1)+,a3	; get target RAM address
		adda.w	#$80,a3		; skip to "main" RAM address
		move.w	(a1)+,d7	; get length of palette data

	@loop:
		move.l	(a2)+,(a3)+	; move data to RAM
		dbf	d7,@loop
		rts	
; End of function PalLoad1


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad2:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2	; get palette data address
		movea.w	(a1)+,a3	; get target RAM address
		move.w	(a1)+,d7	; get length of palette

	@loop:
		move.l	(a2)+,(a3)+	; move data to RAM
		dbf	d7,@loop
		rts	
; End of function PalLoad2

; ---------------------------------------------------------------------------
; Underwater palette loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad3_Water:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2	; get palette data address
		movea.w	(a1)+,a3	; get target RAM address
		suba.w	#$80,a3		; skip to "main" RAM address
		move.w	(a1)+,d7	; get length of palette data

	@loop:
		move.l	(a2)+,(a3)+	; move data to RAM
		dbf	d7,@loop
		rts	
; End of function PalLoad3_Water


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad4_Water:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2	; get palette data address
		movea.w	(a1)+,a3	; get target RAM address
		suba.w	#$100,a3
		move.w	(a1)+,d7	; get length of palette data

	@loop:
		move.l	(a2)+,(a3)+	; move data to RAM
		dbf	d7,@loop
		rts	
; End of function PalLoad4_Water

; ===========================================================================

		include	"_inc\Palette Pointers.asm"

; ---------------------------------------------------------------------------
; Palette data
; ---------------------------------------------------------------------------
Pal_SegaBG:	incbin	"palette\Sega Background.bin"
Pal_Title:	incbin	"palette\Title Screen.bin"
Pal_LevelSel:	incbin	"palette\Level Select.bin"
Pal_Sonic:	incbin	"palette\Sonic.bin"
Pal_GHZ:	incbin	"palette\Green Hill Zone.bin"
Pal_LZ:		incbin	"palette\Labyrinth Zone.bin"
Pal_LZWater:	incbin	"palette\Labyrinth Zone Underwater.bin"
Pal_MZ:		incbin	"palette\Marble Zone.bin"
Pal_SLZ:	incbin	"palette\Star Light Zone.bin"
Pal_SYZ:	incbin	"palette\Spring Yard Zone.bin"
Pal_SBZ1:	incbin	"palette\SBZ Act 1.bin"
Pal_SBZ2:	incbin	"palette\SBZ Act 2.bin"
Pal_Special:	incbin	"palette\Special Stage.bin"
Pal_SBZ3:	incbin	"palette\SBZ Act 3.bin"
Pal_SBZ3Water:	incbin	"palette\SBZ Act 3 Underwater.bin"
Pal_LZSonWater:	incbin	"palette\Sonic - LZ Underwater.bin"
Pal_SBZ3SonWat:	incbin	"palette\Sonic - SBZ3 Underwater.bin"
Pal_SSResult:	incbin	"palette\Special Stage Results.bin"
Pal_Continue:	incbin	"palette\Special Stage Continue Bonus.bin"
Pal_Ending:	incbin	"palette\Ending.bin"
Pal_HUBZ:	incbin	"palette\HUBZ.bin"
Pal_IntroZ:	incbin	"palette\HUBZ.bin"
Pal_Tropic:	incbin	"palette\Tropic.bin"
Pal_Black:	incbin	"palette\black.bin"

; ---------------------------------------------------------------------------
; Subroutine to	wait for VBlank routines to complete
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WaitForVBla:				; XREF: PauseGame
		move	#$2300,sr

	@wait:
		tst.b	(v_vbla_routine).w 			; has VBlank routine finished?
		bne.s	@wait						; if not, branch
		rts	
; End of function WaitForVBla

		include	"_incObj\sub RandomNumber.asm"
		include	"_incObj\sub CalcSine.asm"
		include	"_incObj\sub CalcAngle.asm"
		include	"_incObj\sub SquareRoot.asm"

; ---------------------------------------------------------------------------
; Sega screen
; ---------------------------------------------------------------------------

GM_Sega:				; XREF: GameModeArray
		move.b	#musFadeOut,d0
		jsr	PlaySound_Special ; stop music
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		lea	($C00004).l,a6
		move.w	#$8004,(a6)	; use 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$8700,(a6)	; set background colour (palette entry 0)
		move.w	#$8B00,(a6)	; full-screen vertical scrolling
		clr.b	(f_wtr_state).w
		move	#$2700,sr
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l
		bsr.w	ClearScreen

       ; test for button held, go to sound test
       if StartupSoundtest=1
		andi.b	#btnABC,(v_jpadhold1).w ; is a button being held?
		beq.s	@nosoundtest	; if not, branch
                move.b  #$04, (v_levselpage).w  ; choose sound test menu
                move.b  #$01, (v_menupagestate).l  ; go straight to menu
                jmp     Pause_Menu               ; go to menu
       @nosoundtest:
                endif
		locVRAM	0
		lea	(Nem_SegaLogo).l,a0 ; load Sega	logo patterns
		bsr.w	NemDec
		lea	($FF0000).l,a1
		lea	(Eni_SegaLogo).l,a0 ; load Sega	logo mappings
		move.w	#0,d0
		bsr.w	EniDec

		copyTilemap	$FF0000,$E510,$17,7
		copyTilemap	$FF0180,$C000,$27,$1B

		if Revision=0
		else
			tst.b   (v_megadrive).w	; is console Japanese?
			bmi.s   @loadpal
			copyTilemap	$FF0A40,$C53A,2,1 ; hide "TM" with a white rectangle
		endc

	@loadpal:
		moveq	#palid_SegaBG,d0
		bsr.w	PalLoad2	; load Sega logo palette
		move.w	#-$A,(v_pcyc_num).w
		move.w	#0,(v_pcyc_time).w
		move.w	#0,(v_pal_buffer+$12).w
		move.w	#0,(v_pal_buffer+$10).w
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l

Sega_WaitPal:
		move.b	#2,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	PalCycle_Sega
		bne.s	Sega_WaitPal

		move.b	#musSegaSound,d0
		jsr	PlaySound_Special ; play "SEGA"	sound
		move.b	#$14,(v_vbla_routine).w
		bsr.w	WaitForVBla
		move.w	#$1E,(v_demolength).w

Sega_WaitEnd:
		move.b	#2,(v_vbla_routine).w
		bsr.w	WaitForVBla
		tst.w	(v_demolength).w
		beq.s	Sega_GotoSSRG
		andi.b	#btnStart,(v_jpadpress1).w ; is Start button pressed?
		beq.s	Sega_WaitEnd	; if not, branch
		
Sega_GotoTitle:
		move.b	#id_Title,(v_gamemode).w ; go to title screen
		rts

Sega_GotoSSRG:
		move.b	#id_SSRG,(v_gamemode).w ; go to SSRG screen
		rts




		include	"SSRG/SSRG.asm"
; ===========================================================================

; ---------------------------------------------------------------------------
; Title	screen
; ---------------------------------------------------------------------------

GM_Title:				; XREF: GameModeArray
		move.b	#musFadeOut,d0
		jsr	PlaySound_Special ; stop music
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		move	#$2700,sr
		bsr.w	SoundDriverLoad
		lea	($C00004).l,a6
		move.w	#$8004,(a6)	; 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$9001,(a6)	; 64-cell hscroll size
		move.w	#$9200,(a6)	; window vertical position
		move.w	#$8B03,(a6)
		move.w	#$8720,(a6)	; set background colour (palette line 2, entry 0)
		clr.b	(f_wtr_state).w
		bsr.w	ClearScreen

		lea	(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1

	Tit_ClrObj1:
		move.l	d0,(a1)+
		dbf	d1,Tit_ClrObj1	; fill object space ($D000-$EFFF) with 0

		locVRAM	0
		lea	(Nem_JapNames).l,a0 ; load Japanese credits
		bsr.w	NemDec
		locVRAM	$14C0
		lea	(Nem_CreditText).l,a0 ;	load alphabet
		bsr.w	NemDec
		lea	($FF0000).l,a1
		lea	(Eni_JapNames).l,a0 ; load mappings for	Japanese credits
		move.w	#0,d0
		bsr.w	EniDec

		copyTilemap	$FF0000,$C000,$27,$1B

		lea	(v_pal1_dry).w,a1
		moveq	#cBlack,d0
		move.w	#$1F,d1

	Tit_ClrPal:
		move.l	d0,(a1)+
		dbf	d1,Tit_ClrPal	; fill palette with 0 (black)

		moveq	#palid_Sonic,d0	; load Sonic's palette
		bsr.w	PalLoad1
		move.b	#id_CreditsText,(v_objspace+$80).w ; load "SONIC TEAM PRESENTS" object
		jsr	ExecuteObjects
		jsr	BuildSprites
		bsr.w	PaletteFadeIn
		move	#$2700,sr
		locVRAM	$4000
		lea	(Nem_TitleFg).l,a0 ; load title	screen patterns
		bsr.w	NemDec
		locVRAM	$6000
		lea	(Nem_TitleSonic).l,a0 ;	load Sonic title screen	patterns
		bsr.w	NemDec
		locVRAM	$A200
		lea	(Nem_TitleTM).l,a0 ; load "TM" patterns
		bsr.w	NemDec
		lea	($C00000).l,a6
		locVRAM	$D000,4(a6)
		lea	(Art_Text).l,a5	; load level select font
		move.w	#$28F,d1

	Tit_LoadText:
		move.w	(a5)+,(a6)
		dbf	d1,Tit_LoadText	; load level select font

		move.b	#0,(v_lastlamp).w ; clear lamppost counter
		move.w	#0,(v_debuguse).w ; disable debug item placement mode
		move.w	#0,(f_demo).w	; disable debug mode
		move.w	#0,($FFFFFFEA).w ; unused variable
		move.w	#0,(v_zone).w	; set level to GHZ (00)
		move.w	#0,(v_pcyc_time).w ; disable palette cycling
		bsr.w	LevelSizeLoad
		bsr.w	DeformLayers
		lea	(v_16x16).w,a1
		lea	(Blk16_GHZ).l,a0 ; load	GHZ 16x16 mappings
		move.w	#0,d0
		bsr.w	EniDec
		lea	(Blk256_GHZ).l,a0 ; load GHZ 256x256 mappings
		lea	(v_256x256).l,a1
		bsr.w	KosDec
		bsr.w	LevelLayoutLoad
		bsr.w	PaletteFadeOut
		move	#$2700,sr
		bsr.w	ClearScreen
                lea	($C00004).l,a5
		lea	($C00000).l,a6
		lea	($FFFFF708).w,a3
	;	lea	(v_lvllayout+$40).w,a4
		movea.l	(v_lvllayout+4).w,a4			; MJ: Load address of layout BG
		move.w	#$6000,d2
		bsr.w	DrawChunks
                lea	($FF0000).l,a1
		lea	(Eni_Title).l,a0 ; load	title screen mappings
		move.w	#0,d0
		bsr.w	EniDec

		copyTilemap	$FF0000,$C206,$21,$15

		locVRAM	0
		lea	(Nem_TIT_1st).l,a0 ; load GHZ patterns
		bsr.w	NemDec
		moveq	#palid_Title,d0	; load title screen palette
		bsr.w	PalLoad1
		move.b	#bgm_Title,d0	; play title screen music
		jsr	PlaySound_Special
		move.b	#0,(f_debugmode).w ; disable debug mode
		move.w	#$21C,(v_demolength).w ; run title screen for $178 frames   +++ changed to 
		lea	(v_objspace+$80).w,a1
; 		moveq	#0,d0
; 		move.w	#7,d1
; 
; 	Tit_ClrObj2:
; 		move.l	d0,(a1)+
; 		dbf	d1,Tit_ClrObj2
                jsr     DeleteChild      ; +++ clear object RAM to make room for the "Press Start Button" object
		move.b	#id_TitleSonic,(v_objspace+$40).w ; load big Sonic object
		move.b	#id_PSBTM,(v_objspace+$80).w ; load "PRESS START BUTTON" object

		if Revision=0
		else
			tst.b   (v_megadrive).w	; is console Japanese?
			bpl.s   @isjap		; if yes, branch
		endc

		move.b	#id_PSBTM,(v_objspace+$C0).w ; load "TM" object
		move.b	#3,(v_objspace+$C0+obFrame).w
	@isjap:
		move.b	#id_PSBTM,(v_objspace+$100).w ; load object which hides part of Sonic
		move.b	#2,(v_objspace+$100+obFrame).w
		jsr	ExecuteObjects
		bsr.w	DeformLayers
		jsr	BuildSprites
		moveq	#plcid_Main,d0
		bsr.w	NewPLC
		move.w	#0,(v_title_dcount).w
		move.w	#0,(v_title_ccount).w
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		bsr.w	PaletteFadeIn

Tit_MainLoop:
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr	ExecuteObjects
		bsr.w	DeformLayers
		jsr	BuildSprites
		bsr.w	PCycle_Title
		bsr.w	RunPLC
		move.w	(v_objspace+obX).w,d0
		addq.w	#2,d0
		move.w	d0,(v_objspace+obX).w ; move Sonic to the right
		cmpi.w	#$1C00,d0	; has Sonic object passed $1C00 on x-axis?
		bcs.s	Tit_ChkRegion	; if not, branch

		move.b	#id_Sega,(v_gamemode).w ; go to Sega screen
		rts	
; ===========================================================================

Tit_ChkRegion:
		tst.b	(v_megadrive).w	; check	if the machine is US or	Japanese
		bpl.s	Tit_RegionJap	; if Japanese, branch

		lea	(LevSelCode_US).l,a0 ; load US code
		bra.s	Tit_EnterCheat

	Tit_RegionJap:
		lea	(LevSelCode_J).l,a0 ; load J code

Tit_EnterCheat:
		move.w	(v_title_dcount).w,d0
		adda.w	d0,a0
		move.b	(v_jpadpress1).w,d0 ; get button press
		andi.b	#btnDir,d0	; read only UDLR buttons
		cmp.b	(a0),d0		; does button press match the cheat code?
		bne.s	Tit_ResetCheat	; if not, branch
		addq.w	#1,(v_title_dcount).w ; next button press
		tst.b	d0
		bne.s	Tit_CountC
		lea	(f_levselcheat).w,a0
		move.w	(v_title_ccount).w,d1
		lsr.w	#1,d1
		andi.w	#3,d1
		beq.s	Tit_PlayRing
		tst.b	(v_megadrive).w
		bpl.s	Tit_PlayRing
		moveq	#1,d1
		move.b	d1,1(a0,d1.w)	; cheat depends on how many times C is pressed

	Tit_PlayRing:
		move.b	#1,(a0,d1.w)	; activate cheat
		move.b	#sfx_Ring,d0	; play ring sound when code is entered
		jsr	PlaySound_Special
		bra.s	Tit_CountC
; ===========================================================================

Tit_ResetCheat:				; XREF: Title_EnterCheat
		tst.b	d0
		beq.s	Tit_CountC
		cmpi.w	#9,(v_title_dcount).w
		beq.s	Tit_CountC
		move.w	#0,(v_title_dcount).w ; reset UDLR counter

Tit_CountC:
		move.b	(v_jpadpress1).w,d0
		andi.b	#btnC,d0	; is C button pressed?
		beq.s	loc_3230	; if not, branch
		addq.w	#1,(v_title_ccount).w ; increment C counter

loc_3230:
		tst.w	(v_demolength).w
		beq.w	GotoDemo
		move.b	(v_jpadpress1).w,d0
		andi.b	#btnB,d0	; is B button pressed?
		beq.w	@notB	; if not, branch
                jmp     LoadGame
       @notB:
		andi.b	#btnStart,(v_jpadpress1).w ; check if Start is pressed
		beq.w	Tit_MainLoop	; if not, branch

Tit_ChkLevSel:
		tst.b	(f_levselcheat).w ; check if level select code is on
		beq.w	PlayLevel	; if not, play level
		jmp	 Level_Select_Menu; Go to Sonic 2 Level Select        +++

PlayLevel:
		move.b	#id_Level,(v_gamemode).w ; set screen mode to $0C (level)
		move.b	#3,(v_lives).w	; set lives to 3
		moveq	#0,d0
		move.w	d0,(v_rings).w	; clear rings
		move.l	d0,(v_time).w	; clear time
		move.l	d0,(v_score).w	; clear score
		move.b	d0,(v_lastspecial).w ; clear special stage number
		move.b	d0,(v_emeralds).w ; clear emeralds
		move.l	d0,(v_emldlist).w ; clear emeralds
		move.l	d0,(v_emldlist+4).w ; clear emeralds
		move.b	d0,(v_continues).w ; clear continues
		move.b  #1,(v_abil_none).w ; give the "no ability" ability
		move.b  #1,(v_shoe_default).w ; give default shoes
		move.b  #aNoAbility,(v_a_ability).w
		move.b  #aNoAbility,(v_b_ability).w
		move.b  #aNoAbility,(v_c_ability).w
		move.b  #sDefault,(v_equippedshoes).w
		move.b  #iNoItem,(v_equippeditem1).w
		move.b  #iNoItem,(v_equippeditem2).w
		move.b  #eDefault,(v_equippedemerald).w

		move.b  #1,(f_debugcheat).w ; TESTING, enable debug mode, remove this line for release!!!

                move    #$2700, SR                    ; interrupt mask level 7
                gotoSRAM
		lea	($200001).l,a1	; start of SRAM
                moveq	#0,d1
                moveq	#$3F,d1		; assuming SRAM is from $200001 to $2001FF and is odd addresses only
                moveq	#0,d0

ClrSRAMLoop:
	        movep.l	d0,0(a1)
	        addq.l	#8,a1	; since every other byte is skipped we add 8 instead of 4
	        dbf	d1,ClrSRAMLoop
                gotoROM
                move    #$2300, SR                    ; interrupt mask level 3

		if Revision=0
		else
			move.l	#5000,(v_scorelife).w ; extra life is awarded at 50000 points
		endc
		move.b	#musFadeOut,d0
		jsr	PlaySound_Special ; fade out music
		rts

; ---------------------------------------------------------------------------
; Level	select codes
; ---------------------------------------------------------------------------
LevSelCode_J:	if Revision=0
		dc.b btnUp,btnDn,btnL,btnR,0,$FF
		else
		dc.b btnUp,btnDn,btnDn,btnDn,btnL,btnR,0,$FF
		endc
		even

LevSelCode_US:	dc.b btnUp,btnDn,btnL,btnR,0,$FF
		even
; ===========================================================================

; ---------------------------------------------------------------------------
; Demo mode
; ---------------------------------------------------------------------------

GotoDemo:				; XREF: GM_Title
		move.w	#$1E,(v_demolength).w

loc_33B6:				; XREF: loc_33E4
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	DeformLayers
		bsr.w	PaletteCycle
		bsr.w	RunPLC
		move.w	(v_objspace+obX).w,d0
		addq.w	#2,d0
		move.w	d0,(v_objspace+obX).w
		cmpi.w	#$1C00,d0
		bcs.s	loc_33E4
		move.b	#id_Sega,(v_gamemode).w
		rts	
; ===========================================================================

loc_33E4:
		andi.b	#btnStart,(v_jpadpress1).w ; is Start button pressed?
		bne.w	Tit_ChkLevSel	; if yes, branch
		tst.w	(v_demolength).w
		bne.w	loc_33B6
		move.b	#musFadeOut,d0
		jsr	PlaySound_Special ; fade out music
		move.w	(v_demonum).w,d0 ; load	demo number
		andi.w	#7,d0
		add.w	d0,d0
		move.w	Demo_Levels(pc,d0.w),d0	; load level number for	demo
		move.w	d0,(v_zone).w
		addq.w	#1,(v_demonum).w ; add 1 to demo number
		cmpi.w	#4,(v_demonum).w ; is demo number less than 4?
		bcs.s	loc_3422	; if yes, branch
		move.w	#0,(v_demonum).w ; reset demo number to	0

loc_3422:
		move.w	#1,(f_demo).w	; turn demo mode on
		move.b	#id_Demo,(v_gamemode).w ; set screen mode to 08 (demo)
		cmpi.w	#$600,d0	; is level number 0600 (special	stage)?
		bne.s	Demo_Level	; if not, branch
		move.b	#id_Special,(v_gamemode).w ; set screen mode to $10 (Special Stage)
		clr.w	(v_zone).w	; clear	level number
		clr.b	(v_lastspecial).w ; clear special stage number

Demo_Level:
		move.b	#3,(v_lives).w	; set lives to 3
		moveq	#0,d0
		move.w	d0,(v_rings).w	; clear rings
		move.l	d0,(v_time).w	; clear time
		move.l	d0,(v_score).w	; clear score
		if Revision=0
		else
			move.l	#5000,(v_scorelife).w ; extra life is awarded at 50000 points
		endc
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Levels used in demos
; ---------------------------------------------------------------------------
Demo_Levels:	incbin	"misc\Demo Level Order - Intro.bin"
		even


; ---------------------------------------------------------------------------
; Music	playlists,
; ---------------------------------------------------------------------------
MusicList1:	dc.b bgm_GHZ, bgm_LZ, bgm_MZ, bgm_SLZ, bgm_SYZ, bgm_SBZ, bgm_FZ, bgm_HUBZ, bgm_IntroZ, bgm_Tropic     ; +++ act 1
		even
MusicList2:	dc.b bgm_GHZ, bgm_LZ, bgm_MZ, bgm_SLZ, bgm_SYZ, bgm_SBZ, bgm_FZ, bgm_HUBZ, bgm_IntroZ, bgm_Tropic     ; +++ act 2
		even
MusicList3:	dc.b bgm_GHZ, bgm_LZ, bgm_MZ, bgm_SLZ, bgm_SYZ, bgm_FZ, bgm_FZ, bgm_HUBZ, bgm_IntroZ, bgm_Tropic     ; +++ act 3
		even
MusicList4:	dc.b bgm_GHZ, bgm_SBZ, bgm_MZ, bgm_SLZ, bgm_SYZ, bgm_SBZ, bgm_FZ, bgm_HUBZ, bgm_IntroZ, bgm_Tropic     ; +++ act 4
		even

; ===========================================================================

; ---------------------------------------------------------------------------
; Level             level load stuff is here i think
; ---------------------------------------------------------------------------

GM_Level:				; XREF: GameModeArray
		bset	#7,(v_gamemode).w ; add $80 to screen mode (for pre level sequence)
		tst.w	(f_demo).w
		bmi.s	Level_NoMusicFade
 		tst.w	(f_dontstopmusic).w    ; +++
		bne.s	Level_NoMusicFade      ; +++
		move.b	#musFadeOut,d0
		jsr		PlaySound_Special ; fade out music

	Level_NoMusicFade:
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		tst.w	(f_demo).w	; is an ending sequence demo running?
		bmi.s	Level_ClrRam	; if yes, branch
		move	#$2700,sr
 		tst.w	(f_dontstopmusic).w     ; +++ TESTING
		bne.w	Level_ClrRam	        ; +++ IF YOU DON'T NEED TO RELOAD GRAPHICS, THEN DON'T >:(

	writeVRAM Art_TitleCard, $1000, $B000

		move	#$2300,sr
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#4,d0
		lea		(LevelHeaders).l,a2
		lea		(a2,d0.w),a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	loc_37FC
		bsr.w	AddPLC		; load level patterns

loc_37FC:
		moveq	#plcid_Main2,d0
		bsr.w	AddPLC		; load standard	patterns
; --------------------------------------------------------------------------
Level_ClrRam:
		lea		(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
	Level_ClrObjRam:
		move.l	d0,(a1)+
		dbf		d1,Level_ClrObjRam ; clear object RAM
; --------------------------------------------------------------------------
		lea		($FFFFF628).w,a1
		moveq	#0,d0
		move.w	#$15,d1
	Level_ClrVars1:
		move.l	d0,(a1)+
		dbf		d1,Level_ClrVars1 ; clear misc variables
; --------------------------------------------------------------------------
		lea		(v_screenposx).w,a1
		moveq	#0,d0
		move.w	#$3F,d1
	Level_ClrVars2:
		move.l	d0,(a1)+
		dbf		d1,Level_ClrVars2 ; clear misc variables
; --------------------------------------------------------------------------
		lea		(v_oscillate+2).w,a1
		moveq	#0,d0
		move.w	#$47,d1
	Level_ClrVars3:
		move.l	d0,(a1)+
		dbf		d1,Level_ClrVars3 ; clear object variables
; --------------------------------------------------------------------------
		move	#$2700,sr
		bsr.w	ClearScreen
		lea		($C00004).l,a6
		move.w	#$8B03,(a6)					; line scroll mode
		move.w	#$8200+(vram_fg>>10),(a6) 	; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) 	; set background nametable address
		move.w	#$8500+(vram_sprites>>9),(a6) ; set sprite table address
		move.w	#$9001,(a6)					; 64-cell hscroll size
		move.w	#$8004,(a6)					; 8-colour mode
		move.w	#$8720,(a6)					; set background colour (line 3; colour 0)
		move.w	#$8A00+223,(v_hbla_hreg).w 	; set palette change position (for water)
		move.w	(v_hbla_hreg).w,(a6)
		clr.w	(v_sgfx_buffer).w			; +++ ProcessDMAQueue crap
		move.w	#v_sgfx_buffer,(v_vdp_buffer_slot).w   ; +++

LoadMonitorSRAM:
		cmpi.b	#id_LZ,(v_zone).w ; is level LZ?
		bne.s	Level_LoadPal	; if not, branch
		move	#$2700,sr
		move.w	#$8014,(a6)	; enable H-interrupts
		moveq	#0,d0
		move.b	(v_act).w,d0
		add.w	d0,d0
		lea		(WaterHeight).l,a1 ; load water	height array
		move.w	(a1,d0.w),d0
		move.w	d0,(v_waterpos1).w ; set water heights
		move.w	d0,(v_waterpos2).w
		move.w	d0,(v_waterpos3).w
		clr.b	(v_wtr_routine).w ; clear water routine counter
		clr.b	(f_wtr_state).w	; clear	water state
 		move.b	#1,(f_water).w	; enable water

; 		move.w	#$4EF9,(H_int_jump).w   ;"jmp" in machine code (h-int runs this)
 ;		move.l	#HBlank2,(H_int_addr).w  ; hblank code address to jump to
 ;		move.w	#$8014,($C00004).l	; enable H-interrupts
;		move.w	#$8A00+24,(v_hbla_hreg).w ; set palette change position (for water)

Level_LoadPal:
		move.w	#30,(v_air).w
		move	#$2300,sr
		moveq	#palid_Sonic,d0
		bsr.w	PalLoad2	; load Sonic's palette
		cmpi.b	#id_LZ,(v_zone).w ; is level LZ?
		bne.w	Level_GetBgm	; if not, branch

		moveq	#palid_LZSonWater,d0 ; palette number $F (LZ)
		cmpi.b	#3,(v_act).w	; is act number 3?
		bne.w	Level_WaterPal	; if not, branch
		moveq	#palid_SBZ3SonWat,d0 ; palette number $10 (SBZ3)

	Level_WaterPal:
		bsr.w	PalLoad3_Water	; load underwater palette
		tst.b	(v_lastlamp).w
		beq.w	Level_GetBgm
		move.b	($FFFFFE53).w,(f_wtr_state).w

; Level_GetBgm:
; 		tst.w	(f_demo).w
; 		bmi.s	Level_SkipTtlCard
; 		moveq	#0,d0
; 		move.b	(v_zone).w,d0
; 		cmpi.w	#(id_LZ<<8)+3,(v_zone).w ; is level SBZ3?
; 		bne.s	Level_BgmNotLZ4	; if not, branch
; 		moveq	#5,d0		; use 5th music (SBZ)
; 
; 	Level_BgmNotLZ4:
; 		cmpi.w	#(id_SBZ<<8)+2,(v_zone).w ; is level FZ?
; 		bne.s	Level_PlayBgm	; if not, branch
; 		moveq	#6,d0		; use 6th music (FZ)
; 
; 	Level_PlayBgm:
; 		lea	(MusicList).l,a1 ; load	music playlist
; 		move.b	(a1,d0.w),d0
; 		bsr.w	PlaySound	; play music
; 		move.b	#id_TitleCard,(v_objspace+$80).w ; load title card object

; +++ NineKode begins here - How to play different songs on different acts
 
Level_GetBgm:
		tst.w	(f_demo).w
		bmi.w	Level_SkipTtlCard	; change from bmi.s to bmi.w or you'll get an error
; 		tst.w	(f_leavemenu).w
; 		bne.w	Level_SkipClr	; change from bmi.s to bmi.w or you'll get an error
		tst.w	(f_dontstopmusic).w
		bne.w	Level_TtlCardLoop	; change from bmi.s to bmi.w or you'll get an error
		move.b	#id_TitleCard,(v_objspace+$80).w ; load title	card object

		moveq	#0,d0
		move.b	(v_zone).w,d0

		cmpi.b	#$0,(v_act).w	; is this act 1?
		bne.s	Level_GetBgm2	; if not, branch
		lea	(MusicList1).l,a1	; load Music Playlist for Acts 1
		bra.s	Level_PlayBgm	; go to PlayBgm
 
Level_GetBgm2:
		cmpi.b	#$1,(v_act).w	; is this act 2?
		bne.s	Level_GetBgm3	; if not, branch
		lea	(MusicList2).l,a1	; load Music Playlist for Acts 2
		bra.s	Level_PlayBgm	; go to PlayBgm
 
Level_GetBgm3:
		cmpi.b	#$2,(v_act).w	; is this act 3?
		bne.s	Level_GetBgm4	; if not, branch
		lea	(MusicList3).l,a1	; load Music Playlist for Acts 3
		bra.s	Level_PlayBgm	; go to PlayBgm
 
Level_GetBgm4:
		cmpi.b	#$3,(v_act).w	; is this act 4?
		bne.s	Level_PlayBgm	; if not, branch
		lea	(MusicList4).l,a1	; load Music Playlist for Acts 4
 
Level_PlayBgm:
                move.b	(a1,d0.w),d0	; get d0-th entry from the playlist
		move.w	d0,(v_lastmusic).w	; store level music
		jsr		PlaySound	; play music
		move.b	#id_TitleCard,(v_objspace+$80).w ; load title	card object

; NineKode ends here

Level_TtlCardLoop:
                clr.b   (f_dontstopmusic).w    ; reset the music continue flag
		move.b	#$C,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr		ExecuteObjects
		jsr		BuildSprites
		bsr.w	RunPLC
		move.w	(v_objspace+$108).w,d0
		cmp.w	(v_objspace+$130).w,d0 	; has title card sequence finished?
		bne.s	Level_TtlCardLoop 		; if not, branch
		tst.l	(v_plc_buffer).w		; are there any items in the pattern load cue?
		bne.s	Level_TtlCardLoop 		; if yes, branch
		jsr		Hud_Base				; load basic HUD gfx

	Level_SkipTtlCard:
		moveq	#palid_Sonic,d0
		bsr.w	PalLoad1				; load Sonic's palette
		bsr.w	LevelSizeLoad
		bsr.w	DeformLayers
		bset	#2,(v_bgscroll1).w
		move.w  #$2300,sr
		bsr.w	LoadZoneTiles			; load level art
		bsr.w	LevelDataLoad 			; load block mappings and palettes
		bsr.w	LoadTilesFromStart
		bsr.w	ColIndexLoad
		move.w  #$2700,sr
		bsr.w	LZWaterFeatures
		move.b	#id_SonicPlayer,(v_objspace).w ; load Sonic object
		jsr		Check_TeleportIntro
		tst.w	(f_demo).w
		bmi.s	Level_ChkWater
		move.b	#id_HUD,(v_objspace+$40).w ; load HUD object

Level_ChkWater:
		move.w	#0,(v_jpadhold2).w
		move.w	#0,(v_jpadhold1).w
		cmpi.b	#id_LZ,(v_zone).w 		; is level LZ?
		bne.s	Level_LoadObj			; if not, branch
		move.b	#id_WaterSurface,(v_objspace+$780).w ; load water surface object
		move.w	#$60,(v_objspace+$780+obX).w
		move.b	#id_WaterSurface,(v_objspace+$7C0).w
		move.w	#$120,(v_objspace+$7C0+obX).w

Level_LoadObj:
		jsr		CreateMonitorArray
		jsr     LoadState				; Load act's state from SRAM
		jsr		ObjPosLoad
		jsr		ExecuteObjects
		jsr		BuildSprites
		moveq	#0,d0
		tst.b	(v_lastlamp).w			; are you starting from	a lamppost?
		bne.s	Level_SkipClr			; if yes, branch
	;	move.w	d0,(v_rings).w			; +++ clear rings (commented out, retain rings)
	;	move.l	d0,(v_time).w			; clear time
	;	move.b	d0,(v_lifecount).w 		; clear lives counter
	;	move.b	d0,(f_timeover).w
		move.b	d0,(v_shield).w			; clear shield
		move.b	d0,(v_invinc).w			; clear invincibility
		move.b	d0,(v_shoes).w			; clear speed shoes
		move.b	d0,($FFFFFE2F).w

Level_SkipClr:
		cmpi.b  #$FF,(v_lastlamp).w   	; are you transitioning between acts?
		bne.s   @dontclearlamppost  	; if not, branch
		clr.b   (v_lastlamp).w      	; clear lamp post
	@dontclearlamppost:
		cmpi.b  #$80,(v_lastlamp).w   	; are you coming back from a special stage?
		blt.s   @notfromSS
		subi.b  #$80,(v_lastlamp).w   	; set the last lamppost data back to normal
	@notfromSS:
		move.b	d0,(f_timeover).w
		move.w	d0,(v_debuguse).w
		move.w	d0,(f_restart).w
		move.w	d0,(v_framecount).w
		bsr.w	OscillateNumInit
		jsr		GetWorldMapCoOrds
		move.b	#1,(f_scorecount).w ; update score counter
		move.b	#1,(f_ringcount).w ; update rings counter
		move.b	#1,(f_timecount).w ; update time counter
		move.w	#0,(v_btnpushtime1).w
		lea	(DemoDataPtr).l,a1 ; load demo data
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1
		tst.w	(f_demo).w	; is demo mode on?
		bpl.s	Level_Demo	; if yes, branch
		lea	(DemoEndDataPtr).l,a1 ; load ending demo data
		move.w	(v_creditsnum).w,d0
		subq.w	#1,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1

Level_Demo:
		move.b	1(a1),(v_btnpushtime2).w ; load key press duration
		subq.b	#1,(v_btnpushtime2).w ; subtract 1 from duration
		move.w	#1800,(v_demolength).w
		tst.w	(f_demo).w
		bpl.s	Level_ChkWaterPal
		move.w	#540,(v_demolength).w
		cmpi.w	#4,(v_creditsnum).w
		bne.s	Level_ChkWaterPal
		move.w	#510,(v_demolength).w

Level_ChkWaterPal:
		cmpi.b	#id_LZ,(v_zone).w ; is level LZ/SBZ3?
		bne.s	Level_Delay	; if not, branch
		moveq	#palid_LZWater,d0 ; palette $B (LZ underwater)
		cmpi.b	#3,(v_act).w	; is level SBZ3?
		bne.s	Level_WtrNotSbz	; if not, branch
		moveq	#palid_SBZ3Water,d0 ; palette $D (SBZ3 underwater)

	Level_WtrNotSbz:
		bsr.w	PalLoad4_Water

Level_Delay:
		move.w	#3,d1

	Level_DelayLoop:
		move.b	#8,(v_vbla_routine).w
		bsr.w	WaitForVBla
		dbf	d1,Level_DelayLoop

		move.w	#$202F,(v_pfade_start).w ; fade in 2nd, 3rd & 4th palette lines
		bsr.w	PalFadeIn_Alt
		tst.w	(f_demo).w	; is an ending sequence demo running?
		bmi.w	Level_ClrCardArt ; if yes, branch  +++ was bmi.s
		addq.b	#2,(v_objspace+$80+obRoutine).w ; make title card move
		addq.b	#4,(v_objspace+$C0+obRoutine).w
		addq.b	#4,(v_objspace+$100+obRoutine).w
                addq.b	#4,(v_objspace+$140+obRoutine).w
		bra.s	Level_StartGame
; ===========================================================================

Level_ClrCardArt:
		jsr	(LoadAnimalExplosion).l ; load animal patterns
		
Level_StartGame:
		bclr	#7,(v_gamemode).w ; subtract $80 from mode to end pre-level stuff

; ---------------------------------------------------------------------------
; Main level loop (when	all title card and loading sequences are finished)
; ---------------------------------------------------------------------------

Level_MainLoop:
		cmpi.b  #id_GotPowUpCard,(v_objspace+$5C0).w	; is powerup card active?
		beq.w   PowerupCardLoop				; go to it's own loop
		tst.b	(v_objspace+$5C0).w			; is powerup card active?
		bne.w   PowerupCardLoop				; go to it's own loop
		bsr.w	PauseGame
	; change the background colour, for a pretty basic kind of cpu meter	
;		tst.w	(f_debugmode).w	                    ; is debug mode being used?
;		beq.s	@vbla_wait	                     	; if no, branch
;		move.w	#$8C89,($C00004).l	; H res 40 cells, no interlace, S/H enabled
;	@vbla_wait:	
		move.b	#8,(v_vbla_routine).w
		jsr	(Process_Kos_Queue).l	
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w			; add 1 to level timer
;		move.w	#$8C81,($C00004).l			; H res 40 cells, no interlace, S/H disabled
;		bsr.w	MoveSonicInDemo
		bsr.w	LZWaterFeatures
		bsr.w	GrindRails		
		jsr	ExecuteObjects

		tst.w   (f_restart).w                        ; is restart flag set?
		bne     GM_Level                             ; reload level

		tst.w	(v_debuguse).w	                     ; is debug mode being used?
		bne.s	Level_DoScroll	                     ; if yes, branch
		cmpi.b	#6,(v_player+obRoutine).w            ; has Sonic just died?
		bcc.s	Level_SkipScroll                     ; if yes, branch
	Level_DoScroll:
		bsr.w	DeformLayers

	Level_SkipScroll:
		jsr	BuildSprites
		jsr	ObjPosLoad
		bsr.w	PaletteCycle
		bsr.w	RunPLC
		jsr	(Process_Kos_Module_Queue).l
		bsr.w	OscillateNumDo
		bsr.w	SynchroAnimate
		jsr	RevealMapTile
;		bsr.w	SignpostArtLoad

;		cmpi.b	#id_Demo,(v_gamemode).w
;		beq.w	Level_ChkDemo	                     ; if mode is 8 (demo), branch
		cmpi.b	#id_Level,(v_gamemode).w
		beq.w	Level_MainLoop	                     ; if mode is $C (level), branch
		rts
; ===========================================================================
PowerupCardLoop:
		move.b	#$1A,(v_vbla_routine).w       		; vblank routune without loadtilesasyoumove         
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w                  ; add 1 to level timer

                cmpi.b  #id_GotPowUpCard,(v_objspace+$5C0+$40).w ; has powerup card created a child object?
                beq.s   @executesomeobjects                  ; if so, we don't want to run most objects
                jsr     ExecuteObjects                       ; run all objects, (mostly so that explosions can disappear)
;		bsr.w	DeformLayers                         ; keep scrolling
                bra.s   @scrollingfinished                   ; skip the scrolling
; --------------------------------------------------------------------------
       @executesomeobjects:
		lea	(v_objspace+$40).w,a0                ; set address for object RAM (skiping sonic)
		moveq	#0,d0
		moveq	#$1F,d7                              ; was $1F, skipping sonic now though
		jsr	RunObject                            ; run the first $1F objects normally

		moveq	#$5F,d7
                jsr     RunObjectDisplayOnly                 ; just run DisplaySprite for the other $5F objects

		lea	(v_player).w,a0
		jsr	DisplaySprite                        ; draw Sonic
; --------------------------------------------------------------------------
@scrolling:
        ; first make sure it starts scrolling on the tile boundary
		move.w  (v_screenposy).w,d0
		andi.w	#$7,d0               ; round down
		neg.w	d0
		addi.w	#$8,d0
		asl.w   #2,d0                ; double because table is stored as planes a,b,a,b,etc
		add.w   #$80,d0              ; how far down the screen to start scrolling  (4 more tile rows * 8px per row * 2 because of the two planes)
		lea	(v_scrolltable).w,a1
		adda.w	d0,a1
		moveq   #$1B,d1              ; lines to scroll
	@scrolltop:
                add.w   #2,(a1)              ; scroll 2 pixels per frame
                lea     4(a1),a1             ; next line
                dbf     d1,@scrolltop

		moveq   #$1B,d1              ; lines to scroll
	@scrollbottom:
                sub.w   #2,(a1)              ; scroll 2 pixels per frame
                lea     4(a1),a1             ; next line
                dbf     d1,@scrollbottom

@scrollingfinished:
		jsr	BuildSprites
		bsr.w	PaletteCycle
		bsr.w	RunPLC

		cmpi.b	#id_Level,(v_gamemode).w
		beq.w	Level_MainLoop	; if mode is $C (level), branch
                rts
; ===========================================================================
Level_ChkDemo:
		tst.w	(f_restart).w	; is level set to restart?
		bne.s	Level_EndDemo	; if yes, branch
		tst.w	(v_demolength).w ; is there time left on the demo?
		beq.s	Level_EndDemo	; if not, branch
		cmpi.b	#id_Demo,(v_gamemode).w
		beq.w	Level_MainLoop	; if mode is 8 (demo), branch
		move.b	#id_Sega,(v_gamemode).w ; go to Sega screen
		rts	
; ===========================================================================

Level_EndDemo:
		cmpi.b	#id_Demo,(v_gamemode).w
		bne.s	Level_FadeDemo	; if mode is 8 (demo), branch
		move.b	#id_Sega,(v_gamemode).w ; go to Sega screen
		tst.w	(f_demo).w	; is demo mode on & not ending sequence?
		bpl.s	Level_FadeDemo	; if yes, branch
		move.b	#id_Credits,(v_gamemode).w ; go to credits

Level_FadeDemo:
		move.w	#$3C,(v_demolength).w
		move.w	#$3F,(v_pfade_start).w
		clr.w	(v_palchgspeed).w

	Level_FDLoop:
		move.b	#8,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	MoveSonicInDemo
		jsr	ExecuteObjects
		jsr	BuildSprites
		jsr	ObjPosLoad
		subq.w	#1,(v_palchgspeed).w
		bpl.s	loc_3BC8
		move.w	#2,(v_palchgspeed).w
		bsr.w	FadeOut_ToBlack

loc_3BC8:
		tst.w	(v_demolength).w
		bne.s	Level_FDLoop
		rts	
; ===========================================================================

		include	"_inc\LZWaterFeatures.asm"
		include	"_inc\MoveSonicInDemo.asm"

; ---------------------------------------------------------------------------
; Collision index pointer loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ColIndexLoad:				; XREF: GM_Level
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#$03,d0					; MJ: multiply by 8 not 4
		move.l	ColPointers(pc,d0.w),($FFFFFFD0).w	; MJ: get first collision set
		add.w	#$04,d0					; MJ: increase to next location
		move.l	ColPointers(pc,d0.w),($FFFFFFD4).w	; MJ: get second collision set
		lsl.w	#2,d0
		move.l	ColPointers(pc,d0.w),(v_collindex).w
		rts	
; End of function ColIndexLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Collision index pointers
; ---------------------------------------------------------------------------
ColPointers:; 	dc.l Col_GHZ
; 		dc.l Col_LZ
; 		dc.l Col_MZ
; 		dc.l Col_SLZ
; 		dc.l Col_SYZ
; 		dc.l Col_SBZ
	dc.l Col_GHZ_1                    ; MJ:
	dc.l Col_GHZ_2
	dc.l Col_LZ_1
	dc.l Col_LZ_2
	dc.l Col_MZ_1
	dc.l Col_MZ_2
	dc.l Col_SLZ_1
	dc.l Col_SLZ_2
	dc.l Col_SYZ_1
	dc.l Col_SYZ_2
	dc.l Col_SBZ_1
	dc.l Col_SBZ_2
	dc.l Col_GHZ_1                    ; ending
	dc.l Col_GHZ_2
	dc.l Col_HUBZ_1
	dc.l Col_HUBZ_2
	dc.l Col_IntroZ_1
	dc.l Col_IntroZ_2
	dc.l Col_Tropic_1
	dc.l Col_Tropic_2
		include	"_inc\Oscillatory Routines.asm"

; ---------------------------------------------------------------------------
; Subroutine to	change synchronised animation variables (rings, giant rings)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SynchroAnimate:				; XREF: GM_Level

; Used for GHZ spiked log
Sync1:
		subq.b	#1,(v_ani0_time).w ; has timer reached 0?
		bpl.s	Sync2		; if not, branch
		move.b	#$B,(v_ani0_time).w ; reset timer
		subq.b	#1,(v_ani0_frame).w ; next frame
		andi.b	#7,(v_ani0_frame).w ; max frame is 7

; Used for rings and giant rings
Sync2:
		subq.b	#1,(v_ani1_time).w
		bpl.s	Sync3
		move.b	#7,(v_ani1_time).w
		addq.b	#1,(v_ani1_frame).w
		andi.b	#3,(v_ani1_frame).w

; Used for nothing
Sync3:
		subq.b	#1,(v_ani2_time).w
		bpl.s	Sync4
		move.b	#7,(v_ani2_time).w
		addq.b	#1,(v_ani2_frame).w
		cmpi.b	#6,(v_ani2_frame).w
		bcs.s	Sync4
		move.b	#0,(v_ani2_frame).w

; Used for bouncing rings
Sync4:
		tst.b	(v_ani3_time).w
		beq.s	SyncEnd
		moveq	#0,d0
		move.b	(v_ani3_time).w,d0
		add.w	(v_ani3_buf).w,d0
		move.w	d0,(v_ani3_buf).w
		rol.w	#7,d0
		andi.w	#3,d0
		move.b	d0,(v_ani3_frame).w
		subq.b	#1,(v_ani3_time).w

SyncEnd:
		rts	
; End of function SynchroAnimate

; ---------------------------------------------------------------------------
; End-of-act signpost pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SignpostArtLoad:			; XREF: GM_Level
		tst.w	(v_debuguse).w	; is debug mode	being used?
		bne.w	@exit		; if yes, branch
		cmpi.b	#2,(v_act).w	; is act number 02 (act 3)?
		beq.s	@exit		; if yes, branch
                cmpi.w	#$0301,(v_zone).w; is green hill act 1 or 2        +++
		ble.s	@exit		; if yes, branch

		move.w	(v_screenposx).w,d0
		move.w	(v_limitright2).w,d1
		subi.w	#$100,d1
		cmp.w	d1,d0		; has Sonic reached the	edge of	the level?
		blt.s	@exit		; if not, branch
		tst.b	(f_timecount).w
		beq.s	@exit
		cmp.w	(v_limitleft2).w,d1
		beq.s	@exit
		move.w	d1,(v_limitleft2).w ; move left boundary to current screen position
		moveq	#plcid_Signpost,d0
		bra.w	NewPLC		; load signpost	patterns

	@exit:
		rts	
; End of function SignpostArtLoad

; ===========================================================================
Demo_GHZ:	incbin	"demodata\Intro - GHZ.bin"
Demo_MZ:	incbin	"demodata\Intro - MZ.bin"
Demo_SYZ:	incbin	"demodata\Intro - SYZ.bin"
Demo_SS:	incbin	"demodata\Intro - Special Stage.bin"
; ===========================================================================

; ---------------------------------------------------------------------------
; Special Stage
; ---------------------------------------------------------------------------

GM_Special:				; XREF: GameModeArray
		move.w	#sfx_EnterSS,d0
		jsr	PlaySound_Special ; play special stage entry sound
		bsr.w	PaletteWhiteOut
		move	#$2700,sr
		lea	($C00004).l,a6
		move.w	#$8B03,(a6)	; line scroll mode
		move.w	#$8004,(a6)	; 8-colour mode
		move.w	#$8A00+175,(v_hbla_hreg).w
		move.w	#$9011,(a6)	; 128-cell hscroll size
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l
		bsr.w	ClearScreen
		move	#$2300,sr
		fillVRAM	0,$6FFF,$5000

	SS_WaitForDMA:
		move.w	(a5),d1		; read control port ($C00004)
		btst	#1,d1		; is DMA running?
		bne.s	SS_WaitForDMA	; if yes, branch
		move.w	#$8F02,(a5)	; set VDP increment to 2 bytes
		bsr.w	SS_BGLoad
		moveq	#plcid_SpecialStage,d0
		bsr.w	QuickPLC	; load special stage patterns

		lea	(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
	SS_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,SS_ClrObjRam	; clear	the object RAM

		lea	(v_screenposx).w,a1
		moveq	#0,d0
		move.w	#$3F,d1
	SS_ClrRam1:
		move.l	d0,(a1)+
		dbf	d1,SS_ClrRam1	; clear	variables

		lea	(v_oscillate+2).w,a1
		moveq	#0,d0
		move.w	#$27,d1
	SS_ClrRam2:
		move.l	d0,(a1)+
		dbf	d1,SS_ClrRam2	; clear	variables

		lea	(v_ngfx_buffer).w,a1
		moveq	#0,d0
		move.w	#$7F,d1
	SS_ClrNemRam:
		move.l	d0,(a1)+
		dbf	d1,SS_ClrNemRam	; clear	Nemesis	buffer

		clr.b	(f_wtr_state).w
		clr.w	(f_restart).w
		moveq	#palid_Special,d0
		bsr.w	PalLoad1	; load special stage palette
		jsr	SS_Load		; load SS layout data
		move.l	#0,(v_screenposx).w
		move.l	#0,(v_screenposy).w
		move.b	#9,(v_objspace).w ; load special stage Sonic object
		bsr.w	PalCycle_SS
		clr.w	(v_ssangle).w	; set stage angle to "upright"
		move.w	#$40,(v_ssrotate).w ; set stage rotation speed
		move.w	#bgm_SS,d0
		jsr	PlaySound	; play special stage BG	music
		move.w	#0,(v_btnpushtime1).w
		lea	(DemoDataPtr).l,a1
		moveq	#6,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1
		move.b	1(a1),(v_btnpushtime2).w
		subq.b	#1,(v_btnpushtime2).w
		clr.w	(v_rings).w
		clr.b	(v_lifecount).w
		move.w	#0,(v_debuguse).w
		move.w	#1800,(v_demolength).w
		tst.b	(f_debugcheat).w ; has debug cheat been entered?
		beq.s	SS_NoDebug	; if not, branch
		btst	#bitA,(v_jpadhold1).w ; is A button pressed?
		beq.s	SS_NoDebug	; if not, branch
		move.b	#1,(f_debugmode).w ; enable debug mode

	SS_NoDebug:
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		bsr.w	PaletteWhiteIn

; ---------------------------------------------------------------------------
; Main Special Stage loop
; ---------------------------------------------------------------------------

SS_MainLoop:
		bsr.w	PauseGame
		move.b	#$A,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	MoveSonicInDemo
		move.w	(v_jpadhold1).w,(v_jpadhold2).w
		jsr	ExecuteObjects
		jsr	BuildSprites
		jsr	SS_ShowLayout
		bsr.w	SS_BGAnimate
		tst.w	(f_demo).w	; is demo mode on?
		beq.s	SS_ChkEnd	; if not, branch
		tst.w	(v_demolength).w ; is there time left on the demo?
		beq.w	SS_ToSegaScreen	; if not, branch

	SS_ChkEnd:
		cmpi.b	#id_Special,(v_gamemode).w ; is game mode $10 (special stage)?
		beq.w	SS_MainLoop	; if yes, branch

		tst.w	(f_demo).w	; is demo mode on?
		if Revision=0
		bne.w	SS_ToSegaScreen	; if yes, branch
		else
		bne.w	SS_ToLevel
		endc
		move.b	#id_Level,(v_gamemode).w ; set screen mode to $0C (level)
		cmpi.w	#(id_SBZ<<8)+3,(v_zone).w ; is level number higher than FZ?
		bcs.s	SS_Finish	; if not, branch
		clr.w	(v_zone).w	; set to GHZ1

SS_Finish:
		move.w	#60,(v_demolength).w ; set delay time to 1 second
		move.w	#$3F,(v_pfade_start).w
		clr.w	(v_palchgspeed).w

	SS_FinLoop:
		move.b	#$16,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	MoveSonicInDemo
		move.w	(v_jpadhold1).w,(v_jpadhold2).w
		jsr	ExecuteObjects
		jsr	BuildSprites
		jsr	SS_ShowLayout
		bsr.w	SS_BGAnimate
		subq.w	#1,(v_palchgspeed).w
		bpl.s	loc_47D4
		move.w	#2,(v_palchgspeed).w
		bsr.w	WhiteOut_ToWhite

loc_47D4:
		tst.w	(v_demolength).w
		bne.s	SS_FinLoop

		move	#$2700,sr
		lea	($C00004).l,a6
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$9001,(a6)		; 64-cell hscroll size
		bsr.w	ClearScreen
		locVRAM	$B000
		lea	(Nem_TitleCard).l,a0 ; load title card patterns
		bsr.w	NemDec
		jsr	Hud_Base
		clr.w	(v_sgfx_buffer).w            ; +++ ProcessDMAQueue crap
		move.w	#v_sgfx_buffer,(v_vdp_buffer_slot).w ; +++
		move	#$2300,sr
		moveq	#palid_SSResult,d0
		bsr.w	PalLoad2	; load results screen palette
		moveq	#plcid_Main,d0
		bsr.w	NewPLC
		moveq	#plcid_SSResult,d0
		bsr.w	AddPLC		; load results screen patterns
		move.b	#1,(f_scorecount).w ; update score counter
		move.b	#1,(f_endactbonus).w ; update ring bonus counter
		move.w	(v_rings).w,d0
		mulu.w	#10,d0		; multiply rings by 10
		move.w	d0,(v_ringbonus).w ; set rings bonus
		sfx	bgm_GotThrough	 ; play end-of-level music

		lea	(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
	SS_EndClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,SS_EndClrObjRam ; clear object RAM

		move.b	#id_SSResult,(v_objspace+$5C0).w ; load results screen object
		


SS_NormalExit:
		bsr.w	PauseGame
		move.b	#$C,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr	ExecuteObjects
		jsr	BuildSprites
		bsr.w	RunPLC
		tst.w	(f_restart).w
		beq.s	SS_NormalExit
		tst.l	(v_plc_buffer).w
		bne.s	SS_NormalExit
		move.w	#sfx_EnterSS,d0
		jsr	PlaySound_Special ; play special stage exit sound
		bsr.w	PaletteWhiteOut
		rts	
; ===========================================================================

SS_ToSegaScreen:
		move.b	#id_Sega,(v_gamemode).w ; goto Sega screen
		rts

		if Revision=0
		else
SS_ToLevel:	cmpi.b	#id_Level,(v_gamemode).w
		beq.s	SS_ToSegaScreen
		rts
		endc

; ---------------------------------------------------------------------------
; Special stage	background loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_BGLoad:				; XREF: GM_Special
		lea	($FF0000).l,a1
		lea	(Eni_SSBg1).l,a0 ; load	mappings for the birds and fish
		move.w	#$4051,d0
		bsr.w	EniDec
		move.l	#$50000001,d3
		lea	($FF0080).l,a2
		moveq	#6,d7

loc_48BE:
		move.l	d3,d0
		moveq	#3,d6
		moveq	#0,d4
		cmpi.w	#3,d7
		bcc.s	loc_48CC
		moveq	#1,d4

loc_48CC:
		moveq	#7,d5

loc_48CE:
		movea.l	a2,a1
		eori.b	#1,d4
		bne.s	loc_48E2
		cmpi.w	#6,d7
		bne.s	loc_48F2
		lea	($FF0000).l,a1

loc_48E2:
		movem.l	d0-d4,-(sp)
		moveq	#7,d1
		moveq	#7,d2
		bsr.w	TilemapToVRAM
		movem.l	(sp)+,d0-d4

loc_48F2:
		addi.l	#$100000,d0
		dbf	d5,loc_48CE
		addi.l	#$3800000,d0
		eori.b	#1,d4
		dbf	d6,loc_48CC
		addi.l	#$10000000,d3
		bpl.s	loc_491C
		swap	d3
		addi.l	#$C000,d3
		swap	d3

loc_491C:
		adda.w	#$80,a2
		dbf	d7,loc_48BE
		lea	($FF0000).l,a1
		lea	(Eni_SSBg2).l,a0 ; load	mappings for the clouds
		move.w	#$4000,d0
		bsr.w	EniDec
		lea	($FF0000).l,a1
		move.l	#$40000003,d0
		moveq	#$3F,d1
		moveq	#$1F,d2
		bsr.w	TilemapToVRAM
		lea	($FF0000).l,a1
		move.l	#$50000003,d0
		moveq	#$3F,d1
		moveq	#$3F,d2
		bsr.w	TilemapToVRAM
		rts	
; End of function SS_BGLoad

; ---------------------------------------------------------------------------
; Palette cycling routine - special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_SS:				; XREF: VBla_0A; GM_Special
		tst.w	(f_pause).w
		bne.s	locret_49E6
		subq.w	#1,(v_palss_time).w
		bpl.s	locret_49E6
		lea	($C00004).l,a6
		move.w	(v_palss_num).w,d0
		addq.w	#1,(v_palss_num).w
		andi.w	#$1F,d0
		lsl.w	#2,d0
		lea	(byte_4A3C).l,a0
		adda.w	d0,a0
		move.b	(a0)+,d0
		bpl.s	loc_4992
		move.w	#$1FF,d0

loc_4992:
		move.w	d0,(v_palss_time).w
		moveq	#0,d0
		move.b	(a0)+,d0
		move.w	d0,($FFFFF7A0).w
		lea	(byte_4ABC).l,a1
		lea	(a1,d0.w),a1
		move.w	#-$7E00,d0
		move.b	(a1)+,d0
		move.w	d0,(a6)
		move.b	(a1),(v_scrposy_dup).w
		move.w	#-$7C00,d0
		move.b	(a0)+,d0
		move.w	d0,(a6)
		move.l	#$40000010,($C00004).l
		move.l	(v_scrposy_dup).w,($C00000).l
		moveq	#0,d0
		move.b	(a0)+,d0
		bmi.s	loc_49E8
		lea	(Pal_SSCyc1).l,a1
		adda.w	d0,a1
		lea	(v_pal1_wat+$4E).w,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+

locret_49E6:
		rts	
; ===========================================================================

loc_49E8:				; XREF: PalCycle_SS
		move.w	($FFFFF79E).w,d1
		cmpi.w	#$8A,d0
		bcs.s	loc_49F4
		addq.w	#1,d1

loc_49F4:
		mulu.w	#$2A,d1
		lea	(Pal_SSCyc2).l,a1
		adda.w	d1,a1
		andi.w	#$7F,d0
		bclr	#0,d0
		beq.s	loc_4A18
		lea	(v_pal1_wat+$6E).w,a2
		move.l	(a1),(a2)+
		move.l	4(a1),(a2)+
		move.l	8(a1),(a2)+

loc_4A18:
		adda.w	#$C,a1
		lea	(v_pal1_wat+$5A).w,a2
		cmpi.w	#$A,d0
		bcs.s	loc_4A2E
		subi.w	#$A,d0
		lea	(v_pal1_wat+$7A).w,a2

loc_4A2E:
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		adda.w	d0,a1
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		rts	
; End of function PalCycle_SS

; ===========================================================================
byte_4A3C:	dc.b 3,	0, 7, $92, 3, 0, 7, $90, 3, 0, 7, $8E, 3, 0, 7,	$8C
					; XREF: PalCycle_SS
		dc.b 3,	0, 7, $8B, 3, 0, 7, $80, 3, 0, 7, $82, 3, 0, 7,	$84
		dc.b 3,	0, 7, $86, 3, 0, 7, $88, 7, 8, 7, 0, 7,	$A, 7, $C
		dc.b $FF, $C, 7, $18, $FF, $C, 7, $18, 7, $A, 7, $C, 7,	8, 7, 0
		dc.b 3,	0, 6, $88, 3, 0, 6, $86, 3, 0, 6, $84, 3, 0, 6,	$82
		dc.b 3,	0, 6, $81, 3, 0, 6, $8A, 3, 0, 6, $8C, 3, 0, 6,	$8E
		dc.b 3,	0, 6, $90, 3, 0, 6, $92, 7, 2, 6, $24, 7, 4, 6,	$30
		dc.b $FF, 6, 6,	$3C, $FF, 6, 6,	$3C, 7,	4, 6, $30, 7, 2, 6, $24
		even
byte_4ABC:	dc.b $10, 1, $18, 0, $18, 1, $20, 0, $20, 1, $28, 0, $28, 1
		even

Pal_SSCyc1:	incbin	"palette\Cycle - Special Stage 1.bin"
		even
Pal_SSCyc2:	incbin	"palette\Cycle - Special Stage 2.bin"
		even

; ---------------------------------------------------------------------------
; Subroutine to	make the special stage background animated
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_BGAnimate:				; XREF: GM_Special
		move.w	($FFFFF7A0).w,d0
		bne.s	loc_4BF6
		move.w	#0,($FFFFF70C).w
		move.w	($FFFFF70C).w,($FFFFF618).w

loc_4BF6:
		cmpi.w	#8,d0
		bcc.s	loc_4C4E
		cmpi.w	#6,d0
		bne.s	loc_4C10
		addq.w	#1,($FFFFF718).w
		addq.w	#1,($FFFFF70C).w
		move.w	($FFFFF70C).w,($FFFFF618).w

loc_4C10:
		moveq	#0,d0
		move.w	($FFFFF708).w,d0
		neg.w	d0
		swap	d0
		lea	(byte_4CCC).l,a1
		lea	(v_ngfx_buffer).w,a3
		moveq	#9,d3

loc_4C26:
		move.w	2(a3),d0
		bsr.w	CalcSine
		moveq	#0,d2
		move.b	(a1)+,d2
		muls.w	d2,d0
		asr.l	#8,d0
		move.w	d0,(a3)+
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d2,(a3)+
		dbf	d3,loc_4C26
		lea	(v_ngfx_buffer).w,a3
		lea	(byte_4CB8).l,a2
		bra.s	loc_4C7E
; ===========================================================================

loc_4C4E:				; XREF: SS_BGAnimate
		cmpi.w	#$C,d0
		bne.s	loc_4C74
		subq.w	#1,($FFFFF718).w
		lea	($FFFFAB00).w,a3
		move.l	#$18000,d2
		moveq	#6,d1

loc_4C64:
		move.l	(a3),d0
		sub.l	d2,d0
		move.l	d0,(a3)+
		subi.l	#$2000,d2
		dbf	d1,loc_4C64

loc_4C74:
		lea	($FFFFAB00).w,a3
		lea	(byte_4CC4).l,a2

loc_4C7E:
		lea	(v_scrolltable).w,a1
		move.w	($FFFFF718).w,d0
		neg.w	d0
		swap	d0
		moveq	#0,d3
		move.b	(a2)+,d3
		move.w	($FFFFF70C).w,d2
		neg.w	d2
		andi.w	#$FF,d2
		lsl.w	#2,d2

loc_4C9A:
		move.w	(a3)+,d0
		addq.w	#2,a3
		moveq	#0,d1
		move.b	(a2)+,d1
		subq.w	#1,d1

loc_4CA4:
		move.l	d0,(a1,d2.w)
		addq.w	#4,d2
		andi.w	#$3FC,d2
		dbf	d1,loc_4CA4
		dbf	d3,loc_4C9A
		rts	
; End of function SS_BGAnimate

; ===========================================================================
byte_4CB8:	dc.b 9,	$28, $18, $10, $28, $18, $10, $30, $18,	8, $10,	0
		even
byte_4CC4:	dc.b 6,	$30, $30, $30, $28, $18, $18, $18
		even
byte_4CCC:	dc.b 8,	2, 4, $FF, 2, 3, 8, $FF, 4, 2, 2, 3, 8,	$FD, 4,	2, 2, 3, 2, $FF
		even
					; XREF: SS_BGAnimate
; ===========================================================================

; ---------------------------------------------------------------------------
; Continue screen
; ---------------------------------------------------------------------------

GM_Continue:				; XREF: GameModeArray
		bsr.w	PaletteFadeOut
		move	#$2700,sr
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l
		lea	($C00004).l,a6
		move.w	#$8004,(a6)	; 8 colour mode
		move.w	#$8700,(a6)	; background colour
		bsr.w	ClearScreen

		lea	(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
	Cont_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,Cont_ClrObjRam ; clear object RAM

		locVRAM	$B000
		lea	(Nem_TitleCard).l,a0 ; load title card patterns
		bsr.w	NemDec
		locVRAM	$A000
		lea	(Nem_ContSonic).l,a0 ; load Sonic patterns
		bsr.w	NemDec
		locVRAM	$AA20
		lea	(Nem_MiniSonic).l,a0 ; load continue screen patterns
		bsr.w	NemDec
		moveq	#10,d1
		jsr	ContScrCounter	; run countdown	(start from 10)
		moveq	#palid_Continue,d0
		bsr.w	PalLoad1	; load continue	screen palette
		move.b	#bgm_Continue,d0
		jsr	PlaySound	; play continue	music
		move.w	#659,(v_demolength).w ; set time delay to 11 seconds
		clr.l	(v_screenposx).w
		move.l	#$1000000,(v_screenposy).w
		move.b	#id_ContSonic,(v_objspace).w ; load Sonic object
		move.b	#id_ContScrItem,(v_objspace+$40).w ; load continue screen objects
		move.b	#id_ContScrItem,(v_objspace+$80).w
		move.w	#$180,(v_objspace+$80+obPriority).w
		move.b	#4,(v_objspace+$80+obFrame).w
		move.b	#id_ContScrItem,(v_objspace+$C0).w
		move.b	#4,(v_objspace+$C0+obRoutine).w
		jsr	ExecuteObjects
		jsr	BuildSprites
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		bsr.w	PaletteFadeIn

; ---------------------------------------------------------------------------
; Continue screen main loop
; ---------------------------------------------------------------------------

Cont_MainLoop:
		move.b	#$16,(v_vbla_routine).w
		bsr.w	WaitForVBla
		cmpi.b	#6,(v_objspace+obRoutine).w
		bcc.s	loc_4DF2
		move	#$2700,sr
		move.w	(v_demolength).w,d1
		divu.w	#$3C,d1
		andi.l	#$F,d1
		jsr	ContScrCounter
		move	#$2300,sr

loc_4DF2:
		jsr	ExecuteObjects
		jsr	BuildSprites
		cmpi.w	#$180,(v_objspace+obX).w ; has Sonic run off screen?
		bcc.s	Cont_GotoLevel	; if yes, branch
		cmpi.b	#6,(v_objspace+obRoutine).w
		bcc.s	Cont_MainLoop
		tst.w	(v_demolength).w
		bne.w	Cont_MainLoop
		move.b	#id_Sega,(v_gamemode).w ; go to Sega screen
		rts	
; ===========================================================================

Cont_GotoLevel:
		move.b	#id_Level,(v_gamemode).w ; set screen mode to $0C (level)
		move.b	#3,(v_lives).w	; set lives to 3
		moveq	#0,d0
		move.w	d0,(v_rings).w	; clear rings
		move.l	d0,(v_time).w	; clear time
		move.l	d0,(v_score).w	; clear score
		move.b	d0,(v_lastlamp).w ; clear lamppost count
		subq.b	#1,(v_continues).w ; subtract 1 from continues
		rts	
; ===========================================================================

		include	"_incObj\80 Continue Screen Elements.asm"
		include	"_incObj\81 Continue Screen Sonic.asm"
		include	"_anim\Continue Screen Sonic.asm"
		include	"_maps\Continue Screen.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Ending sequence in Green Hill	Zone
; ---------------------------------------------------------------------------

GM_Ending:				; XREF: GameModeArray
		move.b	#musFadeOut,d0
		jsr	PlaySound_Special ; stop music
		bsr.w	PaletteFadeOut

		lea	(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
	End_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,End_ClrObjRam ; clear object	RAM

		lea	($FFFFF628).w,a1
		moveq	#0,d0
		move.w	#$15,d1
	End_ClrRam1:
		move.l	d0,(a1)+
		dbf	d1,End_ClrRam1	; clear	variables

		lea	(v_screenposx).w,a1
		moveq	#0,d0
		move.w	#$3F,d1
	End_ClrRam2:
		move.l	d0,(a1)+
		dbf	d1,End_ClrRam2	; clear	variables

		lea	(v_oscillate+2).w,a1
		moveq	#0,d0
		move.w	#$47,d1
	End_ClrRam3:
		move.l	d0,(a1)+
		dbf	d1,End_ClrRam3	; clear	variables

		move	#$2700,sr
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l
		bsr.w	ClearScreen
		lea	($C00004).l,a6
		move.w	#$8B03,(a6)	; line scroll mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$8500+(vram_sprites>>9),(a6) ; set sprite table address
		move.w	#$9001,(a6)		; 64-cell hscroll size
		move.w	#$8004,(a6)		; 8-colour mode
		move.w	#$8720,(a6)		; set background colour (line 3; colour 0)
		move.w	#$8A00+223,(v_hbla_hreg).w ; set palette change position (for water)
		move.w	(v_hbla_hreg).w,(a6)
		move.w	#30,(v_air).w
		move.w	#id_EndZ<<8,(v_zone).w ; set level number to 0600 (extra flowers)
		cmpi.b	#6,(v_emeralds).w ; do you have all 6 emeralds?
		beq.s	End_LoadData	; if yes, branch
		move.w	#(id_EndZ<<8)+1,(v_zone).w ; set level number to 0601 (no flowers)

End_LoadData:
		moveq	#plcid_Ending,d0
		bsr.w	QuickPLC	; load ending sequence patterns
		jsr	Hud_Base
		bsr.w	LevelSizeLoad
		bsr.w	DeformLayers
		bset	#2,(v_bgscroll1).w
		bsr.w	LevelDataLoad
		bsr.w	LoadTilesFromStart
	;	move.l	#Col_GHZ,(v_collindex).w ; load collision index
	;	move.l	#Col_GHZ,($FFFFF796).w ; load collision	index   ; MJ's version of the above line
		move.l	#Col_GHZ_1,($FFFFFFD0).w			; MJ: Set first collision for ending
		move.l	#Col_GHZ_2,($FFFFFFD4).w			; MJ: Set second collision for ending
		move	#$2300,sr
		lea	(Kos_EndFlowers).l,a0 ;	load extra flower patterns
		lea	($FFFF9400).w,a1 ; RAM address to buffer the patterns
		bsr.w	KosDec
		moveq	#palid_Sonic,d0
		bsr.w	PalLoad1	; load Sonic's palette
		move.w	#bgm_Ending,d0
		jsr	PlaySound	; play ending sequence music
		btst	#bitA,(v_jpadhold1).w ; is button A pressed?
		beq.s	End_LoadSonic	; if not, branch
		move.b	#1,(f_debugmode).w ; enable debug mode

End_LoadSonic:
		move.b	#id_SonicPlayer,(v_objspace).w ; load Sonic object
		bset	#0,(v_player+obStatus).w ; make Sonic face left
		move.b	#1,(f_lockctrl).w ; lock controls
		move.w	#(btnL<<8),(v_jpadhold2).w ; move Sonic to the left
		move.w	#$F800,(v_player+obInertia).w ; set Sonic's speed
		move.b	#id_HUD,(v_objspace+$40).w ; load HUD object
		jsr	ObjPosLoad
		jsr	ExecuteObjects
		jsr	BuildSprites
		moveq	#0,d0
		move.w	d0,(v_rings).w
		move.l	d0,(v_time).w
		move.b	d0,(v_lifecount).w
; 		move.b	d0,(v_shield).w
; 		move.b	d0,(v_invinc).w
; 		move.b	d0,(v_shoes).w
		move.b	d0,($FFFFFE2F).w
		move.w	d0,(v_debuguse).w
		move.w	d0,(f_restart).w
		move.w	d0,(v_framecount).w
		bsr.w	OscillateNumInit
		move.b	#1,(f_scorecount).w
		move.b	#1,(f_ringcount).w
		move.b	#0,(f_timecount).w
		move.w	#1800,(v_demolength).w
		move.b	#$18,(v_vbla_routine).w
		bsr.w	WaitForVBla
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		move.w	#$3F,(v_pfade_start).w
		bsr.w	PaletteFadeIn

; ---------------------------------------------------------------------------
; Main ending sequence loop
; ---------------------------------------------------------------------------

End_MainLoop:
		bsr.w	PauseGame
		move.b	#$18,(v_vbla_routine).w
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w
		bsr.w	End_MoveSonic
		jsr	ExecuteObjects
		bsr.w	DeformLayers
		jsr	BuildSprites
		jsr	ObjPosLoad
		bsr.w	PaletteCycle
		bsr.w	OscillateNumDo
		bsr.w	SynchroAnimate
		cmpi.b	#id_Ending,(v_gamemode).w ; is game mode $18 (ending)?
		beq.s	End_ChkEmerald	; if yes, branch

		move.b	#id_Credits,(v_gamemode).w ; goto credits
		move.b	#bgm_Credits,d0
		jsr	PlaySound_Special ; play credits music
		move.w	#0,(v_creditsnum).w ; set credits index number to 0
		rts	
; ===========================================================================

End_ChkEmerald:
		tst.w	(f_restart).w	; has Sonic released the emeralds?
		beq.w	End_MainLoop	; if not, branch

		clr.w	(f_restart).w
		move.w	#$3F,(v_pfade_start).w
		clr.w	(v_palchgspeed).w

	End_AllEmlds:
		bsr.w	PauseGame
		move.b	#$18,(v_vbla_routine).w
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w
		bsr.w	End_MoveSonic
		jsr	ExecuteObjects
		bsr.w	DeformLayers
		jsr	BuildSprites
		jsr	ObjPosLoad
		bsr.w	OscillateNumDo
		bsr.w	SynchroAnimate
		subq.w	#1,(v_palchgspeed).w
		bpl.s	End_SlowFade
		move.w	#2,(v_palchgspeed).w
		bsr.w	WhiteOut_ToWhite

	End_SlowFade:
		tst.w	(f_restart).w
		beq.w	End_AllEmlds
		clr.w	(f_restart).w
		move.w	#$2E2F,(v_lvllayout+$80).w ; modify level layout
		lea	($C00004).l,a5
		lea	($C00000).l,a6
		lea	(v_screenposx).w,a3
	;	lea	(v_lvllayout).w,a4                      
		movea.l	(v_lvllayout).w,a4			; MJ: Load address of layout
		move.w	#$4000,d2
		bsr.w	DrawChunks
		moveq	#palid_Ending,d0
		bsr.w	PalLoad1	; load ending palette
		bsr.w	PaletteWhiteIn
		bra.w	End_MainLoop

; ---------------------------------------------------------------------------
; Subroutine controlling Sonic on the ending sequence
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


End_MoveSonic:				; XREF: End_MainLoop
		move.b	(v_sonicend).w,d0
		bne.s	End_MoveSon2
		cmpi.w	#$90,(v_player+obX).w ; has Sonic passed $90 on x-axis?
		bcc.s	End_MoveSonExit	; if not, branch

		addq.b	#2,(v_sonicend).w
		move.b	#1,(f_lockctrl).w ; lock player's controls
		move.w	#(btnR<<8),(v_jpadhold2).w ; move Sonic to the right
		rts	
; ===========================================================================

End_MoveSon2:
		subq.b	#2,d0
		bne.s	End_MoveSon3
		cmpi.w	#$A0,(v_player+obX).w ; has Sonic passed $A0 on x-axis?
		bcs.s	End_MoveSonExit	; if not, branch

		addq.b	#2,(v_sonicend).w
		moveq	#0,d0
		move.b	d0,(f_lockctrl).w
		move.w	d0,(v_jpadhold2).w ; stop Sonic moving
		move.w	d0,(v_player+obInertia).w
		move.b	#$81,(f_lockmulti).w ; lock controls & position
		move.b	#3,(v_player+obFrame).w
		move.w	#(id_Wait<<8)+id_Wait,(v_player+obAnim).w ; use "standing" animation
		move.b	#3,(v_player+obTimeFrame).w
		rts	
; ===========================================================================

End_MoveSon3:
		subq.b	#2,d0
		bne.s	End_MoveSonExit
		addq.b	#2,(v_sonicend).w
		move.w	#$A0,(v_player+obX).w
		move.b	#id_EndSonic,(v_objspace).w ; load Sonic ending sequence object
		clr.w	(v_player+obRoutine).w

End_MoveSonExit:
		rts	
; End of function End_MoveSonic

; ===========================================================================

		include	"_incObj\87 Ending Sequence Sonic.asm"
		include "_anim\Ending Sequence Sonic.asm"
		include	"_incObj\88 Ending Sequence Emeralds.asm"
		include	"_incObj\89 Ending Sequence STH.asm"
		include	"_maps\Ending Sequence Sonic.asm"
		include	"_maps\Ending Sequence Emeralds.asm"
		include	"_maps\Ending Sequence STH.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Credits ending sequence
; ---------------------------------------------------------------------------

GM_Credits:				; XREF: GameModeArray
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		lea	($C00004).l,a6
		move.w	#$8004,(a6)		; 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$9001,(a6)		; 64-cell hscroll size
		move.w	#$9200,(a6)		; window vertical position
		move.w	#$8B03,(a6)		; line scroll mode
		move.w	#$8720,(a6)		; set background colour (line 3; colour 0)
		clr.b	(f_wtr_state).w
		bsr.w	ClearScreen

		lea	(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
	Cred_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,Cred_ClrObjRam ; clear object RAM

		locVRAM	$B400
		lea	(Nem_CreditText).l,a0 ;	load credits alphabet patterns
		bsr.w	NemDec

		lea	(v_pal1_dry).w,a1
		moveq	#0,d0
		move.w	#$1F,d1
	Cred_ClrPal:
		move.l	d0,(a1)+
		dbf	d1,Cred_ClrPal ; fill palette with black

		moveq	#palid_Sonic,d0
		bsr.w	PalLoad1	; load Sonic's palette
		move.b	#id_CreditsText,(v_objspace+$80).w ; load credits object
		jsr	ExecuteObjects
		jsr	BuildSprites
		bsr.w	EndingDemoLoad
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#4,d0
		lea	(LevelHeaders).l,a2
		lea	(a2,d0.w),a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	Cred_SkipObjGfx
		bsr.w	AddPLC		; load object graphics

	Cred_SkipObjGfx:
		moveq	#plcid_Main2,d0
		bsr.w	AddPLC		; load standard	level graphics
		move.w	#120,(v_demolength).w ; display a credit for 2 seconds
		bsr.w	PaletteFadeIn

Cred_WaitLoop:
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	RunPLC
		tst.w	(v_demolength).w ; have 2 seconds elapsed?
		bne.s	Cred_WaitLoop	; if not, branch
		tst.l	(v_plc_buffer).w ; have level gfx finished decompressing?
		bne.s	Cred_WaitLoop	; if not, branch
		cmpi.w	#9,(v_creditsnum).w ; have the credits finished?
		beq.w	TryAgainEnd	; if yes, branch
		rts	

; ---------------------------------------------------------------------------
; Ending sequence demo loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


EndingDemoLoad:				; XREF: GM_Credits
		move.w	(v_creditsnum).w,d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	EndDemo_Levels(pc,d0.w),d0 ; load level	array
		move.w	d0,(v_zone).w	; set level from level array
		addq.w	#1,(v_creditsnum).w
		cmpi.w	#9,(v_creditsnum).w ; have credits finished?
		bcc.s	EndDemo_Exit	; if yes, branch
		move.w	#$8001,(f_demo).w ; set demo+ending mode
		move.b	#id_Demo,(v_gamemode).w ; set game mode to 8 (demo)
		move.b	#3,(v_lives).w	; set lives to 3
		moveq	#0,d0
		move.w	d0,(v_rings).w	; clear rings
		move.l	d0,(v_time).w	; clear time
		move.l	d0,(v_score).w	; clear score
		move.b	d0,(v_lastlamp).w ; clear lamppost counter
		cmpi.w	#4,(v_creditsnum).w ; is SLZ demo running?
		bne.s	EndDemo_Exit	; if not, branch
		lea	(EndDemo_LampVar).l,a1 ; load lamppost variables
		lea	(v_lastlamp).w,a2
		move.w	#8,d0

	EndDemo_LampLoad:
		move.l	(a1)+,(a2)+
		dbf	d0,EndDemo_LampLoad

EndDemo_Exit:
		rts	
; End of function EndingDemoLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Levels used in the end sequence demos
; ---------------------------------------------------------------------------
EndDemo_Levels:	incbin	"misc\Demo Level Order - Ending.bin"

; ---------------------------------------------------------------------------
; Lamppost variables in the end sequence demo (Star Light Zone)
; ---------------------------------------------------------------------------
EndDemo_LampVar:
		dc.b 1,	1		; number of the last lamppost
		dc.w $A00, $62C		; x/y-axis position
		dc.w 13			; rings
		dc.l 0			; time
		dc.b 0,	0		; dynamic level event routine counter
		dc.w $800		; level bottom boundary
		dc.w $957, $5CC		; x/y axis screen position
		dc.w $4AB, $3A6, 0, $28C, 0, 0 ; scroll info
		dc.w $308		; water height
		dc.b 1,	1		; water routine and state
; ===========================================================================
; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END"	screens
; ---------------------------------------------------------------------------

TryAgainEnd:				; XREF: GM_Credits
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		lea	($C00004).l,a6
		move.w	#$8004,(a6)	; use 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$9001,(a6)	; 64-cell hscroll size
		move.w	#$9200,(a6)	; window vertical position
		move.w	#$8B03,(a6)	; line scroll mode
		move.w	#$8720,(a6)	; set background colour (line 3; colour 0)
		clr.b	(f_wtr_state).w
		bsr.w	ClearScreen

		lea	(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
	TryAg_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,TryAg_ClrObjRam ; clear object RAM

		moveq	#plcid_TryAgain,d0
		bsr.w	QuickPLC	; load "TRY AGAIN" or "END" patterns

		lea	(v_pal1_dry).w,a1
		moveq	#0,d0
		move.w	#$1F,d1
	TryAg_ClrPal:
		move.l	d0,(a1)+
		dbf	d1,TryAg_ClrPal ; fill palette with black

		moveq	#palid_Ending,d0
		bsr.w	PalLoad1	; load ending palette
		clr.w	(v_pal1_dry+$40).w
		move.b	#id_EndEggman,(v_objspace+$80).w ; load Eggman object
		jsr	ExecuteObjects
		jsr	BuildSprites
		move.w	#1800,(v_demolength).w ; show screen for 30 seconds
		bsr.w	PaletteFadeIn

; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END"	screen main loop
; ---------------------------------------------------------------------------
TryAg_MainLoop:
		bsr.w	PauseGame
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr	ExecuteObjects
		jsr	BuildSprites
		andi.b	#btnStart,(v_jpadpress1).w ; is Start button pressed?
		bne.s	TryAg_Exit	; if yes, branch
		tst.w	(v_demolength).w ; has 30 seconds elapsed?
		beq.s	TryAg_Exit	; if yes, branch
		cmpi.b	#id_Credits,(v_gamemode).w
		beq.s	TryAg_MainLoop

TryAg_Exit:
		move.b	#id_Sega,(v_gamemode).w ; goto Sega screen
		rts	

; ===========================================================================

		include	"_incObj\8B Try Again & End Eggman.asm"
		include "_anim\Try Again & End Eggman.asm"
		include	"_incObj\8C Try Again Emeralds.asm"
		include	"_maps\Try Again & End Eggman.asm"

; ---------------------------------------------------------------------------
; Ending sequence demos
; ---------------------------------------------------------------------------
Demo_EndGHZ1:	incbin	"demodata\Ending - GHZ1.bin"
		even
Demo_EndMZ:	incbin	"demodata\Ending - MZ.bin"
		even
Demo_EndSYZ:	incbin	"demodata\Ending - SYZ.bin"
		even
Demo_EndLZ:	incbin	"demodata\Ending - LZ.bin"
		even
Demo_EndSLZ:	incbin	"demodata\Ending - SLZ.bin"
		even
Demo_EndSBZ1:	incbin	"demodata\Ending - SBZ1.bin"
		even
Demo_EndSBZ2:	incbin	"demodata\Ending - SBZ2.bin"
		even
Demo_EndGHZ2:	incbin	"demodata\Ending - GHZ2.bin"
		even

		if Revision=0
		include	"_inc\LevelSizeLoad & BgScrollSpeed.asm"
		include	"_inc\DeformLayers.asm"
		else
		include	"_inc\LevelSizeLoad & BgScrollSpeed (JP1).asm"
		include	"_inc\DeformLayers (JP1).asm"
		endc


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_6886:				; XREF: VBla_04
		lea	($C00004).l,a5
		lea	($C00000).l,a6
		lea	(v_bgscroll2).w,a2
		lea	($FFFFF708).w,a3
	;	lea	(v_lvllayout+$40).w,a4
		movea.l	(v_lvllayout+4).w,a4			; MJ: Load address of layout BG
		move.w	#$6000,d2
		bsr.w	sub_6954
		lea	(v_bgscroll3).w,a2
		lea	($FFFFF710).w,a3
		bra.w	sub_69F4
; End of function sub_6886

; ---------------------------------------------------------------------------
; Subroutine to	display	correct	tiles as you move
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTilesAsYouMove:			; XREF: Demo_Time
		lea	($C00004).l,a5
		lea	($C00000).l,a6
		lea	($FFFFFF32).w,a2
		lea	($FFFFFF18).w,a3
	;	lea	(v_lvllayout+$40).w,a4
		movea.l	(v_lvllayout+4).w,a4			; MJ: Load address of layout BG
		move.w	#$6000,d2
		bsr.w	sub_6954
		lea	($FFFFFF34).w,a2
		lea	($FFFFFF20).w,a3
		bsr.w	sub_69F4
		if Revision=0
		else
		lea	($FFFFFF36).w,a2
		lea	($FFFFFF28).w,a3
		bsr.w	locj_6EA4
		endc
		lea	($FFFFFF30).w,a2
		lea	($FFFFFF10).w,a3
	;	lea	(v_lvllayout).w,a4                      
		movea.l	(v_lvllayout).w,a4			; MJ: Load address of layout
		move.w	#$4000,d2
		tst.b	(a2)
		beq.s	locret_6952
		bclr	#0,(a2)
		beq.s	loc_6908
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	DrawTiles_LR

loc_6908:
		bclr	#1,(a2)
		beq.s	loc_6922
		move.w	#$E0,d4
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#$E0,d4
		moveq	#-$10,d5
		bsr.w	DrawTiles_LR

loc_6922:
		bclr	#2,(a2)
		beq.s	loc_6938
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	DrawTiles_TB

loc_6938:
		bclr	#3,(a2)
		beq.s	locret_6952
		moveq	#-$10,d4
		move.w	#$140,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-$10,d4
		move.w	#$140,d5
		bsr.w	DrawTiles_TB

locret_6952:
		rts	
; End of function LoadTilesAsYouMove


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_6954:				; XREF: sub_6886; LoadTilesAsYouMove
		tst.b	(a2)
		beq.w	locret_69F2
		bclr	#0,(a2)
		beq.s	loc_6972
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-$10,d4
		moveq	#-$10,d5
		if Revision=0
		moveq	#$1F,d6
		bsr.w	DrawTiles_LR_2
		else
			bsr.w	DrawTiles_LR
		endc

loc_6972:
		bclr	#1,(a2)
		beq.s	loc_698E
		move.w	#$E0,d4
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#$E0,d4
		moveq	#-$10,d5
		if Revision=0
		moveq	#$1F,d6
		bsr.w	DrawTiles_LR_2
		else
			bsr.w	DrawTiles_LR
		endc

loc_698E:
		bclr	#2,(a2)

		if Revision=0
		beq.s	loc_69BE
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-$10,d4
		moveq	#-$10,d5
		move.w	($FFFFF7F0).w,d6
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d6
		blt.s	loc_69BE
		lsr.w	#4,d6
		cmpi.w	#$F,d6
		bcs.s	loc_69BA
		moveq	#$F,d6

loc_69BA:
		bsr.w	DrawTiles_TB_2

loc_69BE:
		bclr	#3,(a2)
		beq.s	locret_69F2
		moveq	#-$10,d4
		move.w	#$140,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-$10,d4
		move.w	#$140,d5
		move.w	($FFFFF7F0).w,d6
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d6
		blt.s	locret_69F2
		lsr.w	#4,d6
		cmpi.w	#$F,d6
		bcs.s	loc_69EE
		moveq	#$F,d6

loc_69EE:
		bsr.w	DrawTiles_TB_2

		else

			beq.s	locj_6D56
			moveq	#-$10,d4
			moveq	#-$10,d5
			bsr.w	Calc_VRAM_Pos
			moveq	#-$10,d4
			moveq	#-$10,d5
			bsr	DrawTiles_TB
	locj_6D56:

			bclr	#3,(a2)
			beq.s	locj_6D70
			moveq	#-$10,d4
			move.w	#$140,d5
			bsr	Calc_VRAM_Pos
			moveq	#-$10,d4
			move.w	#$140,d5
			bsr	DrawTiles_TB
	locj_6D70:

			bclr	#4,(a2)
			beq.s	locj_6D88
			moveq	#-$10,d4
			moveq	#$00,d5
			bsr	Calc_VRAM_Pos_2
			moveq	#-$10,d4
			moveq	#0,d5
			moveq	#$1F,d6
			bsr	DrawTiles_LR_3
	locj_6D88:

			bclr	#5,(a2)
			beq.s	locret_69F2
			move.w	#$00E0,d4
			moveq	#0,d5
			bsr	Calc_VRAM_Pos_2
			move.w	#$E0,d4
			moveq	#0,d5
			moveq	#$1F,d6
			bsr	DrawTiles_LR_3
		endc

locret_69F2:
		rts	
; End of function sub_6954


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_69F4:				; XREF: sub_6886; LoadTilesAsYouMove
		if Revision=0

		tst.b	(a2)
		beq.w	locret_6A80
		bclr	#2,(a2)
		beq.s	loc_6A3E
		cmpi.w	#$10,(a3)
		bcs.s	loc_6A3E
		move.w	($FFFFF7F0).w,d4
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d4
		move.w	d4,-(sp)
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		move.w	(sp)+,d4
		moveq	#-$10,d5
		move.w	($FFFFF7F0).w,d6
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d6
		blt.s	loc_6A3E
		lsr.w	#4,d6
		subi.w	#$E,d6
		bcc.s	loc_6A3E
		neg.w	d6
		bsr.w	DrawTiles_TB_2

loc_6A3E:
		bclr	#3,(a2)
		beq.s	locret_6A80
		move.w	($FFFFF7F0).w,d4
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d4
		move.w	d4,-(sp)
		move.w	#$140,d5
		bsr.w	Calc_VRAM_Pos
		move.w	(sp)+,d4
		move.w	#$140,d5
		move.w	($FFFFF7F0).w,d6
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d6
		blt.s	locret_6A80
		lsr.w	#4,d6
		subi.w	#$E,d6
		bcc.s	locret_6A80
		neg.w	d6
		bsr.w	DrawTiles_TB_2

locret_6A80:
		rts	
; End of function sub_69F4

; ===========================================================================

		tst.b	(a2)
		beq.s	locret_6AD6
		bclr	#2,(a2)
		beq.s	loc_6AAC
		move.w	#$D0,d4
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d4
		move.w	d4,-(sp)
		moveq	#-$10,d5
		bsr.w	sub_6C3C
		move.w	(sp)+,d4
		moveq	#-$10,d5
		moveq	#2,d6
		bsr.w	DrawTiles_TB_2

loc_6AAC:
		bclr	#3,(a2)
		beq.s	locret_6AD6
		move.w	#$D0,d4
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d4
		move.w	d4,-(sp)
		move.w	#$140,d5
		bsr.w	sub_6C3C
		move.w	(sp)+,d4
		move.w	#$140,d5
		moveq	#2,d6
		bsr.w	DrawTiles_TB_2

locret_6AD6:
		rts	

		else

			tst.b	(a2)
			beq	locj_6DF2
			cmpi.b	#id_SBZ,(v_zone).w
			beq	Draw_SBz
			bclr	#0,(a2)
			beq.s	locj_6DD2
			move.w	#$70,d4
			moveq	#-$10,d5
			bsr	Calc_VRAM_Pos
			move.w	#$70,d4
			moveq	#-$10,d5
			moveq	#2,d6
			bsr	DrawTiles_TB_2
	locj_6DD2:
			bclr	#1,(a2)
			beq.s	locj_6DF2
			move.w	#$70,d4
			move.w	#$140,d5
			bsr	Calc_VRAM_Pos
			move.w	#$70,d4
			move.w	#$140,d5
			moveq	#2,d6
			bsr	DrawTiles_TB_2
	locj_6DF2:
			rts
	locj_6DF4:
			dc.b $00,$00,$00,$00,$00,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$04
			dc.b $04,$04,$04,$04,$04,$04,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$00						
;===============================================================================
	Draw_SBz:
			moveq	#-$10,d4
			bclr	#0,(a2)
			bne.s	locj_6E28
			bclr	#1,(a2)
			beq.s	locj_6E72
			move.w	#$E0,d4
	locj_6E28:
			lea	(locj_6DF4+1),A0
			move.w	($FFFFF70C).w,d0
			add.w	d4,d0
			andi.w	#$1F0,d0
			lsr.w	#4,d0
			move.b	(a0,d0),d0
			lea	(locj_6FE4),a3
			move.w	(a3,d0),a3
			beq.s	locj_6E5E
			moveq	#-$10,d5
			movem.l	d4/d5,-(sp)
			bsr	Calc_VRAM_Pos
			movem.l	(sp)+,d4/d5
			bsr	DrawTiles_LR
			bra.s	locj_6E72
;===============================================================================
	locj_6E5E:
			moveq	#0,d5
			movem.l	d4/d5,-(sp)
			bsr	Calc_VRAM_Pos_2
			movem.l	(sp)+,d4/d5
			moveq	#$1F,d6
			bsr	DrawTiles_LR_3
	locj_6E72:
			tst.b	(a2)
			bne.s	locj_6E78
			rts
;===============================================================================			
	locj_6E78:
			moveq	#-$10,d4
			moveq	#-$10,d5
			move.b	(a2),d0
			andi.b	#$A8,d0
			beq.s	locj_6E8C
			lsr.b	#1,d0
			move.b	d0,(a2)
			move.w	#$140,d5
	locj_6E8C:
			lea	(locj_6DF4),a0
			move.w	($FFFFF70C).w,d0
			andi.w	#$1F0,d0
			lsr.w	#4,d0
			lea	(a0,d0),a0
			bra	locj_6FEC						
;===============================================================================



	locj_6EA4:
			tst.b	(a2)
			beq	locj_6EF0
			cmpi.b	#id_MZ,(v_zone).w
			beq	Draw_Mz
			bclr	#0,(a2)
			beq.s	locj_6ED0
			move.w	#$40,d4
			moveq	#-$10,d5
			bsr	Calc_VRAM_Pos
			move.w	#$40,d4
			moveq	#-$10,d5
			moveq	#2,d6
			bsr	DrawTiles_TB_2
	locj_6ED0:
			bclr	#1,(a2)
			beq.s	locj_6EF0
			move.w	#$40,d4
			move.w	#$140,d5
			bsr	Calc_VRAM_Pos
			move.w	#$40,d4
			move.w	#$140,d5
			moveq	#2,d6
			bsr	DrawTiles_TB_2
	locj_6EF0:
			rts
	locj_6EF2:
			dc.b $00,$00,$00,$00,$00,$00,$06,$06,$04,$04,$04,$04,$04,$04,$04,$04
			dc.b $04,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$00
;===============================================================================
	Draw_Mz:
			moveq	#-$10,d4
			bclr	#0,(a2)
			bne.s	locj_6F66
			bclr	#1,(a2)
			beq.s	locj_6FAE
			move.w	#$E0,d4
	locj_6F66:
			lea	(locj_6EF2+1),a0
			move.w	($FFFFF70C).w,d0
			subi.w	#$200,d0
			add.w	d4,d0
			andi.w	#$7F0,d0
			lsr.w	#4,d0
			move.b	(a0,d0),d0
			move.w	locj_6FE4(pc,d0),a3
			beq.s	locj_6F9A
			moveq	#-$10,d5
			movem.l	d4/d5,-(sp)
			bsr	Calc_VRAM_Pos
			movem.l	(sp)+,d4/d5
			bsr	DrawTiles_LR
			bra.s	locj_6FAE
;===============================================================================
	locj_6F9A:
			moveq	#0,d5
			movem.l	d4/d5,-(sp)
			bsr	Calc_VRAM_Pos_2
			movem.l	(sp)+,d4/d5
			moveq	#$1F,d6
			bsr	DrawTiles_LR_3
	locj_6FAE:
			tst.b	(a2)
			bne.s	locj_6FB4
			rts
;===============================================================================			
	locj_6FB4:
			moveq	#-$10,d4
			moveq	#-$10,d5
			move.b	(a2),d0
			andi.b	#$A8,d0
			beq.s	locj_6FC8
			lsr.b	#1,d0
			move.b	d0,(a2)
			move.w	#$140,d5
	locj_6FC8:
			lea	(locj_6EF2),a0
			move.w	($FFFFF70C).w,d0
			subi.w	#$200,d0
			andi.w	#$7F0,d0
			lsr.w	#4,d0
			lea	(a0,d0),a0
			bra	locj_6FEC
;===============================================================================			
	locj_6FE4:
			dc.b $FF,$18,$FF,$18,$FF,$20,$FF,$28
	locj_6FEC:
			moveq	#$F,d6
			move.l	#$800000,d7
	locj_6FF4:			
			moveq	#0,d0
			move.b	(a0)+,d0
			btst	d0,(a2)
			beq.s	locj_701C
			move.w	locj_6FE4(pc,d0),a3
			movem.l	d4/d5/a0,-(sp)
			movem.l	d4/d5,-(sp)
			bsr	DrawBlocks
			movem.l	(sp)+,d4/d5
			bsr	Calc_VRAM_Pos
			bsr	DrawTiles
			movem.l	(sp)+,d4/d5/a0
	locj_701C:
			addi.w	#$10,d4
			dbra	d6,locj_6FF4
			clr.b	(a2)
			rts			

		endc

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DrawTiles_LR:				; XREF: LoadTilesAsYouMove
		moveq	#$15,d6

DrawTiles_LR_2:				; XREF: sub_6954; DrawChunks
		move.l	#$800000,d7
		move.l	d0,d1

	@loop:
		movem.l	d4-d5,-(sp)
		bsr.w	DrawBlocks
		move.l	d1,d0
		bsr.w	DrawTiles
		addq.b	#4,d1
		andi.b	#$7F,d1
		movem.l	(sp)+,d4-d5
		addi.w	#$10,d5
		dbf	d6,@loop
		rts	
; End of function DrawTiles_LR

		if Revision=0
		else
DrawTiles_LR_3:
		move.l	#$800000,d7
		move.l	d0,d1

	@loop:
		movem.l	d4-d5,-(sp)
		bsr.w	DrawBlocks_2
		move.l	d1,d0
		bsr.w	DrawTiles
		addq.b	#4,d1
		andi.b	#$7F,d1
		movem.l	(sp)+,d4-d5
		addi.w	#$10,d5
		dbf	d6,@loop
		rts	
; End of function DrawTiles_LR_3
		endc


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DrawTiles_TB:				; XREF: LoadTilesAsYouMove
		moveq	#$F,d6

DrawTiles_TB_2:				; XREF: sub_6954
		move.l	#$800000,d7
		move.l	d0,d1

	@loop:
		movem.l	d4-d5,-(sp)
		bsr.w	DrawBlocks
		move.l	d1,d0
		bsr.w	DrawTiles
		addi.w	#$100,d1
		andi.w	#$FFF,d1
		movem.l	(sp)+,d4-d5
		addi.w	#$10,d4
		dbf	d6,@loop
		rts	
; End of function DrawTiles_TB_2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DrawTiles:				; XREF: DrawTiles_LR_2; DrawTiles_TB_2
		or.w	d2,d0
		swap	d0
	;	btst	#4,(a0)
		btst	#3,(a0)					; MJ: checking bit 3 not 4 (Flip)
        	bne.s	DrawFlipY
	;	btst	#3,(a0)
		btst	#2,(a0)					; MJ: checking bit 2 not 3 (Mirror)
		bne.s	DrawFlipX
		move.l	d0,(a5)
		move.l	(a1)+,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		move.l	(a1)+,(a6)
		rts	
; ===========================================================================

DrawFlipX:
		move.l	d0,(a5)
		move.l	(a1)+,d4
		eori.l	#$8000800,d4
		swap	d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		move.l	(a1)+,d4
		eori.l	#$8000800,d4
		swap	d4
		move.l	d4,(a6)
		rts	
; ===========================================================================

DrawFlipY:
	;	btst	#3,(a0)
		btst	#2,(a0) 				; MJ: checking bit 2 not 3 (Mirror)
		bne.s	DrawFlipXY
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d4
		eori.l	#$10001000,d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$10001000,d5
		move.l	d5,(a6)
		rts	
; ===========================================================================

DrawFlipXY:
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d4
		eori.l	#$18001800,d4
		swap	d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$18001800,d5
		swap	d5
		move.l	d5,(a6)
		rts	
; End of function DrawTiles

; ===========================================================================
; unused garbage
		if Revision=0
		rts	
		move.l	d0,(a5)
		move.w	#$2000,d5
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		rts	
		else
		endc

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DrawBlocks:				; XREF: DrawTiles_LR_2; DrawTiles_TB_2
 		if Revision=0
		lea	($FFFFB000).w,a1			; MJ: load Block's location
		add.w	4(a3),d4				; MJ: load Y position to d4
		add.w	(a3),d5					; MJ: load X position to d5
 		else
 			add.w	(a3),d5
 	DrawBlocks_2:
		add.w	4(a3),d4				; MJ: load Y position to d4
		lea	($FFFFB000).w,a1			; MJ: load Block's location
 		endc
; 		move.w	d4,d3
; 		lsr.w	#1,d3
; 		andi.w	#$380,d3
; 		lsr.w	#3,d5
; 		move.w	d5,d0
; 		lsr.w	#5,d0
; 		andi.w	#$7F,d0
; 		add.w	d3,d0
; 		moveq	#-1,d3
; 		move.b	(a4,d0.w),d3
; 		beq.s	locret_6C1E
; 		subq.b	#1,d3
; 		andi.w	#$7F,d3
; 		ror.w	#7,d3
; 		add.w	d4,d4
; 		andi.w	#$1E0,d4
; 		andi.w	#$1E,d5
; 		add.w	d4,d3
; 		add.w	d5,d3
; 		movea.l	d3,a0

; 		lea	($FFFFB000).w,a1			; MJ: load Block's location
; 		add.w	4(a3),d4				; MJ: load Y position to d4
; 		add.w	(a3),d5					; MJ: load X position to d5
		move.w	d4,d3					; MJ: copy Y position to d3
		andi.w	#$780,d3				; MJ: get within 780 (Not 380) (E00 pixels (not 700)) in multiples of 80
		lsr.w	#3,d5					; MJ: divide X position by 8
		move.w	d5,d0					; MJ: copy to d0
		lsr.w	#4,d0					; MJ: divide by 10 (Not 20)
		andi.w	#$7F,d0					; MJ: get within 7F
		lsl.w	#$01,d3					; MJ: multiply by 2 (So it skips the BG)
		add.w	d3,d0					; MJ: add calc'd Y pos
		moveq	#-1,d3					; MJ: prepare FFFF in d3
		move.b	(a4,d0.w),d3				; MJ: collect correct chunk ID from layout
		andi.w	#$FF,d3					; MJ: keep within 7F
		ror.w	#7,d3					; MJ: ror round to the far left
		ror.w	#2,d3					; MJ: ..plus an extra 2 (so it's within 80 bytes, not 200)
		andi.w	#$070,d4				; MJ: keep Y pos within 80 pixels
		andi.w	#$0E,d5					; MJ: keep X pos within 10
		add.w	d4,d3					; MJ: add calc'd Y pos to ror'd d3
		add.w	d5,d3					; MJ: add calc'd X pos to ror'd d3
		movea.l	d3,a0					; MJ: set address (Chunk to read)

		move.w	(a0),d3
		andi.w	#$3FF,d3
		lsl.w	#3,d3
		adda.w	d3,a1

locret_6C1E:
		rts	
; End of function DrawBlocks


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Calc_VRAM_Pos:				; XREF: LoadTilesAsYouMove; et al
		if Revision=0
		add.w	4(a3),d4
		add.w	(a3),d5
		else
			add.w	(a3),d5
	Calc_VRAM_Pos_2:
			add.w	4(a3),d4
		endc
		andi.w	#$F0,d4
		andi.w	#$1F0,d5
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#3,d0
		swap	d0
		move.w	d4,d0
		rts	
; End of function Calc_VRAM_Pos


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; not used


sub_6C3C:
		add.w	4(a3),d4
		add.w	(a3),d5
		andi.w	#$F0,d4
		andi.w	#$1F0,d5
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#2,d0
		swap	d0
		move.w	d4,d0
		rts	
; End of function sub_6C3C

; ---------------------------------------------------------------------------
; Subroutine to	load tiles as soon as the level	appears
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTilesFromStart:			; XREF: GM_Level; GM_Ending
		lea	($C00004).l,a5
		lea	($C00000).l,a6
		lea	(v_screenposx).w,a3
	;	lea	(v_lvllayout).w,a4                      
		movea.l	(v_lvllayout).w,a4			; MJ: Load address of layout
		move.w	#$4000,d2
		bsr.s	DrawChunks
		lea	($FFFFF708).w,a3
	;	lea	(v_lvllayout+$40).w,a4
		movea.l	(v_lvllayout+4).w,a4			; MJ: Load address of layout BG
		move.w	#$6000,d2
		if Revision=0
		else
			tst.b	(v_zone).w
			beq	Draw_GHz_Bg
		;	cmpi.b	#id_MZ,(v_zone).w
		;	beq	Draw_Mz_Bg
			cmpi.w	#(id_SBZ<<8)+0,(v_zone).w
			beq	Draw_SBz_Bg
			cmpi.b	#id_EndZ,(v_zone).w
			beq	Draw_GHz_Bg
		endc
; End of function LoadTilesFromStart


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DrawChunks:				; XREF: LoadTilesFromStart
		moveq	#-$10,d4
		moveq	#$F,d6

	@loop:
		movem.l	d4-d6,-(sp)
		moveq	#0,d5
		move.w	d4,d1
		bsr.w	Calc_VRAM_Pos
		move.w	d1,d4
		moveq	#0,d5
		moveq	#$1F,d6
		bsr.w	DrawTiles_LR_2
		movem.l	(sp)+,d4-d6
		addi.w	#$10,d4
		dbf	d6,@loop
		rts	
; End of function DrawChunks

		if Revision=0
		else

	Draw_GHz_Bg:
			moveq	#0,d4
			moveq	#$F,d6
	locj_7224:			
			movem.l	d4-d6,-(sp)
			lea	(locj_724a),a0
			move.w	($FFFFF70C).w,d0
			add.w	d4,d0
			andi.w	#$F0,d0
			bsr	locj_72Ba
			movem.l	(sp)+,d4-d6
			addi.w	#$10,d4
			dbra	d6,locj_7224
			rts
	locj_724a:
			dc.b $00,$00,$00,$00,$06,$06,$06,$04,$04,$04,$00,$00,$00,$00,$00,$00
;-------------------------------------------------------------------------------
	Draw_Mz_Bg:;locj_725a:
			moveq	#-$10,d4
			moveq	#$F,d6
	locj_725E:			
			movem.l	d4-d6,-(sp)
			lea	(locj_6EF2+$01),a0
			move.w	($FFFFF70C).w,d0
			subi.w	#$200,d0
			add.w	d4,d0
			andi.w	#$7F0,d0
			bsr	locj_72Ba
			movem.l	(sp)+,d4-d6
			addi.w	#$10,d4
			dbra	d6,locj_725E
			rts
;-------------------------------------------------------------------------------
	Draw_SBz_Bg:;locj_7288:
			moveq	#-$10,d4
			moveq	#$F,d6
	locj_728C:			
			movem.l	d4-d6,-(sp)
			lea	(locj_6DF4+$01),a0
			move.w	($FFFFF70C).w,d0
			add.w	d4,d0
			andi.w	#$1F0,d0
			bsr	locj_72Ba
			movem.l	(sp)+,d4-d6
			addi.w	#$10,d4
			dbra	d6,locj_728C
			rts
;-------------------------------------------------------------------------------
	locj_72B2:
			dc.b $F7,$08,$F7,$08,$F7,$10,$F7,$18
	locj_72Ba:
			lsr.w	#4,d0
			move.b	(a0,d0),d0
			move.w	locj_72B2(pc,d0),a3
			beq.s	locj_72da
			moveq	#-$10,d5
			movem.l	d4/d5,-(sp)
			bsr	Calc_VRAM_Pos
			movem.l	(sp)+,d4/d5
			bsr	DrawTiles_LR
			bra.s	locj_72EE
	locj_72da:
			moveq	#0,d5
			movem.l	d4/d5,-(sp)
			bsr	Calc_VRAM_Pos_2
			movem.l	(sp)+,d4/d5
			moveq	#$1F,d6
			bsr	DrawTiles_LR_3
	locj_72EE:
			rts
		endc


; ---------------------------------------------------------------------------
; Subroutine to load level Kosinski art (from Sonic 2, ported by Clowancy)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

LoadZoneTiles:
		moveq	#0,d0				; Clear d0
		move.b	(v_zone).w,d0		; Load number of current zone to d0
		lsl.w	#4,d0				; Multiply by $10, converting the zone ID into an offset
		lea		(LevelHeaders).l,a2	; Load LevelHeaders's address into a2
		lea		(a2,d0.w),a2		; Offset LevelHeaders by the zone-offset, and load the resultant address to a2
		move.l	(a2)+,d0			; Move the first longword of data that a2 points to to d0, this contains the zone's first PLC ID and its art's address.
									; The auto increment is pointless as a2 is overwritten later, and nothing reads from a2 before then
		andi.l	#$FFFFFF,d0    		; Filter out the first byte, which contains the first PLC ID, leaving the address of the zone's art in d0
		movea.l	d0,a0				; Load the address of the zone's art into a0 (source)
		lea		($FF0000).l,a1		; Load v_256x256/StartOfRAM (in this context, an art buffer) into a1 (destination)
		bsr.w	KosDec				; Decompress a0 to a1 (Kosinski compression)
 
		move.w	a1,d3				; Move a word of a1 to d3, note that a1 doesn't exactly contain the address of v_256x256/StartOfRAM anymore, after KosDec, a1 now contains v_256x256/StartOfRAM + the size of the file decompressed to it, d3 now contains the length of the file that was decompressed
		move.w	d3,d7				; Move d3 to d7, for use in seperate calculations
 
		andi.w	#$FFF,d3			; Remove the high nibble of the high byte of the length of decompressed file, this nibble is how many $1000 bytes the decompressed art is
		lsr.w	#1,d3				; Half the value of 'length of decompressed file', d3 becomes the 'DMA transfer length'
 
		rol.w	#4,d7				; Rotate (left) length of decompressed file by one nibble
		andi.w	#$F,d7				; Only keep the low nibble of low byte (the same one filtered out of d3 above), this nibble is how many $1000 bytes the decompressed art is
 
@loop:		
		move.w	d7,d2				; Move d7 to d2, note that the ahead dbf removes 1 byte from d7 each time it loops, meaning that the following calculations will have different results each time
		lsl.w	#7,d2
		lsl.w	#5,d2				; Shift (left) d2 by $C, making it high nibble of the high byte, d2 is now the size of the decompressed file rounded down to the nearest $1000 bytes, d2 becomes the 'destination address'
 
		move.l	#$FFFFFF,d1			; Fill d1 with $FF
		move.w	d2,d1				; Move d2 to d1, overwriting the last word of $FF's with d2, this turns d1 into 'StartOfRAM'+'However many $1000 bytes the decompressed art is', d1 becomes the 'source address'
 
		jsr		(QueueDMATransfer).l	; Use d1, d2, and d3 to locate the decompressed art and ready for transfer to VRAM
		move.w	d7,-(sp)			; Store d7 in the Stack
		move.b	#$C,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	RunPLC
		move.w	(sp)+,d7			; Restore d7 from the Stack
		move.w	#$800,d3			; Force the DMA transfer length to be $1000/2 (the first cycle is dynamic because the art's DMA'd backwards)
		dbf		d7,@loop			; Loop for each $1000 bytes the decompressed art is
 
		rts
; End of function LoadZoneTiles


; ---------------------------------------------------------------------------
; Subroutine to load basic level data
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevelDataLoad:				; XREF: GM_Level; GM_Ending
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#4,d0
		lea	(LevelHeaders).l,a2
		lea	(a2,d0.w),a2
		move.l	a2,-(sp)
		addq.l	#4,a2
		movea.l	(a2)+,a0
		lea	(v_16x16).w,a1	; RAM address for 16x16 mappings
		move.w	#0,d0
		bsr.w	EniDec
		movea.l	(a2)+,a0
		lea	(v_256x256).l,a1 ; RAM address for 256x256 mappings
		bsr.w	KosDec
		bsr.w	LevelLayoutLoad
		move.w	(a2)+,d0
		move.w	(a2),d0
		andi.w	#$FF,d0
		cmpi.w	#(id_LZ<<8)+3,(v_zone).w ; is level SBZ3 (LZ4) ?
		bne.s	@notSBZ3	; if not, branch
		moveq	#palid_SBZ3,d0	; use SB3 palette

	@notSBZ3:
		cmpi.w	#(id_SBZ<<8)+1,(v_zone).w ; is level SBZ2?
		beq.s	@isSBZorFZ	; if yes, branch
		cmpi.w	#(id_SBZ<<8)+2,(v_zone).w ; is level FZ?
		bne.s	@normalpal	; if not, branch

	@isSBZorFZ:
		moveq	#palid_SBZ2,d0	; use SBZ2/FZ palette

	@normalpal:
		bsr.w	PalLoad1	; load palette (based on d0)
		movea.l	(sp)+,a2
		addq.w	#4,a2		; read number for 2nd PLC
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	@skipPLC	; if 2nd PLC is 0 (i.e. the ending sequence), branch
		jsr	AddPLC		; load pattern load cues

	@skipPLC:
		rts	
; End of function LevelDataLoad

; ---------------------------------------------------------------------------
; Level	layout loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; 
; LevelLayoutLoad:			; XREF: GM_Title; LevelDataLoad
; 		lea	(v_lvllayout).w,a3
; 		move.w	#$1FF,d1
; 		moveq	#0,d0
; 
; LevLoad_ClrRam:
; 		move.l	d0,(a3)+
; 		dbf	d1,LevLoad_ClrRam ; clear the RAM ($A400-A7FF)
; 
; 		lea	(v_lvllayout).w,a3 ; RAM address for level layout
; 		moveq	#0,d1
; 		bsr.w	LevelLayoutLoad2 ; load	level layout into RAM
; 		lea	(v_lvllayout+$40).w,a3 ; RAM address for background layout
; 		moveq	#2,d1
; ; End of function LevelLayoutLoad
; 
; ; "LevelLayoutLoad2" is	run twice - for	the level and the background
; 
; ; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; 
; 
; LevelLayoutLoad2:			; XREF: LevelLayoutLoad
; 		move.w	(v_zone).w,d0
; 		lsl.b	#6,d0
; 		lsr.w	#5,d0
; 		move.w	d0,d2
; 		add.w	d0,d0
; 		add.w	d2,d0
; 		add.w	d1,d0
; 		lea	(Level_Index).l,a1
; 		move.w	(a1,d0.w),d0
; 		lea	(a1,d0.w),a1
; 		moveq	#0,d1
; 		move.w	d1,d2
; 		move.b	(a1)+,d1	; load level width (in tiles)
; 		move.b	(a1)+,d2	; load level height (in	tiles)
; 
; LevLoad_NumRows:
; 		move.w	d1,d0
; 		movea.l	a3,a0
; 
; LevLoad_Row:
; 		move.b	(a1)+,(a0)+
; 		dbf	d0,LevLoad_Row	; load 1 row
; 		lea	$80(a3),a3	; do next row
; 		dbf	d2,LevLoad_NumRows ; repeat for	number of rows
; 		rts	
; This method now releases free ram space from A408 - A7FF

LevelLayoutLoad:
		move.w	(v_zone).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		move.w	d0,d2
		add.w	d0,d0
		add.w	d2,d0
		lea		(Level_Index).l,a1
		movea.l	(a1,d0.w),a1				; MJ: moving the address strait to a1 rather than adding a word to an address
		move.l	a1,(v_lvllayout).w			; MJ: save location of layout to $FFFFA400
		adda.w	#$0080,a1				; MJ: add 80 (As the BG line is always after the FG line)
		move.l	a1,(v_lvllayout+4).w			; MJ: save location of layout to $FFFFA404
		rts						; MJ Return
; End of function LevelLayoutLoad2

		include	"_inc\DynamicLevelEvents.asm"
		include "_incObj\sub SaveState LoadState.asm"
		include "_incObj\sub CreateMonitorArray.asm"
		include "_incObj\sub GetActFlag SetActFlag.asm"

		include	"_incObj\11 Bridge.asm"

; ---------------------------------------------------------------------------
; Platform subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

PlatformObject:
		lea	(v_player).w,a1
		tst.w	obVelY(a1)	; is Sonic moving up/jumping?
		bmi.w	Plat_Exit	; if yes, branch

;		perform x-axis range check
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	Plat_Exit
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.w	Plat_Exit

	Plat_NoXCheck:
		move.w	obY(a0),d0
		subq.w	#8,d0

Platform3:
;		perform y-axis range check
		move.w	obY(a1),d2
		move.b	obWidth(a1),d1                ; height
		ext.w	d1
		add.w	d2,d1
		addq.w	#4,d1
		sub.w	d1,d0
		bhi.w	Plat_Exit
		cmpi.w	#-$10,d0
		bcs.w	Plat_Exit

		tst.b	(f_lockmulti).w
		bmi.w	Plat_Exit
		cmpi.b	#6,obRoutine(a1)
		bcc.w	Plat_Exit
		add.w	d0,d2
		addq.w	#3,d2
		move.w	d2,obY(a1)
		addq.b	#2,obRoutine(a0)

loc_74AE:
		btst	#3,obStatus(a1)
		beq.s	loc_74DC
		moveq	#0,d0
		move.b	$3D(a1),d0
		lsl.w	#6,d0
		addi.l	#v_objspace&$FFFFFF,d0
		movea.l	d0,a2
		bclr	#3,obStatus(a2)
		clr.b	ob2ndRout(a2)
		cmpi.b	#4,obRoutine(a2)
		bne.s	loc_74DC
		subq.b	#2,obRoutine(a2)

loc_74DC:
		move.w	a0,d0
		subi.w	#-$3000,d0
		lsr.w	#6,d0
		andi.w	#$7F,d0
		move.b	d0,$3D(a1)
		move.b	#0,obAngle(a1)
		move.w	#0,obVelY(a1)
		move.w	obVelX(a1),obInertia(a1)
		btst	#1,obStatus(a1)
		beq.s	loc_7512
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr	Sonic_ResetOnFloor
		movea.l	(sp)+,a0

loc_7512:
		bset	#3,obStatus(a1)
		bset	#3,obStatus(a0)

Plat_Exit:
		rts	
; End of function PlatformObject

; ---------------------------------------------------------------------------
; Sloped platform subroutine (GHZ collapsing ledges and	SLZ seesaws)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SlopeObject:				; XREF: Obj1A_Slope; Obj5E_Slope
		lea	(v_player).w,a1
		tst.w	obVelY(a1)
		bmi.w	Plat_Exit
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	Plat_Exit
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.s	Plat_Exit
		btst	#0,obRender(a0)
		beq.s	loc_754A
		not.w	d0
		add.w	d1,d0

loc_754A:
		lsr.w	#1,d0
		moveq	#0,d3
		move.b	(a2,d0.w),d3
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.w	Platform3
; End of function SlopeObject


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Swing_Solid:				; XREF: Obj15_SetSolid
		lea	(v_player).w,a1
		tst.w	obVelY(a1)
		bmi.w	Plat_Exit
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	Plat_Exit
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.w	Plat_Exit
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.w	Platform3
; End of function Obj15_Solid

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk or jump off	a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ExitPlatform:
		move.w	d1,d2

ExitPlatform2:
		add.w	d2,d2
		lea	(v_player).w,a1
		btst	#1,obStatus(a1)
		bne.s	loc_75E0
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_75E0
		cmp.w	d2,d0
		bcs.s	locret_75F2

loc_75E0:
		bclr	#3,obStatus(a1)
		move.b	#2,obRoutine(a0)
		bclr	#3,obStatus(a0)

locret_75F2:
		rts	
; End of function ExitPlatform


		include	"_incObj\15 Swinging Platforms (part 1).asm"

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's position with a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MvSonicOnPtfm:
		lea	(v_player).w,a1
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.s	MvSonic2
; End of function MvSonicOnPtfm

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's position with a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MvSonicOnPtfm2:
		lea	(v_player).w,a1
		move.w	obY(a0),d0
		subi.w	#9,d0

MvSonic2:
		tst.b	(f_lockmulti).w
		bmi.s	locret_7B62
		cmpi.b	#6,(v_player+obRoutine).w
		bcc.s	locret_7B62
		tst.w	(v_debuguse).w
		bne.s	locret_7B62
		moveq	#0,d1
		move.b	obWidth(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)
		sub.w	obX(a0),d2
		sub.w	d2,obX(a1)

locret_7B62:
		rts	
; End of function MvSonicOnPtfm2

		include	"_incObj\15 Swinging Platforms (part 2).asm"
		include	"_maps\Swinging Platforms (GHZ).asm"
		include	"_maps\Swinging Platforms (SLZ).asm"
		include	"_incObj\17 Spiked Pole Helix.asm"
		include	"_maps\Spiked Pole Helix.asm"
		include	"_incObj\18 Platforms.asm"
		include	"_maps\Platforms (unused).asm"
		include	"_maps\Platforms (GHZ).asm"
		include	"_maps\Platforms (SYZ).asm"
		include	"_maps\Platforms (SLZ).asm"
		include	"_incObj\19.asm"
		include	"_maps\GHZ Ball.asm"
		include	"_incObj\1A Collapsing Ledge (part 1).asm"
		include	"_incObj\53 Collapsing Floors.asm"

; ===========================================================================

Ledge_Fragment:				; XREF: Obj1A_ChkTouch
		move.b	#0,collapse(a0)

loc_847A:				; XREF: Obj1A_Touch
		lea	(CFlo_Data1).l,a4
		moveq	#$15,d1        ;was $18      ; ledge breaks into $19 pieces
		addq.b	#2,obFrame(a0)       ; change mapping to ledge with more sprite pieces

loc_8486:				; XREF: CFlo_Fragment
		moveq	#0,d0
		move.b	obFrame(a0),d0
		add.w	d0,d0
		movea.l	obMap(a0),a3
		adda.w	(a3,d0.w),a3         ; get mapping data
		addq.w	#1,a3                ; skip sprite piece count byte
		bset	#5,obRender(a0)      ; set raw mapping mode flag
		move.b	(a0),d4              ; save object type
		move.b	obRender(a0),d5      ; save render flags
		movea.l	a0,a1                ; reuse this object as first broken piece object
		bra.s	loc_84B2
; ===========================================================================

loc_84AA:
		bsr.w	FindFreeObj
		bne.s	loc_84F2
		addq.w	#5,a3                ; go to next raw mapping piece

loc_84B2:
		move.b	#6,obRoutine(a1)
		move.b	d4,(a1)              ; set object type
		move.l	a3,obMap(a1)         ; point mappings to raw piece data
		move.b	d5,obRender(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.w	obPriority(a0),obPriority(a1)
		move.b	obActWid(a0),obActWid(a1)
		move.b	(a4)+,timedelay(a1)  ; time until this piece starts falling
		cmpa.l	a0,a1
		bcc.s	loc_84EE
		bsr.w	DisplaySprite1

loc_84EE:
		dbf	d1,loc_84AA

loc_84F2:
		bsr.w	DisplaySprite
		sfx	sfx_Collapse,1	; play collapsing sound
; ===========================================================================
; ---------------------------------------------------------------------------
; Disintegration data for collapsing ledges (MZ, SLZ, SBZ)
; ---------------------------------------------------------------------------
CFlo_Data1:	dc.b $1C, $18, $14, $10, $C, $8
                dc.b $1A, $16, $12,  $E, $A, $6, 2
                dc.b $18, $14, $10,  $C,  8, $4
		dc.b $16, $12, $16
CFlo_Data2:	dc.b $1E, $16, $E, 6, $1A, $12,	$A, 2
CFlo_Data3:	dc.b $16, $1E, $1A, $12, 6, $E,	$A, 2

; ---------------------------------------------------------------------------
; Sloped platform subroutine (GHZ collapsing ledges and	MZ platforms)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SlopeObject2:				; XREF: Obj1A_WalkOff; et al
		lea	(v_player).w,a1
		btst	#3,obStatus(a1)
		beq.s	locret_856E
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		lsr.w	#1,d0
		btst	#0,obRender(a0)
		beq.s	loc_854E
		not.w	d0
		add.w	d1,d0

loc_854E:
		moveq	#0,d1
		move.b	(a2,d0.w),d1
		move.w	obY(a0),d0
		sub.w	d1,d0
		moveq	#0,d1
		move.b	obWidth(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)
		sub.w	obX(a0),d2
		sub.w	d2,obX(a1)

locret_856E:
		rts	
; End of function SlopeObject2

; ===========================================================================
; ---------------------------------------------------------------------------
; Collision data for GHZ collapsing ledge
; ---------------------------------------------------------------------------
Ledge_SlopeData:
		incbin	"misc\GHZ Collapsing Ledge Heightmap.bin"
		even

		include	"_maps\Collapsing Ledge.asm"
		include	"_maps\Collapsing Floors.asm"

		include	"_incObj\1C Scenery.asm"
		include	"_maps\Scenery.asm"

		include	"_incObj\1D Unused Switch.asm"
		include	"_maps\Unused Switch.asm"

		include	"_incObj\2A SBZ Small Door.asm"
		include	"_anim\SBZ Small Door.asm"
		include	"_maps\SBZ Small Door.asm"

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj44_SolidWall:			; XREF: Obj44_Solid
		bsr.w	Obj44_SolidWall2
		beq.s	loc_8AA8
		bmi.w	loc_8AC4
	;Mercury Wall Jump
		moveq	#0,d1
	;end Wall Jump
		tst.w	d0
		beq.w	loc_8A92
		bmi.s	loc_8A7C
		tst.w	obVelX(a1)
		bmi.s	loc_8A92
	;Mercury Wall Jump
		move.b	#btnR,d1
	;end Wall Jump
		bra.s	loc_8A82
; ===========================================================================

loc_8A7C:
		tst.w	obVelX(a1)
		bpl.s	loc_8A92
	;Mercury Wall Jump
		move.b	#btnL,d1
	;end Wall Jump

loc_8A82:
		sub.w	d0,obX(a1)
		move.w	#0,obInertia(a1)
		move.w	#0,obVelX(a1)

loc_8A92:
		btst	#1,obStatus(a1)
		bne.s	loc_8AB6
		bset	#5,obStatus(a1)
		bset	#5,obStatus(a0)
		rts	
; ===========================================================================

loc_8AA8:
		btst	#5,obStatus(a0)
		beq.s	locret_8AC2
		move.w	#id_Run,obAnim(a1)

	;Mercury Wall Jump
		bra.s	loc_8AB6pushclear

loc_8AB6:
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr	WallJump
		movea.l	(sp)+,a0

loc_8AB6pushclear:
		bclr	#5,obStatus(a0)
		bclr	#5,obStatus(a1)

locret_8AC2:
		rts	
; ===========================================================================

loc_8AC4:
		tst.w	obVelY(a1)
		bpl.s	locret_8AD8
		tst.w	d3
		bpl.s	locret_8AD8
		sub.w	d3,obY(a1)
		move.w	#0,obVelY(a1)

locret_8AD8:
		rts	
; End of function Obj44_SolidWall


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj44_SolidWall2:			; XREF: Obj44_SolidWall
		lea	(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_8B48
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.s	loc_8B48
		move.b	obWidth(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	obY(a1),d3
		sub.w	obY(a0),d3
		add.w	d2,d3
		bmi.s	loc_8B48
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bcc.s	loc_8B48
		tst.b	(f_lockmulti).w
		bmi.s	loc_8B48
		cmpi.b	#6,(v_player+obRoutine).w
		bcc.s	loc_8B48
		tst.w	(v_debuguse).w
		bne.s	loc_8B48
		move.w	d0,d5
		cmp.w	d0,d1
		bcc.s	loc_8B30
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5
		neg.w	d5

loc_8B30:
		move.w	d3,d1
		cmp.w	d3,d2
		bcc.s	loc_8B3C
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

loc_8B3C:
		cmp.w	d1,d5
		bhi.s	loc_8B44
		moveq	#1,d4
		rts	
; ===========================================================================

loc_8B44:
		moveq	#-1,d4
		rts	
; ===========================================================================

loc_8B48:
		moveq	#0,d4
		rts	
; End of function Obj44_SolidWall2

; ===========================================================================

		include	"_incObj\1E Ball Hog.asm"
		include	"_incObj\20 Cannonball.asm"
		include	"_incObj\24, 27 & 3F Explosions.asm"
		include	"_anim\Ball Hog.asm"
		include	"_maps\Ball Hog.asm"
		include	"_maps\Buzz Bomber Missile Dissolve.asm"
		include	"_maps\Explosions.asm"

		include	"_incObj\28 Animals.asm"
		include	"_incObj\29 Points.asm"
		include	"_maps\Animals 1.asm"
		include	"_maps\Animals 2.asm"
		include	"_maps\Animals 3.asm"
		include	"_maps\Points.asm"

		include	"_incObj\1F Crabmeat.asm"
		include	"_anim\Crabmeat.asm"
		include	"_maps\Crabmeat.asm"
		include	"_incObj\22 Buzz Bomber.asm"
		include	"_incObj\23 Buzz Bomber Missile.asm"
		include	"_anim\Buzz Bomber.asm"
		include	"_anim\Buzz Bomber Missile.asm"
		include	"_maps\Buzz Bomber.asm"
		include	"_maps\Buzz Bomber Missile.asm"


		include	"_incObj\25 & 37 Rings.asm"
		include	"_incObj\4B Giant Ring.asm"
		include	"_incObj\7C Ring Flash.asm"

		include	"_anim\Rings.asm"
		if Revision=0
		include	"_maps\Rings.asm"
		else
			include	"_maps\Rings (JP1).asm"
		endc
		include	"_maps\Giant Ring.asm"
		include	"_maps\Ring Flash.asm"
		include	"_incObj\26 Monitor.asm"
		include	"_incObj\2E Monitor Content Power-Up.asm"
		include	"_incObj\26 Monitor (SolidSides subroutine).asm"
		include	"_anim\Monitor.asm"
		include	"_maps\Monitor.asm"

		include	"_incObj\0E Title Screen Sonic.asm"
		include	"_incObj\0F Press Start and TM.asm"

		include	"_anim\Title Screen Sonic.asm"
		include	"_anim\Press Start and TM.asm"

		include	"_incObj\sub AnimateSprite.asm"

		include	"_maps\Press Start and TM.asm"
		include	"_maps\Title Screen Sonic.asm"

		include	"_incObj\06 Turtroll.asm"
		include	"_maps\Turtroll.asm"
		include	"_anim\Turtroll.asm"
		include	"_incObj\2B Chopper.asm"
		include	"_anim\Chopper.asm"
		include	"_maps\Chopper.asm"
		include	"_incObj\2C Jaws.asm"
		include	"_anim\Jaws.asm"
		include	"_maps\Jaws.asm"
		include	"_incObj\2D Burrobot.asm"
		include	"_anim\Burrobot.asm"
		include	"_maps\Burrobot.asm"

		include	"_incObj\2F MZ Large Grassy Platforms.asm"
		include	"_incObj\35 Burning Grass.asm"
		include	"_anim\Burning Grass.asm"
		include	"_maps\MZ Large Grassy Platforms.asm"
		include	"_maps\Fireballs.asm"
		include	"_incObj\30 MZ Large Green Glass Blocks.asm"
		include	"_maps\MZ Large Green Glass Blocks.asm"
		include	"_incObj\31 Chained Stompers.asm"
		include	"_incObj\45 Sideways Stomper.asm"
		include	"_maps\Chained Stompers.asm"
		include	"_maps\Sideways Stomper.asm"

		include	"_incObj\32 Button.asm"
		include	"_maps\Button.asm"

		include	"_incObj\33 Pushable Blocks.asm"
		include	"_maps\Pushable Blocks.asm"

		include	"_incObj\34 Title Cards.asm"
		include	"_incObj\39 Game Over.asm"
		include	"_incObj\3A Got Through Card.asm"
		include	"_incObj\7E Special Stage Results.asm"
		include	"_incObj\7F SS Result Chaos Emeralds.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - zone title cards
; ---------------------------------------------------------------------------
Map_Card:	dc.w M_Card_GHZ-Map_Card
		dc.w M_Card_LZ-Map_Card
		dc.w M_Card_MZ-Map_Card
		dc.w M_Card_SLZ-Map_Card
		dc.w M_Card_SYZ-Map_Card
		dc.w M_Card_SBZ-Map_Card
		dc.w M_Card_Zone-Map_Card
		dc.w M_Card_Act1-Map_Card
		dc.w M_Card_Act2-Map_Card
		dc.w M_Card_Act3-Map_Card
		dc.w M_Card_Oval-Map_Card
		dc.w M_Card_FZ-Map_Card
		dc.w M_Card_HUBZ-Map_Card
		dc.w M_Card_IntroZ-Map_Card
		dc.w M_Card_Tropic-Map_Card
M_Card_GHZ:	dc.b 9 			; GREEN HILL
		dc.b $F8, 5, 0,	$18, $B4
		dc.b $F8, 5, 0,	$3A, $C4
		dc.b $F8, 5, 0,	$10, $D4
		dc.b $F8, 5, 0,	$10, $E4
		dc.b $F8, 5, 0,	$2E, $F4
		dc.b $F8, 5, 0,	$1C, $14
		dc.b $F8, 1, 0,	$20, $24
		dc.b $F8, 5, 0,	$26, $2C
		dc.b $F8, 5, 0,	$26, $3C
		even
M_Card_LZ:	dc.b 9			; LABYRINTH
		dc.b $F8, 5, 0,	$26, $BC
		dc.b $F8, 5, 0,	0, $CC
		dc.b $F8, 5, 0,	4, $DC
		dc.b $F8, 5, 0,	$4A, $EC
		dc.b $F8, 5, 0,	$3A, $FC
		dc.b $F8, 1, 0,	$20, $C
		dc.b $F8, 5, 0,	$2E, $14
		dc.b $F8, 5, 0,	$42, $24
		dc.b $F8, 5, 0,	$1C, $34
		even
M_Card_MZ:	dc.b 6			; MARBLE
		dc.b $F8, 5, 0,	$2A, $CF
		dc.b $F8, 5, 0,	0, $E0
		dc.b $F8, 5, 0,	$3A, $F0
		dc.b $F8, 5, 0,	4, 0
		dc.b $F8, 5, 0,	$26, $10
		dc.b $F8, 5, 0,	$10, $20
		even
M_Card_SLZ:	dc.b 9			; STAR LIGHT
		dc.b $F8, 5, 0,	$3E, $B4
		dc.b $F8, 5, 0,	$42, $C4
		dc.b $F8, 5, 0,	0, $D4
		dc.b $F8, 5, 0,	$3A, $E4
		dc.b $F8, 5, 0,	$26, 4
		dc.b $F8, 1, 0,	$20, $14
		dc.b $F8, 5, 0,	$18, $1C
		dc.b $F8, 5, 0,	$1C, $2C
		dc.b $F8, 5, 0,	$42, $3C
		even
M_Card_SYZ:	dc.b $A			; SPRING YARD
		dc.b $F8, 5, 0,	$3E, $AC
		dc.b $F8, 5, 0,	$36, $BC
		dc.b $F8, 5, 0,	$3A, $CC
		dc.b $F8, 1, 0,	$20, $DC
		dc.b $F8, 5, 0,	$2E, $E4
		dc.b $F8, 5, 0,	$18, $F4
		dc.b $F8, 5, 0,	$4A, $14
		dc.b $F8, 5, 0,	0, $24
		dc.b $F8, 5, 0,	$3A, $34
		dc.b $F8, 5, 0,	$C, $44
		even
M_Card_SBZ:	dc.b $A			; SCRAP BRAIN
		dc.b $F8, 5, 0,	$3E, $AC
		dc.b $F8, 5, 0,	8, $BC
		dc.b $F8, 5, 0,	$3A, $CC
		dc.b $F8, 5, 0,	0, $DC
		dc.b $F8, 5, 0,	$36, $EC
		dc.b $F8, 5, 0,	4, $C
		dc.b $F8, 5, 0,	$3A, $1C
		dc.b $F8, 5, 0,	0, $2C
		dc.b $F8, 1, 0,	$20, $3C
		dc.b $F8, 5, 0,	$2E, $44
		even
M_Card_Zone:	dc.b 4			; ZONE
		dc.b $F8, 5, 0,	$4E, $E0
		dc.b $F8, 5, 0,	$32, $F0
		dc.b $F8, 5, 0,	$2E, 0
		dc.b $F8, 5, 0,	$10, $10
		even
M_Card_Act1:	dc.b 2			; ACT 1
		dc.b 4,	$C, 0, $53, $EC
		dc.b $F4, 2, 0,	$57, $C
M_Card_Act2:	dc.b 2			; ACT 2
		dc.b 4,	$C, 0, $53, $EC
		dc.b $F4, 6, 0,	$5A, 8
M_Card_Act3:	dc.b 2			; ACT 3
		dc.b 4,	$C, 0, $53, $EC
		dc.b $F4, 6, 0,	$60, 8
M_Card_Oval:	dc.b $D			; Oval
		dc.b $E4, $C, 0, $70, $F4
		dc.b $E4, 2, 0,	$74, $14
		dc.b $EC, 4, 0,	$77, $EC
		dc.b $F4, 5, 0,	$79, $E4
		dc.b $14, $C, $18, $70,	$EC
		dc.b 4,	2, $18,	$74, $E4
		dc.b $C, 4, $18, $77, 4
		dc.b $FC, 5, $18, $79, $C
		dc.b $EC, 8, 0,	$7D, $FC
		dc.b $F4, $C, 0, $7C, $F4
		dc.b $FC, 8, 0,	$7C, $F4
		dc.b 4,	$C, 0, $7C, $EC
		dc.b $C, 8, 0, $7C, $EC
		even
M_Card_FZ:	dc.b 5			; FINAL
		dc.b $F8, 5, 0,	$14, $DC
		dc.b $F8, 1, 0,	$20, $EC
		dc.b $F8, 5, 0,	$2E, $F4
		dc.b $F8, 5, 0,	0, 4
		dc.b $F8, 5, 0,	$26, $14
		even
M_Card_HUBZ:	dc.b 3	                ; HUB
                dc.b $F8, 5, 0, $1C, $1C	; H
		dc.b $F8, 5, 0, $46, $2C	; U
		dc.b $F8, 5, 0, 4, $3C		; B
      		even
M_Card_IntroZ:	dc.b 9
		dc.b $F8, 5, 0, 0, $B0		; A
		dc.b $F8, 5, 0,	$26, $C0	; L
		dc.b $F8, 5, 0, $36, $D0	; P
		dc.b $F8, 5, 0, $1C, $E0	; H
		dc.b $F8, 5, 0, 0, $F0		; A
		dc.b $F8, 5, 0, 4, $10		; B
		dc.b $F8, 5, 0, $10, $20	; E
		dc.b $F8, 5, 0, $42, $30	; T
		dc.b $F8, 5, 0, 0, $40		; A
		even
M_Card_Tropic:	dc.b 3	                ; HUB
                dc.b $F8, 5, 0, $1C, $1C	; H
		dc.b $F8, 5, 0, $46, $2C	; U
		dc.b $F8, 5, 0, 4, $3C		; B
      		even

		include	"_maps\Game Over.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - "SONIC HAS PASSED" title card
; ---------------------------------------------------------------------------
Map_Got:	dc.w M_Got_SonicHas-Map_Got
		dc.w M_Got_Passed-Map_Got
		dc.w M_Got_Score-Map_Got
		dc.w M_Got_TBonus-Map_Got
		dc.w M_Got_RBonus-Map_Got
		dc.w M_Card_Oval-Map_Got
		dc.w M_Card_Act1-Map_Got
		dc.w M_Card_Act2-Map_Got
		dc.w M_Card_Act3-Map_Got
M_Got_SonicHas:	dc.b 8			; SONIC HAS
		dc.b $F8, 5, 0,	$3E, $B8
		dc.b $F8, 5, 0,	$32, $C8
		dc.b $F8, 5, 0,	$2E, $D8
		dc.b $F8, 1, 0,	$20, $E8
		dc.b $F8, 5, 0,	8, $F0
		dc.b $F8, 5, 0,	$1C, $10
		dc.b $F8, 5, 0,	0, $20
		dc.b $F8, 5, 0,	$3E, $30
M_Got_Passed:	dc.b 6			; PASSED
		dc.b $F8, 5, 0,	$36, $D0
		dc.b $F8, 5, 0,	0, $E0
		dc.b $F8, 5, 0,	$3E, $F0
		dc.b $F8, 5, 0,	$3E, 0
		dc.b $F8, 5, 0,	$10, $10
		dc.b $F8, 5, 0,	$C, $20
M_Got_Score:	dc.b 6			; SCORE
		dc.b $F8, $D, 1, $4A, $B0
		dc.b $F8, 1, 1,	$62, $D0
		dc.b $F8, 9, 1,	$64, $18
		dc.b $F8, $D, 1, $6A, $30
		dc.b $F7, 4, 0,	$6E, $CD
		dc.b $FF, 4, $18, $6E, $CD
M_Got_TBonus:	dc.b 7			; TIME BONUS
		dc.b $F8, $D, 1, $5A, $B0
		dc.b $F8, $D, 0, $66, $D9
		dc.b $F8, 1, 1,	$4A, $F9
		dc.b $F7, 4, 0,	$6E, $F6
		dc.b $FF, 4, $18, $6E, $F6
		dc.b $F8, $D, $FF, $F0,	$28
		dc.b $F8, 1, 1,	$70, $48
M_Got_RBonus:	dc.b 7			; RING BONUS
		dc.b $F8, $D, 1, $52, $B0
		dc.b $F8, $D, 0, $66, $D9
		dc.b $F8, 1, 1,	$4A, $F9
		dc.b $F7, 4, 0,	$6E, $F6
		dc.b $FF, 4, $18, $6E, $F6
		dc.b $F8, $D, $FF, $F8,	$28
		dc.b $F8, 1, 1,	$70, $48
		even

; ---------------------------------------------------------------------------
; Sprite mappings - special stage results screen
; ---------------------------------------------------------------------------
Map_SSR:	dc.w M_SSR_Chaos-Map_SSR
		dc.w M_SSR_Score-Map_SSR
		dc.w byte_CD0D-Map_SSR
		dc.w M_Card_Oval-Map_SSR
		dc.w byte_CD31-Map_SSR
		dc.w byte_CD46-Map_SSR
		dc.w byte_CD5B-Map_SSR
		dc.w byte_CD6B-Map_SSR
		dc.w byte_CDA8-Map_SSR
		dc.w M_SSR_blank-Map_SSR              ; $9
		dc.w M_SSR_SonicCan-Map_SSR           ; $A
		dc.w M_SSR_SuperSon-Map_SSR           ; $B
		dc.w M_SSR_SonicGot-Map_SSR           ; $C
		dc.w M_SSR_Chaos2-Map_SSR             ; $D

M_SSR_Chaos:	dc.b $D			; "CHAOS EMERALDS"
		dc.b $F8, 5, 0,	8, $90
		dc.b $F8, 5, 0,	$1C, $A0
		dc.b $F8, 5, 0,	0, $B0
		dc.b $F8, 5, 0,	$32, $C0
		dc.b $F8, 5, 0,	$3E, $D0
		dc.b $F8, 5, 0,	$10, $F0
		dc.b $F8, 5, 0,	$2A, 0
		dc.b $F8, 5, 0,	$10, $10
		dc.b $F8, 5, 0,	$3A, $20
		dc.b $F8, 5, 0,	0, $30
		dc.b $F8, 5, 0,	$26, $40
		dc.b $F8, 5, 0,	$C, $50
		dc.b $F8, 5, 0,	$3E, $60
M_SSR_Score:	dc.b 6			; "SCORE"
		dc.b $F8, $D, 1, $4A, $B0
		dc.b $F8, 1, 1,	$62, $D0
		dc.b $F8, 9, 1,	$64, $18
		dc.b $F8, $D, 1, $6A, $30
		dc.b $F7, 4, 0,	$6E, $CD
		dc.b $FF, 4, $18, $6E, $CD
byte_CD0D:	dc.b 7                  ; RING BONUS
		dc.b $F8, $D, 1, $52, $B0
		dc.b $F8, $D, 0, $66, $D9
		dc.b $F8, 1, 1,	$4A, $F9
		dc.b $F7, 4, 0,	$6E, $F6
		dc.b $FF, 4, $18, $6E, $F6
		dc.b $F8, $D, $FF, $F8,	$28
		dc.b $F8, 1, 1,	$70, $48
byte_CD31:	dc.b 4
		dc.b $F8, $D, $FF, $D1,	$B0
		dc.b $F8, $D, $FF, $D9,	$D0
		dc.b $F8, 1, $FF, $E1, $F0
		dc.b $F8, 6, $1F, $E3, $40
byte_CD46:	dc.b 4
		dc.b $F8, $D, $FF, $D1,	$B0
		dc.b $F8, $D, $FF, $D9,	$D0
		dc.b $F8, 1, $FF, $E1, $F0
		dc.b $F8, 6, $1F, $E9, $40
byte_CD5B:	dc.b 3
		dc.b $F8, $D, $FF, $D1,	$B0
		dc.b $F8, $D, $FF, $D9,	$D0
		dc.b $F8, 1, $FF, $E1, $F0
byte_CD6B:	dc.b $C			; "SPECIAL STAGE"
		dc.b $F8, 5, 0,	$3E, $9C
		dc.b $F8, 5, 0,	$36, $AC
		dc.b $F8, 5, 0,	$10, $BC
		dc.b $F8, 5, 0,	8, $CC
		dc.b $F8, 1, 0,	$20, $DC
		dc.b $F8, 5, 0,	0, $E4
		dc.b $F8, 5, 0,	$26, $F4
		dc.b $F8, 5, 0,	$3E, $14
		dc.b $F8, 5, 0,	$42, $24
		dc.b $F8, 5, 0,	0, $34
		dc.b $F8, 5, 0,	$18, $44
		dc.b $F8, 5, 0,	$10, $54
byte_CDA8:	dc.b $11  			; "SONIC GOT ALL THE"
		dc.b $F8, 5, 0, $3E, $80	; S
		dc.b $F8, 5, 0, $32, $90	; O
		dc.b $F8, 5, 0, $2E, $A0	; N
		dc.b $F8, 1, 0, $20, $B0	; I
		dc.b $F8, 5, 0, 8, $B8		; C
		dc.b $F8, 0, 0, $56, $C8	; Space
		dc.b $F8, 5, 0, $18, $D8	; G
		dc.b $F8, 5, 0, $32, $E8	; O
		dc.b $F8, 5, 0, $42, $F8	; T
		dc.b $F8, 0, 0, $56, $8	; Space
		dc.b $F8, 5, 0, 0, $18		; A
		dc.b $F8, 5, 0, $26, $28	; L
		dc.b $F8, 5, 0, $26, $38	; L
		dc.b $F8, 0, 0, $56, $48	; Space
		dc.b $F8, 5, 0, $42, $58	; T
		dc.b $F8, 5, 0, $1C, $68	; H
		dc.b $F8, 5, 0, $10, $78	; E
M_SSR_blank:    dc.b $0                ; blank spot
M_SSR_SonicCan:	dc.b $D	                        ; NOM SONIC CAN
		dc.b $F8, 5, 0, $2E, $94	; N
		dc.b $F8, 5, 0, $32, $A4	; O
		dc.b $F8, 5, $10, $2A, $B4	; M (flipped to be W)
		dc.b $F8, 0, 0, $56, $C4	; Space
		dc.b $F8, 5, 0, $3E, $D4	; S
		dc.b $F8, 5, 0, $32, $E4	; O
		dc.b $F8, 5, 0, $2E, $F4	; N
		dc.b $F8, 1, 0, $20, $4	        ; I
		dc.b $F8, 5, 0, 8, $C		; C
		dc.b $F8, 0, 0, $56, $1C	; Space
		dc.b $F8, 5, 0, 8, $2C		; C
		dc.b $F8, 5, 0, 0, $3C		; A
		dc.b $F8, 5, 0, $2E, $4C	; N
M_SSR_SuperSon:	dc.b $E	                        ; BE SUPER SONIC
		dc.b $F8, 5, 0, 4, $8C		; B
		dc.b $F8, 5, 0, $10, $9C	; E
		dc.b $F8, 0, 0, $56, $AC	; Space
		dc.b $F8, 5, 0, $3E, $BC	; S
		dc.b $F8, 5, 0, $46, $CC	; U
		dc.b $F8, 5, 0, $36, $DC	; P
		dc.b $F8, 5, 0, $10, $EC	; E
		dc.b $F8, 5, 0, $3A, $FC	; R
		dc.b $F8, 0, 0, $56, $C	; Space
		dc.b $F8, 5, 0, $3E, $1C	; S
		dc.b $F8, 5, 0, $32, $2C	; O
		dc.b $F8, 5, 0, $2E, $3C	; N
		dc.b $F8, 1, 0, $20, $4C	; I
		dc.b $F8, 5, 0, 8, $54		; C
M_SSR_SonicGot:	dc.b $B	                        ;  SONIC GOT A
		dc.b $F8, 5, 0, $3E, $A0	; S
		dc.b $F8, 5, 0, $32, $B0	; O
		dc.b $F8, 5, 0, $2E, $C0	; N
		dc.b $F8, 1, 0, $20, $D0	; I
		dc.b $F8, 5, 0, 8, $D8		; C
		dc.b $F8, 0, 0, $56, $E8	; Space
		dc.b $F8, 5, 0, $18, $F8	; G
		dc.b $F8, 5, 0, $32, $8	; O
		dc.b $F8, 5, 0, $42, $18	; T
		dc.b $F8, 0, 0, $56, $28	; Space
		dc.b $F8, 5, 0, 0, $38		; A
M_SSR_Chaos2:	dc.b $D	                        ; CHAOS EMERALD
		dc.b $F8, 5, 0, 8, $9C		; C
		dc.b $F8, 5, 0, $1C, $AC	; H
		dc.b $F8, 5, 0, 0, $BC		; A
		dc.b $F8, 5, 0, $32, $CC	; O
		dc.b $F8, 5, 0, $3E, $DC	; S
		dc.b $F8, 0, 0, $56, $EC	; Space
		dc.b $F8, 5, 0, $10, $FC	; E
		dc.b $F8, 5, 0, $2A, $C	; M
		dc.b $F8, 5, 0, $10, $1C	; E
		dc.b $F8, 5, 0, $3A, $2C	; R
		dc.b $F8, 5, 0, 0, $3C		; A
		dc.b $F8, 5, 0, $26, $4C	; L
		dc.b $F8, 5, 0, $0C, $5C	; D
                even

		include	"_maps\SS Result Chaos Emeralds.asm"

		include	"_incObj\36 Spikes.asm"
		include	"_maps\Spikes.asm"
		include	"_incObj\3B Purple Rock.asm"
		include	"_incObj\49 Waterfall Sound.asm"
		include	"_maps\Purple Rock.asm"
		include	"_incObj\3C Smashable Wall.asm"

		include	"_incObj\sub SmashObject.asm"

; ===========================================================================
; Smashed block	fragment speeds
;
Smash_FragSpd1:	dc.w $400, -$500	; x-move speed,	y-move speed
		dc.w $600, -$100
		dc.w $600, $100
		dc.w $400, $500
		dc.w $600, -$600
		dc.w $800, -$200
		dc.w $800, $200
		dc.w $600, $600

Smash_FragSpd2:	dc.w -$600, -$600
		dc.w -$800, -$200
		dc.w -$800, $200
		dc.w -$600, $600
		dc.w -$400, -$500
		dc.w -$600, -$100
		dc.w -$600, $100
		dc.w -$400, $500

		include	"_maps\Smashable Walls.asm"

; ---------------------------------------------------------------------------
; Object code execution subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ExecuteObjects:				; XREF: GM_Title; et al
		lea	(v_objspace).w,a0 ; set address for object RAM
		moveq	#$7F,d7           ; run the first $80 objects out of levels
		move.w  #$FFFF,(v_homingdistance).w         ; reset homing attack target
		move.b  #$0,(v_homingtarget).w              ; reset homing attack target
		moveq	#0,d0
		cmpi.b	#6,(v_player+obRoutine).w
		bcc.s	RunObjectsWhenPlayerIsDead          ; if dead, branch

RunObject:
		move.b	(a0),d0		     ; load object number from RAM
		beq.s	@nextobject        ; if it's obj00, skip it
		add.w	d0,d0
		add.w	d0,d0                ; d0 = object ID * 4
		movea.l	Obj_Index-4(pc,d0.w),a1 ; load the address of the object's code
		jsr	(a1)		     ; run the object's code   ; dynamic call! to one of the the entries in Obj_Index
		moveq	#0,d0

         @nextobject:
		lea	$40(a0),a0	     ; next object
		dbf	d7,RunObject
		rts
; ===========================================================================
; this skips certain objects to make enemies and things pause when Sonic dies
RunObjectsWhenPlayerIsDead:
		moveq	#$1F,d7
		bsr.s	RunObject            ; run the first $1F objects normally
		moveq	#$5F,d7

RunObjectDisplayOnly:
		moveq	#0,d0
		move.b	(a0),d0              	; get the object's ID
		beq.s	@nextobject             ; if it's obj00, skip it
		tst.b	obRender(a0)         	; should we render it?
		bpl.s	@nextobject             ; if not, skip it
		move.w  obPriority(a0),d0       ; move object's priority to d0
		btst    #6,obRender(a0)    	; is the compound sprites flag set?
		beq.s   @display            	; if not, branch
		move.w  #$200,d0        	; move $200 to d0
	@display:
		bsr.w	DisplaySprite3

        @nextobject:
		lea	$40(a0),a0           ; next object
		dbf	d7,RunObjectDisplayOnly
		rts	
; End of function ExecuteObjects

; ===========================================================================
; ---------------------------------------------------------------------------
; Object pointers
; ---------------------------------------------------------------------------
Obj_Index:
		include	"_inc\Object Pointers.asm"

		include	"_incObj\sub ObjectFall.asm"
		include	"_incObj\sub SpeedToPos.asm"
		include	"_incObj\sub DisplaySprite.asm"
		include	"_incObj\sub DeleteObject.asm"

; ===========================================================================
BldSpr_ScrPos:	dc.l 0			; blank
		dc.l $FFF700		; main screen x-position
		dc.l $FFF708		; background x-position	1
		dc.l $FFF718		; background x-position	2
; ---------------------------------------------------------------------------
; Subroutine to	convert	mappings (etc) to proper Megadrive sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSprites:				; XREF: GM_Title; et al
		lea	(v_sprites).w,a2          ; set address for sprite table
		moveq	#0,d5
		lea	(v_spritequeue).w,a4
		moveq	#7,d7                     ; 8 priority levels

BuildSprites_LevelLoop:
		tst.w	(a4)                      ; does this level have any objects?
		beq.w	BuildSprites_NextLevel    ; if not, check the next one
		moveq	#2,d6

BuildSprites_ObjLoop:
		movea.w	(a4,d6.w),a0              ; a0=object
		tst.b	(a0)                      ; is this object slot occupied?
		beq.w	BuildSprites_NextObj      ; if not, check next one
		bclr	#7,obRender(a0)           ; clear on-screen flag
		move.b	obRender(a0),d0
		move.b	d0,d4

	        btst	#6,d0	                  ; is the multi-draw flag set?
	        bne.w	BuildSprites_MultiDraw	  ; if it is, branch

		andi.w	#$C,d0                    ; is this to be positioned by screen coordinates?
		beq.s	BuildSprites_ScreenSpaceObj ; if it is, branch
		movea.l	BldSpr_ScrPos(pc,d0.w),a1
		moveq	#0,d0
		move.b	obActWid(a0),d0
		move.w	obX(a0),d3
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1                    ; is the object right edge to the left of the screen?
		bmi.w	BuildSprites_NextObj     ; if it is, branch
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#$140,d1                 ; is the object left edge to the right of the screen?
		bge.s	BuildSprites_NextObj     ; if it is, branch
		addi.w	#$80,d3
		btst	#4,d4                    ; is the accurate Y check flag set?
		beq.s	BuildSprites_ApproxYCheck                 ; if not, branch
		moveq	#0,d0
		move.b	obWidth(a0),d0           ; this actually checks height but the cleverpants who made this disassembly got the names mixed up!!!
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	BuildSprites_NextObj     ; if the object is above the screen
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#$E0,d1
		bge.s	BuildSprites_NextObj     ; if the object is below the screen
		addi.w	#$80,d2
		bra.s	BuildSprites_DrawSprite
; ===========================================================================

BuildSprites_ScreenSpaceObj:
		move.w	$A(a0),d2
		move.w	obX(a0),d3
		bra.s	BuildSprites_DrawSprite
; ===========================================================================

BuildSprites_ApproxYCheck:
		move.w	obY(a0),d2
		sub.w	obMap(a1),d2
		addi.w	#$80,d2
		cmpi.w	#$60,d2                  ; assume Y radius to be 32 pixels
		bcs.s	BuildSprites_NextObj
		cmpi.w	#$180,d2
		bcc.s	BuildSprites_NextObj

BuildSprites_DrawSprite:
		movea.l	obMap(a0),a1
		moveq	#0,d1
		btst	#5,d4                    ; is the static mappings flag set?
		bne.s	loc_D71C                 ; if it is, branch
		move.b	obFrame(a0),d1
		add.w	d1,d1                    ; +++ was .b, changed to increase animation frames
		adda.w	(a1,d1.w),a1
		moveq	#0,d1                    ; +++
                move.b	(a1)+,d1
		subq.b	#1,d1                    ; get number of pieces
		bmi.s	loc_D720                 ; if there are 0 pieces, branch

loc_D71C:
		bsr.w	DrawSprite               ; draw the sprite

loc_D720:
		bset	#7,obRender(a0)          ; set on-screen flag

BuildSprites_NextObj:
		addq.w	#2,d6                    ; load next object
		subq.w	#2,(a4)                  ; decrement object count
		bne.w	BuildSprites_ObjLoop     ; if there are objects left, repeat

BuildSprites_NextLevel:
		lea	$80(a4),a4               ; load next priority level
		dbf	d7,BuildSprites_LevelLoop  ; loop
		move.b	d5,(v_spritecount).w
		cmpi.b	#$50,d5                  ; was the sprite limit reached?
		beq.s	loc_D748                 ; if it was, branch
		move.l	#0,(a2)                  ; set link field to 0
		rts	
loc_D748:
		move.b	#0,-5(a2)                ; set link field to 0
		rts
; ===========================================================================
; loc_1671C:
BuildSprites_MultiDraw:
	move.l	a4,-(sp)
	lea	(v_screenposx).w,a4
	movea.w	obGfx(a0),a3
	movea.l	obMap(a0),a5
	moveq	#0,d0

	; check if object is within X bounds
	move.b	mainspr_width(a0),d0	; load pixel width
	move.w	obX(a0),d3
	sub.w	(a4),d3
	move.w	d3,d1                            
	add.w	d0,d1                            ; is the object right edge to the left of the screen? 
	bmi.w	BuildSprites_MultiDraw_NextObj   ; if it is, branch
	move.w	d3,d1
	sub.w	d0,d1
	cmpi.w	#320,d1                          ; is the object left edge to the right of the screen?
	bge.w	BuildSprites_MultiDraw_NextObj   ; if it is, branch
	addi.w	#128,d3

	; check if object is within Y bounds
	btst	#4,d4                            ; is the accurate Y check flag set?
	beq.s	BuildSpritesMulti_ApproxYCheck
	moveq	#0,d0
	move.b	mainspr_height(a0),d0	         ; load pixel height
	move.w	obY(a0),d2
	sub.w	4(a4),d2
	move.w	d2,d1
	add.w	d0,d1
	bmi.w	BuildSprites_MultiDraw_NextObj  ; if the object is above the screen
	move.w	d2,d1
	sub.w	d0,d1
	cmpi.w	#224,d1
	bge.w	BuildSprites_MultiDraw_NextObj  ; if the object is below the screen
	addi.w	#128,d2
	bra.s	BuildSpritesMulti_DrawSprite
BuildSpritesMulti_ApproxYCheck:
	move.w	obY(a0),d2
	sub.w	4(a4),d2
	addi.w	#128,d2
	andi.w	#$7FF,d2
	cmpi.w	#-32+128,d2
	blo.s	BuildSprites_MultiDraw_NextObj
	cmpi.w	#32+128+224,d2
	bhs.s	BuildSprites_MultiDraw_NextObj
BuildSpritesMulti_DrawSprite:
	moveq	#0,d1
	move.b	mainspr_mapframe(a0),d1	         ; get current frame
	beq.s	@noparenttodraw
	add.w	d1,d1
	movea.l	a5,a1                            ; a5 is obmap(a0), copy to a1
	adda.w	(a1,d1.w),a1
	moveq	#0,d1
	move.b	(a1)+,d1
	subq.b	#1,d1                            ; get number of pieces
	bmi.s	@noparenttodraw                  ; if there are 0 pieces, branch
	move.w	d4,-(sp)
	bsr.w	ChkDrawSprite	                 ; draw the sprite
	move.w	(sp)+,d4
@noparenttodraw:
	ori.b	#$80,obRender(a0)	         ; set onscreen flag
	lea	sub2_x_pos(a0),a6                ; address of first child sprite info
	moveq	#0,d0
	move.b	mainspr_childsprites(a0),d0	 ; get child sprite count
	subq.w	#1,d0		                 ; if there are 0, go to next object
	bcs.s	BuildSprites_MultiDraw_NextObj

@drawchildloop:
	swap	d0
	move.w	(a6)+,d3	                 ; get X pos
	sub.w	(a4),d3                          ; subtract the screen's x position
	addi.w	#128,d3
	move.w	(a6)+,d2	                 ; get Y pos
	sub.w	4(a4),d2                         ; subtract the screen's y position
	addi.w	#128,d2
	andi.w	#$7FF,d2
	addq.w	#1,a6
	moveq	#0,d1
	move.b	(a6)+,d1	                 ; get mapping frame
	add.w	d1,d1
	movea.l	a5,a1
	adda.w	(a1,d1.w),a1
	move.b	(a1)+,d1
	subq.b	#1,d1                            ; get number of pieces
	bmi.s	@nochildleft                     ; if there are 0 pieces, branch
	move.w	d4,-(sp)
	bsr.w	ChkDrawSprite
	move.w	(sp)+,d4
@nochildleft:
	swap	d0
	dbf	d0,@drawchildloop	         ; repeat for number of child sprites
; loc_16804:
BuildSprites_MultiDraw_NextObj:
	movea.l	(sp)+,a4
	bra.w	BuildSprites_NextObj; End of function BuildSprites


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_1680A:
ChkDrawSprite:
	cmpi.b	#80,d5		; has the sprite limit been reached?
	blo.s	DrawSprite_Cont	; if it hasn't, branch
	rts	; otherwise, return
; End of function ChkDrawSprite; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DrawSprite:				; XREF: BuildSprites
		movea.w	obGfx(a0),a3
DrawSprite_Cont:
		btst	#0,d4                    ; is the sprite to be X-flipped?
		bne.s	DrawSprite_FlipX         ; if it is, branch
		btst	#1,d4                    ; is the sprite to be Y-flipped?
		bne.w	DrawSprite_FlipY         ; if it is, branch
; End of function DrawSprite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DrawSprite_Loop:				; XREF: DrawSprite_Loop; SS_ShowLayout
		cmpi.b	#$50,d5
		beq.s	locret_D794
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D78E
		addq.w	#1,d0

loc_D78E:
		move.w	d0,(a2)+
		dbf	d1,DrawSprite_Loop

locret_D794:
		rts	
; End of function DrawSprite_Loop

; ===========================================================================

DrawSprite_FlipX:
		btst	#1,d4
		bne.w	loc_D82A

loc_D79E:
		cmpi.b	#$50,d5
		beq.s	locret_D7E2
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$800,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		neg.w	d0
		add.b	d4,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D7DC
		addq.w	#1,d0

loc_D7DC:
		move.w	d0,(a2)+
		dbf	d1,loc_D79E

locret_D7E2:
		rts	
; ===========================================================================

DrawSprite_FlipY:				; XREF: DrawSprite
		cmpi.b	#$50,d5
		beq.s	locret_D828
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		lsl.b	#3,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1000,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D822
		addq.w	#1,d0

loc_D822:
		move.w	d0,(a2)+
		dbf	d1,DrawSprite_FlipY

locret_D828:
		rts	
; ===========================================================================

loc_D82A:
		cmpi.b	#$50,d5
		beq.s	locret_D87C
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		lsl.b	#3,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1800,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		neg.w	d0
		add.b	d4,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D876
		addq.w	#1,d0

loc_D876:
		move.w	d0,(a2)+
		dbf	d1,loc_D82A

locret_D87C:
		rts

		include	"_incObj\sub ChkObjectVisible.asm"

        if S3KObjectManager=0
		include	"_inc\Object Manager(S1).asm"
	else
		include	"_inc\Object Manager(S3K).asm"
        endif

		include	"_incObj\sub FindFreeObj.asm"
		include	"_incObj\41 Springs.asm"
		include	"_anim\Springs.asm"
		include	"_maps\Springs.asm"


		include	"_incObj\42 Newtron.asm"
		include	"_anim\Newtron.asm"
		include	"_maps\Newtron.asm"
		include	"_incObj\43 Roller.asm"
		include	"_anim\Roller.asm"
		include	"_maps\Roller.asm"

		include	"_incObj\44 GHZ Edge Walls.asm"
		include	"_maps\GHZ Edge Walls.asm"


		include	"_incObj\13 Lava Ball Maker.asm"
		include	"_incObj\14 Lava Ball.asm"
		include	"_anim\Fireballs.asm"

		include	"_incObj\6D Flamethrower.asm"
		include	"_anim\Flamethrower.asm"
		include	"_maps\Flamethrower.asm"

		include	"_incObj\46 MZ Bricks.asm"
		include	"_maps\MZ Bricks.asm"

		include	"_incObj\12 Light.asm"
		include	"_maps\Light.asm"
		include	"_incObj\47 Bumper.asm"
		include	"_anim\Bumper.asm"
		include	"_maps\Bumper.asm"

		include	"_incObj\0D Signpost.asm"

; ---------------------------------------------------------------------------
; Subroutine to	set up bonuses at the end of an	act
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


GotThroughAct:				; XREF: Obj3E_EndAct
		tst.b	(v_objspace+$5C0).w
		bne.s	locret_ECEE
;		move.w	(v_limitright2).w,(v_limitleft2).w
		clr.b	(v_invinc).w	; disable invincibility
		clr.b	(f_timecount).w	; stop time counter
		move.b	#id_GotThroughCard,(v_objspace+$5C0).w
		moveq	#plcid_TitleCard,d0
		jsr	(NewPLC).l	; load title card patterns
		move.b	#1,(f_endactbonus).w
		moveq	#0,d0
		move.b	(v_timemin).w,d0
		mulu.w	#60,d0		; convert minutes to seconds
		moveq	#0,d1
		move.b	(v_timesec).w,d1
		add.w	d1,d0		; add up your time
		divu.w	#15,d0		; divide by 15
		moveq	#$14,d1
		cmp.w	d1,d0		; is time 5 minutes or higher?
		bcs.s	loc_ECD0	; if not, branch
		move.w	d1,d0		; use minimum time bonus (0)

loc_ECD0:
		add.w	d0,d0
		move.w	TimeBonuses(pc,d0.w),(v_timebonus).w ; set time bonus
		move.w	(v_rings).w,d0	; load number of rings
		mulu.w	#10,d0		; multiply by 10
		move.w	d0,(v_ringbonus).w ; set ring bonus
		sfx	bgm_GotThrough	; play "Sonic got through" music

locret_ECEE:
		rts	
; End of function GotThroughAct

; ===========================================================================
TimeBonuses:	dc.w 5000, 5000, 1000, 500, 400, 400, 300, 300,	200, 200
		dc.w 200, 200, 100, 100, 100, 100, 50, 50, 50, 50, 0
; ===========================================================================

locret_ED1A:				; XREF: Obj0D_Index
		rts	
; ===========================================================================

		include	"_anim\Signpost.asm"
		include	"_maps\Signpost.asm"

		include	"_incObj\4C & 4D Lava Geyser Maker.asm"
		include	"_incObj\4E Wall of Lava.asm"
		include	"_incObj\54 Lava Tag.asm"
		include	"_maps\Lava Tag.asm"
		include	"_anim\Lava Geyser.asm"
		include	"_anim\Wall of Lava.asm"
		include	"_maps\Lava Geyser.asm"
		include	"_maps\Wall of Lava.asm"

		include	"_incObj\40 Moto Bug.asm" ; includes "_incObj\sub RememberState.asm"
		include	"_anim\Moto Bug.asm"
		include	"_maps\Moto Bug.asm"
		include	"_incObj\4F Sonic Got PowerUp Card.asm"     ; +++

		include	"_incObj\50 Yadrin.asm"
		include	"_anim\Yadrin.asm"
		include	"_maps\Yadrin.asm"

		include	"_incObj\sub SolidObject.asm"

		include	"_incObj\51 Smashable Green Block.asm"
		include	"_maps\Smashable Green Block.asm"

		include	"_incObj\52 Moving Blocks.asm"
		include	"_maps\Moving Blocks (MZ and SBZ).asm"
		include	"_maps\Moving Blocks (LZ).asm"

		include	"_incObj\55 Basaran.asm"
		include	"_anim\Basaran.asm"
		include	"_maps\Basaran.asm"

		include	"_incObj\56 Floating Blocks and Doors.asm"
		include	"_maps\Floating Blocks and Doors.asm"

		include	"_incObj\57 Spiked Ball and Chain.asm"
		include	"_maps\Spiked Ball and Chain (SYZ).asm"
		include	"_maps\Spiked Ball and Chain (LZ).asm"
		include	"_incObj\58 Big Spiked Ball.asm"
		include	"_maps\Big Spiked Ball.asm"
		include	"_incObj\59 SLZ Elevators.asm"
		include	"_maps\SLZ Elevators.asm"
		include	"_incObj\5A SLZ Circling Platform.asm"
		include	"_maps\SLZ Circling Platform.asm"
		include	"_incObj\5B Staircase.asm"
		include	"_maps\Staircase.asm"
		include	"_incObj\5C Pylon.asm"
		include	"_maps\Pylon.asm"

		include	"_incObj\1B Water Surface.asm"
		include	"_maps\Water Surface.asm"
		include	"_incObj\0B Pole that Breaks.asm"
		include	"_maps\Pole that Breaks.asm"
		include	"_incObj\0C Flapping Door.asm"
		include	"_anim\Flapping Door.asm"
		include	"_maps\Flapping Door.asm"

		include	"_incObj\71 Invisible Barriers.asm"
		include	"_maps\Invisible Barriers.asm"

		include	"_incObj\5D Fan.asm"
		include	"_maps\Fan.asm"
		include	"_incObj\5E Seesaw.asm"
		include	"_maps\Seesaw.asm"
		include	"_maps\Seesaw Ball.asm"
		include	"_incObj\5F Bomb Enemy.asm"
		include	"_anim\Bomb Enemy.asm"
		include	"_maps\Bomb Enemy.asm"

		include	"_incObj\60 Orbinaut.asm"
		include	"_anim\Orbinaut.asm"
		include	"_maps\Orbinaut.asm"

		include	"_incObj\16 Harpoon.asm"
		include	"_anim\Harpoon.asm"
		include	"_maps\Harpoon.asm"
		include	"_incObj\61 LZ Blocks.asm"
		include	"_maps\LZ BLocks.asm"
		include	"_incObj\62 Gargoyle.asm"
		include	"_maps\Gargoyle.asm"
		include	"_incObj\63 LZ Conveyor.asm"
		include	"_maps\LZ Conveyor.asm"
		include	"_incObj\64 Bubbles.asm"
		include	"_anim\Bubbles.asm"
		include	"_maps\Bubbles.asm"
		include	"_incObj\65 Waterfalls.asm"
		include	"_anim\Waterfalls.asm"
		include	"_maps\Waterfalls.asm"
		include	"_incObj\05 SpinDash Dust.asm"	; +++ add the dust object
		include	"_incObj\04 InstaShield.asm"
		include	"_incObj\MTZ Boss.asm"
        include "_incObj\Wfz Boss.asm"
		include	"_incObj\Springboard.asm"
		include	"_incObj\Speed Booster.asm"
		include	"_incObj\Decorative Torch.asm"
		include	"_incObj\Dash Spark.asm"
		include	"_incObj\Leaf Generator.asm"
		include	"_incObj\Island.asm"
		include	"_incObj\HangPoint.asm"
		include	"_incObj\Spring Pole.asm"
		include	"_incObj\Splats.asm"
		include	"_incObj\Teleporter.asm"

		
		even



; ===========================================================================
; ---------------------------------------------------------------------------
; Object 01 - Sonic
; ---------------------------------------------------------------------------

SonicPlayer:				; XREF: Obj_Index
		tst.w	(v_debuguse).w	; is debug mode	being used?
		beq.s	Sonic_Normal	; if not, branch
		jmp	DebugMode
; ===========================================================================

Sonic_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Sonic_Index(pc,d0.w),d1
		jmp	Sonic_Index(pc,d1.w)
; ===========================================================================
Sonic_Index:	dc.w Sonic_Main-Sonic_Index
		dc.w Sonic_Control-Sonic_Index
		dc.w Sonic_Hurt-Sonic_Index
		dc.w Sonic_Death-Sonic_Index
		dc.w Sonic_ResetLevel-Sonic_Index
; ===========================================================================

Sonic_Main:	; Routine 0
		move.b	#$00,(v_layer).w			; MJ: set collision to 1st
		addq.b	#2,obRoutine(a0)
		move.b	#$13,obWidth(a0)
		move.b	#9,obHeight(a0)
		move.l	#Map_Sonic,obMap(a0)
		move.w	#$780,obGfx(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
        jsr     SetStatEffects
		move.b	#id_SpinDashDust,(v_dustobj).w ; load the spindash dust object
		move.b	#id_HomingTarget,(v_homingattackobj).w ; Homing Target object
		move.b	#id_InstaShield,(v_shieldobj).w  ; generic shield object

		move.b	#id_SonicTrail,(v_objspace+$240).w ; load stars object ($3802)
		move.b	#2,(v_objspace+$240+obAnim).w
		move.b	#id_SonicTrail,(v_objspace+$280).w ; load stars object ($3802)
		move.b	#3,(v_objspace+$280+obAnim).w
		move.b	#id_SonicTrail,(v_objspace+$2C0).w ; load stars object ($3802)
		move.b	#4,(v_objspace+$2C0+obAnim).w

Sonic_Control:	; Routine 2

	;Mercury Wall Jump
		tst.b	obWallJump(a0)
		beq.s	@nodec
		subq.b	#1,obWallJump(a0)
		bne.s	@chkLR
		move.b	#id_Roll,obAnim(a0) ; use "jumping" animation
		
	@chkLR:
		move.b	(v_jpadhold2).w,d0	; get jpad
		and.b	(obWallJump+1)(a0),d0	; compare jpad to stored L,R button states
		bne.s	@skip		; if still held, branch
		move.b	#0,obWallJump(a0)	; clear wall jump flag and button states
		move.b	#id_Roll,obAnim(a0) ; use "jumping" animation
	
	@skip:
		;Mercury Wall Jump Smoke Puff
		;USES Smoke Puff
	;	move.b	(v_framebyte).w,d0
	;	andi.b	#7,d0
	;	cmpi.b	#7,d0
	;	bne.s	@nodec
	;create puff
	;	bsr.w	FindFreeObj
	;	bne.s	@nodec
	;	move.b	#id_SmokePuff,0(a1) ; load missile object
	;	move.w	obX(a0),obX(a1)
	;	move.w	obY(a0),obY(a1)
	;	addi.w	#$1C,obY(a1)
	;	move.b	#1,obSubtype(a1)
		;end Wall Jump Smoke Puff
		
	@nodec:
	;end Wall Jump

		tst.w	(f_debugmode).w	; is debug cheat enabled?
		beq.s	loc_12C58	; if not, branch
		btst	#bitB,(v_jpadpress1).w ; is button B pressed?
		beq.s	loc_12C58	; if not, branch
		move.w	#1,(v_debuguse).w ; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		rts	
; ===========================================================================

loc_12C58:
		tst.b	(f_lockctrl).w	; are controls locked?
		bne.s	loc_12C64	; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w ; enable joypad control

loc_12C64:
		btst	#0,(f_lockmulti).w ; are controls locked?
		bne.s	loc_12C7E	; if yes, branch
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	Sonic_Modes(pc,d0.w),d1
		jsr	Sonic_Modes(pc,d1.w)

loc_12C7E:
		bsr.s	Sonic_Display
		bsr.w   Sonic_Super
		bsr.w	Sonic_RecordPosition
		bsr.w	Sonic_Water
		move.b	(v_anglebuffer).w,$36(a0)
		move.b	($FFFFF76A).w,$37(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	loc_12CA6
		tst.b	obAnim(a0)
		bne.s	loc_12CA6
		move.b	obNextAni(a0),obAnim(a0)

loc_12CA6:
		bsr.w	Sonic_Animate
		tst.b	(f_lockmulti).w
		bmi.s	loc_12CB6
		jsr	ReactToItem

loc_12CB6:
		bsr.w	Sonic_Loops
		bsr.w	Sonic_LoadGfx
		rts	
; ===========================================================================
Sonic_Modes:	dc.w Sonic_MdNormal-Sonic_Modes
		dc.w Sonic_MdJump-Sonic_Modes
		dc.w Sonic_MdRoll-Sonic_Modes
		dc.w Sonic_MdJump2-Sonic_Modes
; ---------------------------------------------------------------------------
; Music	to play	after invincibility wears off    +++ don't need this anymore
; ---------------------------------------------------------------------------
;MusicList2:	dc.b bgm_GHZ, bgm_LZ, bgm_MZ, bgm_SLZ, bgm_SYZ, bgm_SBZ
;		even

		include	"_incObj\Sonic Display.asm"
		include	"_incObj\Sonic RecordPosition.asm"
		include	"_incObj\Sonic Water.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Modes	for controlling	Sonic
; ---------------------------------------------------------------------------
Sonic_MdNormal:				; XREF: Sonic_Modes
		bsr.w   Sonic_LightDash       ; +++ light dash
		bsr.w	Sonic_SpinDash	; +++ added Spin Dash
		bsr.w	Sonic_Dash      ; +++ added Mercury's peelout
		bsr.w	Sonic_Jump
		bsr.w	Sonic_SlopeResist
		bsr.w	Sonic_Move
		bsr.w	Sonic_Roll
		bsr.w	Sonic_LevelBound
		jsr	SpeedToPos
		bsr.w	Sonic_AnglePos
		bsr.w	Sonic_SlopeRepel
		bsr.w	Sonic_BoostMode
		rts	
; ===========================================================================
Sonic_MdJump:				; XREF: Sonic_Modes
		bclr	#staSpinDash,obStatus2(a0); clear Spin Dash flag
		bclr	#staDash,obStatus2(a0)	; clear Mercury's Dash flag
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_JumpDirection
		bsr.w	Sonic_LevelBound
		bsr.w   Sonic_DownAttack      ; +++ downwards attack
		bsr.w   Sonic_DoubleJump      ; +++ double jump
		bsr.w   Sonic_JumpDash        ; +++ jump dash / homing attack
		bsr.w   Sonic_LightDash       ; +++ light dash
		jsr	ObjectFall
	;Mercury Wall Jump
		clr.b   (v_justwalljumped).w
                tst.b	obWallJump(a0)
		beq.s	@nowalljump
		subi.w	#$30,obVelY(a0)
		bra.s	@done
		
	@nowalljump:
		btst	#6,obStatus(a0)
		beq.s	@done
		subi.w	#$28,obVelY(a0)	

	@done:
; 		btst	#6,obStatus(a0)
; 		beq.s	loc_12E5C            3 lines commented out
; 		subi.w	#$28,obVelY(a0)      because of walljump
        ;end Wall Jump
loc_12E5C:
		bsr.w	Sonic_JumpAngle
		bsr.w	Sonic_Floor
		rts	
; ===========================================================================

Sonic_MdRoll:				; XREF: Sonic_Modes
		bsr.w	Sonic_Jump
		bsr.w	Sonic_RollRepel
		bsr.w	Sonic_RollSpeed
		bsr.w	Sonic_LevelBound
		jsr	SpeedToPos
		bsr.w	Sonic_AnglePos
		bsr.w	Sonic_SlopeRepel
		bsr.w	Sonic_BoostMode
		rts	
; ===========================================================================

Sonic_MdJump2:				; XREF: Sonic_Modes
		bclr	#staSpinDash,obStatus2(a0); clear Spin Dash flag
		bclr	#staDash,obStatus2(a0)	; clear Mercury's Dash flag
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_JumpDirection
		bsr.w	Sonic_LevelBound
		bsr.w   Sonic_DownAttack      ; +++ downwards attack
		bsr.w   Sonic_DoubleJump      ; +++ double jump
		bsr.w   Sonic_JumpDash        ; +++ jump dash
		bsr.w   Sonic_LightDash       ; +++ light dash
		bsr.w   Sonic_InstaShield     ; +++ instashield
Sonic_Skip_Jumpmoves:		
		jsr	ObjectFall
	;Mercury Wall Jump
		clr.b   (v_justwalljumped).w
		tst.b	obWallJump(a0)
		beq.s	@nowalljump
		subi.w	#$30,obVelY(a0)
		bra.s	@done
		
	@nowalljump:
		btst	#6,obStatus(a0)
		beq.s	@done
		subi.w	#$28,obVelY(a0)	

	@done:
; 		btst	#6,obStatus(a0)
; 		beq.s	loc_12EA6            3 lines commented out
; 		subi.w	#$28,obVelY(a0)      cos of walljump
        ;end Wall Jump

loc_12EA6:
		bsr.w	Sonic_JumpAngle
		bsr.w	Sonic_Floor
		rts	

		include	"_incObj\Sonic Move.asm"
		include	"_incObj\Sonic RollSpeed.asm"
		include	"_incObj\Sonic JumpDirection.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Unused subroutine to squash Sonic
; ---------------------------------------------------------------------------
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_13302
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	locret_13302
		move.w	#0,obInertia(a0) ; stop Sonic moving
		move.w	#0,obVelX(a0)
		move.w	#0,obVelY(a0)
		move.b	#id_Warp3,obAnim(a0) ; use "warping" animation

locret_13302:
		rts	

		include	"_incObj\Sonic LevelBound.asm"
		include	"_incObj\Sonic Roll.asm"
		include	"_incObj\Sonic Jump.asm"
		include	"_incObj\Sonic Double Jump.asm"  ; +++ added Double Jump
		include "_incObj\Sonic Jump Dash.asm"    ; +++ added Jump Dash
		include "_incObj\Sonic Light Dash.asm"   ; +++ added Light Dash
		include "_incObj\Sonic Downwards.asm"    ; +++ added Downwards Attack
		include "_incObj\Sonic InstaShield.asm"  ; +++ added Instashield
		include	"_incObj\Sonic JumpHeight.asm"
		include	"_incObj\Sonic Super.asm"
		include	"_incObj\Sonic SpinDash.asm"     ; +++ added spindash
		include	"_incObj\Sonic Dash.asm"
		include	"_incObj\Sonic Boost Mode.asm"		
		include	"_incObj\Sonic SlopeResist.asm"
		include	"_incObj\Sonic RollRepel.asm"
		include	"_incObj\Sonic SlopeRepel.asm"
		include	"_incObj\Sonic JumpAngle.asm"
		include	"_incObj\Sonic Floor.asm"
		include	"_incObj\Sonic ResetOnFloor.asm"
		include	"_incObj\Sonic (part 2).asm"
		include	"_incObj\Sonic Loops.asm"
		include	"_incObj\Sonic Animate.asm"
		include	"_anim\Sonic.asm"
		include	"_incObj\Sonic LoadGfx.asm"

		include	"_incObj\0A Drowning Countdown.asm"
		


; ---------------------------------------------------------------------------
; Subroutine to	play music for LZ/SBZ3 after a countdown
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ResumeMusic:	; +++			; XREF: Obj64_Wobble; Sonic_Water; Obj0A_ReduceAir
		cmpi.w	#12,(v_air).w	; more than 12 seconds of air left?
		bhi.w	@over12		; if yes, branch
; 		move.w	#bgm_LZ,d0	; play LZ music
; 		cmpi.w	#(id_LZ<<8)+3,(v_zone).w ; check if level is 0103 (SBZ3)
; 		bne.s	@notsbz
; 		move.w	#bgm_SBZ,d0	; play SBZ music
; 
; 	@notsbz:
; 		if Revision=0
; 		else
; 			tst.b	(v_invinc).w ; is Sonic invincible?
; 			beq.s	@notinvinc ; if not, branch
; 			move.w	#bgm_Invincible,d0
; 	@notinvinc:
; 			tst.b	(f_lockscreen).w ; is Sonic at a boss?
; 			beq.s	@playselected ; if not, branch
; 			move.w	#bgm_Boss,d0

     		move.b	(v_lastmusic).w,d0	; restore last music played
		jsr	(PlaySound).l

	@over12:
		move.w	#30,(v_air).w	; reset air to 30 seconds
		clr.b	(v_objspace+$340+$32).w
		rts	
; End of function ResumeMusic

; ===========================================================================

		include	"_anim\Drowning Countdown.asm"
		include	"_maps\Drowning Countdown.asm"

		include	"_incObj\38 Invincibility Stars.asm"
		include	"_incObj\4A Special Stage Entry (Unused).asm"
		include	"_incObj\08 Water Splash.asm"
		include	"_maps\Invincibility Stars.asm"
		include	"_anim\Special Stage Entry (Unused).asm"
		include	"_maps\Special Stage Entry (Unused).asm"
		include	"_anim\Water Splash.asm"
		include	"_maps\Water Splash.asm"

		include	"_incObj\Sonic AnglePos.asm"

		include	"_incObj\sub FindNearestTile.asm"
		include	"_incObj\sub FindFloor.asm"
		include	"_incObj\sub FindWall.asm"

; ---------------------------------------------------------------------------
; Unused floor/wall subroutine - logs something	to do with collision
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


; FloorLog_Unk:				; XREF: GM_Level
; 		rts	
; 
; 		lea	(CollArray1).l,a1
; 		lea	(CollArray1).l,a2
; 		move.w	#$FF,d3
; 
; loc_14C5E:
; 		moveq	#$10,d5
; 		move.w	#$F,d2
; 
; loc_14C64:
; 		moveq	#0,d4
; 		move.w	#$F,d1
; 
; loc_14C6A:
; 		move.w	(a1)+,d0
; 		lsr.l	d5,d0
; 		addx.w	d4,d4
; 		dbf	d1,loc_14C6A
; 
; 		move.w	d4,(a2)+
; 		suba.w	#$20,a1
; 		subq.w	#1,d5
; 		dbf	d2,loc_14C64
; 
; 		adda.w	#$20,a1
; 		dbf	d3,loc_14C5E
; 
; 		lea	(CollArray1).l,a1
; 		lea	(CollArray2).l,a2
; 		bsr.s	FloorLog_Unk2
; 		lea	(CollArray1).l,a1
; 		lea	(CollArray1).l,a2
; 
; ; End of function FloorLog_Unk
; 
; ; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; 
; 
; FloorLog_Unk2:				; XREF: FloorLog_Unk
; 		move.w	#$FFF,d3
; 
; loc_14CA6:
; 		moveq	#0,d2
; 		move.w	#$F,d1
; 		move.w	(a1)+,d0
; 		beq.s	loc_14CD4
; 		bmi.s	loc_14CBE
; 
; loc_14CB2:
; 		lsr.w	#1,d0
; 		bcc.s	loc_14CB8
; 		addq.b	#1,d2
; 
; loc_14CB8:
; 		dbf	d1,loc_14CB2
; 
; 		bra.s	loc_14CD6
; ; ===========================================================================
; 
; loc_14CBE:
; 		cmpi.w	#-1,d0
; 		beq.s	loc_14CD0
; 
; loc_14CC4:
; 		lsl.w	#1,d0
; 		bcc.s	loc_14CCA
; 		subq.b	#1,d2
; 
; loc_14CCA:
; 		dbf	d1,loc_14CC4
; 
; 		bra.s	loc_14CD6
; ; ===========================================================================
; 
; loc_14CD0:
; 		move.w	#$10,d0
; 
; loc_14CD4:
; 		move.w	d0,d2
; 
; loc_14CD6:
; 		move.b	d2,(a2)+
; 		dbf	d3,loc_14CA6
; 
; 		rts	
; 
; ; End of function FloorLog_Unk2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WalkSpeed:			; XREF: Sonic_Move
		move.l	obX(a0),d3
		move.l	obY(a0),d2
		move.w	obVelX(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d3
		move.w	obVelY(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d2
		swap	d2
		swap	d3
		move.b	d0,(v_anglebuffer).w
		move.b	d0,($FFFFF76A).w
		move.b	d0,d1
		addi.b	#$20,d0
		bpl.s	loc_14D1A
		move.b	d1,d0
		bpl.s	loc_14D14
		subq.b	#1,d0

loc_14D14:
		addi.b	#$20,d0
		bra.s	loc_14D24
; ===========================================================================

loc_14D1A:
		move.b	d1,d0
		bpl.s	loc_14D20
		addq.b	#1,d0

loc_14D20:
		addi.b	#$1F,d0

loc_14D24:
		andi.b	#$C0,d0
		beq.w	loc_14DF0
		cmpi.b	#$80,d0
		beq.w	loc_14F7C
		andi.b	#$38,d1
		bne.s	loc_14D3C
		addq.w	#8,d2

loc_14D3C:
		cmpi.b	#$40,d0
		beq.w	loc_1504A
		bra.w	loc_14EBC

; End of function Sonic_WalkSpeed


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_14D48:				; XREF: Sonic_Jump
		move.b	d0,(v_anglebuffer).w
		move.b	d0,($FFFFF76A).w
		addi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	loc_14FD6
		cmpi.b	#$80,d0
		beq.w	Sonic_DontRunOnWalls
		cmpi.b	#$C0,d0
		beq.w	sub_14E50

; End of function sub_14D48

; ---------------------------------------------------------------------------
; Subroutine to	make Sonic land	on the floor after jumping
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_HitFloor:				; XREF: Sonic_Floor

                move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(v_anglebuffer).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
; 		moveq	#$D,d5
; 		bsr.w	FindFloor
		moveq	#$C,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	($FFFFF76A).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
; 		moveq	#$D,d5
; 		bsr.w	FindFloor
		moveq	#$C,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#0,d2

loc_14DD0:
		move.b	($FFFFF76A).w,d3
		cmp.w	d0,d1
		ble.s	loc_14DDE
		move.b	(v_anglebuffer).w,d3
		exg	d0,d1

loc_14DDE:
		btst	#0,d3
		beq.s	locret_14DE6
		move.b	d2,d3

locret_14DE6:
		rts	

; End of function Sonic_HitFloor

; ===========================================================================
		move.w	obY(a0),d2
		move.w	obX(a0),d3

loc_14DF0:				; XREF: Sonic_WalkSpeed
		addi.w	#$A,d2
		lea	(v_anglebuffer).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
; 		moveq	#$E,d5
; 		bsr.w	FindFloor
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.b	#0,d2

loc_14E0A:				; XREF: sub_14EB4
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3
		beq.s	locret_14E16
		move.b	d2,d3

locret_14E16:
		rts	

		include	"_incObj\sub ObjFloorDist.asm"


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_14E50:				; XREF: sub_14D48
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(v_anglebuffer).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
; 		moveq	#$E,d5
; 		bsr.w	FindWall
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF76A).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
; 		moveq	#$E,d5
; 		bsr.w	FindWall
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#-$40,d2
		bra.w	loc_14DD0

; End of function sub_14E50


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_14EB4:				; XREF: Sonic_Floor
		move.w	obY(a0),d2
		move.w	obX(a0),d3

loc_14EBC:
		addi.w	#$A,d3
		lea	(v_anglebuffer).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
; 		moveq	#$E,d5
; 		bsr.w	FindWall
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.b	#-$40,d2
		bra.w	loc_14E0A

; End of function sub_14EB4

; ---------------------------------------------------------------------------
; Subroutine to	detect when an object hits a wall to its right
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitWallRight:
		add.w	obX(a0),d3
		move.w	obY(a0),d2
		lea	(v_anglebuffer).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
; 		moveq	#$E,d5
; 		bsr.w	FindWall
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3
		beq.s	locret_14F06
		move.b	#-$40,d3

locret_14F06:
		rts	

; End of function ObjHitWallRight

; ---------------------------------------------------------------------------
; Subroutine preventing	Sonic from running on walls and	ceilings when he
; touches them
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_DontRunOnWalls:			; XREF: Sonic_Floor; et al
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(v_anglebuffer).w,a4
		movea.w	#-$10,a3
; 		move.w	#$1000,d6
; 		moveq	#$E,d5
; 		bsr.w	FindFloor
		move.w	#$0800,d6                               ; MJ
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	($FFFFF76A).w,a4
		movea.w	#-$10,a3
; 		move.w	#$1000,d6
; 		moveq	#$E,d5
; 		bsr.w	FindFloor
		move.w	#$0800,d6                               ; MJ
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#-$80,d2
		bra.w	loc_14DD0
; End of function Sonic_DontRunOnWalls

; ===========================================================================
		move.w	obY(a0),d2
		move.w	obX(a0),d3

loc_14F7C:
		subi.w	#$A,d2
		eori.w	#$F,d2
		lea	(v_anglebuffer).w,a4
		movea.w	#-$10,a3
; 		move.w	#$1000,d6
; 		moveq	#$E,d5
; 		bsr.w	FindFloor
		move.w	#$0800,d6                               ; MJ
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.b	#-$80,d2
		bra.w	loc_14E0A

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitCeiling:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		lea	(v_anglebuffer).w,a4
		movea.w	#-$10,a3
; 		move.w	#$1000,d6
; 		moveq	#$E,d5
; 		bsr.w	FindFloor
		move.w	#$0800,d6                               ; MJ
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3
		beq.s	locret_14FD4
		move.b	#-$80,d3

locret_14FD4:
		rts	
; End of function ObjHitCeiling

; ===========================================================================

loc_14FD6:				; XREF: sub_14D48
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(v_anglebuffer).w,a4
		movea.w	#-$10,a3
; 		move.w	#$800,d6
; 		moveq	#$E,d5
; 		bsr.w	FindWall
		move.w	#$400,d6                                ; MJ
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	($FFFFF76A).w,a4
		movea.w	#-$10,a3
; 		move.w	#$800,d6
; 		moveq	#$E,d5
; 		bsr.w	FindWall
		move.w	#$400,d6
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#$40,d2
		bra.w	loc_14DD0

; ---------------------------------------------------------------------------
; Subroutine to	stop Sonic when	he jumps at a wall
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_HitWall:				; XREF: Sonic_Floor
		move.w	obY(a0),d2
		move.w	obX(a0),d3

loc_1504A:
		subi.w	#$A,d3
		eori.w	#$F,d3
		lea	(v_anglebuffer).w,a4
		movea.w	#-$10,a3
; 		move.w	#$800,d6
; 		moveq	#$E,d5
; 		bsr.w	FindWall
		move.w	#$400,d6                                ; MJ
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.b	#$40,d2
		bra.w	loc_14E0A
; End of function Sonic_HitWall

; ---------------------------------------------------------------------------
; Subroutine to	detect when an object hits a wall to its left
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitWallLeft:
		add.w	obX(a0),d3
		move.w	obY(a0),d2
		; Engine bug: colliding with left walls is erratic with this function.
		; The cause is this: a missing instruction to flip collision on the found
 		; 16x16 block; this one:
 		eori.w	#$F,d3
		lea	(v_anglebuffer).w,a4
		move.b	#0,(a4)
		movea.w	#-$10,a3
; 		move.w	#$800,d6
; 		moveq	#$E,d5
; 		bsr.w	FindWall
		move.w	#$400,d6                                ; MJ
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3
		beq.s	locret_15098
		move.b	#$40,d3

locret_15098:
		rts	
; End of function ObjHitWallLeft

; ===========================================================================

		include	"_incObj\66 Rotating Junction.asm"
		include	"_maps\Rotating Junction.asm"
		include	"_incObj\67 Running Disc.asm"
		include	"_maps\Running Disc.asm"
		include	"_incObj\68 Conveyor Belt.asm"
		include	"_incObj\69 SBZ Spinning Platforms.asm"
		include	"_anim\SBZ Spinning Platforms.asm"
		include	"_maps\Trapdoor.asm"
		include	"_maps\SBZ Spinning Platforms.asm"
		include	"_incObj\6A Saws and Pizza Cutters.asm"
		include	"_maps\Saws and Pizza Cutters.asm"
		include	"_incObj\6B SBZ Stomper and Door.asm"
		include	"_maps\SBZ Stomper and Door.asm"
		include	"_incObj\6C SBZ Vanishing Platforms.asm"
		include	"_anim\SBZ Vanishing Platforms.asm"
		include	"_maps\SBZ Vanishing Platforms.asm"
		include	"_incObj\6E Electrocuter.asm"
		include	"_anim\Electrocuter.asm"
		include	"_maps\Electrocuter.asm"
		include	"_incObj\6F SBZ Spin Platform Conveyor.asm"
		include	"_anim\SBZ Spin Platform Conveyor.asm"

off_164A6:	dc.w word_164B2-off_164A6, word_164C6-off_164A6, word_164DA-off_164A6
		dc.w word_164EE-off_164A6, word_16502-off_164A6, word_16516-off_164A6
word_164B2:	dc.w $10, $E80,	$E14, $370, $EEF, $302,	$EEF, $340, $E14, $3AE
word_164C6:	dc.w $10, $F80,	$F14, $2E0, $FEF, $272,	$FEF, $2B0, $F14, $31E
word_164DA:	dc.w $10, $1080, $1014,	$270, $10EF, $202, $10EF, $240,	$1014, $2AE
word_164EE:	dc.w $10, $F80,	$F14, $570, $FEF, $502,	$FEF, $540, $F14, $5AE
word_16502:	dc.w $10, $1B80, $1B14,	$670, $1BEF, $602, $1BEF, $640,	$1B14, $6AE
word_16516:	dc.w $10, $1C80, $1C14,	$5E0, $1CEF, $572, $1CEF, $5B0,	$1C14, $61E
; ===========================================================================

		include	"_incObj\70 Girder Block.asm"
		include	"_maps\Girder Block.asm"
		include	"_incObj\72 Teleporter.asm"

		include	"_incObj\78 Caterkiller.asm"
		include	"_anim\Caterkiller.asm"
		include	"_maps\Caterkiller.asm"

		include	"_incObj\79 Lamppost.asm"
		include	"_maps\Lamppost.asm"
		include	"_incObj\7D Hidden Bonuses.asm"
		include	"_maps\Hidden Bonuses.asm"

		include	"_incObj\19 Power Up.asm"


		include	"_incObj\8A Credits.asm"
		include	"_maps\Credits.asm"

		include	"_incObj\3D Boss - Green Hill (part 1).asm"

; ---------------------------------------------------------------------------
; Defeated boss	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BossDefeated:
		move.b	(v_vbla_byte).w,d0
		andi.b	#7,d0
		bne.s	locret_178A2
		jsr		FindFreeObj
		bne.s	locret_178A2
		move.b	#id_ExplosionBomb,(a1)	; load explosion object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		jsr		(RandomNumber).l
		move.w	d0,d1
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,obX(a1)
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,obY(a1)

locret_178A2:
		rts	
; End of function BossDefeated

; ---------------------------------------------------------------------------
; Subroutine to	move a boss
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BossMove:
		move.l	$30(a0),d2
		move.l	$38(a0),d3
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,$30(a0)
		move.l	d3,$38(a0)
		rts	
; End of function BossMove

; ===========================================================================

		include	"_incObj\3D Boss - Green Hill (part 2).asm"
		include	"_incObj\48 Eggman's Swinging Ball.asm"
		include	"_anim\Eggman.asm"
		include	"_maps\Eggman.asm"
		include	"_maps\Boss Items.asm"
		include	"_incObj\77 Boss - Labyrinth.asm"
		include	"_incObj\73 Boss - Marble.asm"
		include	"_incObj\74 MZ Boss Fire.asm"

	Obj7A_Delete:
		jmp	DeleteObject

		include	"_incObj\7A Boss - Star Light.asm"
		include	"_incObj\7B SLZ Boss Spikeball.asm"
		include	"_maps\SLZ Boss Spikeball.asm"
		include	"_incObj\75 Boss - Spring Yard.asm"
		include	"_incObj\76 SYZ Boss Blocks.asm"
		include	"_maps\SYZ Boss Blocks.asm"

loc_1982C:				; XREF: loc_19C62; loc_19C80
		jmp	DeleteObject

		include	"_incObj\82 Eggman - Scrap Brain 2.asm"
		include	"_anim\Eggman - Scrap Brain 2 & Final.asm"
		include	"_maps\Eggman - Scrap Brain 2.asm"
		include	"_incObj\83 SBZ Eggman's Crumbling Floor.asm"
		include	"_maps\SBZ Eggman's Crumbling Floor.asm"
		include	"_incObj\85 Boss - Final.asm"
		include	"_anim\FZ Eggman in Ship.asm"
		include	"_maps\FZ Damaged Eggmobile.asm"
		include	"_maps\FZ Eggmobile Legs.asm"
		include	"_incObj\84 FZ Eggman's Cylinders.asm"
		include	"_maps\FZ Eggman's Cylinders.asm"
		include	"_incObj\86 FZ Plasma Ball Launcher.asm"
		include	"_anim\Plasma Ball Launcher.asm"
		include	"_maps\Plasma Ball Launcher.asm"
		include	"_anim\Plasma Balls.asm"
		include	"_maps\Plasma Balls.asm"

		include	"_incObj\3E Prison Capsule.asm"
		include	"_anim\Prison Capsule.asm"
		include	"_maps\Prison Capsule.asm"

		include	"_incObj\sub ReactToItem.asm"
		include	"_incObj\sub SetStatEffects.asm"
		include	"_incObj\sub CheckAbility.asm"
		include	"_incObj\sub DestroyEnemies.asm"

; ---------------------------------------------------------------------------
; Subroutine to	show the special stage layout
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_ShowLayout:				; XREF: GM_Special
		bsr.w	SS_AniWallsRings
		bsr.w	SS_AniItems
		move.w	d5,-(sp)
		lea	($FFFF8000).w,a1
		move.b	(v_ssangle).w,d0
;		andi.b	#$FC,d0                                      ; one line disabled to make the rotation smooth, thanks to Cinossu
		jsr	(CalcSine).l
		move.w	d0,d4
		move.w	d1,d5
		muls.w	#$18,d4
		muls.w	#$18,d5
		moveq	#0,d2
		move.w	(v_screenposx).w,d2
		divu.w	#$18,d2
		swap	d2
		neg.w	d2
		addi.w	#-$B4,d2
		moveq	#0,d3
		move.w	(v_screenposy).w,d3
		divu.w	#$18,d3
		swap	d3
		neg.w	d3
		addi.w	#-$B4,d3
		move.w	#$F,d7

loc_1B19E:
		movem.w	d0-d2,-(sp)
		movem.w	d0-d1,-(sp)
		neg.w	d0
		muls.w	d2,d1
		muls.w	d3,d0
		move.l	d0,d6
		add.l	d1,d6
		movem.w	(sp)+,d0-d1
		muls.w	d2,d0
		muls.w	d3,d1
		add.l	d0,d1
		move.l	d6,d2
		move.w	#$F,d6

loc_1B1C0:
		move.l	d2,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		move.l	d1,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		add.l	d5,d2
		add.l	d4,d1
		dbf	d6,loc_1B1C0

		movem.w	(sp)+,d0-d2
		addi.w	#$18,d3
		dbf	d7,loc_1B19E

		move.w	(sp)+,d5
		lea	($FF0000).l,a0
		moveq	#0,d0
		move.w	(v_screenposy).w,d0
		divu.w	#$18,d0
		mulu.w	#$80,d0
		adda.l	d0,a0
		moveq	#0,d0
		move.w	(v_screenposx).w,d0
		divu.w	#$18,d0
		adda.w	d0,a0
		lea	($FFFF8000).w,a4
		move.w	#$F,d7

loc_1B20C:
		move.w	#$F,d6

loc_1B210:
		moveq	#0,d0
		move.b	(a0)+,d0
		beq.s	loc_1B268
		cmpi.b	#$4E,d0
		bhi.s	loc_1B268
		move.w	(a4),d3
		addi.w	#$120,d3
		cmpi.w	#$70,d3
		bcs.s	loc_1B268
		cmpi.w	#$1D0,d3
		bcc.s	loc_1B268
		move.w	2(a4),d2
		addi.w	#$F0,d2
		cmpi.w	#$70,d2
		bcs.s	loc_1B268
		cmpi.w	#$170,d2
		bcc.s	loc_1B268
		lea	($FF4000).l,a5
		lsl.w	#3,d0
		lea	(a5,d0.w),a5
		movea.l	(a5)+,a1
		move.w	(a5)+,d1
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		movea.w	(a5)+,a3
		moveq	#0,d1
		move.b	(a1)+,d1
		subq.b	#1,d1
		bmi.s	loc_1B268
		jsr	DrawSprite_Loop

loc_1B268:
		addq.w	#4,a4
		dbf	d6,loc_1B210

		lea	$70(a0),a0
		dbf	d7,loc_1B20C

		move.b	d5,(v_spritecount).w
		cmpi.b	#$50,d5
		beq.s	loc_1B288
		move.l	#0,(a2)
		rts	
; ===========================================================================

loc_1B288:
		move.b	#0,-5(a2)
		rts	
; End of function SS_ShowLayout

; ---------------------------------------------------------------------------
; Subroutine to	animate	walls and rings	in the special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_AniWallsRings:			; XREF: SS_ShowLayout
		lea	($FF400C).l,a1
		moveq	#0,d0
		move.b	(v_ssangle).w,d0
		lsr.b	#2,d0
		andi.w	#$F,d0
		moveq	#$23,d1

loc_1B2A4:
		move.w	d0,(a1)
		addq.w	#8,a1
		dbf	d1,loc_1B2A4

		lea	($FF4005).l,a1
		subq.b	#1,(v_ani1_time).w
		bpl.s	loc_1B2C8
		move.b	#7,(v_ani1_time).w
		addq.b	#1,(v_ani1_frame).w
		andi.b	#3,(v_ani1_frame).w

loc_1B2C8:
		move.b	(v_ani1_frame).w,$1D0(a1)
		subq.b	#1,(v_ani2_time).w
		bpl.s	loc_1B2E4
		move.b	#7,(v_ani2_time).w
		addq.b	#1,(v_ani2_frame).w
		andi.b	#1,(v_ani2_frame).w

loc_1B2E4:
		move.b	(v_ani2_frame).w,d0
		move.b	d0,$138(a1)
		move.b	d0,$160(a1)
		move.b	d0,$148(a1)
		move.b	d0,$150(a1)
		move.b	d0,$1D8(a1)
		move.b	d0,$1E0(a1)
		move.b	d0,$1E8(a1)
		move.b	d0,$1F0(a1)
		move.b	d0,$1F8(a1)
		move.b	d0,$200(a1)
		subq.b	#1,(v_ani3_time).w
		bpl.s	loc_1B326
		move.b	#4,(v_ani3_time).w
		addq.b	#1,(v_ani3_frame).w
		andi.b	#3,(v_ani3_frame).w

loc_1B326:
		move.b	(v_ani3_frame).w,d0
		move.b	d0,$168(a1)
		move.b	d0,$170(a1)
		move.b	d0,$178(a1)
		move.b	d0,$180(a1)
		subq.b	#1,(v_ani0_time).w
		bpl.s	loc_1B350
		move.b	#7,(v_ani0_time).w
		subq.b	#1,(v_ani0_frame).w
		andi.b	#7,(v_ani0_frame).w

loc_1B350:
		lea	($FF4016).l,a1
		lea	(SS_WaRiVramSet).l,a0
		moveq	#0,d0
		move.b	(v_ani0_frame).w,d0
		add.w	d0,d0
		lea	(a0,d0.w),a0
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		rts	
; End of function SS_AniWallsRings

; ===========================================================================
SS_WaRiVramSet:	dc.w $142, $6142, $142,	$142, $142, $142, $142,	$6142
		dc.w $142, $6142, $142,	$142, $142, $142, $142,	$6142
		dc.w $2142, $142, $2142, $2142,	$2142, $2142, $2142, $142
		dc.w $2142, $142, $2142, $2142,	$2142, $2142, $2142, $142
		dc.w $4142, $2142, $4142, $4142, $4142,	$4142, $4142, $2142
		dc.w $4142, $2142, $4142, $4142, $4142,	$4142, $4142, $2142
		dc.w $6142, $4142, $6142, $6142, $6142,	$6142, $6142, $4142
		dc.w $6142, $4142, $6142, $6142, $6142,	$6142, $6142, $4142
; ---------------------------------------------------------------------------
; Subroutine to	remove items when you collect them in the special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_RemoveCollectedItem:			; XREF: Obj09_ChkItems
		lea	($FF4400).l,a2
		move.w	#$1F,d0

loc_1B4C4:
		tst.b	(a2)
		beq.s	locret_1B4CE
		addq.w	#8,a2
		dbf	d0,loc_1B4C4

locret_1B4CE:
		rts	
; End of function SS_RemoveCollectedItem

; ---------------------------------------------------------------------------
; Subroutine to	animate	special	stage items when you touch them
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_AniItems:				; XREF: SS_ShowLayout
		lea	($FF4400).l,a0
		move.w	#$1F,d7

loc_1B4DA:
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	loc_1B4E8
		lsl.w	#2,d0
		movea.l	SS_AniIndex-4(pc,d0.w),a1
		jsr	(a1)

loc_1B4E8:
		addq.w	#8,a0

loc_1B4EA:
		dbf	d7,loc_1B4DA

		rts	
; End of function SS_AniItems

; ===========================================================================
SS_AniIndex:	dc.l SS_AniRingSparks
		dc.l SS_AniBumper
		dc.l SS_Ani1Up
		dc.l SS_AniReverse
		dc.l SS_AniEmeraldSparks
		dc.l SS_AniGlassBlock
; ===========================================================================

SS_AniRingSparks:			; XREF: SS_AniIndex
		subq.b	#1,2(a0)
		bpl.s	locret_1B530
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniRingData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B530
		clr.l	(a0)
		clr.l	4(a0)

locret_1B530:
		rts	
; ===========================================================================
SS_AniRingData:	dc.b $42, $43, $44, $45, 0, 0
; ===========================================================================

SS_AniBumper:				; XREF: SS_AniIndex
		subq.b	#1,2(a0)
		bpl.s	locret_1B566
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniBumpData(pc,d0.w),d0
		bne.s	loc_1B564
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$25,(a1)
		rts	
; ===========================================================================

loc_1B564:
		move.b	d0,(a1)

locret_1B566:
		rts	
; ===========================================================================
SS_AniBumpData:	dc.b $32, $33, $32, $33, 0, 0
; ===========================================================================

SS_Ani1Up:				; XREF: SS_AniIndex
		subq.b	#1,2(a0)
		bpl.s	locret_1B596
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_Ani1UpData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B596
		clr.l	(a0)
		clr.l	4(a0)

locret_1B596:
		rts	
; ===========================================================================
SS_Ani1UpData:	dc.b $46, $47, $48, $49, 0, 0
; ===========================================================================

SS_AniReverse:				; XREF: SS_AniIndex
		subq.b	#1,2(a0)
		bpl.s	locret_1B5CC
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniRevData(pc,d0.w),d0
		bne.s	loc_1B5CA
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$2B,(a1)
		rts	
; ===========================================================================

loc_1B5CA:
		move.b	d0,(a1)

locret_1B5CC:
		rts	
; ===========================================================================
SS_AniRevData:	dc.b $2B, $31, $2B, $31, 0, 0
; ===========================================================================

SS_AniEmeraldSparks:			; XREF: SS_AniIndex
		subq.b	#1,2(a0)
		bpl.s	locret_1B60C
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniEmerData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B60C
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#4,($FFFFD024).w
		move.b	#1,(v_got_emerald).w
		sfx	sfx_SSGoal	; play special stage GOAL sound

locret_1B60C:
		rts	
; ===========================================================================
SS_AniEmerData:	dc.b $46, $47, $48, $49, 0, 0
; ===========================================================================

SS_AniGlassBlock:			; XREF: SS_AniIndex
		subq.b	#1,2(a0)
		bpl.s	locret_1B640
		move.b	#1,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniGlassData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B640
		move.b	4(a0),(a1)
		clr.l	(a0)
		clr.l	4(a0)

locret_1B640:
		rts	
; ===========================================================================
SS_AniGlassData:dc.b $4B, $4C, $4D, $4E, $4B, $4C, $4D,	$4E, 0,	0

; ---------------------------------------------------------------------------
; Special stage	layout pointers
; ---------------------------------------------------------------------------
SS_LayoutIndex:
		dc.l SS_1
		dc.l SS_2
		dc.l SS_3
		dc.l SS_4
		dc.l SS_5
		dc.l SS_6
		even

; ---------------------------------------------------------------------------
; Special stage	start locations
; ---------------------------------------------------------------------------
SS_StartLoc:	incbin	"misc\Start Location Array - Special Stages.bin"
		even

; ---------------------------------------------------------------------------
; Subroutine to	load special stage layout
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_Load:				; XREF: GM_Special
		moveq	#0,d0
		move.b	(v_lastspecial).w,d0 ; load number of last special stage entered
		addq.b	#1,(v_lastspecial).w
		cmpi.b	#6,(v_lastspecial).w
		bcs.s	SS_ChkEmldNum
		move.b	#0,(v_lastspecial).w ; reset if higher than 6

SS_ChkEmldNum:
		cmpi.b	#6,(v_emeralds).w ; do you have all emeralds?
		beq.s	SS_LoadData	; if yes, branch
		moveq	#0,d1
		move.b	(v_emeralds).w,d1
		subq.b	#1,d1
		bcs.s	SS_LoadData
		lea	(v_emldlist).w,a3 ; check which emeralds you have

SS_ChkEmldLoop:	
		cmp.b	(a3,d1.w),d0
		bne.s	SS_ChkEmldRepeat
		bra.s	SS_Load
; ===========================================================================

SS_ChkEmldRepeat:
		dbf	d1,SS_ChkEmldLoop

SS_LoadData:
		lsl.w	#2,d0
		lea	SS_StartLoc(pc,d0.w),a1
		move.w	(a1)+,(v_player+obX).w
		move.w	(a1)+,(v_player+obY).w
		movea.l	SS_LayoutIndex(pc,d0.w),a0
		lea	($FF4000).l,a1
		move.w	#0,d0
		jsr	(EniDec).l
		lea	($FF0000).l,a1
		move.w	#$FFF,d0

SS_ClrRAM3:
		clr.l	(a1)+
		dbf	d0,SS_ClrRAM3

		lea	($FF1020).l,a1
		lea	($FF4000).l,a0
		moveq	#$3F,d1

loc_1B6F6:
		moveq	#$3F,d2

loc_1B6F8:
		move.b	(a0)+,(a1)+
		dbf	d2,loc_1B6F8

		lea	$40(a1),a1
		dbf	d1,loc_1B6F6

		lea	($FF4008).l,a1
		lea	(SS_MapIndex).l,a0
		moveq	#$4D,d1

loc_1B714:
		move.l	(a0)+,(a1)+
		move.w	#0,(a1)+
		move.b	-4(a0),-1(a1)
		move.w	(a0)+,(a1)+
		dbf	d1,loc_1B714

		lea	($FF4400).l,a1
		move.w	#$3F,d1

loc_1B730:

		clr.l	(a1)+
		dbf	d1,loc_1B730

		rts	
; End of function SS_Load

; ===========================================================================

SS_MapIndex:
		include	"_inc\Special Stage Mappings & VRAM Pointers.asm"

		include	"_maps\SS R Block.asm"
		include	"_maps\SS Glass Block.asm"
		include	"_maps\SS UP Block.asm"
		include	"_maps\SS DOWN Block.asm"
		include	"_maps\SS Chaos Emeralds.asm"

		include	"_incObj\09 Sonic in Special Stage.asm"

		include	"_incObj\10 Homing Target.asm"
		include	"_anim\Homing Target.asm"
		include	"_maps\HomingTarget.asm"

        include "_incObj\03 Plane & Layer Switcher.asm"
        include "_incObj\sub RevealMapTile.asm"

		include	"_inc\AnimateLevelGfx.asm"

		include	"_incObj\21 HUD.asm"
		include	"_maps\HUD.asm"

		include	"_incObj\Sonic Trail Object.asm"

; ---------------------------------------------------------------------------
; Add points subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AddPoints:
		move.b	#1,(f_scorecount).w ; set score counter to update

		if Revision=0
		lea	(v_scorecopy).w,a2
		lea	(v_score).w,a3
		add.l	d0,(a3)		; add d0*10 to the score
		move.l	#999999,d1
		cmp.l	(a3),d1		; is score below 999999?
		bhi.w	@belowmax	; if yes, branch
		move.l	d1,(a3)		; reset	score to 999999
		move.l	d1,(a2)

	@belowmax:
		move.l	(a3),d0
		cmp.l	(a2),d0
		bcs.w	@locret_1C6B6
		move.l	d0,(a2)

		else

			lea     (v_score).w,a3
			add.l   d0,(a3)
			move.l  #999999,d1
			cmp.l   (a3),d1 ; is score below 999999?
			bhi.s   @belowmax ; if yes, branch
			move.l  d1,(a3) ; reset score to 999999
		@belowmax:
			move.l  (a3),d0
			cmp.l   (v_scorelife).w,d0 ; has Sonic got 50000+ points?
			bcs.s   @noextralife ; if not, branch

			addi.l  #5000,(v_scorelife).w ; increase requirement by 50000
	;		tst.b   (v_megadrive).w
	;		bmi.s   @noextralife ; branch if Mega Drive is Japanese   +++ don't branch, give bonus anyway
			addq.b  #1,(v_lives).w ; give extra life
			addq.b  #1,(f_lifecount).w
			music	bgm_ExtraLife,1
		endc

@locret_1C6B6:
@noextralife:
		rts	
; End of function AddPoints

		include	"_inc\HUD_Update.asm"

; ---------------------------------------------------------------------------
; Subroutine to	load countdown numbers on the continue screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ContScrCounter:				; XREF: GM_Continue
		locVRAM	$DF80
		lea	($C00000).l,a6
		lea	(Hud_10).l,a2
		moveq	#1,d6
		moveq	#0,d4
		lea	Art_Hud(pc),a1 ; load numbers patterns

ContScr_Loop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C95A:
		sub.l	d3,d1
		bcs.s	loc_1C962
		addq.w	#1,d2
		bra.s	loc_1C95A
; ===========================================================================

loc_1C962:
		add.l	d3,d1
		lsl.w	#6,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		dbf	d6,ContScr_Loop	; repeat 1 more	time

		rts	
; End of function ContScrCounter

; ===========================================================================
; ---------------------------------------------------------------------------
; HUD counter sizes
; ---------------------------------------------------------------------------
Hud_100000:	dc.l 100000		; XREF: Hud_Score
Hud_10000:	dc.l 10000
Hud_1000:	dc.l 1000		; XREF: Hud_TimeRingBonus
Hud_100:	dc.l 100		; XREF: Hud_Rings
Hud_10:		dc.l 10			; XREF: ContScrCounter; Hud_Secs; Hud_Lives
Hud_1:		dc.l 1			; XREF: Hud_Mins

; ---------------------------------------------------------------------------
; Subroutine to	load time numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Mins:				; XREF: Hud_ChkTime
		lea	(Hud_1).l,a2
		moveq	#0,d6
		bra.s	loc_1C9BA
; End of function Hud_Mins


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Secs:				; XREF: Hud_ChkTime
		lea	(Hud_10).l,a2
		moveq	#1,d6

loc_1C9BA:
		moveq	#0,d4
		lea	Art_Hud(pc),a1

Hud_TimeLoop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C9C4:
		sub.l	d3,d1
		bcs.s	loc_1C9CC
		addq.w	#1,d2
		bra.s	loc_1C9C4
; ===========================================================================

loc_1C9CC:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1C9D6
		move.w	#1,d4

loc_1C9D6:
		lsl.w	#6,d2
		move.l	d0,4(a6)
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		addi.l	#$400000,d0
		dbf	d6,Hud_TimeLoop

		rts	
; End of function Hud_Secs

; ---------------------------------------------------------------------------
; Subroutine to	load time/ring bonus numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_TimeRingBonus:			; XREF: Hud_ChkBonus
		lea	(Hud_1000).l,a2
		moveq	#3,d6
		moveq	#0,d4
		lea	Art_Hud(pc),a1

Hud_BonusLoop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1CA1E:
		sub.l	d3,d1
		bcs.s	loc_1CA26
		addq.w	#1,d2
		bra.s	loc_1CA1E
; ===========================================================================

loc_1CA26:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1CA30
		move.w	#1,d4

loc_1CA30:
		tst.w	d4
		beq.s	Hud_ClrBonus
		lsl.w	#6,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1CA5A:
		dbf	d6,Hud_BonusLoop ; repeat 3 more times

		rts	
; ===========================================================================

Hud_ClrBonus:
		moveq	#$F,d5

Hud_ClrBonusLoop:
		move.l	#0,(a6)
		dbf	d5,Hud_ClrBonusLoop

		bra.s	loc_1CA5A
; End of function Hud_TimeRingBonus

; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed lives	counter	patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Lives:				; XREF: Hud_ChkLives
		move.l	#$7BA00003,d0	; set VRAM address
		moveq	#0,d1
		move.b	(v_lives).w,d1	; load number of lives
		lea	(Hud_10).l,a2
		moveq	#1,d6
		moveq	#0,d4
		lea	Art_LivesNums(pc),a1

Hud_LivesLoop:
		move.l	d0,4(a6)
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1CA90:
		sub.l	d3,d1
		bcs.s	loc_1CA98
		addq.w	#1,d2
		bra.s	loc_1CA90
; ===========================================================================

loc_1CA98:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1CAA2
		move.w	#1,d4

loc_1CAA2:
		tst.w	d4
		beq.s	Hud_ClrLives

loc_1CAA6:
		lsl.w	#5,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1CABC:
		addi.l	#$400000,d0
		dbf	d6,Hud_LivesLoop ; repeat 1 more time

		rts	
; ===========================================================================

Hud_ClrLives:
		tst.w	d6
		beq.s	loc_1CAA6
		moveq	#7,d5

Hud_ClrLivesLoop:
		move.l	#0,(a6)
		dbf	d5,Hud_ClrLivesLoop
		bra.s	loc_1CABC
; End of function Hud_Lives

; ===========================================================================
Art_Hud:	incbin	"artunc\HUD Numbers.bin" ; 8x16 pixel numbers on HUD
		even
Art_LivesNums:	incbin	"artunc\Lives Counter Numbers.bin" ; 8x8 pixel numbers on lives counter
		even
Art_HudText:	incbin	"artunc\HUD Popup Font.bin" ; 8x8 pixel letters in Hud popup
		even

		include	"_incObj\8f HUD Text.asm"
		include	"_maps\HUD Text Box.asm"
		even

		include "_incobj\TeleportBeam.asm"



s2_menuasm:     include 's2_menu.asm'
PauseMenuASM:   include "_inc\menu\PauseMenu.asm"
		include	"_incObj\DebugMode.asm"
		include	"_inc\DebugList.asm"
		include	"_inc\LevelHeaders.asm"
		include	"_inc\Pattern Load Cues.asm"

		align	$100,$FF
		if Revision=0
Nem_SegaLogo:	incbin	"artnem\Sega Logo.bin"	; large Sega logo
		even
Eni_SegaLogo:	incbin	"tilemaps\Sega Logo.bin" ; large Sega logo (mappings)
		even
		else
			dcb.b	$400,$FF
	Nem_SegaLogo:	incbin	"artnem\Sega Logo (JP1).bin" ; large Sega logo
			even
	Eni_SegaLogo:	incbin	"tilemaps\Sega Logo (JP1).bin" ; large Sega logo (mappings)
			even
		endc
Eni_Title:	incbin	"tilemaps\Title Screen.bin" ; title screen foreground (mappings)
		even
Nem_TitleFg:	incbin	"artnem\Title Screen Foreground.bin"
		even
Nem_TitleSonic:	incbin	"artnem\Title Screen Sonic.bin"
		even
Nem_TitleTM:	incbin	"artnem\Title Screen TM.bin"
		even
Eni_JapNames:	incbin	"tilemaps\Hidden Japanese Credits.bin" ; Japanese credits (mappings)
		even
Nem_JapNames:	incbin	"artnem\Hidden Japanese Credits.bin"
		even

		include	"_maps\Sonic.asm"
		include	"_maps\Sonic - Dynamic Gfx Script.asm"

		align $20000
; ---------------------------------------------------------------------------
; Uncompressed graphics	- Sonic
; ---------------------------------------------------------------------------
Art_Sonic:	incbin	"artunc\Sonic.bin"	; Sonic
		even
Art_SonicWallJump:	incbin	"artunc\(Mercury) Sonic WallJump.bin"
		even
Art_SonicSpinDash:	incbin	"artunc\(Mercury) Sonic SpinDash.bin"
		even
Art_SonicDashCD: incbin	"artunc\(Mercury) Sonic DashCD.bin"
                even
Art_SuperSonic: incbin	"artunc\Super Sonic.bin" ; Super Sonic
                even
Art_Balance1:	incbin	"artunc\Sonic Balance.bin"	; Sonic
		even
Art_Balance2:	incbin	"artunc\Sonic Balance2.bin"	; Sonic
		even
Art_SonicFlip:	incbin	"artunc\Sonic Flip.bin"	; Sonic
		even
Art_SonicHang:	incbin	"artunc\Sonic Hanging.bin"	; Sonic
		even
Art_SonicIdle:	incbin	"artunc\Sonic Extra Idle Frames.bin"	; Sonic
		even
Art_SonicStomp:	incbin	"artunc\Sonic Stomp.bin"	; Sonic CD 
		even
Art_SonicGrind:	incbin	"artunc\Sonic Grind.bin"	; Sonic
		even
Art_InstaShield:incbin  "artunc\Instashield.bin"
                even
Art_FireShield: incbin  "artunc\Fire Shield.bin"
                even
Art_Stars:      incbin  "artunc\Invincibility Stars.bin"
                even
Art_Dust	incbin	"artunc\spindust.bin"	; Spindash Dust, splash, skid dust, water spray
		even
; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
		if Revision=0
Nem_Smoke:	incbin	"artnem\Unused - Smoke.bin"
		even
Nem_SyzSparkle:	incbin	"artnem\Unused - SYZ Sparkles.bin"
		even
		else
		endc
; Nem_Shield:	incbin	"artnem\Shield.bin"
; 		even
; Nem_Stars:	incbin	"artnem\Invincibility Stars.bin"
; 		even
		if Revision=0
Nem_LzSonic:	incbin	"artnem\Unused - LZ Sonic.bin" ; Sonic holding his breath
		even
Nem_UnkFire:	incbin	"artnem\Unused - Fireball.bin" ; unused fireball
		even
Nem_Warp:	incbin	"artnem\Unused - SStage Flash.bin" ; entry to special stage flash
		even
Nem_Goggle:	incbin	"artnem\Unused - Goggles.bin" ; unused goggles
		even
		else
		endc

		include	"_maps\SS Walls.asm"

; ---------------------------------------------------------------------------
; Compressed graphics - special stage
; ---------------------------------------------------------------------------
Nem_SSWalls:	incbin	"artnem\Special Walls.bin" ; special stage walls
		even
Eni_SSBg1:	incbin	"tilemaps\SS Background 1.bin" ; special stage background (mappings)
		even
Nem_SSBgFish:	incbin	"artnem\Special Birds & Fish.bin" ; special stage birds and fish background
		even
Eni_SSBg2:	incbin	"tilemaps\SS Background 2.bin" ; special stage background (mappings)
		even
Nem_SSBgCloud:	incbin	"artnem\Special Clouds.bin" ; special stage clouds background
		even
Nem_SSGOAL:	incbin	"artnem\Special GOAL.bin" ; special stage GOAL block
		even
Nem_SSRBlock:	incbin	"artnem\Special R.bin"	; special stage R block
		even
Nem_SS1UpBlock:	incbin	"artnem\Special 1UP.bin" ; special stage 1UP block
		even
Nem_SSEmStars:	incbin	"artnem\Special Emerald Twinkle.bin" ; special stage stars from a collected emerald
		even
Nem_SSRedWhite:	incbin	"artnem\Special Red-White.bin" ; special stage red/white block
		even
Nem_SSZone1:	incbin	"artnem\Special ZONE1.bin" ; special stage ZONE1 block
		even
Nem_SSZone2:	incbin	"artnem\Special ZONE2.bin" ; ZONE2 block
		even
Nem_SSZone3:	incbin	"artnem\Special ZONE3.bin" ; ZONE3 block
		even
Nem_SSZone4:	incbin	"artnem\Special ZONE4.bin" ; ZONE4 block
		even
Nem_SSZone5:	incbin	"artnem\Special ZONE5.bin" ; ZONE5 block
		even
Nem_SSZone6:	incbin	"artnem\Special ZONE6.bin" ; ZONE6 block
		even
Nem_SSUpDown:	incbin	"artnem\Special UP-DOWN.bin" ; special stage UP/DOWN block
		even
Nem_SSEmerald:	incbin	"artnem\Special Emeralds.bin" ; special stage chaos emeralds
		even
Nem_SSGhost:	incbin	"artnem\Special Ghost.bin" ; special stage ghost block
		even
Nem_SSWBlock:	incbin	"artnem\Special W.bin"	; special stage W block
		even
Nem_SSGlass:	incbin	"artnem\Special Glass.bin" ; special stage destroyable glass block
		even
Nem_ResultEm:	incbin	"artnem\Special Result Emeralds.bin" ; chaos emeralds on special stage results screen
		even
; ---------------------------------------------------------------------------
; Compressed graphics - GHZ stuff
; ---------------------------------------------------------------------------
Nem_Stalk:	incbin	"artnem\GHZ Flower Stalk.bin"
		even
Nem_Swing:	incbin	"artnem\GHZ Swinging Platform.bin"
		even
Nem_Bridge:	incbin	"artnem\GHZ Bridge.bin"
		even
Nem_GhzUnkBlock:incbin	"artnem\Unused - GHZ Block.bin"
		even
Nem_Ball:	incbin	"artnem\GHZ Giant Ball.bin"
		even
Nem_Spikes:	incbin	"artnem\Spikes.bin"
		even
Nem_GhzLog:	incbin	"artnem\Unused - GHZ Log.bin"
		even
Nem_SpikePole:	incbin	"artnem\GHZ Spiked Log.bin"
		even
Nem_PplRock:	incbin	"artnem\GHZ Purple Rock.bin"
		even
Nem_GhzWall1:	incbin	"artnem\GHZ Breakable Wall.bin"
		even
Nem_GhzWall2:	incbin	"artnem\GHZ Edge Wall.bin"
		even
Nem_MonitorSpinDash:	incbin	"artnem\Monitor Spin Dash.bin"     ; +++
		even
Nem_GHZplatform:incbin	"artnem\GHZ Platform.bin"
		even
Nem_Springboard:	incbin	"artnem\Springboard.bin"
		even
Nem_Leaves:	incbin	"artnem\GHZ Leaves.bin"
		even
Nem_SpringPole:	incbin	"artnem\Springy Pole.bin"
		even
Nem_Island:	incbin	"artnem\Island.bin"
		even


; ---------------------------------------------------------------------------
; Compressed graphics - LZ stuff
; ---------------------------------------------------------------------------
Nem_Water:	incbin	"artnem\LZ Water Surface.bin"
		even
Nem_Splash:	incbin	"artnem\LZ Water & Splashes.bin"
		even
Nem_LzSpikeBall:incbin	"artnem\LZ Spiked Ball & Chain.bin"
		even
Nem_FlapDoor:	incbin	"artnem\LZ Flapping Door.bin"
		even
Nem_Bubbles:	incbin	"artnem\LZ Bubbles & Countdown.bin"
		even
Nem_LzBlock3:	incbin	"artnem\LZ 32x16 Block.bin"
		even
Nem_LzDoor1:	incbin	"artnem\LZ Vertical Door.bin"
		even
Nem_Harpoon:	incbin	"artnem\LZ Harpoon.bin"
		even
Nem_LzPole:	incbin	"artnem\LZ Breakable Pole.bin"
		even
Nem_LzDoor2:	incbin	"artnem\LZ Horizontal Door.bin"
		even
Nem_LzWheel:	incbin	"artnem\LZ Wheel.bin"
		even
Nem_Gargoyle:	incbin	"artnem\LZ Gargoyle & Fireball.bin"
		even
Nem_LzBlock2:	incbin	"artnem\LZ Blocks.bin"
		even
Nem_LzPlatfm:	incbin	"artnem\LZ Rising Platform.bin"
		even
Nem_Cork:	incbin	"artnem\LZ Cork.bin"
		even
Nem_LzBlock1:	incbin	"artnem\LZ 32x32 Block.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - MZ stuff
; ---------------------------------------------------------------------------
Nem_MzMetal:	incbin	"artnem\MZ Metal Blocks.bin"
		even
Nem_MzSwitch:	incbin	"artnem\MZ Switch.bin"
		even
Nem_MzGlass:	incbin	"artnem\MZ Green Glass Block.bin"
		even
Nem_UnkGrass:	incbin	"artnem\Unused - Grass.bin"
		even
Nem_MzFire:		incbin	"artnem\Fireballs.bin"
		even
Nem_Lava:		incbin	"artnem\MZ Lava.bin"
		even
Nem_MzBlock:	incbin	"artnem\MZ Green Pushable Block.bin"
		even
Nem_MzUnkBlock:	incbin	"artnem\Unused - MZ Background.bin"
		even
Nem_MonitorDJump:	incbin	"artnem\Monitor Double Jump.bin"      ; +++ icon for double jump
		even
Nem_SpeedBooster:	incbin	"artnem\SpeedBooster.bin"      
		even
Nem_Torch:		incbin	"artnem\Torch.bin"      
		even
; ---------------------------------------------------------------------------
; Compressed graphics - SLZ stuff
; ---------------------------------------------------------------------------
Nem_Seesaw:	incbin	"artnem\SLZ Seesaw.bin"
		even
Nem_SlzSpike:	incbin	"artnem\SLZ Little Spikeball.bin"
		even
Nem_Fan:	incbin	"artnem\SLZ Fan.bin"
		even
Nem_SlzWall:	incbin	"artnem\SLZ Breakable Wall.bin"
		even
Nem_Pylon:	incbin	"artnem\SLZ Pylon.bin"
		even
Nem_SlzSwing:	incbin	"artnem\SLZ Swinging Platform.bin"
		even
Nem_SlzBlock:	incbin	"artnem\SLZ 32x32 Block.bin"
		even
Nem_SlzCannon:	incbin	"artnem\SLZ Cannon.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - SYZ stuff
; ---------------------------------------------------------------------------
Nem_Bumper:	incbin	"artnem\SYZ Bumper.bin"
		even
Nem_SyzSpike2:	incbin	"artnem\SYZ Small Spikeball.bin"
		even
Nem_LzSwitch:	incbin	"artnem\Switch.bin"
		even
Nem_SyzSpike1:	incbin	"artnem\SYZ Large Spikeball.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - SBZ stuff
; ---------------------------------------------------------------------------
Nem_SbzWheel1:	incbin	"artnem\SBZ Running Disc.bin"
		even
Nem_SbzWheel2:	incbin	"artnem\SBZ Junction Wheel.bin"
		even
Nem_Cutter:	incbin	"artnem\SBZ Pizza Cutter.bin"
		even
Nem_Stomper:	incbin	"artnem\SBZ Stomper.bin"
		even
Nem_SpinPform:	incbin	"artnem\SBZ Spinning Platform.bin"
		even
Nem_TrapDoor:	incbin	"artnem\SBZ Trapdoor.bin"
		even
Nem_SbzFloor:	incbin	"artnem\SBZ Collapsing Floor.bin"
		even
Nem_Electric:	incbin	"artnem\SBZ Electrocuter.bin"
		even
Nem_SbzBlock:	incbin	"artnem\SBZ Vanishing Block.bin"
		even
Nem_FlamePipe:	incbin	"artnem\SBZ Flaming Pipe.bin"
		even
Nem_SbzDoor1:	incbin	"artnem\SBZ Small Vertical Door.bin"
		even
Nem_SlideFloor:	incbin	"artnem\SBZ Sliding Floor Trap.bin"
		even
Nem_SbzDoor2:	incbin	"artnem\SBZ Large Horizontal Door.bin"
		even
Nem_Girder:	incbin	"artnem\SBZ Crushing Girder.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - enemies
; ---------------------------------------------------------------------------
Nem_BallHog:	incbin	"artnem\Enemy Ball Hog.bin"
		even
Nem_Crabmeat:	incbin	"artnem\Enemy Crabmeat.bin"
		even
Nem_Turtroll:	incbin	"artnem\Enemy Turtroll.bin"
		even
Nem_Buzz:	incbin	"artnem\Enemy Buzz Bomber.bin"
		even
Nem_UnkExplode:	incbin	"artnem\Unused - Explosion.bin"
		even
Nem_Burrobot:	incbin	"artnem\Enemy Burrobot.bin"
		even
Nem_Chopper:	incbin	"artnem\Enemy Chopper.bin"
		even
Nem_Jaws:	incbin	"artnem\Enemy Jaws.bin"
		even
Nem_Roller:	incbin	"artnem\Enemy Roller.bin"
		even
Nem_Motobug:	incbin	"artnem\Enemy Motobug.bin"
		even
Nem_Newtron:	incbin	"artnem\Enemy Newtron.bin"
		even
Nem_Yadrin:	incbin	"artnem\Enemy Yadrin.bin"
		even
Nem_Basaran:	incbin	"artnem\Enemy Basaran.bin"
		even
Nem_Splats:	incbin	"artnem\Enemy Splats.bin"
		even
Nem_Bomb:	incbin	"artnem\Enemy Bomb.bin"
		even
Nem_Orbinaut:	incbin	"artnem\Enemy Orbinaut.bin"
		even
Nem_Cater:	incbin	"artnem\Enemy Caterkiller.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
Art_TitleCard:	incbin	"artunc\Title Cards.bin"          ; +++ uncompressed version
		even
Art_BigFont:	incbin	"artunc\Big Font.bin"          ; +++ uncompressed version
		even
Nem_TitleCard:	incbin	"artnem\Title Cards.bin"
 		even
Nem_Hud:	incbin	"artnem\HUD Ring.bin"	; HUD Ring
		even
Nem_Hud_BG:	incbin	"artnem\HUD Text BG.bin"
 		even
Nem_Homing:     incbin  "artnem\HomingTarget.bin"
                even
Nem_Ring:	incbin	"artnem\Rings.bin"
		even
Nem_Monitors:	incbin	"artnem\Monitors.bin"
		even
Nem_BossExplode:incbin	"artnem\Boss Explosion.bin"
		even
Nem_Points:	incbin	"artnem\Points.bin"	; points from destroyed enemy or object
		even
Nem_GameOver:	incbin	"artnem\Game Over.bin"	; game over / time over
		even
Nem_HSpring:	incbin	"artnem\Spring Horizontal.bin"
		even
Nem_VSpring:	incbin	"artnem\Spring Vertical.bin"
		even
Nem_DSpring:	incbin	"artnem\Spring Diagonal.bin"
		even
Nem_SignPost:	incbin	"artnem\Signpost.bin"	; end of level signpost
		even
Nem_Lamp:	incbin	"artnem\Lamppost.bin"
		even
Nem_BigFlash:	incbin	"artnem\Giant Ring Flash.bin"
		even
Nem_Bonus:	incbin	"artnem\Hidden Bonuses.bin" ; hidden bonuses at end of a level
		even
; ---------------------------------------------------------------------------
; Compressed graphics - various Kosinski Moduled
; ---------------------------------------------------------------------------
KosM_Teleporter:	incbin	"artkosm\Teleporter.kosm" ; ssz/hpz type teleporter
		even
KosM_Explode:	incbin	"artkosm\Explosion.kosm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - continue screen
; ---------------------------------------------------------------------------
Nem_ContSonic:	incbin	"artnem\Continue Screen Sonic.bin"
		even
Nem_MiniSonic:	incbin	"artnem\Continue Screen Stuff.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - animals
; ---------------------------------------------------------------------------
KosM_Rabbit:	incbin	"artkosm\Animal Rabbit.kosm"
		even
KosM_Chicken:	incbin	"artkosm\Animal Chicken.kosm"
		even
KosM_BlackBird:	incbin	"artkosm\Animal Blackbird.kosm"
		even
KosM_Seal:	incbin	"artkosm\Animal Seal.kosm"
		even
KosM_Pig:	incbin	"artkosm\Animal Pig.kosm"
		even
KosM_Flicky:	incbin	"artkosm\Animal Flicky.kosm"
		even
KosM_Squirrel:	incbin	"artkosm\Animal Squirrel.kosm"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------

Nem_TIT_1st:	incbin	artnem\8x8tit1.bin	; Title primary patterns
		even
Nem_TIT_2nd:	incbin	artnem\8x8tit2.bin	; Title secondary patterns
		even
Blk16_GHZ:	incbin	"map16\GHZ.bin"
		even
Kos_GHZ:	incbin	"artkos\8x8 - GHZ.kos"	; GHZ primary patterns
		even
Blk256_GHZ:	incbin	"map256\GHZ.bin"
		even
Blk16_LZ:	incbin	"map16\LZ.bin"
		even
Kos_LZ:		incbin	"artkos\8x8 - LZ.kos"	; LZ primary patterns
		even
Blk256_LZ:	incbin	"map256\LZ.bin"
		even
Blk16_MZ:	incbin	"map16\MZ.bin"
		even
Kos_MZ:		incbin	"artkos\8x8 - MZ.kos"	; MZ primary patterns
		even
Blk256_MZ:	incbin	"map256\MZ.bin"
		even
Blk16_SLZ:	incbin	"map16\SLZ.bin"
		even
Kos_SLZ:	incbin	"artkos\8x8 - SLZ.kos"	; SLZ primary patterns
		even
Blk256_SLZ:	incbin	"map256\SLZ.bin"
		even
Blk16_SYZ:	incbin	"map16\SYZ.bin"
		even
Kos_SYZ:	incbin	"artkos\8x8 - SYZ.kos"	; SYZ primary patterns
		even
Blk256_SYZ:	incbin	"map256\SYZ.bin"
		even
Blk16_SBZ:	incbin	"map16\SBZ.bin"
		even
Kos_SBZ:	incbin	"artkos\8x8 - SBZ.kos"	; SBZ primary patterns
		even
Blk256_SBZ:	if Revision=0
		incbin	"map256\SBZ.bin"
		else
		incbin	"map256\SBZ (JP1).bin"
		endc
		even
Blk16_HUBZ:	incbin	"map16\HUBZ.bin"
		even
Kos_HUBZ:	incbin	"artkos\8x8 - HUBZ.kos"	; HUBZ primary patterns
		even
Blk256_HUBZ:	incbin	"map256\HUBZ.bin"
		even
Blk16_IntroZ:	incbin	"map16\HUBZ.bin"
		even
Kos_IntroZ:	incbin	"artkos\8x8 - HUBZ.kos"	; HUBZ primary patterns
		even
Blk256_IntroZ:	incbin	"map256\HUBZ.bin"
		even
Blk16_Tropic:	incbin	"map16\Tropic.bin"
		even
Kos_Tropic:	incbin	"artkos\8x8 - Tropic.kos"	; HUBZ primary patterns
		even
Blk256_Tropic:	incbin	"map256\Tropic.bin"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - bosses and ending sequence
; ---------------------------------------------------------------------------
Nem_Eggman:	incbin	"artnem\Boss - Main.bin"
		even
Nem_Weapons:	incbin	"artnem\Boss - Weapons.bin"
		even
Nem_Prison:	incbin	"artnem\Prison Capsule.bin"
		even
Nem_Sbz2Eggman:	incbin	"artnem\Boss - Eggman in SBZ2 & FZ.bin"
		even
Nem_FzBoss:	incbin	"artnem\Boss - Final Zone.bin"
		even
Nem_FzEggman:	incbin	"artnem\Boss - Eggman after FZ Fight.bin"
		even
Nem_Exhaust:	incbin	"artnem\Boss - Exhaust Flame.bin"
		even
Nem_EndEm:	incbin	"artnem\Ending - Emeralds.bin"
		even
Nem_EndSonic:	incbin	"artnem\Ending - Sonic.bin"
		even
Nem_TryAgain:	incbin	"artnem\Ending - Try Again.bin"
		even
Nem_EndEggman:	if Revision=0
		incbin	"artnem\Unused - Eggman Ending.bin"
		else
		endc
		even
Kos_EndFlowers:	incbin	"artkos\Flowers at Ending.bin" ; ending sequence animated flowers
		even
Nem_EndFlower:	incbin	"artnem\Ending - Flowers.bin"
		even
Nem_CreditText:	incbin	"artnem\Ending - Credits.bin"
		even
Nem_EndStH:	incbin	"artnem\Ending - StH Logo.bin"
		even
Nem_EggpodS2:	incbin	"artnem\Eggpod.bin"
		even
Nem_MTZBoss:	incbin	"artnem\MTZ boss.bin"
		even
Nem_EggpodJetsS2: incbin "artnem\Horizontal jet.bin"
		even
Nem_WFZBoss:    incbin	"artnem\WFZ boss.bin"
		even


		if Revision=0
		dcb.b $104,$FF			; why?
		else
		dcb.b $40,$FF
		endc
; ---------------------------------------------------------------------------
; Collision data
; ---------------------------------------------------------------------------
AngleMap:	incbin	"collide\Angle Map.bin"
		even
CollArray1:	incbin	"collide\Collision Array (Normal).bin"
		even
CollArray2:	incbin	"collide\Collision Array (Rotated).bin"
		even
Col_GHZ_1:	incbin	collide\ghz1.bin	; GHZ index 1
		even
Col_GHZ_2:	incbin	collide\ghz2.bin	; GHZ index 2
		even
Col_LZ_1:	incbin	collide\lz1.bin		; LZ index 1
		even
Col_LZ_2:	incbin	collide\lz2.bin		; LZ index 2
		even
Col_MZ_1:	incbin	collide\mz1.bin		; MZ index 1
		even
Col_MZ_2:	incbin	collide\mz2.bin		; MZ index 2
		even
Col_SLZ_1:	incbin	collide\slz1.bin	; SLZ index 1
		even
Col_SLZ_2:	incbin	collide\slz2.bin	; SLZ index 2
		even
Col_SYZ_1:	incbin	collide\syz1.bin	; SYZ index 1
		even
Col_SYZ_2:	incbin	collide\syz2.bin	; SYZ index 2
		even
Col_SBZ_1:	incbin	collide\sbz1.bin	; SBZ index 1
		even
Col_SBZ_2:	incbin	collide\sbz2.bin	; SBZ index 2
		even
Col_HUBZ_1:	incbin	collide\hubz1.bin	; HUBZ index 1
		even
Col_HUBZ_2:	incbin	collide\hubz2.bin	; HUBZ index 2
		even
Col_IntroZ_1:	incbin	collide\hubz1.bin	; IntroZ index 1
		even
Col_IntroZ_2:	incbin	collide\hubz2.bin	; IntroZ index 2
		even
Col_Tropic_1:	incbin	collide\Tropic1.bin	; Tropic index 1
		even
Col_Tropic_2:	incbin	collide\Tropic2.bin	; Tropic index 2
		even

; ---------------------------------------------------------------------------
; Special Stage layouts
; ---------------------------------------------------------------------------
SS_1:		incbin	"sslayout\1.bin"
		even
SS_2:		incbin	"sslayout\2.bin"
		even
SS_3:		incbin	"sslayout\3.bin"
		even
SS_4:		incbin	"sslayout\4.bin"
		even
		if Revision=0
SS_5:		incbin	"sslayout\5.bin"
		even
SS_6:		incbin	"sslayout\6.bin"
		else
	SS_5:		incbin	"sslayout\5 (JP1).bin"
			even
	SS_6:		incbin	"sslayout\6 (JP1).bin"
		endc
		even
; ---------------------------------------------------------------------------
; Animated uncompressed graphics
; ---------------------------------------------------------------------------
Art_GhzWater:	incbin	"artunc\GHZ Waterfall.bin"
		even
Art_GhzFlower1:	incbin	"artunc\GHZ Flower Large.bin"
		even
Art_GhzFlower2:	incbin	"artunc\GHZ Flower Small.bin"
		even
Art_MzLava1:	incbin	"artunc\Lava Animation.bin"
		even
Art_MzLava2:	incbin	"artunc\MZ Lava.bin"
		even
Art_MzTorch:	incbin	"artunc\MZ Background Torch.bin"
		even
Art_SbzSmoke:	incbin	"artunc\SBZ Background Smoke.bin"
		even

ArtUnc_AniHCZ1_WaterlineBelow:
		incbin "artunc\Act1 Water Below 1.bin"
		even
ArtUnc_FixHCZ1_UpperBG1:
		incbin "artunc\Act1 Upper BG 1.bin"
		even
ArtUnc_AniHCZ1_WaterlineAbove:
		incbin "artunc\Act1 Water Above 1.bin"
		even

ArtUnc_FixHCZ1_LowerBG1:	
		incbin "artunc\Act1 Lower BG 1.bin"
		even
ArtUnc_AniHCZ1_WaterlineBelow2:
		incbin "artunc\Act1 Water Below 2.bin"
		even
ArtUnc_FixHCZ1_UpperBG2:
		incbin "artunc\Act1 Upper BG 2.bin"
		even
ArtUnc_AniHCZ1_WaterlineAbove2:
		incbin "artunc\Act1 Water Above 2.bin"
		even
ArtUnc_FixHCZ1_LowerBG2:
		incbin "artunc\Act1 Lower BG 2.bin"
		even

HCZ_WaterlineScroll_Data:
		incbin "misc\HCZ Waterline Scroll Data.bin"
		even

; ---------------------------------------------------------------------------
; Level	layout index
; ---------------------------------------------------------------------------
Level_Index:	dc.l Level_GHZ1, Level_GHZbg, byte_68D70	; MJ: Table needs to be read in long-word as the layouts are now bigger
		dc.l Level_GHZ2, Level_GHZbg, byte_68E3C
		dc.l Level_GHZ3, Level_GHZbg, byte_68F84
		dc.l byte_68F88, byte_68F88, byte_68F88
		dc.l Level_LZ1, Level_LZbg, byte_69190
		dc.l Level_LZ2, Level_LZbg, byte_6922E
		dc.l Level_LZ3, Level_LZbg, byte_6934C
		dc.l Level_SBZ3, Level_LZbg, byte_6940A
		dc.l Level_MZ1, Level_MZ1bg, Level_MZ1
		dc.l Level_MZ2, Level_MZ2bg, byte_6965C
		dc.l Level_MZ3, Level_MZ3bg, byte_697E6
		dc.l byte_697EA, byte_697EA, byte_697EA
		dc.l Level_SLZ1, Level_SLZbg, byte_69B84
		dc.l Level_SLZ2, Level_SLZbg, byte_69B84
		dc.l Level_SLZ3, Level_SLZbg, byte_69B84
		dc.l byte_69B84, byte_69B84, byte_69B84
		dc.l Level_SYZ1, Level_SYZbg, byte_69C7E
		dc.l Level_SYZ2, Level_SYZbg, byte_69D86
		dc.l Level_SYZ3, Level_SYZbg, byte_69EE4
		dc.l byte_69EE8, byte_69EE8, byte_69EE8
		dc.l Level_SBZ1, Level_SBZ1bg, Level_SBZ1bg
		dc.l Level_SBZ2, Level_SBZ2bg, Level_SBZ2bg
		dc.l Level_SBZ2, Level_SBZ2bg, byte_6A2F8
		dc.l byte_6A2FC, byte_6A2FC, byte_6A2FC
		dc.l Level_End, Level_GHZbg, byte_6A320
		dc.l Level_End, Level_GHZbg, byte_6A320
		dc.l byte_6A320, byte_6A320, byte_6A320
		dc.l byte_6A320, byte_6A320, byte_6A320
                dc.l Level_HUBZ1, Level_HUBZbg, byte_6A320
		dc.l Level_HUBZ2, Level_HUBZbg, byte_6A320
		dc.l Level_HUBZ3, Level_HUBZbg, byte_6A320
		dc.l byte_6A320, byte_6A320, byte_6A320
                dc.l Level_IntroZ1, Level_IntroZbg, byte_6A320
		dc.l Level_IntroZ2, Level_IntroZbg, byte_6A320
		dc.l Level_IntroZ3, Level_IntroZbg, byte_6A320
		dc.l byte_6A320, byte_6A320, byte_6A320
                dc.l Level_Tropic1, Level_Tropicbg, byte_6A320
		dc.l Level_Tropic2, Level_Tropicbg, byte_6A320
		dc.l Level_Tropic3, Level_Tropicbg, byte_6A320
		dc.l byte_6A320, byte_6A320, byte_6A320
Level_GHZ1:	incbin	levels\ghz1.bin
		even
byte_68D70:	dc.b 0,	0, 0, 0
Level_GHZ2:	incbin	levels\ghz2.bin
		even
byte_68E3C:	dc.b 0,	0, 0, 0
Level_GHZ3:	incbin	levels\ghz3.bin
		even
Level_GHZbg:	incbin	levels\ghzbg.bin
		even
byte_68F84:	dc.b 0,	0, 0, 0
byte_68F88:	dc.b 0,	0, 0, 0

Level_LZ1:	incbin	levels\lz1.bin
		even
Level_LZbg:	incbin	levels\lzbg.bin
		even
byte_69190:	dc.b 0,	0, 0, 0
Level_LZ2:	incbin	levels\lz2.bin
		even
byte_6922E:	dc.b 0,	0, 0, 0
Level_LZ3:	incbin	levels\lz3.bin
		even
Level_LZ3_WALL:	incbin	levels\lz3_wall.bin	; MJ: layout with LZ's wall change (When the switch is pressed) data is not in ram anymore,
		even				; and altering values in rom is prohibited, so a new layout is loaded in its place.

byte_6934C:	dc.b 0,	0, 0, 0
Level_SBZ3:	incbin	levels\sbz3.bin
		even
byte_6940A:	dc.b 0,	0, 0, 0

Level_MZ1:	incbin	levels\mz1.bin
		even
Level_MZ1bg:	incbin	levels\mz1bg.bin
		even
Level_MZ2:	incbin	levels\mz2.bin
		even
Level_MZ2bg:	incbin	levels\mz2bg.bin
		even
byte_6965C:	dc.b 0,	0, 0, 0
Level_MZ3:	incbin	levels\mz3.bin
		even
Level_MZ3bg:	incbin	levels\mz3bg.bin
		even
byte_697E6:	dc.b 0,	0, 0, 0
byte_697EA:	dc.b 0,	0, 0, 0

Level_SLZ1:	incbin	levels\slz1.bin
		even
Level_SLZbg:	incbin	levels\slzbg.bin
		even
Level_SLZ2:	incbin	levels\slz2.bin
		even
Level_SLZ3:	incbin	levels\slz3.bin
		even
byte_69B84:	dc.b 0,	0, 0, 0

Level_SYZ1:	incbin	levels\syz1.bin
		even
Level_SYZbg:	if Revision=0
		incbin	levels\syzbg.bin
		else
		incbin	"levels\syzbg (JP1).bin"
		endc
		even
byte_69C7E:	dc.b 0,	0, 0, 0
Level_SYZ2:	incbin	levels\syz2.bin
		even
byte_69D86:	dc.b 0,	0, 0, 0
Level_SYZ3:	incbin	levels\syz3.bin
		even
byte_69EE4:	dc.b 0,	0, 0, 0
byte_69EE8:	dc.b 0,	0, 0, 0

Level_SBZ1:	incbin	levels\sbz1.bin
		even
Level_SBZ1bg:	incbin	levels\sbz1bg.bin
		even
Level_SBZ2:	incbin	levels\sbz2.bin
		even
Level_SBZ2bg:	incbin	levels\sbz2bg.bin
		even
byte_6A2F8:	dc.b 0,	0, 0, 0
byte_6A2FC:	dc.b 0,	0, 0, 0
Level_End:	incbin	levels\ending.bin
		even
byte_6A320:	dc.b 0,	0, 0, 0
Level_HUBZ1:	incbin	levels\hubz1.bin
		even
Level_HUBZ2:	incbin	levels\hubz2.bin
		even
Level_HUBZ3:	incbin	levels\hubz3.bin
		even
Level_HUBZbg:	incbin	levels\hubzbg.bin
		even
Level_IntroZ1:	incbin	levels\hubz1.bin
		even
Level_IntroZ2:	incbin	levels\hubz2.bin
		even
Level_IntroZ3:	incbin	levels\hubz3.bin
		even
Level_IntroZbg:	incbin	levels\hubzbg.bin
		even
Level_Tropic1:	incbin	levels\Tropic1.bin
		even
Level_Tropic2:	incbin	levels\Tropic2.bin
		even
Level_Tropic3:	incbin	levels\Tropic3.bin
		even
Level_Tropicbg:	incbin	levels\Tropicbg.bin
		even



Art_BigRing:	incbin	"artunc\Giant Ring.bin"
		even
Art_BigRingFlash:incbin	"artunc\Giant Ring Flash.bin"
		even
		align	$100,$FF

; ---------------------------------------------------------------------------
; Sprite locations index
; ---------------------------------------------------------------------------
ObjPos_Index:	dc.w ObjPos_GHZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index     ; MJ changed this stuff
		dc.w ObjPos_GHZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SBZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SYZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SYZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SYZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SYZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SBZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SBZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_FZ-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SBZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HUBZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HUBZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HUBZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HUBZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
 		dc.w ObjPos_IntroZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
 		dc.w ObjPos_IntroZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
 		dc.w ObjPos_IntroZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
 		dc.w ObjPos_IntroZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
 		dc.w ObjPos_Tropic1-ObjPos_Index, ObjPos_Null-ObjPos_Index
 		dc.w ObjPos_Tropic2-ObjPos_Index, ObjPos_Null-ObjPos_Index
 		dc.w ObjPos_Tropic3-ObjPos_Index, ObjPos_Null-ObjPos_Index
 		dc.w ObjPos_Tropic1-ObjPos_Index, ObjPos_Null-ObjPos_Index
ObjPos_LZxpf_Index:
		dc.w ObjPos_LZ1pf1-ObjPos_Index, ObjPos_LZ1pf2-ObjPos_Index
		dc.w ObjPos_LZ2pf1-ObjPos_Index, ObjPos_LZ2pf2-ObjPos_Index
		dc.w ObjPos_LZ3pf1-ObjPos_Index, ObjPos_LZ3pf2-ObjPos_Index
 		dc.w ObjPos_LZ1pf1-ObjPos_Index, ObjPos_LZ1pf2-ObjPos_Index
ObjPos_SBZ1pf_Index:
		dc.w ObjPos_SBZ1pf1-ObjPos_Index, ObjPos_SBZ1pf2-ObjPos_Index
		dc.w ObjPos_SBZ1pf3-ObjPos_Index, ObjPos_SBZ1pf4-ObjPos_Index
		dc.w ObjPos_SBZ1pf5-ObjPos_Index, ObjPos_SBZ1pf6-ObjPos_Index
 		dc.w ObjPos_SBZ1pf1-ObjPos_Index, ObjPos_SBZ1pf2-ObjPos_Index
		dc.b $FF, $FF, 0, 0, 0,	0
ObjPos_GHZ1:	incbin	objpos\ghz1.bin
		even
ObjPos_GHZ2:	incbin	objpos\ghz2.bin
		even
ObjPos_GHZ3:	incbin	objpos\ghz3.bin
		even
ObjPos_LZ1:	incbin	objpos\lz1.bin
		even
ObjPos_LZ2:	incbin	objpos\lz2.bin
		even
ObjPos_LZ3:	incbin	objpos\lz3.bin
		even
ObjPos_SBZ3:	incbin	objpos\sbz3.bin
		even
ObjPos_MZ1:	incbin	objpos\mz1.bin
		even
ObjPos_MZ2:	incbin	objpos\mz2.bin
		even
ObjPos_MZ3:	incbin	objpos\mz3.bin
		even
ObjPos_SLZ1:	incbin	objpos\slz1.bin
		even
ObjPos_SLZ2:	incbin	objpos\slz2.bin
		even
ObjPos_SLZ3:	incbin	objpos\slz3.bin
		even
ObjPos_SYZ1:	incbin	objpos\syz1.bin
		even
ObjPos_SYZ2:	incbin	objpos\syz2.bin
		even
ObjPos_SYZ3:	incbin	objpos\syz3.bin
		even
ObjPos_SBZ1:	incbin	objpos\sbz1.bin
		even
ObjPos_SBZ2:	incbin	objpos\sbz2.bin
		even
ObjPos_FZ:	incbin	objpos\fz.bin
		even
ObjPos_HUBZ1:	incbin	objpos\hubz1.bin
		even
ObjPos_HUBZ2:	incbin	objpos\hubz2.bin
		even
ObjPos_HUBZ3:	incbin	objpos\hubz3.bin
		even
ObjPos_IntroZ1:	incbin	objpos\introz1.bin
 		even
ObjPos_IntroZ2:	incbin	objpos\introz2.bin
 		even
ObjPos_IntroZ3:	incbin	objpos\introz3.bin
 		even
ObjPos_Tropic1:	incbin	objpos\Tropic1.bin
 		even
ObjPos_Tropic2:	incbin	objpos\Tropic2.bin
 		even
ObjPos_Tropic3:	incbin	objpos\Tropic3.bin
 		even
ObjPos_LZ1pf1:	incbin	objpos\lz1pf1.bin
		even
ObjPos_LZ1pf2:	incbin	objpos\lz1pf2.bin
		even
ObjPos_LZ2pf1:	incbin	objpos\lz2pf1.bin
		even
ObjPos_LZ2pf2:	incbin	objpos\lz2pf2.bin
		even
ObjPos_LZ3pf1:	incbin	objpos\lz3pf1.bin
		even
ObjPos_LZ3pf2:	incbin	objpos\lz3pf2.bin
		even
ObjPos_SBZ1pf1:	incbin	objpos\sbz1pf1.bin
		even
ObjPos_SBZ1pf2:	incbin	objpos\sbz1pf2.bin
		even
ObjPos_SBZ1pf3:	incbin	objpos\sbz1pf3.bin
		even
ObjPos_SBZ1pf4:	incbin	objpos\sbz1pf4.bin
		even
ObjPos_SBZ1pf5:	incbin	objpos\sbz1pf5.bin
		even
ObjPos_SBZ1pf6:	incbin	objpos\sbz1pf6.bin
		even
ObjPos_End:	incbin	objpos\ending.bin
		even
ObjPos_Null:	dc.b $FF, $FF, 0, 0, 0,	0

		if Revision=0
		dcb.b $62A,$FF
		else
		dcb.b $63C,$FF
		endc
		;dcb.b ($10000-(*%$10000))-(EndOfRom-SoundDriver),$FF

                even

ChangeLevelData:include "_inc\Change Level Array.asm"
                even
; --------------------------------------------------------------------------
MenuHeaderIndex:
                dc.w  Art_Status-MenuHeaderIndex
                dc.w  Art_Map-MenuHeaderIndex
;                dc.w  Art_UseItem-MenuHeaderIndex
                dc.w  Art_Equip-MenuHeaderIndex
                dc.w  Art_Status-MenuHeaderIndex
                dc.w  Art_Status-MenuHeaderIndex

Art_Status:     incbin "artunc\Status.bin"
                even
Art_Map:        incbin "artunc\Map.bin"
                even
; Art_UseItem:    incbin "artunc\Use Item.bin"
;                 even
Art_Equip:      incbin "artunc\Equip.bin"
                even
; --------------------------------------------------------------------------
;Large Menu Icons
IconPal_Default:incbin "artunc\Icons\Default Icon Palette.bin"
                even
Icon_NoIcon:    incbin "artunc\Icons\No Icon.bin"
                even
Icon_Shield:    incbin "artunc\Icons\Shield.bin"
                even
Icon_Invincibility:incbin "artunc\Icons\Invincibility.bin"
                even
Icon_SpeedShoes:incbin "artunc\Icons\Speed Shoes.bin"
                even
Icon_Key:       incbin "artunc\Icons\Key.bin"
                even
IconPal_Key:    incbin "artunc\Icons\KeyPal.bin"
                even
Icon_Spindash:  incbin "artunc\Icons\Spindash.bin"
                even
Icon_UseItem:   incbin "artunc\Icons\Use Item.bin"
                even
Icon_Debug:     incbin "artunc\Icons\Debug.bin"
                even
Icon_Save:      incbin "artunc\Icons\Save.bin"
                even
Icon_SoundTest: incbin "artunc\Icons\Sound Test.bin"
                even
;Small Hud Icons
SIcon_Empty:    incbin "artunc\SIcons\Empty.bin"
                even
SIcon_Djump1:   incbin "artunc\SIcons\DoubleJump.bin"
                even
SIcon_Djump2:   incbin "artunc\SIcons\DoubleJump2.bin"
                even
SIcon_Homing:   incbin "artunc\SIcons\HomingAttack.bin"
                even
SIcon_LDash:    incbin "artunc\SIcons\LightDash.bin"
                even

;KosM_MenuBG:     incbin "artkosm\Menu Background.kosm"
;                even
KosM_MenuFont:   incbin "artkosm\Menu Font.kosm"
                even
Eni_MenuBG:     incbin "tilemaps\Menu Background (Enigma).bin"
                even               

Art_MapTiles:	incbin "artunc\maptiles.bin"
				even
                include "_inc\WorldMap.asm"
                even
Art_PowerUps:	incbin "artunc\Power Ups.bin"					; floating pickup icons
				even


	if VladDebug = 0
         include "_debugger\DebuggerBlob.asm"
	else
         include "_debug_vlad\Error Handler.asm"
	endif

                even


; =========================================================================
; Sound Driver
; =========================================================================
SoundDriverASM:

; end of 'ROM'
         even
         ;org $8000
EndOfRom:


		END
