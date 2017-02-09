;========================================================================================================================
; Exit on pressing Start
;========================================================================================================================
@startpressed:
;                tst.b   (f_inmenu).w
		bra.w   ExitPauseMenu
		rts

;========================================================================================================================
; Button Handling
;========================================================================================================================
MenuButtonHandling:
		cmpi.b  #6,(v_levselpage).w        ; vram viewer?
		beq.w   VRAMviewButtons
	; first check what state the menu is in and jump to the appropriate place
		moveq   #$00, D0                 ; clear d0
		move.b  (v_menupagestate).l,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	PageStates(pc,d0.w),a6		; load correct routine to jump to
		jmp	(a6)

PageStates:
		dc.l	SelectPage
		dc.l	SelectSlot
		dc.l	SelectInventory

;========================================================================================================================
; Page State 0 (Select which page is viewed)
;========================================================================================================================

SelectPage:
		moveq   #$00, D0
		move.w  (v_Ctrl1Press).w, D1

		moveq   #3,d2                      ; only go up to page 2
		tst.b   (f_debugcheat).w           ; is debug is active?
		beq.s   @DpadRight                 ; if not, branch
		moveq   #4,d2                      ; we can go up to page 3
		
		moveq   #5,d2                      ; go up to 4 (soundtest)

       ; if left or right is held, change the page shown

	@DpadRight:
		btst    #$03, D1                   ; is dpad right held?
		beq.s   @DpadLeft                  ; if not, branch
		sfx	sfx_Switch                 ; play switch sound
		add.b   #1,(v_levselpage).w
		cmp.b   (v_levselpage).w,d2        ; past the end of list?
		bne.s   @UpdatePage                ; if not, branch
		move.b  #$00, (v_levselpage).w     ; set page counter to 0
		bra.s   @UpdatePage                ; if not, branch
	@DpadLeft:
		btst    #$02, D1                   ; is dpad right held?
		beq.s   @CheckAB                   ; if not, branch
		sfx	sfx_Switch	           ; play switch sound
		sub.b   #1,(v_levselpage).w
		bcc.s   @UpdatePage                ; if not past the start of list, branch
		sub.b   #1,d2
		move.b  d2,(v_levselpage).w        ; set page counter to 3
@UpdatePage:
		move.b  #0, (v_menuequipslot)      ; set selected item to 0
		bsr.w   RedrawFullMenu

       ; if A or B is pressed, go to next page mode (slot select)
@CheckAB:
		move.w	(v_Ctrl1Press).w,d0
		andi.b	#btnAB,d0	              ; is A or B pressed?
		beq.w	@CheckC	              ; if not, branch
;                sfx     sfx_Lamppost
		move.b  #1,(v_menupagestate).l        ; advance state
		move.w  #0,(v_levselitem).w           ; set menu to top
; exceptions
		cmpi.b  #0,(v_levselpage).w           ; on use item page
		bne.s   @continue                     ; if not, branch
		move.b  #2,(v_menupagestate).l        ; skip straight to inventory mode
	@continue:
		bsr.w   RedrawFullMenu
@CheckC:
       ; if C is pressed, exit menu             ?????? WHY DOES THIS CRASH???????
;                 move.w	(v_Ctrl1Press).w,d0
; 		andi.b	#btnC,d0	              ; is C pressed?
; 		beq.w	@donothing	              ; if not, branch
;         ;        tst.b   (f_inmenu).w
;                 bra.w   ExitPauseMenu
@donothing:
		rts








;========================================================================================================================
; Page State 1 (Select slot)
;========================================================================================================================

SelectSlot:
		moveq   #$00, D0
		move.w  (v_Ctrl1Press).w, D1
		andi.b  #$03, D1                   ; are dpad up or down pressed?
		bne.s   @DpadUpDown                ; if so?, branch
		subq.w  #$01, (v_levseldelay).w    ; sub 1 from time until change
		bpl.s   @CheckAB                   ; if time is positive, branch
