;===============================================================================
; Sonic2 Menu In Sonic 1 reprogrammed by Esrael L. G. Grandson
; [Home]
;
; The code for this menu is designed to work with
; The disassembly of one made by Sonic -> drx (www.hacking-cult.org)
;
; If using a different disassembly modify the jumps at the end of
; Code to point to the routines equivalent.
;
; To use this menu you can just make the following change in code
; Original:
; Locate the label -> loc_3242 add -> jmp Level_Select_Menu
; The code should look like below
;               ......................
; loc_3242:
;		tst.b	($FFFFFFE0).w
;		beq.w	PlayLevel	
;		btst	#6,($FFFFF604).w 
;		beq.w	PlayLevel	  		
;		jmp     Level_Select_Menu ; <- Loads the menu of Sonic 2
;		moveq	#2,d0		
;		bsr.w	PalLoad		 
;               ...............
;
; Do not forget to include this in your asm code with the include directive:
;               include 's2_menu.asm'
;===============================================================================  
Slow_Motion_Flag      equ $FFFFFFE1
Debug_Mode_Flag       equ $FFFFFFE2

Level_Select_PauseMenu_snd   = $0081
Emerald_Snd2             = $0093
Ring_Snd                = $00B5
Volume_Down             = $00E0
Stop_Sound              = $00E4
FontLocation            = $0580
;-------------------------------------------------------------------------------
Pause_Menu:
                 tst.b   (v_levelselnofade).w     ; is don't fade flag set?
                 bne.w   @domenu                  ; if so, branch
;                move.b  #Stop_Sound, D0
;                bsr     PlaySound
;                  moveq   #palid_Black, D0
;                  jsr     PalLoad2
                jsr     PaletteFadeOut
;                jsr     ClearPLC
                move.w  #2,(v_levselitem).w       ; reset selection
                ; save the background positions for reloading on exit

; 		move.w	(v_screenposx).w,($FFFFFE40).w 	; screen x-position
; 		move.w	(v_screenposy).w,($FFFFFE42).w 	; screen y-position
                moveq   #0,d0
		move.w	(v_screenposx).w,d0 	; screen x-position
                bclr   #0,d0
                bclr   #1,d0
                bclr   #2,d0
		move.w	d0,(v_screenposx).w 	; screen x-position
		move.w	d0,(v_scrposx_dup).w 	; screen x-position
                moveq   #0,d0
		move.w	(v_screenposy).w,d0 	; screen y-position
                bclr   #0,d0
                bclr   #1,d0
                bclr   #2,d0
		move.w	d0,(v_screenposy).w 	; screen y-position
		move.w	d0,(v_scrposy_dup).w 	; screen y-position
                move.w	($FFFFF708).w,($FFFFFE44).w 	; bg position
		move.w	($FFFFF70C).w,($FFFFFE46).w 	; bg position
		move.w	($FFFFF710).w,($FFFFFE48).w 	; bg position
		move.w	($FFFFF714).w,($FFFFFE4A).w 	; bg position
		move.w	($FFFFF718).w,($FFFFFE4C).w 	; bg position
		move.w	($FFFFF71C).w,($FFFFFE4E).w 	; bg position

@domenu
;                 move    #$2700, SR
;                 move.w  (v_vdp_buffer1).w, D0
;                 andi.b  #$BF, D0
;                 move.w  D0, ($00C00004)
;                jsr     ClearScreen

;=============================
;ClearScreen copy
;=============================

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
;		move.l	#0,(v_scrposx_dup).w
		else
		clr.l	(v_scrposy_dup).w
;		clr.l	(v_scrposx_dup).w
		endc
;
		lea	(v_sprites).w,a1
		moveq	#0,d0
		move.w	#$A0,d1

	@clearsprites:
		move.l	d0,(a1)+
		dbf	d1,@clearsprites ; clear sprite table (in RAM)

; 		lea	(v_scrolltable).w,a1
; 		moveq	#0,d0
; 		move.w	#$100,d1
; 
; 	@clearhscroll:
; 		move.l	d0,(a1)+
; 		dbf	d1,@clearhscroll ; clear hscroll table (in RAM)

;=============================
;End of ClearScreen copy
;=============================



                lea     ($00C00004), A6
                move.w  #$8004, (A6)
                move.w  #$8230, (A6)
                move.w  #$8407, (A6)
                move.w  #$8230, (A6)
                move.w  #$8700, (A6)
                move.w  #$8C81, (A6)
                move.w  #$9001, (A6)
;                 lea     (v_spritequeue).w, A1       ; clear sprite queue?
;                 moveq   #$00, D0                    ; |
;                 move.w  #$00FF, D1                  ; |
; @clrspriteloop:                                     ; |
;                 move.l  D0, (A1)+                   ; |
;                 dbra    D1, @clrspriteloop          ; V
                lea     (v_16x16).w, A1             ; clear 16x16 tiles?
                moveq   #$00, D0                    ; |
                move.w  #$07FF, D1                  ; |
@clr16x16loop:                                      ; |
                move.l  D0, (A1)+                   ; |
                dbra    D1, @clr16x16loop           ; V
                 tst.b   (v_levelselnofade).w     ; is don't fade flag set?
                 bne.w   @fontsalreadyloaded                  ; if so, branch

		lea	($C00000).l,a6
		locVRAM	$B000,4(a6)
		lea	(Art_MenuFont).l,a5	; +++ load uncompressed menu graphics
		move.w	#$35F,d1

	@LoadMenuGFX:
		move.w	(a5)+,(a6)
		dbf	d1,@LoadMenuGFX

;-------------------------------------------------------------------------------
; Loads the mapping of the Fund Sonic / Miles      remove this and the background stays plain blue
;-------------------------------------------------------------------------------
                lea     (v_256x256).l, a1
                moveq   #0,d1
                move.w  #$A400,d1
           @clrloop:
                move.b  #$00,(a1)+                ; clear all 256x256 tiles
		dbf	d1,@clrloop
;                 lea     (Menu_Mappings), A0
;                 move.w  #$6000, D0
;                 jsr     EniDec

@fontsalreadyloaded

                moveq   #0,d1
                moveq   #0,d2
                moveq   #0,d3
                moveq   #0,d4

; draw header background
                move.w  #$00A4,d3                  ; start position
                move.b  #$25,d2                    ; width
                move.b  #$8,d1                     ; height
                jsr     DrawBacker

; draw use items background
                move.w  #$0374,d3                  ; start position
                move.b  #$12,d2                    ; width
                move.b  #$B,d1                     ; height
                jsr     DrawBacker

; draw abilities background
                move.w  #$039A,d3                  ; start position
                move.b  #$12,d2                    ; width
                move.b  #$B,d1                     ; height
                jsr     DrawBacker

; draw description background
                move.w  #$0730,d3                ; start position
                move.b  #39,d2                   ; width
                move.b  #$4,d1                   ; height
                lea     (v_256x256), A3          ; load start address of 256x256 block
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position
                move.w  D2, D4                   ; set d4 to length of string as well, so we can reset d2 later
      @drawdescbg:
      @drawdescbgline:
                move.w  #FontLocation+$35, (A2)+ ; set a2 to black tile and advance
                dbra    D2, @drawdescbgline      ; sub 1 from d2, if 0 continue

                move.w  d4, d2                   ; reset width counter
                add.w   #$0050,d3                ; set draw position to next line
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position
                dbra    D1, @drawdescbg          ; sub 1 from d2, if 0 continue




                lea     (v_256x256), A1
                move.l  #$60000003, D0
                moveq   #$27, D1
                moveq   #$1B, D2
                jsr     TilemapToVRAM

;-------------------------------------------------------------------------------
; Load the Text Menu Selection Phase
;-------------------------------------------------------------------------------







PauseMenu_DrawText:
;                 lea     (v_256x256), A3          ; load start address of 256x256 block
;                 move.w  #$045F, D1               ; loop $045F (1119) times
; @clr256x256loop:
;                 move.w  #$0000, (A3)+            ; clear address and advance to next
;                 dbra    D1, @clr256x256loop      ; loop back to do it again
                lea     (v_256x256), A3          ; load start address of 256x256 block
                lea     (PauseMenu_Level_Select_Text), A1    ; loads first item of first string to a1 (the first byte of the string defines string length)
                lea     (PauseMenu_Text_Positions), A5
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                move.w  #$000C, D1               ; set loop counter to 13 (the number of options)
PauseMenu_Loop_Load_Text:
                move.w  (A5)+, D3                ; put required text position in d3, advance a5 to next item (for next time it loops)
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position???
                moveq   #$00, D2                 ; clear d2
                move.b  (A1)+, D2                ; set d2 to length of string, advance a1 to first letter in string
                move.w  D2, D3                   ; set d3 to length of string as well
@loadtextloop1:
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                move.b  (A1)+, D0                ; set d0 to letter required, advance a1 to letter for next loop around
                add.w   #FontLocation,d0         ; add vram offset
                cmpi.w  #$0004,d1                ; are we going to draw an ability?
                bgt.s   @drawletter              ; if not, branch
                cmpi.w  #$0004,d1                ; are we going to draw spindash?
                blt.s   @notspindash
 	        btst    #1,(v_abilities).w       ; is spin dash allowed?
                bne.s   @drawletter
      @notspindash:
                cmpi.w  #$0003,d1                ; are we going to draw air hop?
                blt.s   @notairhop
 	        btst    #0,(v_abilities).w
                bne.s   @drawletter
      @notairhop:
                cmpi.w  #$0002,d1                ; are we going to draw jump dash?
                blt.s   @notjumpdash
 	        btst    #3,(v_abilities).w       ; have jump dash?
                bne.s   @drawletter
      @notjumpdash:
                cmpi.w  #$0001,d1                ; are we going to draw goggles?
                blt.s   @notgoggles
 	        btst    #2,(v_abilities).w       ; have goggles?
                bne.s   @drawletter
      @notgoggles:
                cmpi.w  #$0000,d1                ; are we going to draw the soundtest?
                beq.s   @drawletter              ; if so, branch
                move.w  #FontLocation+$2B, (A2)+ ; set a2 to question mark and advance
