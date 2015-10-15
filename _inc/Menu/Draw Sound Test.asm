; ---------------------------------------------------------------------------
; Draw sound test, vu meters etc.
; ---------------------------------------------------------------------------
sndtestNote     = 0
sndtestVolume   = 2
sndtestPan      = 3
sndtestCurrNoteFill = 4
sndtestSavedNoteFill = 5
sndtestAtRest   = 6
sndtestChannel  = 7    ; 9 = fm1, 8 = fm2 etc.
      if z80SoundDriver=0
sndtestDAC      = $0
ChannelVolume   = $9
ChannelPan      = $A
ChannelCurrNoteFill = $E
ChannelSavedNoteFill = $F
ChannelNote     = $10
      else
sndtestDAC      = $1
ChannelVolume   = $6
ChannelPan      = $A
ChannelCurrNoteFill = $B
ChannelSavedNoteFill = $C
ChannelNote     = $D
; these tables are already included inside the 68k driver
FMPitchTable:
    dc.w $0284,$02AB,$02D3,$02FE,$032D,$035C,$038F,$03C5,$03FF,$043C,$047C,$04C0    

PSGPitchTable:
		dc.w $3FF,$3FF,$3FF,$3FF,$3FF,$3FF,$3FF,$3FF,$3FF,$3FF,$3F7,$3BE,$388
		dc.w $356,$326,$2F9,$2CE,$2A5,$280,$25C,$23A,$21A,$1FB,$1DF,$1C4
		dc.w $1AB,$193,$17D,$167,$153,$140,$12E,$11D,$10D,$0FE,$0EF,$0E2
		dc.w $0D6,$0C9,$0BE,$0B4,$0A9,$0A0,$097,$08F,$087,$07F,$078,$071
		dc.w $06B,$065,$05F,$05A,$055,$050,$04B,$047,$043,$040,$03C,$039
		dc.w $036,$033,$030,$02D,$02B,$028,$026,$024,$022,$020,$01F,$01D
		dc.w $01B,$01A,$018,$017,$016,$015,$013,$012,$011,$010,$000,$000
      endif
; ===========================================================================
Channel_Address:
      if z80SoundDriver=0
	     dc.l	$FFFFF040	; DAC          ;0
	     dc.l	$FFFFF1F0	; PSG3         ;1
	     dc.l	$FFFFF1C0	; PSG2         ;2
	     dc.l	$FFFFF190	; PSG1         ;3
	     dc.l	$FFFFF160	; FM6          ;4
	     dc.l	$FFFFF130	; FM5          ;5
	     dc.l	$FFFFF100	; FM4          ;6
	     dc.l	$FFFFF0D0	; FM3          ;7
	     dc.l	$FFFFF0A0	; FM2          ;8
	     dc.l	$FFFFF070	; FM1          ;9
      else
	     dc.l	$A01C40	        ; DAC          ;0
	     dc.l	$A01DC0	        ; PSG3         ;1
	     dc.l	$A01D90	        ; PSG2         ;2
	     dc.l	$A01D60	        ; PSG1         ;3
	     dc.l	$A01c40	        ; FM6          ;4
	     dc.l	$A01D30	        ; FM5          ;5
	     dc.l	$A01D00	        ; FM4          ;6
	     dc.l	$A01CD0	        ; FM3          ;7
	     dc.l	$A01CA0	        ; FM2          ;8
	     dc.l	$A01C70	        ; FM1          ;9
      endif
; =========================================================================
;  HANG ON, I know it's called 'draw' sound test but we don't draw yet, we gotta get that sweet sweet data first
; =========================================================================
DrawSoundTest:
        ; first we pull all the data we need into a temp table in ram
                stopZ80                                 ; if we're running the sonic 3 sound driver we gotta stop the z80 before we read its RAM or real hardware chucks a shitfit, if not, fuck it, who cares let's stop it anyway, i don't wanna put a C if statement here
                waitZ80                                 ; make sure that shit's really stopped and it's not just fuckin wit us
                moveq   #9,d2                           ; we got 10 channels to get data from
                lea     (v_sndtsttemp),a4               ; temp location for data the sound test needs
        @loop:
                moveq   #0,d4
                move.b  d2,d4                           ; copy loop to d4
                add.w	d4,d4
                add.w	d4,d4
 	        movea.l	Channel_Address(pc,d4.w),a1	; load channel address from table
      if z80SoundDriver=1
                move.b  ChannelNote+1(a1),(a4)+         ; that's $0 in our table
                move.b  ChannelNote+0(a1),(a4)+         ; that's $1 in our table
      else
                move.w  ChannelNote(a1),(a4)+           ; that's $0 in our table
      endif
                move.b  ChannelVolume(a1),(a4)+         ; $2
                move.b  ChannelPan(a1),(a4)+            ; $3
                move.b  ChannelCurrNoteFill(a1),(a4)+   ; $4
                move.b  ChannelSavedNoteFill(a1),(a4)+  ; $5
        ; set flag if 'track resting' bit is set
                moveq   #0,d0
      if z80SoundDriver=1
                btst    #4,(a1)
      else
                btst    #1,(a1)
      endif
                beq.s   @dontset
                moveq   #1,d0
      @dontset:
                move.b  d0,(a4)+                        ; $6 set the track resting byte
                move.b  d2,(a4)+                        ; $7 give this channel a number
                dbf     d2,@loop
                startZ80                                ; we got what we need, don't leave em waiting
