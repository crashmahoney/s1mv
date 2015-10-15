Foreground_ZigZags:         ; number of tiles to draw /2, 2 nametable entries
        dc.l    59, $25832583, 19, $25842D84, 359, $0, 19, $25852D85, 19, $25862D86, 59, $25832583
        even    
Foreground_ZigZags2:        ; vram location, 2 nametable entries
        dc.l    $41800003, $25842D84, $4B000003, $25852D85, $4B800003, $25862D86
;========================================================================================================================
; Draw The Menu
;========================================================================================================================
RedrawFullMenu:
        move    #$2700, SR                    ; interrupt mask level 7
;========================================================================================================================
; write header and footer into RAM tilemap  
        lea     (v_menufg).l, a1                ; tilemap location
        lea     Foreground_ZigZags,a2           ; array
        moveq   #5,d0                           ; loop 6 times
    @blockloop:
            move.l  (a2)+,d1                    ; number of tiles to draw /2
            move.l  (a2)+,d2                    ; get the 2 tiles
        @tileloop:
            move.l  d2,(a1)+                    ; write tile            
            dbf     d1,@tileloop
        dbf     d0,@blockloop
;========================================================================================================================
; write part of header and footer into VRAM 
; this is to fill in the part of the foreground plane that scrolls, that the tilemap isn't big enough to fill
Draw_header_fg:
        lea     ($C00000).l,a6
        lea     Foreground_ZigZags2,a2
        moveq   #2,d4                   ;loop 3 times
    @blockloop:
            move.l  (a2)+,4(a6)
            move.l  (a2)+,d1            ; tilemap to move
            moveq   #31,d3
        @bg_Cell:
                move.l  d1,(a6)         ; write value to namespace
                dbf     d3,@bg_Cell
           dbf     d4,@blockloop
;========================================================================================================================
; write checkered bg mappings direct into VRAM
Draw_checkered_bg:
        lea     ($C00000).l,a6
        move.l  #$60000003,4(a6)    ; vram address
        moveq   #31,d2              ; draw 32 rows
        move.l  #$05810582,d1       ; tilemap to move
    @bg_Line:
        moveq   #31,d3              ; draw 64 columns
    @bg_Cell:
        move.l  d1,(a6)             ; write value to namespace
        dbf     d3,@bg_Cell
        swap    d1
        dbf     d2,@bg_Line

;========================================================================================================================
PauseMenu_DrawTopMenu:
        lea     (v_menufg).l, a1                ; tilemap location
        cmpi.b  #5,(v_levselpage).w
        bcc.w   @skipheader

; load the large text's uncompressed graphics
        lea     (MenuHeaderIndex).l,a0
        moveq   #0,d2
        move.b  (v_levselpage),d2
        add.b   d2,d2
		adda.w	(a0,d2.w),a0                  ; load pointer to graphics
        lea	    ($C00000).l,a6
		locVRAM	$BC80,4(a6)
		move.l	#$AF,d0
	@LoadIconGFX:
		move.l	(a0)+,(a6)
		dbf	d0,@LoadIconGFX

; draw the small left and right text
                cmpi.b  #0,(v_menupagestate)     ; if not selecting tab, don't draw small text
                bne.s   @drawlargetext
                lea     (TopMenuIndex),a1
                moveq   #0,d2
                move.b  (v_levselpage),d2        ; selected page
                add.b   d2,d2
		adda.w	(a1,d2.w),a1             ; load pointer to curent tab description
                lea     (v_menufg),a3
                lea     (TopMenu_Positions),a5
                moveq   #1,d1                    ; number of items to draw (2)
                bsr.w   DrawBasicMenuText        ; draw the menu

       ; draw top half of large text
@drawlargetext:
                moveq   #0,d0                    ; clear d0
                lea     (v_menufg).l,a2
                adda    #$006C,a2                ; text on screen location
                move.w  #$25E4,d0                   ; first tile to draw
                moveq   #10,d1                   ; draw 11 tiles
@drawtile:
                move.w  d0, (a2)+                ; set a2 to letter required and advance
                add.b   #$1,d0                   ; advance to next letter
                dbra    d1, @drawtile            ; if d2 is over 0 loop back and draw next tile

       ; draw bottom half of large text
                lea     (v_menufg).l,a2
                adda    #$00BC,a2                ; text on screen location
                moveq   #10,d1                   ; draw 11 tiles
