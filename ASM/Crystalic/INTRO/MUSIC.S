	move.w	#8000,-(sp)
	move.w	#1,-(sp)
	trap	#14
	addq.l	#4,sp
	
	move.l	d0,add
add:
	dc.l	0
	
	lea		music,a0
	move.l	add,a1
	move.w	#7800,d0
loop:
	move.b	(a0)+,(a1)+
	dbf.w	d0,loop
		
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	moveq	#1,d0
	jsr		add

	move.l	$456,a0
	move.l	#start,4(a0)

	clr.w	-(sp)
	trap	#1
start:
	jsr		add+8
	rts
music:
	incbin	b:\max_7.mus
