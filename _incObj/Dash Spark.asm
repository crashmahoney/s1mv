; =============== S U B R O U T I N E =======================================
; ---------------------------------------------------------------------------
; branch to this subroutine in your jumpdash code
; ---------------------------------------------------------------------------
CreateSparks:
		lea		(SparkVelocities).l,a2
		moveq	#3,d1								; make 4 sparks
@makespark:
		jsr		FindFreeObj
		bne.s	@rts			
		move.b	#id_Spark,(a1)						; Make new object a Spark
		move.w	obX(a0),obX(a1)						; Get X position from Sonic
		move.w	obY(a0),obY(a1)						; Get Y position from Sonic
		move.l	#Map_Spark,obMap(a1)
		move.w	#$26C0,obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	obPriority(a0),obPriority(a1)
		move.b	#8,obWidth(a1)
		move.b	#8,obHeight(a1)
		move.b	#0,obAnim(a1)
		move.w	(a2)+,obVelX(a1)					; (Spark) Give x_vel (unique to each of the four Sparks)
        btst    #0,obStatus(a0) 					; is sonic facing left?
        beq.s   @doVelY   							; if not, branch
        neg.w   obVelX(a1)							; send spark backwards
	@doVelY:
		move.w	(a2)+,obVelY(a1)					; (Spark) Give y_vel (unique to each of the four Sparks)
		dbf		d1,@makespark

@rts:
		rts
; ---------------------------------------------------------------------------
SparkVelocities:
; double jump pattern
		dc.w  -$200, -$200
		dc.w   $200, -$200
		dc.w  -$200,  $200
		dc.w   $200,  $200


; horizontal dash pattern
		dc.w  -$200, -$200
		dc.w  -$100, -$100
		dc.w  -$100,  $100
		dc.w  -$200,  $200
; ---------------------------------------------------------------------------


; ===========================================================================
; ---------------------------------------------------------------------------
; this is the actual spark object, needs to be in the object list
; ---------------------------------------------------------------------------
Spark:
		jsr		SpeedToPos				; move object
		addi.w	#$18,obVelY(a0)			; apply some gravity
		lea		(Spark_Animation).l,a1	
		jsr		AnimateSprite			; run animation
		tst.b	obRoutine(a0)			; the animation changes the routine when finished
		bne.s	Spark_Delete			; branch to delete routine
		jmp		DisplaySprite
; ---------------------------------------------------------------------------
Spark_Delete:
		jmp		DeleteObject
; ---------------------------------------------------------------------------
; end of object
; ---------------------------------------------------------------------------

	even

; ===========================================================================
; ---------------------------------------------------------------------------
; mappings
; you might need to edit these to suit your graphics
; ---------------------------------------------------------------------------
Map_Spark:
		dc.w SparkSmall-Map_Spark
		dc.w SparkLarge-Map_Spark	
		dc.w SparkBlank-Map_Spark 	
		dc.w SparkMid-Map_Spark 	
SparkSmall:	dc.b 1
		dc.b $FC, 0, 0, $D, $FC
SparkLarge:	dc.b 1	
		dc.b $F8, 5, 0, $8, $F8	
SparkBlank:	dc.b 0
SparkMid:	dc.b 1
		dc.b $FC, 0, 0, $C, $FC
		even


; ===========================================================================
; ---------------------------------------------------------------------------
; animation sequence, changes object's routine when finished so object knows to delete
; first byte is animation speed, last 2 bytes are the control bytes to change routine
; the rest is the frame numbers, you can change them to suit
; ---------------------------------------------------------------------------
Spark_Animation:
		dc.w Spark_Ani_1-Spark_Animation
		dc.w Spark_Ani_2-Spark_Animation ; Power up sparkles

Spark_Ani_1:	dc.b    0, $0, $1, $2, $0, $1, $2, $0, $1, $2, $0, $1, $2
		    	dc.b   $0, $1, $2, $0, $1, $2, $0, $1, $FC, $FF

Spark_Ani_2:	dc.b    0, 1,3,1,3,1,3,1,3,1,3,0,3,0,3,0,3,0,3,0,3,0,2,0,2,0,2, $FC, $FF
		even