@drawtile2:
                move.w  d0, (a2)+                ; set a2 to letter required and advance
                add.b   #$1,d0                   ; advance to next letter
                dbra    d1, @drawtile2            ; if d2 is over 0 loop back and draw next tile

@skipheader:
;========================================================================================================================
; Choose menu to draw
;========================================================================================================================

                moveq   #0,d0
                moveq   #0,d1
                moveq   #0,d2
                moveq   #0,d3
                moveq   #0,d4
                move.b  (v_levselpage).w,d0
		add.w	d0,d0
		add.w	d0,d0
 		movea.l	MenuPages(pc,d0.w),a6		; load correct routine to jump to
		jmp	(a6)

; ===========================================================================
MenuPages:
                dc.l	PauseMenu_DrawStatus              ; $0
                dc.l	PauseMenu_DrawMap                 ; $1
;                dc.l	PauseMenu_DrawItems               ; $2
                dc.l	PauseMenu_DrawEquip               ; $2
                dc.l	PauseMenu_DrawDebug               ; $3
                dc.l    PauseMenu_DrawSoundTest           ; $4
                dc.l    Pausemenu_DrawError               ; $5
                dc.l    Pausemenu_VRAM                    ; $6
; ===========================================================================

;========================================================================================================================
; Draw The Status Screen
;========================================================================================================================

PauseMenu_DrawStatus:
@drawbg:
; draw stats background
                move.w  #$01B8,d3                  ; start position
                move.b  #$13,d2                    ; width
                move.b  #$7,d1                     ; height
                jsr     DrawBacker
; draw inventory background
                move.w  #$0412,d3                  ; start position
                move.b  #$26,d2                    ; width
                move.b  #$9,d1                     ; height
                jsr     DrawBacker
@drawtext:
                jsr     DrawStats                  ; draw the stats
                jsr     DrawInventory

                lea     (v_menufg), A3
                lea     (StatusText), A1         ; loads first item of first string to a1 (the first byte of the string defines string length)
                lea     (StatusTextPositions), A5
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                moveq   #$00, D1                 ; clear d0 (normally stores the letter to draw, i think)
                move.b  #6, D1                   ; set loop counter to 5 (the number of options)
Status_Loop_Load_Text:
                move.w  (A5)+, D3                ; put required text position in d3, advance a5 to next item (for next time it loops)
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position???
                moveq   #$00, D2                 ; clear d2
                move.b  (A1)+, D2                ; set d2 to length of string, advance a1 to first letter in string
                move.w  D2, D3                   ; set d3 to length of string as well
@loadtextloop1:
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                move.b  (A1)+, D0                ; set d0 to letter required, advance a1 to letter for next loop around
                add.w   #FontLocation,d0         ; add vram offset
                move.w  d0, (A2)+                ; set a2 to letter required and advance
                dbra    D2, @loadtextloop1       ; if d2 is over 0 loop back and draw next letter
                move.w  #$000B, D2               ; set d2 to 13
                sub.w   D3, D2                   ; sub d3(string length from before (should be 14)) from d2(13)
                bcs.s   @drawactnumber           ; if below 0, skip (should happen all the time, really)
@loadtextloop2:
                move.w  #$0000, (A2)+            ; set value at a2 to clear, advance
                dbra    D2, @loadtextloop2       ; sub 1 from d2, if 0 continue

@drawactnumber:
                moveq   #0,d0
                move.b  d1,d0
		add.w	d0,d0
		add.w	d0,d0
 		movea.l	Status_Draw_Number(pc,d0.w),a6		; load correct routine to jump to
		jmp	(a6)

; ===========================================================================
Status_Draw_Number:
		dc.l	@skipnumber           ; header for inventory
		dc.l	@skipnumber           ;   "     "      "
                dc.l	@time
		dc.l	@next
		dc.l	@exp
		dc.l	@parts
		dc.l	@rings

