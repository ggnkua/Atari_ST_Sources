
	move	#1,-(sp)   ; res ?
 	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp


	move.l	#$f8000,a0	
	move.l	#$8000,d4

	move.l	#199,d6
y_loop
	add.l	#1,y

	move.l	#639,d7
x_loop
	add.l	#1,x

	move.l	x,d0
	sub.l	#512,d0
	move.l	d0,x1

	move.l	#100,d0
	move.l	y,d1
	sub.l	d1,d0
	move.l	d0,y1

	move.l	x1,xc
	move.l	y1,yc

	move.l	#100,d0
i_loop
	move.l	x1,xt
	
* left bracket

	move.l	x1,d1
	
	muls	d1,d1
	divs	#256,d1
	and.l	#$ffff,d1
	ext.l	d1
	move.l	y1,d2
	muls	d2,d2
	muls	#40,d2
	divs	#640,d2
	and.l	#$ffff,d2
	ext.l	d2
	sub.l	d2,d1
	move.l	xc,d2
	add.l	d2,d1

	move.l	d1,x1 * end first calc


* next calc

	move.l	xt,d1
	move.l	y1,d2
	muls	d2,d1
	divs	#128,d1
	and.l	#$ffff,d1
	ext.l	d1
	move.l	yc,d2
	add.l	d2,d1

	move.l	d1,y1 * end 2nd calc

	move.l	x1,d1
	cmp.l	#1024,d1
	bgt	out_set
	cmp.l	#-1024,d1
	blt	out_set

	move.l	y1,d1
	cmp.l	#320,d1
	bgt	out_set
	cmp.l	#-320,d1
	blt	out_set
	*move	#0,d0
	move	#-1,d5
	bra	nojust
out_set
	move	#0,d5
	move	#0,d0
nojust
	dbra	d0,i_loop

	cmp.l	#0,d5
	beq	no_plot
	or.w	d4,2(a0)
no_plot
	
	ror.w	d4
	
	bcc	no_add
	add.l	#4,a0
no_add
	

	dbra	d7,x_loop
	move.l	#-1,x
	dbra	d6,y_loop

	move	#1,-(sp)
	trap	#1
	add.l	#2,sp

	move	#0,-(sp)   ; res ?
 	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp



	clr.w	-(sp)
	trap	#1   *ugh GEM !


x	dc.l	-1
y	dc.l	-1
x1	dc.l	0
y1	dc.l	0
xt	dc.l	0
xc	dc.l	0
yc	dc.l	0


