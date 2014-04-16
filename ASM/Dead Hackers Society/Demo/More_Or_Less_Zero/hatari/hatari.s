
		section	text

;-------------- Hatari interaction ---------------------

hatari_max:					; in: none
		move.w	#2,-(sp)
		move.w	#255,-(sp)
		trap	#14
		addq.w	#4,sp
		rts
		
hatari_min:					; in: none
		move.w	#1,-(sp)
		move.w	#255,-(sp)
		trap	#14
		addq.w	#4,sp
		rts
		
hatari_debug:					; in: length in d0, memptr in a0
		move.l	d0,-(sp)
		move.l	a0,-(sp)
		move.w	#254,-(sp)
		trap	#14
		add.l	#10,sp
		rts
hatari_registers:				; in: none
	;	move.l	d0,-(sp)
	;	move.l	a0,-(sp)
		move.w	#250,-(sp)
		trap	#14
		add.l	#2,sp
		rts

hatari_cycles_start:				; in: cycle counter # in d0.w
		move.w	d0,-(sp)
		move.w	#253,-(sp)
		trap	#14
		addq.l	#4,sp
		rts

hatari_cycles_read:				; in: cycle counter # in d0.w
		move.w	d0,-(sp)
		move.w	#252,-(sp)
		trap	#14
		addq.l	#4,sp
		rts
