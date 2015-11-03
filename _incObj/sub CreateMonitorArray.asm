; put monitor x positions into an array for the monitor code to use to figure out if it's broken or not
; this is super unoptimized because there are extra checks to play sfx to let you know that there's a problem with the level layout
CreateMonitorArray:
		move.w	(v_zone).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea		(ObjPos_Index).l,a0    ; load the first pointer in the object layout list pointer index,
		adda.w	(a0,d0.w),a0           ; load the pointer to the current object layout
		lea     (v_monitorlocations).w,a1
		moveq   #23,d0                 ; 24 max monitors
	@loop:
		cmp.w   #$FFFF,(a0)            ; end of object list?
		beq.w   @end
		cmp.b   #$26,4(a0)             ; is this object a monitor?
		bne.s   @nextobject
		move.w  (a0),d1
		cmp.w   -2(a1),d1              ; is this monitor's x position the same as the last one added to the list?
		bne.s   @addtolist
		sfx     sfx_Teleport           ; play a sound to signify that 2 monitors have the same x position
	@addtolist:
		move.w  (a0),(a1)+             ; put object's location into list
		addq.w	#6,a0                  ; next object
		dbf     d0,@loop
		sfx     sfx_SSGoal             ; play a sound to signify that there are too many monitors in this level
		bra.s   @end
	@nextobject:
		addq.w	#6,a0                  ; next object
		bra.s   @loop
	@end:
		rts