; ===========================================================================
@time:
                sub.w   #14,a2                   ; move drawing position back
        ;draw hours
                move.w  #FontLocation+$30, (A2)+             ; draw "0"
                move.w  #FontLocation+$30, (A2)+             ; draw "0"
                sub.w   #$04,a2                  ; move drawing position back to draw 10s column
		moveq	#0,d5
		move.b	(v_time).w,d5	         ; load stat
		lea	(Hud_10).l,a6
		moveq	#1,d6                    ; number of digits (ie. 3)
                bsr.w   DrawDecimal
        ;draw minutes
                move.w  #FontLocation+":", (A2)+             ; draw ":"
                move.w  #FontLocation+$30, (A2)+             ; draw "0"
                move.w  #FontLocation+$30, (A2)+             ; draw "0"
                sub.w   #$04,a2                  ; move drawing position back to draw 10s column
		moveq	#0,d5
		move.b	(v_timemin).w,d5	         ; load stat
		lea	(Hud_10).l,a6
		moveq	#1,d6                    ; number of digits (ie. 3)
                bsr.w   DrawDecimal
        ; draw seconds
                move.w  #FontLocation+":", (A2)+             ; draw "0"
                move.w  #FontLocation+$30, (A2)+             ; draw "0"
                move.w  #FontLocation+$30, (A2)+             ; draw "0"
                sub.w   #$04,a2                  ; move drawing position back to draw 10s column
		moveq	#0,d5
		move.b	(v_timesec).w,d5	         ; load stat
		lea	(Hud_10).l,a6
		moveq	#1,d6                    ; number of digits (ie. 3)
                bsr.w   DrawDecimal
                bra.s   @skipnumber

; ===========================================================================
@next:
;                 moveq   #$00,d5
;                 addi.w  #FontLocation+$30,d5     ; draw 0
;  	        btst    #2,(v_abilities).w       ; is goggles allowed?
; 		beq.s   @drawnumber              ; if not, branch
;                 moveq   #$00,d5
;                 addi.w  #FontLocation+$31,d5     ; draw 1
;                 bra.s   @drawnumber

; ===========================================================================
@exp:
                move.w  #FontLocation+$30, (A2)             ; draw "0"
                sub.w   #$0C,a2                  ; move drawing position back to draw 10000s column
		moveq	#0,d5
		move.l	(v_score).w,d5	         ; load stat
		lea	(Hud_100000).l,a6
		moveq	#5,d6                    ; number of digits (ie. 5)
                bsr.w   DrawDecimal
                bra.s   @skipnumber

; ===========================================================================
@parts:
;                 moveq   #$00,d5
;                 addi.w  #FontLocation+$30,d5
;  	        btst    #3,(v_abilities).w       ; is jump dash allowed?
; 		beq.s   @drawnumber              ; if not, branch
;                 moveq   #$00,d5
;                 addi.w  #FontLocation+$31,d5
;                 bra.s   @drawnumber

; ===========================================================================
@rings:
                move.w  #FontLocation+$30, (A2)             ; draw "0"
                sub.w   #$04,a2                  ; move drawing position back to draw 100s column
		moveq	#0,d5
		move.w	(v_rings).w,d5	         ; load stat
		lea	(Hud_100).l,a6
		moveq	#2,d6                    ; number of digits (ie. 3)
                bsr.w   DrawDecimal
                bra.s   @skipnumber

; ===========================================================================


       @drawnumber:
                move.w  d5,(a2)
       @skipnumber:
                dbra    D1, Status_Loop_Load_Text ; if all lines drawn, continue, otherwise loop back and draw the next line

                jmp     PauseMenu_DrawMenu         ; draw the Menu

;========================================================================================================================
; Draw The Map Screen
;========================================================================================================================

PauseMenu_DrawMap:
                lea     (v_menufg), A3
                lea     (Map_Text), A1    ; loads first item of first string to a1 (the first byte of the string defines string length)
                lea     (Map_Positions), A5
                moveq   #0,d0
                moveq   #1,d1                      ; number of items to draw (-1)
                bsr.w   DrawBasicMenuText          ; draw the menu
                jmp     PauseMenu_DrawMenu         ; draw the Menu
;========================================================================================================================
; Draw The Items Screen
;========================================================================================================================
PauseMenu_DrawItems:
@drawbg:
; draw stats background
                move.w  #$01B8,d3                  ; start position
                move.b  #$13,d2                    ; width
                move.b  #$9,d1                     ; height
                jsr     DrawBacker
; draw inventory background
                move.w  #$04B2,d3                  ; start position
                move.b  #$26,d2                    ; width
                move.b  #$7,d1                     ; height
                jsr     DrawBacker
