loadboot	move.w	#1,-(sp)		Read old boot sector
	move.w	#0,-(sp)		from side 0
	move.w	#0,-(sp)		track 0
	move.w	#1,-(sp)		sector 1
	move.w	#0,-(sp)		drive A
	clr.l	-(sp)		Filler
	move.l	#buffer,-(sp)	Address to load to
	move.w	#8,-(sp)		Function number
	trap	#14		Call XBIOS
	add.l	#20,sp		Correct stack

	move.w	#240,d0		Set up counter
	move.l	#buffer,a0	Address of old boot sector
	lea	30(a0),a0		Skip past header
	move.l	#bootprog,a1	Address of new program
loop	move.w	(a1)+,(a0)+	Copy across word
	dbf	d0,loop		Copy next word
	move.l	loader,buffer	Copy across new header
	move.l	loader+4,buffer+4	Copy across new header

	move.w	#1,-(sp)		Executable boot sector
	move.w	#-1,-(sp)		Don't change disk type
	move.l	#-1,-(sp)		Don't change serial number
	move.l	#buffer,-(sp)	Address of new program
	move.w	#18,-(sp)		Modify boot sector
	trap	#14		Call XBIOS
	add.l	#14,sp		Correct stack

	move.w	#1,-(sp)		Write boot sector
	move.w	#0,-(sp)		to side 0
	move.w	#0,-(sp)		track 0
	move.w	#1,-(sp)		sector 1
	move.w	#0,-(sp)		drive A
	clr.l	-(sp)		Filler
	move.l	#buffer,-(sp)	Address to write from
	move.w	#9,-(sp)		Function number
	trap	#14		Call XBIOS
	add.l	#20,sp		Correct stack

	clr.w	-(sp)		Exit program
	trap	#1		Call GEMDOS

buffer	ds.b	512
loader	dc.b	$60,$1C,"*C&D* "

bootprog	lea	fade(pc),a4	Address of fade data
	lea	$ffff8240.w,a5	Palette register
	move.w	#6,d6		Set up a counter
	move.w	d6,d7		Make a copy for later
fadeloop	move.w	(a4)+,(a5)	Get first colour
	move.w	#37,-(sp)		Wait VBL
	trap	#14		Call XBIOS
	dbf	d6,fadeloop	Fade to next colour
blackpal	clr.l	(a5)+		Clear first 2 colours
	dbf	d7,blackpal	Clear more colours

	lea	disk(pc),a4	Address of disk drive data
	move.l	#$eff7c,a0	Destination address
	move.w	#2754,d3		Number of bytes to read
	bsr	fastload		Load in data
	move.l	#$eff7c,a1	Address of data
	jsr	(a1)		Decompress it

	move.w	#2,-(sp)		Get physical adddress
	trap	#14		Call XBIOS
	move.l	#$effbc,a0	Source address
	move.l	d0,a1		Destination address
	move.w	#7999,d0		Set up counter
logoloop	move.l	(a0)+,(a1)+	Copy across long word
	dbf	d0,logoloop	Next 4 bytes
	move.l	#$00002222,$ffff8240.w	Set palette
	move.l	#$33334444,$ffff8244.w	Set palette

	move.l	#$a77a,a0		Destination address
	move.l	a0,a3		Copy into a3
	move.w	#$0402,(a4)	Side 1, sector 2
	move.w	#56,2(a4)		Track 56
	move.w	#60000,d3		Size of program
	bsr	fastload		Load in data

	move.w	#$a796,d2		End of base page
	lea	$1c(a3),a1	Copy into a1
	move.l	a1,a2		Copy into a2
	add.l	2(a3),a2		Pointer to start of program
	add.l	(a2)+,a1		Store in a1
	add.l	d2,(a1)		Modify start address
qloop2	clr.w	d1		Clear d1
qloop	clr.w	d0		Clear d0
	move.b	(a2)+,d0		Get address
	cmp.b	#1,d0		Convert it?
	bne	noqloop		Yes, goto routine
	add.w	#$fe,d1		Move to next address
	bra	qloop		Loop back around
noqloop	add.w	d0,d1		Relocate address
	add.w	d1,a1		New address
	add.l	d2,(a1)		Store it
	tst.b	(a2)		All relocated yet?
	bne	qloop2		No, relocate some more

	clr.l	-(sp)		No new stack
	move.w	#$20,-(sp)	User mode
	trap	#1		Call XBIOS
	jmp	(a3)		Run program

dmamode	equ	$ff8606
dmadat	equ	$ff8604
dmahigh	equ	$ff8609
dmamid	equ	$ff860b
dmalow	equ	$ff860d
mfp	equ	$fffa01
flselec	equ	$ff8800
flwrite	equ	$ff8802
flock	equ	$43e

fastload	st	flock		Disable floppy interrupt
	move.b	#$e,flselec	Select port A	
	move.b	#5,flwrite	Activate drive
	move.w	#$80,dmamode	Access FDC register
	move.w	#$d0,dmadat	Reset command
	move.w	#80,d7		Set up a delay
delay	dbf	d7,delay		Wait for reset

loaddata	lea	lbuffer(pc),a1	Address of buffer
	move.l	a1,d7		Copy into d7
	move.b	d7,dmalow		Set low byte
	lsr.l	#8,d7
	move.b	d7,dmamid		Set mid byte
	lsr.l	#8,d7
	move.b	d7,dmahigh	Set high byte
	
	move.b	#$e,flselec	Select port A
	move.b	(a4),flwrite	Select side

	move.w	#$86,dmamode	Access track register
	move.w	2(a4),d6		New track
	move.w	d6,dmadat		Send command
	move.w	#$80,dmamode	Select FDC register
	move.w	#$1b,dmadat	Seek track command
	bsr	waitready		Wait for ready signal

	move.w	#$90,dmamode	Sector count register
	move.w	#1,dmadat		Read 1 sector
	move.w	#$84,dmamode	Select sector register
	move.b	1(a4),d6		New sector
	move.w	d6,dmadat		Send command
	move.w	#$80,dmamode	Select FDC register
	move.w	#$80,dmadat	Read sector command
	bsr	waitready		Wait for ready signal

	add.b	#1,1(a4)		Move to next sector
	cmp.b	#10,1(a4)		Next track yet?
	bne	posfound		No, skip next bit
	move.b	#1,1(a4)		Back to sector 1
	add.w	#1,2(a4)		Move up track counter

posfound	lea	lbuffer(pc),a1	Address of buffer
	cmp.w	#512,d3		Less than 513 bytes remaining?
	bls	endload		Yes, end load sequence
	move.w	#31,d0		Set up a counter
buffcopy	move.l	(a1)+,(a0)+	Copy data out of buffer
	move.l	(a1)+,(a0)+	Copy data out of buffer
	move.l	(a1)+,(a0)+	Copy data out of buffer
	move.l	(a1)+,(a0)+	Copy data out of buffer
	dbf	d0,buffcopy	Copy some more data
	sub.w	#512,d3		Decrease amount to load
	bra	loaddata		Load in some more

endload	sub.w	#1,d3		Number of bytes remaining
buffcopy2	move.b	(a1)+,(a0)+	Copy data out of buffer
	dbf	d3,buffcopy2	Copy some more
	sf	flock		Enable floppy interrupt
	rts			Return

waitready	btst	#5,mfp		Command processed?
	bne	waitready		No, keep waiting
	rts			Return

disk	dc.b	5,2		Side to read
	dc.w	23		Track to read

fade	dc.w	$777,$666,$555,$444,$333,$222,$111
lbuffer