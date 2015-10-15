



PauseMenu_DeformLayers:

		add.w   #$1,(v_menu_bgY)
		move.l	(v_menu_fgY),(v_scrposy_dup).w


; top that doesn't scroll
		lea		(v_scrolltable).w,a1
		moveq	#0,d0
		move.w	(v_menu_bgY),d1
		neg		d1
		move.w  d1,d0
		move.l	#23,d1
	@writetable:	
		move.l	d0,(a1)+
		dbf		d1,@writetable

; top jagged scrolly bit
		moveq   #0,d1
		move.w	(v_menu_bgY),d1
		swap	d1
		add.l  d1,d0
		move.l	#7,d1
	@writetable2:	
		move.l	d0,(a1)+
		dbf		d1,@writetable2

; middle that doesn't scroll
		swap	d0
		move.w  #$0000,d0
		swap	d0
		move.l	#147,d1
	@writetable3:	
		move.l	d0,(a1)+
		dbf		d1,@writetable3

; bottom jagged scrolly bit
		moveq   #0,d1
		move.w	(v_menu_bgY),d1
		neg		d1
		swap	d1
		add.l  d1,d0
		move.l	#7,d1
	@writetable4:	
		move.l	d0,(a1)+
		dbf		d1,@writetable4

; bottom that doesn't scroll
		swap	d0
		move.w  #$0000,d0
		swap	d0
		move.l	#35,d1
	@writetable5:	
		move.l	d0,(a1)+
		dbf		d1,@writetable5

		rts



;========================================================================================================================
