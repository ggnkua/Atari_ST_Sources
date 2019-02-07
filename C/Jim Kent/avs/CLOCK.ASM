
	public _mouse_y
	public _pscreen


old_crit	dc.l	0

my_critical
	rts

critsave
	move.l	#old_crit,a0
	move.l	$404,(a0)
	rts

critin	
	move.l	#my_critical,$404
	rts

critout	move.l	old_crit,$404
	rts

	public _save_critical
_save_critical
	pea	critsave
	bra		trap38

	public _install_critical
_install_critical
	pea	critin
	bra		trap38

	public _remove_critical
_remove_critical
	pea	critout
	bra		trap38

	 ;time_peek()
	;	catch a look at 200 Hz system clock
	public _time_peek
_time_peek
	pea		timer
trap38
	move.w	#38,-(sp)
	trap 	#14
	addq	#6,sp
	rts

timer 	; return system 200hz clock in d0 from super mode
	move.l	$4ba,d0
	rts



