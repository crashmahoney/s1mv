; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; ---------------------------------------------------------------------------
; KOSINSKI DECOMPRESSION PROCEDURE
; (sometimes called KOZINSKI decompression)

; This is the only procedure in the game that stores variables on the stack.

; ARGUMENTS:
; a0 = source address
; a1 = destination address

; For format explanation see http://info.sonicretro.org/Kosinski_compression
; New faster version by written by vladikcomper, with additional improvements by
; MarkeyJester and Flamewing
; ---------------------------------------------------------------------------
KosDec_UseLUT = 1
KosDec_LoopUnroll = 3

_Kos_RunBitStream macro
	dbf	d2,_skip\@
	moveq	#7,d2					; Set repeat count to 8.
	move.b	d1,d0					; Use the remaining 8 bits.
	swap	d3					; Have all 16 bits been used up?
	bpl.s	_skip\@					; Branch if not.
	move.b	(a0)+,d0				; Get desc field low-byte.
	move.b	(a0)+,d1				; Get desc field hi-byte.
	if (KosDec_UseLUT=1)
	move.b	(a4,d0.w),d0			; Invert bit order...
	move.b	(a4,d1.w),d1			; ... for both bytes.
	endif
_skip\@ EQU     *
	endm

_Kos_ReadBit macro
	if (KosDec_UseLUT=1)
	add.b	d0,d0					; Get a bit from the bitstream.
	else
	lsr.b	#1,d0					; Get a bit from the bitstream.
	endif
	endm
; ===========================================================================
; KozDec_193A:
KosDec:
	moveq	#(1<<KosDec_LoopUnroll)-1,d7
	if (KosDec_UseLUT=1)
	moveq	#0,d0
	moveq	#0,d1
	lea	KosDec_ByteMap(pc),a4		; Load LUT pointer.
	endif
	move.b	(a0)+,d0				; Get desc field low-byte.
	move.b	(a0)+,d1				; Get desc field hi-byte.
	if (KosDec_UseLUT=1)
	move.b	(a4,d0.w),d0			; Invert bit order...
	move.b	(a4,d1.w),d1			; ... for both bytes.
	endif
	moveq	#7,d2					; Set repeat count to 8.
	moveq	#-1,d3					; d3 will be desc field switcher.
	clr.w	d3						; Low word is zero.
	bra.s	KosDec_FetchNewCode

KosDec_FetchCodeLoop:
	; Code 1 (Uncompressed byte).
	_Kos_RunBitStream
	move.b	(a0)+,(a1)+

KosDec_FetchNewCode:
	_Kos_ReadBit
	bcs.s	KosDec_FetchCodeLoop	; If code = 0, branch.

	; Codes 00 and 01.
	_Kos_RunBitStream
	moveq	#0,d4					; d4 will contain copy count.
	_Kos_ReadBit
	bcs.s	KosDec_Code_01

	; Code 00 (Dictionary ref. short).
	_Kos_RunBitStream
	_Kos_ReadBit
	addx.w	d4,d4
	_Kos_RunBitStream
	_Kos_ReadBit
	addx.w	d4,d4
	_Kos_RunBitStream
	moveq	#-1,d5
	move.b	(a0)+,d5				; d5 = displacement.

KosDec_StreamCopy:
	lea	(a1,d5),a3
	move.b	(a3)+,(a1)+		; Do 1 extra copy (to compensate +1 to copy counter).

KosDec_copy:
	move.b	(a3)+,(a1)+
	dbf	d4,KosDec_copy
	bra.w	KosDec_FetchNewCode
