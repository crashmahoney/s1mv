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

Level_Select_MapScreenMenu_snd   = $0081
Emerald_Snd2             = $0093
Ring_Snd                = $00B5
Volume_Down             = $00E0
Stop_Sound              = $00E4
;-------------------------------------------------------------------------------
MapScreen_Menu:
                 tst.b   (v_levelselnofade).w     ; is don't fade flag set?
                 bne.w   @domenu                  ; if so, branch
;                move.b  #Stop_Sound, D0
;                bsr     PlaySound
;                jsr     PaletteFadeOut
                ; save the background positions for reloading on exit
                move.w	($FFFFF708).w,($FFFFFE44).w 	; bg position
		move.w	($FFFFF70C).w,($FFFFFE46).w 	; bg position
		move.w	($FFFFF710).w,($FFFFFE48).w 	; bg position
		move.w	($FFFFF714).w,($FFFFFE4A).w 	; bg position
		move.w	($FFFFF718).w,($FFFFFE4C).w 	; bg position
		move.w	($FFFFF71C).w,($FFFFFE4E).w 	; bg position

@domenu
                move    #$2700, SR
                move.w  (v_vdp_buffer1).w, D0
                andi.b  #$BF, D0
                move.w  D0, ($00C00004)
       ;         jsr     ClearScreen
       
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
		move.l	#0,(v_scrposx_dup).w
		else
		clr.l	(v_scrposy_dup).w
		clr.l	(v_scrposx_dup).w
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
                lea     (v_spritequeue).w, A1       ; clear sprite queue?
                moveq   #$00, D0                    ; |
                move.w  #$00FF, D1                  ; |
@clrspriteloop:                                   ; |
                move.l  D0, (A1)+                   ; |
                dbra    D1, @clrspriteloop        ; V
                lea     (v_16x16).w, A1             ; clear 16x16 tiles?
                moveq   #$00, D0                    ; |
                move.w  #$07FF, D1                  ; |
@clr16x16loop:                                    ; |
                move.l  D0, (A1)+                   ; |
                dbra    D1, @clr16x16loop         ; V
;                clr.w   ($FFFFDC00).w
;                move.l  #$FFFFDC00, ($FFFFDCFC).w
;                  tst.b   (v_levelselnofade).w     ; is don't fade flag set?
;                  bne.w   @fontsalreadyloaded                  ; if so, branch
                 move.l  #$42000000, ($00C00004)
                 lea     (Menu_Font), A0
                 jsr     NemDec
		locVRAM	$0E00
                lea     (Map_Tiles), A0
                jsr     NemDec
@fontsalreadyloaded
;-------------------------------------------------------------------------------
; Loads the mapping of the Fund Sonic / Miles      remove this and the background stays plain blue
;-------------------------------------------------------------------------------
                lea     (v_256x256), A1
                lea     (Menu_Mappings), A0
                move.w  #$6000, D0
                jsr     EniDec
                lea     (v_256x256), A1
                move.l  #$60000003, D0
                moveq   #$27, D1
                moveq   #$1B, D2
                jsr     TilemapToVRAM
;-------------------------------------------------------------------------------
; Load the Text Menu Selection Phase
;-------------------------------------------------------------------------------
MapScreenMenu_DrawText:
                lea     (v_256x256), A3          ; load start address of 256x256 block
                move.w  #$045F, D1               ; loop $045F (1119) times
@clr256x256loop:
                move.w  #$0000, (A3)+            ; clear address and advance to next
                dbra    D1, @clr256x256loop      ; loop back to do it again
                lea     (v_256x256), A3          ; load start address of 256x256 block
                lea     (MapScreenMenu_Level_Select_Text), A1    ; loads first item of first string to a1 (the first byte of the string defines string length)
                lea     (MapScreenMenu_Text_Positions), A5
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                move.w  #$000C, D1               ; set loop counter to 13 (the number of options)
MapScreenMenu_Loop_Load_Text:
                move.w  (A5)+, D3                ; put required text position in d3, advance a5 to next item (for next time it loops)
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position???
                moveq   #$00, D2                 ; clear d2
                move.b  (A1)+, D2                ; set d2 to length of string, advance a1 to first letter in string
                move.w  D2, D3                   ; set d3 to length of string as well
@loadtextloop1:
                move.b  (A1)+, D0                ; set d0 to letter required, advance a1 to letter for next loop around
      @drawletter:
                move.w  D0, (A2)+                ; set a2 to letter required and advance
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
                bne.s   @skipheader1              ; if so, branch
                move.w  #$0000, (A2)             ; Load " "
       @skipheader1:
                cmpi.b  #$06,d1                  ; is 'abilities' being drawn?
                bne.s   @skipheader2              ; if so, branch
                move.w  #$0000, (A2)             ; Load " "
       @skipheader2:
                cmpi.b  #$0B,d1                  ; is dividing line in column 1 being drawn?
                bne.s   @skipline1                 ; if not, branch
                move.w  #$0038, (A2)             ; Load "-"
       @skipline1:
                cmpi.b  #$05,d1                  ; is dividing line in column 2 being drawn?
                bne.s   @skipline2                 ; if not, branch
                move.w  #$0000, (A2)             ; Load "-"
       @skipline2:

;                 cmpi.b  #$0A,d1                  ; is shield being drawn
;                 bne.s   @notshield               ; if not, branch
;                 moveq   #$00,d5
;                 move.b  (v_inv_shield).w,d5      ;
;                 addi.b  #$10,d5
;                 move.w  d5,(a2)
;        @notshield:
; 
;                 cmpi.b  #$09,d1                  ; is invincibility being drawn
;                 bne.s   @notinvinc               ; if not, branch
;                 moveq   #$00,d5
;                 move.b  (v_inv_invinc).w,d5      ;
;                 addi.b  #$10,d5
;                 move.w  d5,(a2)
;        @notinvinc:
; 
;                 cmpi.b  #$08,d1                  ; is shoes being drawn
;                 bne.s   @notshoes               ; if not, branch
;                 moveq   #$00,d5
;                 move.b  (v_inv_shoes).w,d5      ;
;                 addi.b  #$10,d5
;                 move.w  d5,(a2)
;        @notshoes:
; 
;                 cmpi.b  #$07,d1                  ; is shield being drawn
;                 bne.s   @notkey               ; if not, branch
;                 moveq   #$00,d5
;                 move.b  (v_inv_key).w,d5      ;
;                 addi.b  #$10,d5
;                 move.w  d5,(a2)
       @notkey:

       @notline:
;                move.w  #$0011, (A2)             ; Load "1"
;                 lea     $0050(A2), A2            ; add $50 to text drawing position
;                 move.w  #$0012, (A2)             ; Load "2"
;                 lea     $0050(A2), A2            ; add $50 to text drawing position
;                 move.w  #$0013, (A2)             ; Load "3"
@skipnumber
                dbra    D1, MapScreenMenu_Loop_Load_Text ; if all lines drawn, continue, otherwise loop back and draw the next line
;-------------------------------------------------------------------------------                
;                 moveq   #$00, D1                 ; set loop counter to $0E (14) (number of act numbers to remove)
;                 lea     $FFFFFBA0(A2), A2        ; load position to start clearing numbers
; MapScreenMenu_Clear_Act_x:                           ; Clears the numbers of Acts not used and carries the "*" from the Sound Test
;                 move.w  #$0000, (A2)             ; Load " "
;                 lea     $0050(A2), A2            ; add $50 to text drawing position
;                 dbra    D1, MapScreenMenu_Clear_Act_x
                lea     $FFFFFF10,a2;$FFFFFF10(A2), A2
                move.w  #$001A, (A2)          ; Load "*"


;                jsr     DrawMap


;-------------------------------------------------------------------------------
; Loads the mapping of the Wings where icons are displayed
;------------------------------------------------------------------------------- 
                lea     (Wings_Mappings), A0
                lea     ($FFFF0670), A1
                move     #$06, D1
MapScreenMenu_Loop_Next_Line:
                move     #$09, D0
MapScreenMenu_Loop_Load_Wings:
                move.w   (A0)+, (A1)+
                dbra     D0, MapScreenMenu_Loop_Load_Wings
                add.w    #$3C, A1
                dbra     D1, MapScreenMenu_Loop_Next_Line
;-------------------------------------------------------------------------------
; Loads the icon mappings
;-------------------------------------------------------------------------------                                    
                lea     ($FFFF08C0), A1
                lea     (Icons_Mappings), A0
                move.w  #$0090, D0
                jsr     EniDec
                lea     (v_256x256), A1
                move.l  #$40000003, D0
                moveq   #$27, D1
                moveq   #$1B, D2
                jsr     TilemapToVRAM             ; write the whole shebang to the screen
;-------------------------------------------------------------------------------
                moveq   #$00, D3
                bsr     MapScreenMenu_SndTst           ; at the moment this is jumping to the code in s2_menu.asm, cos i haven't finished converting the stuff at the bottom of this file :)
                clr.w   ($FFFFFF70).w
                clr.w   ($FFFFFE40).w
                clr.b   ($FFFFF711).w
                clr.w   ($FFFFF7F0).w
;-------------------------------------------------------------------------------
	        clr.l	($FFFFF7B8).w		; clear RAM adresses $F7B8 to $F7BA  +++ replaced the 2 lines below, caused a crash, can't change a word at an odd ram address
       ;        move.w  #$0000, (v_lani4_frame).w  ; Initializes the frames of the animations menu
       ;        move.w  #$0000, (v_lani4_time).w  ; Initializes the counter of the animations menu
                jsr     Dynamic_Menu           ; Calls the animation routine
;-------------------------------------------------------------------------------

                 moveq   #palid_Menu_Palette, D0
                 jsr     PalLoad1
                lea     ($FFFFFB40).w, A1
                lea     ($FFFFFBC0).w, A2
                moveq   #$07, D1
@loop:
                move.l  (A1), (A2)+
                clr.l   (A1)+
                dbra    D1, @loop
;                 move.b  #bgm_LevelSelect, D0
;                 jsr     PlaySound
;                 moveq   #$00, D0
;                 jsr     NewPLC
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
                jsr     DrawMap          ; draw the descriiption
                tst.b   (v_levelselnofade).w          ; if flag is set
                bne.s   MapScreenMenu_Main_Loop           ; skip fading in
                jsr     PaletteFadeIn
MapScreenMenu_Main_Loop:
                move.b  #$01,(v_levelselnofade).w     ; don't fade in again
                move.b  #$01,(f_inmenu).w             ; set in menu flag
;                move.b  #$00,(v_levelselnofade).w     ; clear flag
                move.b  #$18, (v_vbla_routine).w
                jsr     WaitForVBla
                move    #$2700, SR
                moveq   #$00, D3
;                bsr     HighlightItem
                bsr     mapchkdpad
                move.w  #$6000, D3
;                bsr     MapScreenMenu_Highlight
                move    #$2300, SR
                jsr     Dynamic_Menu
                jsr     RunPLC
;                 btst    #$04, (v_jpadhold1).w         ; is B button held?
;                 beq.s   @bnotpressed                  ; if not, branch
;                 move.w  #$0001, ($FFFFFFD8).w
; @bnotpressed:
                move.b  (v_jpadpress1).w, D0          ;
