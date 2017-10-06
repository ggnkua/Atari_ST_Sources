*
*	New version of relmod.
*	Made by J.A.M.Vermaseren, 17-12-1986.
*	Public domain. This program may be copied for free only.
*	Anybody selling public domain disks with whatever tiny profit
*	beyond the direct costs should send me Dfl 2,-- per copy ( $1 ).
*	My address : J.Vermaseren, Leerdamhof 441, 1108CL Amsterdam.
*	Be fair : If you get something for the trouble I want something
*	for mine.
*
******************************************************************************
*									     *
*	Variables in the heap :	( a6 is heap pointer )			     *
*									     *
*	0	Number of characters read into input buffer		     *
*	4	Output error information from reloc.			     *
*	8	Last relocation address.				     *
*	12	Little trap routine.					     *
*	24	Input name.						     *	
*									     *
*	Variables in the registers :					     *
*									     *
*	d7	Input file handle					     *
*	d6	Output file handle					     *
*	d5	(reloc) characters in output buffer			     *
*	d4	(reloc)	characters in input buffer			     *
*	d3	Length of the buffers					     *
*	d2	(reloc)	Distance to start of text			     *
*	a5	Output buffer						     *
*	a4	(reloc) Input buffer					     *
*	a3	(reloc) Next position in output buffer			     *
*	a2	(reloc) Next position in input buffer			     *	
*									     *
******************************************************************************
*
*	The startup is done in a particular way, to build the heap before
*	the setblock is done. The Atari ROM refuses to execute trap functions
*	and return to the ROM safely. This way a little routine like
*		move.l	(sp)+,offset+8(a6)
*		trap	#1
*		jmp	unimportant
*	can be put at offset(a6) and all trap #1 replaced by jmp offset(a6).
*	In this program offset is 12, so jmp 12(a6) is equivalent to trap #1
*	This has to be done before the first trap call, ie the setblock.
*
start:	move.l	4(sp),a3		* Base page address.
	move.l	12(a3),d0		* Length of text.
	add.l	20(a3),d0		* Initialized data.
	add.l	28(a3),d0		* Uninitialized data.
	add.l	#$100,d0		* + 100 bytes basepage.
	lea	(a3,d0.l),a6		* Heap pointer.
	add.l	#$200,d0		* Heap + stack space.
	move.l	sp,d3			* Top of available memory.
	lea	(a3,d0.l),sp		* Install new stack pointer
	sub.l	sp,d3			* Available for copying.
	andi.l	#$FFFFF800,d3		* Make multiple of 2048.
	beq	nomemory		* Not enough memory.
	add.l	d3,d0			* Total memory requirement.
	lsr.l	#1,d3			* Space for each buffer.
	move.l	sp,-(sp)		* Input buffer for later.
	lea	(sp,d3.l),a5		* Output buffer.
*
*	Just for fun. I don't expect you to put it in the ROM cartridge.
*
	move.l	#$2D5F0014,12(a6)	* move.l (sp)+,20(a6)
	move.l	#$4E414EF9,16(a6)	* trap	 #1
*					* jmp	 .....
*
	move.l	d0,-(sp)		* Total reservation.
	move.l	a3,-(sp)		* Start address.
	clr.w	-(sp)			* For GEMDOS. It eats its stack!!!!!!
	move.w	#$4A,-(sp)		* Setblock.
	jsr	12(a6)			* This is trap #1
	lea	12(sp),sp		* Reset the stack.
	tst.l	d0
	bne	nomemory
*
*	Study the command tail. Problem : What if there ain't any.
*	Normally : Pascal string : One byte with the length of the rest, and
*				   then the rest.
*	Is none	 : 60,1A or something. So if 60, then look at offset 18. If
*		   no tail there is a zero there. With tail there ain't.
*
	lea	$80(a3),a4		* The beginning of the command tail
	moveq.l	#0,d5
	move.b	(a4)+,d5		* String length. String at a4.
	beq	notail			* Length 0.
	cmpi.w	#$60,d5
	bne	istail			* There is a command tail.
	tst.b	17(a4)
	beq	notail			* No commmand tail --> error message.
