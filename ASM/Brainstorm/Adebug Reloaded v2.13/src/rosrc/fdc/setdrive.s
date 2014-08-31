	output	.ro
	include	fdcmac.s
set_drive:
	move.l	a1,a6
	move.l	a0,a5
	;par defaut drive 0 side 0
	SET_DRIVE	(a6),4(a6)
	rts
	include	..\rostruct.s

