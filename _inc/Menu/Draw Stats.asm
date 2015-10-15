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
                move.w  #FontLocation+" ", (A2)  ; Load " "
       @skipheader1:
                cmpi.b  #$03,d1                  ; is dividing line in being drawn?
                bne.s   @skipline1               ; if not, branch
                move.w  #FontLocation+"=", (A2)  ; Load "-"
       @skipline1:

                cmpi.b  #$02,d1                  ; is speed being drawn
                bne.s   @notspeed                ; if not, branch
                move.w  #FontLocation+$30, (A2)             ; draw "0"
                sub.w   #$04,a2                  ; move drawing position back to draw 100s column
		moveq	#0,d5
		move.b	(v_statspeed).w,d5	         ; load stat
		lea	(Hud_100).l,a6
		moveq	#2,d6                    ; number of digits (ie. 3)
                bsr.w   DrawDecimal
       @notspeed:

                cmpi.b  #$01,d1                  ; is accel being drawn
                bne.s   @notaccel                ; if not, branch
                move.w  #FontLocation+$30, (A2)             ; draw "0"
                sub.w   #$04,a2                  ; move drawing position back to draw 100s column
		moveq	#0,d5
		move.b	(v_stataccel).w,d5	         ; load stat
		lea	(Hud_100).l,a6
		moveq	#2,d6                    ; number of digits (ie. 3)
                bsr.w   DrawDecimal
       @notaccel:

                cmpi.b  #$00,d1                  ; is accel being drawn
                bne.s   @notjump                ; if not, branch
                move.w  #FontLocation+$30, (A2)             ; draw "0"
                sub.w   #$04,a2                  ; move drawing position back to draw 100s column
		moveq	#0,d5
		move.b	(v_statjump).w,d5	         ; load stat
		lea	(Hud_100).l,a6
		moveq	#2,d6                    ; number of digits (ie. 3)
                bsr.w   DrawDecimal
       @notjump:

                dbra    D1, Stats_Loop_Load_Text ; if all lines drawn, continue, otherwise loop back and draw the next line
                rts
                even
; ===========================================================================