;                 or.b    ($FFFFF607).w, D0             ; i think this
;                 andi.b  #$80, D0                      ; means 'is start pressed?'
		andi.b	#btnStart,d0	; is start pressed?
                bne.s   @startpressed
                move.b	(v_jpadpress1).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		bne.w	@abcpressed	; if so, branch
                bra     MapScreenMenu_Main_Loop
@startpressed:
                tst.b   (f_inmenu).w
                bne.w   ExitPauseMenu
                rts
;                 move.b  #1,(f_leavemenu).w
;                 move.w  (v_levselitem).w, D0           ; selcted item to d0
;                 add.w   D0, D0                         ; double the amount
;                 move.w  MapScreenMenu_Level_Select_Array(PC, D0), D0      ; refer to array below
;                 bmi     MapScreenMenu_Game_Reset          ; if below 0, branch
;                 cmpi.w  #$0600, D0                    ; if $0600
;                 beq     MapScreenMenu_Ending_Sequence     ; go to ending
;                 cmpi.w  #$5555, D0
;                 beq     MapScreenMenu_Main_Loop
;                 cmpi.w  #$4000, D0                    ; is special stage selected?
;                 bne     MapScreenMenu_Load_Level          ; if not, load level
;                 move.b  #$10, (v_gamemode).w         ; go to special stage code below
;                 clr.w   (v_zone).w
;                 move.b  #$03, (v_lives).w
;                 move.b  #$03, (v_ani3_time).w
;                 moveq   #$00, D0
;                 move.w  D0, (v_rings).w
;                 move.l  D0, (v_time).w
;                 move.l  D0, (v_score).w
;                 move.w  D0, ($FFFFFED0).w
;                 move.l  D0, ($FFFFFED2).w
;                 move.l  D0, ($FFFFFED6).w
;                 move.l  #$00001388, (v_scorelife).w
;                 move.l  #$00001388, ($FFFFFFC4).w
;                 move.w  ($FFFFFF72).w, ($FFFFFF70).w
;                 rts
; MapScreenMenu_Game_Reset:
;                 move.b  #$0000, (v_gamemode).w
;                 rts
; MapScreenMenu_Ending_Sequence:
;                 move.b	#$0018,(v_gamemode).w
; 		move.w	#$0600,(v_zone).w
; 		rts

@abcpressed:
                cmpi.w  #$0002,(v_levselitem).w  ; is shield selected?
                bne.s   @notshield               ; if not, branch
                tst.b   (v_inv_shield).w         ; any shields in inventory?
                beq.s   @notshield               ; if not, branch
                subi.b  #$01,(v_inv_shield).w    ; subtract 1 from inventory
		move.b	#1,(v_shield).w	; give Sonic a shield
		move.b	#id_InvincibilityStars,(v_objspace+$180).w ; load shield object ($38)
		music	sfx_Shield,1	; play shield sound
		bsr.w   MapScreenMenu_DrawText
        @notshield:
                cmpi.w  #$0003,(v_levselitem).w  ; is invinc selected?
                bne.s   @notinvinc                 ; if not, branch
                tst.b   (v_inv_invinc).w         ; any invinc in inventory?
                beq.s   @notinvinc               ; if not, branch
                subi.b  #$01,(v_inv_invinc).w    ; subtract 1 from inventory
		move.b	#1,(v_invinc).w	; make Sonic invincible
		move.w	#$4B0,(v_player+$32).w ; time limit for the power-up
		move.b	#id_InvincibilityStars,(v_objspace+$200).w ; load stars object ($3801)
		move.b	#1,(v_objspace+$200+obAnim).w
		move.b	#id_InvincibilityStars,(v_objspace+$240).w ; load stars object ($3802)
		move.b	#2,(v_objspace+$240+obAnim).w
		move.b	#id_InvincibilityStars,(v_objspace+$280).w ; load stars object ($3803)
		move.b	#3,(v_objspace+$280+obAnim).w
		move.b	#id_InvincibilityStars,(v_objspace+$2C0).w ; load stars object ($3804)
		move.b	#4,(v_objspace+$2C0+obAnim).w
		tst.b	(f_lockscreen).w ; is boss mode on?
		bne.s	@Pow_NoMusic	; if yes, branch
		if Revision=0
		else
			cmpi.w	#$C,(v_air).w
			bls.s	@Pow_NoMusic
		endc
		music	bgm_Invincible,1 ; play invincibility music
		bsr.w   MapScreenMenu_Main_Loop  
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
		move.b	#1,(v_shoes).w	; speed up the BG music
		move.w	#$4B0,(v_player+$34).w	; time limit for the power-up
                jsr     SetStatEffects
; 		move.w	#$C00,(v_sonspeedmax).w ; change Sonic's top speed
; 		move.w	#$18,(v_sonspeedacc).w	; change Sonic's acceleration
; 		move.w	#$80,(v_sonspeeddec).w	; change Sonic's deceleration
		music	$E2,1		; Speed	up the music
        @notshoes:
                cmpi.w  #$0005,(v_levselitem).w  ; is keys selected?
                bne.s   @notkeys                 ; if not, branch
                nop
        @notkeys:
                rts
MapScreenMenu_Level_Select_Array:
                dc.w    $0000, $0000, $0002        ; 'use items', divider, shield
                dc.w    $0200, $0201, $0202        ; marble
                dc.w    $0400, $0401, $0402        ; spring yard
                dc.w    $0100, $0101, $0102        ; labyrinth
                dc.w    $0300, $0301, $0302        ; star light
                dc.w    $0500, $0501, $0103        ; scrap brain
                dc.w    $0502, $4000, $0600        ; final, special stage, ending
                dc.w    $FFFF                      ; sound test?
