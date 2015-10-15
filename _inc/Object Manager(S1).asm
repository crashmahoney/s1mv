; ---------------------------------------------------------------------------
; Subroutine to	load a level's objects
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjPosLoad:				; XREF: GM_Level; et al
		moveq	#0,d0
		move.b	(v_opl_routine).w,d0
		move.w	OPL_Index(pc,d0.w),d0
		jmp	OPL_Index(pc,d0.w)
; End of function ObjPosLoad

; ===========================================================================
OPL_Index:	dc.w OPL_Main-OPL_Index
		dc.w OPL_Next-OPL_Index
; ===========================================================================

OPL_Main:				; XREF: OPL_Index
		addq.b	#2,(v_opl_routine).w
		move.w	(v_zone).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea	(ObjPos_Index).l,a0    ; load the first pointer in the object layout list pointer index,
		movea.l	a0,a1
		adda.w	(a0,d0.w),a0           ; load the pointer to the current object layout
		; initialize each object load address with the first object in the layout
                move.l	a0,(v_opl_data).w
		move.l	a0,(v_opl_data+4).w
		adda.w	2(a1,d0.w),a1
		move.l	a1,(v_opl_data+8).w
		move.l	a1,(v_opl_data+$C).w
		lea	(v_objstate).w,a2
		move.w	#$101,(a2)+     ; the first two bytes are not used as respawn values
                                        ; instead, they are used to keep track of the current respawn indexes
		move.w	#$5E,d0         ; set loop counter

OPL_ClrList:
		clr.l	(a2)+           ; loop clears all other respawn values
		dbf	d0,OPL_ClrList

		lea	(v_objstate).w,a2  ; reset a2
		moveq	#0,d2
		move.w	(v_screenposx).w,d6
		subi.w	#$80,d6                    ; look one chunk to the left
		bcc.s	@notneg                    ; if the result was negative,
		moveq	#0,d6                      ; cap at zero

@notneg:
		andi.w	#$FF80,d6                   ; limit to increments of $80 (width of a chunk)
		movea.l	(v_opl_data).w,a0           ; load address of object placement list

 	; at the beginning of a level this gives respawn table entries to any object that is one chunk
	; behind the left edge of the screen that needs to remember its state (Monitors, Badniks, etc.)
loc_D944:
		cmp.w	(a0),d6                     ; is object's x position >= d6?
		bls.s	loc_D956                    ; if yes, branch
		tst.b	4(a0)                       ; does the object get a respawn table entry?
		bpl.s	loc_D952                    ; if not, branch
		move.b	(a2),d2
		addq.b	#1,(a2)                     ; respawn index of next object to the right

loc_D952:
		addq.w	#6,a0                       ; get address of next object
		bra.s	loc_D944                    ; continue with next object
; ===========================================================================

loc_D956:
		move.l	a0,(v_opl_data).w          ; remember rightmost object that has been processed, so far (we still need to look forward)
		movea.l	(v_opl_data+4).w,a0        ; reset a0
		subi.w	#$80,d6                    ; look even farther left (any object behind this is out of range)
		bcs.s	loc_D976                   ; branch, if camera position would be behind level's left boundary

loc_D964:       ; count how many objects are behind the screen that are not in range and need to remember their state
		cmp.w	(a0),d6                    ; is object's x position >= d6?
		bls.s	loc_D976                   ; if yes, branch
		tst.b	4(a0)                      ; does the object get a respawn table entry?
		bpl.s	loc_D972                   ; if not, branch
		addq.b	#1,1(a2)                   ; respawn index of current object to the left

loc_D972:
		addq.w	#6,a0                      ; get address of next object
		bra.s	loc_D964                   ; continue with next object
; ===========================================================================

loc_D976:
		move.l	a0,(v_opl_data+4).w        ; remember current object from the left
		move.w	#-1,(v_opl_screen).w       ; make sure OPL_GoingForward is run

OPL_Next:				; XREF: OPL_Index
		lea	(v_objstate).w,a2
		moveq	#0,d2
		move.w	(v_screenposx).w,d6
		andi.w	#$FF80,d6                  ; round off to nearest $80 (chunk size)
		cmp.w	(v_opl_screen).w,d6        ; is the X range the same as last time?
		beq.w	OPL_SameXRange             ; if yes, branch
		bge.s	OPL_GoingForward           ; if new pos is greater than old pos, branch
		move.w	d6,(v_opl_screen).w        ; remember current position for next time
		movea.l	(v_opl_data+4).w,a0        ; get current object going left
		subi.w	#$80,d6                    ; look one chunk to the left
		bcs.s	loc_D9D2                   ; branch, if camera position would be behind level's left boundary

loc_D9A6:   ; load all objects left of the screen that are now in range
		cmp.w	-6(a0),d6                  ; is the previous object's X pos less than d6?
		bge.s	loc_D9D2                   ; if it is, branch
		subq.w	#6,a0                      ; get object's address
		tst.b	4(a0)                      ; does the object get a respawn table entry?
		bpl.s	@loadobject                ; if not, branch
		subq.b	#1,1(a2)                   ; respawn index of this object
		move.b	1(a2),d2

