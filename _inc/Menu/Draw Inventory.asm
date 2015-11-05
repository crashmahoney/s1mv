DrawInventory:
    ; clear the tilemap
        lea		($FFFF0504).l,a3               ; Location in tilemap where inventory list is drawn
		move.l	#(FontLocation+' '<<16)+FontLocation+' ',d2	;data to write (2 Spaces)
		moveq	#4,d1							; rows to clear
@clearrow:
        moveq	#$F,d0							; longwords to clear on this row
    @clearlong:
        move.l	d2,(a3)+
        dbf		d0,@clearlong
        lea		$10(a3),a3						; reposition to next line
        dbf		d1,@clearrow

    ; clear the list of items that were drawn last time
        lea      (CurrentInventoryArray).l,a3   ; First slot (of 10, each slot 2 bytes)
        moveq    #$1F,d0                        ; overall inventory slots
    @clearinv:
        move.w   #0,(a3)+
        dbf      d0,@clearinv
; =========================================================================
;
; =========================================================================
; get which list we need to draw
        lea		InventoryItemsList,a1       	; Load list of useable items
        moveq	#(InventoryItemsList_End-InventoryItemsList)/4,d3 ; number of items in list
        cmpi.b	#2,(v_levselpage).l           	; on the equip page?
        bne.s	@gotlist                     	; if not, branch
        moveq	#0,d0
        move.b	(v_menuequipslot).l,d0
        add.w	d0,d0
        add.w	d0,d0
        add.w	d0,d0
        lea		EquipSlots,a1
        lea		(a1,d0.w),a1					; address of list of equippable items
        move.l	4(a1),d3						; number of items in list
        sub.l	#1,d3
        movea.l	(a1),a1							; load list of equippable items
    @gotlist:    
        lea		(CurrentInventoryArray).l,a3  	; First slot (of 10, each slot 2 bytes)
        move.w	#0,(NumberOfItems).l
        moveq	#0,d1							; number of current item being written
        bra.s	@none
@SlotLoop:
        add.w	#1,d1                         ; advance
; put the index number of the items to draw and quantities into memory
		move.w	d1,d2
        add.w	d2,d2
        add.w	d2,d2
        lea		(a1,d2),a4
        movea.l	(a4),a4                       ; move quantity location address to a4
        movea.l	(a4),a4                       ; move actual quantity location to a4
        tst.b	(a4)                          ; check if any in inventory
        beq.s	@none                         ; if 0, then branch
        move.b	d1,(a3)+                      ; move item number to slot (first byte)
        move.b	(a4),(a3)+                    ; move quantity to slot    (second byte)
        add.w	#1,(NumberOfItems).l
    @none:
        dbf		d3,@SlotLoop

; draw the items to screen
        lea     (v_256x256),a3                 ; load start address of 256x256 block
        lea     (CurrentInventoryArray).l,a4   ; First slot (of 10, each slot 2 bytes)
        moveq	#0,d2
        move.b  (FirstDrawnItem).l,d2
		add.w	d2,d2
        lea     (a4,d2),a4                     ; First slot (of 10, each slot 2 bytes)
        lea     (Inventory_Text_Positions),a5
        moveq   #$00,d0                        ; clear d0 (normally stores the letter to draw, i think)
        moveq   #$09,d1                        ; Draw 10 inventory items

Inv_Loop_Load_Text:
        tst.b	(a4)
        bne.s	@continue                     ; if not 0, then branch
        bra.w	@uparrow                      ; don't draw any more items
    @continue:
        moveq	#0,d2
        move.b	(a4)+,d2                      ; inventory item to draw
        add.w	d2,d2
        add.w	d2,d2
        lea		(a1,d2),a0                    ; get current inv item address
        movea.l	(a0),a0                       ; move start of text to a1
        adda.l	#InvNameOffset,a0             ; get text location

        move.w  (A5)+, D3                ; put required text position in d3, advance a5 to next item (for next time it loops)
        lea     $00(A3, D3), A2          ; sets a2 to address of requred text position???
        moveq   #$00, D2                 ; clear d2
        move.b  (A0)+, D2                ; set d2 to length of string, advance a1 to first letter in string
        move.w  D2, D3                   ; set d3 to length of string as well