MapScreenMenu_Load_Level:
; the code in here always gets run after the code above
                jsr     MapScreenMenu_DrawText         ; redraws the menu
                jsr     DrawMap
;               rts                                ; uncomment??? quits and reloads the menu
mapchkdpad:
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
;                 jsr     MapScreenMenu_DrawText
                jsr     DrawMap
                rts
@SndTstSelected:
                cmpi.w  #$000C, (v_levselitem).w   ; is sound test selected?
                bne.s   @NotSndTst                 ; if not, branch
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
                move.w  D0, (v_levselsound).w      ; set sount test item
                andi.w  #$0030, D1                 ; are B or C pressed?
                beq.s   @donothing                 ; if not, branch
                move.w  (v_levselsound).w, D0
                addi.w  #$0080, D0                 ; choose actual sound offset
;                jsr     PlaySound_Unused                  ; start playing music
		move.b	#$80,(f_stopmusic).w       ; let music play (in case it was stopped from pausing)
                lea     (Code_Debug_Mode), A0
                lea     (Code_All_Emeralds), A2
                lea     ($FFFFFF0A).w, A1
                moveq   #$01, D2
                bsr     MapScreenMenu_Code_Test 
@donothing:
                rts
@NotSndTst:
                move.b  (v_jpadpress1).w, D1
                andi.b  #$0C, D1                  ; are dpad left or right pressed?
                beq.s   @donothing2               ; if not, branch
                move.w  (v_levselitem).w, D0
                move.b  MapScreenMenu_Left_Right_Select(PC, D0), D0
                move.w  D0, (v_levselitem).w
                jsr     DrawMap
@donothing2:
                rts

MapScreenMenu_Left_Right_Select:
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

; map_highlightitem:  ; the first section of this seems to set unselected text back to white  actually no it does the opposite i think???
;                 lea     (v_256x256), A4           ; load start address of 256x256 block to a4
;                 lea     (MapScreenMenu_Text_Highlight), A5     ; load start of highlight array to a5
;                 lea     ($00C00000), A6           ; load start of vdp ram (vram?) to a6                                                 d0
;                 moveq   #$00, D0                  ; clear d0                                                                       $0000 0000
;                 move.w  (v_levselitem).w, D0      ; set d0 to the number of the selected item                       let's say item $0000 0001
;                 lsl.w   #$02, D0                  ; multiply d0 by 4                                                gives us       $0000 0004            each selection has 2 words, or 4 bytes!!!
;                 lea     $00(A5, D0), A3           ; load address from start of highlight array plus d0 to a3                           ($0306)
;                 moveq   #$00, D0                  ; clear d0                                                                       $0000 0000
;                 move.b  (A3), D0                  ; set d0 to first byte of what was picked from highlight array                   $0000 0003
;                 mulu.w  #$0050, D0                ; multiply by $0050                                                              $0000 00F0
;                 moveq   #$00, D1                  ; clear d1
;                 move.b  $0001(A3), D1             ; moves contents of a3 plus 1 byte to d1
;                 add.w   D1, D0                    ; adds d1 to d0                                                                  $0000 00F6
;                 lea     $00(A4, D0), A1           ; load 256x256 address plus what's in d0                                                           $FFFF00F6
;                 moveq   #$00, D1                  ; clear d1                                                                            d1
;                 move.b  (A3), D1                  ; move first byte of a3 to d1                                                    $0000 0003
;                 lsl.w   #$07, D1                  ; multiply d1 by 80? too much for a word, gets cut off                           $0000 0180
;                 add.b   $0001(A3), D1             ; add contents of a3 plus 1 byte to d1                                           $0000 0186
;                 addi.w  #$C000, D1                ; add $C000 to d1                                                                $0000 C186            I HAVE NO IDEA
;                 lsl.l   #$02, D1                  ;                                                                                $0003 0618            IF ANY OF THIS
;                 lsr.w   #$02, D1                  ;                                                                                $0003 0186            IS EVEN CLOSE TO
;                 ori.w   #$4000, D1                ;                                                                                $0003 4186            BEING RIGHT!!!!!
;                 swap.w  D1                        ;                                                                                $4186 0003
;                 move.l  D1, $0004(A6)             ; moves d1 to $00C00004 (vram where graphics are sent to i think)
;                 moveq   #$0E, D2    ; Number of letters to select (Highlight) $0E
; @HighlightLoop:
;                 move.w  (A1)+, D0                 ;
;                 add.w   D3, D0
;                 move.w  D0, (A6)                  ; colour the letter yellow
;                 dbra    D2, @HighlightLoop        ; loop back if not finished
;                 addq.w  #$02, A3
;                 moveq   #$00, D0
;                 move.b  (A3), D0
;                 beq.s   @skip
;                 mulu.w  #$0050, D0                ; this code is the same as above
;                 moveq   #$00, D1
;                 move.b  $0001(A3), D1
;                 add.w   D1, D0
;                 lea     $00(A4, D0), A1
;                 moveq   #$00, D1
;                 move.b  (A3), D1
;                 lsl.w   #$07, D1
;                 add.b   $0001(A3), D1
;                 addi.w  #$C000, D1
;                 lsl.l   #$02, D1
;                 lsr.w   #$02, D1
;                 ori.w   #$4000, D1
;                 swap.w  D1
;                 move.l  D1, $0004(A6)             ; moves d1 to vram, (chooses where to draw ???)
;                 move.w  (A1)+, D0
;                 add.w   D3, D0
;                 move.w  D0, (A6)                  ;
; @skip:
;                 cmpi.w  #$000C, (v_levselitem).w  ; Is Sound Test selected?
;                 bne.s   @donothing           ; if not, branch
;                 bsr     map_SndTstselected2
; @donothing:
;                  rts
; map_SndTstselected2:
;                 move.l  #$49C60003, ($00C00004) ; Position of numbers from the Sound Test
;                 move.w  (v_levselsound).w, D0
;                 move.b  D0, D2
;                 lsr.b   #$04, D0
;                 bsr.s   map_SndTstselected3
;                 move.b  D2, D0
; map_SndTstselected3:
;                 andi.w  #$000F, D0
;                 cmpi.b  #$0A, D0
;                 bcs.s   map_SndTstselected4
;                 addi.b  #$04, D0
; map_SndTstselected4:
;                 addi.b  #$10, D0
;                 add.w   D3, D0
;                 move.w  D0, (A6)
;                 rts
;-------------------------------------------------------------------------------
MapScreenMenu_Code_Test:
;                 move.w  ($FFFFFF0C).w, D0
;                 adda.w  D0, A0
;                 move.w  (v_levselsound).w, D0
;                 cmp.b   (A0), D0
;                 bne.s   MapScreenMenu_Reset_Debug_Mode_Code_Counter
;                 addq.w  #$01, ($FFFFFF0C).w
;                 tst.b   $0001(A0)
;                 bpl.s   MapScreenMenu_All_Emeralds_Code_Test 
;                 move.w  #$0101, (A1)
;                 bra     MapScreenMenu_Set_Debug_Flag 
; MapScreenMenu_Reset_Debug_Mode_Code_Counter: 
;                 move.w  #$0000, ($FFFFFF0C).w
; MapScreenMenu_All_Emeralds_Code_Test: 
;                 move.w  ($FFFFFF0E).w, D0
;                 adda.w  D0, A2
;                 move.w  (v_levselsound).w, D0
;                 cmp.b   (A2), D0
;                 bne.s   MapScreenMenu_Reset_All_Emerald_Code_Counter 
;                 addq.w  #$01, ($FFFFFF0E).w
;                 tst.b   $0001(A2)
;                 bpl.s   MapScreenMenu_Code_Not_0xFF 
;                 tst.w   D2
;                 bne.s   MapScreenMenu_Set_All_Emeralds 
; MapScreenMenu_Set_Debug_Flag: 
;                 move.b  #$01, (Slow_Motion_Flag).w
;                 move.b  #$01, (Debug_Mode_Flag).w
;                 move.b  #Ring_Snd, D0
;                 jsr     PlaySound
;                 bra.s   MapScreenMenu_Reset_All_Emerald_Code_Counter 
; MapScreenMenu_Set_All_Emeralds: 
;                 move.w  #$0006, ($FFFFFE56).w
;                 move.b  #Emerald_Snd2, D0
;                 jsr     PlaySound
; MapScreenMenu_Reset_All_Emerald_Code_Counter: 
;                 move.w  #$0000, ($FFFFFF0E).w
; MapScreenMenu_Code_Not_0xFF: 
;                 rts               
;-------------------------------------------------------------------------------
MapScreenMenu_SndTst:
;                bsr     map_SndTstselected2
;                bsr     DrawMap
                bra     MapScreenMenu_Icons
