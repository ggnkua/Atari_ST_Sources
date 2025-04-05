ifw:		equ	172
ifh:		equ	144
ofw:		equ	160
ofh:		equ	134
frames:		equ	10

*************************************************
*	Little prog to resize the frames to	*
*	160x134					*
*	writes out file smlmvie.dat		*
*************************************************
start:
	bsr	openfiles
	move.w	#ifw,width
	move.w	#ifh,height

	move.w	#frames,d7
rloop:
	move.l	d7,-(sp)
	bsr	getframe
	bsr	resizeframe
	bsr	writeframe
	move.l	(sp)+,d7
	dbf	d7,rloop

	bsr	closefiles
exit:
	clr.w	-(sp)
	trap	#1



resizeframe:
	lea	inpic,a0
	add.l	#12,a0		;move across 6 pixels
	lea	outpic,a1
	move.w	#ofh-1,d0
rsl1:
	move.w	#ofw-1,d1
	move.l	a0,a2
rsl2:
	move.w	(a0)+,(a1)+
	dbf	d1,rsl2
	add.l	#(ifw*2),a2
	move.l	a2,a0
	dbf	d0,rsl1
	rts







	move.w	#ofw,d0
	fmove.w	d0,fp2
	fdiv.s	#172,fp2
	move.w	#ofh,d0
	fmove.w	d0,fp3
	fdiv.s	#144,fp3

	fmove.w	height,fp4
	fmul	fp3,fp4
	fmove.w	fp4,d1
	subq.w	#1,d1
yloop:
	fmove.w	width,fp5
	fmul	fp2,fp5
	fmove.w	fp5,d0
	subq.w	#1,d0
xloop:
	fmove.w	d0,fp0
	fmove.w	d1,fp1
	fdiv	fp2,fp0
	fdiv	fp3,fp1
	fmove.w	fp0,pixelx
	fmove.w	fp1,pixely
	bsr	getpoint
	
	move.w	d0,pixelx
*	add.w	#100,pixelx
	move.w	d1,pixely
	bsr	putpoint
	dbf	d0,xloop
	dbf	d1,yloop
	rts

getpoint:
	lea	inpic,a0
	move.w	pixelx,d7
	add.w	d7,d7
	move.w	pixely,d6
	mulu	#ifw*2,d6
	add.w	d6,d7
	move.w	(a0,d7.w),pixelcolor
	rts
putpoint:
	lea	outpic,a0
	move.w	pixelx,d7
	add.w	d7,d7
	move.w	pixely,d6
	mulu	#ofw*2,d6
	add.w	d6,d7
	move.w	pixelcolor,(a0,d7.w)
	rts


openfiles:
	move.w	#0,-(sp)
	move.l	#fname,-(sp)
	move.w	#$3D,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,handle

	move.w	#$0,-(sp)
	move.l	#ofname,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,ohandle
	rts

getframe:
	pea	inpic
	move.l	#(ifw*ifh*2),-(sp)
	move.w	handle,-(sp)	;and read it in
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	rts
writeframe:
	pea	outpic
	move.l	#(ofw*ofh*2),-(sp)
	move.w	ohandle,-(sp)	;and read it in
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	rts

closefiles:
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	move.w	ohandle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

fname:
	dc.b	'cmovie.dat',0
ofname:	dc.b	'smlmvie.dat',0
	even

handle:		dc.w	0
ohandle:	dc.w	0
pixelcolor:	dc.w	0
pixelx:		dc.w	0
pixely:		dc.w	0
width:		dc.w	0
height:		dc.w	0

	section	BSS
inpic:	ds.w	ifw*ifh

	ds.w	50000
outpic:
	ds.w	ofw*ofh
	ds.w	50000