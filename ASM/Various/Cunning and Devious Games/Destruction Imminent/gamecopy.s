	*File copier program

	move.l	#names,a6		Address of file names
	move.l	#filesize,a5	Address of file sizes
	move.w	numfile,d7	Number of files
	sub.w	#1,d7		Count from zero

nextfile	nop

	move.l	a6,a0		Address of file to load
	lea	13(a6),a6		Move to next name
	move.l	(a5)+,d2		Size of file
	move.l	#buffer,a1	Destination address
	bsr	loaddata		Load in file

	divu.w	#512,d2		Find number of sectors needed
	move.l	#buffer,a4	Source address
	move.w	d2,d6		Set up a counter
	move.w	d2,size		Size of file
	add.w	#1,size		Count from 1

	move.w	#1,-(sp)
	trap	#1
	addq.l	#2,sp
	
writeloop	move.w	#1,-(sp)		Write one sector
	move.w	side,-(sp)	Side to write
	move.w	track,-(sp)	Track to write
	move.w	sector,-(sp)	Sector to write
	clr.w	-(sp)		Drive A
	clr.l	-(sp)		Filler
	move.l	a4,-(sp)		Source address
	move.w	#9,-(sp)		Function number
	trap	#14		Call XBIOS
	add.l	#20,sp		Correct stack

	lea	512(a4),a4	Move up buffer
	add.w	#1,sector		Move to next sector
	cmp.w	#10,sector	Next track yet?
	bne	posfound		No, skip next bit
	move.w	#1,sector		Back to sector 1
	add.w	#1,track		Move up track counter
	cmp.w	#80,track		Next side yet?
	bne	posfound		No, skip next bit
	move.w	#0,track		Move back to track 0
	move.w	#1,side		Move to side 1

posfound	dbf	d6,writeloop	Write next sector

	clr.w	-(sp)
	trap	#1

	*A:\LOADER.S
	*******************************
	*loaddata - reads in data file*
	*   a0 = address of filename  *
	*   a1 = destination address  *
	*  d2 = size of file in bytes *
	*      corrupts d0-d1/a0      *
	*******************************

loaddata	move.w	#2,-(sp)		Open File
	move.l	a0,-(sp)		Address of filename
	move.w	#$3d,-(sp)	Function Number
	trap	#1		Call GEMDOS
	addq.l	#8,sp		Clean up stack
	move.w	d0,d1		Store file handle

	move.l	a1,-(sp)		Address to store data
	move.l	d2,-(sp)		Number of bytes to read
	move.w	d1,-(sp)		File handle
	move.w	#$3f,-(sp)	Function Number
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack

	move.w	d1,-(sp)		File handle
	move.w	#$3e,-(sp)	Function number
	trap	#1		Call GEMDOS
	addq.l	#4,sp		Correct stack
	rts			Return

	even
	dc.b	"Side"
side	dc.w	1,0		Start with side 1
	dc.b	"Trck"
track	dc.w	56,0		Track 56
	dc.b	"Sctr"
sector	dc.w	2,0		Sector 2
	dc.b	"Size"
size	dc.w	0,0

numfile	dc.w	1		Number of files

names	dc.b	"d:\GAME.DAT",0,0,0,0,0
	even

filesize	dc.l	60000

buffer