@loadobject:
		bsr.w	OPL_Chk_MakeItem           ; load object
		bne.s	@undoloadobject            ; branch, if SST is full
		subq.w	#6,a0
		bra.s	loc_D9A6                   ; continue with previous object
; ===========================================================================

@undoloadobject:       ; undo a few things, if the object couldn't load
		tst.b	4(a0)                      ; does the object get a respawn table entry?
		bpl.s	loc_D9D0                   ; if not, branch
		addq.b	#1,1(a2)                   ; since we didn't load the object, undo last change

loc_D9D0:
		addq.w	#6,a0                      ; go back to last object
; ===========================================================================

loc_D9D2:       ; going back part 2
		move.l	a0,(v_opl_data+4).w        ; remember current object going left
		movea.l	(v_opl_data).w,a0          ; get next object going right
		addi.w	#$300,d6                   ; look two chunks beyond the right edge of the screen

loc_D9DE:       ; subtract number of objects that have been moved out of range (from the right side)
		cmp.w	-6(a0),d6                  ; is the previous object's X pos less than d6?
		bgt.s	loc_D9F0                   ; if it is, branch
		tst.b	-2(a0)
		bpl.s	loc_D9EC
		subq.b	#1,(a2)

loc_D9EC:
		subq.w	#6,a0                      ; get object's address
		bra.s	loc_D9DE                   ; continue with previous object
; ===========================================================================

loc_D9F0:
		move.l	a0,(v_opl_data).w          ; remember next object going right
		rts	
; ===========================================================================

OPL_GoingForward:
		move.w	d6,(v_opl_screen).w        
		movea.l	(v_opl_data).w,a0          ; get next object from the right
		addi.w	#$280,d6                   ; look two chunks forward

loc_DA02:
		cmp.w	(a0),d6                    ; is object's x position >= d6?
		bls.s	OPL_GoingForward_Part2     ; if yes, branch
		tst.b	4(a0)                      ; does the object get a respawn table entry?
		bpl.s	loc_DA10                   ; if not, branch
		move.b	(a2),d2                    ; respawn index of this object
		addq.b	#1,(a2)                    ; respawn index of next object to the right

loc_DA10:
		bsr.w	OPL_Chk_MakeItem           ; load object (and get address of next object)
		beq.s	loc_DA02                   ; continue loading objects, if the SST isn't full

OPL_GoingForward_Part2:
		move.l	a0,(v_opl_data).w         ; remember next object from the right
		movea.l	(v_opl_data+4).w,a0       ; get current object from the left
		subi.w	#$300,d6                  ; look one chunk behind the left edge of the screen
		bcs.s	loc_DA36                  ; branch, if camera position would be behind level's left boundary

loc_DA24:       ; subtract number of objects that have been moved out of range (from the left)
		cmp.w	(a0),d6                   ; is object's x position >= d6?
		bls.s	loc_DA36                  ; if yes, branch
		tst.b	4(a0)                     ; does the object get a respawn table entry?
		bpl.s	loc_DA32                  ; if not, branch
		addq.b	#1,1(a2)                  ; respawn index of next object to the left

loc_DA32:
		addq.w	#6,a0
		bra.s	loc_DA24                  ; continue with previous object
; ===========================================================================

loc_DA36:
		move.l	a0,(v_opl_data+4).w       ; remember current object from the left

OPL_SameXRange:
		rts	
; ===========================================================================

OPL_Chk_MakeItem:
		tst.b	4(a0)                    ; does the object get a respawn table entry?
		bpl.s	OPL_MakeItem             ; if not, branch
		bset	#7,2(a2,d2.w)            ; mark object as loaded
		beq.s	OPL_MakeItem             ; branch if it wasn't already loaded
		addq.w	#6,a0                    ; next object
		moveq	#0,d0                    ; let the objects manager know that it can keep going
		rts	
; ===========================================================================

OPL_MakeItem:
		bsr.w	FindFreeObj              ; find empty slot
		bne.s	locret_DA8A              ; branch, if there is no room left in the SST
		move.w	(a0)+,obX(a1)
		move.w	(a0)+,d0
		move.w	d0,d1                    ; copy for later
		andi.w	#$FFF,d0                 ; get y-position
		move.w	d0,obY(a1)
		rol.w	#2,d1                    ; adjust bits
		andi.b	#3,d1                    ; get render flags
		move.b	d1,obRender(a1)
		move.b	d1,obStatus(a1)
		move.b	(a0)+,d0
		bpl.s	loc_DA80                 ; branch, if the object doesn't get a respawn table entry
		andi.b	#$7F,d0                  ; get correct object number
		move.b	d2,obRespawnNo(a1)       ; set respawn index

loc_DA80:
		move.b	d0,0(a1)                 ; load obj
		move.b	(a0)+,obSubtype(a1)
		moveq	#0,d0

locret_DA8A:
		rts	