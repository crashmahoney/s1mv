; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------
Map_HUD:	dc.w @ringGFX-Map_HUD, @ringGFXred-Map_HUD


@ringGFX:	dc.b 6
		SpriteMap  -112, -120, 3, 2, 0, 0, 1, 0, 0x0022     ; ring amount
		SpriteMap  -120, -128, 2, 3, 0, 0, 1, 1, 0x0000     ; ring
		SpriteMap  -128, -104, 2, 2, 0, 0, 1, 0, 0x0006    ; A box
		SpriteMap  -111, -104, 2, 2, 0, 0, 1, 0, 0x000A     ; B box
;		SpriteMap  -94, -104, 4, 2, 0, 0, 1, 0, 0x000E    ; C box
		SpriteMap  -94, -104, 2, 2, 0, 0, 1, 0, 0x000E    ; C box
		SpriteMap  127, -128, 4, 4, 0, 0, 1, 0, 0x0012    ; map
		even

@ringGFXred:	dc.b 6
		SpriteMap  -112, -120, 3, 2, 0, 0, 1, 0, 0x0022     ; ring amount
		SpriteMap  -120, -128, 2, 3, 0, 0, 1, 0, 0x0000     ; ring
		SpriteMap  -128, -104, 2, 2, 0, 0, 1, 0, 0x0006    ; A box
		SpriteMap  -111, -104, 2, 2, 0, 0, 1, 0, 0x000A     ; B box
;		SpriteMap  -94, -104, 4, 2, 0, 0, 1, 0, 0x000E    ; C box
		SpriteMap  -94, -104, 2, 2, 0, 0, 1, 0, 0x000E    ; C box
		SpriteMap  127, -128, 4, 4, 0, 0, 1, 0, 0x0012    ; map
		even