istail:	lea	(a4,d5.w),a3		* First address beyond the tail.
	moveq.l	#0,d0
	moveq.l	#$20,d2			* This is a blank.
loop1:	move.b	(a4)+,d0		* Get one character.
	cmp.b	d2,d0
	beq	loop1			* Strip leading blanks.
	cmpi.b	#$2D,d0
	bne	nodash
	move.b	(a4)+,d0		* Skip a dash.
nodash:	cmp.l	a4,a3			* Do we have a nontrivial character ?
	blt	notail
	lea	24(a6),a0		* For storage.
	move.l	a0,a1			* For later to find the extention.
	move.l	a0,a2			* Keep track of the '.'
loop2:	cmp.b	#$2E,d0
	bne	loop2a
	move.l	a0,a2			* Address of the last period
loop2a:	move.b	d0,(a0)+
	move.b	(a4)+,d0
	cmp.b	d2,d0			* Go till blank or end of tail
	beq	endpar
	cmp.l	a4,a3
	bge	loop2			* A good character --> copy.
endpar:
	cmp.l	a2,a1			* Was there a period ?
	bne	fullnm			* Got a full name.
	move.l	a0,a2
	move.b	#$2E,(a0)+		* '.'
	move.b	#$36,(a0)+		* '6'
	move.b	#$38,(a0)+		* '8'
	move.b	#$4B,(a0)+		* 'K'
fullnm:	clr.b	(a0)
	clr.w	-(sp)			* Reading this file only.
	move.l	a1,-(sp)		* Address of the file name.
	move.w	#$3D,-(sp)		* Fopen.
	jsr	12(a6)			* This is trap #1
	addq.l	#8,sp
	tst.l	d0			* Did the file get opened?
	bmi	filerr
	move.l	d0,d7			* Store the handle.
*
	moveq.l	#0,d0
loop3:	move.b	(a4)+,d0
	cmp.b	d2,d0
	beq	loop3
	cmp.l	a4,a3
	bmi	only1			* Only one parameter --> transform.
	lea	-1(a4),a1		* Start of second name.
loop4:	move.b	(a4)+,d0
	cmp.b	d2,d0
	beq	param2
	cmp.l	a4,a3
	bge	loop4
	bra	param2
only1:	lea	1(a2),a4
	move.b	#$50,(a4)+
	move.b	#$52,(a4)+
	move.b	#$47,(a4)+
	addq.l	#1,a4
param2:	subq.l	#1,a4
	move.b	(a4),d4			* Save old character
	clr.b	(a4)			* End on 0 for GEMDOS.
	clr.w	-(sp)			* Read and write.
	move.l	a1,-(sp)
	move.w	#$3C,-(sp)		* Fcreate
	jsr	12(a6)			* This is trap #1
	addq.l	#8,sp
	move.b	d4,(a4)			* Restore old character.
	tst.l	d0
	bmi	filer2
	move.l	d0,d6			* Save the output handle.
*
*	Now we have two opened files and the buffers are ready.
*
      	move.l	(sp)+,a4		* Input buffer.
	bsr	reloc			* Make the relocation table.
	move.w	d6,-(sp)		* Output file.
	bsr	fclose
	move.w	d7,(sp)			* Input file.
	bsr	fclose
	addq.l	#2,sp
	move.w	4(a6),-(sp)		* Error code from reloc ( or none ).
	move.w	#$4C,-(sp)		* Pterm: exit with possible error code.
	jsr	12(a6)			* This is trap #1
*
*	Error messages when a file cannot be opened.
*
filer2:	move.w	d7,-(sp)
	bsr	fclose			* First close the input file.
	addq.l	#2,sp
*
filerr:	pea	nofil(pc)		* First part of error message.
	bsr	out_str
	addq.l	#4,sp
	move.l	a1,-(sp)		* Pointer to the name of the file.
conti:	bsr	out_str
	addq.l	#4,sp
	pea	newlin(pc)		* CR+linefeed.
	bsr	out_str
	addq.l	#4,sp
	bra	errext
