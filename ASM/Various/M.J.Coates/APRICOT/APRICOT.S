***************************************************
* Copy Apricot Single sided disk to Atari ST disk *
*						  *
*      Written by M.J.Coates - February 1987      *
***************************************************

start:	move.l	#stp,sp 	; set stack pointer

	move.l	#mess1,d0 	; insert Apricot disk
	bsr	text
	bsr	space

* Read directory of Apricot disk *

	move.w	#4,count 	; read 4 sectors
	move.w	#2,sector 	; from sector 2
	move.w	#0,track 	;      track 0
	move.l	#cluster,store 	; to cluster store
	bsr	floprd

	move.w	#6,sector 	; now read directory
	move.l	#direct,store 	; first half
	bsr	floprd
	move.w	#1,sector 	; second half
	move.w	#1,track
	add.l	#2048,store
	bsr	floprd

* Unscramble cluster map *

	move.l	#cluster,a0
	move.l	#word,a1

cloop:	bsr	unpack
	addq.l	#3,a0 		; cluster info in groups of 3
	addq.l	#4,a1 		; we copy it into 4's
	cmp.l	#word,a0
	bge	cexit
	bra	cloop
cexit:

* get filename for transfer *

	move.l	#mess2,d0
	bsr	text

	move.l	#direct-32,a6 	; start at first name

ford:	move.l	a6,a5 		; save current name
file1:	add.l	#32,a6
	cmp.l	#cluster,a6 	; end?
	beq	fexit
	move.b	(a6),d0 	; first char of filename
	cmp.b	#$e5,d0 	; file deleted?
	beq	file1
	move.b	11(a6),d0 	; file attribute
	cmp.b	#32,d0 		; normal file
	bne	file1
	bra	filem
fexit:	move.l	a5,a6 		; restore last name
	cmp.l	#direct-32,a6	; were there any files?
	beq	nofile
	bra	filem

back:	move.l	a6,a5 		; save current name
file2:	sub.l	#32,a6
	cmp.l	#direct-32,a6
	beq	fexit
	move.b	(a6),d0
	cmp.b	#$e5,d0 	; deleted file?
	beq	file2
	move.b	11(a6),d0 	; file attribute
	cmp.b	#32,d0
	bne	file2
	
filem:	move.l	#rest,d0 	; restore cursor position
	bsr	text
	clr.l	d4 		; set pointer
file3:	move.b	0(a6,d4.w),d0 	; get letter of filename
	bsr	chrout
	addq.l	#1,d4
	cmp.b	#8,d4 		; extension
	bne	file4
	move.b	#46,d0
	bsr	chrout 		; so print '.'
file4:	cmp.b	#11,d4
	bne	file3

file5:	bsr	chrin 		; wait for keypress
	cmp.l	#$004D0000,d0 	; cursor right
	beq	ford
	cmp.l	#$004B0000,d0 	; cursor left
	beq	back
	cmp.b	#13,d0 		; CR
	beq	rdfile
	cmp.b	#27,d0 		; ESC
	beq	exit
	bra	file5

* Read file into memory *

rdfile:	move.l	#mess4,d0
	bsr	text

	move.l	#file,store 	; start of file store
	move.b	26(a6),filecl+1 ; start cluster lo
	move.b	27(a6),filecl	; 		hi
	move.b	28(a6),filesz+3 ; filesize lo-lo
	move.b	29(a6),filesz+2 ;	   lo-hi
	move.b	30(a6),filesz+1 ;	   hi-lo
	move.b	31(a6),filesz 	;	   hi-hi

	move.l	#fname,a1 	; point to filename
	moveq.l	#0,d0
fn0:	move.b	0(a6,d0.w),d1 	; get char of filename
	cmp.b	#32,d1 		; is it a space
	beq	ignore
	move.b	d1,(a1)+ 	; move to filename + inc pointer
ignore:	addq.b	#1,d0
	cmp.b	#8,d0
	bne	fn1
	move.b	#$2E,(a1)+ 	; add the '.'
fn1:	cmp.b	#11,d0
	bne	fn0
	move.b	#0,(a1)+ 	; and terminate with a 0
	
	move.w	#1,count 	; read 1 sector at a time

floop:	clr.l	d0 		; find track & sector
	move.w	filecl,d0
	add.l	#11,d0 		; start offset
	divu	#9,d0 		; 9 sectors per track
	move.w	d0,track 	; quotient = track
	swap	d0
	addq.w	#1,d0
	move.w	d0,sector 	; remainder = sector

	bsr	floprd 		; read it

	add.l	#512,store 	; increment store

	move.l	#word,a0 	; address of my cluster table
	clr.l	d0
	move.w	filecl,d0 	; last cluster
	asl.l	#1,d0 		; multiply by 2
	move.w	0(a0,d0.w),d1 	; next cluster
	cmp.w	#$FFF,d1
	beq	write		; we've reached the end
	move.w	d1,filecl
	bra	floop

