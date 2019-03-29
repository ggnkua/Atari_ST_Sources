* COPY1.S
*
* Example program for Assembly Line
*
* Use the GEM File Selector to copy a file
*
* By Charles F. Johnson
* Copyright 1989 ST-Log
*

* Last revision: Friday, February 3, 1989  10:18:34 am

	.text

	move.l	4(sp),d1	; Get address of basepage
	lea	ustack,sp	; Set up my stack
	move.l	#prgend,d0	; Address of end of this program
	sub.l	d1,d0		; Get the length of this program

	move.l	d0,-(sp)	; Push length of area to reserve
	move.l	d1,-(sp)	; Push start address of area
	clr	-(sp)		; Not used, but necessary
	move	#$4A,-(sp)	; Mshrink
	trap	#1
	lea	12(sp),sp	; Tidy up the stack
	tst	d0		; Error?
	bpl.s	getdrv

	lea	cantshrnk(pc),a5
	bsr	print
	bra	byebye		; If this fails, we flee in terror

* Set up default path specification for fsel_input

getdrv:	move	#$19,-(sp)	; Get current drive (returned in d0)
	trap	#1
	addq	#2,sp
	add.b	#'A',d0		; Convert to ASCII
	lea	copy_dir,a6	; Get address of fsel_input path string
	move.b	d0,(a6)+	; Put in the drive letter
	move.b	#':',(a6)+	; Followed by a colon

	clr	-(sp)		; Get path for current drive
	move.l	a6,-(sp)	; Put it right after the colon
	move	#$47,-(sp)	; Dgetpath
	trap	#1
	addq	#8,sp

	lea	copy_dir,a0	; Address of directory
.loop:	tst.b	(a0)+		; Find the end of the pathname string
	bne	.loop		; Loop til we get a zero
	subq	#1,a0		; Back up one character
	lea	spec(pc),a1	; Address of search spec string
.loop1:	move.b	(a1)+,(a0)+	; Tack the search spec to the end of the path
	bne	.loop1		; Keep moving til we get a zero

	lea	title(pc),a5	; Clear screen and print title
	bsr	print

* Get the first filename (the source file)

	lea	src_msg(pc),a5
	bsr	print

	lea	copy_dir,a4	; Address of path line
	lea	copy_file,a5	; Address of filename line
	bsr	fsel_input	; Call fsel_input
	bpl.s	src_2		; Returns with condition code set

fsel_cancel:
	lea	cancel(pc),a5
	bsr	print
	bra	byebye

src_2:	lea	source,a0	; Location which will hold the source filename
	lea	copy_dir,a1	; Get address of fsel directory line
	lea	copy_file,a2	; Address of fsel selection line
	bsr	make_name	; Construct the full pathname

* Now get the destination filename

	lea	dst_msg(pc),a5
	bsr	print

	lea	copy_dir,a4
	lea	copy_file,a5
	bsr	fsel_input
	bmi	fsel_cancel

	lea	dest,a0
	lea	copy_dir,a1
	lea	copy_file,a2
	bsr	make_name

	move	#0,d5		; Search for normal files
	lea	source,a5	; Address of source filename
	bsr	fsfirst		; Search for it
	beq.s	get_free

	lea	cantfind(pc),a5
	bsr	print
	bra	byebye		; If we didn't find it, bye bye

get_free:
	move.l	#-1,-(sp)	; -1 = Return free memory
	move	#$48,-(sp)	; Malloc
	trap	#1
	addq	#6,sp

	cmp.l	dta+26,d0	; Compare size of file with amount of free RAM
	blo.s	no_memory

	move.l	dta+26,-(sp)	; Allocate enough memory to hold the entire
	move	#$48,-(sp)	; file
	trap	#1
	addq	#6,sp
	tst.l	d0		; Test for error
	bne.s	gotram

no_memory:
	lea	no_ram(pc),a5	; If zero, scram
	bsr	print
	bra	byebye