*
nomemory:
	pea	nomem(pc)		* Shortage of memory.
	bra	conti
*
notail:	pea	use(pc)			* Show correct usage.
	bsr	out_str
	addq.l	#4,sp
errext:
	move.w	#-1,-(sp)
	move.w	#$4C,-(sp)
	jsr	12(a6)			* Pterm with errorflag.
*
use:	dc.b	'Usage: FASTREL [-]file[.68K] [output file]'
newlin:	dc.b	$0D,$0A,0,0
nofil:	dc.b	'Cannot open file ',0
nomem:	dc.b	'Not enough memory available.',0,0
errrel:	dc.b	'File error.',0
*
*	Close a file
*
fclose:	move.w	4(sp),-(sp)
	move.w	#$3E,-(sp)		* Fclose
	jsr	12(a6)			* This is trap #1
	addq.l	#4,sp
	rts
*
*	Routine to write a zero terminated string to the screen.
*
out_str:
	move.l	4(sp),-(sp)
	move.w	#9,-(sp)
	jsr	12(a6)			* This is trap #1
	addq.l	#6,sp
	rts
*
*	The routine to make a relocation table.
*
reloc:	bsr	readin			* Read the first buffer.
	bmi	error
	moveq.l	#28,d4			* Header length.
	add.l	2(a4),d4		* Text length.
	add.l	6(a4),d4		* Data segment.
	add.l	14(a4),d4		* Symbol table.
	bsr	copyd4			* Copy this piece to the output buffer.
	bmi	error
	clr.l	8(a6)			* Start of relocation
	moveq.l	#-4,d2			* Running counter.
rloop:	addq.l	#2,d2
rloopp:	addq.l	#2,d2
	bsr	getone			* Get a single relocation number in d1.
	bne	relend
	andi.w	#7,d1
	cmpi.w	#5,d1
	bne	rloopp			* Not relevant on the ST.
	bsr	getone			* Upper half of a long word. Get next.
	bne	relend			* Originally:
	subq.w	#1,d1			* 1 relative to data segment
	andi.w	#7,d1			* 2 relative to text segment
	cmp.w	#3,d1			* 3 relative to bss
	bge	rloop			* On the ST its all relative to text.
relo1:	tst.l	8(a6)			* First relocation?
	bne	relo2			* No
	move.l	d2,8(a6)
	move.l	d2,d1
	rol.l	#8,d1			* Put now the 4 bytes of d1.
	bsr	putone
	bne	error
	rol.l	#8,d1
	bsr	putone
	bne	error
	rol.l	#8,d1
	bsr	putone
	bne	error
	rol.l	#8,d1
	bsr	putone
	beq	rloop
	bra	error
relo2:	move.l	d2,d1
	sub.l	8(a6),d1		* Difference with the previous one.
	move.l	d2,8(a6)		* The new 'previous one'
	bra	relo4
relo3:	move.l	d1,d2			* If > 254 --> write a 1
	sub.l	#254,d2			* and subtract 254.
	moveq.l	#1,d1
	bsr	putone
	bne	error
	move.l	d2,d1
	move.l	8(a6),d2		* We needed register d2 for scratch.
relo4:	cmp.l	#254,d1
	bgt	relo3
	bsr	putone			* Put the relocation increment.
	beq	rloop	
error:	move.w	#-1,4(a6)		* Error code.
	rts
relend:	cmp.w	#-1,d0			* End of relocation.
	bne	error			* Here due to e read error.
	bsr	wrttail			* Empty the buffer.
	move.w	#0,4(a6)		* Exit with OK code.
	rts
*
*	Routine fills the input buffer. Returns the normal d0.
*
readin:	move.l	a4,-(sp)		* Input buffer.
	move.l	d3,-(sp)		* Length of the buffer.
	move.w	d7,-(sp)		* Handle.
	move.w	#$3F,-(sp)		* Fread.
	jsr	12(a6)			* This is trap #1
	lea	12(sp),sp		* Restore the stack.
	move.l	d0,(a6)			* Number of bytes read.
	rts
