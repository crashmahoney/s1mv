; ---------------------------------------------------------------------------
; Align and pad
; input: length to align to, value to use as padding (default is 0)
; ---------------------------------------------------------------------------

align:	macro
	if (narg=1)
	dcb.b \1-(*%\1),0
	else
	dcb.b \1-(*%\1),\2
	endc
	endm

; ---------------------------------------------------------------------------
; Set a VRAM address via the VDP control port.
; input: 16-bit VRAM address, control port (default is ($C00004).l)
; ---------------------------------------------------------------------------

locVRAM:	macro loc,controlport
		if (narg=1)
		move.l	#($40000000+((loc&$3FFF)<<16)+((loc&$C000)>>14)),($C00004).l
		else
		move.l	#($40000000+((loc&$3FFF)<<16)+((loc&$C000)>>14)),controlport
		endc
		endm

; ---------------------------------------------------------------------------
; Set a VRAM address via the VDP control port.
; input: 16-bit VRAM address, control port (default is ($C00004).l)
; ---------------------------------------------------------------------------

locVRAMread:	macro loc,controlport
		if (narg=1)
		move.l	#($00000000+((loc&$3FFF)<<16)+((loc&$C000)>>14)),($C00004).l
		else
		move.l	#($00000000+((loc&$3FFF)<<16)+((loc&$C000)>>14)),controlport
		endc
		endm
; ---------------------------------------------------------------------------
; DMA copy data from 68K (ROM/RAM) to the VRAM
; input: source, length, destination
; ---------------------------------------------------------------------------

writeVRAM:	macro
		lea	($C00004).l,a5
		move.l	#$94000000+(((\2>>1)&$FF00)<<8)+$9300+((\2>>1)&$FF),(a5)
		move.l	#$96000000+(((\1>>1)&$FF00)<<8)+$9500+((\1>>1)&$FF),(a5)
		move.w	#$9700+((((\1>>1)&$FF0000)>>16)&$7F),(a5)
		move.w	#$4000+(\3&$3FFF),(a5)
		move.w	#$80+((\3&$C000)>>14),(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		endm

; ---------------------------------------------------------------------------
; DMA copy data from 68K (ROM/RAM) to the CRAM
; input: source, length, destination
; ---------------------------------------------------------------------------

writeCRAM:	macro
		lea	($C00004).l,a5
		move.l	#$94000000+(((\2>>1)&$FF00)<<8)+$9300+((\2>>1)&$FF),(a5)
		move.l	#$96000000+(((\1>>1)&$FF00)<<8)+$9500+((\1>>1)&$FF),(a5)
		move.w	#$9700+((((\1>>1)&$FF0000)>>16)&$7F),(a5)
		move.w	#$C000+(\3&$3FFF),(a5)
		move.w	#$80+((\3&$C000)>>14),(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		endm

; ---------------------------------------------------------------------------
; DMA fill VRAM with a value
; input: value, length, destination
; ---------------------------------------------------------------------------

fillVRAM:	macro value,length,loc
		lea	($C00004).l,a5
		move.w	#$8F01,(a5)
		move.l	#$94000000+((length&$FF00)<<8)+$9300+(length&$FF),(a5)
		move.w	#$9780,(a5)
		move.l	#$40000080+((loc&$3FFF)<<16)+((loc&$C000)>>14),(a5)
		move.w	#value,($C00000).l
		endm

; ---------------------------------------------------------------------------
; Copy a tilemap from 68K (ROM/RAM) to the VRAM without using DMA
; input: source, destination, width [cells], height [cells]
; ---------------------------------------------------------------------------

copyTilemap:	macro source,loc,width,height
		lea	(source).l,a1
		move.l	#$40000000+((loc&$3FFF)<<16)+((loc&$C000)>>14),d0
		moveq	#width,d1
		moveq	#height,d2
		jsr	TilemapToVRAM
		endm

; ---------------------------------------------------------------------------
; stop the Z80
; ---------------------------------------------------------------------------

stopZ80:	macro
		move.w	#$100,($A11100).l
		endm

; ---------------------------------------------------------------------------
; wait for Z80 to stop
; ---------------------------------------------------------------------------

waitZ80:	macro
	@wait:	btst	#0,($A11100).l
		bne.s	@wait
		endm

; ---------------------------------------------------------------------------
; reset the Z80
; ---------------------------------------------------------------------------

resetZ80:	macro
		move.w	#$100,($A11200).l
		endm

resetZ80a:	macro
		move.w	#0,($A11200).l
		endm

; ---------------------------------------------------------------------------
; start the Z80
; ---------------------------------------------------------------------------

startZ80:	macro
		move.w	#0,($A11100).l
		endm

; ---------------------------------------------------------------------------
; check if object moves out of range
; input: location to jump to if out of range, x-axis pos (obX(a0) by default)
; ---------------------------------------------------------------------------