@DpadUpDown:
		move.w  #$000B, (v_levseldelay).w  ; set delay to 14? frames?
		move.w  (v_Ctrl1Held).w, D1
		andi.b  #$03, D1                   ; are dpad up or down held?
		beq.s   @CheckAB                   ; if not, branch
		move.w  (v_levselitem).w, D0
		btst    #$00, D1                   ; is dpad up held?
		beq.s   @DpadDown                  ; if not, branch
;		sfx	sfx_Switch                 ; play switch sound
		move.w  (v_levselitem).w, D0
		subq.w  #$01, D0                   ; sub 1 from selected item
		bcc.s   @DpadDown                  ; if not below 0 branch
		moveq   #$00, D0
		move.b  (v_menuslots), D0          ; jump to bottom
@DpadDown:
		btst    #$01, D1                   ; is dpad down held?
		beq.s   @SetSelectedItem           ; if not, branch
;		sfx	sfx_Switch                 ; play switch sound
		move.w  (v_levselitem).w, D0
		addq.w  #$01, D0                   ; add 1 to selected item
		cmp.b   (v_menuslots),d0           ; if gone past the end of 2nd column
		bls.s   @SetSelectedItem
		moveq   #$0000, D0                 ; jump to top of 2nd column


@SetSelectedItem:
		move.w  D0, (v_levselitem).w       ; set selected item
		move.b  D0, (v_menuequipslot)      ; set selected item
		jsr     DrawDescription
		cmpi.b  #2,(v_levselpage)             ; on the equip page?
		bne.w   @donothing                     ; if not, branch
		jsr     DrawInventory
		jsr     PauseMenu_DrawMenu         ; draw the Menu
		rts
       ; if A or B is pressed, go to next page mode (slot select)
@CheckAB:
       ; Sound Test Selected?
		cmpi.b  #$04, (v_levselpage).w     ; On Soundtest page?
		bne     @notsndtest
		cmpi.w  #$0000, (v_levselitem).w   ; is sound test selected?
		beq.w   SndTstSelected             ; if so, branch
		cmpi.w  #$0001, (v_levselitem).w   ; is tempo divider selected?
		beq.w   TempoDivSelected           ; if so, branch
		cmpi.w  #$0002, (v_levselitem).w   ; is tempo modifier selected?
		beq.w   TempoModSelected           ; if so, branch
		cmpi.w  #$0003, (v_levselitem).w   ; is music pitch selected?
		beq.w   MusicPitchSelected         ; if so, branch
		cmpi.w  #$0004, (v_levselitem).w   ; is drum kit selected?
		beq.w   DrumKitSelected            ; if so, branch
       @notsndtest:
		move.w	(v_Ctrl1Press).w,d0
		andi.b	#btnAB,d0	              ; is A or B pressed?
		beq.w	@CheckC	                      ; if not, branch
		cmpi.b  #2,(v_levselpage)             ; on the equip page?
		bne.s   @CheckDebug                   ; if not, branch
;                sfx     sfx_Door
		move.w  #0, (v_levselitem).w          ; set selected item
		move.b  #2,(v_menupagestate).l        ; advance state
		bsr.w   RedrawFullMenu
		rts
       @CheckDebug:
		jsr     ButtonPress_Debug
@CheckC:
       ; if C is pressed, go back to previous state
		move.w	(v_Ctrl1Press).w,d0
		andi.b	#btnC,d0	              ; is C pressed?
		beq.w	@donothing	              ; if not, branch
;                sfx     sfx_SSItem
		move.b  #0,(v_menupagestate).l        ; decrease state
		bsr.w   RedrawFullMenu
@donothing:
		rts






;========================================================================================================================
; Page State 2 (Select inventory)
;========================================================================================================================

SelectInventory:
		move.w  (v_Ctrl1Press).w, D1
		andi.b  #$03, D1                   ; are dpad up or down pressed?
		bne.s   @DpadUpDown                ; if so?, branch
		subq.w  #$01, (v_levseldelay).w    ; sub 1 from time until change
		bpl.w   @SkipDpadUpDown            ; if time is positive, branch