gotram:	move.l	d0,copy_buffer	; Save address of buffer

	lea	copying(pc),a5
	bsr	print

	clr	d0		; Open the source file in "READ" mode
	lea	source,a0
	bsr	open_file
	bmi	bad_open

	move	d0,handle	; Save the file handle
	move.l	dta+26,d0	; Read this many bytes
	move.l	copy_buffer,a0	; Into our malloc'ed buffer
	bsr	read_file
	move.l	d0,d7		; Save status in d7 temporarily

	bsr	close_file	; Close the file
	tst.l	d7		; Was the read successful?
	bmi.s	bad_read	; I guess not

	pea	dest		; First delete the destination file
	move	#$41,-(sp)	; (we really oughtta ask first!)
	trap	#1
	addq	#6,sp		; We'll ignore errors from this call

	move	#0,d0		; Try to create the destination file
	lea	dest,a0		; with R/W status
	bsr	create_file
	bmi.s	bad_create	; If error, bye bye

	move	d0,handle	; Save file handle

	move.l	dta+26,d0	; Write this many bytes (size of the file)
	move.l	copy_buffer,a0	; From our malloc'ed buffer
	bsr	write_file
	move.l	d0,d7		; Save status

	bsr	close_file	; Close the file
	tst.l	d7		; Was the write successful?
	bmi.s	bad_write	; Nope

	lea	finished(pc),a5	; Completion message
outta_here:
	bsr.s	print

	move.l	copy_buffer,-(sp) ; Remember to de-allocate the buffer!
	move	#$49,-(sp)	; Mfree
	trap	#1
	addq	#6,sp

byebye:
	lea	hitakey(pc),a5	; Prompt for keypress
	bsr.s	print
	bsr.s	getkey		; Wait for it

	clr	-(sp)		; We now return control of your computer
	trap	#1		; to you

* Errors end up here

bad_open:
	lea	cantopen(pc),a5
	bra	outta_here
bad_read:
	lea	cantread(pc),a5
	bra	outta_here
bad_create:
	lea	cantcreat(pc),a5
	bra	outta_here
bad_write:
	lea	cantwrit(pc),a5
	bra	outta_here

* -------------
*  Subroutines
* -------------

* Print a line of text
*
* Enter with:
* a5 -> text to print
* device = device number
*
* Preserves a5
* Clobbers a0-a4/d0-d2

print:	dc.w	$A00A		; Hide mouse
	moveq	#0,d0		; Make sure this is zero
	move.l	a5,a4
print2:	move.b	(a4)+,d0	; Get character
	beq.s	p_x		; If zero, exit
	move	d0,-(sp)	; Print it with bconout
	move	device(pc),-(sp)
	move	#3,-(sp)
	trap	#13
	addq	#6,sp
	bra	print2		; Keep looping til done
p_x:	dc.w	$A009		; Show the mouse
	rts

getkey:	dc.w	$A00A		; Hide mouse
	move	#2,-(sp)	; Get a key with bconin
	move	#2,-(sp)
	trap	#13
	addq	#4,sp
	move.l	d0,-(sp)	; Save it
	dc.w	$A009		; Show mouse
	move.l	(sp)+,d0	; Get the character back
	rts

fsfirst:
	pea	dta		; First set the dta address
	move	#$1A,-(sp)
	trap	#1
	addq	#6,sp
	move	d5,-(sp)	; File attributes to search for
	move.l	a5,-(sp)	; Address of search spec
	move	#$4E,-(sp)	; Fsfirst
	trap	#1
	addq	#8,sp
	tst.l	d0
	rts

open_file:
	move	d0,-(sp)	; Mode - 0=read, 1=write, 2=R/W
	move.l	a0,-(sp)	; Address of filename
	move	#$3D,-(sp)	; Fopen
	trap	#1
	addq	#8,sp
	tst.l	d0
	rts

create_file:
	move	d0,-(sp)	; File attributes
	move.l	a0,-(sp)	; Filename
	move	#$3C,-(sp)	; Fcreate
	trap	#1
	addq	#8,sp
	tst.l	d0
	rts

read_file:
	move.l	a0,-(sp)	; Address of buffer
	move.l	d0,-(sp)	; Number of bytes to read
	move	handle,-(sp)	; File handle
	move	#$3F,-(sp)	; Fread
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	rts

write_file:
	move.l	a0,-(sp)	; Address of buffer
	move.l	d0,-(sp)	; Number of bytes to write
	move	handle,-(sp)	; File handle
	move	#$40,-(sp)	; Fwrite
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	rts

close_file:
	move	handle,-(sp)	; File handle
	move	#$3E,-(sp)	; Fclose
	trap	#1
	addq	#4,sp
	rts

* Construct a pathname from the output of fsel_input
* Enter with:
* a0 -> location to hold the complete pathname
* a1 -> fsel_input directory line
* a2 -> fsel_input selection line
*
* Clobbers a0-a2

make_name:
	move.b	(a1)+,(a0)+	; Copy the directory line
	bne	make_name