* Now write it to an atari disk *

write:	move.l	#mess5,d0 	; get atari disk
	bsr	text
	bsr	space

* Write file out *

	move.w	#0,-(sp) 	; normal file
	move.l	#fname,-(sp)
	move.w	#$3C,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi	derr 		; disk error
	move.w	d0,handle 	; save file I.D

	move.l	#file,-(sp) 	; start of file buffer
	move.l	filesz,-(sp) 	; file length
	move.w	handle,-(sp) 	; file I.D
	move.w	#$40,-(sp) 	; WRITE
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	derr 		; disk error

	move.w	handle,-(sp)
	move.w	#$3E,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	bmi	derr 		; disk error
	bra	bye

* Disk write error *

derr:	move.l	#err2,d0
	bsr	text
	bra	bye

* No files error *

nofile:	move.l	#err1,d0
	bsr	text

* Exit system *

bye:	move.l	#mess3,d0
	bsr	text
	bsr	space
exit:	clr.l	-(sp)
	trap	#1

* NOW FOR SOMETHING COMPLETELY DIFFERENT - SUBROUTINES *

text:	move.l	d0,-(sp)
	move.w	#9,-(sp) 	; PRINT LINE
	trap	#1
	addq.l	#6,sp
	rts

chrin:	move.w	#1,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

chrout:	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

space:	move.l	#on,d0
	bsr	text

space1:	bsr	chrin
	cmp.w	#27,d0 		; ESCape key?
	beq	exit 		; yes - emergency exit

	cmp.w	#32,d0 		; was is a SPACE
	bne	space1
	move.l	#off,d0
	bra	text

floprd:	move.w	count,-(sp)
	move.w	#0,-(sp) 	; side 0
	move.w	track,-(sp)
	move.w	sector,-(sp)
	move.w	#0,-(sp) 	; drive A
	clr.l	-(sp)
	move.l	store,-(sp)
	move.w	#8,-(sp) 	; FLOPRD
	trap	#14
	add.l	#20,sp
	rts

unpack:	clr.l	d1 		; clusters are stored on disk
	move.b	1(a0),d1 	; in 12 bit formats but for
	move.l	d1,d0 		; ease of access this turns
	and.b	#15,d0 		; into words
	asl.w	#8,d0 		; (ab cd ef -> dab efc )
	clr.l	d3
	move.b	(a0),d3
	add.w	d3,d0
	move.w	d0,(a1) 	; word 1

	clr.l	d0
	lsr.b	#4,d1
	and.b	#15,d1
	move.b	2(a0),d0
	asl.w	#4,d0
	add.w	d1,d0
	move.w	d0,2(a1) 	; and word 2
	rts


* NOW FOR VARIABLES AND MESSAGES *
	even
count:	dc.w	0
track:	dc.w	0
sector:	dc.w	0
store:	dc.l	0
handle:	dc.w	0
filecl:	dc.w	0
filesz:	dc.l	0
	ds.l	512
stp:
fname:	dc.b	"xxxxxxxx.xxx",0
mess1:	dc.b	27,69,"           Single sided Apricot disk to Ata"
	dc.b	"ri file Xfer by M.J.Coates",13,10,10
	dc.b	"         Insert Apricot disk in drive A and p"
	dc.b	"ress SPACE (ESC to quit) ",0
mess2:	dc.b	13,10,10,10,"          "
	dc.b	"Select file using cursor keys, RETURN to accept, "
	dc.b	"ESC to quit",13,10,10,"                       "
	dc.b	"File to Transfer -             ",0
rest:	dc.b	8,8,8,8,8,8,8,8,8,8,8,8,0
mess3:	dc.b	13,10,10,"                            "
	dc.b	"Press SPACE to exit ",0
mess4:	dc.b	13,10,10,10,"                                 "
	dc.b	"Reading file ",27,101,0
err1:	dc.b	13,10,10,10,"                          "
	dc.b	"ERROR - No valid files found",0
on:	dc.b	27,101,0
off:	dc.b	27,102,0
mess5:	dc.b	27,102,13,10,10,10
	dc.b	"         Insert Atari disk in drive A and p"
	dc.b	"ress SPACE (ESC to quit) ",0
err2:	dc.b	13,10,10,10,"           ERROR - A disk has occurre"
	dc.b	"d whilst writing the Atari file",0

* The disk contents will go here *
	even
direct:		ds.b	4096	; disk directory
cluster:	ds.b	2048 	; cluster map
word:		ds.b	3072 	; unscrambled cluster map
file:		ds.w	1	; file buffer