obRange:	macro exit,pos
		if (narg=2)
		move.w	pos,d0		; get object position (if specified as not obX)
		else
		move.w	obX(a0),d0	; get object position
		endc
		andi.w	#$FF80,d0	; round down to nearest $80
		move.w	(v_screenposx).w,d1 ; get screen position
		subi.w	#128,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#128+320+192,d0
		bhi.w	exit		; if object moves out of range, branch
		endm

obRanges:	macro exit,pos
		if (narg=2)
		move.w	pos,d0		; get object position (if specified as not obX)
		else
		move.w	obX(a0),d0	; get object position
		endc
		andi.w	#$FF80,d0	; round down to nearest $80
		move.w	(v_screenposx).w,d1 ; get screen position
		subi.w	#128,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#128+320+192,d0
		bhi.s	exit		; if object moves out of range, branch
		endm

; ---------------------------------------------------------------------------
; change an objects status in the respawn table
; ---------------------------------------------------------------------------

obMarkGone      macro
        if S3KObjectManager=1
		moveq	#0,d0
                move.w	obRespawnNo(a0),d0	; get address in respawn table
	        beq.s	@dontremember		; if it's zero, don't remember object
	        movea.w	d0,a2	; load address into a2
	        bclr	#7,(a2)	; clear respawn table entry, so object can be loaded again           
            @dontremember:

        else
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		bclr	#7,2(a2,d0.w)
        endif
                endm
; ===========================================================================

obSetBit        macro bit
        if S3KObjectManager=1
		moveq	#0,d0
                move.w	obRespawnNo(a0),d0
	        movea.w	d0,a2	; load address into a2
	        bset	#bit,(a2)	        ; set required bit in respawn table
	else
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		bset	#bit,2(a2,d0.w)
        endif
                endm
; ===========================================================================
obTestBit        macro bit
        if S3KObjectManager=1
		moveq	#0,d0
                move.w	obRespawnNo(a0),d0
	        movea.w	d0,a2	; load address into a2
	        btst	#bit,(a2)	        ; set required bit in respawn table
	else
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		btst	#bit,2(a2,d0.w)
        endif
                endm

; ---------------------------------------------------------------------------
; play a sound effect or music
; input: track, terminate routine (leave blank to not terminate)
; ---------------------------------------------------------------------------

music:		macro track,terminate
		move.w	#track,d0
		if (narg=1)
		jsr	(PlaySound).l
		else
		jmp	(PlaySound).l
		endc
		endm

sfx:		macro track,terminate
		move.w	#track,d0
		if (narg=1)
		jsr	(PlaySound_Special).l
		else
		jmp	(PlaySound_Special).l
		endc
		endm

; ---------------------------------------------------------------------------
; bankswitch between SRAM and ROM
; (remember to enable SRAM in the header first!)
; ---------------------------------------------------------------------------

gotoSRAM:	macro
		move.b  #1,($A130F1).l
		endm

gotoROM:	macro
		move.b  #0,($A130F1).l
		endm

; ---------------------------------------------------------------------------
; Store a VRAM address in d0
; input: 16-bit VRAM address
; ---------------------------------------------------------------------------

locVRAMd0:	macro loc
		move.l	#($40000000+((loc&$3FFF)<<16)+((loc&$C000)>>14)),d0
		endm

; ---------------------------------------------------------------------------
; SpriteMap macro usage
; l = left coordinate
; t = top coordinate
; w = width (in tiles)
; h = height (in tiles)
; x = horizontal mirroring 1=yes 0=no
; y = vertical mirroring 1=yes 0=no
; pri = priority 1=always on top
; pal = palette index (0...3)
; ind = starting tile index
; ---------------------------------------------------------------------------

SpriteMap:	macro	l, t, w, h, x, y, pri, pal, ind
		dc.b	t
		dc.b	(h-1)|((w-1)<<2)
		dc.b	(pri<<7)|(pal<<5)|(y<<4)|(x<<3)|(ind>>8)
		dc.b	ind&0xFF
		dc.b	l
		endm

; ---------------------------------------------------------------------------
; DynPLC macro usage
; n = number of tiles
; i = starting tile index
; o = offset (optional), i.e. Art_SonicSpinDash-Art_Sonic
; ---------------------------------------------------------------------------

DynPLC:		macro	n, i, o
		if (narg=2)
		dc.b	((n-1)<<4)|(i>>8)
		dc.b	i&$FF
		else
		dc.b	((n-1)<<4)|((i+((o)>>5))>>8)
		dc.b	(i+((o)>>5))&$FF
		endc
		endm
		
; macro to move the absolute value of the source in the destination
mvabs	macro ;source, destination
	move.\0	\1,\2
	bpl.s	@\@skip
	neg.\0	\2
@\@skip:
    endm


; this instruction is basically 2 nops, except it affects cc too and is 2 bytes shorter
ctrl_delay	macro
	or.l	d0,d0
	endm    
