; ---------------------------------------------------------------------------
; Save the current act's state
; ---------------------------------------------------------------------------

SaveState:
;        move    #$2700, SR                    ; interrupt mask level 7
;		moveq	#0,d1
;		moveq	#0,d3
;
 ;       lea     (SRAMLevelStates).l,a1
;		move.b	(v_zone).w,d3         ; get zone number
;		add.w	d3,d3
;		add.w	d3,d3
 ;       adda.l  d3,a1
  ;      movea.l (a1),a1               ; set a1 to Sram location for act 1
;
;		moveq	#0,d3
;		move.b  (v_act).w,d3          ; add act number to get final index number
;		mulu    #4,d3                 ; mutliply by number of bytes saved in each act
 ;       add.w   d3,d3                 ; double (cos we have to skip even bytes)
  ;      adda.l  d3,a1                 ; set a1 to Sram location with correct act
;
;    gotoSRAM
 ;       move.b  (v_brokenmonitors1).w,d1
  ;      move.b  d1,(a1)
   ;     addq.l   #2,a1
    ;    move.b  (v_brokenmonitors2).w,d1
;        move.b  d1,(a1)
;        addq.l   #2,a1
;        move.b  (v_brokenmonitors3).w,d1
;        move.b  d1,(a1)
;        addq.l   #2,a1
;        move.b  (v_actflags).w,d1
;        move.b  d1,(a1)
;    gotoROM
;        move    #$2300, SR                    ; interrupt mask level 3
        rts

; ===========================================================================

; ---------------------------------------------------------------------------
; Load the current act's state
; ---------------------------------------------------------------------------

LoadState:
;        move    #$2700, SR                    ; interrupt mask level 7
;		moveq	#0,d1
;		moveq	#0,d3
;
;        lea     (SRAMLevelStates).l,a1
;		move.b	(v_zone).w,d3         ; get zone number
;		add.w	d3,d3
;		add.w	d3,d3
;        adda.l  d3,a1
;        movea.l (a1),a1               ; set a1 to Sram location for act 1

;		moveq	#0,d3
;		move.b  (v_act).w,d3          ; add act number to get final index number
;		mulu    #4,d3                 ; mutliply by number of bytes saved in each act
 ;       add.w   d3,d3                 ; double (cos we have to skip even bytes)
;        adda.l  d3,a1                 ; set a1 to Sram location with correct act

;    gotoSRAM
;        move.b  (a1),d1
;        move.b  d1,(v_brokenmonitors1).w
;        addq.l   #2,a1
;        move.b  (a1),d1
;        move.b  d1,(v_brokenmonitors2).w
;        addq.l   #2,a1
;        move.b  (a1),d1
;        move.b  d1,(v_brokenmonitors3).w
;        addq.l   #2,a1
;        move.b  (a1),d1
;        move.b  d1,(v_actflags).w
;    gotoROM
;        move    #$2300, SR                    ; interrupt mask level 3
        rts

                even
SRAMLevelStates:
                dc.l   $00200001                 ; GHZ
                dc.l   $00200021                 ; LZ
                dc.l   $00200041                 ; MZ
                dc.l   $00200061                 ; SLZ
                dc.l   $00200081                 ; SYZ
                dc.l   $00200101                 ; SBZ
                dc.l   $00200121                 ; Ending
                dc.l   $00200141                 ; Hub Zone
                dc.l   $00200161                 ; Intro Zone



; ===========================================================================
LevelDataSize   equ     190                   ; size of level state data
Save1Loc:       equ     $200201               ; save game no.1 location
Save2Loc:       equ     $200501               ; save game no.2 location
Save3Loc:       equ     $200801               ; save game no.3 location

; ===========================================================================
SaveGame:
                move    #$2700, SR                    ; interrupt mask level 7
                lea     ($200001).l,a2        ; Start of SRAM (temp save)
        @save1:
                cmpi.b  #0,d0
                bne.s   @save2
                lea     (Save1Loc).l,a1       ; Location to save to
                bra.s   @save
        @save2:
                cmpi.b  #1,d0
                bne.s   @save3
                lea     (Save2Loc).l,a1       ; Location to save to
                bra.s   @save
        @save3:
                cmpi.b  #2,d0
                bne.s   @savenull
                lea     (Save3Loc).l,a1       ; Location to save to
                bra.s   @save
        @savenull:
                rts
        @save:
                gotoSRAM

		move.b	(v_zone).w,d1 	      ; current zone
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram
                
		move.b	(v_act).w,d1 	      ; current act
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram

		move.b	(v_rings).w,d1 	      ; rings byte 1
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram
		move.b	(v_rings+$1).w,d1      ; rings byte 2
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram

		move.b	(v_lives).w,d1        ; lives
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram

		move.b	(v_time).w,d1 	      ; time byte 1
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram
		move.b	(v_timemin).w,d1      ; time byte 2
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram
		move.b	(v_timesec).w,d1      ; time byte 3
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram
		move.b	(v_timecent).w,d1     ; time byte 4
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram

		move.b	(v_score).w,d1 	      ; score byte 1
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram
		move.b	(v_score+$1).w,d1      ; score byte 2
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram
		move.b	(v_score+$2).w,d1      ; score byte 3
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram
		move.b	(v_score+$3).w,d1     ; score byte 4
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram

; 		move.b	(v_abilities).w,d1    ; sonic's abilities
;                 move.b  d1,(a1)               ; save to sram
;                 addq.l   #2,a1                ; advance sram

		move.b	(v_inv_shield).w,d1    ; shields
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram

		move.b	(v_inv_invinc).w,d1    ; invincibilities
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram

		move.b	(v_inv_shoes).w,d1    ; shoes
                move.b  d1,(a1)               ; save to sram
                addq.l   #2,a1                ; advance sram

		moveq	#0,d3
		move.b	#LevelDataSize,d3     ; size of save in bytes (save level data only)
          @saveloop:
                move.b  (a2),d1
                move.b  d1,(a1)
                addq.l   #2,a1                ; advance sram
                addq.l   #2,a2                ; advance sram
                dbf      d3,@saveloop
                gotoROM
                move    #$2300, SR                    ; interrupt mask level 3
                rts

; ===========================================================================

LoadGame:
; clear old data before loading game
                move    #$2700, SR                    ; interrupt mask level 7
		move.b	#id_Level,(v_gamemode).w ; set screen mode to $0C (level)
		moveq	#0,d0
		move.w	d0,(v_rings).w	; clear rings
		move.l	d0,(v_time).w	; clear time
		move.b	d0,(v_lives).w	; clear lives
		move.l	d0,(v_score).w	; clear score
		move.b	d0,(v_lastspecial).w ; clear special stage number
		move.b	d0,(v_emeralds).w ; clear emeralds
		move.l	d0,(v_emldlist).w ; clear emeralds
		move.l	d0,(v_emldlist+4).w ; clear emeralds
		move.b	d0,(v_continues).w ; clear continues
		
                gotoSRAM
		lea	($200001).l,a2	; start of SRAM
                moveq	#0,d1
                moveq	#$3F,d1		; assuming SRAM is from $200001 to $2001FF and is odd addresses only
                moveq	#0,d0

@ClrSRAMLoop:
	        movep.l	d0,0(a2)
	        addq.l	#8,a2	; since every other byte is skipped we add 8 instead of 4
	        dbf	d1,@ClrSRAMLoop

; select save slot
		lea	($200001).l,a2	; start of SRAM
        @save1:
                cmpi.b  #0,d0
                bne.s   @save2
                lea     (Save1Loc).l,a1       ; Location to save to
                bra.s   @load
        @save2:
                cmpi.b  #1,d0
                bne.s   @save3
                lea     (Save2Loc).l,a1       ; Location to save to
                bra.s   @load
        @save3:
                cmpi.b  #2,d0
                bne.s   @savenull
                lea     (Save3Loc).l,a1       ; Location to save to
                bra.s   @load
        @savenull:
                rts
        @load:
                move.b  (a1),d1               ; zone
		move.b	d1,(v_zone).w
                addq.l   #2,a1

                move.b  (a1),d1               ; act
		move.b	d1,(v_act).w
                addq.l   #2,a1

                move.b  (a1),d1               ; rings byte 1
		move.b	d1,(v_rings).w
                addq.l   #2,a1
                move.b  (a1),d1               ; rings byte 2
		move.b	d1,(v_rings+$1).w
                addq.l   #2,a1

                move.b  (a1),d1               ; lives
		move.b	d1,(v_lives).w
                addq.l   #2,a1

                move.b  (a1),d1               ; time byte 1
		move.b	d1,(v_time).w
                addq.l   #2,a1
                move.b  (a1),d1               ; time byte 2
		move.b	d1,(v_timemin).w
                addq.l   #2,a1
                move.b  (a1),d1               ; time byte 3
		move.b	d1,(v_timesec).w
                addq.l   #2,a1
                move.b  (a1),d1               ; time byte 4
		move.b	d1,(v_timecent).w
                addq.l   #2,a1

                move.b  (a1),d1               ; score byte 1
		move.b	d1,(v_score).w
                addq.l   #2,a1
                move.b  (a1),d1               ; score byte 2
		move.b	d1,(v_score+$1).w
                addq.l   #2,a1
                move.b  (a1),d1               ; score byte 3
		move.b	d1,(v_score+$2).w
                addq.l   #2,a1
                move.b  (a1),d1               ; score byte 4
		move.b	d1,(v_score+$3).w
                addq.l   #2,a1

;                 move.b  (a1),d1               ; sonic's abilities
; 		move.b	d1,(v_abilities).w
;                 addq.l   #2,a1

                move.b  (a1),d1               ; shields
		move.b	d1,(v_inv_shield).w
                addq.l   #2,a1

                move.b  (a1),d1               ; invincibility
		move.b	d1,(v_inv_invinc).w
                addq.l   #2,a1

                move.b  (a1),d1               ; shoes
		move.b	d1,(v_inv_shoes).w
                addq.l   #2,a1

		moveq	#0,d3
		move.b	#LevelDataSize,d3     ; size of save in bytes (save level data only)
          @loadloop:
                move.b  (a1),d1
                move.b   d1,(a2)
                addq.l   #2,a1                ; advance sram
                addq.l   #2,a2                ; advance sram
                dbf      d3,@loadloop
                gotoROM


		if Revision=0
		else
			move.l	#5000,(v_scorelife).w ; extra life is awarded at 50000 points
		endc
                move    #$2300, SR                    ; interrupt mask level 3
		jsr	PlaySound_Special ; fade out music
		move.b	#$E0,d0
		rts