@DpadUpDown:
		move.w  #$000B, (v_levseldelay).w  ; set delay to 14? frames?
		move.w  (v_Ctrl1Held).w, D1
		andi.b  #$03, D1                   ; are dpad up or down held?
		beq.w   @SkipDpadUpDown            ; if not, branch
		move.w  (v_levselitem).w, D0
		btst    #$00, D1                   ; is dpad up held?
		beq.s   @DpadDown                  ; if not, branch
		cmpi.w  #1,d0                      ; is cursor at top of list?
		bgt.s   @decrease                  ; if not, branch
		cmpi.b  #0,(FirstDrawnItem)        ; scrolled right to the top?
		beq.s   @noscroll                  ; if so, branch
		sfx	sfx_Switch                 ; play switch sound
		sub.b   #2,(FirstDrawnItem).l      ; scroll list up
		jsr     RedrawFullMenu
		jsr     DrawDescription
	@noscroll:
			rts
	@decrease:
		sfx	sfx_Switch                 ; play switch sound
		move.w  (v_levselitem).w, D0
		subq.w  #$02, D0                   ; sub 1 from selected item
		bra.w   @SetSelectedItem
@DpadDown:
		btst    #$01, D1                   ; is dpad down held?
		beq.w   @SetSelectedItem           ; if not, branch
		move.w  (v_levselitem).w, D0
		move.w  (NumberOfItems), d2
		sub.b   (FirstDrawnItem),d2
		sub.b   #3,d2
		cmp.b   d0,d2                      ; last item on list?
		bge.s   @checkscroll               ; if not, skip
		rts

	@checkscroll:
		cmpi.w  #8,d0                      ; at the bottom of the list (9 or 10)
		blt.s   @increase                  ; if not, branch
		sfx	sfx_Switch                 ; play switch sound
		move.w  (v_levselitem).w, D0
		add.b   #2,(FirstDrawnItem).l      ; scroll list down
		jsr     RedrawFullMenu
		jsr     DrawDescription
		rts
	@increase:
		sfx	sfx_Switch                 ; play switch sound
		move.w  (v_levselitem).w, D0
		addq.w  #$02, D0                   ; add 1 to selected item
		bra.s   @SetSelectedItem

@SkipDpadUpDown:
@DpadLR:
		moveq   #$00, D0
		move.w  (v_Ctrl1Press).w, D1
	@DpadRight:
		btst    #$03, D1                   ; is dpad right held?
		beq.s   @DpadLeft                  ; if not, branch

		btst    #0,(v_levselitem+$1).w     ; is selection even (on left side?)
		bne.s   @CheckAB                   ; if not, branch
		move.w  (v_levselitem).w, d0
		move.w  (NumberOfItems), d2
		sub.b   (FirstDrawnItem),d2
		sub.b   #1,d2
		cmp.b   d0,d2                      ; last item on list?
		beq.s   @CheckAB                   ; if so, branch
		sfx	sfx_Switch                 ; play switch sound
		move.w  (v_levselitem).w, d0
		add.w   #1,d0
		bra.s   @SetSelectedItem
	@DpadLeft:
		btst    #$02, D1                   ; is dpad left held?
		beq.s   @CheckAB                   ; if not, branch

		btst    #0,(v_levselitem+$1).w     ; is selection even (on left side?)
		beq.s   @CheckAB                   ; if not, branch
		sfx	sfx_Switch	           ; play switch sound
		move.w  (v_levselitem).w, d0
		sub.w   #1,d0
@SetSelectedItem:
		move.w  D0, (v_levselitem).w       ; set selected item
		jsr     DrawDescription
		rts
       ; if A or B is pressed, run selected item's code
@CheckAB:
		move.w	(v_Ctrl1Press).w,d0
		andi.b	#btnAB,d0	               ; is A or B pressed?
		beq.w	@CheckC	                       ; if not, branch
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
		moveq    #0,d2
		lea      (EquipAbilitiesList),a1       ; List of equippable abilities
		lea      (v_a_ability),a2         ;  "        "         "        "
		move.b   (v_menuequipslot),d2          ; get the slot that ability is being equipped to
		adda.l   d2,a2
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
		move.b   (a4),d2                       ; inventory item selected
		add.w	 d2,d2
		add.w	 d2,d2
		adda.l   d2,a1                         ; get current inv item address
		movea.l  (a1),a1                       ; move item to a1
		movea.l  a1,a0                         ; copy address so we can still use it later
		adda.l   #InvCodeOffset,a0             ; get code location
		jsr      (a0)                          ; jump to code location
		cmpi.b   #2,(v_levselpage)             ; on the equip page?
		beq.s    @goback                       ; if so, branch
		rts
