; Joiner for split files
;
; Created 16/4/91

chnk_size	equ	8*1024		8K chunks (irrelevant really)

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
	
	lea	filename,a0
.fl	tst.b	(a0)
	beq.s	.fe
	cmp.b	#'.',(a0)
	beq.s	.fe
	addq.w	#1,a0
	bra.s	.fl
.fe	move.b	#'.',(a0)+
	move.l	a0,ext_ptr

	lea	creating,a0
	bsr	print

main_loop
	lea	chnk_txt,a0
	move.l	a0,a1
	move.l	ext_ptr,a2
	moveq	#0,d0
	move.w	chnk_num,d0
	divu	#100,d0
	add.w	#'0',d0
	move.b	d0,(a1)+
	move.b	d0,(a2)+
	clr.w	d0
	swap	d0
	divu	#10,d0
	add.w	#'0',d0
	move.b	d0,(a1)+
	move.b	d0,(a2)+
	swap	d0
	add.w	#'0',d0
	move.b	d0,(a1)
	move.b	d0,(a2)
	bsr	print

	clr.w	-(a7)
	pea	filename
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.l	d0
	bmi	all_read
	move.w	d0,-(a7)
	move.l	start,-(a7)
	pea	$400000
	move.w	d0,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	add.w	#12,a7
	add.l	d0,length
	add.l	d0,start
	move.l	ptrs,a0
	move.l	start,(a0)+
	move.l	a0,ptrs
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7		

	pea	filename		Delete input file
	move.w	#$41,-(a7)
	trap	#1
	addq.l	#6,a7

	addq.w	#1,chnk_num	Next chunk
	bra	main_loop

all_read
	lea	header+12,a0	Convert header to offsets
	move.l	ptrs,d0
	sub.l	#header,d0
	move.l	#buffer,d1
	sub.l	d0,d1
.sub	sub.l	d1,(a0)+
	cmp.l	ptrs,a0
	bne.s	.sub

	move.l	ext_ptr,a0	.dat extender
	move.b	#'d',(a0)+
	move.b	#'a',(a0)+
	move.b	#'t',(a0)

	clr.w	-(a7)		create
	pea	filename
	move.w	#$3c,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.w	d0
	bmi	error

	move.w	d0,d7
	lea	header,a0		write header
	move.l	ptrs,d6
	sub.l	a0,d6
	bsr	write

	lea	buffer,a0		write chunks
	move.l	length,d6
	bsr	write
	
	move.w	d7,-(a7)		Close it up
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	bra	all_done

error
	lea	dead_txt,a0
	bra.s	exit
all_done
	lea	key_exit,a0
exit	bsr	print
	bsr	get_key
	clr.w	-(a7)
	trap	#1

write
	move.l	a0,-(a7)
	move.l	d6,-(a7)
	move.w	d7,-(a7)
	move.w	#$40,-(a7)
	trap	#1
	add.w	#12,a7
	cmp.l	d0,d6
	bne	error
	rts
		

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
ptrs	dc.l	header+16
length	dc.l	0
ext_ptr	dc.l	0

title	dc.b	27,'E'
	dc.b	'Chunky maker by Andy The Arfling',10,13,0
file_in	dc.b	10,13,'Data files to lump : ',0
creating	dc.b	27,'f',10,13,10,13,'Reading chunk : ',0
chnk_txt	dc.b	'000',27,'D',27,'D',27,'D',0
dead_txt	dc.b	27,'e',10,13,10,13,'Fatal error - mission aborted',0
key_exit	dc.b	27,'e',10,13,10,13,'Press any key to quit',10,13,0

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

header	dc.b	'BBB!'
	dc.l	12345678	;original size of file
	dc.l	chnk_size
	dc.l	buffer
	ds.l	399		400 chunks, roughly 3.2 Mb!

buffer