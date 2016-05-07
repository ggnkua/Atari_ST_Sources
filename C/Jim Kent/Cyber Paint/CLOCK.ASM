
	public _mouse_y
	public _pscreen


old_crit	dc.l	0
err_d0		dc.l	0
err_d7		dc.l	0

	public _get_err_d0
_get_err_d0
	move.l	err_d0,d0
	rts

	public _get_err_d7
_get_err_d7
	move.l	err_d7,d0
	rts

my_critical
	move.l	#err_d0,a0
	move.l	d0,(a0)+
	move.l	d7,(a0)+
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

	; time_peek()
	;	catch a look at 200 Hz system clock
	;public _time_peek
;_time_peek
	;pea		timer
	;bra		trap38

;timer 	; return system 200hz clock in d0 from super mode
	;move.l	$4ba,d0
	;rts


	; beam_peek()
	;	find out what word the video beam is on
	;	it's between $f8000 and $ffd00 if you don't setscreen ...
	public _beam_peek
_beam_peek
	pea		beamer
trap38
	move.w	#38,-(sp)
	trap 	#14
	addq	#6,sp
	rts

beamer	; what gets done in supervisor - look at hardware beam registers
	move.l	#$ff8205,a0
	move.l	#0,d0
	move.b	(a0),d0
	asl.l	#8,d0
	adda.w	#2,a0
	move.b	(a0),d0
	asl.l	#8,d0
	adda.w	#2,a0
	move.b	(a0),d0
	rts


	; wait_out_beam()
	;	wait until it looks like not in danger of intersecting beam
	;	with cursor position
	public _wait_out_beam
_wait_out_beam
	move.l	_pscreen,d1
	add.l	#32000,d1		; find end of screen
	bsr		_beam_peek		; check the beam
	cmp.l	d0,d1
	beq		waited			; if in 1st 1/2 of vblank return now
	move.w	_mouse_y,d1
	move.l	_pscreen,a1
	lsl.w	#5,d1
	add.w	d1,a1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,a1
	move.l	a1,d1
	move.l	d1,d2			; a1=d1=d2 = pscreen + 160 * mouse_y
	sub.l	#28*160,d1		; lower bound of beam address to wait for
	add.l	#8*160,d2		; upper bound of beam address to wait for
waitloop	cmp.l	d1,d0	
	ble		waited
	cmp.l	d2,d0
	bge		waited
	bsr		_beam_peek
	bra 	waitloop
waited	rts


	;skip_beam()
	;	wait to do copy screen so that avoid beam
	;	copy screen takes less than 1/50th second
	;	color beam time 1/70th second
	;	so beam outruns copy a bit
	;	wait for beam to be in top 3/4 of screen...
	public _skip_beam
_skip_beam
	move.l	_pscreen,d1
	move.l	d1,d2
	add.l	#1*160,d1		; lower bound of beam to wait for
	add.l	#150*160,d2		; upper bound of beam to wait for
skiploop	
	bsr		_beam_peek
	cmp.l	d1,d0	
	blt		skiploop
	cmp.l	d2,d0
	bgt		skiploop
	rts

	;mskip_beam()
	;   wait to do copy of screen segment between pulldowns
	;   and menus so that don't get glitch
	public	_mskip_beam
_mskip_beam
	move.l	_pscreen,d1
	move.l	d1,d2
	add.l	#10*160,d1		; lower bound of beam to wait for
	add.l	#170*160,d2		; upper bound of beam to wait for
	bra		skiploop