@drawtext:
                jsr     DrawStats                  ; draw the stats
                jsr     DrawInventory

                jmp     PauseMenu_DrawMenu         ; draw the Menu
;========================================================================================================================
; Draw The Equip Screen
;========================================================================================================================
PauseMenu_DrawEquip:
; draw slots background
                move.w  #$0142,d3                  ; start position
                move.b  #$26,d2                    ; width
                move.b  #$A,d1                     ; height
                jsr     DrawBacker
; draw inventory background
                move.w  #$0462,d3                  ; start position
                move.b  #$26,d2                    ; width
                move.b  #$8,d1                     ; height
                jsr     DrawBacker
                jsr     DrawInventory
; draw slot names
                move.b  #6,(v_menuslots)           ; 7 equip slots
                lea     (v_menufg), A3             ; load start address of 256x256 block
                lea     (Equip_Menu_Items), A1     ; loads first item of first string to a1 (the first byte of the string defines string length)
                lea     (Equip_Text_Positions), A5
                moveq   #$00, D1                   ; clear d0 (normally stores the letter to draw, i think)
                move.b  (v_menuslots), D1          ; set loop counter to 7 (the number of options)
                bsr.w   DrawBasicMenuText
; draw equipped items
                move.b  (v_menuslots), D1          ; set loop counter to 7 (the number of options)
                lea     (v_menufg), A3             ; load start address of 256x256 block
                lea     (Equip_Text_Positions), A5

                lea     (EquipAbilitiesList),a1        ; List of equippable items
                moveq   #0,d2
                move.b  (v_a_ability).w,d2
                bsr.s   @drawitemname
                lea     (EquipAbilitiesList),a1        ; List of equippable items
                moveq   #0,d2
                move.b  (v_b_ability).w,d2
                bsr.s   @drawitemname
                lea     (EquipAbilitiesList),a1        ; List of equippable items
                moveq   #0,d2
                move.b  (v_c_ability).w,d2
                bsr.s   @drawitemname
                lea     (EquipShoesList),a1        ; List of equippable items
                moveq   #0,d2
                move.b  (v_equippedshoes).w,d2
                bsr.s   @drawitemname
                lea     (EquipItemsList),a1        ; List of equippable items
                moveq   #0,d2
                move.b  (v_equippeditem1).w,d2
                bsr.s   @drawitemname
                lea     (EquipItemsList),a1        ; List of equippable items
                moveq   #0,d2
                move.b  (v_equippeditem2).w,d2
                bsr.s   @drawitemname

                cmpi.b  #2,(v_menupagestate).l     ; is inventory selected?
                bne.s   @end
; draw stats background
                move.w  #$01B8,d3                  ; start position
                move.b  #$13,d2                    ; width
                move.b  #$9,d1                     ; height
;                jsr     DrawBacker
                jsr     DrawStats                  ; draw the stats
         @end:
                jmp     PauseMenu_DrawMenu         ; draw the Menu
; --------------------------------------------------------------------------
@drawitemname:
		add.w	 d2,d2
		add.w	 d2,d2
                adda.l   d2,a1                         ; get current inv item address
                movea.l  (a1),a1                       ; move start of text to a1
                adda.l   #InvNameOffset,a1             ; get text location
                move.w  (a5)+,d3                 ; put required text position in d3, advance a5 to next item (for next time it loops)
                add.w   #$52,d3                  ; adjust drawing position
                lea     (a3,d3),a2               ; sets a2 to address of requred text position
                moveq   #0,d2                    ; clear d2
                move.b  (a1)+,d2                 ; set d2 to length of string, advance a1 to first letter in string
@loadtextloop1:
                moveq   #0,d0
                move.b  (a1)+,d0                 ; set d0 to letter required, advance a1 to letter for next loop around
                add.w   #FontLocation,d0         ; add vram offset
                add.w   #$2000,d0                ; use second palette line
                move.w  d0,(a2)+                 ; set a2 to letter required and advance
                dbf     d2,@loadtextloop1        ; if d2 is over 0 loop back and draw next letter
                rts

;========================================================================================================================
; Draw The Debug Screen
;========================================================================================================================
PauseMenu_DrawDebug:
       ; draw debug background
