*** Out To binary.
***	By RaY.

debug	equ	1
	opt	d+

	include	"stdlib.s"
	include	"include.s"

	Powerup

	lea	out_bfr(pc),a1
	move.l	a1,d6
	addq	#1,d6

	Fopen	#0,in_file(pc)
	move.l	d0,d7
	bmi.s	line_loop
	Fread	in_bufr,#(15*32768)+1,d7	Read in max no. of bytes
	tst.l	d0				in file(I hope)
	bmi.s	line_loop
	Fclose	d7

	lea	in_bufr,a0
	moveq	#0,d1

line_loop
	move	#3-1,d2
	cmp.b	#"P",(a0)		Program Memory?	Extra code could
	beq.s	pass
	cmp.b	#"X",(a0)		X Memory?	Be put in to deal
	beq.s	pass
	cmp.b	#"Y",(a0)		Y Memory?	With things being
	beq.s	pass
	bra.s	exit			End Of File.	Put in X,Y mem.
pass	addq	#7,a0
loop	bsr	do_it
	move.b	d0,d1
	lsl	#4,d1
	bsr	do_it
	add.b	d0,d1
	move.b	d1,(a1)+
	dbf	d2,loop
	addq.l	#2,a0
	bra.s	line_loop

do_it	move.b	(a0)+,d0
	cmp.b	#57,d0
	ble.s	one_9
	sub.b	#7,d0
one_9	sub.b	#48,d0
	rts

exit	sub.l	d6,a1
	Fcreate	#0,out_fle(pc)		Create Output file
	move.l	d0,d7
	bmi.s	fin
	Fwrite	out_bfr,a1,d7
	tst.l	d0
	bmi.s	fin
	Fclose	d7


fin	Powerdown

in_file	dc.b	"d:\a56.out",0
out_fle	dc.b	"d:\dsp.bin",0
Section BSS
out_bfr	ds.b	(3*32768)		3 bytes/line * 32768(max) words (1 word/line)
in_bufr	ds.b	(15*32768)		15 bytes/line * 32768(max) words (1 word/line)

** Should use Malloc to get *ONLY* as much space as is needed.