MapScreenMenu_Highlight:
;                bsr     map_highlightitem
;                bsr     DrawMap
                bra     MapScreenMenu_Icons
MapScreenMenu_Icons:
                move.w  (v_levselitem).w, D0
                lea     (MapScreenMenu_Icon_List), A3
                lea     $00(A3, D0), A3
                lea     ($FFFF08C0), A1
                moveq   #$00, D0
                move.b  (A3), D0
                lsl.w   #$03, D0
                move.w  D0, D1
                add.w   D0, D0
                add.w   D1, D0
                lea     $00(A1, D0), A1
                move.l  #$4B360003, D0        ; Horizontal Icons
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
; MapScreenMenu_Loop_Load_Tiles:
;                 move.l  (A1)+, (A6)
;                 move.l  (A1)+, (A6)     
;                 move.l  (A1)+, (A6)     
;                 move.l  (A1)+, (A6)     
;                 move.l  (A1)+, (A6)     
;                 move.l  (A1)+, (A6)
;                 move.l  (A1)+, (A6)
;                 move.l  (A1)+, (A6)
;                 dbra    D0, MapScreenMenu_Loop_Load_Tiles
; Exit_Dinamic_Menu:                
;                 rts              
; Sonic_Miles_Frame_Select:     
;                 dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;                 dc.b    $05, $0A
;                 dc.b    $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
;                 dc.b    $0A, $05   
;                 ; 0 = 0000000000  ; 1 = 0101000000  ; 2 = 1010000000 ; 3 = 1111000000
; ;------------------------------------------------------------------------------                  
; Map Tile defenitions
MapScreenMenu_Icon_List:
                dc.b    $00  ; 'use items'
                dc.b    $00  ; dividing line
                dc.b    $00  ; shield
                dc.b    $06  ; invincibility
                dc.b    $06  ; speed shoes
                dc.b    $06  ; keys
                dc.b    $0B  ; 'abilites'
                dc.b    $0B  ; dividing line
                dc.b    $0B  ; spin dash
                dc.b    $0E  ; air hop
                dc.b    $0E  ; jump dash
                dc.b    $11  ; sound test
;-------------------------------------------------------------------------------
MapScreenMenu_Text_Highlight:            ; in pairs of 2, i think. first is the text to highlight, second is the number
                dc.w    $0306, $0324  ; 'use items'                                  ; as for the numbers themselves,
                dc.w    $0406, $0424  ; dividing line                                ; the first byte is how many rows from the top it is,
                dc.w    $0506, $0524  ; shield                                       ; the second is the horizontal rows times 2 for some reason
                dc.w    $0606, $0624  ; invincibility
                dc.w    $0706, $0724  ; speed shoes
                dc.w    $0806, $0824  ; keys
                