; ---------------------------------------------------------------------------
KosDec_Code_01:
	; Code 01 (Dictionary ref. long / special).
	_Kos_RunBitStream
	move.b	(a0)+,d6				; d6 = %LLLLLLLL.
	move.b	(a0)+,d4				; d4 = %HHHHHCCC.
	moveq	#-1,d5
	move.b	d4,d5					; d5 = %11111111 HHHHHCCC.
	lsl.w	#5,d5					; d5 = %111HHHHH CCC00000.
	move.b	d6,d5					; d5 = %111HHHHH LLLLLLLL.
	if (KosDec_LoopUnroll=3)
	and.w	d7,d4					; d4 = %00000CCC.
	else
	andi.w	#7,d4
	endif
	bne.s	KosDec_StreamCopy		; if CCC=0, branch.

	; special mode (extended counter)
	move.b	(a0)+,d4				; Read cnt
	beq.s	KosDec_Quit				; If cnt=0, quit decompression.
	subq.b	#1,d4
	beq.w	KosDec_FetchNewCode		; If cnt=1, fetch a new code.

	lea	(a1,d5),a3
	move.b	(a3)+,(a1)+				; Do 1 extra copy (to compensate +1 to copy counter).
	move.w	d4,d6
	not.w	d6
	and.w	d7,d6
	add.w	d6,d6
	lsr.w	#KosDec_LoopUnroll,d4
	jmp	KosDec_largecopy(pc,d6.w)

KosDec_largecopy:
;	rept (1<<KosDec_LoopUnroll)
	move.b	(a3)+,(a1)+
	move.b	(a3)+,(a1)+
	move.b	(a3)+,(a1)+
	move.b	(a3)+,(a1)+
	move.b	(a3)+,(a1)+
	move.b	(a3)+,(a1)+
	move.b	(a3)+,(a1)+
	move.b	(a3)+,(a1)+
;	endm
	dbf	d4,KosDec_largecopy
	bra.w	KosDec_FetchNewCode

KosDec_Quit:
	rts								; End of function KosDec.
; ===========================================================================
	if (KosDec_UseLUT=1)
KosDec_ByteMap:
	dc.b	$00,$80,$40,$C0,$20,$A0,$60,$E0,$10,$90,$50,$D0,$30,$B0,$70,$F0
	dc.b	$08,$88,$48,$C8,$28,$A8,$68,$E8,$18,$98,$58,$D8,$38,$B8,$78,$F8
	dc.b	$04,$84,$44,$C4,$24,$A4,$64,$E4,$14,$94,$54,$D4,$34,$B4,$74,$F4
	dc.b	$0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC,$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
	dc.b	$02,$82,$42,$C2,$22,$A2,$62,$E2,$12,$92,$52,$D2,$32,$B2,$72,$F2
	dc.b	$0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA,$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
	dc.b	$06,$86,$46,$C6,$26,$A6,$66,$E6,$16,$96,$56,$D6,$36,$B6,$76,$F6
	dc.b	$0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE,$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
	dc.b	$01,$81,$41,$C1,$21,$A1,$61,$E1,$11,$91,$51,$D1,$31,$B1,$71,$F1
	dc.b	$09,$89,$49,$C9,$29,$A9,$69,$E9,$19,$99,$59,$D9,$39,$B9,$79,$F9
	dc.b	$05,$85,$45,$C5,$25,$A5,$65,$E5,$15,$95,$55,$D5,$35,$B5,$75,$F5
	dc.b	$0D,$8D,$4D,$CD,$2D,$AD,$6D,$ED,$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
	dc.b	$03,$83,$43,$C3,$23,$A3,$63,$E3,$13,$93,$53,$D3,$33,$B3,$73,$F3
	dc.b	$0B,$8B,$4B,$CB,$2B,$AB,$6B,$EB,$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
	dc.b	$07,$87,$47,$C7,$27,$A7,$67,$E7,$17,$97,$57,$D7,$37,$B7,$77,$F7
	dc.b	$0F,$8F,$4F,$CF,$2F,$AF,$6F,$EF,$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF
	endif
; ===========================================================================



; ---------------------------------------------------------------------------
; Adds a Kosinski Moduled archive to the module queue
; Inputs:
; a1 = address of the archive
; d2 = destination in VRAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================