; draw slots background
                move.w  #$0142,d3                  ; start position
                move.b  #$26,d2                    ; width
                move.b  #$F,d1                     ; height
                jsr     DrawBacker

                move.b  #$A,(v_menuslots)         ; 12 menu slots

@drawtext:
                lea     (v_menufg), A3          
                lea     (Debug_Menu_Items), A1    ; loads first item of first string to a1 (the first byte of the string defines string length)
                lea     (Debug_Text_Positions), A5
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                moveq   #$00, D1                 ; clear d0 (normally stores the letter to draw, i think)
                move.b  (v_menuslots), D1        ; set loop counter to 9 (the number of options)
Debug_Loop_Load_Text:
                move.w  (A5)+, D3                ; put required text position in d3, advance a5 to next item (for next time it loops)
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position???
                moveq   #$00, D2                 ; clear d2
                move.b  (A1)+, D2                ; set d2 to length of string, advance a1 to first letter in string
                move.w  D2, D3                   ; set d3 to length of string as well
@loadtextloop1:
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                move.b  (A1)+, D0                ; set d0 to letter required, advance a1 to letter for next loop around
                add.w   #FontLocation,d0         ; add vram offset
                move.w  d0, (A2)+                ; set a2 to letter required and advance
                dbra    D2, @loadtextloop1       ; if d2 is over 0 loop back and draw next letter
                move.w  #$000B, D2               ; set d2 to 13
                sub.w   D3, D2                   ; sub d3(string length from before (should be 14)) from d2(13)
                bcs.s   @drawactnumber           ; if below 0, skip (should happen all the time, really)
@loadtextloop2:
                move.w  #$0000, (A2)+            ; set value at a2 to clear, advance
                dbra    D2, @loadtextloop2       ; sub 1 from d2, if 0 continue

@drawactnumber:
                moveq   #0,d0
                move.b  d1,d0
		add.w	d0,d0
		add.w	d0,d0
 		movea.l	Debug_Draw_Number(pc,d0.w),a6		; load correct routine to jump to
		jmp	(a6)

; ===========================================================================
Debug_Draw_Number:
		dc.l	@skipnumber		; vram viewer
                dc.l	@skipnumber             ; 1 of all items
                dc.l	@skipnumber             ; all abilities
                dc.l	@skipnumber             ; level select
		dc.l	@chaos
                dc.l	@skipnumber             ; add 1 minute
		dc.l	@supersonic
		dc.l	@itemplace
		dc.l	@skipnumber		; save slot 3
		dc.l	@skipnumber		; save slot 2
		dc.l	@skipnumber		; save slot 1
; ===========================================================================
@chaos:
                moveq   #$00,d0
                move.b  (v_emeralds).w,d0
                bsr     DrawHex
                bra     @skipnumber

; ===========================================================================
@supersonic:
                moveq   #$00,d5
                addi.w  #FontLocation+$30,d5
 	        tst.b   (f_supersonic).w          ; is super sonic on?
		beq.w   @drawnumber              ; if not, branch
                moveq   #$00,d5
                addi.w  #FontLocation+$31,d5
                bra.s   @drawnumber

; ===========================================================================
@itemplace:
                moveq   #$00,d5
                addi.w  #FontLocation+$30,d5
 	        tst.b   (f_debugmode).w          ; is item placement cheat on?
		beq.w   @drawnumber              ; if not, branch
                moveq   #$00,d5
                addi.w  #FontLocation+$31,d5
; ===========================================================================

       @drawnumber:
                move.w  d5,(a2)
       @skipnumber:
                dbra    D1, Debug_Loop_Load_Text ; if all lines drawn, continue, otherwise loop back and draw the next line
                jmp     PauseMenu_DrawMenu         ; draw the Menu

;========================================================================================================================
; Draw Sound Test Menu
;========================================================================================================================
PauseMenu_DrawSoundTest:
                move.w  #$0142,d3                  ; start position
                move.b  #$26,d2                    ; width
                move.b  #$12,d1                    ; height
                jsr     DrawBacker



                move.b  #$4,(v_menuslots)         ; 5 menu slots

@drawtext:
                lea     (v_256x256), A3          ; load start address of 256x256 block
                lea     (SoundTest_Menu_Items), A1    ; loads first item of first string to a1 (the first byte of the string defines string length)
                lea     (SoundTest_Text_Positions), A5
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                moveq   #$00, D1                 ; clear d0 (normally stores the letter to draw, i think)
                move.b  (v_menuslots), D1        ; set loop counter to 5 (the number of options)