make_2:	cmp.b	#'\\',-(a0)	; Back up to the backslash
	bne	make_2
	addq	#1,a0		; First byte past the backslash
make_3:	move.b	(a2)+,(a0)+	; Copy the selection line
	bne	make_3
	rts

* Call fsel_input
* Enter with:
* a4 -> directory line
* a5 -> selection line
*
* Returns with condition code set
*   Negative=cancel
*   Zero=file selected

fsel_input:
	move	#90,contrl	; Set the opcode for fsel_input
	clr	contrl+2	; and the other parameters for
	move	#2,contrl+4	; the AES contrl array
	move	#2,contrl+6
	clr	contrl+8
	move.l	a4,addrin	; Set address of path spec for fsel_input
	move.l	a5,addrin+4	; Set address of filename buffer
	bsr.s	aes		; Go call fsel_input

	cmp	#1,intout+2	; Did we click on OK? (or double-click a file?)
	bne.s	.bad		; No, bail out
	tst.b	(a5)		; Is there a filename selected?
	beq.s	.bad		; No, let's scram

	moveq	#0,d0		; Zero=good exit
	rts
.bad:	moveq	#-1,d0		; Negative=cancel
	rts

* --------------
*  Call the AES
* --------------

aes:	move.l	#aespb,d1	; Address of aes parameter block in d1
	move.l	#$C8,d0		; Magic word $C8 means this is an AES call
	trap	#2
	rts

* The text strings are kept in the ".text" segment. When we don't put them
* in the ".data" segment, we can use PC relative addressing to access them.

spec:	dc.b	'\\*.*',0	; Double backslash is necessary for MAD MAC

title:	dc.b	27,'E',27,'f',27,'p'
	dcb.b	11,' '
	dc.b	'File Copier by Charles F. Johnson (Copyright 1989 ST-Log)'
	dcb.b	12,' '
	dc.b	27,'q',13,10,10,0

src_msg:
	dc.b	27,'Y',33,32,27,'J',13,10
	dc.b	'Source file:',0
dst_msg:
	dc.b	27,'Y',33,32,27,'J',13,10
	dc.b	'Destination file:',0
cancel:
	dc.b	27,'Y',33,32,27,'J',13,10
	dc.b	' Operation cancelled.',13,10,10,0
copying:
	dc.b	27,'Y',33,32,27,'J',13,10
	dc.b	' Copying...',13,10,10,0
no_ram:
	dc.b	7,27,'Y',33,32,27,'J',13,10
	dc.b	' Not enough RAM to copy this file!',13,10,10,0
cantshrnk:
	dc.b	7,27,'Y',33,32,27,'J',13,10
	dc.b	' Not enough memory to run!',13,10,10,0
cantfind:
	dc.b	7,27,'Y',33,32,27,'J',13,10
	dc.b	' Cannot find source file!',13,10,10,0
cantopen:
	dc.b	7,27,'Y',33,32,27,'J',13,10
	dc.b	' Cannot open file!',13,10,10,0
cantcreat:
	dc.b	7,27,'Y',33,32,27,'J',13,10
	dc.b	' Cannot create new file!',13,10,10,0
cantread:
	dc.b	7,27,'Y',33,32,27,'J',13,10
	dc.b	' Cannot read file!',13,10,10,0
cantwrit:
	dc.b	7,27,'Y',33,32,27,'J',13,10
	dc.b	' Cannot write file!',13,10,10,0
finished:
	dc.b	7,27,'Y',33,32,27,'J',13,10
	dc.b	' File copied successfully!',13,10,10,0
hitakey:
	dc.b	' Hit any key.',0

	.even

device:	dc.w	2

aespb:	dc.l	contrl,global,intin,intout,addrin,addrout

	.bss
	.even

copy_buffer:	ds.l	1

contrl:		ds.w	5
intin:		ds.w	32
intout:		ds.w	32
global:
apvrsn:		ds.w	1
apcont:		ds.w	1
apid:		ds.w	1
apprvt:		ds.l	1
apptre:		ds.l	1
ap1rsv:		ds.l	1
ap2rsv:		ds.l	1
ap3rsv:		ds.l	1
ap4rsv:		ds.l	1
addrin:		ds.l	4
addrout:	ds.l	4

handle:		ds.w	1

source:		ds.b	80
dest:		ds.b	80

copy_dir:	ds.b	80
copy_file:	ds.b	16

dta:		ds.b	44

		ds.l	300
ustack:		ds.l	1
		ds.w	10

prgend:		ds.w	0

	.end