;                 move.w  #$3A, (A2)+              ; set a2 to question mark and advance
;                 move.w  #$3A, (A2)+              ; set a2 to question mark and advance
;                 move.w  #0, d2                   ; set loop amount to 0 to end it
                bra.s   @drawnletter
      @drawletter:
                move.w  d0, (A2)+                ; set a2 to letter required and advance
      @drawnletter:
                dbra    D2, @loadtextloop1       ; if d2 is over 0 loop back and draw next letter
                move.w  #$000B, D2               ; set d2 to 13
                sub.w   D3, D2                   ; sub d3(string length from before (should be 14)) from d2(13)
                bcs.s   @drawactnumber           ; if below 0, skip (should happen all the time, really)
@loadtextloop2:
                move.w  #$0000, (A2)+            ; set value at a2 to clear, advance
                dbra    D2, @loadtextloop2       ; sub 1 from d2, if 0 continue
@drawactnumber:
                cmpi.b  #$0C,d1                  ; is 'use items' being drawn?
                bne.s   @skipheader1             ; if so, branch
                move.w  #FontLocation+$00, (A2)  ; Load " "
       @skipheader1:
                cmpi.b  #$06,d1                  ; is 'abilities' being drawn?
                bne.s   @skipheader2             ; if so, branch
                move.w  #FontLocation+$00, (A2)  ; Load " "
       @skipheader2:
                cmpi.b  #$0B,d1                  ; is dividing line in column 1 being drawn?
                bne.s   @skipline1               ; if not, branch
                move.w  #FontLocation+$29, (A2)  ; Load "-"
       @skipline1:
                cmpi.b  #$05,d1                  ; is dividing line in column 2 being drawn?
                bne.s   @skipline2               ; if not, branch
                move.w  #FontLocation+$29, (A2)  ; Load "-"
       @skipline2:

                cmpi.b  #$0A,d1                  ; is shield being drawn
                bne.s   @notshield               ; if not, branch
                moveq   #$00,d5
                move.b  (v_inv_shield).w,d5      ;
                addi.w  #FontLocation+$01,d5
                move.w  d5,(a2)
       @notshield:

                cmpi.b  #$09,d1                  ; is invincibility being drawn
                bne.s   @notinvinc               ; if not, branch
                moveq   #$00,d5
                move.b  (v_inv_invinc).w,d5      ;
                addi.w  #FontLocation+$01,d5
                move.w  d5,(a2)
       @notinvinc:

                cmpi.b  #$08,d1                  ; is shoes being drawn
                bne.s   @notshoes               ; if not, branch
                moveq   #$00,d5
                move.b  (v_inv_shoes).w,d5      ;
                addi.w  #FontLocation+$01,d5
                move.w  d5,(a2)
       @notshoes:

                cmpi.b  #$07,d1                  ; is shield being drawn
                bne.s   @notkey               ; if not, branch
                moveq   #$00,d5
                move.b  (v_inv_key).w,d5      ;
                addi.w  #FontLocation+$01,d5
                move.w  d5,(a2)
       @notkey:

       @notline:
@skipnumber
                dbra    D1, PauseMenu_Loop_Load_Text ; if all lines drawn, continue, otherwise loop back and draw the next line
;-------------------------------------------------------------------------------                
                lea     $FFFFFF10,a2
                move.w  #FontLocation+$0B, (A2)          ; Load "*" for sound test
                lea     $FFFFFF16,a2
                move.w  #FontLocation+$0B, (A2)          ; Load "*"


;                jsr     DrawDescription

;-------------------------------------------------------------------------------
; Loads the icon mappings
;-------------------------------------------------------------------------------                                    
                lea     ($FFFF08C0), A1
                lea     (Icons_Mappings), A0
                move.w  #$0090, D0
                jsr     EniDec
;-------------------------------------------------------------------------------
                moveq   #$00, D3
                bsr     PauseMenu_SndTst           ; at the moment this is jumping to the code in s2_menu.asm, cos i haven't finished converting the stuff at the bottom of this file :)
                clr.w   ($FFFFFF70).w
                clr.w   ($FFFFFE40).w
                clr.b   ($FFFFF711).w
                clr.w   ($FFFFF7F0).w
;-------------------------------------------------------------------------------
	        clr.l	($FFFFF7B8).w		; clear RAM adresses $F7B8 to $F7BA  +++ replaced the 2 lines below, caused a crash, can't change a word at an odd ram address
       ;        move.w  #$0000, (v_lani4_frame).w  ; Initializes the frames of the animations menu
       ;        move.w  #$0000, (v_lani4_time).w  ; Initializes the counter of the animations menu
       ;         jsr     Dynamic_Menu           ; Calls the animation routine
;-------------------------------------------------------------------------------

                 moveq   #palid_Menu_Palette, D0
                 jsr     PalLoad1
                 moveq   #palid_Menu_Palette, D0
		jsr	PalLoad4_Water
                lea     ($FFFFFB40).w, A1
                lea     ($FFFFFBC0).w, A2
                moveq   #$07, D1
@loop:
                move.l  (A1), (A2)+
                clr.l   (A1)+
                dbra    D1, @loop
                move.w  #$0707, ($FFFFF614).w
                clr.w   ($FFFFFFDC).w
                clr.l   ($FFFFEE00).w
                clr.l   ($FFFFEE04).w
                clr.w   ($FFFFFF0C).w
                clr.w   ($FFFFFF0E).w
                move.b  #$18, (v_vbla_routine).w
                jsr     WaitForVBla
                move.w  (v_vdp_buffer1).w, D0
                ori.b   #$40, D0
                move.w  D0, ($00C00004)
                cmpi.w  #$0000,(v_levselitem).w  ; is 'use items' text selected?
                bne.s   @skip                    ; if not, branch
                move.w  #$02,(v_levselitem).w    ; change selection to 'shield'
        @skip:
                jsr     DrawDescription          ; draw the descriiption
                jsr     DrawStats                ; draw the stats
                lea     (v_256x256), A1           ; tilemap location
                move.l  #$40000003, D0            ; vram location
                moveq   #$27, D1                  ; tilemap width
                moveq   #$1B, D2                  ; tilemap height
                jsr     TilemapToVRAM             ; write the whole shebang to the screen


                tst.b   (v_levelselnofade).w          ; if flag is set
                bne.s   PauseMenu_Main_Loop           ; skip fading in
;                  moveq   #palid_Menu_Palette, D0
;                  jsr     PalLoad2
        @finishloadinggfx:
                move.b	#$C,(v_vbla_routine).w
		jsr	WaitForVBla
                jsr	RunPLC
 		tst.l	(v_plc_buffer).w ; are there any items in the pattern load cue?
 		bne.s	@finishloadinggfx ; if yes, branch



                jsr     PaletteFadeIn

;===============================================================================
;  Menu Main Loop
;===============================================================================

PauseMenu_Main_Loop:
                move.b  #$01,(v_levelselnofade).w     ; don't fade in again
                move.b  #$01,(f_inmenu).w             ; set in menu flag
                move.b  #$18, (v_vbla_routine).w
                jsr     WaitForVBla
                move    #$2700, SR                    ; interrupt mask level 7
  	        lea     (v_256x256), A1               ; tilemap location                          ------------------------
                move.l  #$40000003, D0                ; vram location                            | not technically needed |
                moveq   #$27, D1                      ; tilemap width                            | but fixes a bug where  |
                moveq   #$1B, D2                      ; tilemap height                           | menu text disappears   |
                jsr     TilemapToVRAM                 ; write the whole shebang to the screen     ------------------------
                moveq   #$00, D3                      ; d3 is used in calculating the VDP command for changing the palette of the highlighted item
                bsr     HighlightItem                 ; clear highlight
                bsr     ChkDpad
                move.w  #$6000, D3                    ; palette line 3 will be set
                bsr     PauseMenu_Highlight           ; highlight item
                move    #$2300, SR                    ; interrupt mask level 3
;               jsr     Dynamic_Menu                  ; run Sonic/Miles animation
                move.b  (v_jpadpress1).w, D0
		andi.b	#btnStart,d0	              ; is start pressed?
                bne.s   @startpressed
                move.b	(v_jpadpress1).w,d0
		andi.b	#btnABC,d0	              ; is A, B or C pressed?
		bne.w	@abcpressed	              ; if so, branch
                bra     PauseMenu_Main_Loop
;===============================================================================

@startpressed:
                cmpi.w  #$000C,(v_levselitem).w  ; is level select selected?
                bne.s   @dontgotomap             ; if not, branch
                jmp     MapScreen_Menu           ; load map screen
    @dontgotomap:
                tst.b   (f_inmenu).w
                bne.w   ExitPauseMenu
                rts

