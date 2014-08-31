	output	.ro
	include	fdcmac.s
read_address:
	move.l	a1,a6
	move.l	a0,a5
	;si pas de paramätre prendre l'@ de la fen courante
	tst.l	(a6)
	bne.s	.param
	;provisoirement pas d'erreur
	moveq	#0,d7
	bra	.end
.param:
	READ_ADDRESS	(a6),4(a6)
.end:
	rts
	include	..\rostruct.s