;                 dc.w    $0706, $0824, $0706, $0924, $0B06, $0B24, $0B06, $0C24
;                 dc.w    $0B06, $0D24, $0F06, $0F24, $0F06, $1024, $0F06, $1124
;                 dc.w    $1306, $1324, $1306, $1424, $1306, $1524,

                dc.w    $032C, $034A   ; 'abilities'
                dc.w    $042C, $044A   ; dividing line
                dc.w    $052C, $054A   ; spin dash
                dc.w    $062C, $064A   ; air hop
                dc.w    $072C, $074A   ; jump dash
                dc.w    $082C, $084A   ; goggles
                dc.w    $132C, $134A   ; sound test
;-------------------------------------------------------------------------------
MapScreenMenu_Text_Positions:   ; I think these numbers are how many 8x8 tiles before drawing each option
                dc.w    $00F6          ; 'use items'                  $0000               $000C
                dc.w    $0146          ; dividing line                $0001               $000B
                dc.w    $0196          ; shield                       $0002               $000A
                dc.w    $01E6          ; invincibility                $0003               $0009
                dc.w    $0236          ; speed shoes                  $0004               $0008
                dc.w    $0286          ; keys                         $0005               $0007

                dc.w    $011C          ; 'abilities'                  $0006               $0006
                dc.w    $016C          ; dividing line                $0007               $0005
                dc.w    $01BC          ; spin dash                    $0008               $0004
                dc.w    $020C          ; air hop                      $0009               $0003
                dc.w    $025C          ; jump dash                    $000A               $0002
                dc.w    $02AC          ; goggles                      $000B               $0001

                dc.w    $061C          ; sound test                   $000C               $0000
;-------------------------------------------------------------------------------                          
MapScreenMenu_Level_Select_Text:
                dc.b    $0E, _M, _A, _P, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
                even
; ;-------------------------------------------------------------------------------
;=================================================================================
DrawMap:

DrawGHZ1:
                lea     (v_256x256), A3;($FFFF05F6), A3          ; load start address of 256x256 block
                lea     (GHZ1_Description), A1   ; loads first item of first string to a1 (the first byte of the string defines string length)
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                moveq   #$00, D4                 ; clear d4 (position to start drawing)
                move.w  #$0001, D1               ; set loop counter to 2 (the number of options)
                move.w  #$01E6, D4               ; put required text position in d4
@drawrow
                lea     $00(A3, D4), A2          ; sets a2 to address of requred text position???
                moveq   #$00, D2                 ; clear d2 (length of string)
                move.b  (A1)+, D2                ; set d2 to length of string, advance a1 to first letter in string
                move.w  D2, D3                   ; set d3 to length of string as well
@drawtile:
                move.b  (A1)+, D0                ; set d0 to letter required, advance a1 to letter for next loop around
                move.w  D0, (A2)+                ; set a2 to letter required and advance
                dbra    D2, @drawtile            ; if d2 is over 0 loop back and draw next letter
                move.w  #$0004, D2               ; set d2 to 4
                sub.w   D3, D2                   ; sub d3(string length from before (should be 14)) from d2(13)
                add.w   #$0050,d4                ; move drawing position to next line
                dbra    D1, @drawrow             ; if all lines drawn, continue, otherwise loop back and draw the next line
;------------------------------------------------------------------------------------------------------------------------------------------------
DrawGHZ2:
                lea     (v_256x256), A3;($FFFF05F6), A3          ; load start address of 256x256 block
                lea     (GHZ2_Description), A1   ; loads first item of first string to a1 (the first byte of the string defines string length)
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                moveq   #$00, D4                 ; clear d4 (position to start drawing)
                move.w  #$0001, D1               ; set loop counter to 2 (the number of options)
                move.w  #$0286, D4               ; put required text position in d4
@drawrow
                lea     $00(A3, D4), A2          ; sets a2 to address of requred text position???
                moveq   #$00, D2                 ; clear d2 (length of string)
                move.b  (A1)+, D2                ; set d2 to length of string, advance a1 to first letter in string
                move.w  D2, D3                   ; set d3 to length of string as well
@drawtile:
                move.b  (A1)+, D0                ; set d0 to letter required, advance a1 to letter for next loop around
                move.w  D0, (A2)+                ; set a2 to letter required and advance
                dbra    D2, @drawtile            ; if d2 is over 0 loop back and draw next letter
                move.w  #$0004, D2               ; set d2 to 4
                sub.w   D3, D2                   ; sub d3(string length from before (should be 14)) from d2(13)
                add.w   #$0050,d4                ; move drawing position to next line
                dbra    D1, @drawrow             ; if all lines drawn, continue, otherwise loop back and draw the next line
;------------------------------------------------------------------------------------------------------------------------------------------------
DrawGHZ3:
                lea     (v_256x256), A3;($FFFF05F6), A3          ; load start address of 256x256 block
                lea     (GHZ3_Description), A1   ; loads first item of first string to a1 (the first byte of the string defines string length)
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                moveq   #$00, D4                 ; clear d4 (position to start drawing)
                move.w  #$0001, D1               ; set loop counter to 2 (the number of options)
                move.w  #$0294, D4               ; put required text position in d4
@drawrow
                lea     $00(A3, D4), A2          ; sets a2 to address of requred text position???
                moveq   #$00, D2                 ; clear d2 (length of string)
                move.b  (A1)+, D2                ; set d2 to length of string, advance a1 to first letter in string
                move.w  D2, D3                   ; set d3 to length of string as well
