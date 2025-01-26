
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


;start	move.l	$a8,trap10
;	move.l	#sector,$a8	;put routine through trap 10 vector

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
	
	move.l	#$4eb90001,$1b282	;jsr $1b292
	move.w	#$b292,$1b286
	
	move.l	#$0c420000,$1b288	;cmpi.w	#0,d2
	move.l	#$6600fff4,$1b28c	;bne	$1b282
	

	mulu	#10,d0		;get start sector/track
	add.b	d1,d0		;get logical start sector
	mulu	d2,d0		;unique filename
	bsr	hex_ascii
	movem.l	(a7)+,d0-a6
	
	movem.l	d0-a6,-(a7)	;save all registers again!
	mulu	#10,d0		;get start sector/track
	add.b	d1,d0		;get logical start sector
	move.w	d0,d3		;save value for rwabs
	move.b	d2,d4		;number to read from drive A
	mulu	#512,d4		;length to write to new file

rwabs	clr.w	-(a7)		;drive A=0, B=1, C=2 etc...
	move.w	d3,-(a7)	;start sector
	move.w	d2,-(a7)	;number to read
	pea	buffer(pc)	;read address
	move.w	#2,-(a7)	;read and ignore disk change
	move.w	#4,-(a7)
	trap	#13
	add.l	#14,a7
	bsr	err_check	
	
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
		
create	move.w	#0,-(a7)	;r/w status
	pea	filename(pc)	;address of filename
	move.w	#$3c,-(a7)
	trap	#1
	addq.l	#8,a7
	bsr	err_check
	move.w	d0,d7		;store handle


write	pea	buffer(pc)	;address to write from
	move.l	d4,-(a7)	;length to write
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

	movem.l	(a7)+,d0-a6	;restore all registers
	rte			;end of routine


	
err_check
	rts
	tst.l	d0
	bmi	exit
	rts
		
	
exit	clr.w	-(a7)
	trap	#1	

;---------------------------------------------------------

hex_ascii:
	lea	abuf(pc),a0		;a0 -> our buffer
	move.l	#$0,d1
	move.l	d1,(a0)
	move.l	d1,4(a0)
	move.l	d1,8(a0)

	moveq	#11,d1

.loop	divu	#16,d0
	swap	d0			;remainder in top word
	cmp.b	#10,d0
	blt	.add_0
	add.b	#'A'-'0'-10,d0
.add_0	add.b	#'0',d0
	move.b	d0,0(a0,d1.w)
	move.w	#0,d0
	swap	d0
	tst.l	d0
 	beq	.fini
	dbf	d1,.loop

.fini:	subq	#1,d1
	move.b	#'$',0(a0,d1.w)
	rts



	
	
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*	
	
	data
	even


trap10	ds.l	1
	even

logical	ds.l	1	

filename
	dc.b	"B:\B"
abuf:	dc.b	'   $00000000'
ext	dc.b	0,0,0,0
filend	even
buffer	even

		