Queue_Kos_Module:
		lea	(Kos_module_queue).w,a2
		tst.l	(a2)	; is the first slot free?
		beq.s	Process_Kos_Module_Queue_Init	; if it is, branch
		addq.w	#6,a2	; otherwise, check next slot

@findFreeSlot:
		tst.l	(a2)
		beq.s	@freeSlotFound
		addq.w	#6,a2
		bra.s	@findFreeSlot
; ---------------------------------------------------------------------------

@freeSlotFound:
		move.l	a1,(a2)+	; store source address
		move.w	d2,(a2)+	; store destination VRAM address
		rts
; End of function Queue_Kos_Module

; ---------------------------------------------------------------------------
; Initializes processing of the first module on the queue
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================


Process_Kos_Module_Queue_Init:
		move.w	(a1)+,d3	; get uncompressed size
		cmpi.w	#$A000,d3
		bne.s	@notA000
		move.w	#$8000,d3	; $A000 means $8000 for some reason
@notA000:
		lsr.w	#1,d3
		move.w	d3,d0
		rol.w	#5,d0
		andi.w	#$1F,d0	; get number of complete modules
		move.b	d0,(Kos_modules_left).w
		andi.l	#$7FF,d3	; get size of last module in words
		bne.s	@nonzero	; branch if it's non-zero
		subq.b	#1,(Kos_modules_left).w	; otherwise decrement the number of modules
		move.l	#$800,d3	; and take the size of the last module to be $800 words
@nonzero:
		move.w	d3,(Kos_last_module_size).w
		move.w	d2,(Kos_module_destination).w
		move.l	a1,(Kos_module_queue).w
		addq.b	#1,(Kos_modules_left).w	; store total number of modules
		rts
; End of function Process_Kos_Module_Queue_Init

; ---------------------------------------------------------------------------
; Processes the first module on the queue
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================


Process_Kos_Module_Queue:
		tst.b	(Kos_modules_left).w
		bne.s	@modulesLeft

@done:
		rts
; ---------------------------------------------------------------------------

@modulesLeft:
		bmi.s	@decompressionStarted
		cmpi.w	#4,(Kos_decomp_queue_count).w
		bcc.s	@done	; branch if the Kosinski decompression queue is full
		movea.l	(Kos_module_queue).w,a1
		lea	(Kos_decomp_buffer).w,a2
		bsr.w	Queue_Kos	; add current module to decompression queue
		ori.b	#$80,(Kos_modules_left).w	; and set bit to signify decompression in progress
		rts
; ---------------------------------------------------------------------------

@decompressionStarted:
		tst.w	(Kos_decomp_queue_count).w
		bne.s	@done	; branch if the decompression isn't complete

		; otherwise, DMA the decompressed data to VRAM
		andi.b	#$7F,(Kos_modules_left).w
		move.l	#$800,d3
		subq.b	#1,(Kos_modules_left).w
		bne.s	@notlast	; branch if it isn't the last module
		move.w	(Kos_last_module_size).w,d3
@notlast:
		move.w	(Kos_module_destination).w,d2
		move.w	d2,d0
		add.w	d3,d0
		add.w	d3,d0
		move.w	d0,(Kos_module_destination).w	; set new destination
		move.l	(Kos_module_queue).w,d0
		move.l	(Kos_decomp_queue).w,d1
		sub.l	d1,d0
		andi.l	#$F,d0
		add.l	d0,d1	; round to the nearest $10 boundary
		move.l	d1,(Kos_module_queue).w	; and set new source
		move.l	#Kos_decomp_buffer,d1
		andi.l	#$FFFFFF,d1
		jsr	(QueueDMATransfer).l
		tst.b	(Kos_modules_left).w
		bne.s	@rts	; return if this wasn't the last module
		lea	(Kos_module_queue).w,a0
		lea	(Kos_module_queue+6).w,a1
		move.l	(a1)+,(a0)+	; otherwise, shift all entries up
		move.w	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.l	#0,(a0)+	; and mark the last slot as free
		move.w	#0,(a0)+
		move.l	(Kos_module_queue).w,d0
		beq.s	@rts	; return if the queue is now empty
		movea.l	d0,a1
		move.w	(Kos_module_destination).w,d2
		jmp	(Process_Kos_Module_Queue_Init).l