@loadtextloop1:
        moveq   #$00, D0                 ; clear d0 (normally stores the letter to draw, i think)
        move.b  (A0)+, D0                ; set d0 to letter required, advance a1 to letter for next loop around
        add.w   #FontLocation,d0         ; add vram offset
        move.w  d0, (A2)+                ; set a2 to letter required and advance
        dbra    D2, @loadtextloop1       ; if d2 is over 0 loop back and draw next letter
        moveq   #$000B, D2               ; set d2 to 13
        sub.w   D3, D2                   ; sub d3(string length from before (should be 14)) from d2(13)
        bcs.s   @drawactnumber           ; if below 0, skip (should happen all the time, really)
@loadtextloop2:
        move.w  #$0000, (A2)+            ; set value at a2 to clear, advance
        dbra    D2, @loadtextloop2       ; sub 1 from d2, if 0 continue

@drawactnumber:
        moveq   #0,d5
        move.b  (a4)+,d5
    ; check if number shouldn't be drawn
        cmpi.b   #2,(v_levselpage)             ; are we on the equip page?
        bne.s    @drawnumber                   ; if not, branch
        cmpi.b   #2,(v_menuequipslot)          ; are we on an equip ability slot(0, 1, or 2)?
        bls.s    @nonumber                     ; if so, branch
        cmpi.b   #4,(v_menuequipslot)          ; are we on an equip item or emerald slot?
        bge.s    @nonumber                     ; if so, branch
        tst.b    (FirstDrawnItem).l            ; are we at the top of the list?
        bne.s    @drawnumber                   ; if not, branch
        cmpi.b   #9,d1                         ; are we drawing the first item?
        beq.s    @nonumber                     ; that means this is the 'unequip' or --- slot, so, branch

    @drawnumber:
        addi.w  #FontLocation+$30,d5
		move.w  d5,(a2)
		@nonumber:

		dbra    D1, Inv_Loop_Load_Text   ; if all lines drawn, continue, otherwise loop back and draw the next line

	; draw the up and down arrows if it can scroll
@uparrow:
                moveq   #0,d0
                cmpi.b  #0,(FirstDrawnItem).l    ; if at top of list
                beq.s   @downarrow               ; don't draw up arrow
                lea     $FFFF054A,a2             ; move screen position to a2
                move.w  #FontLocation+"+",d0     ; put up arrow ("+" in ascii) in d0
                move.w  d0, (A2)                 ; draw the arrow
@downarrow:
                moveq   #0,d2
                move.w  (NumberOfItems), d2
                sub.b   (FirstDrawnItem),d2
                cmpi.b  #$A,d2                   ; at end of list?
                bls.s   @end                     ; if so, skip
                lea     $FFFF068A,a2             ; move screen position to a2
                move.w  #FontLocation+"-",d0     ; put down arrow ("-" in ascii) in d0
                move.w  d0, (A2)                 ; draw the arrow
@end:
                rts

; =========================================================================
EquipSlots:
	dc.l EquipAbilitiesList, (EquipAbilitiesList_End-EquipAbilitiesList)/4
	dc.l EquipAbilitiesList, (EquipAbilitiesList_End-EquipAbilitiesList)/4
	dc.l EquipAbilitiesList, (EquipAbilitiesList_End-EquipAbilitiesList)/4
	dc.l EquipShoesList, (EquipShoesList_End-EquipShoesList)/4
	dc.l EquipItemsList, (EquipItemsList_End-EquipItemsList)/4
	dc.l EquipItemsList, (EquipItemsList_End-EquipItemsList)/4
	dc.l EquipItemsList, (EquipItemsList_End-EquipItemsList)/4		; will need to be changed to emeralds when (or if) it exists
	even