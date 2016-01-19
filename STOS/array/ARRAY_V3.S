start:	
 	CMPI.b	#1,D1
	BEQ	One_array
	CMPI.b	#2,D1
	BEQ	Two_array
	CMPI.b	#3,D1
	BEQ	Three_array

One_array:
	subq.b	#1,d0
.loop	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	rts

Two_array:
	subq.b	#1,d0
.loop	move.l	(a0)+,(a1)+
	move.l	(a2)+,(a3)+
	dbra	d0,.loop
	rts

Three_array:
	subq.b	#1,d0
.loop	move.l	(a0)+,(a1)+
	move.l	(a2)+,(a3)+
	move.l	(a4)+,(a5)+
	dbra	d0,.loop
	rts