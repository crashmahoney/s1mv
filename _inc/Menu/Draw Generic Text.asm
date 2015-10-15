;========================================================================================================================
; Draw Generic Menu text    (top menu, description, whatever doesn't need special code)
;
;      input:
;                   d1 - number of lines to draw
;                   a1 - text to draw
;                   a3 - start of temp screen ram
;                   a5 - posiotion to draw text to
;
;========================================================================================================================

DrawBasicMenuText:
                move.w  (a5)+,d3                 ; put required text position in d3, advance a5 to next item (for next time it loops)
                lea     (a3,d3),a2               ; sets a2 to address of requred text position
                moveq   #0,d2                    ; clear d2
                move.b  (a1)+,d2                 ; set d2 to length of string, advance a1 to first letter in string
@loadtextloop1:
                moveq   #0,d0                    ; clear d0 (normally stores the letter to draw, i think)
                move.b  (a1)+,d0                 ; set d0 to letter required, advance a1 to letter for next loop around
                add.w   #FontLocation+$2000,d0         ; add vram offset
                move.w  d0,(a2)+                 ; set a2 to letter required and advance
                dbf     d2,@loadtextloop1        ; if d2 is over 0 loop back and draw next letter
                dbf     d1,DrawBasicMenuText     ; if all lines drawn, continue, otherwise loop back and draw the next line
                rts

