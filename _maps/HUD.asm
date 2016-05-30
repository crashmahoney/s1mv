; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------
Map_HUD:	dc.w @ringGFX-Map_HUD, @ringGFXred-Map_HUD


@ringGFX:	dc.b 6
		SpriteMap  8, -120, 3, 2, 0, 0, 1, 0, 0x0022     ; ring amount
		SpriteMap  0, -128, 2, 3, 0, 0, 1, 1, 0x0000     ; ring
		SpriteMap  -8, -104, 2, 2, 0, 0, 1, 0, 0x0006    ; A box
		SpriteMap  9, -104, 2, 2, 0, 0, 1, 0, 0x000A     ; B box
;		SpriteMap  26, -104, 4, 2, 0, 0, 1, 0, 0x000E    ; C box
		SpriteMap  26, -104, 2, 2, 0, 0, 1, 0, 0x000E    ; C box
		SpriteMap  56, -120, 4, 4, 0, 0, 1, 0, 0x0012    ; map

		even
@ringGFXred:	dc.b 6
		SpriteMap  8, -120, 3, 2, 0, 0, 1, 0, 0x0022     ; ring amount
		SpriteMap  0, -128, 2, 3, 0, 0, 1, 0, 0x0000     ; ring
		SpriteMap  -8, -104, 2, 2, 0, 0, 1, 0, 0x0006    ; A box
		SpriteMap  9, -104, 2, 2, 0, 0, 1, 0, 0x000A     ; B box
;		SpriteMap  26, -104, 4, 2, 0, 0, 1, 0, 0x000E    ; C box
		SpriteMap  26, -104, 2, 2, 0, 0, 1, 0, 0x000E    ; C box
		SpriteMap  56, -120, 4, 4, 0, 0, 1, 0, 0x0012    ; map
		even