; =========================================================================
;  clear the sound test tilemap
; =========================================================================
                lea     v_sndtsttilemap,a2
                move.l  #$02D0,d2                       ; probably the wrong amount here
      @clearsndtstloop:
                move.b  #0,(a2)+
                dbf     d2,@clearsndtstloop
                bra.s   DrawFMChannels
                
ChannelNames:
                dc.b    " FM5"
                dc.b    " FM4"
                dc.b    " FM3"
                dc.b    " FM2"
                dc.b    " FM1"
FM6Txt:         dc.b    " FM6"
DACTxt:         dc.b    " DAC"
PSG3Txt:        dc.b    "PSG3"
                dc.b    "PSG2"
                dc.b    "PSG1"

; =========================================================================
;  NOW we finally start drawing shit
; =========================================================================
DrawFMChannels:
                moveq   #4,d2                            ; 5 loops
                lea     (v_sndtsttemp),a4                ; table that temporarily stores the data ne need for each channel
                lea     (v_sndtsttilemap),a2
; --------------------------------------------------------------------------
; first draw the 5 standard FM channels
; --------------------------------------------------------------------------
      @FMloop:
                lea     ChannelNames,a1                  ; first item in list
                moveq   #0,d4
                move.b  d2,d4
                mulu.w  #$4,d4                           ; 4 bytes in each channel label
                adda.w  d4,a1                            ; get address of text to draw
                bsr.w   SndTst_DrawText
                addq    #$2,a2                          ; add a space
                bsr.w   SndTst_GetFMNote
                bsr.w   SndTst_DrawText
                bsr.w   SndTst_GetPan
                bsr.w   SndTst_DrawText
                bsr.w   VUMeter
                addq    #8,a4
                lea     (v_sndtsttilemap),a2
                move.l  d2,d4                           ; copy current line to d4
                mulu.w  #$30,d4                         ; multiply by length of a line
                sub.w   #$30*5,d4                       ; subtract from start of last line (length of line * 5 lines)
                neg     d4                              ; negate to get position
                adda.l  d4,a2
                dbf     d2,@FMloop
; --------------------------------------------------------------------------
; choose between drawing FM6 or DAC (will always be DAC in z80 driver)
; --------------------------------------------------------------------------
      if z80SoundDriver=0
                tst.l   (a4)                            ; check if there's anything in the FM6 data
                beq.w   @drawDAC                        ; if not, draw DAC instead
                lea     FM6Txt,a1
                bsr.w   SndTst_DrawText
                addq    #$2,a2                          ; add a space
                bsr.w   SndTst_GetFMNote
                bsr.w   SndTst_DrawText
                bsr.w   SndTst_GetPan
                bsr.w   SndTst_DrawText
                bsr.w   VUMeter
                bra.s   @drawPSG
       endif
@drawDAC:
                lea     (v_sndtsttemp+72),a4            ; load start of DAC data
                lea     DACTxt,a1
                bsr.w   SndTst_DrawText
                addq    #$6,a2                          ; move 'cursor' into correct position
                move.b  sndtestDAC(a4),d0               ; "drawhex" wants the data to be in d0
                bsr.w   DrawHex
                addq    #$6,a2                          ; move 'cursor' into correct position
                bsr.w   SndTst_GetPan
                bsr.w   SndTst_DrawText
                bsr.w   VUMeter
; --------------------------------------------------------------------------
; draw the PSG channels
; --------------------------------------------------------------------------
@drawPSG:
                moveq   #2,d2                           ; 3 loops
                lea     (v_sndtsttilemap+($30*6)),a2
                lea     (v_sndtsttemp+48),a4            ; load start of PSG data
       @psgloop:
                lea     PSG3Txt,a1                      ; first item in list
                moveq   #0,d4
                move.b  d2,d4
                mulu.w  #$4,d4                          ; 4 bytes in each channel label
                adda.w  d4,a1                           ; get address of text to draw
                bsr.s   SndTst_DrawText
                addq    #$2,a2                          ; add a space
                bsr.w   SndTst_GetPSGNote
                bsr.w   SndTst_DrawText
                bsr.w   SndTst_GetPan
                bsr.w   SndTst_DrawText
                bsr.w   VUMeter
                lea     (v_sndtsttilemap+($30*6)),a2
                move.l  d2,d4                           ; copy current line to d4
                mulu.w  #$30,d4                         ; multiply by length of a line
                sub.w   #$30*3,d4                       ; subtract from start of last line (length of line * 3 lines)
                neg     d4                              ; negate to get position
                adda.l  d4,a2
                addq    #8,a4
                dbf     d2,@psgloop