@abcpressed:
                cmpi.w  #$0002,(v_levselitem).w  ; is shield selected?
                bne.s   @notshield               ; if not, branch
                tst.b   (v_inv_shield).w         ; any shields in inventory?
                beq.s   @notshield               ; if not, branch
                subi.b  #$01,(v_inv_shield).w    ; subtract 1 from inventory
		move.b	#1,(v_shield).w	; give Sonic a shield
		move.b	#id_ShieldItem,(v_objspace+$180).w ; load shield object ($38)
		music	sfx_Shield,1	; play shield sound
                bsr.w   PauseMenu_Main_Loop
        @notshield:
                cmpi.w  #$0003,(v_levselitem).w  ; is invinc selected?
                bne.s   @notinvinc                 ; if not, branch
                tst.b   (v_inv_invinc).w         ; any invinc in inventory?
                beq.s   @notinvinc               ; if not, branch
                subi.b  #$01,(v_inv_invinc).w    ; subtract 1 from inventory
		move.b	#1,(v_invinc).w	; make Sonic invincible
		move.w	#$4B0,(v_player+$32).w ; time limit for the power-up
		move.b	#id_ShieldItem,(v_objspace+$200).w ; load stars object ($3801)
		move.b	#1,(v_objspace+$200+obAnim).w
		move.b	#id_ShieldItem,(v_objspace+$240).w ; load stars object ($3802)
		move.b	#2,(v_objspace+$240+obAnim).w
		move.b	#id_ShieldItem,(v_objspace+$280).w ; load stars object ($3803)
		move.b	#3,(v_objspace+$280+obAnim).w
		move.b	#id_ShieldItem,(v_objspace+$2C0).w ; load stars object ($3804)
		move.b	#4,(v_objspace+$2C0+obAnim).w
		tst.b	(f_lockscreen).w ; is boss mode on?
		bne.s	@Pow_NoMusic	; if yes, branch
		if Revision=0
		else
			cmpi.w	#$C,(v_air).w
			bls.s	@Pow_NoMusic
		endc
		music	bgm_Invincible,1 ; play invincibility music
		bsr.w   PauseMenu_Main_Loop  
; ===========================================================================

@Pow_NoMusic:
		rts
; ===========================================================================
        @notinvinc:
                cmpi.w  #$0004,(v_levselitem).w  ; is shoes selected?
                bne.s   @notshoes                 ; if not, branch
                tst.b   (v_inv_shoes).w         ; any shoes in inventory?
                beq.s   @notshoes               ; if not, branch
                subi.b  #$01,(v_inv_shoes).w    ; subtract 1 from inventory
		move.b	#1,(v_shoes).w	        ; speed up the BG music
		move.w	#$4B0,(v_player+$34).w	; time limit for the power-up
                jsr     SetStatEffects
		music	$E2,1		; Speed	up the music
                bsr.w   PauseMenu_Main_Loop
        @notshoes:
                cmpi.w  #$0005,(v_levselitem).w  ; is keys selected?
                bne.s   @notkeys                 ; if not, branch
                nop
        @notkeys:
                bsr.w   PauseMenu_Main_Loop
PauseMenu_Level_Select_Array:
                dc.w    $0000, $0000, $0002        ; 'use items', divider, shield
                dc.w    $0200, $0201, $0202        ; marble
                dc.w    $0400, $0401, $0402        ; spring yard
                dc.w    $0100, $0101, $0102        ; labyrinth
                dc.w    $0300, $0301, $0302        ; star light
                dc.w    $0500, $0501, $0103        ; scrap brain
                dc.w    $0502, $4000, $0600        ; final, special stage, ending
                dc.w    $FFFF                      ; sound test?
                even
PauseMenu_Load_Level:
; the code in here always gets run after the code above
;                jsr     PauseMenu_DrawText         ; redraws the menu
;                jsr     DrawDescription
;                jsr     DrawStats                ; draw the stats
;               rts                                ; uncomment??? quits and reloads the menu
ChkDpad:
                move.b  (v_jpadpress1).w, D1
                andi.b  #$03, D1                   ; are dpad up or down pressed?
                bne.s   @DpadUpDown                ; if so?, branch
                subq.w  #$01, (v_levseldelay).w    ; sub 1 from time until change
                bpl.s   @SndTstSelected            ; if time is positive, branch
@DpadUpDown:
                move.w  #$000B, (v_levseldelay).w  ; set delay to 14? frames?
                move.b  (v_jpadhold1).w, D1
                andi.b  #$03, D1                   ; are dpad up or down held?
                beq.s   @SndTstSelected            ; if not, branch
                move.w  (v_levselitem).w, D0
                btst    #$00, D1                   ; is dpad up held?
                beq.s   @DpadDown                  ; if not, branch
                subq.w  #$01, D0                   ; sub 1 from selected item
;                bcc.s   @DpadDown                 ; if not below 0 branch
                cmpi.w  #$0001,d0                  ; if selected dividing line in 1st column
                bne.s   @skip1
                moveq   #$0005,d0                  ; jump to bottom of 1st column
         @skip1:
                cmpi.w  #$0007,d0                  ; if selected dividing line in 2nd column
                bne.s   @DpadDown
                moveq   #$000C, D0                 ; jump to bottom of 2nd column
@DpadDown:
                btst    #$01, D1                   ; is dpad down held?
                beq.s   @SetSelectedItem           ; if not, branch
                addq.w  #$01, D0                   ; add 1 to selected item
                cmpi.w  #$0006,d0                  ; if gone past the end of 1st column
                bne.s   @skip2
                moveq   #$0002,d0                  ; jump to top of 1st column
         @skip2:
                cmpi.w  #$000D,d0                  ; if gone past the end of 2nd column
                bne.s   @SetSelectedItem
                moveq   #$0008, D0                 ; jump to top of 2nd column

;                 cmpi.w  #$0016, D0   ; is selected item is higher than last item on list?
;                 bcs.s   @SetSelectedItem           ; if not, branch
;                 moveq   #$02, D0                   ; set selected item to 2 (back to start)
@SetSelectedItem:
                move.w  D0, (v_levselitem).w       ; set selected item
;                 move.b  #$01,(v_levelselnofade).w  ; sets flag to stop fade in
;                 jsr     PauseMenu_DrawText
                jsr     DrawDescription
;                jsr     DrawStats                ; draw the stats
                rts
@SndTstSelected:
                cmpi.w  #$000C, (v_levselitem).w   ; is sound test selected?
                bne.w   @NotSndTst                 ; if not, branch
                move.w  (v_levselsound).w, D0
                move.b  (v_jpadpress1).w, D1
                btst    #$02, D1                   ; is dpad left pressed?
                beq.s   @ChkSndTstRight            ; if not, branch
                subq.b  #$01, D0                   ; subtract sound test counter
                bcc.s   @ChkSndTstRight            ; if not past the start of list, branch
                moveq   #$7F, D0                   ; roll sound test counter back to end
@ChkSndTstRight:
                btst    #$03, D1                   ; is dpad right held?
                beq.s   @ChkSndTstA                ; if not, branch
                addq.b  #$01, D0                   ; add 1 to sound test counter
                cmpi.w  #$0080, D0                 ; past the end of list?
                bcs.s   @ChkSndTstA                ; if not, branch
                moveq   #$00, D0                   ; set sount test counter to 0
@ChkSndTstA:
                btst    #$06, D1                   ; is button A is pressed?
                beq.s   @SetSndTstItem             ; if not, branch
                addi.b  #$10, D0                   ; add $10 to sound test counter
                andi.b  #$7F, D0                   ; don't go over $7F
