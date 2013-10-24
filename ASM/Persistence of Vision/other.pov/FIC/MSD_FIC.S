*************************************************************************
*			CRC checking program				*
*			~~~~~~~~~~~~~~~~~~~~				*
*									*
* Written by: MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
* Date: Feb 1997							*
*									*
*************************************************************************
* use POV CRC CALC program to use this version
*************************************************************************
* based on Original pompey file integrity check from PP81
*************************************************************************

	bra	advert
	dc.b	"        POV CRC File Integrity Checker program        "
advert
	clr.l	-(a7)		;set super
	move.w	#$20,-(a7)
	trap	#1

	lea	cls(pc),a0	;clear screen
	bsr	print_string

	lea	filenames(pc),a5
	lea	crc_numbers(pc),a6	;list of CRCs for each file
main_loop
	movea.l	(a5)+,a4	;put address of filename into A4
	cmpa.l	#0,a4		;end of list?
	beq.s	report		;yes

	lea	checking(pc),a0
	bsr	print_string

	movea.l	a4,a0		;print_string filename
	bsr	print_string

	bsr	open_file
	tst.l	d0		;test for good load
	bmi	open_err	;bad open! (file not found)
	move.w	d0,handle	;store handle
	bsr	read_file
	tst.l	d0		;test for good load
	bmi	read_err	;Bad load
	bsr	close_file
	bsr	calc_crc

	move.l	(a6)+,d6	;get CRC from our list
	cmp.l	tempcrc,d6	;compare calculcated CRC with our reference
	beq.s	fileok		;it was ok

;not all files were ok, so we need to increase a counter to show later
	add.b	#1,total	;increase total
	cmp.b	#":",total	;has total gone over 9?
	bne.s	single		;no
	addq.b	#1,badtotal	;yes so make it say 10
	move.b	#"0",total	;clear 0-9
single	lea	badtxt(pc),a0	;now print 'BAD FILE'
	bra.s	notok

fileok	lea	ok_txt(pc),a0
notok	bsr.s	print_string
	bra.s	main_loop

report	lea	allfiletxt(pc),a0
	cmpi.w	#"00",badtotal
	beq.s	fin

	lea	crlf(pc),a0
fin	bsr.s	print_string

	move.w	#7,-(sp)	;get key
	trap	#1
	addq.l	#2,sp

	move.l	4.w,-(sp)	;reset
	rts

print_string	pea	(a0)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

open_file
	clr.w	-(a7)		;select read only
	pea	(a4)		;put filename on stack
	move.w	#$3d,-(a7)	;open file
	trap	#1
	addq.l	#8,a7
	rts

read_file
	pea	loadarea(pc)
	pea	400000		;max bytes to load (400K)
	move.w	handle,-(sp)	;file handle
	move.w	#$3f,-(sp)	;read file
	trap	#1
	lea	12(sp),sp
	move.l	d0,filelength
	rts

close_file
	move.w	handle,-(a7)	;handle
	move.w	#$3e,-(a7)	;close file
	trap	#1
	addq.l	#4,a7
	rts

calc_crc
	lea	loadarea(pc),a0
	move.l	filelength,d1	;number of bytes read
	moveq	#0,d0
.crc	add.b	(a0)+,d0	;add byte from file to total
	rol.l	#1,d0
	subq.l	#1,d1		;sub 1 from file length
	bne.s	.crc		;do loop
	move.l	d0,tempcrc	;total
	rts

open_err
	lea	erroropen(pc),a0
	bra	fin

read_err
	lea	errorread(pc),a0
	bra	fin

	section	data
filenames	;put your points to the filenames here...
	dc.l	file1
	dc.l	file2
	dc.l	file3
	dc.l	file4
	dc.l	file5
	dc.l	file6
	dc.l	file7
	dc.l	file8
	dc.l	file9
	dc.l	file10
	dc.l	file11
	dc.l	file12
	dc.l	0	;put this at the end of the filenames


crc_numbers	;these are the CRCs created from the POV CRC program
		dc.l	$784be7ea
		dc.l	$619b63b1	;should be $619b63b2
		dc.l	$6fdfc5ae
		dc.l	$0badbad0	;purposeful errors
		dc.l	$0badbad0
		dc.l	$badbadba
		dc.l	$badbadba
		dc.l	$0badbad0
		dc.l	$0badbad0
		dc.l	$0badbad0
		dc.l	$0badbad0
		dc.l	$0badbad0


file1	dc.b	'a:\test.txt',0
file2	dc.b	"groden.prg",0
file3	dc.b	"atom-35+.prg",0
file4	dc.b	'test.txt',0
file5	dc.b	'test.txt',0
file6	dc.b	'test.txt',0
file7	dc.b	'test.txt',0
file8	dc.b	'test.txt',0
file9	dc.b	'test.txt',0
file10	dc.b	'test.txt',0
file11	dc.b	'test.txt',0
file12	dc.b	'test.txt',0
	even



ok_txt	dc.b	' : OK',13,10,10,0
badtxt	dc.b	7,' : ',27,'b1BAD!',27,'b',$f,7,13,10,10,0
crlf	dc.b	13,10
badtotal	dc.b	'0'
total	dc.b	'0 file(s) are corrupt - recopy!',7,0

allfiletxt
	dc.b	13,10,10,'All files checked out OK!',0

checking	dc.b	'Checking: ',0

cls	dc.b	27,'E',0

erroropen	dc.b	13,10,10,7,'Error opening file!',0
errorread	dc.b	$d,$a,$a,7,'Error reading file!',0,0

	section bss
handle		ds.w	1
filelength	ds.l	1
tempcrc		ds.l	1
loadarea	ds.b	400000
