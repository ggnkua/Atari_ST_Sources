image:		equ	$70000
buffer1:	equ	$68000
buffer2:	equ	$60000
free1:		equ	$20000
free2:		equ	$28000

;
; load tyranos4.pi1
;

	lea	$78000,sp

	clr	-(sp)
	pea	file(pc)
	move	#$3d,-(sp)
	trap	#1
	addq	#8,sp

	move	d0,d7
	pea	palette(pc)
	pea	34.w
	move	d7,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp

	pea	image
	pea	32000.w
	move	d7,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp

	move	d7,-(sp)
	move	#$3e,-(sp)
	trap	#1
	addq	#4,sp

	move.l	#free1,source
	move.l	#free2,datas

	lea	image,a0
	lea	buffer1,a1
	lea	buffer2,a2
	move.l	a1,buffer
	move.l	a2,cmpbuf

	move	#32000/4-1,d0
copy:	move.l	(a0)+,d1
	move.l	d1,(a1)+
	move.l	d1,(a2)+
	dbra	d0,copy

	clr	decalage
more:	bsr.s	decale		;decale (buffer)
	bsr.L	compact		;compacte (buffer) par rapport … (cmpbuf)
	move.l	buffer(pc),d0
	move.l	cmpbuf(pc),d1
	move.l	d1,buffer
	move.l	d0,cmpbuf
	addq	#1,decalage
	cmp	#16,decalage
	blo.s	more
	bsr.s	save

	illegal

save:
	rts
; create
	clr	-(sp)
	pea	fileout(pc)
	move	#$3c,-(sp)
	trap	#1
	addq	#8,sp
	move	d0,handle
; save
; puis close
	move	handle(pc),-(sp)
	move	#$3e,-(sp)
	trap	#1
	addq	#4,sp
	rts

decale:
	move.l	buffer(pc),a0
	move	#200-1,d1	;compteur de lignes
plan1:	moveq	#3,d0		;compteur de plans
plan2:
	lsr	#1,(a0)
	roxr	#1,4(a0)
	roxr	#1,8(a0)
	roxr	#1,12(a0)
	roxr	#1,16(a0)
	roxr	#1,20(a0)
	roxr	#1,24(a0)
	roxr	#1,28(a0)
	roxr	#1,32(a0)
	roxr	#1,36(a0)
	roxr	#1,40(a0)
	roxr	#1,44(a0)
	roxr	#1,48(a0)
	roxr	#1,52(a0)
	roxr	#1,56(a0)
	roxr	#1,60(a0)
	roxr	#1,64(a0)
	roxr	#1,68(a0)
	roxr	#1,72(a0)
	roxr	#1,76(a0)
	roxr	#1,80(a0)
	roxr	#1,84(a0)
	roxr	#1,88(a0)
	roxr	#1,92(a0)
	roxr	#1,96(a0)
	roxr	#1,100(a0)
	roxr	#1,104(a0)
	roxr	#1,108(a0)
	roxr	#1,112(a0)
	roxr	#1,116(a0)
	roxr	#1,120(a0)
	roxr	#1,124(a0)
	roxr	#1,128(a0)
	roxr	#1,132(a0)
	roxr	#1,136(a0)
	roxr	#1,140(a0)
	roxr	#1,144(a0)
	roxr	#1,148(a0)
	roxr	#1,152(a0)
	roxr	#1,156(a0)
	addq	#2,a0
	dbra	d0,plan2
	lea	160-8(a0),a0
	dbra	d1,plan1
	rts

compact:
	move.l	buffer(pc),a0
	move.l	cmpbuf(pc),a1
	move.l	source(pc),a2
	move.l	datas(pc),a3

	lea	32000(a0),a4
	moveq	#80-1,d7		;nb plans
comp0:	bsr.s	comp1
	lea	-32000+2(a0),a0
	lea	-32000+2(a1),a1
	dbra	d7,comp0
	move.l	a2,source
	move.l	a3,datas
	rts

comp1:
	move	(a0),d0
	cmp	(a1),d0
	beq.s	skipbyte
	moveq	#-1,d1
comp2:	addq	#1,d1
	move	d0,(a3)+
	lea	160(a0),a0
	lea	160(a1),a1
	cmp.l	a4,a0
	bhs.s	finirep
	cmp	#$7f,d1
	beq.s	finirep
	move	(a0),d0
	cmp	(a1),d0
	bne.s	comp2
	move	160(a0),d2
	cmp	160(a1),d2
	bne.s	comp2
	move.b	d1,(a2)+
	bra.s	skipbyte
finirep:
	move.b	d1,(a2)+
	cmp.l	a4,a0
	blo.s	comp1
	rts
skipbyte:
	moveq	#0,d1
comp3:
	subq	#1,d1
	lea	160(a0),a0
	lea	160(a1),a1
	cmp.l	a4,a0
	bhs.s	finirep
	cmp.b	#$80,d1
	beq.s	finirep
	move	(a0),d0
	cmp	(a1),d0
	beq.s	comp3
	move.b	d1,(a2)+
	bra.s	comp1

palette:
	blk.b	34

file:	dc.b	'TYRANOS4.PI1'
	dc.b	0

fileout:
	dc.b	'TYRANOS.BIT'
	dc.b	0

	even
buffer:	dc.l	0
cmpbuf:	dc.l	0
source:	dc.l	0
datas:	dc.l	0
decalage:
	dc.w	0
handle:	dc.w	0

