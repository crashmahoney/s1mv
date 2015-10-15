; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to destroy all enemies/monitors/etc on screen  (Thanks to MarkeyJester)
; ---------------------------------------------------------------------------

DestroyEnemies:
		lea	($FFFFD800).w,a1			; load start of level object ram
		moveq	#$5F,d6					; set repeat times

DE_CheckNext:
		tst.b	(a1)					; is the object valid?
		beq	DE_NextObject				; if not, branch
		lea	DE_BossList(pc),a2			; load start of boss ID list
		bra	DE_CheckBoss				; continue

DE_NoEndList:
		cmp.b	(a1),d0					; is it a boss?
		beq	DE_NextObject				; if so, branch

DE_CheckBoss:
		move.b	(a2)+,d0				; load boss ID
		bne	DE_NoEndList				; if it's not the end of the list, branch
		cmpi.b	#$5F,(a1)				; is it a bomb fuse?
		bne	DE_NoBombFuse				; if not, branch
		cmpi.b	#$04,$28(a1)				; is it a fuse and not the bomb?
		beq	DE_DestroyNoAnimal			; if so, branch

DE_NoBombFuse:
		tst.b	$01(a1)					; is the object displayed on screen?
		bpl	DE_NextObject				; if not, branch
		cmpi.b	#$20,(a1)				; is it the ball of a ball hog?
		beq	DE_DestroyNoAnimal			; if so, branch
		cmpi.b	#$5F,(a1)				; is it a bomb?
		bne	DE_NoBomb				; if not, branch

DE_DestroyNoAnimal:
		move.b	#$3F,(a1)				; change bomb into an explosion object
		sf.b	$24(a1)					; clear routine counter
		bra	DE_NextObject				; skip for next object

DE_NoBomb:
		cmpi.b	#$26,(a1)				; is it a monitor?
		bne	DE_NoMonitor				; if not, branch
		cmpi.b	#$04,$24(a1)				; is the monitor destroyed?
		bge	DE_NextObject				; if so, branch
		move.b	#$04,$24(a1)				; set to correct destory routine
		bra	DE_NextObject				; skip for next object

DE_NoMonitor:
		cmpi.b	#$50,(a1)				; is it a yadrin?
		beq	DE_Destory				; if so, branch
		move.b	$20(a1),d0				; load touch type
		beq	DE_NextObject				; if it's not valid, branch
		andi.b	#$C0,d0					; get only types
		bne	DE_NextObject				; if it's not an enemie, branch

DE_Destory:
		movem.l	d0-a6,-(sp)				; store register data
		move.w	$12(a0),-(sp)				; store Y speed
		clr.w	$12(a0)					; set no Y speed
		jsr	touch_killenemy				; run destroy code
		move.w	(sp)+,$12(a0)				; reload Y speed
		movem.l	(sp)+,d0-a6				; reload register data

DE_NextObject:
		lea	$40(a1),a1				; advance to next object slot
		dbf	d6,DE_CheckNext				; repeat til all object slots are done
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Boss ID's to check (00 means end of list)
; ---------------------------------------------------------------------------
DE_BossList:	dc.b	$3D,$73,$75,$77,$7A,$82,$85,$00
		even
; ---------------------------------------------------------------------------
; ===========================================================================