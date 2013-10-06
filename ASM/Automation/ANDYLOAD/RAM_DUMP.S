; Ram disk dumper for Andyload
;
; Created 27/10/90

start
	lea	title,a0
	bsr	print

	pea	get_ram
	move.w	#$26,-(a7)
	trap	#$e
	addq.l	#6,a7

	move.l	ram_pos,a0
	cmp.l	#$400000,a0
	blt.s	ram_in
	lea	no_ram,a0
	bra	exit
ram_in	
	lea	file_in,a0
	bsr	print
	pea	buffer
	move.w	#10,-(a7)
	trap	#1
	addq.l	#6,a7
	tst.w	d0
	beq.s	ram_in
	
retry
	clr.w	-(a7)
	pea	filename
	move.w	#$3c,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.l	d0
	bmi	f_error1
	
	move.w	d0,d7
	move.l	ram_pos,a0
	move.l	$14554-$144c4(a0),-(a7)	Ram disk start
	move.w	$14566-$144c4(a0),d6	Clusters for data
	add.w	d6,d6			
	add.w	$14564-$144c4(a0),d6	Extra sectors
	mulu	#$200,d6
	move.l	d6,-(a7)
	move.w	d7,-(a7)
	move.w	#$40,-(a7)
	trap	#1
	lea	12(a7),a7
	cmp.l	d0,d6
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

get_ram
	move.l	$472.w,ram_pos
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

ram_pos	dc.l	0		Contents of $472
buffer	dc.b	16		max no. of chars
	dc.b	0		
filename	ds.b	16

title	dc.b	27,'E'
	dc.b	'    BBC ram disk dumper for Andyload',10,13,0
no_ram	dc.b	10,13,'No ram disk in memory!',10,13,10,13,0
file_in	dc.b	10,13,'Filename to save as : ',0
alldone	dc.b	10,13,'Ram disk saved OK',10,13,10,13,0
f_err1	dc.b	10,13,'Error creating file',10,13,0
f_err2	dc.b	10,13,'Error writing file',10,13,0
f_err	dc.b	'Press any key to retry',10,13,0
key_exit	dc.b	'Press any key to quit',10,13,0
