
*	Ballistix sector to file creator by DR DYNAC
*	Disk is 1*10*79

*	Creates files each time the disk is acessed from 
*	within the game and saves them to drive B

*	On entry from game:

*	d0 = start sector
*	d1 = start track
*	d2 = number of sectors to read
*	a5 = read address

	opt	o+,w-


super	pea	0
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7

reloc	lea	sector(pc),a0
	move.l	$432,a1
	move.l	#buffer-sector,d0
copy	move.b	(a0)+,(a1)+
	dbf	d0,copy

readboot
	lea	$80000,a5
	clr.w	-(a7)		;drive A=0, B=1, C=2 etc...
	move.w	#0,-(a7)	;start sector
	move.w	#1,-(a7)	;number to read
	move.l	a5,-(a7)	;read address
	move.w	#2,-(a7)	;read and ignore disk change
	move.w	#4,-(a7)
	trap	#13
	add.l	#14,a7
	jmp	(a5)

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*


sector	movem.l	d0-a6,-(a7)		;save all registers
	move.l	a5,savea5
	mulu	#10,d0		;get start sector/track
	add.b	d1,d0		;get logical start sector
	mulu	d2,d0		;unique filename
	bsr	hex_ascii
	movem.l	(a7)+,d0-a6
	
	movem.l	d0-a6,-(a7)	;save all registers again!
	move.b	d2,d4		;number to read from drive A
	mulu	#512,d4		;length to write to new file
	move.w	d4,length	;save for writing file later
	movem.l	(a7)+,d0-a6	;restore all registers again!

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	movem.l	d0-a6,-(a7)	;save all registers yet agian!		

	jsr	$1b282		;use games' sector loader

	movem.l	(a7)+,d0-a6	;restore all registers again!


	

	bsr	setb
create	move.w	#0,-(a7)	;r/w status
	pea	store(pc)	;address of filename
	move.w	#$3c,-(a7)
	trap	#1
	addq.l	#8,a7
	bsr	err_check
	move.w	d0,d7		;store handle


write	move.l	savea5,-(a7)	;address to write from
	move.l	length,-(a7)	;length to write
	move.w	d7,-(a7)	;file handle
	move.w	#$40,-(a7)	
	trap	#1
	add.l	#12,a7
	bsr	err_check

close	move.w	d7,-(a7)
	move.w	#$3c,-(a7)
	trap	#1
	addq.l	#4,a7
	bsr	err_check
	bsr	seta
	movem.l	(a7)+,d0-a6	;restore all registers
	jmp	$1b282		;end of routine


	
err_check
	rts
	tst.l	d0
	bmi	exit
	rts
		
	
exit	clr.w	-(a7)
	trap	#1	

;---------------------------------------------------------

hex_ascii:

	movem.l	d0-a6,-(a7)
	move.l	d0,d0
	bsr	convert
	movem.l	(a7)+,d0-a6

	move.b	3(a0),(a1)
	move.b	4(a0),1(a1)
	move.b	#"_",2(a1)
	
	movem.l	d0-a6,-(a7)
	move.l	d1,d0
	bsr	convert
	movem.l	(a7)+,d0-a6

	move.b	3(a0),3(a1)
	move.b	4(a0),4(a1)
	move.b	#"_",5(a1)
	
	movem.l	d0-a6,-(a7)
	move.l	d2,d0
	bsr	convert
	movem.l	(a7)+,d0-a6

	move.b	3(a0),6(a1)
	move.b	4(a0),7(a1)

	move.l	ext,8(a1)
	move.b	ext+5,12(a1)
	rts

convert	clr.l	d1
	lea	store(pc),a0
	clr.l	(a0)
	lea	buff(pc),a1
	bsr	.bindec
	rts
		
	

.bindec 	
	movem.l	d0-a6,-(sp) 
	MOVE.B	#' ',D1
	TST.W	D0
	BPL.S	.notneg
	MOVE.B	#"-",D1
	NEG.W	D0
.notneg	MOVE.B	D1,(A0)+
	ADDA.L	#4,A0		this figure previously 5 but some
	MOVE.W	#4,D1		failure on display caused a change to 4...
.binloop 
	EXT.L	D0
	DIVS	#10,D0
	SWAP	D0
	MOVE.B	D0,-(A0)
	ADD.B	#"0",(A0)
	SWAP	D0
	DBRA	D1,.binloop
	movem.l	(sp)+,d0-a6
	RTS

store	ds.b	3
prop	ds.b	1
	dc.b	0,0
ext	dc.b	".DAT"
	dc.b	0,0
	even

buff	ds.l	4




seta	move.w	#0,-(a7)
	move.w	#$e,-(a7)
	trap	#1
	addq.l	#4,a7
	rts
	
setb	move.w	#1,-(a7)
	move.w	#$e,-(a7)
	trap	#1
	addq.l	#4,a7
	rts
	


	
	
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*	
	
	data
	even


trap10	ds.l	1
savea5	ds.l	1	
length	ds.w	1
buffer	even

		