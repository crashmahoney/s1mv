; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------
Map_HUD:	dc.w @ringGFX-Map_HUD, @ringGFXred-Map_HUD
;                 dc.w @allyellow-Map_HUD, @ringred-Map_HUD
; 		dc.w @timered-Map_HUD, @allred-Map_HUD


@ringGFX:	dc.b 5
                SpriteMap  8, -120, 3, 2, 0, 0, 1, 0, 0x0016     ; ring amount
                SpriteMap  0, -128, 2, 3, 0, 0, 1, 1, 0x0000     ; ring
                SpriteMap  -8, -104, 2, 2, 0, 0, 1, 0, 0x0006    ; A box
                SpriteMap  9, -104, 2, 2, 0, 0, 1, 0, 0x000A     ; B box
                SpriteMap  26, -104, 4, 2, 0, 0, 1, 0, 0x000E    ; C box
                even
@ringGFXred:	dc.b 5
                SpriteMap  8, -120, 3, 2, 0, 0, 1, 0, 0x0016     ; ring amount
                SpriteMap  0, -128, 2, 3, 0, 0, 1, 0, 0x0000     ; ring
                SpriteMap  -8, -104, 2, 2, 0, 0, 1, 0, 0x0006    ; A box
                SpriteMap  9, -104, 2, 2, 0, 0, 1, 0, 0x000A     ; B box
                SpriteMap  26, -104, 4, 2, 0, 0, 1, 0, 0x000E    ; C box
                even
                



;old hud mappings from here vvvvvv
; @allyellow:	dc.b $A
; 		dc.b $80, $D, $80, 0, 0
; 		dc.b $80, $D, $80, $18,	$20
; 		dc.b $80, $D, $80, $20,	$40
; 		dc.b $90, $D, $80, $10,	0
; 		dc.b $90, $D, $80, $28,	$28
; 		dc.b $A0, $D, $80, 8, 0
; 		dc.b $A0, 1, $80, 0, $20
; 		dc.b $A0, 9, $80, $30, $30
; 		dc.b $40, 5, $81, $A, 0
; 		dc.b $40, $D, $81, $E, $10
; 		dc.b 0
; @ringred:	dc.b $A
; 		dc.b $80, $D, $80, 0, 0
; 		dc.b $80, $D, $80, $18,	$20
; 		dc.b $80, $D, $80, $20,	$40
; 		dc.b $90, $D, $80, $10,	0
; 		dc.b $90, $D, $80, $28,	$28
; 		dc.b $A0, $D, $A0, 8, 0
; 		dc.b $A0, 1, $A0, 0, $20
; 		dc.b $A0, 9, $80, $30, $30
; 		dc.b $40, 5, $81, $A, 0
; 		dc.b $40, $D, $81, $E, $10
; 		dc.b 0
; @timered:	dc.b $A
; 		dc.b $80, $D, $80, 0, 0
; 		dc.b $80, $D, $80, $18,	$20
; 		dc.b $80, $D, $80, $20,	$40
; 		dc.b $90, $D, $A0, $10,	0
; 		dc.b $90, $D, $80, $28,	$28
; 		dc.b $A0, $D, $80, 8, 0
; 		dc.b $A0, 1, $80, 0, $20
; 		dc.b $A0, 9, $80, $30, $30
; 		dc.b $40, 5, $81, $A, 0
; 		dc.b $40, $D, $81, $E, $10
; 		dc.b 0
; @allred:	dc.b $A
; 		dc.b $80, $D, $80, 0, 0
; 		dc.b $80, $D, $80, $18,	$20
; 		dc.b $80, $D, $80, $20,	$40
; 		dc.b $90, $D, $A0, $10,	0
; 		dc.b $90, $D, $80, $28,	$28
; 		dc.b $A0, $D, $A0, 8, 0
; 		dc.b $A0, 1, $A0, 0, $20
; 		dc.b $A0, 9, $80, $30, $30
; 		dc.b $40, 5, $81, $A, 0
; 		dc.b $40, $D, $81, $E, $10
; 		even