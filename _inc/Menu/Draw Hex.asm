DrawHex:
       ; draw hex number onto screen
       ; input  d0 = number to draw
       ;        a2 = position to draw
                moveq   #0,d5
                move.b  d0,d5
                and.b   #%00001111,d5
                cmpi.b  #$9,d5                   ; need to display hex on loweset byte (ie. over 9)?
                ble.s   @underA                  ; if not, branch
                addi.w  #$7,d5                   ; add to font offset
       @underA:
                addi.w  #FontLocation+$30,d5
                move.w  d5,(a2)                  ; draw first digit
                moveq   #0,d5
                move.b  d0,d5                    ; get original number back
                lsr.w   #4,d5                    ; choose second digit
                cmpi.b  #$9,d5                   ; need to display hex on loweset byte (ie. over 9)?
                ble.s   @underA2                 ; if not, branch
                addi.w  #$7,d5                   ; add to font offset
       @underA2:
                addi.w  #FontLocation+$30,d5
                move.w  d5,-(a2)
		rts	
                even
; ===========================================================================
