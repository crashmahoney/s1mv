; ---------------------------------------------------------------------------
; Sprite mappings - explosion from a badnik or monitor
; ---------------------------------------------------------------------------
Map_ExplodeItem:	
		dc.w Map_ExplodeItem_A-Map_ExplodeItem, Map_ExplodeItem_10-Map_ExplodeItem	
		dc.w Map_ExplodeItem_16-Map_ExplodeItem, Map_ExplodeItem_1C-Map_ExplodeItem	
		dc.w Map_ExplodeItem_22-Map_ExplodeItem	
Map_ExplodeItem_A:	dc.b 1	
		dc.b $F8, 5, $20, 0, $F8	
Map_ExplodeItem_10:	dc.b 1	
		dc.b $F0, $F, 0, 4, $F0	
Map_ExplodeItem_16:	dc.b 1	
		dc.b $F0, $F, 0, $14, $F0	
Map_ExplodeItem_1C:	dc.b 1	
		dc.b $F0, $F, 0, $24, $F0	
Map_ExplodeItem_22:	dc.b 1	
		dc.b $F0, $F, 0, $34, $F0	
		even
; ---------------------------------------------------------------------------
; Sprite mappings - explosion from when	a boss is destroyed
; ---------------------------------------------------------------------------
Map_ExplodeBomb:	
		dc.w Map_ExplodeBomb_C-Map_ExplodeBomb, Map_ExplodeBomb_12-Map_ExplodeBomb	
		dc.w Map_ExplodeBomb_18-Map_ExplodeBomb, Map_ExplodeBomb_1E-Map_ExplodeBomb	
		dc.w Map_ExplodeBomb_24-Map_ExplodeBomb, Map_ExplodeBomb_2A-Map_ExplodeBomb	
Map_ExplodeBomb_C:	dc.b 1	
		dc.b $F8, 5, $20, 0, $F8	
Map_ExplodeBomb_12:	dc.b 1	
		dc.b $F4, $A, $20, 4, $F4	
Map_ExplodeBomb_18:	dc.b 1	
		dc.b $F4, $A, $20, $D, $F4	
Map_ExplodeBomb_1E:	dc.b 1	
		dc.b $F4, $A, $20, $16, $F4	
Map_ExplodeBomb_24:	dc.b 1	
		dc.b $F3, $A, $20, $1F, $F4	
Map_ExplodeBomb_2A:	dc.b 1	
		dc.b $F6, 9, $20, $28, $F4	
		even