@drawtile:
                move.b  (A1)+, D0                ; set d0 to letter required, advance a1 to letter for next loop around
                move.w  D0, (A2)+                ; set a2 to letter required and advance
                dbra    D2, @drawtile            ; if d2 is over 0 loop back and draw next letter
                move.w  #$0004, D2               ; set d2 to 4
                sub.w   D3, D2                   ; sub d3(string length from before (should be 14)) from d2(13)
                add.w   #$0050,d4                ; move drawing position to next line
                dbra    D1, @drawrow             ; if all lines drawn, continue, otherwise loop back and draw the next line
;------------------------------------------------------------------------------------------------------------------------------------------------
DrawMZ3:
                lea     (v_256x256), A3;($FFFF05F6), A3          ; load start address of 256x256 block
                lea     (MZ1_Description), A1   ; loads first item of first string to a1 (the first byte of the string defines string length)
                moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
                moveq   #$00, D4                 ; clear d4 (position to start drawing)
                move.w  #$0002, D1               ; set loop counter to 3 (the number of options)
                move.w  #$02A6, D4               ; put required text position in d4
@drawrow
                lea     $00(A3, D4), A2          ; sets a2 to address of requred text position???
                moveq   #$00, D2                 ; clear d2 (length of string)
                move.b  (A1)+, D2                ; set d2 to length of string, advance a1 to first letter in string
                move.w  D2, D3                   ; set d3 to length of string as well
@drawtile:
                move.b  (A1)+, D0                ; set d0 to letter required, advance a1 to letter for next loop around
                move.w  D0, (A2)+                ; set a2 to letter required and advance
                dbra    D2, @drawtile            ; if d2 is over 0 loop back and draw next letter
                move.w  #$0004, D2               ; set d2 to 4
                sub.w   D3, D2                   ; sub d3(string length from before (should be 14)) from d2(13)
                add.w   #$0050,d4                ; move drawing position to next line
                dbra    D1, @drawrow             ; if all lines drawn, continue, otherwise loop back and draw the next line

                lea     (v_256x256), A1
                move.l  #$40000003, D0
                moveq   #$27, D1
                moveq   #$1B, D2
                jsr     TilemapToVRAM             ; write the whole shebang to the screen

                rts

; ========================================================================================================================
; Description_Text_Positions:   ; I think these numbers are how many 8x8 tiles before drawing each option
;                 dc.w    $05F6          ; 'description'                $0000               $0006
;                 dc.w    $0646          ; dividing line                $0001               $0005
;                 dc.w    $0696          ; line1                        $0002               $0004
;                 dc.w    $06E6          ; line2                        $0003               $0003
;                 dc.w    $0736          ; line3                        $0004               $0002
;                 dc.w    $0786          ; line5                        $0005               $0001
;                 dc.w    $07D6          ; line6                        $0006               $0000
____  = $00    ;         blank tile

_tlc = $80     ;         top left closed
_tlo = $83     ;         top left, top open
_tl0 = $86     ;         top left, side open

_toc = $81     ;         top closed
_too = $84     ;         top open

_trc = $82     ;         top right closed
_tro = $85     ;         top right, top open
_tr0 = $87     ;         top right, side open

_lec = $78     ;  |      left closed
_leo = $7B     ;  :      left open

_cen = $79     ;         centre tile

_ric = $7A     ;    |    right closed
_rio = $7D     ;    :    right open

_blc = $70     ;  |_     bottom left closed
_blo = $73     ;  |_ _   bottom left, bottom open
_bl0 = $7E     ;  :_     bottom left, side open

_boc = $71     ;  _      bottom closed
_boo = $74     ;  _ _    bottom open

_brc = $72     ;  _|     bottom right closed
_bro = $75     ;  _ _|   bottom right, bottom open
_br0 = $7F     ;  _:     bottom right, side open

_ver = $76     ; []      vertical open
_hor = $77     ; =       horizontal open

GHZ1_Description:
                dc.b    $06, _tlc, _toc, _toc, _toc, _toc, _toc, _trc
                dc.b    $06, _bl0, _boc, _boo, _boc, _boc, _boc, _brc
GHZ2_Description:
                dc.b    $06, _tlc, _toc, _too, _toc, _toc, _toc, _tr0
                dc.b    $06, _blc, _boc, _boc, _boc, _boc, _boc, _brc
GHZ3_Description:
                dc.b    $08, _tl0, _toc, _toc, _toc, _toc, _toc, _toc, _toc, _trc
                dc.b    $08, _blc, _boc, _boc, _boc, _boc, _boc, _brc, ____, ____
MZ1_Description:
                dc.b    $05, _bl0, _boc, _too, _toc, _boc, _br0
                dc.b    $05, ____, ____, _leo, _ric, ____, ____
                dc.b    $05, ____, ____, _blo, _brc, ____, ____


