
	; time_peek()
	;	catch a look at 200 Hz system clock
	public _time_peek
_time_peek
	pea		timer
	move.w	#38,-(sp)
	trap 	#14
	addq	#6,sp
	rts

timer 	; return system 200hz clock in d0 from super mode
	move.l	$4ba,d0
	rts

