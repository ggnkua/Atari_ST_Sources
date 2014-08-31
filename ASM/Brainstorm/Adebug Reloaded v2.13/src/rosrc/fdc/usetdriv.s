	output	.ro
	include	fdcmac.s
unset_drive:
	;par defaut drive 0 side 0
	UNSET_DRIVE
	rts
	include	..\rostruct.s

