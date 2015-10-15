; --------------------------------------------------------------------------------
; Dynamic Pattern Loading Cues - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

SSonicDynPLC:
		dc.w SSonPLC_Null-SSonicDynPLC
                dc.w SSonPLC_Transform1-SSonicDynPLC
		dc.w SSonPLC_Transform2-SSonicDynPLC
                dc.w SSonPLC_Transform3-SSonicDynPLC
		dc.w SSonPLC_Transform4-SSonicDynPLC
                dc.w SSonPLC_Transform5-SSonicDynPLC
		dc.w SSonPLC_E0-SSonicDynPLC
                dc.w SSonPLC_E5-SSonicDynPLC
		dc.w SSonPLC_EA-SSonicDynPLC
                dc.w SSonPLC_EF-SSonicDynPLC
		dc.w SSonPLC_F6-SSonicDynPLC, SSonPLC_FF-SSonicDynPLC	
		dc.w SSonPLC_106-SSonicDynPLC, SSonPLC_10B-SSonicDynPLC	
		dc.w SSonPLC_112-SSonicDynPLC, SSonPLC_11B-SSonicDynPLC	
		dc.w SSonPLC_122-SSonicDynPLC, SSonPLC_127-SSonicDynPLC	
		dc.w SSonPLC_130-SSonicDynPLC, SSonPLC_13B-SSonicDynPLC	
		dc.w SSonPLC_146-SSonicDynPLC, SSonPLC_151-SSonicDynPLC	
		dc.w SSonPLC_15E-SSonicDynPLC, SSonPLC_16B-SSonicDynPLC	
		dc.w SSonPLC_176-SSonicDynPLC, SSonPLC_181-SSonicDynPLC	
		dc.w SSonPLC_188-SSonicDynPLC, SSonPLC_18F-SSonicDynPLC	
		dc.w SSonPLC_196-SSonicDynPLC, SSonPLC_19B-SSonicDynPLC	
		dc.w SSonPLC_1A2-SSonicDynPLC, SSonPLC_1A9-SSonicDynPLC	
		dc.w SSonPLC_1B0-SSonicDynPLC, SSonPLC_1B5-SSonicDynPLC	
		dc.w SSonPLC_1BE-SSonicDynPLC, SSonPLC_1C9-SSonicDynPLC	
		dc.w SSonPLC_1D2-SSonicDynPLC, SSonPLC_1DB-SSonicDynPLC	
		dc.w SSonPLC_1E4-SSonicDynPLC, SSonPLC_1EF-SSonicDynPLC	
		dc.w SSonPLC_1F8-SSonicDynPLC, SSonPLC_201-SSonicDynPLC	
		dc.w SSonPLC_208-SSonicDynPLC, SSonPLC_211-SSonicDynPLC	
		dc.w SSonPLC_218-SSonicDynPLC, SSonPLC_21D-SSonicDynPLC	
		dc.w SSonPLC_224-SSonicDynPLC, SSonPLC_22D-SSonicDynPLC	
		dc.w SSonPLC_234-SSonicDynPLC, SSonPLC_239-SSonicDynPLC	
		dc.w SSonPLC_244-SSonicDynPLC, SSonPLC_251-SSonicDynPLC	
		dc.w SSonPLC_25C-SSonicDynPLC, SSonPLC_267-SSonicDynPLC	
		dc.w SSonPLC_274-SSonicDynPLC, SSonPLC_281-SSonicDynPLC	
		dc.w SSonPLC_28C-SSonicDynPLC, SSonPLC_299-SSonicDynPLC	
		dc.w SSonPLC_2A0-SSonicDynPLC, SSonPLC_2A7-SSonicDynPLC	
		dc.w SSonPLC_2AE-SSonicDynPLC, SSonPLC_2B3-SSonicDynPLC	
		dc.w SSonPLC_2BA-SSonicDynPLC, SSonPLC_2C1-SSonicDynPLC	
		dc.w SSonPLC_2C8-SSonicDynPLC, SSonPLC_2CD-SSonicDynPLC	
		dc.w SSonPLC_2D6-SSonicDynPLC, SSonPLC_2E1-SSonicDynPLC	
		dc.w SSonPLC_2EC-SSonicDynPLC, SSonPLC_2F5-SSonicDynPLC	
		dc.w SSonPLC_2FE-SSonicDynPLC, SSonPLC_309-SSonicDynPLC	
		dc.w SSonPLC_314-SSonicDynPLC, SSonPLC_31F-SSonicDynPLC	
		dc.w SSonPLC_328-SSonicDynPLC, SSonPLC_331-SSonicDynPLC	
		dc.w SSonPLC_33A-SSonicDynPLC, SSonPLC_345-SSonicDynPLC	
		dc.w SSonPLC_34E-SSonicDynPLC, SSonPLC_357-SSonicDynPLC	
		dc.w SSonPLC_360-SSonicDynPLC, SSonPLC_36B-SSonicDynPLC	
		dc.w SSonPLC_374-SSonicDynPLC, SSonPLC_37D-SSonicDynPLC	
		dc.w SSonPLC_386-SSonicDynPLC, SSonPLC_38F-SSonicDynPLC	
		dc.w SSonPLC_394-SSonicDynPLC, SSonPLC_39B-SSonicDynPLC	
		dc.w SSonPLC_3A2-SSonicDynPLC, SSonPLC_3A9-SSonicDynPLC	
		dc.w SSonPLC_3B0-SSonicDynPLC, SSonPLC_3B7-SSonicDynPLC