@CheckC:
       ; if C is pressed, go back to previous state
		move.w	(v_Ctrl1Press).w,d0
		andi.b	#btnC,d0	              ; is C pressed?
		beq.w	@donothing	              ; if not, branch
		sfx     sfx_SSItem
	@goback:
		move.b  #1,(v_menupagestate).l        ; decrease state
		moveq   #0,d0
		move.b  (v_menuequipslot),d0
		move.w  d0,(v_levselitem).w           ; set menu to top
; exceptions
		cmpi.b  #0,(v_levselpage).w           ; on use item page
		bne.s   @continue                     ; if not, branch
		move.b  #0,(v_menupagestate).l        ; skip straight to page select
	@continue:
		bsr.w   RedrawFullMenu
@donothing:
		rts

; ===========================================================================

; ---------------------------------------------------------------------------
; Adds the selected item's effects to the Effect list
; ---------------------------------------------------------------------------

ApplyItemEffects:
		cmpi.b  #16,(v_activeeffects).w ;already at max effects?
		bhs.s   @rts            ; if so branch
		lea     (ItemEffects).w,a3   ; current effects list
		moveq   #0,d0
		adda    #InvEffeOffset,a1    ; get effect time timit
		move.b  (a1)+,d0        ; move to d0, now a1 is first effect
		mulu.w  #60,d0          ; get time limit in frames
		moveq   #19,d1          ; loop through 20 effect slots
	@effectloop:
		tst.b   (a3)            ; is there an active effect in this slot?
		bne.s   @skip           ; if so, branch
		move.b  (a1)+,(a3)      ; set effect type
		move.b  (a1)+,1(a3)     ; set effect amount
		move.w  d0,2(a3)        ; set time limit
		add.b   #1,(v_activeeffects).w
		tst.b   (a1)            ; is there another effect?
		beq.s   @breakfromloop  ; if not, exit loop
	@skip:
		adda    #4,a3           ; go to next slot
		dbf     d1,@effectloop  ; loop
	@breakfromloop:
		bsr.w   SetStatEffects  ; apply effects
	@rts:
		rts
; ===========================================================================










;
; 
; ;========================================================================================================================
; ; Is A, B, or C pressed?
; ;========================================================================================================================
; 
; @abcpressed:
;                 moveq   #$00, D0                 ; clear d0
;                 move.b  (v_levselpage).w,d0
; 		add.w	d0,d0
; 		add.w	d0,d0
;  		movea.l	ABCMenuPages(pc,d0.w),a6		; load correct routine to jump to
; 		jmp	(a6)
; 
; ; ===========================================================================
; ABCMenuPages:
;                 dc.l	ButtonPress_Status
;                 dc.l	ButtonPress_Map
;                 dc.l	ButtonPress_Items
;                 dc.l	ButtonPress_Abilities
;                 dc.l	ButtonPress_Debug
; ; ===========================================================================
; ; ---------------------------------------------------------------------------
; ; Routine when on Status Screen
; ; ---------------------------------------------------------------------------
; ButtonPress_Status:
;                 bra     PauseMenu_Main_Loop
; ;========================================================================================================================
; ; ---------------------------------------------------------------------------
; ; Routine when on Map Screen
; ; ---------------------------------------------------------------------------
; ButtonPress_Map:
;                 bra     PauseMenu_Main_Loop
; ;========================================================================================================================
; ; ---------------------------------------------------------------------------
; ; Routine when on Item Screen
; ; ---------------------------------------------------------------------------
; ButtonPress_Items:
; 
;                 lea     (CurrentInventoryArray).l,a4   ; First slot (of 10, each slot 2 bytes)
;                 moveq    #0,d2
;                 move.b  (FirstDrawnItem).l,d2
; 		add.w	 d2,d2
;                 lea     (a4,d2),a4                     ; First slot (of 10, each slot 2 bytes)
;                 moveq    #0,d0
;                 move.w  (v_levselitem).w,d0
;                 mulu     #2,d0
;                 adda.l   d0,a4                         ; get inventory item in selected inventory slot
;                 lea      (Inventory_Text_Positions),a5
;                 lea      (InventoryItemsList),a1       ; List of inventory items
;                 moveq    #0,d2
;                 move.b   (a4),d2                       ; inventory item selected
; 		add.w	 d2,d2
; 		add.w	 d2,d2
;                 adda.l   d2,a1                         ; get current inv item address
;                 movea.l  (a1),a1                       ; move item to a1
;                 adda.l   #InvCodeOffset,a1             ; get code location
;                 jmp      (a1)                          ; jump to code location
; 
; ; ===========================================================================
; ; ---------------------------------------------------------------------------
; ; Routine when on Ability Screen
; ; ---------------------------------------------------------------------------
; 
; ButtonPress_Abilities:
;                 bra     PauseMenu_Main_Loop
; 
;========================================================================================================================
; ---------------------------------------------------------------------------
; Routine when on Debug Screen
; ---------------------------------------------------------------------------
ButtonPress_Debug:
		moveq   #$00, D0                 ; clear d0
		move.w  (v_levselitem).w,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	ButtonPress_Debug_Select(pc,d0.w),a6		; load correct routine to jump to
		jmp	(a6)

