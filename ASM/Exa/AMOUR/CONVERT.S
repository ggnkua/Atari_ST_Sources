;	init img
	lea	image+18(pc),a2
	lea	start,a1
	
	moveq	#0,d0
	move	#7,d7
loop_all_block

	move.l	a2,a0
	move	#64-1,d2
haut
	move	#128-1,d1	
larg
	move.w	(a0)+,(a1)+
	dbf	d1,larg
	lea	(640*2)-128*2(a0),a0
	dbf	d2,haut
	addq	#1,d0
	cmp	#5,d0
	beq.s	.yes
	lea	128*2(a2),a2
	bra.s	.no
.yes	
	lea	-128*2*4(a2),a2	
	add.l	#(640*2)*64,a2
	moveq	#0,d0
.no
	dbf	d7,loop_all_block

	clr.l	-(sp)
	trap	#1

image
	incbin	d:\morf_de2.tg1
	even
start