SSonPLC_Null:	dc.b 0
SSonPLC_Transform1:
                DynPLC 12, 0, Art_SuperSonic-Art_Sonic          ;dc.b 1, $B2, $C0
SSonPLC_Transform2:	dc.b 3, $B2, $CC, $12, $D8, $52, $DA
SSonPLC_Transform3:	dc.b 3, $82, $E0, 4, 1, $82, $E9
SSonPLC_Transform4:	dc.b 5, $22, $F2, $12, $F5, $32, $F7, $82, $FB, 3, 4	
SSonPLC_Transform5:	dc.b 5, $23, 5, $13, 8, $32, $F7, $82, $FB, 3, 4
SSonPLC_E0:	dc.b 2, $83, $A, $83, $13	
SSonPLC_E5:	dc.b 2, $83, $1C, $83, $13	
SSonPLC_EA:	dc.b 2, $83, $25, $83, $13	
SSonPLC_EF:	dc.b 3, $B1, $BE, $10, 0, $F0, 2	
SSonPLC_F6:	dc.b 4, $B1, $BE, $10, $12, $B0, $14, $10, $20	
SSonPLC_FF:	dc.b 3, $B1, $CA, $50, $22, $30, $28	
SSonPLC_106:	dc.b 2, $81, $D6, $F0, $2C	
SSonPLC_10B:	dc.b 3, $81, $D6, $F0, $3C, $10, $4C	
SSonPLC_112:	dc.b 4, $81, $D6, $10, $4E, $B0, $50, $10, $5C	
SSonPLC_11B:	dc.b 3, $B1, $CA, $50, $5E, $30, $64	
SSonPLC_122:	dc.b 2, $B1, $BE, $B0, $68	
SSonPLC_127:	dc.b 4, $71, $DF, $30, $7A, $50, $74, $10, $7E	
SSonPLC_130:	dc.b 5, $71, $DF, $10, $80, $70, $82, $30, $8A, $10, $8E	
SSonPLC_13B:	dc.b 5, $81, $E7, $30, $90, 1, $F0, $10, $94, $30, $96	
SSonPLC_146:	dc.b 5, 1, $F1, $71, $F2, $10, $9A, $30, $9C, $B0, $A0	
SSonPLC_151:	dc.b 6, 1, $F1, $71, $F2, $10, $AC, $10, $B6, $70, $AE, $30, $B8	
SSonPLC_15E:	dc.b 6, 1, $F1, $71, $F2, $10, $BC, $70, $BE, $30, $C6, $10, $CA	
SSonPLC_16B:	dc.b 5, $81, $E7, $30, $CC, 1, $F0, $10, $D0, $30, $D2	
SSonPLC_176:	dc.b 5, $71, $DF, $10, $DC, $50, $D6, 0, $DE, $30, $E0	
SSonPLC_181:	dc.b 3, $B1, $FA, $B0, $E4, $30, $F0	
SSonPLC_188:	dc.b 3, $B1, $FA, $B0, $F4, $31, 0	
SSonPLC_18F:	dc.b 3, $B2, 6, $31, 4, $31, 8	
SSonPLC_196:	dc.b 2, $82, $12, $B1, $C	
SSonPLC_19B:	dc.b 3, $82, $12, $31, $18, $B1, $1C	
SSonPLC_1A2:	dc.b 3, $82, $12, $B1, $28, $31, $34	
SSonPLC_1A9:	dc.b 3, $B2, 6, $31, $38, $31, $3C	
SSonPLC_1B0:	dc.b 2, $B1, $FA, $B1, $40	
SSonPLC_1B5:	dc.b 4, $31, $4C, $72, $1B, $71, $50, 2, $23	
SSonPLC_1BE:	dc.b 5, $31, $58, $51, $5C, $72, $1B, $71, $62, 2, $23	
SSonPLC_1C9:	dc.b 4, $71, $6A, $72, $24, $31, $72, $12, $2C	
SSonPLC_1D2:	dc.b 4, $71, $76, $B2, $2E, $51, $7E, 2, $3A	
SSonPLC_1DB:	dc.b 4, $51, $84, $B2, $2E, $71, $8A, 2, $3A	
SSonPLC_1E4:	dc.b 5, $31, $92, $51, $96, $B2, $2E, $71, $9C, 2, $3A	
SSonPLC_1EF:	dc.b 4, $71, $A4, $72, $24, $31, $AC, $12, $2C	
SSonPLC_1F8:	dc.b 4, $71, $B0, $72, $1B, $51, $B8, 2, $23	
SSonPLC_201:	dc.b 3, $B2, $3B, $10, 0, $F0, 2	
SSonPLC_208:	dc.b 4, $B2, $3B, $10, $12, $B0, $14, $10, $20	
SSonPLC_211:	dc.b 3, $B2, $47, $50, $22, $30, $28	
SSonPLC_218:	dc.b 2, $82, $53, $F0, $2C	
SSonPLC_21D:	dc.b 3, $82, $53, $F0, $3C, $10, $4C	
SSonPLC_224:	dc.b 4, $82, $53, $10, $4E, $B0, $50, $10, $5C	
SSonPLC_22D:	dc.b 3, $B2, $47, $50, $5E, $30, $64	
SSonPLC_234:	dc.b 2, $B2, $3B, $B0, $68	
SSonPLC_239:	dc.b 5, $12, $5C, $72, $5E, $50, $74, $30, $7A, $10, $7E	
SSonPLC_244:	dc.b 6, $12, $5C, $72, $5E, $10, $80, $70, $82, $30, $8A, $10, $8E	
SSonPLC_251:	dc.b 5, $52, $66, $32, $6C, $30, $90, $10, $94, $30, $96	
SSonPLC_25C:	dc.b 5, $12, $70, $72, $72, $10, $9A, $30, $9C, $B0, $A0	
SSonPLC_267:	dc.b 6, $12, $70, $72, $72, $10, $AC, $10, $B6, $70, $AE, $30, $B8	
SSonPLC_274:	dc.b 6, $12, $70, $72, $72, $10, $BC, $70, $BE, $30, $C6, $10, $CA	
SSonPLC_281:	dc.b 5, $52, $66, $32, $6C, $30, $CC, $10, $D0, $30, $D2	
SSonPLC_28C:	dc.b 6, $12, $5C, $72, $5E, $50, $D6, $10, $DC, $30, $E0, $10, $DE	
SSonPLC_299:	dc.b 3, $B2, $7A, $B0, $E4, $30, $F0	
SSonPLC_2A0:	dc.b 3, $B2, $7A, $B0, $F4, $31, 0	
SSonPLC_2A7:	dc.b 3, $B2, $86, $31, 4, $31, 8	
SSonPLC_2AE:	dc.b 2, $82, $92, $B1, $C	
SSonPLC_2B3:	dc.b 3, $82, $92, $31, $18, $B1, $1C	
SSonPLC_2BA:	dc.b 3, $82, $92, $B1, $28, $31, $34	
SSonPLC_2C1:	dc.b 3, $B2, $86, $31, $38, $31, $3C	
SSonPLC_2C8:	dc.b 2, $B2, $7A, $B1, $40	
SSonPLC_2CD:	dc.b 4, $31, $4C, $B2, $9B, $71, $50, 2, $A7	
SSonPLC_2D6:	dc.b 5, $31, $58, $51, $5C, $B2, $9B, $71, $62, 2, $A7	
SSonPLC_2E1:	dc.b 5, $71, $6A, $12, $A8, $72, $AA, $31, $72, 2, $B2	
SSonPLC_2EC:	dc.b 4, $71, $76, $B2, $B3, $51, $7E, 2, $BF	
SSonPLC_2F5:	dc.b 4, $51, $84, $B2, $B3, $71, $8A, 2, $BF	
SSonPLC_2FE:	dc.b 5, $31, $92, $51, $96, $B2, $B3, $71, $9C, 2, $BF	
SSonPLC_309:	dc.b 5, $71, $A4, $12, $A8, $72, $AA, $31, $AC, 2, $B2	
SSonPLC_314:	dc.b 5, $71, $B0, $12, $9C, $72, $9F, $51, $B8, 2, $A7	
SSonPLC_31F:	dc.b 4, $23, $2E, 3, $31, $33, $32, $53, $36	
SSonPLC_328:	dc.b 4, $13, $3C, $B3, $3E, $23, $4A, $13, $4D	
SSonPLC_331:	dc.b 4, $23, $4F, $33, $52, $23, $56, $33, $59	
SSonPLC_33A:	dc.b 5, $23, $5D, $73, $60, $33, $68, $13, $6C, 3, $6E	
SSonPLC_345:	dc.b 4, $53, $6F, 3, $75, $33, $32, $53, $76	
SSonPLC_34E:	dc.b 4, $13, $7C, $B3, $7E, $23, $4A, 3, $8A	
SSonPLC_357:	dc.b 4, $53, $8B, $33, $52, 3, $91, $53, $92	
SSonPLC_360:	dc.b 5, $23, $5D, $73, $98, $33, $A0, $13, $A4, 3, $6E	
SSonPLC_36B:	dc.b 4, $53, $A6, $33, $AC, $33, $B0, $73, $B4	
SSonPLC_374:	dc.b 4, $53, $BC, $33, $C2, $33, $B0, $73, $C6	
SSonPLC_37D:	dc.b 4, $53, $A6, $33, $AC, $33, $B0, $73, $CE	
SSonPLC_386:	dc.b 4, $53, $BC, $33, $C2, $33, $B0, $73, $D6	
SSonPLC_38F:	dc.b 2, $23, $DE, $B3, $E1	
SSonPLC_394:	dc.b 3, $83, $ED, $23, $F6, $33, $F9	
SSonPLC_39B:	dc.b 3, $83, $1C, $23, $F6, $33, $F9	
SSonPLC_3A2:	dc.b 3, $83, $25, $23, $F6, $33, $F9	
SSonPLC_3A9:	dc.b 3, $83, $ED, $23, $F6, $33, $FD	
SSonPLC_3B0:	dc.b 3, $83, $1C, $23, $F6, $33, $FD	
SSonPLC_3B7:	dc.b 3, $83, $25, $23, $F6, $33, $FD
		even