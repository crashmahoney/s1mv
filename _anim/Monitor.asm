; ---------------------------------------------------------------------------
; Animation script - monitors
; ---------------------------------------------------------------------------
Ani_Monitor:

ptr_DoubleJmon:	dc.w MonAni_DoubleJmon-Ani_Monitor
ptr_Eggman:     dc.w MonAni_eggman-Ani_Monitor
ptr_Sonicmon:   dc.w MonAni_sonic-Ani_Monitor
ptr_Shoesmon:   dc.w MonAni_shoes-Ani_Monitor
ptr_Shieldmon:  dc.w MonAni_shield-Ani_Monitor
ptr_Invincmon   dc.w MonAni_invincible-Ani_Monitor
ptr_Ringsmon:   dc.w MonAni_rings-Ani_Monitor
ptr_S1mon:      dc.w MonAni_s-Ani_Monitor
ptr_Gogglesmon: dc.w MonAni_goggles-Ani_Monitor
ptr_S2mon:      dc.w MonAni_s2-Ani_Monitor
ptr_S3mon:      dc.w MonAni_s3-Ani_Monitor
ptr_S4mon:      dc.w MonAni_s4-Ani_Monitor
ptr_S5mon:      dc.w MonAni_s5-Ani_Monitor
ptr_S6mon:      dc.w MonAni_s6-Ani_Monitor
ptr_S7mon:      dc.w MonAni_s7-Ani_Monitor
ptr_S8mon:      dc.w MonAni_s8-Ani_Monitor
ptr_Breakingmon:dc.w MonAni_breaking-Ani_Monitor


MonAni_DoubleJmon:	dc.b 1,	0, 12, 12, 1, 12, 12, 2, 12, 12, afEnd
		even
MonAni_eggman:	dc.b 1,	0, 3, 3, 1, 3, 3, 2, 3,	3, afEnd
		even
MonAni_sonic:		dc.b 1,	0, 4, 4, 1, 4, 4, 2, 4,	4, afEnd
		even
MonAni_shoes:		dc.b 1,	0, 5, 5, 1, 5, 5, 2, 5,	5, afEnd
		even
MonAni_shield:	dc.b 1,	0, 6, 6, 1, 6, 6, 2, 6,	6, afEnd
		even
MonAni_invincible:	dc.b 1,	0, 7, 7, 1, 7, 7, 2, 7,	7, afEnd
		even
MonAni_rings:		dc.b 1,	0, 8, 8, 1, 8, 8, 2, 8,	8, afEnd
		even
MonAni_s:		dc.b 1,	0, 9, 9, 1, 9, 9, 2, 9,	9, afEnd
		even
MonAni_goggles:	dc.b 1,	0, $A, $A, 1, $A, $A, 2, $A, $A, afEnd
		even
MonAni_s2:		dc.b 1,	0, $B, $B, 1, $B, $B, 2, $B,	$B, afEnd
		even
MonAni_s3:		dc.b 1,	0, $C, $C, 1, $C, $C, 2, $C,	$C, afEnd
		even
MonAni_s4:		dc.b 1,	0, $D, $D, 1, $D, $D, 2, $D,	$D, afEnd
		even
MonAni_s5:		dc.b 1,	0, $E, $E, 1, $E, $E, 2, $E,	$E, afEnd
		even
MonAni_s6:		dc.b 1,	0, $F, $F, 1, $F, $F, 2, $F,	$F, afEnd
		even
MonAni_s7:		dc.b 1,	0, 10, 10, 1, 10, 10, 2, 10,	10, afEnd
		even
MonAni_s8:		dc.b 1,	0, 11, 11, 1, 11, 11, 2, 11,	11, afEnd
		even
MonAni_breaking:	dc.b 2,	0, 1, 2, $B, afBack, 1           ;2,	0, 1, 2, $D, afBack, 1
		even


id_DoubleJmon:     equ (ptr_DoubleJmon-Ani_Monitor)/2        ;0
id_Eggman:     equ (ptr_Eggman-Ani_Monitor)/2
id_Sonicmon:   equ (ptr_Sonicmon-Ani_Monitor)/2
id_Shoesmon:   equ (ptr_Shoesmon-Ani_Monitor)/2
id_Shieldmon:  equ (ptr_Shieldmon-Ani_Monitor)/2
id_Invincmon   equ (ptr_Invincmon-Ani_Monitor)/2
id_Ringsmon:   equ (ptr_Ringsmon-Ani_Monitor)/2
id_S1mon:      equ (ptr_S1mon-Ani_Monitor)/2
id_Gogglesmon: equ (ptr_Gogglesmon-Ani_Monitor)/2
id_S2mon:      equ (ptr_S2mon-Ani_Monitor)/2
id_S3mon:      equ (ptr_S3mon-Ani_Monitor)/2
id_S4mon:      equ (ptr_S4mon-Ani_Monitor)/2
id_S5mon:      equ (ptr_S5mon-Ani_Monitor)/2
id_S6mon:      equ (ptr_S6mon-Ani_Monitor)/2
id_S7mon:      equ (ptr_S7mon-Ani_Monitor)/2
id_S8mon:      equ (ptr_S8mon-Ani_Monitor)/2
id_Breakingmon:equ (ptr_Breakingmon-Ani_Monitor)/2