; ===========================================================================
ButtonPress_Debug_Select:
		dc.l	@save1       		; save slot 1
		dc.l	@save2     		; save slot 2
		dc.l	@save3   		; save slot 3
		dc.l	@itemplace
		dc.l	@supersonic
		dc.l	@addminute
		dc.l	@chaosemerald
		dc.l	@LevelSelect
		dc.l	@AllAbilities
		dc.l	@AllItems
		dc.l    @VRAMviewer
		dc.l    @CPUMeter
; ===========================================================================
@save1:		; save slot 1
		sfx	sfx_Cash                 ; play switch sound
		jsr     SaveState
		moveq   #0,d0                      ; save slot 1
		jsr     SaveGame
		rts
; ===========================================================================
@save2:		; save slot 2
		sfx	sfx_Cash                 ; play switch sound
		jsr     SaveState
		moveq   #1,d0
		jsr     SaveGame                   ; save slot 2
		rts
; ===========================================================================
@save3:		; save slot 3
		sfx	sfx_Cash                 ; play switch sound
		jsr     SaveState
		moveq   #2,d0                      ; save slot 3
		jsr     SaveGame
		rts
; ===========================================================================
@itemplace:
		sfx	sfx_Cash                 ; play switch sound
		eori.b  #1,(f_debugmode).w       ; toggle item placement mode
		bsr.w   RedrawFullMenu
		rts
; ===========================================================================
@supersonic:
		sfx	sfx_Cash                 ; play switch sound
; 	        eori.b  #1,(f_supersonic).w      ; toggle super sonic mode
		jsr	Sonic_CheckGoSuper	; if yes, test for turning into Super Sonic

		bsr.w   RedrawFullMenu
		rts
; ===========================================================================
@addminute:
		sfx	sfx_Cash                 ; play switch sound
		add.b  #1,(v_timemin).w          ; add 1 minute to timer
		bsr.w   RedrawFullMenu
		rts
; ===========================================================================
@chaosemerald:
		sfx	sfx_Cash                 ; play switch sound
		add.b  #1,(v_emeralds).w          ; add to emerald count
		bsr.w   RedrawFullMenu
		rts
; ===========================================================================
@LevelSelect:
		jmp	 Level_Select_Menu; Go to Sonic 2 Level Select        +++
		rts
; ===========================================================================
@AllAbilities:
		moveq   #0,d1
		move.b  #$1F,d1
		lea     (v_abil_items).w,a0
    @abilloop:  move.b  #1,(a0)+
		dbf     d1,@abilloop
		sfx	sfx_Cash                 ; play switch sound
		rts
; ===========================================================================
@AllItems:
		sfx	sfx_Cash                 ; play switch sound
		lea     (v_inv_items).w,a0
		move.l  #v_abil_items-1,d1
		sub.l   a0,d1
    @itemloop:  cmpi.b  #9,(a0)
		beq.s   @dontadd
		add.b   #1,(a0)+
		dbf     d1,@itemloop
		rts
    @dontadd:   adda    #1,a0
		dbf     d1,@itemloop
		rts