; --------------------------------------------------------------------------
; write the tilemap to VRAM
; --------------------------------------------------------------------------
               lea     (v_sndtsttilemap).l, A1
               move.l  #$458C0003, D0                   ; vram location
               moveq   #23, D1
               moveq   #$8, D2
               jsr     TilemapToVRAM
               rts










SndTst_DrawText:
                moveq   #3,d3                           ; 4 letters
@loadtextloop1:
                moveq   #0,d0
                move.b  (a1)+,d0                        ; set d0 to letter required, advance a1 to letter for next loop around
                add.w   #FontLocation,d0                ; add vram offset
                move.w  d0,(a2)+                        ; set a2 to letter required and advance
                dbf     d3,@loadtextloop1               ; if d2 is over 0 loop back and draw next letter
                rts
; ===========================================================================
SndTst_GetFMNote:
                moveq   #0,d5                           ; set loop counter to 0
                moveq   #0,d6
                tst.b   sndtestAtRest(a4)               ; is track at rest??
                bne.s   @getaddress                     ; if so, branch
                moveq   #0,d4
                move.w  sndtestNote(a4),d4              ; put the note frequency into d4
                bne.w   @findnote                       ; if there's a note playing, branch
                bra.s   @getaddress                     ; otherwise just draw blank
 @findnote:
        @findnoteloop:
                cmpi.b   #$6C,d5                        ; check if loop number is higher than our note table goes to
                bcc.s    @getaddress                    ; if so, use blank note at entry $6C in note name table
                lea      (FMPitchTable),a5
                moveq    #11,d0                         ; check through 12 notes of this octave
        @octaveloop:        
                add.b    #1,d5
                move.w   (a5)+,d3
                add.w    d6,d3                          ; add octave amount  
                cmp.w    d3,d4                          ; does current pitch match pitch in table
                beq.s    @getaddress                    ; if so, get adress of text to draw
                dbf      d0,@octaveloop

                add.w    #$0800,d6                      ; check next octave
                bra.s    @findnoteloop                  ; try the next note
@getaddress:
                lea      (SoundTestNotes),a1
                mulu.w   #$4,d5                         ; multiply by no of bytes in each text entry
                adda.w   d5,a1                          ; add to address to get note text
                rts
; ===========================================================================
SndTst_GetPSGNote:
                moveq   #0,d5                           ; set loop counter to 0
                tst.b   sndtestAtRest(a4)               ; is track at rest??
                bne.s   @getaddress                     ; if so, branch
                moveq   #0,d4
                move.w  sndtestNote(a4),d4              ; put the note frequency into d4
                bne.s   @findnote                       ; if there's a note playing, branch
                bra.s   @getaddress                     ; otherwise just draw blank
@findnote:
                lea     (PSGPitchTable),a5
        @findnoteloop:
                cmpi.b   #$6C,d5                        ; check if loop number is higher than our note table goes to
                bcc.s    @getaddress                    ; if so, use blank note at entry $6C in note name table
                cmp.w    (a5)+,d4                       ; does current pitch match pitch in table
                beq.s    @getaddress                    ; if so, get adress of text to draw
                add.b    #1,d5
                bra.s    @findnoteloop                  ; try the next note
@getaddress:
                lea      (SoundTestNotes),a1
                mulu.w   #$4,d5                         ; multiply by no of bytes in each text entry
                adda.w   d5,a1                          ; add to address to get note text
                rts
; ===========================================================================
SndTst_GetPan:
               moveq    #0,d4
	       move.b   sndtestPan(a4),d4               ; d4 now contains pan info
	       divu.w   #$40,d4                         ; pan info is in multiples of 40
               lea      SoundTest_Pan,a1
               mulu.w   #$4,d4                          ; multiply by no of bytes in each text entry
               adda.w   d4,a1                           ; add to address to get pan text
               rts
