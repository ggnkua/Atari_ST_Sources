	output	.ro
	include	fdcmac.s
seek_track:
	move.l	a1,a6
	; par d‚faut piste 0
	SEEK_TRACK	(a6)
	rts
	include	..\rostruct.s

