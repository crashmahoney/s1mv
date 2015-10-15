; ---------------------------------------------------------------------------
; Subroutine to remember whether an object is destroyed/collected
; ---------------------------------------------------------------------------

RememberState:
		obRange	@offscreen
		bra.w	DisplaySprite

	@offscreen:
Mark_ChkGone:	                                ; MJ: +++ this was the symbol in the old disassembly
;                 obMarkGone
    if S3KObjectManager=1
        move.w	obRespawnNo(a0),d0		; get address in respawn table
	    beq.s	@dontremember			; if it's zero, don't remember object
	    movea.w	d0,a2	                ; load address into a2
	    bclr	#7,(a2)	                ; clear respawn table entry, so object can be loaded again
      @dontremember:
		bra.w	DeleteObject

        else
		lea	(v_objstate).w,a2       	; respawn table
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0      ; get respawn table slot number
		bclr	#7,2(a2,d0.w)           ; clear respawn table entry, so object can be loaded again
		bra.w	DeleteObject
        endif
