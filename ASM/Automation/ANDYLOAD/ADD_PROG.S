; Ram disk dumper for Andyload
;
; Created 27/10/90

start
	lea	title,a0
	bsr	print

	lea	ask_data,a5
	lea	buffer1,a6
	bsr	enter_txt
	lea	ask_prog,a5
	lea	buffer2,a6
	bsr	enter_txt
	lea	ask_game,a5
	lea	buffer3,a6
	bsr	enter_txt
	lea	buffer3,a0
	bsr	centre_txt
	lea	ask_hack,a5
	lea	buffer4,a6
	bsr	enter_txt
	lea	buffer4,a0
	bsr	centre_txt
	lea	ask_this,a5
	lea	buffer5,a6
	bsr	enter_txt
	
	lea	prog,a6

	lea	dataname,a0
	move.w	#11,d0
	moveq	#$20,d1
	bsr	copyprog	
	lea	progname,a0
	move.w	#11,d0
	moveq	#$2d,d1
	bsr	copyprog	
	lea	gamename,a0
	move.w	#39,d0
	moveq	#$60,d1
	bsr	copyprog	
	lea	hackname,a0
	move.w	#39,d0
	move.w	#$b0,d1
	bsr	copyprog	

retry
	clr.w	-(a7)
	pea	thisname
	move.w	#$3c,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.l	d0
	bmi	f_error1
	
	move.w	d0,d7
	pea	prog
	pea	prog_end-prog
	move.w	d7,-(a7)
	move.w	#$40,-(a7)
	trap	#1
	lea	12(a7),a7
	cmp.l	#prog_end-prog,d0
	bne	f_error2

	bsr	close	

	lea	alldone,a0
exit	
	bsr	print
	lea	key_exit,a0
	bsr	print
	bsr	get_key
	clr.w	-(a7)
	trap	#1

f_error1
	lea	f_err1,a0
	bra.s	f_error
f_error2
	bsr	close
	lea	f_err2,a0
f_error
	bsr	print
	lea	f_err,a0	
	bsr	print
	bsr	get_key
	bra	retry

close	
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7	
	rts

print
	move.l	a0,-(a7)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts

get_key
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

enter_txt
	move.l	a5,a0
	bsr	print
	move.l	a6,-(a7)
	move.w	#10,-(a7)
	trap	#1
	addq.l	#6,a7
	tst.w	d0
	beq.s	enter_txt
	rts

centre_txt
	moveq	#0,d0
	move.b	1(a0),d0
	moveq	#40,d1
	sub.w	d0,d1
	lsr.w	#1,d1		d1=spaces to add to front
.add	tst.w	d1
	beq.s	.done
	moveq	#39,d0
.loop	move.b	2(a0,d0.w),d2
	move.b	d2,3(a0,d0.w)
	subq.w	#1,d0
	bpl.s	.loop
	move.b	#' ',2(a0)
	subq.w	#1,d1
	bra.s	.add
.done	rts

copyprog
	move.b	(a0)+,0(a6,d1.w)
	addq.w	#1,d1
	dbf	d0,copyprog
	rts


buffer1	dc.b	16		max no. of chars
	dc.b	0		
dataname	ds.b	16

buffer2	dc.b	16		max no. of chars
	dc.b	0		
progname	ds.b	16

buffer3	dc.b	40		max no. of chars
	dc.b	0		
gamename	dcb.b	40,' '

buffer4	dc.b	40		max no. of chars
	dc.b	0		
hackname	dcb.b	40,' '

buffer5	dc.b	16		max no. of chars
	dc.b	0		
thisname	ds.b	16

title	dc.b	27,'E'
	dc.b	'     BBC program adder for Andyload',10,13,0

ask_prog	dc.b	10,13,'Enter filename of program file of game',10,13,0
ask_data	dc.b	10,13,'Enter filename of packed data file',10,13,0
ask_game	dc.b	10,13,'Enter name of game',10,13,0
ask_hack	dc.b	10,13,'Enter your pseudonym',10,13,0
ask_this	dc.b	10,13,'Enter filename for this program',10,13,0

alldone	dc.b	10,13,10,13,'Program saved OK',10,13,10,13,0
f_err1	dc.b	10,13,'Error creating file',10,13,0
f_err2	dc.b	10,13,'Error writing file',10,13,0
f_err	dc.b	'Press any key to retry',10,13,0
key_exit	dc.b	'Press any key to quit',10,13,0

	even

prog	incbin	'andyload.prg'
prog_end