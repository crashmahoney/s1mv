
BusError:
		move.b	#2,(v_errortype).w
		bra.s	loc_43A

AddressError:
		move.b	#4,(v_errortype).w
		bra.s	loc_43A

IllegalInstr:
		move.b	#6,(v_errortype).w
		addq.l	#2,2(sp)
		bra.w	loc_462

ZeroDivide:
		move.b	#8,(v_errortype).w
		bra.s	loc_462

ChkInstr:
		move.b	#$A,(v_errortype).w
		bra.s	loc_462

TrapvInstr:
		move.b	#$C,(v_errortype).w
		bra.s	loc_462

PrivilegeViol:
		move.b	#$E,(v_errortype).w
		bra.s	loc_462

Trace:
		move.b	#$10,(v_errortype).w
		bra.s	loc_462

Line1010Emu:
		move.b	#$12,(v_errortype).w
		addq.l	#2,2(sp)
		bra.s	loc_462

Line1111Emu:
		move.b	#$14,(v_errortype).w
		addq.l	#2,2(sp)
		bra.s	loc_462

ErrorExcept:
		move.b	#0,(v_errortype).w
		bra.s	loc_462
; ===========================================================================
loc_43A:
		move	#$2700,sr
		addq.w	#2,sp                  ; skip interrupt flags
		move.l	(sp)+,(v_spbuffer).w   ; value that caused the exception
		addq.w	#2,sp                  ; skip instruction register
		addq.w	#2,sp                  ; skip status register
		move.l	(sp)+,(v_pcbuffer).w   ; PC
		movem.l	d0-a7,(v_regbuffer).w
                move.b  #5,(v_levselpage).w
                jmp     Pause_Menu
; ===========================================================================

loc_462:
 		move	#$2700,sr
		movem.l	d0-a7,(v_regbuffer).w
		addq.w	#2,sp                  ; skip interrupt flags
		move.l	(sp)+,(v_spbuffer).w   ; value that caused the exception
	;	move.l	(a0),(v_pcbuffer).w    ; testing!!!! see what object is causing problems
                move.b  #5,(v_levselpage).w
                jmp     Pause_Menu


; loc_478:
; 		bsr.w	ErrorWaitForC
; 		movem.l	(v_regbuffer).w,d0-a7
; 		move	#$2300,sr
; 		rte	
; ;
; ; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; 
; 
; ShowErrorMessage:
; 		lea	($C00000).l,a6
; 		locVRAM	$F800
; 		lea	(Art_Text).l,a0
; 		move.w	#$27F,d1
; 	@loadgfx:
; 		move.w	(a0)+,(a6)
; 		dbf	d1,@loadgfx
; 
; 		moveq	#0,d0		; clear	d0
; 		move.b	(v_errortype).w,d0 ; load error code
; 		move.w	ErrorText(pc,d0.w),d0
; 		lea	ErrorText(pc,d0.w),a0
; 		locVRAM	(vram_fg+$604)
; 		moveq	#$12,d1		; number of characters (minus 1)
; 
; 	@showchars:
; 		moveq	#0,d0
; 		move.b	(a0)+,d0
; 		addi.w	#$790,d0
; 		move.w	d0,(a6)
; 		dbf	d1,@showchars	; repeat for number of characters
; 		rts	
; ; End of function ShowErrorMessage
; 
; ; ===========================================================================
; ErrorText:	dc.w @exception-ErrorText, @bus-ErrorText
; 		dc.w @address-ErrorText, @illinstruct-ErrorText
; 		dc.w @zerodivide-ErrorText, @chkinstruct-ErrorText
; 		dc.w @trapv-ErrorText, @privilege-ErrorText
; 		dc.w @trace-ErrorText, @line1010-ErrorText
; 		dc.w @line1111-ErrorText
; @exception:	dc.b "ERROR EXCEPTION    "
; @bus:		dc.b "BUS ERROR          "
; @address:	dc.b "ADDRESS ERROR      "
; @illinstruct:	dc.b "ILLEGAL INSTRUCTION"
; @zerodivide:	dc.b "@ERO DIVIDE        "
; @chkinstruct:	dc.b "CHK INSTRUCTION    "
; @trapv:		dc.b "TRAPV INSTRUCTION  "
; @privilege:	dc.b "PRIVILEGE VIOLATION"
; @trace:		dc.b "TRACE              "
; @line1010:	dc.b "LINE 1010 EMULATOR "
; @line1111:	dc.b "LINE 1111 EMULATOR "
; 		even
; 
; ; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; 
; 
; ShowErrorValue:
; 		move.w	#$7CA,(a6)	; display "$" symbol
; 		moveq	#7,d2
; 
; 	@loop:
; 		rol.l	#4,d0
; 		bsr.s	@shownumber	; display 8 numbers
; 		dbf	d2,@loop
; 		rts	
; ; End of function ShowErrorValue
; 
; 
; ; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; 
; 
; @shownumber:
; 		move.w	d0,d1
; 		andi.w	#$F,d1
; 		cmpi.w	#$A,d1
; 		bcs.s	@chars0to9
; 		addq.w	#7,d1		; add 7 for characters A-F
; 
; 	@chars0to9:
; 		addi.w	#$7C0,d1
; 		move.w	d1,(a6)
; 		rts	
; ; End of function sub_5CA
; 
; 
; ; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; 
; 
; ErrorWaitForC:				; XREF: loc_478
; 		bsr.w	ReadJoypads
; 		cmpi.b	#btnC,(v_jpadpress1).w ; is button C pressed?
; 		bne.w	ErrorWaitForC	; if not, branch
; 		rts
; ; End of function ErrorWaitForC
