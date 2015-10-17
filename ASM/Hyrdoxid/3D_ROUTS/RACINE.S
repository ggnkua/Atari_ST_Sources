;racine carree
SQR
	moveq	#15,d0		;nb iterations
	move.l	#5089422,d1		;nb dont on veut la racine=A
	move.l	#5,d2		;x0
;suite de la forme:Xn+1=(Xn+A/Xn)/2
.LOOP
	move.l	d2,d3
	move.l	d1,d4
	divu.l	d3,d4		;A/Xn
	add.l	d3,d4		;A/Xn+Xn
	asr.l	d4
	move.l	d4,d2
	dbf	d0,.LOOP
	rts