; ===========================================================================
@VRAMviewer:
		sfx	sfx_Cash                 ; play switch sound
		move.b  #6,(v_levselpage)        ; go to screen
		move.w  #0,(v_levselitem)        ; go to screen
		bsr.w   RedrawFullMenu
		rts
; ===========================================================================
@CPUMeter:
		sfx sfx_Cash                 	; play switch sound
		eori.b  #1,(v_cpumeter).w       ; toggle cpu meter mode
		move.w	#$9100,(VDP_control_port).l	; set window plane horiz to 0
		move.w	#$8004,(VDP_control_port).l	; turn sms vdp mode off

		move.w	#$2700,sr		; disable ints
		lea	(VDP_data_port).l,a6
		move.w	#$8F80,4(a6)		; set autoincrement to 128 bytes
		move.l	#$86908690,d0		; we want to write tile $690 high priority to window nametable

		move.l	#$40000000+(($D000&$3FFF)<<16)+(($D000&$C000)>>14),4(a6)	; write to vram location $D000
		moveq	#14-1,d2		; loop for 28 tiles
	@writerow1:	
		move.l	d0,(a6)			; send to vdp data port
		dbf	d2,@writerow1

		move.l	#$40000000+(($D002&$3FFF)<<16)+(($D002&$C000)>>14),4(a6)	; write to vram location $D002
		moveq	#14-1,d2		; loop for 28 tiles
	@writerow2:	
		move.l	d0,(a6)			; send to vdp data port
		dbf	d2,@writerow2

		move.w	#$8F02,4(a6)		; set autoincrement to 2 bytes
		move.w	#$2300,sr		; enable ints		
		bsr.w   RedrawFullMenu
		rts
;========================================================================================================================
; ---------------------------------------------------------------------------
; debug special button presses :)
; ---------------------------------------------------------------------------

SndTstSelected:
		move.w  (v_levselsound).w, D0
		move.w  (v_Ctrl1Press).w, D1
		btst    #$02, D1                   ; is dpad left pressed?
		beq.s   @ChkSndTstRight            ; if not, branch
		subq.b  #$01, D0                   ; subtract sound test counter

	if z80SoundDriver=0
		bcc.s   @ChkSndTstRight            ; if not past the start of list, branch
		moveq   #$7F, D0                   ; roll sound test counter back to end
	endif

@ChkSndTstRight:
		btst    #$03, D1                   ; is dpad right held?
		beq.s   @ChkSndTstA                ; if not, branch
		addq.b  #$01, D0                   ; add 1 to sound test counter

      if z80SoundDriver=0
		cmpi.w  #$0080, D0                 ; past the end of list?
		bcs.s   @ChkSndTstA                ; if not, branch
		moveq   #$00, D0                   ; set sount test counter to 0
      endif

@ChkSndTstA:
		btst    #$06, D1                   ; is button A is pressed?
		beq.s   @SetSndTstItem             ; if not, branch
		addi.b  #$10, D0                   ; add $10 to sound test counter
      if z80SoundDriver=0
		andi.b  #$7F, D0                   ; don't go over $7F
      endif
@SetSndTstItem:
		move.w  D0, (v_levselsound).w      ; set sound test item
       ; draw number
		lea     (v_256x256).l,a2
		adda.l  #$01B4,a2
      if z80SoundDriver=0
		addi.w  #$0080, D0                 ; choose actual sound offset
      endif
		bsr     DrawHex                    ; draw counter no.
     ; play music
		andi.w  #$0030, D1                 ; are B or C pressed?
		beq.s   @donothing                 ; if not, branch
		move.w  (v_levselsound).w, D0
      if z80SoundDriver=0
		addi.w  #$0080, D0                 ; choose actual sound offset
      endif
		jsr     PlaySound                  ; start playing music
		jsr     RedrawFullMenu

		lea     (Code_Debug_Mode), A0
		lea     (Code_All_Emeralds), A2
		lea     ($FFFFFF0A).w, A1
		moveq   #$01, D2
		bsr     PauseMenu_Code_Test 