; ===========================================================================
VUMeter:
               lea      (v_vucounter).l,a1
               moveq    #0,d0
               move.b   sndtestChannel(a4),d0
               adda.l	d0,a1
               moveq    #0,d0
               move.b   sndtestSavedNoteFill(a4),d0
               sub.b    sndtestCurrNoteFill(a4),d0 ; did a new note just start?
               cmpi.b   #2,d0
               ble.s    @checkrest               ; if so, check if it's a rest or a proper note
               cmpi.b   #0,sndtestChannel(a4)    ; is this the dac channel
               beq.s    @lowerthemeter           ; drop vu instantly so it doesn't look like a held note
               cmpi.b   #8,sndtestCurrNoteFill(a4) ; less than 8 ticks left in currently playing note?
               ble.s    @lowerthemeter           ; if so, branch
        @checkrest:
               tst.b    sndtestAtRest(a4)        ; is track at rest??
               bne.s    @lowerthemeter           ; if so, branch
               cmpi.b   #$80,sndtestDAC(a4)      ; is the DAC playing $80
               beq.s    @lowerthemeter           ; if so, branch
        @resetmeter:
               move.b   #64,(a1)                 ; set meter to full
               move.b   sndtestVolume(a4),d0     ; get channel volume
               sub.b    d0,(a1)                  ; subtract channel volume
        @lowerthemeter:
               sub.b    #4,(a1)                  ; sub 1 from meter
               bpl.s    @calculateNoOfTiles      ; if it hasn't gone negative, then branch
               move.b   #0,(a1)                  ; set meter to 0
        @calculateNoOfTiles:
               moveq    #0,d4
               move.b   (a1),d4                  ; move meter to d4
               divu.w   #8,d4                    ; divide by 8 to get number of bars to draw
               cmpi.w   #8,d4                    ; is counter too high?
               bls.s    @meterok                 ; if not, branch
               moveq    #8,d4                    ; reset to allowed level
        @meterok:

               lea      VU_Tiles,a1
@drawvu:
               moveq    #$00, d0
               move.w   (a1)+, d0                ; set d0 to tile and advance
               add.w    #FontLocation,d0         ; add vram offset
               move.w   d0, (a2)+                ; set a2 to letter required and advance
               dbf      d4, @drawvu              ; if d2 is over 0 loop back and draw next letter
               rts
; first byte is palette line, second is the tile
VU_Tiles:      dc.w $005B, $005B, $005B, $005B, $005B, $205B, $205B, $605B

; @getchanneltype:
;                cmp.b    #$0,d1                   ; is this the dac channel?
;                bne.s    @notdac                  ; if not, branch
;                move.w   #$0000,(a2)+             ; add a space
;                move.w   #$0000,(a2)+             ; add a space
;       if z80SoundDriver=0
;                lsr.w    #$8,d4                   ; get first byte
;       endif
;                move.w   d4,d0                    ; "drawhex" wants the data to be in d0
;                bsr      DrawHex
;                adda.l   #$4,a2                   ; reposition "cursor"
;                move.w   #$0000,(a2)+             ; add a space
;                bra.s    Pan                     ; we're done drawing the dac note
; 
;         @notdac:
;                lea      (FMPitchTable),a4
;                cmpi.b   #$4,d1
;                bcc.s    @findnoteloop            ; branch if not a psg track
;                lea      (PSGPitchTable),a4
;                moveq    #0,d5                    ; set loop counter to 0
; 
;         @findnoteloop:
;                cmpi.b   #$6C,d5                  ; check if note is note too high
;                bcc.s    @notetextbegin           ; if so, branch
;                add.b    #1,d5
;                cmp.w    (a4)+,d4                 ; does current pitch match pitch in table
;                bne      @findnoteloop            ; if not, try next note
; 
; @notetextbegin:
;        ; stupid hack...
;                sub.b    #$1,d5                   ; for some reason fm notes are displaying 1 semitone too high
;                cmpi.b   #$4,d1
;                bcc.s    @notpsg                  ; branch if not a psg track
;                add.b    #1,d5                    ; psg notes display fine though...
;        @notpsg:
;        ; stupid hack ends...
;                lea      (SoundTestNotes),a1
;                mulu.w   #$5,d5                   ; multiply by no of bytes in each text entry
;                adda.w   d5,a1                    ; add to address to get note text
;                moveq    #$00, D2                 ; clear d2
;                move.b   (A1)+, D2                ; set d2 to length of string, advance a1 to first letter in string
;                move.w   D2, D3                   ; set d3 to length of string as well
; @notetext:
;                moveq    #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
;                move.b   (A1)+, D0                ; set d0 to letter required, advance a1 to letter for next loop around
;                add.w    #FontLocation,d0         ; add vram offset
;                move.w   D0, (A2)+                ; set a2 to letter required and advance
;                dbra     D2, @notetext            ; if d2 is over 0 loop back and draw next letter
;                bra.s    Pan
;                nop
; ; ===========================================================================

; 
; 
;

              



