DrawBacker:
; pass values: d3 - start location, d2 - width, d1 - height
                lea     (v_menufg), A3     ; load start address of 256x256 block
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position
                move.w  D2, D4                   ; set d4 to length of string as well, so we can reset d2 later
; =========================================================================
      @drawtopleft:
                adda.w  #2,a2                    ; first tile is blank
                move.w  #FontLocation+$20+$3D,(a2)+ ; set a2 to top left corner and advance
                move.w  #FontLocation+$20+$3E,(a2)+ ; set a2 to top left corner and advance
                sub.w   #3,d2                    ; sub 1 from width counter
      @drawtopline:
                cmpi.w  #1,d2                    ; are we down to the last one
                beq.s   @drawtopright            ; if so, branch
                move.w  #FontLocation+$20+$3F,(a2)+ ; set a2 to top and advance
                subq.w  #1,d2                    ; sub 1 from width counter
                bra.s   @drawtopline             ; loop
      @drawtopright:
                move.w  #FontLocation+$20+$40,(a2)+ ; set a2 to top right corner and advance
                sub.w   #1,d1                    ; sub 1 from height counter
; =========================================================================
      @drawtopleft2:
                move.w  d4, d2                   ; reset width counter
                add.w   #$0050,d3                  ; set draw position to next line
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position

                move.w  #FontLocation+$20+$3D,(a2)+ ; set a2 to top left corner and advance
                move.w  #FontLocation+$20+$41,(a2)+ ; set a2 to top left corner and advance
                move.w  #FontLocation+$20+$42,(a2)+ ; set a2 to top left corner and advance
                sub.w   #3,d2                    ; sub 1 from width counter
      @drawtopline2:
                cmpi.w  #1,d2                    ; are we down to the last one
                beq.s   @drawtopright2            ; if so, branch
                move.w  #FontLocation+$20+$0,(a2)+ ; set a2 to top and advance
                subq.w  #1,d2                    ; sub 1 from width counter
                bra.s   @drawtopline2             ; loop
      @drawtopright2:
                move.w  #FontLocation+$20+$43,(a2)+ ; set a2 to top right corner and advance
                sub.w   #1,d1                    ; sub 1 from height counter
; =========================================================================
      @drawtopleft3:
                move.w  d4, d2                   ; reset width counter
                add.w   #$0050,d3                  ; set draw position to next line
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position

                move.w  #FontLocation+$20+$44,(a2)+ ; set a2 to top left corner and advance
                move.w  #FontLocation+$20+$42,(a2)+ ; set a2 to top left corner and advance
                sub.w   #2,d2                    ; sub 1 from width counter
      @drawtopline3:
                cmpi.w  #1,d2                    ; are we down to the last one
                beq.s   @drawtopright3            ; if so, branch
                move.w  #FontLocation+$20+$0,(a2)+ ; set a2 to top and advance
                subq.w  #1,d2                    ; sub 1 from width counter
                bra.s   @drawtopline3             ; loop
      @drawtopright3:
                move.w  #FontLocation+$20+$43,(a2)+ ; set a2 to top right corner and advance
                sub.w   #1,d1                    ; sub 1 from height counter
; =========================================================================

      @drawsideleft:
                move.w  d4, d2                   ; reset width counter
                add.w   #$0050,d3                  ; set draw position to next line
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position

                move.w  #FontLocation+$20+$4F,(a2)+ ; set a2 to top left side and advance
                sub.w   #1,d2                    ; sub 1 from width counter
      @drawmiddletile:
                cmpi.w  #1,d2                    ; are we down to the last one
                beq.s   @drawsideright           ; if so, branch
                move.w  #FontLocation+$20+$0,(a2)+ ; set a2 to backing tile and advance
                sub.w   #1,d2                    ; sub 1 from width counter
                bra.s   @drawmiddletile          ; loop
      @drawsideright:
                move.w  #FontLocation+$20+$50,(a2)+ ; set a2 to top right side and advance
                sub.w   #1,d1                    ; sub 1 from height counter

                cmpi.b  #2,d1                    ; only 2 lines left to draw?
                beq.s   @drawbottomleft          ; if so, branch
                bra.s   @drawsideleft            ; loop
; =========================================================================
      @drawbottomleft:
                move.w  d4, d2                   ; reset width counter
                add.w   #$0050,d3                  ; set draw position to next line
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position

                move.w  #FontLocation+$20+$4F,(a2)+ ; set a2 to top left side and advance
                sub.w   #1,d2                    ; sub 1 from width counter
      @drawmiddletile2:
                cmpi.w  #2,d2                    ; are we down to the 2nd last one
                beq.s   @drawsideright2           ; if so, branch
                move.w  #FontLocation+$20+$0,(a2)+ ; set a2 to backing tile and advance
                sub.w   #1,d2                    ; sub 1 from width counter
                bra.s   @drawmiddletile2          ; loop
      @drawsideright2:
                move.w  #FontLocation+$20+$4A,(a2)+ ; set a2 to top right side and advance
                move.w  #FontLocation+$20+$4B,(a2)+ ; set a2 to top right side and advance
                sub.w   #1,d1                    ; sub 1 from height counter
; =========================================================================

      @drawbottomleft2:
                move.w  d4, d2                   ; reset width counter
                add.w   #$0050,d3                  ; set draw position to next line
                lea     $00(A3, D3), A2          ; sets a2 to address of requred text position

                move.w  #FontLocation+$20+$46,(a2)+ ; set a2 to bottom left corner and advance
                sub.w   #1,d2                    ; sub 1 from width counter
      @drawbottomline2:
                cmpi.w  #3,d2                    ; are we down to the 3rd last one
                beq.s   @drawbottomright2         ; if so, branch
                move.w  #FontLocation+$20+$47,(a2)+ ; set a2 to bottom and advance
                sub.w   #1,d2                    ; sub 1 from width counter
                bra.s   @drawbottomline2          ; loop
      @drawbottomright2:
                move.w  #FontLocation+$20+$48,(a2)+ ; set a2 to bottom right corner and advance
                move.w  #FontLocation+$20+$49,(a2)+ ; set a2 to bottom right corner and advance


                rts