@donothing:
		rts

; ===========================================================================


MusicPitchSelected:
		move.b  (v_musicpitch).w, D0
		move.w  (v_Ctrl1Press).w, D1
		btst    #$02, D1                   ; is dpad left pressed?
		beq.s   @ChkSndTstRight            ; if not, branch
		subq.b  #$01, D0                   ; subtract sound test counter
@ChkSndTstRight:
		btst    #$03, D1                   ; is dpad right held?
		beq.s   @SetSndTstItem             ; if not, branch
		addq.b  #$01, D0                   ; add 1 to sound test counter
@SetSndTstItem:
		move.b  D0, (v_musicpitch).w      ; set sound test item
       ; draw number
		lea     (v_256x256).l,a2
		adda.l  #$02A4,a2
		bsr     DrawHex                    ; draw counter no.
		rts

; ===========================================================================
DrumKitSelected:
		move.b  (v_drumkit).w, D0
		move.w  (v_Ctrl1Press).w, D1
		btst    #$02, D1                   ; is dpad left pressed?
		beq.s   @ChkDrumKitRight           ; if not, branch
		sub.b   #$01, D0                   ; subtract sound test counter
		bcc.s   @ChkDrumKitRight           ; if below 0
		move.b  #$d9,d0                     ; roll counter over

@ChkDrumKitRight:
		btst    #$03, D1                   ; is dpad right held?
		beq.s   @SetDrumKitItem            ; if not, branch
		add.b   #$01, D0                   ; add 1 to sound test counter
		cmpi.b  #$d9,d0                      ; is drum kit over 6?
		bls.s   @SetDrumKitItem            ; if not, branch
		moveq   #0,d0                      ; roll counter over

@SetDrumKitItem:
		move.b  D0, (v_drumkit).w          ; set sound test item
       ; draw number
		lea     (v_256x256).l,a2
		adda.l  #$02F4,a2
		bsr     DrawHex                    ; draw counter no.

     ; play music
		andi.w  #$0030, D1                 ; are B or C pressed?
		beq.s   @donothing                 ; if not, branch
		move.b  (v_drumkit).w, D0
	;        add.b   #$80,d0
		stopZ80
		waitz80
		move.b  d0,($A01CAA).l
		startZ80
       @donothing:
		rts

; ===========================================================================


TempoDivSelected:
;                 move.b  (v_tempo_time).w, D2
;                 move.w  (v_Ctrl1Press).w, D1
;                 btst    #$02, D1                   ; is dpad left pressed?
;                 beq.s   @ChkSndTstRight            ; if not, branch
;                 subq.b  #$01, D2                   ; subtract tempo div counter
;                 bra.s   @SetTempoDiv
; @ChkSndTstRight:
;                 btst    #$03, D1                   ; is dpad right held?
;                 beq.s   @donothing                 ; if not, branch
;                 addq.b  #$01, D2                   ; add 1 to tempo div counter
; @SetTempoDiv:
;                 move.w  (v_levselsound).w, D0
;                 jsr     PlaySound_Special          ; start playing music
;                 move.b  D2, (v_tempo_time).w      ; set DAC divider
;                 move.b  D2, ($FFFFF072).w         ; set FM1 divider
;                 move.b  D2, ($FFFFF0A2).w         ; set FM2 divider
;                 move.b  D2, ($FFFFF0D2).w         ; set FM3 divider
;                 move.b  D2, ($FFFFF102).w         ; set FM4 divider
; ;                move.b  D2, ($FFFFF132).w         ; set FM5 divider
;                 move.b  D2, ($FFFFF10B).w         ; set FM5 divider
;                 move.b  D2, ($FFFFF192).w         ; set PSG1 divider
;                 move.b  D2, ($FFFFF1C2).w         ; set PSG2 divider
;                 move.b  D2, ($FFFFF1F2).w         ; set PSG3 divider
;        ; draw number
;                 jsr     RedrawFullMenu
       @donothing:
		rts

; ===========================================================================