; Invinc_Description:
;                 dc.b    $0E, _D, _E, _S, _C, _R, _I, _P, _T, _I, _O, _N, __, __, __, __
;                 dc.b    $0E, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da
;                 dc.b    $0E, _G, _R, _A, _N, _T, _S, __, _S, _O, _N, _I, _C, __, _2, _0
;                 dc.b    $0E, _S, _E, _C, _O, _N, _D, _S, __, _O, _F, __, __, __, __, __
;                 dc.b    $0E, _I, _N, _V, _I, _N, _C, _I, _B, _I, _L, _I, _T, _Y, _stop, __
;                 dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
;                 dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
; Shoes_Description:
;                 dc.b    $0E, _D, _E, _S, _C, _R, _I, _P, _T, _I, _O, _N, __, __, __, __
;                 dc.b    $0E, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da
;                 dc.b    $0E, _G, _R, _A, _N, _T, _S, __, _S, _O, _N, _I, _C, __, _2, _0
;                 dc.b    $0E, _S, _E, _C, _O, _N, _D, _S, __, _O, _F, __, __, __, __, __
;                 dc.b    $0E, _S, _U, _P, _E, _R, __, _S, _P, _E, _E, _D, _stop, __, __, __
;                 dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
;                 dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
; Keys_Description:
;                 dc.b    $0E, _D, _E, _S, _C, _R, _I, _P, _T, _I, _O, _N, __, __, __, __
;                 dc.b    $0E, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da
;                 dc.b    $0E, _W, _H, _Y, __, _D, _O, _E, _S, __, _S, _O, _N, _I, _C, __
;                 dc.b    $0E, _N, _E, _E, _D, __, _K, _E, _Y, _S, _qm, __, _W, _H, _O, __
;                 dc.b    $0E, _T, _H, _E, __, _H, _E, _L, _L, __, _K, _N, _O, _W, _S, _qm
;                 dc.b    $0E, _C, _E, _R, _T, _A, _I, _N, _L, _Y, __, _N, _O, _T, __, __
;                 dc.b    $0E, _M, _E, _stop, __, __, __, __, __, __, __, __, __, __, __, __
; NoAbility_Description:
;                 dc.b    $0E, _D, _E, _S, _C, _R, _I, _P, _T, _I, _O, _N, __, __, __, __
;                 dc.b    $0E, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da
;                 dc.b    $0E, _Y, _O, _U, __, _D, _O, __, _N, _O, _T, __, _H, _A, _V, _E
;                 dc.b    $0E, _T, _H, _I, _S, __, _A, _B, _I, _L, _I, _T, _Y, __, __, __
;                 dc.b    $0E, _Y, _E, _T, _stop, __, __, __, __, __, __, __, __, __, __, __
;                 dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
;                 dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
; Spindash_Description:
;                 dc.b    $0E, _D, _E, _S, _C, _R, _I, _P, _T, _I, _O, _N, __, __, __, __
;                 dc.b    $0E, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da
;                 dc.b    $0E, _D, _U, _C, _K, __, _A, _N, _D, __, _T, _A, _P, __, __, __
;                 dc.b    $0E, _J, _U, _M, _P, __, _T, _O, __, _R, _E, _V, __, _U, _P, _stop
;                 dc.b    $0E, _R, _E, _L, _E, _A, _S, _E, __, _T, _O, __, _T, _A, _K, _E
;                 dc.b    $0E, _O, _F, _F, _stop, __, _U, _S, _E, _F, _U, _L, __, _F, _O, _R
;                 dc.b    $0E, _B, _R, _E, _A, _K, _I, _N, _G, __, _W, _A, _L, _L, _S, _stop
; AirHop_Description:
;                 dc.b    $0E, _D, _E, _S, _C, _R, _I, _P, _T, _I, _O, _N, __, __, __, __
;                 dc.b    $0E, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da
;                 dc.b    $0E, _P, _R, _E, _S, _S, __, _A, __, _I, _N, __, __, __, __, __
;                 dc.b    $0E, _M, _I, _D, _da, _A, _I, _R, __, _T, _O, __, __, __, __, __
;                 dc.b    $0E, _P, _E, _R, _F, _O, _R, _M, __, _A, __, __, __, __, __, __
;                 dc.b    $0E, _D, _O, _U, _B, _L, _E, __, _J, _U, _M, _P, _stop, __, __, __
;                 dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
; JumpDash_Description:
;                 dc.b    $0E, _D, _E, _S, _C, _R, _I, _P, _T, _I, _O, _N, __, __, __, __
;                 dc.b    $0E, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da
;                 dc.b    $0E, _P, _O, _W, _E, _R, __, _L, _E, _V, _E, _L, __, _1, __, __
;                 dc.b    $0E, _P, _R, _E, _S, _S, __, _B, __, _I, _N, __, __, __, __, __
;                 dc.b    $0E, _M, _I, _D, _da, _A, _I, _R, __, _T, _O, __, __, __, __, __
;                 dc.b    $0E, _P, _E, _R, _F, _O, _R, _M, __, _A, __, __, __, __, __, __
;                 dc.b    $0E, _J, _U, _M, _P, __, _D, _A, _S, _H, _stop, __, __, __, __, __
; Goggles_Description:
;                 dc.b    $0E, _D, _E, _S, _C, _R, _I, _P, _T, _I, _O, _N, __, __, __, __
;                 dc.b    $0E, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da
;                 dc.b    $0E, _B, _R, _E, _A, _T, _H, _E, __, __, __, __, __, __, __, __
;                 dc.b    $0E, _U, _N, _D, _E, _R, _W, _A, _T, _E, _R, __, __, __, __, __
;                 dc.b    $0E, _I, _N, _D, _E, _F, _I, _N, _I, _T, _L, _Y, _stop, __, __, __
;                 dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
;                 dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
; SoundTest_Description:
;                 dc.b    $0E, _D, _E, _S, _C, _R, _I, _P, _T, _I, _O, _N, __, __, __, __
;                 dc.b    $0E, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da, _da
;                 dc.b    $0E, _T, _E, _S, _T, __, _T, _H, _E, __, __, __, __, __, __, __
;                 dc.b    $0E, _S, _O, _U, _N, _D, _S,_com, __, _D, _U, _H, __, __, __, __
;                 dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
;                 dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __
;                 dc.b    $0E, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __

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
                  even
Map_Tiles         incbin  'data\map screen\maptiles.bin'
                  even
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