@rts:
		rts
; End of function Process_Kos_Module_Queue

; ---------------------------------------------------------------------------
; Adds Kosinski-compressed data to the decompression queue
; Inputs:
; a1 = compressed data address
; a2 = decompression destination in RAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================


Queue_Kos:
		move.w	(Kos_decomp_queue_count).w,d0
		lsl.w	#3,d0
		lea	(Kos_decomp_queue).w,a3
		move.l	a1,(a3,d0.w)	; store source
		move.l	a2,4(a3,d0.w)	; store destination
		addq.w	#1,(Kos_decomp_queue_count).w
		rts
; End of function Queue_Kos

; ---------------------------------------------------------------------------
; Checks if V-int occured in the middle of Kosinski queue processing
; and stores the location from which processing is to resume if it did
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================


Set_Kos_Bookmark:
		tst.w	(Kos_decomp_queue_count).w
		bpl.s	@rts	; branch if a decompression wasn't in progress
		move.l	$42(sp),d0	; check address V-int is supposed to rte to
		cmpi.l	#Process_Kos_Queue_Main,d0
		bcs.s	@rts
		cmpi.l	#Process_Kos_Queue_Done,d0
		bcc.s	@rts
		move.l	$42(sp),(Kos_decomp_bookmark).w
		move.l	#Backup_Kos_Registers,$42(sp)	; force V-int to rte here instead if needed
@rts:
		rts
; End of function Set_Kos_Bookmark

; ---------------------------------------------------------------------------
; Processes the first entry in the Kosinski decompression queue
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================


Process_Kos_Queue:
		tst.w	(Kos_decomp_queue_count).w
		beq.w	Process_Kos_Queue_Done
		bmi.w	Restore_Kos_Bookmark	; branch if a decompression was interrupted by V-int

Process_Kos_Queue_Main:
		ori.w	#$8000,(Kos_decomp_queue_count).w	; set sign bit to signify decompression in progress
		movea.l	(Kos_decomp_queue).w,a0
		movea.l	(Kos_decomp_destination).w,a1

		; what follows is identical to the normal Kosinski decompressor except for using Kos_description_field instead of the stack
		lea	(Kos_description_field).w,a2
		move.b	(a0)+,1(a2)
		move.b	(a0)+,(a2)
		move.w	(a2),d5
		moveq	#$F,d4

Process_Kos_Queue_Loop:
		lsr.w	#1,d5
		move	sr,d6
		dbf	d4,Process_Kos_Queue_ChkBit
		move.b	(a0)+,1(a2)
		move.b	(a0)+,(a2)
		move.w	(a2),d5
		moveq	#$F,d4

Process_Kos_Queue_ChkBit:
		move	d6,ccr
		bcc.s	Process_Kos_Queue_RLE
		move.b	(a0)+,(a1)+
		bra.s	Process_Kos_Queue_Loop
; ---------------------------------------------------------------------------

Process_Kos_Queue_RLE:
		moveq	#0,d3
		lsr.w	#1,d5
		move	sr,d6
		dbf	d4,Process_Kos_Queue_ChkBit2
		move.b	(a0)+,1(a2)
		move.b	(a0)+,(a2)
		move.w	(a2),d5
		moveq	#$F,d4

