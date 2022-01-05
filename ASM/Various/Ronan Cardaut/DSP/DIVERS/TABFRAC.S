* clacul la table de 32 nombres BCD
* pour chaque 1/2^ possible pour n=0 … n=23

CALC_TAB
	lea	BUF+16,a0
	moveq	#2,d1
	move	#24-1,d7
LOOP	
	bsr	CALC
	
	add.l	d1,d1
	dbra	d7,LOOP
	rts
		



CALC
	lea	RESULT,a1
	move	#32-1,d6
	moveq	#1,d2
.LOOP	
	divul.l	d1,d3:d2
	
	move.b	d2,(a1)+
	move.l	d3,d2
	mulu.l	#10,d2
	
	dbra	d6,.LOOP
	
	add	#16,a0
	move	#16-1,d6
.PACK	pack	-(a1),-(a0),#0
	dbra	d6,.PACK	
	add	#16,a0
	rts
	

		



RESULT	ds.b	32

