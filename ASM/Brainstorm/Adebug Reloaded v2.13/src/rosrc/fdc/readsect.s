	output	.ro
	include	fdcmac.s
read_sector:
	move.l	a1,a6
	move.l	a0,a5
	;si pas de paramätre prendre l'@ de la fen courante
	tst.l	(a6)
	bne.s	.param
	;provisoirement pas d'erreur
	moveq	#0,d7
	bra	.end
.param:
	READ_SECTOR	(a6),4(a6)
	move.l	d0,d7
.end:
	move.l	d7,d0
	rts
	include	..\rostruct.s