Process_Kos_Queue_ChkBit2:
		move	d6,ccr
		bcs.s	Process_Kos_Queue_SeparateRLE
		lsr.w	#1,d5
		dbf	d4,@loop1
		move.b	(a0)+,1(a2)
		move.b	(a0)+,(a2)
		move.w	(a2),d5
		moveq	#$F,d4
	@loop1:
		roxl.w	#1,d3
		lsr.w	#1,d5
		dbf	d4,@loop2
		move.b	(a0)+,1(a2)
		move.b	(a0)+,(a2)
		move.w	(a2),d5
		moveq	#$F,d4
	@loop2:
		roxl.w	#1,d3
		addq.w	#1,d3
		moveq	#-1,d2
		move.b	(a0)+,d2
		bra.s	Process_Kos_Queue_RLELoop
; ---------------------------------------------------------------------------

Process_Kos_Queue_SeparateRLE:
		move.b	(a0)+,d0
		move.b	(a0)+,d1
		moveq	#-1,d2
		move.b	d1,d2
		lsl.w	#5,d2
		move.b	d0,d2
		andi.w	#7,d1
		beq.s	Process_Kos_Queue_SeparateRLE2
		move.b	d1,d3
		addq.w	#1,d3

Process_Kos_Queue_RLELoop:
		move.b	(a1,d2.w),d0
		move.b	d0,(a1)+
		dbf	d3,Process_Kos_Queue_RLELoop
		bra.s	Process_Kos_Queue_Loop
; ---------------------------------------------------------------------------

Process_Kos_Queue_SeparateRLE2:
		move.b	(a0)+,d1
		beq.s	Process_Kos_Queue_EndReached
		cmpi.b	#1,d1
		beq.w	Process_Kos_Queue_Loop
		move.b	d1,d3
		bra.s	Process_Kos_Queue_RLELoop
