	move.l	#$800000,d0
	move.l	#0,d1
	
	
	move.l	#1000000000000000000000000,d2
	moveq	#0,d3
	
	
	moveq	#0,d5
	moveq	#0,d6
	
	moveq	#0,d7
	
j
	moveq	#0,d4
	roxl.l	d0
	;roxl.l	d0
	
	
	bcc	d
	
	
	add.l	d3,d6
	addx.l	d2,d5
	
	
d
	roxr.l	d2
	roxr.l	d3
	dbra	d7,j
	
	illegal