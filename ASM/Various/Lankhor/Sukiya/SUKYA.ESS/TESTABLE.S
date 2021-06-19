main:
        move.l	#to+2,a0
	move  	to,d0
	lsr   	#1,d0
        subq  	#2,d0
	move  	to,d2
bcl:    move  	(a0),d1
	add   	d1,d2
        move  	d2,(a0)+
	dbf   	d0,bcl
	illegal
to:
