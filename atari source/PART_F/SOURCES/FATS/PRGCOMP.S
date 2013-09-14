*
*  Compare two .prg files
*
*
*
PRN	equ	0
AUX	equ	1
CON	equ	2
*
INSTAT	equ	1
CHARIN	equ	2
CHAROUT	equ	3
*
XON	equ	$13
XOFF	equ	$11
*
*
*
*
*
start:
	move.w	#0,-(sp)
	move.l	#patha,-(sp)		;open file name
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
*
	move.w	d0,handle
	bpl.s	godfilea		;br if this one was found
*
*  File name missing or read error on: 
*
	pea	patha
baddload:
	pea	errmsg0(pc)		;"Read error on: "
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
*
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
*
quit:
	move.w	#CON,-(sp)
	move.w	#CHARIN,-(sp)
	trap	#13
	addq.l	#6,sp
*	
	clr.w	-(sp)
	trap	#1
*
godfilea:
	move.l	#buffera,-(sp)		;get pointer to currently avail memory
	move.l	#200000,-(sp)		;read in the input file
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	adda.w	#12,sp
*
	tst.l	d0
	bmi	baddload
*
	add.l	#buffera,d0
	move.l	d0,bufenda
*
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			;close file
	addq.l	#4,sp
*
*  read in next file..
*
	move.w	#0,-(sp)
	move.l	#pathb,-(sp)		;open file name
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
*
	pea	pathb
	move.w	d0,handle
	bmi	baddload
*
	move.l	#bufferb,-(sp)		;get pointer to currently avail memory
	move.l	#200000,-(sp)		;read in the input file
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	adda.w	#12,sp
*
	tst.l	d0
	bmi	baddload
*
	add.l	#bufferb,d0
	move.l	d0,bufendb
*
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			;close file
	addq.l	#4,sp
*
*
	addq.l	#4,sp
*
*  now compare the two...
*
	move.w	#-1,streak
*
*
	lea	buffera,a0
	lea	bufferb,a1
	move.l	bufenda,a2
	move.l	bufendb,a3
*
loop:
	move.b	(a0)+,d0
	move.b	(a1)+,d1
	cmp.b	d1,d0
	bne.s	diffout
	cmp.l	a0,a2
	bcs.s	done
	cmp.l	a1,a3
	bcc	loop
done:
	pea	donemsg(pc)		;"done message"
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
*
	bra	quit
*
diffout:
	tst.w	streak
	bne	nostreak
	movem.l	a0-a1,-(sp)
	moveq	#6,d3
diflp:
	move.b	(a0)+,d2
	cmp.b	(a1)+,d2
	bne	diflp1
	movem.l	(sp)+,a0-a1
	bra	loop	
diflp1:
	dbra	d3,diflp
	move.w	#-1,streak
	movem.l	(sp)+,a0-a1
*
nostreak:
	movem.l	a0-a3/d0-d1,-(sp)
	pea	msg0(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,a0-a3/d0-d1
*
	move.w	d0,d2
	move.l	a0,d0
	subi.l	#buffera+$1d,d0
	bcs	loop
*
	subq.w	#1,linez
	bmi	done
	bsr	wordout
*
	move.w	d2,d0
	movem.l	a0-a3/d0-d1,-(sp)
	pea	msg1(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,a0-a3/d0-d1
*
	bsr	byteout
*
	movem.l	a0-a3/d0-d1,-(sp)
	pea	msg1(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,a0-a3/d0-d1
*
	move.w	d1,d0
	bsr	byteout
	bra	loop
*
*  puts out contents of d0.w to console
*
wordout:
	move.w	d0,-(sp)
	lsr.w	#8,d0
	bsr.s	byteout
	move.w	(sp)+,d0
	andi.w	#$ff,d0
*
*  puts contents of d0.b out to console
*
byteout:
	movem.l	d0-d7/a0-a6,-(sp)
	andi.w	#$ff,d0
	move.w	d0,d1
	move.w	d1,d2
	lsr.w	#4,d1
	move.b	hextab(pc,d1.w),d0
	move.w	d2,-(sp)
	bsr.s	dataout
	move.w	(sp)+,d2
	andi.w	#$f,d2
	move.b	hextab(pc,d2.w),d0
	bsr.s	dataout
	movem.l	(sp)+,d0-d7/a0-a6
	rts
*
*
hextab:
	.dc.b	"0123456789ABCDEF"
*
*   d0.b = data to write
*   a4-> current buffer position
*
dataout:
	move.w	d0,-(sp)
	move.w	#CON,-(sp)
	move.w	#CHAROUT,-(sp)
	trap	#13
	addq.l	#6,sp
	rts
*
*
*
linez:
	.dc.w	20
patha:
	.dc.b	"FAT.PRG",0
pathb:
	.dc.b	"NEO.PRG",0
errmsg0:
	.dc.b	13,10,"Read error on: ",0
donemsg:
	.dc.b	13,10,"All done (hit CR).",0
msg0:
	.dc.b	13,10,0
msg1:
	.dc.b	"  ",0
*
*
*
	.bss
streak:
	.ds.w	1
handle:
	.ds.w	1
bufenda:
	.ds.l	1
bufendb:
	.ds.l	1
buffera:
	.ds.b	200000
bufferb:
	.ds.b	200000