@SetSndTstItem:
                move.w  D0, (v_levselsound).w      ; set sound test item
                andi.w  #$0030, D1                 ; are B or C pressed?
                beq.s   @donothing                 ; if not, branch
                move.w  (v_levselsound).w, D0
                addi.w  #$0080, D0                 ; choose actual sound offset
                cmpi.w  #$0070,(v_levselsound).w     ; is 70 or higher selected?
                bge.s   @dontplaymusic             ; if so, branch (don't crash)
                jsr     PlaySound                  ; start playing music                    
;		move.b	#$80,(f_stopmusic).w       ; let music play (in case it was stopped from pausing)
@dontplaymusic
                cmpi.w  #$007F,(v_levselsound).w     ; is 7F selected?
                bne.s   @not7F                     ; if not, branch
                addi.b  #5,(v_statspeed).w         ; add 1 to speed stat
                jsr     DrawStats                  ; draw the stats
                jsr     SetStatEffects
        @not7F:
                cmpi.w  #$007E,(v_levselsound).w     ; is 7F selected?
                bne.s   @not7E                     ; if not, branch
                addi.b  #5,(v_stataccel).w         ; add 1 to accel stat
                jsr     DrawStats                  ; draw the stats
                jsr     SetStatEffects
        @not7E:
                cmpi.w  #$007D,(v_levselsound).w     ; is 7F selected?
                bne.s   @not7D                     ; if not, branch
                addi.b  #5,(v_statjump).w          ; add 1 to speed stat
                jsr     DrawStats                  ; draw the stats
                jsr     SetStatEffects
        @not7D:

                lea     (Code_Debug_Mode), A0
                lea     (Code_All_Emeralds), A2
                lea     ($FFFFFF0A).w, A1
                moveq   #$01, D2
                bsr     PauseMenu_Code_Test 
@donothing:
                rts
@NotSndTst:
                move.b  (v_jpadpress1).w, D1
                andi.b  #$0C, D1                  ; are dpad left or right pressed?
                beq.s   @donothing2               ; if not, branch
                move.w  (v_levselitem).w, D0
                move.b  PauseMenu_Left_Right_Select(PC, D0), D0
                move.w  D0, (v_levselitem).w
                jsr     DrawDescription
                jsr     DrawStats                ; draw the stats
@donothing2:
                rts

PauseMenu_Left_Right_Select:
                dc.b    $06
                dc.b    $07
                dc.b    $08
                dc.b    $09
                dc.b    $0A
                dc.b    $0B
                     
                dc.b    $00
                dc.b    $01
                dc.b    $02
                dc.b    $03
                dc.b    $04
                dc.b    $05
;                dc.b    $05
                even
HighlightItem:
;  	        lea     (v_256x256), A1           ; tilemap location
;                 move.l  #$40000003, D0            ; vram location
;                 moveq   #$27, D1                  ; tilemap width
;                 moveq   #$1B, D2                  ; tilemap height
;                 jsr     TilemapToVRAM             ; write the whole shebang to the screen
; 
;                 moveq   #0, D3
;                 move.w  #$6000, D3
                lea     (v_256x256), A4           ; load start address of 256x256 block to a4
                lea     (PauseMenu_Text_Highlight), A5     ; load start of highlight array to a5
                lea     ($00C00000), A6           ; load start of vdp ram (vram?) to a6
                moveq   #$00, D0                  ; clear d0
                move.w  (v_levselitem).w, D0      ; set d0 to the number of the selected item
                lsl.w   #$02, D0                  ; multiply d0 by 4 (there are 4 bytes in each line of array)
                lea     $00(A5, D0), A3           ; load address from start of highlight array plus d0 to a3
                moveq   #$00, D0                  ; clear d0
                move.b  (A3), D0                  ; number of rows from top of screen
                mulu.w  #$0050, D0                ; multiply by $0050 (number of tiles in each screen line)
                moveq   #$00, D1                  ; clear d1
                move.b  $0001(A3), D1             ; moves horizontal position (in tiles) times 2 to d1
                add.w   D1, D0                    ; adds d1 to d0 to give total number of tiles (this should be the same as what's in the "PauseMenu_Text_Positions" array)
                lea     $00(A4, D0), A1           ; load 256x256 address plus number of tiles
                moveq   #$00, D1                  ; clear d1
                move.b  (A3), D1                  ; move number of rows from top of screen to d1
                lsl.w   #$07, D1                  ; multiply d1 by 80 ($50 again???)
                add.b   $0001(A3), D1             ; adds horizontal position (in tiles) times 2 to d1
                addi.w  #$C000, D1                ; add $C000 to d1
                lsl.l   #$02, D1                  ;
                lsr.w   #$02, D1                  ; leaves us with highest 2(?) bits in the upper half of d1, lowest 2 in the lower half
                ori.w   #$4000, D1                ;
                swap.w  D1                        ; should end up with 40??00?? (like a vdp address i think???)
                move.l  D1, $0004(A6)             ; moves d1 to $00C00004 (vdp address port)
                moveq   #$0E, D2    ; Number of letters to select (Highlight) $0E
@HighlightLoop:
                move.w  (A1)+, D0                 ; copies data in 256x256 location to d0, and advances for next loop
                add.w   D3, D0                    ; d3 should be #$6000
                move.w  D0, (A6)                  ; sends data to vdp (sets palette to line 3, to colour it yellow)
                dbra    D2, @HighlightLoop        ; loop back if not finished
                addq.w  #$02, A3
                moveq   #$00, D0
                move.b  (A3), D0
                beq.s   @skip
                mulu.w  #$0050, D0                ; this code is the same as above
                moveq   #$00, D1
                move.b  $0001(A3), D1
                add.w   D1, D0
                lea     $00(A4, D0), A1
                moveq   #$00, D1
                move.b  (A3), D1
                lsl.w   #$07, D1
                add.b   $0001(A3), D1
                addi.w  #$C000, D1
                lsl.l   #$02, D1
                lsr.w   #$02, D1
                ori.w   #$4000, D1
                swap.w  D1
                move.l  D1, $0004(A6)             ; moves d1 to vram, (chooses where to draw ???)
                move.w  (A1)+, D0                 ; 256x256 location to d0, and advance
                add.w   D3, D0                    ; d3 should be #$6000
                move.w  D0, (A6)                  ; colours the number yellow
@skip:
                cmpi.w  #$000C, (v_levselitem).w  ; Is Sound Test selected?
                bne.s   @donothing           ; if not, branch
                bsr     SndTstSelected2
@donothing:
                 rts
SndTstSelected2:
                move.l  #$49C60003, ($00C00004) ; Position of numbers from the Sound Test
                move.w  (v_levselsound).w, D0
                move.b  D0, D2
                lsr.b   #$04, D0
                bsr.s   SndTstSelected3
                move.b  D2, D0
SndTstSelected3:
                andi.w  #$000F, D0
                cmpi.b  #$0A, D0
                bcs.s   SndTstSelected4
                addi.b  #$04, D0
SndTstSelected4:
                addi.b  #$10, D0
                add.w   D3, D0
                move.w  D0, (A6)
                rts
;-------------------------------------------------------------------------------
PauseMenu_Code_Test: 
                move.w  ($FFFFFF0C).w, D0
                adda.w  D0, A0
                move.w  (v_levselsound).w, D0
                cmp.b   (A0), D0
                bne.s   PauseMenu_Reset_Debug_Mode_Code_Counter
                addq.w  #$01, ($FFFFFF0C).w
                tst.b   $0001(A0)
                bpl.s   PauseMenu_All_Emeralds_Code_Test 
                move.w  #$0101, (A1)
                bra     PauseMenu_Set_Debug_Flag 
PauseMenu_Reset_Debug_Mode_Code_Counter: 
                move.w  #$0000, ($FFFFFF0C).w
PauseMenu_All_Emeralds_Code_Test: 
                move.w  ($FFFFFF0E).w, D0
                adda.w  D0, A2
                move.w  (v_levselsound).w, D0
                cmp.b   (A2), D0
                bne.s   PauseMenu_Reset_All_Emerald_Code_Counter 
                addq.w  #$01, ($FFFFFF0E).w
                tst.b   $0001(A2)
                bpl.s   PauseMenu_Code_Not_0xFF 
                tst.w   D2
                bne.s   PauseMenu_Set_All_Emeralds 
PauseMenu_Set_Debug_Flag: 
                move.b  #$01, (Slow_Motion_Flag).w
                move.b  #$01, (Debug_Mode_Flag).w
                move.b  #Ring_Snd, D0
                jsr     PlaySound
                bra.s   PauseMenu_Reset_All_Emerald_Code_Counter 
PauseMenu_Set_All_Emeralds: 
                move.w  #$0006, ($FFFFFE56).w
                move.b  #Emerald_Snd2, D0
                jsr     PlaySound
PauseMenu_Reset_All_Emerald_Code_Counter: 
                move.w  #$0000, ($FFFFFF0E).w
PauseMenu_Code_Not_0xFF: 
                rts               
;-------------------------------------------------------------------------------
PauseMenu_SndTst:
                bsr     SndTstSelected2
                bra     PauseMenu_Icons
PauseMenu_Highlight:
                bsr     HighlightItem
                bra     PauseMenu_Icons
PauseMenu_Icons:
                move.w  (v_levselitem).w, D0
                lea     (PauseMenu_Icon_List), A3
                lea     $00(A3, D0), A3
                lea     ($FFFF08C0), A1
                moveq   #$00, D0
                move.b  (A3), D0
                lsl.w   #$03, D0
                move.w  D0, D1
                add.w   D0, D0
                add.w   D1, D0
                lea     $00(A1, D0), A1
;                move.l  #$4B360003, D0        ; Horizontal Icons
                move.l  #$4C020003, D0        ; Horizontal Icons
                moveq   #$03, D1
                moveq   #$02, D2
                jsr     TilemapToVRAM
                lea     (Icon_Palettes), A1  
                moveq   #$00, D0
                move.b  (A3), D0
                lsl.w   #$05, D0
                lea     $00(A1, D0), A1
                lea     ($FFFFFB40).w, A2
                moveq   #$07, D1
@iconpaletteloop:                
                move.l  (A1)+, (A2)+
                dbra    D1, @iconpaletteloop
                rts
; ;-------------------------------------------------------------------------------
; Dynamic_Menu:                           
;                 subq.b  #$01, (v_lani4_time).w          ; Decreases em a time or
;                 bpl.s   Exit_Dinamic_Menu            ; If greater than or equal to 0 leaves the function
;                 move.b  #$07, (v_lani4_time).w          ; Initializes the duration of each frame
;                 move.b  ($FFFFF7B8).w, D0            ; Loads the ID Frame Current in D0
;                 addq.b  #$01, (v_lani4_frame).w          ; Load the next frame at $ FFFFFFB8
;                 andi.w  #$001F, D0
;                 move.b  Sonic_Miles_Frame_Select(PC, D0), D0  ; Loads the ID frame in D0
;               ; muls.w  #$0140, D0                   ; Id multiplies the size in bytes of each frame
;                 lsl.w   #$06, D0
;                 lea     ($00C00000), A6
;                 move.l  #$40200000, $0004(A6)
;                 lea     (Sonic_Miles_Spr), A1
;                 lea     $00(A1, D0), A1
;                 move.w  #$0009, D0                   ; Tiles-1 loaded at a time
; PauseMenu_Loop_Load_Tiles:
;                 move.l  (A1)+, (A6)
;                 move.l  (A1)+, (A6)     
;                 move.l  (A1)+, (A6)     
;                 move.l  (A1)+, (A6)     
;                 move.l  (A1)+, (A6)     
;                 move.l  (A1)+, (A6)
;                 move.l  (A1)+, (A6)
;                 move.l  (A1)+, (A6)
;                 dbra    D0, PauseMenu_Loop_Load_Tiles
; Exit_Dinamic_Menu:                
;                 rts              
; Sonic_Miles_Frame_Select:     
;                 dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;                 dc.b    $05, $0A
;                 dc.b    $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
;                 dc.b    $0A, $05   
;                 ; 0 = 0000000000  ; 1 = 0101000000  ; 2 = 1010000000 ; 3 = 1111000000
; ;------------------------------------------------------------------------------                  

;=================================================================================
DrawDescription:
                lea     (v_256x256), A3;          ; load start address of 256x256 block
                lea     (NoAbility_Description), A1   ; loads first item of first string to a1 (the first byte of the string defines string length)
                cmpi.w  #$0002,(v_levselitem).w  ; is shield selected?
                bne.s   @notshield                 ; if not, branch
                lea     (Shield_Description), A1   ; loads first item of first string to a1 (the first byte of the string defines string length)
        @notshield:
                cmpi.w  #$0003,(v_levselitem).w  ; is invinc selected?
                bne.s   @notinvinc                 ; if not, branch
                lea     (Invinc_Description), A1   ; loads first item of first string to a1 (the first byte of the string defines string length)
        @notinvinc:
                cmpi.w  #$0004,(v_levselitem).w  ; is shoes selected?
                bne.s   @notshoes                 ; if not, branch
                lea     (Shoes_Description), A1   ; loads first item of first string to a1 (the first byte of the string defines string length)
        @notshoes:
                cmpi.w  #$0005,(v_levselitem).w  ; is keys selected?
                bne.s   @notkeys                 ; if not, branch
                lea     (Keys_Description), A1   ; loads first item of first string to a1 (the first byte of the string defines string length)
        @notkeys:
                cmpi.w  #$0008,(v_levselitem).w  ; is spin dash selected?
                bne.s   @notspindash             ; if not, branch
 	        btst    #1,(v_abilities).w       ; have spin dash ability?
                beq.s   @notspindash             ; if not, branch
                lea     (Spindash_Description), A1   ; loads first item of first string to a1 (the first byte of the string defines string length)
        @notspindash:
                cmpi.w  #$0009,(v_levselitem).w  ; is air hop selected?
                bne.s   @notairhop               ; if not, branch
 	        btst    #0,(v_abilities).w
                beq.s   @notairhop               ; if not, branch
                lea     (AirHop_Description), A1   ; loads first item of first string to a1 (the first byte of the string defines string length)
        @notairhop:
                cmpi.w  #$000A,(v_levselitem).w  ; is jump dash selected?
                bne.s   @notjumpdash             ; if not, branch
 	        btst    #3,(v_abilities).w       ; have jump dash ability?
                beq.s   @notjumpdash             ; if not, branch
                lea     (JumpDash_Description), A1   ; loads first item of first string to a1 (the first byte of the string defines string length)
        @notjumpdash:
                cmpi.w  #$000B,(v_levselitem).w  ; is goggles selected?
                bne.s   @notgoggles              ; if not, branch
 	        btst    #2,(v_abilities).w       ; have goggles?
                beq.s   @notgoggles               ; if not, branch
                lea     (Goggles_Description), A1   ; loads first item of first string to a1 (the first byte of the string defines string length)
        @notgoggles:
                cmpi.w  #$000c,(v_levselitem).w    ; is sound test selected?
                bne.s   @notsndtst                 ; if not, branch
                lea     (SoundTest_Description), A1   ; loads first item of first string to a1 (the first byte of the string defines string length)
        @notsndtst:
                lea     (Description_Text_Positions), A5
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                move.w  #$0004, D1               ; set loop counter to 13 (the number of options)
Description_Loop_Load_Text:
                move.w  (A5)+, D3                ; put required text position in d3, advance a5 to next item (for next time it loops)
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position???
                moveq   #$00, D2                 ; clear d2
                move.b  (A1)+, D2                ; set d2 to length of string, advance a1 to first letter in string
                move.w  D2, D3                   ; set d3 to length of string as well
@loadtextloop1:
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                move.b  (A1)+, D0                ; set d0 to letter required, advance a1 to letter for next loop around
                add.w   #FontLocation,d0         ; add vram offset
                move.w  D0, (A2)+                ; set a2 to letter required and advance
                dbra    D2, @loadtextloop1       ; if d2 is over 0 loop back and draw next letter
                move.w  #$0004, D2               ; set d2 to 13
                sub.w   D3, D2                   ; sub d3(string length from before (should be 14)) from d2(13)
                dbra    D1, Description_Loop_Load_Text ; if all lines drawn, continue, otherwise loop back and draw the next line
                lea     (v_256x256), A1
                move.l  #$40000003, D0
                moveq   #$27, D1
                moveq   #$1B, D2
                jsr     TilemapToVRAM             ; write the whole shebang to the screen

                rts

;========================================================================================================================

DrawStats:
                lea     (v_256x256), A3         ; load start address of 256x256 block
                lea     (StatText), A1          ; loads first item of first string to a1 (the first byte of the string defines string length)
                lea     (StatTextPosotions), A5
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                move.w  #$0004, D1               ; set loop counter to 13 (the number of options)
Stats_Loop_Load_Text:
                move.w  (A5)+, D3                ; put required text position in d3, advance a5 to next item (for next time it loops)
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position???
                moveq   #$00, D2                 ; clear d2
                move.b  (A1)+, D2                ; set d2 to length of string, advance a1 to first letter in string
                move.w  D2, D3                   ; set d3 to length of string as well
@loadtextloop1:
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                move.b  (A1)+, D0                ; set d0 to letter required, advance a1 to letter for next loop around
                add.w   #FontLocation,d0         ; add vram offset
                move.w  D0, (A2)+                ; set a2 to letter required and advance
                dbra    D2, @loadtextloop1       ; if d2 is over 0 loop back and draw next letter
                move.w  #$0006, D2               ; set d2 to 13
                sub.w   D3, D2                   ; sub d3(string length from before (should be 14)) from d2(13)
@drawnumber:
                cmpi.b  #$04,d1                  ; is 'statistics' being drawn?
                bne.s   @skipheader1             ; if so, branch
                move.w  #FontLocation+$00, (A2)  ; Load " "
       @skipheader1:
                cmpi.b  #$03,d1                  ; is dividing line in being drawn?
                bne.s   @skipline1               ; if not, branch
                move.w  #FontLocation+$29, (A2)  ; Load "-"
       @skipline1:

                cmpi.b  #$02,d1                  ; is speed being drawn
                bne.s   @notspeed                ; if not, branch
                move.w  #$0010, (A2)             ; draw "0"
                sub.w   #$04,a2                  ; move drawing position back to draw 100s column
		moveq	#0,d5
		move.b	(v_statspeed).w,d5	         ; load stat
		lea	(Hud_100).l,a6
		moveq	#2,d6                    ; number of digits (ie. 3)
                bsr.w   DrawDecimal
       @notspeed:

                cmpi.b  #$01,d1                  ; is accel being drawn
                bne.s   @notaccel                ; if not, branch
                move.w  #$0010, (A2)             ; draw "0"
                sub.w   #$04,a2                  ; move drawing position back to draw 100s column
		moveq	#0,d5
		move.b	(v_stataccel).w,d5	         ; load stat
		lea	(Hud_100).l,a6
		moveq	#2,d6                    ; number of digits (ie. 3)
                bsr.w   DrawDecimal
       @notaccel:

                cmpi.b  #$00,d1                  ; is accel being drawn
                bne.s   @notjump                ; if not, branch
                move.w  #$0010, (A2)             ; draw "0"
                sub.w   #$04,a2                  ; move drawing position back to draw 100s column
		moveq	#0,d5
		move.b	(v_statjump).w,d5	         ; load stat
		lea	(Hud_100).l,a6
		moveq	#2,d6                    ; number of digits (ie. 3)
                bsr.w   DrawDecimal
       @notjump:

                 dbra    D1, Stats_Loop_Load_Text ; if all lines drawn, continue, otherwise loop back and draw the next line
;                 lea     (v_256x256), A1
;                 move.l  #$40000003, D0
;                 moveq   #$27, D1
;                 moveq   #$1B, D2
;                 jsr     TilemapToVRAM             ; write the whole shebang to the screen

                rts
                even
; ===========================================================================
DrawDecimal:
       ; convert to decimal
		moveq	#0,d4                    ; clear d4

@mainloop:
		moveq	#0,d2                    ; clear d2 (carried digit)
		move.l	(a6)+,d3                 ; what to multiply digit by

@loopback:
		sub.l	d3,d5                    ; subtract from number of rings
		bcs.s	@carry                   ; branch on carry set
		addq.w	#1,d2                    ; add 1 to carried digit
		bra.s	@loopback                ; skip next bit
; ===========================================================================

@carry:                                          ; if no carried digit
		add.l	d3,d5                    ; add back to number of rings
		tst.w	d2                       ; is there a carried digit?
		beq.s	@nocarry                 ; if not, branch
		move.w	#1,d4                    ; put 1 in d4

@nocarry:
		tst.w	d4                       ; is there anything in d4?
		beq.s	@skipdraw                ; if not, dont't draw anything
;		lsl.w	#6,d2

                addi.w  #FontLocation+$01,d2     ; set it to the correct tile
                move.w  d2,(a2)                  ; draw it, move drawing position back a tile for next digit
                subi.w  #FontLocation+$01,d2     ; set it to the correct tile

@skipdraw:
                move.w  (a2)+,d4                 ; draw it, move drawing position to next digit (d4 is irrelevant here, just need to increment)
		dbf	d6,@mainloop             ; loop function

		rts	
                even
; ===========================================================================

DrawBacker:
; pass values: d3 - start location, d2 - width, d1 - height
                lea     (v_256x256), A3          ; load start address of 256x256 block
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position
                move.w  D2, D4                   ; set d4 to length of string as well, so we can reset d2 later
      @drawtopleft:
                move.w  #FontLocation+$2C, (A2)+ ; set a2 to top left corner and advance
                sub.w   #1,d2                    ; sub 1 from width counter
      @drawtopline:
                cmpi.w  #1,d2                    ; are we down to the last one
                beq.s   @drawtopright            ; if so, branch
                move.w  #FontLocation+$2F, (A2)+ ; set a2 to top and advance
                sub.w   #1,d2                    ; sub 1 from width counter
                bra.s   @drawtopline             ; loop
      @drawtopright:
                move.w  #FontLocation+$32, (A2)+ ; set a2 to top right corner and advance
                sub.w   #1,d1                    ; sub 1 from height counter

      @drawsideleft:
                move.w  d4, d2                   ; reset width counter
                add.w   #$0050,d3                  ; set draw position to next line
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position

                move.w  #FontLocation+$2D, (A2)+ ; set a2 to left side and advance
                sub.w   #1,d2                    ; sub 1 from width counter
      @drawmiddletile:
                cmpi.w  #1,d2                    ; are we down to the last one
                beq.s   @drawsideright           ; if so, branch
                move.w  #FontLocation+$30, (A2)+ ; set a2 to backing tile and advance
                sub.w   #1,d2                    ; sub 1 from width counter
                bra.s   @drawmiddletile          ; loop
      @drawsideright:
                move.w  #FontLocation+$33, (A2)+ ; set a2 to right side and advance
                sub.w   #1,d1                    ; sub 1 from height counter

                cmpi.b  #1,d1                    ; only one line left to draw?
                beq.s   @drawbottomleft          ; if so, branch
                bra.s   @drawsideleft            ; loop

      @drawbottomleft:
                move.w  d4, d2                   ; reset width counter
                add.w   #$0050,d3                  ; set draw position to next line
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position

                move.w  #FontLocation+$2E, (A2)+ ; set a2 to bottom left corner and advance
                sub.w   #1,d2                    ; sub 1 from width counter
      @drawbottomline:
                cmpi.w  #1,d2                    ; are we down to the last one
                beq.s   @drawbottomright         ; if so, branch
                move.w  #FontLocation+$31, (A2)+ ; set a2 to bottom and advance
                sub.w   #1,d2                    ; sub 1 from width counter
                bra.s   @drawbottomline          ; loop
      @drawbottomright:
                move.w  #FontLocation+$34, (A2)+ ; set a2 to bottom right corner and advance


                rts



@loadtextloop1:
                move.b  (A1)+, D0                ; set d0 to letter required, advance a1 to letter for next loop around
                move.w  D0, (A2)+                ; set a2 to letter required and advance
                dbra    D2, @loadtextloop1       ; if d2 is over 0 loop back and draw next letter
                move.w  #$0006, D2               ; set d2 to 13
                sub.w   D3, D2                   ; sub d3(string length from before (should be 14)) from d2(13)
                dbra    D1, Description_Loop_Load_Text ; if all lines drawn, continue, otherwise loop back and draw the next line




; ;-------------------------------------------------------------------------------
; Wings_Mappings:
;                 dc.w    $6000, $6000, $6000, $604D, $604E, $684E, $684D, $6000, $6000, $6000
;Wings_Line_1:
;                 dc.w    $604F, $6050, $6051, $6052, $6053, $6853, $6852, $6851, $6850, $684F
;Wings_Line_2:
;                 dc.w    $6054, $6055, $6056, $6057, $6057, $6057, $6057, $6856, $6855, $6854
;Wings_Line_3:
;                 dc.w    $6058, $6059, $605A, $6057, $6057, $6057, $6057, $685A, $6859, $6858
;Wings_Line_4:
;                 dc.w    $605B, $605C, $605D, $6057, $6057, $6057, $6057, $685D, $685C, $685B
;Wings_Line_5:
;                 dc.w    $6000, $605E, $605F, $6060, $6061, $6062, $6063, $6064, $685E, $6000
;Wings_Line_6:
;                 dc.w    $6000, $6000, $6065, $6066, $6067, $6867, $6866, $6865, $6000, $6000
;-------------------------------------------------------------------------------    
; Menu_Palette:                                       this stuff's already included in the level select code
;                 incbin  'data\menu\menu.pal'
;-------------------------------------------------------------------------------
; Menu_Font:
;                 incbin  'data\menu\menufont.nem'
; Level_Icons:
;                 incbin  'data\menu\levelico.nem'   
; Menu_Mappings:
;                 incbin  'data\menu\menubg.eni'
; Icons_Mappings:
;                 incbin  'data\menu\iconsmap.eni'
; Sonic_Miles_Spr:                                         
;                 incbin  'data\menu\soncmils.dat'   
;===============================================================================
; Menu 2 Sonic Sonic In a reprogrammed by Esrael L. G. Grandson
; [End]
;===============================================================================
ExitPauseMenu:

                move.b  (v_jpadpress1).w, D0          ;
		andi.b	#btnStart,d0	; is start pressed?
                bne.s   @startpressed
                bsr.w   PauseMenu_Main_Loop
@startpressed:
;                move    #$2700, SR                    ; interrupt mask level 7
                andi.w  #$3FFF, D0
	        jsr     PaletteFadeOut
	        jsr     LevelDataLoad
;		move	#$2700,sr
;		jsr	ClearScreen
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
		clr.w	($FFFFC800).w              ; +++ ProcessDMAQueue crap
		move.l	#$FFFFC800,($FFFFC8FC).w   ; +++
		clr.b   (f_inmenu).w
		clr.b   (v_levelselnofade).w

		moveq	#plcid_Explode,d0
		jsr	(NewPLC).l	; load explosion patterns
 		jsr     RunPLC
		jsr	(LoadAnimalPLC).l ; load animal patterns

@loadGHZ
 		cmpi.b	#id_GHZ,(v_zone).w ; is level GHZ?
 		bne.s	@loadLZ	; if not, branch
;                 move.l  #$40000000, ($00C00004)
;                 lea     (Nem_GHZ_1st), A0
;                 jsr     NemDec
;                 moveq	#plcid_GHZmenu,d0
; 		jsr	NewPLC	; load GHZ patterns
; 		jsr     RunPLC
                moveq	#palid_GHZ,d0
		jsr	PalLoad1

@loadLZ
 		cmpi.b	#id_LZ,(v_zone).w ; is level LZ?
 		bne.s	@loadMZ	; if not, branch
;                 move.l  #$40000000, ($00C00004)
;                 lea     (Nem_LZ), A0
;                 jsr     NemDec
;                 moveq	#plcid_LZ,d0
; 		jsr	NewPLC   	; load LZ patterns
; 		jsr     RunPLC
 		move.w	(v_hbla_hreg).w,(a6)
 		move.w	#$8A00+223,(v_hbla_hreg).w ; set palette change position (for water)
		move.w	#$8014,(a6)	; enable H-interrupts
		move.b	#1,(f_water).w	; enable water
		moveq	#palid_LZSonWater,d0 ; palette number $F (LZ)
		cmpi.b	#3,(v_act).w	; is act number 3?
		bne.s	@Level_WaterPal	; if not, branch
		moveq	#palid_SBZ3SonWat,d0 ; palette number $10 (SBZ3)

	@Level_WaterPal:
;		jsr	PalLoad3_Water	; load underwater palette

        @Level_ChkWaterPal:
		moveq	#palid_LZWater,d0 ; palette $B (LZ underwater)
		cmpi.b	#3,(v_act).w	; is level SBZ3?
		bne.s	@Level_WtrNotSbz	; if not, branch
		moveq	#palid_SBZ3Water,d0 ; palette $D (SBZ3 underwater)

	@Level_WtrNotSbz:
		jsr	PalLoad4_Water
; 		move.b	($FFFFFE53).w,(f_wtr_state).w
;                 moveq	#palid_LZ,d0
;  		jsr	PalLoad1
@loadMZ
 		cmpi.b	#id_MZ,(v_zone).w ; is level MZ?
 		bne.s	@loadSLZ	; if not, branch
;                 move.l  #$40000000, ($00C00004)
;                 lea     (Nem_MZ), A0
;                 jsr     NemDec
;                 moveq	#plcid_MZ,d0
; 		jsr	NewPLC   	; load MZ patterns
; 		jsr     RunPLC
                moveq	#palid_MZ,d0
		jsr	PalLoad1
@loadSLZ
 		cmpi.b	#id_SLZ,(v_zone).w ; is level SLZ?
 		bne.s	@loadSYZ	; if not, branch
;                 move.l  #$40000000, ($00C00004)
;                 lea     (Nem_SLZ), A0
;                 jsr     NemDec
;                 moveq	#plcid_SLZ,d0
; 		jsr	NewPLC	; load SLZ patterns
; 		jsr     RunPLC
                moveq	#palid_SLZ,d0
		jsr	PalLoad1
@loadSYZ
 		cmpi.b	#id_SYZ,(v_zone).w ; is level SYZ?
 		bne.s	@loadSBZ	; if not, branch
;                 move.l  #$40000000, ($00C00004)
;                 lea     (Nem_SYZ), A0
;                 jsr     NemDec
;                 moveq	#plcid_SYZ,d0
; 		jsr	NewPLC	; load SYZ patterns
; 		jsr     RunPLC
                moveq	#palid_SYZ,d0
		jsr	PalLoad1
@loadSBZ
 		cmpi.b	#id_SBZ,(v_zone).w ; is level SBZ?
		bne.s	@loadHubZ	; if not, branch
;                 move.l  #$40000000, ($00C00004)
;                 lea     (Nem_SBZ), A0
;                 jsr     NemDec
;                 moveq	#plcid_SBZ,d0
; 		jsr	NewPLC	; load SBZ patterns
; 		jsr     RunPLC
                moveq	#palid_SBZ1,d0
		jsr	PalLoad1
@loadHubZ
 		cmpi.b	#id_HUBZ,(v_zone).w ; is level HUBZ?
		bne.s	@endload	; if not, branch
;                 move.l  #$40000000, ($00C00004)
;                 lea     (Nem_HUBZ), A0
;                 jsr     NemDec
;                 moveq	#plcid_HubZ,d0
; 		jsr	NewPLC	; load Hub Zone patterns
; 		jsr     RunPLC
                moveq	#palid_HUBZ,d0
		jsr	PalLoad1
@endload
		; restore the background positions
; 		move.w	($FFFFFE40).w,(v_screenposx).w
; 		move.w	($FFFFFE42).w,(v_screenposy).w
                move.w	($FFFFFE44).w,($FFFFF708).w
		move.w	($FFFFFE46).w,($FFFFF70C).w
		move.w	($FFFFFE48).w,($FFFFF710).w
		move.w	($FFFFFE4A).w,($FFFFF714).w
		move.w	($FFFFFE4C).w,($FFFFF718).w
		move.w	($FFFFFE4E).w,($FFFFF71C).w

;		jsr	LevelSizeLoad
		jsr	DeformLayers
		bset	#2,(v_bgscroll1).w
;		jsr	LevelDataLoad ; load block mappings and palettes
		jsr	LoadTilesFromStart
;		jsr	FloorLog_Unk
;		jsr	ColIndexLoad
;		jsr	LZWaterFeatures
		moveq	#palid_Sonic,d0
		jsr	PalLoad1	; load Sonic's palette
		move.b	#id_SonicPlayer,(v_objspace).w ; load Sonic object
; @finishloadinggfx:
; 		move.b	#$C,(v_vbla_routine).w
; 		jsr	WaitForVBla
; ; 		jsr	ExecuteObjects
; ; 		jsr	BuildSprites
;                 jsr	RunPLC
;  		tst.l	(v_plc_buffer).w ; are there any items in the pattern load cue?
;  		bne.s	@finishloadinggfx ; if yes, branch
 		jsr     PaletteFadeIn
;                jsr     Pause_EndMusic
;   		move.w	#$202F,(v_pfade_start).w ; fade in 2nd, 3rd & 4th palette lines
;   		jsr	PalFadeIn_Alt
; 		move.w	#3,d1
; 
; 	@Level_DelayLoop:
; 		move.b	#8,(v_vbla_routine).w
; 		jsr	WaitForVBla
; 		dbf	d1,@Level_DelayLoop
                move    #$2300, SR                    ; interrupt mask level 3
 		move.w	#0,(f_pause).w	; unpause the game
endloadgraphics:
; 		clr.b   (f_leavemenu).w
                rts









;========================================================================================================================
; TEXTS
;========================================================================================================================




;========================================================================================================================
; Text Equates
;========================================================================================================================
__ = $00      ; space
_0 = $01
_1 = $02
_2 = $03
_3 = $04
_4 = $05
_5 = $06
_6 = $07
_7 = $08
_8 = $09
_9 = $0A
_st = $0B     ; star
_com = $0C    ; comma
_co = $0D     ; colon
_stop = $0E   ; full stop
_A = $0F
_B = $10
_C = $11
_D = $12
_E = $13
_F = $14
_G = $15
_H = $16
_I = $17
_J = $18
_K = $19
_L = $1A
_M = $1B
_N = $1C
_O = $1D
_P = $1E
_Q = $1F
_R = $20
_S = $21 ;$6B0 ;
_T = $22
_U = $23
_V = $24
_W = $25
_X = $26
_Y = $27
_Z = $28
_da = $29     ; dash
_qm = $2B     ; question mark

;========================================================================================================================
; Menu text
;========================================================================================================================
PauseMenu_Text_Highlight:            ; in pairs of 2, i think. first is the text to highlight, second is the number
                dc.w    $0C06, $0C24  ; 'use items'                                  ; as for the numbers themselves,
                dc.w    $0D06, $0D24  ; dividing line                                ; the first byte is how many rows from the top it is,
                dc.w    $0E06, $0E24  ; shield                                       ; the second is the horizontal rows multiplied by 2 for some reason
                dc.w    $0F06, $0F24  ; invincibility
                dc.w    $1006, $1024  ; speed shoes
                dc.w    $1106, $1124  ; keys
                

;                 dc.w    $0706, $0824, $0706, $0924, $0B06, $0B24, $0B06, $0C24
;                 dc.w    $0B06, $0D24, $0F06, $0F24, $0F06, $1024, $0F06, $1124
;                 dc.w    $1306, $1324, $1306, $1424, $1306, $1524,

                dc.w    $0C2C, $0C4A   ; 'abilities'
                dc.w    $0D2C, $0D4A   ; dividing line
                dc.w    $0E2C, $0E4A   ; spin dash
                dc.w    $0F2C, $0F4A   ; air hop
                dc.w    $102C, $010A   ; jump dash
                dc.w    $112C, $114A   ; goggles
                dc.w    $132C, $134A   ; sound test
                even
;-------------------------------------------------------------------------------
PauseMenu_Text_Positions:   ; I think these numbers are how many 8x8 tiles before drawing each option
                dc.w    $03C6          ; 'use items'                  $0000               $000C
                dc.w    $0416          ; dividing line                $0001               $000B
                dc.w    $0466          ; shield                       $0002               $000A
                dc.w    $04B6          ; invincibility                $0003               $0009
                dc.w    $0506          ; speed shoes                  $0004               $0008
                dc.w    $0556          ; keys                         $0005               $0007

                dc.w    $03EC          ; 'abilities'                  $0006               $0006
                dc.w    $043C          ; dividing line                $0007               $0005
                dc.w    $048C          ; spin dash                    $0008               $0004
                dc.w    $04DC          ; air hop                      $0009               $0003
                dc.w    $052C          ; jump dash                    $000A               $0002
                dc.w    $057C          ; goggles                      $000B               $0001

                dc.w    $061C          ; sound test                   $000C               $0000
                even
;-------------------------------------------------------------------------------
PauseMenu_Level_Select_Text:
                dc.b    $0E, _U, _S, _E, __, _I, _T, _E, _M, _S, __, __, __, __, __, __
                dc.b    $0E, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da
                dc.b    $0E, _S, _H, _I, _E, _L, _D, __, __, __, __, __, __, __, __, __
                dc.b    $0E, _I, _N, _V, _I, _N, _C, _I, _B, _I, _L, _I, _T, _Y, __, __
                dc.b    $0E, _S, _P, _E, _E, _D, __, _S, _H, _O, _E, _S, __, __, __, __
                dc.b    $0E, _K, _E, _Y, _S, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, _A, _B, _I, _L, _I, _T, _I, _E, _S, __, __, __, __, __, __
                dc.b    $0E, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da
                dc.b    $0E, _S, _P, _I, _N, _D, _A, _S, _H, __, __, __, __, __, __, __
                dc.b    $0E, _A, _I, _R, __, _H, _O, _P, __, __, __, __, __, __, __, __
                dc.b    $0E, _J, _U, _M, _P, __, _D, _A, _S, _H, __, __, __, __, __, __
                dc.b    $0E, _G, _O, _G, _G, _L, _E, _S, __, __, __, __, __, __, __, __
                dc.b    $0E, _S, _O, _U, _N, _D, __, _T, _E, _S, _T, __, __, _st,__, __
                even
; ;-------------------------------------------------------------------------------

;========================================================================================================================
; Statistics text
;========================================================================================================================

StatTextPosotions:   ; I think these numbers are how many 8x8 tiles before drawing each option
                dc.w    $011C          ; 'stats      '                $0000               $0005
                dc.w    $016C          ; dividing line                $0001               $0004
                dc.w    $01BC          ; speed                        $0002               $0003
                dc.w    $020C          ; accel                        $0003               $0002
                dc.w    $025C          ; jump                         $0004               $0001
                even

StatText:
                dc.b    $0E, _S, _T, _A, _T, _I, _S, _T, _I, _C, _S, __, __, __, __, __
                dc.b    $0E, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da
                dc.b    $0E, _M, _A, _X, __, _S, _P, _E, _E, _D, __, __, __, __, __, __
                dc.b    $0E, _A, _C, _C, _E, _L, _E, _R, _A, _T, _I, _O, _N, __, __, __
                dc.b    $0E, _J, _U, _M, _P, __, _H, _E, _I, _G, _H, _T, __, __, __, __
                even

;========================================================================================================================
; Descriptions
;========================================================================================================================
Description_Text_Positions:   ; I think these numbers are how many 8x8 tiles before drawing each option
                dc.w    $078C          ; line1                        $0002               $0004
                dc.w    $07DC          ; line2                        $0003               $0003
                dc.w    $082C          ; line3                        $0004               $0002
                dc.w    $087C          ; line5                        $0005               $0001
                dc.w    $08A6          ; line6                        $0006               $0000
                even
Shield_Description:
                dc.b    $1D, _P, _R, _O, _T, _E, _C, _T, _S, __, _S, _O, _N, _I, _C, __, _F, _R, _O, _M, __, _O, _N, _E, __, _H, _I, _T, _stop, __, __
                dc.b    $1D, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $1D, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                even
Invinc_Description:
                dc.b    $1D, _G, _R, _A, _N, _T, _S, __, _S, _O, _N, _I, _C, __, _2, _0, __, _S, _E, _C, _O, _N, _D, _S, __, _O, _F, __, __, __, __
                dc.b    $1D, _I, _N, _V, _I, _N, _C, _I, _B, _I, _L, _I, _T, _Y, _stop, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $1D, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                even
Shoes_Description:
                dc.b    $1D, _G, _R, _A, _N, _T, _S, __, _S, _O, _N, _I, _C, __, _2, _0, __, _S, _E, _C, _O, _N, _D, _S, __, _O, _F, __, __, __, __
                dc.b    $1D, _S, _U, _P, _E, _R, __, _S, _P, _E, _E, _D, _stop, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $1D, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                even
Keys_Description:
                dc.b    $1D, _W, _H, _Y, __, _D, _O, _E, _S, __, _S, _O, _N, _I, _C, __, _N, _E, _E, _D, __, _K, _E, _Y, _S, _qm, __, _W, _H, _O, __
                dc.b    $1D, _T, _H, _E, __, _H, _E, _L, _L, __, _K, _N, _O, _W, _S, _qm, __, _C, _E, _R, _T, _A, _I, _N, _L, _Y, __, _N, _O, _T, __
                dc.b    $1D, _M, _E, _stop, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                even
NoAbility_Description:
                dc.b    $1D, _Y, _O, _U, __, _D, _O, __, _N, _O, _T, __, _H, _A, _V, _E, __, _T, _H, _I, _S, __, _A, _B, _I, _L, _I, _T, _Y, __, __
                dc.b    $1D, _Y, _E, _T, _stop, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $1D, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                even
Spindash_Description:
                dc.b    $1D, _D, _U, _C, _K, __, _A, _N, _D, __, _T, _A, _P, __, _J, _U, _M, _P, __, _T, _O, __, _R, _E, _V, __, _U, _P, _stop, __, __
                dc.b    $1D, _R, _E, _L, _E, _A, _S, _E, __, _T, _O, __, _T, _A, _K, _E, __, _O, _F, _F, _stop, __, __, __, __, __, __, __, __, __, __
                dc.b    $1D, _U, _S, _E, _F, _U, _L, __, _F, _O, _R, __, _B, _R, _E, _A, _K, _I, _N, _G, __, _W, _A, _L, _L, _S, _stop, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                even
AirHop_Description:
                dc.b    $1D, _P, _R, _E, _S, _S, __, _A, __, _I, _N, __, _M, _I, _D, _da, _A, _I, _R, __, _T, _O,  __, _P, _E, _R, _F, _O, _R, _M, __
                dc.b    $1D, _A, __, _D, _O, _U, _B, _L, _E, __, _J, _U, _M, _P, _stop, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $1D, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                even
JumpDash_Description:
                dc.b    $1D, _P, _R, _E, _S, _S, __, _B, __, _I, _N, __, _M, _I, _D, _da, _A, _I, _R, __, _T, _O,  __, _P, _E, _R, _F, _O, _R, _M, __
                dc.b    $1D, _A, __,  _J, _U, _M, _P, __, _D, _A, _S, _H, _stop, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $1D, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, _P, _O, _W, _E, _R, __, _L, _E, _V, _E, _L, __, _1, __, __
                even
Goggles_Description:
                dc.b    $1D, _B, _R, _E, _A, _T, _H, _E, __, _U, _N, _D, _E, _R, _W, _A, _T, _E, _R, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $1D, _I, _N, _D, _E, _F, _I, _N, _I, _T, _L, _Y, _stop, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $1D, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                even
SoundTest_Description:
                dc.b    $1D, _T, _E, _S, _T, __, _T, _H, _E, __, _S, _O, _U, _N, _D, _S,_com, __, _D, _U, _H, __, __, __, __, __, __, __, __, __, __
                dc.b    $1D, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $1D, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                even

;========================================================================================================================
; Menu text
;========================================================================================================================


; ;-------------------------------------------------------------------------------
PauseMenu_Icon_List:
                dc.b    $00  ; 'use items'
                dc.b    $00  ; dividing line
                dc.b    $03  ; shield
                dc.b    $01  ; invincibility
                dc.b    $02  ; speed shoes
                dc.b    $06  ; keys
                dc.b    $0B  ; 'abilites'
                dc.b    $0B  ; dividing line
                dc.b    $0B  ; spin dash
                dc.b    $0C  ; air hop
                dc.b    $0E  ; jump dash
                dc.b    $10  ; goggles
                dc.b    $11  ; sound test
                even
; ;-------------------------------------------------------------------------------
; Icon_Palettes:
;                 dc.w    $0000, $0000, $0048, $006A, $008E, $00CE, $0EEE, $00E0
;                 dc.w    $00A4, $0082, $0062, $0000, $0E86, $0026, $0E42, $0C00
;                 dc.w    $0000, $0000, $0420, $0820, $0C00, $0E60, $0A00, $0000
;                 dc.w    $0E00, $0000, $0000, $0000, $0444, $0666, $0AAA, $0EEE
;                 dc.w    $0000, $0204, $0026, $0248, $046A, $048C, $06CE, $0002
;                 dc.w    $0000, $0220, $0040, $0060, $0080, $02A0, $06E0, $0A0C
;                 dc.w    $0000, $0000, $0A00, $0660, $0C80, $0EC0, $006A, $0008
;                 dc.w    $028A, $00AE, $004C, $006E, $0060, $0066, $00C0, $00CA
;                 dc.w    $0000, $0000, $0CE2, $0000, $0480, $0240, $0EEE, $04AC
;                 dc.w    $006A, $0026, $0842, $0620, $0400, $0000, $0000, $0000
;                 dc.w    $0000, $0000, $0EEE, $0ECA, $0E86, $0E64, $0E42, $06AE
;                 dc.w    $048A, $0268, $0246, $0024, $0888, $0444, $000E, $0008
;                 dc.w    $0000, $0000, $0A26, $0C48, $0E8C, $00CE, $00C4, $0080
;                 dc.w    $0C00, $0000, $0EEE, $0EEA, $0EC8, $006E, $004A, $0028
;                 dc.w    $0000, $0000, $0048, $006A, $008E, $00CE, $0EEE, $00E0
;                 dc.w    $00A4, $0082, $0062, $0808, $0A4A, $0026, $0626, $0404
;                 dc.w    $0000, $0000, $0EEE, $0ECA, $0E86, $0E64, $0E42, $06AE
;                 dc.w    $048A, $0268, $0246, $0024, $0888, $0444, $000E, $0008
;                 dc.w    $0000, $0000, $0048, $006A, $008E, $00CE, $0EEE, $00E0
;                 dc.w    $00A4, $0082, $0062, $0400, $0E86, $006E, $0E42, $0C00
;                 dc.w    $0000, $0000, $0CE2, $08C0, $0480, $0240, $0EEE, $02AC
;                 dc.w    $006A, $0026, $0AA6, $0000, $060A, $0408, $0204, $0000
;                 dc.w    $0000, $0000, $0C06, $0C0A, $0C6E, $0068, $008A, $0000
;                 dc.w    $02CE, $00EC, $00AE, $006E, $0EEE, $0000, $000E, $00C4
;                 dc.w    $0000, $0000, $0EEE, $0AAA, $0000, $0666, $0444, $0E40
;                 dc.w    $0C00, $0800, $00CE, $028E, $000E, $0084, $0062, $0020
;                 dc.w    $0000, $0000, $0004, $0044, $0084, $0088, $00A8, $00AC
;                 dc.w    $006C, $002C, $0028, $0006, $0666, $0888, $0CCC, $0EEE
;                 dc.w    $0000, $0000, $06CE, $04AC, $028A, $0068, $0046, $00E8
;                 dc.w    $00C4, $0080, $0040, $0EEE, $0C00, $0EC0, $0860, $0000
;                 dc.w    $0000, $0000, $0E64, $0E86, $0EA8, $0ECA, $0EEE, $0000
;                 dc.w    $00AE, $006E, $0E22, $00E0, $0000, $0000, $0000, $0000
;                 dc.w    $0000, $0E20, $004E, $006E, $0048, $008C, $00CE, $08EE
;                 dc.w    $0800, $0400, $0000, $0EE8, $0E80, $0E60, $0000, $0000
;                 dc.w    $0000, $0000, $0A22, $0C42, $0000, $0E66, $0EEE, $0AAA
;                 dc.w    $0888, $0444, $08AE, $046A, $000E, $0000, $00EE, $0000
;                 dc.w    $0000, $0000, $0A22, $0C42, $0000, $0E66, $0EEE, $0AAA
;                 dc.w    $0888, $0444, $08AE, $046A, $000E, $0000, $00EE, $0000
;-------------------------------------------------------------------------------
even