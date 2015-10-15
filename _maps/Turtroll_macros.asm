Map_Turtroll:	mappingsTable
	mappingsTableEntry.w	@stand
	mappingsTableEntry.w	@crouch1
	mappingsTableEntry.w	@crouch2
	mappingsTableEntry.w	@crouch3
	mappingsTableEntry.w	@roll1
	mappingsTableEntry.w	@roll2
	mappingsTableEntry.w	@roll3
	mappingsTableEntry.w	@dizzy1
	mappingsTableEntry.w	@dizzy2

@stand:	spriteHeader
	spritePiece	-8, -$20, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-8, -$10, 2, 1, 4, 0, 0, 0, 0
	spritePiece	8, -$20, 1, 3, 6, 0, 0, 0, 0
@stand_End

@crouch1:	spriteHeader
	spritePiece	-8, -$20, 2, 2, 9, 0, 0, 0, 0
	spritePiece	-8, -$10, 2, 1, $11, 0, 0, 0, 0
	spritePiece	8, -$20, 1, 3, 6, 0, 0, 0, 0
@crouch1_End

@crouch2:	spriteHeader
	spritePiece	-8, -$20, 2, 2, $D, 0, 0, 0, 0
	spritePiece	-8, -$10, 2, 1, $11, 0, 0, 0, 0
	spritePiece	8, -$20, 1, 3, 6, 0, 0, 0, 0
@crouch2_End

@crouch3:	spriteHeader
	spritePiece	-8, -$20, 3, 3, $13, 0, 0, 0, 0
@crouch3_End

@roll1:	spriteHeader
	spritePiece	-8, -$20, 3, 3, $1C, 0, 0, 0, 0
@roll1_End

@roll2:	spriteHeader
	spritePiece	-8, -$20, 3, 3, $25, 0, 0, 0, 0
@roll2_End

@roll3:	spriteHeader
	spritePiece	-8, -$20, 3, 3, $2E, 0, 0, 0, 0
@roll3_End

@dizzy1:	spriteHeader
	spritePiece	-8, -$20, 2, 2, $37, 0, 0, 0, 0
	spritePiece	-8, -$10, 2, 1, 4, 0, 0, 0, 0
	spritePiece	8, -$20, 1, 3, 6, 0, 0, 0, 0
@dizzy1_End

@dizzy2:	spriteHeader
	spritePiece	-8, -$20, 2, 2, $3B, 0, 0, 0, 0
	spritePiece	-8, -$10, 2, 1, 4, 0, 0, 0, 0
	spritePiece	8, -$20, 1, 3, 6, 0, 0, 0, 0
@dizzy2_End

	even
