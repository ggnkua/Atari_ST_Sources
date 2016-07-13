start
	lea	img(pc),a0	
	lea	img_16,a1
	lea	palette(pc),a2
	pea	(a2)
	pea	(a1)
	bsr	tg1_format
	move.l	(sp)+,a1
	bsr	convert_into_4_plan
	move.l	(sp)+,a2
	bsr	convert_palette
	rts

tg1_format
	lea	12(a0),a0
	movem.w	(a0)+,d0-d1	;x y
	lea	2(a0),a0
	move.l	a0,ptr_tg1
	clr	nb_color
	bsr	search_all_color
	rts

search_all_color
	movem.w	d0-d1,x_larg
	lea	buffer(pc),a1
	move.l	a1,a2
	mulu	d0,d1
.loop
	lea	buffer(pc),a1
	move	nb_color(pc),d2
	move	(a0)+,d0
	subq	#1,d2
	bmi.s	.no_find_same_color
.no_find
	cmp	(a1)+,d0
	dbeq	d2,.no_find
	bne.s	.no_find_same_color
	subq.l	#1,d1
	bne.s	.loop
	rts
.no_find_same_color
	move	d0,(a2)+
	addq	#1,nb_color
	subq.l	#1,d1
	bne.s	.loop
	rts

num_col	macro
	moveq	#-1,d1
	move.l	a2,a3
	move	(a0)+,d0
*-6
	addq	#1,d1
	cmp	(a3)+,d0
	bne.s	*-4
	endm

convert_into_4_plan
	move.l	ptr_tg1(pc),a0
	lea	buffer(pc),a2
	move	y_larg(pc),-(sp)
.loop2
	move	x_larg(pc),d7
	lsr	#4,d7
	subq	#1,d7
.loop3
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#$f,d6
.loop_i
	num_col
	swap	d2
	lsr	d1
	addx	d2,d2

	swap	d2
	lsr	d1
	addx	d2,d2

	swap	d3
	lsr	d1
	addx	d3,d3

	swap	d3
	lsr	d1
	addx	d3,d3

	lsr	d1
	addx	d4,d4

	dbf	d6,.loop_i
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.w	d4,(a1)+
	dbf	d7,.loop3
	subq	#1,(sp)
	bne	.loop2
	lea	2(sp),sp
	rts

convert_palette
	lea	buffer(pc),a0
	move	nb_color(pc),d7
	subq	#1,d7
.loop
	move	(a0)+,d0
	move	d0,d1
	move	d1,d2
	lsr	#6,d0
	lsr	#5,d0
	lsl	#3,d0
	move.b	d0,(a2)+
	lsr	#5,d1
	lsl	#2,d1
	move.b	d1,(a2)+
	clr.b	(a2)+
	lsl	#3,d2
	move.b	d2,(a2)+
	dbf	d7,.loop
	rts
	
	
	
ptr_tg1	ds.l	1
x_larg	ds	1
y_larg	ds	1
buffer	ds.w	256	;256 couleur tru color.
palette	ds.L	256
nb_color	ds	1
img
	incbin	babies.tg1
	even		
img_16
	ds.b	60000
	
	
	
	
	
	
	
	
	
	
	
	