; 		; what follows is identical to the normal Kosinski decompressor except for using Kos_description_field instead of the stack
; 	moveq	#(1<<KosDec_LoopUnroll)-1,d7
; 	if (KosDec_UseLUT=1)
; 	moveq	#0,d0
; 	moveq	#0,d1
; 	lea	KosDec_ByteMap(pc),a4		; Load LUT pointer.
; 	endif
; 	move.b	(a0)+,d0				; Get desc field low-byte.
; 	move.b	(a0)+,d1				; Get desc field hi-byte.
; 	if (KosDec_UseLUT=1)
; 	move.b	(a4,d0.w),d0			; Invert bit order...
; 	move.b	(a4,d1.w),d1			; ... for both bytes.
; 	endif
; 	moveq	#7,d2					; Set repeat count to 8.
; 	moveq	#-1,d3					; d3 will be desc field switcher.
; 	clr.w	d3						; Low word is zero.
; 	bra.s	Process_Kos_Queue_FetchNewCode
; 
; Process_Kos_Queue_FetchCodeLoop:
; 	; Code 1 (Uncompressed byte).
; 	_Kos_RunBitStream
; 	move.b	(a0)+,(a1)+
; 
; Process_Kos_Queue_FetchNewCode:
; 	_Kos_ReadBit
; 	bcs.s	Process_Kos_Queue_FetchCodeLoop	; If code = 0, branch.
; 
; 	; Codes 00 and 01.
; 	_Kos_RunBitStream
; 	moveq	#0,d4					; d4 will contain copy count.
; 	_Kos_ReadBit
; 	bcs.s	Process_Kos_Queue_Code_01
; 
; 	; Code 00 (Dictionary ref. short).
; 	_Kos_RunBitStream
; 	_Kos_ReadBit
; 	addx.w	d4,d4
; 	_Kos_RunBitStream
; 	_Kos_ReadBit
; 	addx.w	d4,d4
; 	_Kos_RunBitStream
; 	moveq	#-1,d5
; 	move.b	(a0)+,d5				; d5 = displacement.
; 
; Process_Kos_Queue_StreamCopy:
; 	lea	(a1,d5),a3
; 	move.b	(a3)+,(a1)+		; Do 1 extra copy (to compensate +1 to copy counter).
; 
; Process_Kos_Queue_copy:
; 	move.b	(a3)+,(a1)+
; 	dbf	d4,Process_Kos_Queue_copy
; 	bra.w	Process_Kos_Queue_FetchNewCode
; ; ---------------------------------------------------------------------------
; Process_Kos_Queue_Code_01:
; 	; Code 01 (Dictionary ref. long / special).
; 	_Kos_RunBitStream
; 	move.b	(a0)+,d6				; d6 = %LLLLLLLL.
; 	move.b	(a0)+,d4				; d4 = %HHHHHCCC.
; 	moveq	#-1,d5
; 	move.b	d4,d5					; d5 = %11111111 HHHHHCCC.
; 	lsl.w	#5,d5					; d5 = %111HHHHH CCC00000.
; 	move.b	d6,d5					; d5 = %111HHHHH LLLLLLLL.
; 	if (KosDec_LoopUnroll=3)
; 	and.w	d7,d4					; d4 = %00000CCC.
; 	else
; 	andi.w	#7,d4
; 	endif
; 	bne.s	Process_Kos_Queue_StreamCopy		; if CCC=0, branch.
; 
; 	; special mode (extended counter)
; 	move.b	(a0)+,d4				; Read cnt
; 	beq.s	Process_Kos_Queue_EndReached				; If cnt=0, quit decompression.
; 	subq.b	#1,d4
; 	beq.w	Process_Kos_Queue_FetchNewCode		; If cnt=1, fetch a new code.
; 
; 	lea	(a1,d5),a3
; 	move.b	(a3)+,(a1)+				; Do 1 extra copy (to compensate +1 to copy counter).
; 	move.w	d4,d6
; 	not.w	d6
; 	and.w	d7,d6
; 	add.w	d6,d6
; 	lsr.w	#KosDec_LoopUnroll,d4
; 	jmp	Process_Kos_Queue_largecopy(pc,d6.w)
; 
; Process_Kos_Queue_largecopy:
; ;	rept (1<<KosDec_LoopUnroll)
; 	move.b	(a3)+,(a1)+
; 	move.b	(a3)+,(a1)+
; 	move.b	(a3)+,(a1)+
; 	move.b	(a3)+,(a1)+
; 	move.b	(a3)+,(a1)+
; 	move.b	(a3)+,(a1)+
; 	move.b	(a3)+,(a1)+
; 	move.b	(a3)+,(a1)+
; ;	endm
; 	dbf	d4,Process_Kos_Queue_largecopy
; 	bra.w	Process_Kos_Queue_FetchNewCode
; ---------------------------------------------------------------------------

Process_Kos_Queue_EndReached:
		move.l	a0,(Kos_decomp_queue).w
		move.l	a1,(Kos_decomp_destination).w
		andi.w	#$7FFF,(Kos_decomp_queue_count).w	; clear decompression in progress bit
		subq.w	#1,(Kos_decomp_queue_count).w
		beq.s	Process_Kos_Queue_Done	; branch if there aren't any entries remaining in the queue
		lea	(Kos_decomp_queue).w,a0
		lea	(Kos_decomp_queue+8).w,a1	; otherwise, shift all entries up
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+

Process_Kos_Queue_Done:
		rts
; ---------------------------------------------------------------------------

Restore_Kos_Bookmark:
		movem.l	(Kos_decomp_stored_registers).w,d0-d6/a0-a2        ; the optimised version of kosdec uses more registers, i'll need to save more here to get it working
		move.l	(Kos_decomp_bookmark).w,-(sp)
		move.w	(Kos_decomp_stored_SR).w,-(sp)
		rte
; ---------------------------------------------------------------------------

Backup_Kos_Registers:
		move	sr,(Kos_decomp_stored_SR).w
		movem.l	d0-d6/a0-a2,(Kos_decomp_stored_registers).w
		rts
; End of function Process_Kos_Queue


