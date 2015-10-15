
;=================================================================================
DrawDescription:
                lea     (v_256x256),a3                 ; load start address of 256x256 block
		moveq	#0,d2
		move.b	(v_menupagestate),d2
		add.b   d2,d2
		move.w	DrawDescriptionIndex(pc,d2.w),d2
		jmp	DrawDescriptionIndex(pc,d2.w)
; --------------------------------------------------------------------------
DrawDescriptionIndex:
                dc.w @tabselected-DrawDescriptionIndex
                dc.w @slotselected-DrawDescriptionIndex
                dc.w @invselected-DrawDescriptionIndex
;=================================================================================
@tabselected:
       ; get description when selecting page
                moveq   #0,d2
                lea     (Tab_Descriptions),a1
                move.b  (v_levselpage),d2              ; selected page
                add.b   d2,d2
		adda.w	(a1,d2.w),a1                   ; load pointer to curent tab description
                bra.w   @loadGFX
;=================================================================================
@SlotIndex:
                dc.l    EquipSlotDescriptions          ; 0
                dc.l    EquipSlotDescriptions          ; 1
                dc.l    EquipSlotDescriptions          ; 2
                dc.l    DebugSlotDescriptions          ; 3
                dc.l    SoundTestSlotDescriptions      ; 4
; --------------------------------------------------------------------------
@slotselected:
       ; get description when selecting page
                lea     (@SlotIndex).l,a1
                moveq   #0,d2
                move.b  (v_levselpage),d2              ; selected tab
                add.b   d2,d2
                add.b   d2,d2
		adda.l	d2,a1
		movea.l (a1),a1

                move.w  (v_levselitem),d2              ; current slot
                add.b   d2,d2
		adda.w	(a1,d2.w),a1                   ; load pointer to curent slot description
                bra.w   @loadGFX
;=================================================================================
@invselected:
       ; get description when selecting inventory item
                lea     (CurrentInventoryArray).l,a4   ; First slot (of 10, each slot 2 bytes)
                moveq    #0,d2
                move.b  (FirstDrawnItem).l,d2
		add.w	 d2,d2
                lea     (a4,d2),a4                     ; First slot (of 10, each slot 2 bytes)
                moveq    #0,d0
                move.w  (v_levselitem).w,d0
                mulu     #2,d0
                adda.l   d0,a4                         ; get inventory item in selected inventory slot
                lea      (Inventory_Text_Positions),a5

       ; get which list is being drawn
                lea      (InventoryItemsList),a1       ; List of inventory items
                cmpi.b   #2,(v_levselpage)             ; on the equip page?
                bne.s    @notequip                     ; if not, branch
                lea      (EquipAbilitiesList),a1       ; List of equippable abilities
                cmpi.b   #3,(v_menuequipslot)          ; on shoes slot?
                bne.s    @notshoes                     ; if not, branch
                lea      (EquipShoesList),a1           ; List of equippable abilities
        @notshoes:
                cmpi.b   #4,(v_menuequipslot)          ; on item 1 slot?
                bne.s    @notitem1                     ; if not, branch
                lea      (EquipItemsList),a1           ; List of equippable items
        @notitem1:
                cmpi.b   #5,(v_menuequipslot)          ; on item 2 slot?
                bne.s    @notequip                     ; if not, branch
                lea      (EquipItemsList),a1           ; List of equippable items
        @notequip:
                moveq    #0,d2
                move.b   (a4),d2                       ; inventory item to draw
		add.w	 d2,d2
		add.w	 d2,d2
                adda.l   d2,a1                         ; get current inv item address
                movea.l  (a1),a1                       ; move start of text to a1
                adda.l   #InvDescOffset,a1             ; get descrpition location

; =========================================================================
; load the icon's uncompressed graphics
; =========================================================================
@loadGFX:
		lea	    ($C00000).l,a6
		locVRAM	$BB00,4(a6)
        movea.l (a1)+,a5                       ; move icon location to a5, advance a1 to palette location
		moveq	#$5F,d1
	@LoadIconGFX:
		move.l	(a5)+,(a6)
		dbf	d1,@LoadIconGFX

; =========================================================================
; load the palette
; =========================================================================
                movea.l (a1)+,a6
                lea     ($FFFFFB40).w,a2
                moveq   #$07, d1
@iconpaletteloop:                
                move.l  (a6)+, (a2)+
                dbra    d1, @iconpaletteloop

; =========================================================================
; create the tile map for the icon  (this is retarded, cos of the way sonmaped is saving the art)
; =========================================================================
                moveq   #0,d0                    ; clear d0
                lea     (v_256x256).l,a2
                adda    #$0782,a2                ; icon on screen location
                moveq   #2,d1                    ; draw 3 lines
                move.w  #$45D8,d0   ; first tile to draw
@drawline:
                moveq   #$3,d2                   ; line is 4 tiles long
@drawtile:
                move.w  D0, (A2)+                ; set a2 to letter required and advance
                addq.w  #$3,d0                   ; advance to next letter
                dbra    D2, @drawtile            ; if d2 is over 0 loop back and draw next tile
                sub.w   #$B,d0                   ; choose correct letter to draw 
                adda    #$48,a2                  ; set icon location to next line
                dbra    D1, @drawline            ; if all lines drawn, continue, otherwise loop back and draw the next line

; =========================================================================
; draw the description
; =========================================================================
                lea     (Description_Text_Positions), A5
                moveq   #0, D0                 ; clear d0 (normally stores the letter to draw, i think)
                moveq   #4, D1                 ; set loop counter to 5 (the number of strings)
                bsr.w   DrawBasicMenuText

                lea     (v_256x256).l,a1
                adda    #$0780,a1                ;
                move.l  #$4C000003, D0
                moveq   #$27, D1
                moveq   #$4, D2
                jsr     TilemapToVRAM

                rts