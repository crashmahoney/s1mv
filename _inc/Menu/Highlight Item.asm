
HighlightItem:
                lea     (v_256x256), A4           ; load start address of 256x256 block to a4
       ; choosing equip slot?
                cmpi.b  #2,(v_levselpage)         ; on equip page?
                bne.s   @CheckInv
                cmpi.b  #1,(v_menupagestate)      ; choosing slot?
                bne.s   @CheckInv
                lea     (Equip_Text_Highlight), A5     ; load start of highlight array to a5
                bra.s   @continue
       ; choosing from inventory?
          @CheckInv:
                cmpi.b  #2,(v_menupagestate)
                bne.s   @CheckDebug
                lea     (Inventory_Text_Highlight), A5     ; load start of highlight array to a5
                bra.s   @continue
          @CheckDebug:
                cmpi.b  #3,(v_levselpage)         ; on debug page?
                bne.s   @CheckSoundTest
                cmpi.b  #1,(v_menupagestate)      ; choosing slot?
                bne.s   @donothing
                lea     (Debug_Text_Highlight), A5     ; load start of highlight array to a5
                bra.s   @continue
          @CheckSoundTest:
                cmpi.b  #4,(v_levselpage)         ; on sound test page?
                bne.s   @donothing
                cmpi.b  #1,(v_menupagestate)      ; choosing slot?
                bne.s   @donothing
                lea     (SoundTest_Text_Highlight), A5     ; load start of highlight array to a5
                bra.s   @continue

          @donothing:
                rts
@continue:
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
                 rts