*
*	Get one character from the input buffer. If it is empty, fill it
*	or return an EOF message. Entry is 'getone'
*
getbuf:	cmp.l	(a6),d3		* Was it a full buffer?
	bne	eof
	move.l	a4,-(sp)
	move.l	d3,-(sp)
	move.w	d7,-(sp)
	move.w	#$3F,-(sp)
	jsr	12(a6)		* This is trap #1
	lea	12(sp),sp
	tst.l	d0
	bmi	inerr
	move.l	d0,(a6)
	moveq.l	#0,d4
	move.l	a4,a2
*				* Now the main entry.
getone:	cmp.l	(a6),d4		* Buffer used completely?
	bge	getbuf		* Still characters in the buffer.
	move.w	(a2)+,d1
	addq.l	#2,d4
	moveq.l	#0,d0
	rts
eof:	moveq.l	#-1,d0
inerr:	rts
*
*	Routine copies the normal program segment to the output buffer.
*	If this segment is longer than one buffer it is written to file and
*	a new buffer is read till the leftover fits.
*
copyd4:	cmp.l	d4,d3			* Does it fit ?
	bgt	itfits
	move.l	a4,-(sp)		* The buffer.
	move.l	d3,-(sp)		* Its length.
	move.w	d6,-(sp)		* Output handle.
	move.w	#$40,-(sp)		* Fwrite.
	jsr	12(a6)			* This is trap #1
	lea	12(sp),sp		* Restore the stack.
	tst.l	d0
	bmi	cdone
	sub.l	d3,d4			* This much left.
	bsr	readin			* Read a new buffer
	bmi	cdone
	bra	copyd4
itfits:	move.l	d4,d1			* Number of bytes.
	addq.l	#3,d1			* For rounding up.
	lsr.l	#2,d1			* Converted to words of 4 bytes.
	move.l	a4,a2
	move.l	a5,a3
	bra	copyl2
copyl1:	move.l	(a2)+,(a3)+		* Even addresses --> use long words.
copyl2:	dbra	d1,copyl1
	lea	(a5,d4.l),a3		* Put the addresses right.
	lea	(a4,d4.l),a2
	move.l	d4,d5			* Characters in output buffer.
	moveq.l	#0,d0			* No errors.
cdone:	rts
*
*	Write the rest of the output buffer, followed by one zero if there
*	was a relocation and by 4 of them if there wasn't.
*
wrttail:
	moveq.l	#0,d1
	tst.l	8(a6)			* Zero if no relocations.
	bne	wrtone			* Write only one byte.
	bsr	putone			* Write four zero bytes.
	bne	wrtok
	bsr	putone
	bne	wrtok
	bsr	putone
	bne	wrtok
wrtone:	bsr	putone
	bne	wrtok
	tst.l	d5
	beq	wrtok
	move.l	a5,-(sp)		* Output buffer.
	move.l	d5,-(sp)		* Number of bytes to be written.
	move.w	d6,-(sp)		* Output handle.
	move.w	#$40,-(sp)		* Fwrite
	jsr	12(a6)			* This is trap #1
	lea	12(sp),sp
wrtok:	rts
*
*	Routine adds one character to the output buffer. If it is full the
*	buffer is emptied by writing to file. The character is expected in d1.
*
putone:	move.b	d1,(a3)+		* Put the character in the buffer.
	addq.l	#1,d5			* One more.
	cmp.l	d5,d3			* Buffer full?
	bgt	putok			* No
	move.l	a5,-(sp)		* Output buffer.
	move.l	d5,-(sp)		* Number of characters.
	move.w	d6,-(sp)		* Output handle.
	move.w	#$40,-(sp)		* Fwrite.
	jsr	12(a6)			* This is trap #1
	lea	12(sp),sp		* Restore the stack.
	move.l	a5,a3			* Start of buffer again.
	cmp.l	d5,d0			* Wrote enough bytes?
	bne	putex			* Return with status at ne.
	moveq.l	#0,d5			* Zero bytes in buffer.
putok:	moveq.l	#0,d0			* Condition is eq.
putex:	rts

public:	dc.b	'Program by Jos Vermaseren 17-12-86'