SoundTest_Loop_Load_Text:
                move.w  (A5)+, D3                ; put required text position in d3, advance a5 to next item (for next time it loops)
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position???
                moveq   #$00, D2                 ; clear d2
                move.b  (A1)+, D2                ; set d2 to length of string, advance a1 to first letter in string
                move.w  D2, D3                   ; set d3 to length of string as well
@loadtextloop1:
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                move.b  (A1)+, D0                ; set d0 to letter required, advance a1 to letter for next loop around
                add.w   #FontLocation,d0         ; add vram offset
                move.w  d0, (A2)+                ; set a2 to letter required and advance
                dbra    D2, @loadtextloop1       ; if d2 is over 0 loop back and draw next letter
                move.w  #$000B, D2               ; set d2 to 13
                sub.w   D3, D2                   ; sub d3(string length from before (should be 14)) from d2(13)
                bcs.s   @drawactnumber           ; if below 0, skip (should happen all the time, really)
@loadtextloop2:
                move.w  #$0000, (A2)+            ; set value at a2 to clear, advance
                dbra    D2, @loadtextloop2       ; sub 1 from d2, if 0 continue

@drawactnumber:
                stopZ80
	        waitz80
                moveq   #0,d0
                move.b  d1,d0
		add.w	d0,d0
		add.w	d0,d0
 		movea.l	SoundTest_Draw_Number(pc,d0.w),a6		; load correct routine to jump to
		jmp	(a6)

; ===========================================================================
Soundtest_Draw_Number:
                dc.l    @drumkit
                dc.l	@MusicPitch
		dc.l	@tempomod
		dc.l	@tempodiv
                dc.l	@SoundTest
; ===========================================================================
@drumkit:
                moveq   #$00,d0
                move.b  (v_drumkit).w,d0
                bsr     DrawHex
                bra     @skipnumber

; ===========================================================================
@MusicPitch:
                moveq   #$00,d0
                move.b  (v_musicpitch).w,d0
                bsr     DrawHex
                bra     @skipnumber

; ===========================================================================
@SoundTest:
                moveq   #$00,d0
                move.w  (v_levselsound).w,d0
      if z80SoundDriver=0
                addi.w  #$0080, d0                 ; choose actual sound offset
      endif
                bsr     DrawHex
                bra     @skipnumber

; ===========================================================================
@tempomod:
                moveq   #$00,d0
      if z80SoundDriver=0
                move.b  ($FFFFF002).w, D0
      else
                move.b  ($A01C24).l,d0
      endif
                bsr     DrawHex
                bra     @skipnumber

; ===========================================================================
@tempodiv:
                moveq   #$00,d0
      if z80SoundDriver=0
                move.b  ($FFFFF042).w,d0
      else
                move.b  ($A01C3B).l,d0
      endif
                bsr     DrawHex
                bra     @skipnumber

; ===========================================================================


       @drawnumber:
                move.w  d5,(a2)
       @skipnumber:
                startZ80
                dbra    D1, SoundTest_Loop_Load_Text ; if all lines drawn, continue, otherwise loop back and draw the next line

                bsr     DrawSoundTest

                jmp     PauseMenu_DrawMenu         ; draw the Menu
;========================================================================================================================
; Draw The Error Screen
;========================================================================================================================

PauseMenu_DrawError:

ErrorType:
		moveq	#0,d0		; clear	d0
		move.b	(v_errortype).w,d0 ; load error code
		lea     (ErrorText).l,a1
		adda.w	(a1,d0.w),a1             ; load pointer to text
                lea     (v_menufg+$01A4),a2      ; sets a2 to address of requred text position
		moveq	#$12,d1		; number of characters (minus 1)

	@showchars:
		moveq	#0,d0
		move.b	(a1)+,d0
                add.w   #FontLocation,d0         ; add vram offset
		move.w	d0,(a2)+
		dbf	d1,@showchars

ErrorData:
                lea     (v_menufg+$0244),a2      ; sets a2 to address of requred text position
		move.l  (v_spbuffer).w,d0
		moveq	#3,d2                    ; we want to draw 4 hex bytes
        @number:
 		rol.l	#8,d0
                bsr.w   DrawHex
                adda.w  #6,a2                    ; advance text position
                dbf     d2,@number


