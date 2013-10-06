; Ram disk dumper for Andyload
;
; Created 27/10/90

chnk_size	equ	8*1024		8K chunks

	move.l	a7,a0
	lea	stack,a7
	move.l	a0,-(a7)

	lea	title,a0
	bsr	print

get_inp
	lea	file_in,a0
	bsr	print
	lea	buffer1,a0
	bsr	input
	tst.w	d0
	beq.s	get_inp
	
	clr.w	-(a7)
	pea	filename
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7
	move.w	d0,-(a7)
	pea	buffer
	pea	$400000
	move.w	d0,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	add.w	#12,a7
	move.l	d0,length
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7		

	lea	filename,a0
.find_ex	cmp.b	#'.',(a0)		Has it already got extender?
	beq.s	.ext
	tst.b	(a0)+
	bne.s	.find_ex
	move.b	#'.',-(a0)	No, so add one
.ext
	lea	num_in,a0
	bsr	print
	lea	buffer2,a0
	bsr	input
	moveq	#0,d7		Number entered
	lea	chnk_inp,a0
.inp_num	subq.w	#1,d0
	bmi.s	.done
	mulu	#10,d7
	moveq	#0,d1
	move.b	(a0)+,d1	
	sub.w	#'0',d1
	add.w	d1,d7
	bra.s	.inp_num
.done	move.w	d7,chnk_num

	lea	creating,a0
	bsr	print

	pea	filename		Delete input file
	move.w	#$41,-(a7)
	trap	#1
	addq.l	#6,a7

main_loop
	move.l	length,d7
	beq	all_done
	cmp.l	#chnk_size,d7
	blt.s	.last
	move.l	#chnk_size,d7
.last	sub.l	d7,length

	lea	chnk_txt,a0
	move.l	a0,a1
	moveq	#0,d0
	move.w	chnk_num,d0
	divu	#100,d0
	add.w	#'0',d0
	move.b	d0,(a1)+
	clr.w	d0
	swap	d0
	divu	#10,d0
	add.w	#'0',d0
	move.b	d0,(a1)+
	swap	d0
	add.w	#'0',d0
	move.b	d0,(a1)
	bsr	print

	lea	filename,a0
.f_dot	cmp.b	#'.',(a0)+	Find extender
	bne.s	.f_dot
.found	move.b	chnk_txt,(a0)+	Change it to chunk number
	move.b	chnk_txt+1,(a0)+
	move.b	chnk_txt+2,(a0)

	clr.w	-(a7)
	pea	filename
	move.w	#$3c,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.w	d0
	bmi	error
	move.w	d0,-(a7)
	move.l	start,-(a7)
	move.l	d7,-(a7)
	add.l	d7,start
	move.w	d0,-(a7)
	move.w	#$40,-(a7)
	trap	#1
	add.w	#12,a7
	cmp.l	d0,d7
	bne	error
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7

	addq.w	#1,chnk_num
	bra	main_loop

error
	lea	dead_txt,a0
	bra.s	exit
all_done
	lea	key_exit,a0
exit	bsr	print
	bsr	get_key
	clr.w	-(a7)
	trap	#1
		
print
	move.l	a0,-(a7)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts

input
	move.l	a0,-(a7)
	move.w	#10,-(a7)
	trap	#1
	addq.l	#6,a7
	rts

get_key
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

chnk_num	dc.w	0
start	dc.l	buffer
length	dc.l	0

title	dc.b	27,'E'
	dc.b	'Chunky maker by Andy The Arfling',10,13,0
file_in	dc.b	10,13,'Data file to chunk : ',0
num_in	dc.b	10,13,'Initial chunk number (Default 0) : ',0
creating	dc.b	10,13,10,13,'Creating chunk : ',0
chnk_txt	dc.b	'000',27,'D',27,'D',27,'D',0
dead_txt	dc.b	10,13,10,13,'Fatal error - mission aborted',0
key_exit	dc.b	10,13,10,13,'Press any key to quit',10,13,0

	even

	ds.b	$100
stack

buffer2	dc.b	3		max no. of chars
	dc.b	0		
chnk_inp	dc.b	'000'

buffer1	dc.b	16		max no. of chars
	dc.b	0		
filename	ds.b	16

	even
buffer