TempoModSelected:
      if z80SoundDriver=0
		move.b  ($FFFFF002).w, D0
      else
		stopZ80
		waitz80
		move.b  ($A01C24).l,d0
      endif
		move.w  (v_Ctrl1Press).w, D1
		btst    #$02, D1                   ; is dpad left pressed?
		beq.s   @ChkSndTstRight            ; if not, branch
		subq.b  #$01, D0                   ; subtract sound test counter
@ChkSndTstRight:
		btst    #$03, D1                   ; is dpad right held?
		beq.s   @ChkSndTstA                ; if not, branch
		addq.b  #$01, D0                   ; add 1 to sound test counter
@ChkSndTstA:
		btst    #$06, D1                   ; is button A is pressed?
		beq.s   @ChkSndTstB                ; if not, branch
		addi.b  #$10, D0                   ; add $10 to sound test counter
@ChkSndTstB:
		btst    #$04, D1                   ; is button B is pressed?
		beq.s   @SetSndTstItem             ; if not, branch
		subi.b  #$10, D0                   ; add $10 to sound test counter
@SetSndTstItem:
      if z80SoundDriver=0
		move.b  d0,($FFFFF002).w
      else
		move.b  d0,($A01C24).l
		startZ80
      endif
       ; draw number
		lea     (v_256x256).l,a2
		adda.l  #$0254,a2
		bsr     DrawHex                    ; draw counter no.
		rts
; --------------------------------------------------------------------------
; =========================================================================
;
; =========================================================================
VRAMviewButtons:
		moveq   #$00, D0
		move.w  (v_Ctrl1Press).w, D1
		andi.b  #$03, D1                   ; are dpad up or down pressed?
		bne.s   @DpadUpDown                ; if so?, branch
		subq.w  #$01, (v_levseldelay).w    ; sub 1 from time until change
		bpl.s   @CheckAB                   ; if time is positive, branch
@DpadUpDown:
		move.w  #$0003, (v_levseldelay).w  ; set delay to 14 frames
		move.w  (v_Ctrl1Held).w, D1
		andi.b  #$03, D1                   ; are dpad up or down held?
		beq.s   @CheckAB                   ; if not, branch
		btst    #$00, D1                   ; is dpad up held?
		beq.s   @DpadDown                  ; if not, branch
		sfx	sfx_Switch                 ; play switch sound
		move.w  (v_levselitem).w, D0
		sub.w   #$20, D0                   ; sub 10 from selected item
@DpadDown:
		btst    #$01, D1                   ; is dpad down held?
		beq.s   @SetSelectedItem           ; if not, branch
		sfx	sfx_Switch                 ; play switch sound
		move.w  (v_levselitem).w, D0
		add.w   #$20, D0                   ; add 1 to selected item
@SetSelectedItem:
		move.w  D0, (v_levselitem).w       ; set selected item
		jsr     RedrawFullMenu
		rts

@CheckAB:
		move.w	(v_Ctrl1Press).w,d0
		andi.b	#btnA,d0	              ; is A pressed?
		beq.w	@CheckB	                      ; if not, branch
		sfx     sfx_Door
		bchg    #3,(v_levselitem).w           ; toggles mirroring
		bsr.w   RedrawFullMenu
		rts
@CheckB:
		move.w	(v_Ctrl1Press).w,d0
		andi.b	#btnB,d0	              ; is B pressed?
		beq.w	@CheckC	                      ; if not, branch
		sfx     sfx_Door
		bchg    #4,(v_levselitem).w           ; toggles mirroring
		bsr.w   RedrawFullMenu
		rts
@CheckC:
		move.w	(v_Ctrl1Press).w,d0
		andi.b	#btnC,d0	              ; is C pressed?
		beq.w	@CheckR                	      ; if not, branch
		sfx     sfx_SSItem
		move.w  #0, (v_levselpage).w          ; set selected item
		move.b  #0,(v_menupagestate).l        ; decrease state
		bsr.w   RedrawFullMenu
		rts
@CheckR:
		move.w	(v_Ctrl1Press).w,d0
		andi.b	#btnR,d0	              ; is R pressed?
		beq.w	@donothing	              ; if not, branch
		sfx     sfx_Door
		add.w   #$2000,(v_levselitem).w       ; change palette
		bsr.w   RedrawFullMenu
@donothing:
		rts