ErrorPC:
		lea     (PClabel).l,a1
                lea     (v_menufg+$0294),a5
                moveq   #0,d1                    ; number of items to draw (1)
                bsr.w   DrawBasicMenuText        ; draw the menu
		move.l  (v_pcbuffer).w,d0
		moveq	#3,d2                    ; we want to draw 4 hex bytes
        @number:
 		rol.l	#8,d0
                bsr.w   DrawHex
                adda.w  #6,a2                    ; advance text position
                dbf     d2,@number

RegisterDump:
                lea     (RegisterLabels),a1
                lea     (v_regbuffer),a3
                lea     (v_menufg+$0372),a2      ; sets a2 to address of requred text position
                moveq   #4,d1                    ; we want to draw 5 rows
     @newline:
                moveq   #2,d3                    ; each with 3 registers
     @drawregister:
                moveq   #2,d2                    ; we want to draw 3 letters
        @label:
                moveq   #0,d0
                move.b  (a1)+,d0                 ; get letter to draw
                add.w   #FontLocation,d0         ; add vram offset
                move.w  d0,(a2)+                 ; write letter to tilemap
                dbf     d2,@label
                
                adda.w  #2,a2                    ; advance text position
		move.l  (a3)+,d0                 ; get next register value
		moveq	#3,d2                    ; we want to draw 4 hex bytes
        @number:
 		rol.l	#8,d0
                bsr.w   DrawHex
                adda.w  #6,a2                    ; advance text position
                dbf     d2,@number

                adda.w  #2,a2                    ; advance text position
                dbf     d3,@drawregister
                adda.w  #2,a2                    ; advance text position
                dbf     d1,@newline
                jmp     PauseMenu_DrawMenu         ; draw the Menu


; =========================================================================
; VRAM viewer
; pccvhnnn nnnnnnnn
; |||||||| ||||||||
; |||||+++-++++++++- Tile index
; ||||+------------- Horizontal flip
; |||+-------------- Vertical flip
; |++--------------- Color palette index
; +----------------- Priority
; =========================================================================
Pausemenu_VRAM:
        ;restore correct palettes
		moveq	#palid_Sonic,d0
		jsr	PalLoad2	; load Sonic's palette
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#4,d0
		lea	(LevelHeaders).l,a2
		lea	(a2,d0.w),a2
		lea	14(a2),a2
		move.w	(a2),d0
		andi.w	#$FF,d0
		jsr	PalLoad2

                move.w  (v_levselitem).w,d1        ; munber of first tile to draw
  	        lea     (v_256x256+6), a2          ; tilemap location

  	        moveq   #27,d2                     ; number of rows to draw
      @drawrow:
  	        move.w  d1,d0
  	        lsr.w   #8,d0
                bsr     DrawHex
                lea     $6(a2),a2                  ; reposition
  	        move.w  d1,d0
                bsr     DrawHex
                lea     $4(a2),a2                  ; reposition

                moveq   #31,d0                     ; number of tiles to draw on this line
      @drawtile:
                move.w  d1,(a2)+
                addq.w  #1,d1
                dbf     d0,@drawtile
                
                lea     $A(a2),a2                  ; reposition for next line
                dbf     d2,@drawrow

;                 jmp     PauseMenu_DrawMenu         ; draw the Menu

;========================================================================================================================
; Move tilemaps to Vram
;========================================================================================================================
PauseMenu_DrawMenu:
                move    #$2700, SR                    ; interrupt mask level 7
;                lea     (v_256x256+$8C0).l, A1
;                move.l  #$60000003, D0
;                moveq   #$27, D1
;                moveq   #$1B, D2
;                jsr     TilemapToVRAM

  	         lea     (v_256x256), A1               ; tilemap location
                move.l  #$40000003, D0                ; vram location
                moveq   #$27, D1                      ; tilemap width
                moveq   #$1B, D2                      ; tilemap height
                jsr     TilemapToVRAM                 ; write the whole shebang to the screen
                move    #$2300, SR                    ; interrupt mask level 3
                cmpi.b  #5,(v_levselpage).w
                bcc.w   @rts
                bsr.w   DrawDescription
        @rts:
                rts

;=================================================================================

