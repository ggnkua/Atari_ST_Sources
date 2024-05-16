;	lea	$40000,a0
	lea	$42000,a0
	lea	$f8000,a1
	moveq	#10,d2
o1:
	moveq	#320/32-1,d1
o:
	moveq	#32-1,d0
copy:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	160-16(a1),a1
	dbra	d0,copy

	lea	-32*160+16(a1),a1
	dbra	d1,o

	lea	-160(a1),a1
	lea	32*160(a1),a1
	dbra	d2,o1

	illegal
