***************************************************************************
* PROGRAMSTART
***************************************************************************
programstart:

*////			The same start for all programs

	move.l	4(a7),a0		A0 -> program base page
	move.l	12(a0),d0		D0.l <- code size
	add.l	20(a0),d0		D0.l <- D0.l + data size
	add.l	28(a0),d0		D0.l <- D0.l + BSS size
	add.l	#zsbasepage+zsstacksize,d0	D0.l <- D0.l +extras
	addq.l	#1,d0			D0.l = required memory for program
	bclr	#0,d0			that has to be an EVEN value
	lea	0(a0,d0.l),a7		A7.l <- new value for Stack Pointer

*////			Now reserve this area only and free up the rest

	move.l	d0,-(sp)		memory size to reserve
	move.l	a0,-(sp)		start of the memory area to reserve
	clr	-(sp)
	move	#$4A,-(sp)		TOS Setblock
	trap	#1
	lea	12(sp),sp
	tst.l	d0			error ?
	bne.s	programend		no / yes => it's all over

*////			Go to SUPERVISOR mode now saving the TOS SSP

	clr.l	-(sp)
	move	#$20,-(sp)		TOS SUPERVISOR
	trap	#1
	addq	#6,sp
	lea	zsavedSSP(pc),a0
	move.l	d0,(a0)			save TOS SSP to restore it later

*////			Execute our main program

	bsr.s	mainprog		main program

*////			Go back to USER mode

	move.l	a7,usp			our Stack Pointer is now the USP
	move.l	zsavedSSP(pc),a7	restores the TOS SSP
	and	#$DFFF,sr		clears the SUPERVISOR bit in SR


***************************************************************************
* PROGRAMEND
***************************************************************************
programend:

*////			Go back to TOS

	clr	-(sp)
	move	#$4C,-(sp)		return to TOS desktop
	trap	#1

zsbasepage	equ	256
zsstacksize	equ	4096
zsavedSSP	ds.l	1


***************************************************************************
* MAINPROG
***************************************************************************
mainprog:	

	bsr	sav

	bsr	test_hw
	tst.b	d1
	bne	its_over

	move.l	#129822,-(sp)		768+560*230+254
	move	#$48,-(sp)
	trap	#1			reserves video memory
	addq	#6,sp
	tst.l	d0
	bmi	its_over
	add.l	#$000000FE,d0
	clr.b	d0			D0.L is now multiple of 256
	lea	zvideoptrs(pc),a1
	move.l	d0,(a1)+

	bsr	getdrv
	clr	-(sp)
	pea	syncfil(pc)
	bsr	bload
	addq	#6,sp
	tst.b	d1
	bne	its_over
	lea	zpsyncstart(pc),a1
	move.l	a0,(a1)
	addq	#1,a0
	lea	zpsyncro(pc),a1
	move.l	a0,(a1)
	clr	-(sp)
	pea	grafil(pc)
	bsr	bload
	addq	#6,sp
	tst.b	d1
	bne	its_over
	addq	#2,a0
	lea	zcolors(pc),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	zvideoptrs(pc),a1
	lea	768(a1),a1
	moveq	#0,d0
	move	#559,d7
cp_image:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move	d0,(a1)+
	dbf	d7,cp_image

	move.b	zSTE(pc),d0
	beq.s	lvbl1
	lea	lpatchSTE1(pc),a0
	move	#$4E71,(a0)+			NOP
	lea	lpatchSTE2(pc),a0
	move	#$1881,(a0)+			MOVE.B	D1,(A4)		-43
	move	#$4E71,(a0)+			NOP			-39
	move	#$1880,(a0)+			MOVE.B	D0,(A4)		-31
	move	#$8080,(a0)+			OR.L	D0,D0		-23
	move	#$8080,(a0)+			OR.L	D0,D0		-15
	bra.s	lvbl2
lvbl1
	move.b	zwakeup(pc),d0
	cmp.b	#2,d0
	beq.s	lvbl2
	lea	lpatchSTF1A(pc),a0
	lea	lpatchSTF2A(pc),a1
	lea	lpatchSTF3A(pc),a2
	move	#$C140,(a0)			EXG	D0,D0		-37
	move	#$C140,(a1)			EXG	D0,D0		-37
	move	#$C140,(a2)			EXG	D0,D0		-37
	lea	lpatchSTF1B(pc),a0
	lea	lpatchSTF2B(pc),a1
	lea	lpatchSTF3B(pc),a2
	move	#$4E71,(a0)			NOP			-35
	move	#$4E71,(a1)			NOP			-35
	move	#$4E71,(a2)			NOP			-35
	lea	lpatchSTF1C(pc),a0
	lea	lpatchSTF2C(pc),a1
	lea	lpatchSTF3C(pc),a2
	move	#$8080,(a0)			OR.L	D0,D0		-11
	move	#$8080,(a1)			OR.L	D0,D0		-11
	move	#$8080,(a2)			OR.L	D0,D0		-11
lvbl2


	bsr	wdrvmot
	bsr	install


	move	#$2500,sr
	bsr	qwaitvbl
	bsr	swapbas
	bsr	coloroff
	lea	$FFFF8209.w,a0
	moveq	#32,d0
wscreen0:
	tst.b	(a0)
	beq.s	wscreen0
	sub.b	(a0),d0
	lsr	d0,d1		053

	move	#11714-1237,d0
wscreen1:
	dbf	d0,wscreen1	8(move) + 11715*12 + 4(dbf) = 140592 = 274*512 + 304

*	nop			361
	bra	start_irq	373

wait_mfp
	lea	$FFFFFA21.w,a0		08
	moveq	#86,d0			04
wait_timer
	cmp.b	(a0),d0
	bne.s	wait_timer
	clr.b	$FFFFFA1B.w			Stop Timer B
	move	#$2300,sr		allow VBL
	stop	#$2100
	stop	#$2100
	move	#$2500,sr

	lea	$FFFF8240.w,a0
	lea	$FFFF820A.w,a4
	lea	$FFFF8260.w,a5
	moveq	#2,d0
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move	#$000,(a0)

	move.l	(a0),(a0)		???
	move	(a0),(a0)		???
lpatchSTE1:
	or.l	d0,d0			???
*	nop				???
*	nop				???
	move	d0,(a4)

*	nop


	lea	$FFFF8209.w,a0		+360
	moveq	#32,d2			+364
	move.l	zpsyncro(pc),a1			16
	move.b	(a1)+,d1			8
	bne.s	wscreen2b			8,12


	move.b	d0,(a5)			+372
	nop
	nop
	move	d0,(a5)			+388

	move.b	d0,(a4)
	move.b	(a1)+,d1
	lea	$FFFF8240.w,a3

wscreen2a
	tst.b	(a0)
	beq.s	wscreen2a
	sub.b	(a0),d2
	lsr	d2,d3			001

	move.l	(a3),(a3)
	move.l	(a3),(a3)
	bra	wscreen2c


wscreen2b
	move.b	d0,(a4)
	move.b	(a1)+,d1
wscreen2
	tst.b	(a0)
	beq.s	wscreen2
	sub.b	(a0),d2
	lsr	d2,d3			053

wscreen2c
	tst.b	d1		057		d1.b=0 ? yes -> short right
	beq.s	synclab3a	065/069
	or.l	d0,d0		073
	or.l	d0,d0		081
	bra.s	synclab4a	093
synclab3a
	move.b	d0,(a5)		077
	moveq	#6,d1		081		d1=6 -> behave as normal right end
	move	d0,(a5)		089
	nop			093
synclab4a

*----------------------------------------------------------------------------------

	lea	$FFFF8240.w,a0	101
	moveq	#1,d2		105		d2 = number of dbf lines - 1
	move.l	(a0),(a0)	125
	move.l	(a0),(a0)	145
	move.l	(a0),(a0)	165
	move.l	(a0),(a0)	185
	move.l	(a0),(a0)	205
	move.l	(a0),(a0)	225
	move.l	(a0),(a0)	245
	move.l	(a0),(a0)	265						172

*----------------------------------------------------------------------------------

	subq.b	#2,d1		269		d1.b = 0/2/4
	bne.s	synclab5a	277/281		=0 ? Yes -> 60 Hz right
	move	d0,(a4)		285
	move.b	d0,(a4)		293
	bra.s	synclab6a	305
synclab5a
	subq	#2,d1		285		d1.b = 0/2
	move.b	d1,(a4)		293		right border removal or not
	move.b	d0,(a4)		301
	nop			305
synclab6a

*----------------------------------------------------------------------------------

	or.l	d0,d0		313
	nop			317
synclp
	nop			321
	move	#$000,(a0)	333
	or.l	d0,d0		341
	or.l	d0,d0		349					44
	move.b	(a1)+,(a5)	361		stabilization info
	nop			365					04
	move	d0,(a5)		373
	move.l	(a0),(a0)	393
	move	(a0),(a0)	405					32	080

*----------------------------------------------------------------------------------

	move.b	(a1)+,d1	413
	bne.s	synclab0	421/-91 / 425/-87	d1.b=0 ? yes -> no left
	move.b	d0,(a5)		-083
	nop			-079
	move	d0,(a5)		-071
	nop			-067
	nop			-063
	or.l	d0,d0		-055		NO BLANK
	or.l	d0,d0		-047
	nop			-043
	nop			-039
	nop			-035
	nop			-031
	nop			-027
	nop			-023
	bra.s	synclab2	-011
synclab0
	subq.b	#2,d1		-083		d1.b = 0/2/4
	beq.s	synclab1	-075/-071	d1.b=0 ? yes -> 0 bytes line
	subq.b	#2,d1		-071		d1.b = 0/2
	nop			-067
	nop			-063
	or.l	d0,d0		-055		NO BLANK
	move.b	d1,(a4)		-047		early start or not
	nop			-043
lpatchSTF1A
	or.l	d0,d0		-035		EXG	D0,D0	-037
	move.b	d0,(a4)		-027				-029
	nop			-023
	bra.s	synclab2	-011
synclab1
	nop			-067
	nop			-063
	or.l	d0,d0		-055		NO BLANK
	nop			-051
lpatchSTE2
	or.l	d0,d0		-043
	nop			-039
lpatchSTF1B
	exg	d0,d0		-033		OR NOP		-035
	move.b	d1,(a4)		-025				-027
	move.b	d0,(a4)		-015				-019
lpatchSTF1C
	nop			-011		OR OR.L	D0,D0	-011
synclab2

*----------------------------------------------------------------------------------

	move	#$000,(a0)	001
	or.l	d0,d0		009
	move.l	(a0),(a0)	029
	move.l	(a0),(a0)	049						060

*----------------------------------------------------------------------------------

	move.b	(a1)+,d1	057
	beq.s	synclab3	065/069		d1.b=0 ? yes -> short right
	or.l	d0,d0		073
	or.l	d0,d0		081
	bra.s	synclab4	093
synclab3
	move.b	d0,(a5)		077
	moveq	#6,d1		081		d1=6 -> behave as normal right end
	move	d0,(a5)		089
	nop			093
synclab4

*----------------------------------------------------------------------------------

	move	#$000,(a0)	105
	move.l	(a0),(a0)	125
	move.l	(a0),(a0)	145
	move.l	(a0),(a0)	165
	move.l	(a0),(a0)	185
	move.l	(a0),(a0)	205
	move.l	(a0),(a0)	225
	move.l	(a0),(a0)	245
	move.l	(a0),(a0)	265						172

*----------------------------------------------------------------------------------

	subq.b	#2,d1		269		d1.b = 0/2/4
	bne.s	synclab5	277/281		=0 ? Yes -> 60 Hz right
	move	d0,(a4)		285
	move.b	d0,(a4)		293
	bra.s	synclab6	305
synclab5
	subq	#2,d1		285		d1.b = 0/2
	move.b	d1,(a4)		293		right border removal or not
	move.b	d0,(a4)		301
	nop			305
synclab6

*----------------------------------------------------------------------------------

	dbf	d2,synclp	321/317
	move	#$000,(a0)	333
	or.l	d0,d0		341
	or.l	d0,d0		349					44
	move.b	(a1)+,(a5)	361		stabilization info
	nop			365					04
	move	d0,(a5)		373
	move.l	(a0),(a0)	393
	move	(a0),(a0)	405					32	080

*----------------------------------------------------------------------------------

	move.b	(a1)+,d1	413
	bne.s	synclab0b	421/-91 / 425/-87	d1.b=0 ? yes -> no left
	move.b	d0,(a5)		-083
	nop			-079
	move	d0,(a5)		-071
	nop			-067
	nop			-063
	move	d0,(a4)		-055		BLANK
	move.b	d0,(a4)		-047
	nop			-043
	nop			-039
	nop			-035
	nop			-031
	nop			-027
	nop			-023
	bra.s	synclab2b	-011
synclab0b
	subq.b	#2,d1		-083		d1.b = 0/2/4
	beq.s	synclab1b	-075/-071	d1.b=0 ? yes -> 0 bytes line
	subq.b	#2,d1		-071		d1.b = 0/2
	nop			-067
	nop			-063
	move	d0,(a4)		-055		BLANK
	move.b	d1,(a4)		-047		early start or not
	nop			-043
lpatchSTF2A
	or.l	d0,d0		-035		EXG	D0,D0	-037
	move.b	d0,(a4)		-027				-029
	nop			-023
	bra.s	synclab2b	-011
synclab1b
	nop			-067
	nop			-063
	move	d0,(a4)		-055		BLANK
	move.b	d0,(a4)		-047
	nop			-043
	nop			-039
lpatchSTF2B
	exg	d0,d0		-033		OR NOP		-035
	move.b	d1,(a4)		-025				-027
	move.b	d0,(a4)		-015				-019
lpatchSTF2C
	nop			-011		OR OR.L	D0,D0	-011
synclab2b

*----------------------------------------------------------------------------------

	move	#$000,(a0)	001
	or.l	d0,d0		009
	move.l	(a0),(a0)	029
	move.l	(a0),(a0)	049						060

*----------------------------------------------------------------------------------

	move.b	(a1)+,d1	057
	beq.s	synclab3b	065/069		d1.b=0 ? yes -> short right
	or.l	d0,d0		073
	or.l	d0,d0		081
	bra.s	synclab4b	093
synclab3b
	move.b	d0,(a5)		077
	moveq	#6,d1		081		d1=6 -> behave as normal right end
	move	d0,(a5)		089
	nop			093
synclab4b

*----------------------------------------------------------------------------------

	lea	zcolors(pc),a3	08
	lea	(a0),a2		04
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+

*	move	#$000,(a0)	105
*	move.l	(a0),(a0)	125
*	move.l	(a0),(a0)	145
*	move.l	(a0),(a0)	165
*	move.l	(a0),(a0)	185
*	move.l	(a0),(a0)	205
*	move.l	(a0),(a0)	225
*	move.l	(a0),(a0)	245
*	move.l	(a0),(a0)	265						172

*----------------------------------------------------------------------------------

	subq.b	#2,d1		269		d1.b = 0/2/4
	bne.s	synclab5b	277/281		=0 ? Yes -> 60 Hz right
	move	d0,(a4)		285
	move.b	d0,(a4)		293
	bra.s	synclab6b	305
synclab5b
	subq	#2,d1		285		d1.b = 0/2
	move.b	d1,(a4)		293		right border removal or not
	move.b	d0,(a4)		301
	nop			305
synclab6b

*----------------------------------------------------------------------------------

	nop			309
	move.l	(a0),(a0)	329
	move.l	(a0),(a0)	349
	move.b	(a1)+,(a5)	361
	nop			365
	move	d0,(a5)		373
	move.l	(a0),(a0)	393
	move	#$000,(a0)	405					32	080

*----------------------------------------------------------------------------------

	move.b	(a1)+,d1	413
	bne.s	synclab0c	421/-91 / 425/-87	d1.b=0 ? yes -> no left
	move.b	d0,(a5)		-083
	nop			-079
	move	d0,(a5)		-071
	nop			-067
	nop			-063
	move.b	d0,(a4)		-055		BLANK
	move.b	d0,(a4)		-047
	nop			-043
	nop			-039
	nop			-035
	nop			-031
	nop			-027
	nop			-023
	bra.s	synclab2c	-011
synclab0c
	subq.b	#2,d1		-083		d1.b = 0/2/4
	beq.s	synclab1c	-075/-071	d1.b=0 ? yes -> 0 bytes line
	subq.b	#2,d1		-071		d1.b = 0/2
	nop			-067
	nop			-063
	move.b	d0,(a4)		-055		BLANK
	move.b	d1,(a4)		-047		early start or not
	nop			-043
lpatchSTF3A
	or.l	d0,d0		-035		EXG	D0,D0	-037
	move.b	d0,(a4)		-027				-029
	nop			-023
	bra.s	synclab2c	-011
synclab1c
	nop			-067
	nop			-063
	move.b	d0,(a4)		-055		BLANK
	move.b	d0,(a4)		-047
	nop			-043
	nop			-039
lpatchSTF3B
	exg	d0,d0		-033		OR NOP		-035
	move.b	d1,(a4)		-025				-027
	move.b	d0,(a4)		-015				-019
lpatchSTF3C
	nop			-011		OR OR.L	D0,D0	-011
synclab2c

*----------------------------------------------------------------------------------

	move.l	(a0),(a0)	009
	move.l	(a0),(a0)	029
	move.l	(a0),(a0)	049						060

*----------------------------------------------------------------------------------

	move.b	(a1)+,d1	057
	beq.s	synclab3c	065/069		d1.b=0 ? yes -> short right
	or.l	d0,d0		073
	or.l	d0,d0		081
	bra.s	synclab4c	093
synclab3c
	move.b	d0,(a5)		077
	moveq	#6,d1		081		d1=6 -> behave as normal right end
	move	d0,(a5)		089
	nop			093
synclab4c

*----------------------------------------------------------------------------------

	move	(a0),(a0)	105
	move.l	(a0),(a0)	125
	move.l	(a0),(a0)	145
	move.l	(a0),(a0)	165
	move.l	(a0),(a0)	185
	move.l	(a0),(a0)	205
	move.l	(a0),(a0)	225
	move.l	(a0),(a0)	245
	move.l	(a0),(a0)	265						172

*----------------------------------------------------------------------------------

	subq.b	#2,d1		269		d1.b = 0/2/4
	bne.s	synclab5c	277/281		=0 ? Yes -> 60 Hz right
	move	d0,(a4)		285
	move.b	d0,(a4)		293
	bra.s	synclab6c	305
synclab5c
	subq	#2,d1		285		d1.b = 0/2
	move.b	d1,(a4)		293		right border removal or not
	move.b	d0,(a4)		301
	nop			305
synclab6c

*----------------------------------------------------------------------------------

	nop			309
	move.l	(a0),(a0)	329
	move.l	(a0),(a0)	349
	move.b	(a1)+,(a5)	361
	nop			365
	move	d0,(a5)		373

	move.l	(a0),(a0)
	move	(a0),(a0)
	nop
	move	#222,d2
fulldisp
	nop
	move.b	d0,(a5)
	nop
	move	d0,(a5)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move	(a0),(a0)
	nop
	move	d0,(a4)
	move.b	d0,(a4)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move	(a0),(a0)
	move.b	d0,(a5)
	nop
	move	d0,(a5)
	move.l	(a0),(a0)
	move	(a0),(a0)
	dbf	d2,fulldisp

	move.b	d0,(a5)
	nop
	move	d0,(a5)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move	(a0),(a0)
	nop
	move	d0,(a4)
	move.b	d0,(a4)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move	(a0),(a0)
	move.b	d0,(a5)
	nop
	move	d0,(a5)
	move	d0,(a4)
	move.l	(a0),(a0)
	move.l	(a0),(a0)

	move.b	d0,(a5)
	nop
	move	d0,(a5)
	move.b	d0,(a4)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	or.l	d0,d0
	move	d0,(a4)
	move.b	d0,(a4)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move	(a0),(a0)
	move.b	d0,(a5)
	nop
	move	d0,(a5)

	move.l	(a0),(a0)
	move	(a0),(a0)
	nop
	move	#43,d2
fulldisp2
	nop
	move.b	d0,(a5)
	nop
	move	d0,(a5)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move	(a0),(a0)
	nop
	move	d0,(a4)
	move.b	d0,(a4)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move	(a0),(a0)
	move.b	d0,(a5)
	nop
	move	d0,(a5)
	move.l	(a0),(a0)
	move	(a0),(a0)
	dbf	d2,fulldisp2


	move.b	d0,(a5)
	nop
	move	d0,(a5)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move	(a0),(a0)
	nop
	move	d0,(a4)		285
	move.b	d0,(a4)		293
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move	(a0),(a0)
patch_127
	move.b	d0,(a5)				NOT DONE
	nop
	move	d0,(a5)
*	move.l	(a0),(a0)
*	move.l	(a0),(a0)
*	nop					417

*	move	#3194,d0
*wscreen3:
*	dbf	d0,wscreen3	8(move) + 3195*12 + 4(dbf) = 38352 = 74*512 + 464

*	nop			373


start_irq:
	move.b	#200,$FFFFFA21.w	16
	move.b	#4,$FFFFFA1B.w		16	Start Timer B

	bsr	coloroff

	btst	#0,$FFFFFC00.w
	beq.s	wend
	move.b	$FFFFFC02.w,d0
	bmi.s	wend
	cmp.b	#$3B,d0
	beq.s	bye
	cmp.b	#$39,d0
	beq.s	frozcase
	cmp.b	#$38,d0
	bne.s	wend
	lea	zstep(pc),a0
	not	(a0)
	bra.s	wend
frozcase:
	lea	zfrozen(pc),a0
	not	(a0)
wend
	move	zfrozen(pc),d0
	beq.s	wend0
	move	zstep(pc),d0
	beq.s	wend3
	lea	zstep(pc),a0
	not	(a0)
wend0
	lea	zboffset(pc),a0
	move.l	(a0),d0
	add.l	4(a0),d0
	beq.s	wend1
	cmp.l	#289*230,d0
	bne.s	wend2
wend1
	neg.l	4(a0)
wend2
	move.l	d0,(a0)
	bsr	swapbas
wend3
	bra	wait_mfp


bye:
	clr.b	$FFFFFA1B.w			Stop Timer B
its_over
	bsr	qwaitvbl
	clr.b	$FFFF820A.w
	move	#$2300,sr
	bsr	rest
	rts



zfrozen		dc.w	-1
zstep		dc.w	-1
zvideoptrs	ds.l	1
zcolors		ds.w	16
zpsyncstart	ds.l	1
zpsyncro	ds.l	1
grafil	dc.b	'forestv.pi1',0
syncfil	dc.b	'hardlast.blk',0
zboffset	dc.l	0
zspeed		dc.l	230

	even

***************************************************************************
* PROC: TEST_HW
***************************************************************************
test_hw:
	move	#$2700,sr
	bsr	qwaitvbl
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movem.l	d0-d7,$FFFF8240.w
	move.b	#0,$FFFF8260.w
	move.b	#2,$FFFF820A.w
	move	#$0555,d0
	move	#$0AAA,d1
	move	d0,$FFFF825E.w
	move	$FFFF825E.w,d2
	and	#$0FFF,d2
	move	d1,$FFFF825E.w
	move	$FFFF825E.w,d3
	and	#$0FFF,d3
	cmp	d0,d2
	bne.s	ltest_hw_0
	cmp	d1,d3
	bne.s	ltest_hw_0
	moveq	#1,d4
	bra.s	ltest_hw_1
ltest_hw_0
	moveq	#0,d4
ltest_hw_1
	lea	zSTE(pc),a0
	move.b	d4,(a0)
	move	#0,$FFFF825E.w
	bsr	qscr162
	lea	zoffset162a(pc),a0
	move.b	d0,(a0)
	lea	l162STF(pc),a0
	move	#$C140,(a0)			EXG	D0,D0		-37
	bsr	qscr162
	lea	zoffset162b(pc),a0
	move.b	d0,(a0)
	move.b	zSTE(pc),d0
	beq.s	ltest_hw_2
	lea	l000STE(pc),a0
	move	#$3880,(a0)+			MOVE	D0,(A4)		-43
	move	#$4E71,(a0)+			NOP			-39
	move	#$1880,(a0)+			MOVE.B	D0,(A4)		-31
	move	#$8080,(a0)+			OR.L	D0,D0		-23
	move	#$8080,(a0)+			OR.L	D0,D0		-15
	bsr	qscr000
	cmp.b	#$A0,d0
	bne.s	ltest_hw_4
	lea	zwakeup(pc),a0
	move.b	#2,(a0)
	move.b	zoffset162a(pc),d0
	cmp.b	#$8E,d0
	beq.s	ltest_hw_5
	bra.s	ltest_hw_4
ltest_hw_2
	bsr	qscr000
	cmp.b	#$A0,d0
	bne.s	ltest_hw_3
	lea	zwakeup(pc),a0
	move.b	#2,(a0)
	move.b	zoffset162a(pc),d0
	cmp.b	#$8E,d0
	bne.s	ltest_hw_4
	bra.s	ltest_hw_5
ltest_hw_3
	lea	l000STFA(pc),a0
	move	#$4E71,(a0)			NOP			-35
	lea	l000STFB(pc),a0
	move	#$8080,(a0)			OR.L	D0,D0		-11
	bsr	qscr000
	cmp.b	#$A0,d0
	bne.s	ltest_hw_4
	lea	zwakeup(pc),a0
	move.b	#1,(a0)
	move.b	zoffset162b(pc),d0
	cmp.b	#$8E,d0
	beq.s	ltest_hw_5
ltest_hw_4
	lea	zwakeup(pc),a0
	move.b	#0,(a0)
ltest_hw_5
	bsr	qwaitvbl
	clr.b	$FFFF820A.w
	bsr	rest
	pea	clsrn(pc)
	bsr	write_it
	pea	texto01(pc)
	bsr	write_it
	pea	crlf(pc)
	bsr	write_it
	pea	texto02(pc)
	bsr	write_it
	pea	texto03(pc)
	bsr	write_it
	pea	texto04(pc)
	bsr	write_it
	pea	texto05(pc)
	bsr	write_it
	pea	texto05A(pc)
	bsr	write_it
	pea	texto06(pc)
	bsr	write_it
	pea	texto07(pc)
	bsr	write_it
	pea	texto08(pc)
	bsr	write_it
	pea	texto09(pc)
	bsr	write_it
	pea	texto10(pc)
	bsr	write_it
	pea	texto11(pc)
	bsr	write_it
	move.b	zSTE(pc),d0
	beq.s	ltest_hw_6
	pea	texto12(pc)
	bsr	write_it
	bra.s	ltest_hw_9
ltest_hw_6
	pea	texto13(pc)
	bsr	write_it
	move.b	zwakeup(pc),d0
	cmp.b	#1,d0
	bne.s	ltest_hw_7
	pea	texto14(pc)
	bsr	write_it
	bra.s	ltest_hw_9
ltest_hw_7
	cmp.b	#2,d0
	bne.s	ltest_hw_8
	pea	texto15(pc)
	bsr	write_it
	bra.s	ltest_hw_9
ltest_hw_8
	pea	texto16(pc)
	bsr	write_it
ltest_hw_9
	move.b	zwakeup(pc),d0
	bne.s	ltest_hw_A
	pea	texto17(pc)
	bsr	write_it
	bra.s	ltest_hw_B
ltest_hw_A
	pea	texto18(pc)
	bsr	write_it
ltest_hw_B
	pea	crlf(pc)
	bsr	write_it
	pea	texto19(pc)
	bsr	write_it
	pea	texto20(pc)
	bsr	write_it
	move.b	zwakeup(pc),d0
	seq	d1
	bne.s	ltest_hw_C
	move	#7,-(sp)
	trap	#1
	addq	#2,sp
	moveq	#-1,d1
ltest_hw_C
	rts


zSTE		ds.b	1
zwakeup		ds.b	1
zoffset162a	ds.b	1
zoffset162b	ds.b	1

write_it
	move.l	4(sp),d0
	move.l	(sp),a0
	move.l	a0,4(sp)
	move.l	d0,(sp)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
	rts

clsrn	dc.b	27,'E',0
texto01	dc.b	'Hi !',13,10,0
texto02	dc.b	'This program runs with 512KB.',13,10,0
texto03	dc.b	'It features a 416x560 pixels picture',13,10,0
texto04	dc.b	'scrolling using sync scrolling with',13,10,0
texto05	dc.b	'4(*) lines to control it: sync line + 3.',13,10,0
texto05A dc.b	'(*) For 127 of 128 offsets.',13,10,0
texto06	dc.b	'The program itself is not optimized in',13,10,0
texto07	dc.b	'any way and has only been done to prove',13,10,0
texto08	dc.b	'that this sync scrolling can be done.',13,10,0
texto09	dc.b	'This program is not supported by current',13,10,0
texto10	dc.b	'emulators releases: SainT1.99g/STEem3.2.',13,10,0
texto11	dc.b	'Your system was detected as an ',0
texto12 dc.b	'STE.',13,10,0
texto13 dc.b	'STF',0
texto14 dc.b	'(1).',13,10,0
texto15 dc.b	'(2).',13,10,0
texto16 dc.b	'.',13,10,0
texto17 dc.b	'Your HW does not support this program.',13,10,0
texto18 dc.b	'SPACE holds ALT steps and F1 quits.',13,10,0
texto19	dc.b	'That is all ... for now.',13,10,0
texto20	dc.b	'Paulo Simoes / LJBK  26 November 2006',13,10,0
crlf	dc.b	13,10,0
	even

***************************************************************************
* PROC: QSCR000
***************************************************************************
qscr000:
	bsr	qwaitvbl
	lea	$FFFF820A.w,a4
	lea	$FFFF8209.w,a0
	moveq	#32,d0
lscr000_0
	tst.b	(a0)
	beq.s	lscr000_0
	sub.b	(a0),d0
	lsr	d0,d1		053
	lea	$FFFF8240.w,a0	061
	moveq	#2,d0		065
	move	#198,d1		073
lscr000_1
	nop			077
	move.l	(a0),(a0)	097
	move.l	(a0),(a0)	117
	move.l	(a0),(a0)	137
	move.l	(a0),(a0)	157
	move.l	(a0),(a0)	177
	move.l	(a0),(a0)	197
	move.l	(a0),(a0)	217
	move.l	(a0),(a0)	237
	move.l	(a0),(a0)	257
	move.l	(a0),(a0)	277
	move.l	(a0),(a0)	297
	move.l	(a0),(a0)	317
	move.l	(a0),(a0)	337
	move.l	(a0),(a0)	357
	move.l	(a0),(a0)	377
	move.l	(a0),(a0)	397
	move.l	(a0),(a0)	-95/417
	move.l	(a0),(a0)	-75
	move.l	(a0),(a0)	-55
	nop			-51
l000STE
	or.l	d0,d0		-43		STE place
	nop			-39
l000STFA
	exg	d0,d0		-33		OR NOP		-35
	move	d0,(a4)		-25				-27
	move.b	d0,(a4)		-15				-19
l000STFB
	nop			-11		OR OR.L	D0,D0	-11
	nop			-07
	move.l	(a0),(a0)	013
	move.l	(a0),(a0)	033
	move.l	(a0),(a0)	053
	or.l	d0,d0		061
	dbf	d1,lscr000_1	077,073
	move.l	(a0),(a0)	097
	move.l	(a0),(a0)	117
	move.l	(a0),(a0)	137
	move.l	(a0),(a0)	157
	move.l	(a0),(a0)	177
	move.l	(a0),(a0)	197
	move.l	(a0),(a0)	217
	move.l	(a0),(a0)	237
	move.l	(a0),(a0)	257
	move.l	(a0),(a0)	277
	move.l	(a0),(a0)	297
	move.l	(a0),(a0)	317
	move.l	(a0),(a0)	337
	move.b	$FFFF8209.w,d0
	rts


***************************************************************************
* PROC: QSCR162
***************************************************************************
qscr162:
	bsr	qwaitvbl
	lea	$FFFF820A.w,a4
	lea	$FFFF8209.w,a0
	moveq	#32,d0
lscr162_0
	tst.b	(a0)
	beq.s	lscr162_0
	sub.b	(a0),d0
	lsr	d0,d1		053
	lea	$FFFF8240.w,a0	061
	moveq	#2,d0		065
	move	#198,d1		073
lscr162_1
	nop			077
	move.l	(a0),(a0)	097
	move.l	(a0),(a0)	117
	move.l	(a0),(a0)	137
	move.l	(a0),(a0)	157
	move.l	(a0),(a0)	177
	move.l	(a0),(a0)	197
	move.l	(a0),(a0)	217
	move.l	(a0),(a0)	237
	move.l	(a0),(a0)	257
	move.l	(a0),(a0)	277
	move.l	(a0),(a0)	297
	move.l	(a0),(a0)	317
	move.l	(a0),(a0)	337
	move.l	(a0),(a0)	357
	move.l	(a0),(a0)	377
	move.l	(a0),(a0)	397
	move.l	(a0),(a0)	-95/417
	move.l	(a0),(a0)	-75
	move.l	(a0),(a0)	-55
	move	d0,(a4)		-47
	nop			-43
l162STF
	or.l	d0,d0		-35		EXG	D0,D0	-37
	move.b	d0,(a4)		-27				-29
	move.l	(a0),(a0)	-07
	move.l	(a0),(a0)	013
	move.l	(a0),(a0)	033
	move.l	(a0),(a0)	053
	or.l	d0,d0		061
	dbf	d1,lscr162_1	077,073
	move.l	(a0),(a0)	097
	move.l	(a0),(a0)	117
	move.l	(a0),(a0)	137
	move.l	(a0),(a0)	157
	move.l	(a0),(a0)	177
	move.l	(a0),(a0)	197
	move.l	(a0),(a0)	217
	move.l	(a0),(a0)	237
	move.l	(a0),(a0)	257
	move.l	(a0),(a0)	277
	move.l	(a0),(a0)	297
	move.l	(a0),(a0)	317
	move.l	(a0),(a0)	337
	move.b	$FFFF8209.w,d0
	rts


***************************************************************************
* PROC: QWAITVBL
***************************************************************************
qwaitVBL:
	lea	$FFFF8201.w,a0		current video memory start address
	movep	0(a0),d0
	lea	$FFFF8205.w,a0		current video memory address
lwaitVBL_0
	movep	0(a0),d1
	cmp	d0,d1			wait while both are equal
	beq.s	lwaitVBL_0		(top border ? )
lwaitVBL_1
	movep	0(a0),d1
	cmp	d0,d1			wait while they are different
	bne.s	lwaitVBL_1		(screen or lower border ?)
	rts

***************************************************************************
* PROC: SWAPBAS
***************************************************************************
swapbas:
	move.l	zvideoptrs(pc),d0
	lea	patch_127(pc),a1
	move	#$1A80,d2
	move.l	zboffset(pc),d1
	cmp.b	#254,d1
	bne.s	swapbas1
	move	#$3A80,d2
swapbas1:
	move	d2,(a1)
	move	d1,d2
	and	#%11111110,d2		multiple of 2
	add	d2,d2
	add	d2,d2
	add	d2,d2			16 bytes per case
	move.l	zpsyncstart(pc),a1
	add	d2,a1
	moveq	#0,d2
	move.b	(a1)+,d2
	lea	$FFFF8201.w,a0
	lsr.l	#8,d0
	add	d2,d0			add offset
	lsr.l	#8,d1
	add	d1,d0
	movep	d0,0(a0)		set HW registers
	lea	zpsyncro(pc),a2
	move.l	a1,(a2)
	rts

coloroff:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movem.l	d0-d7,$FFFF8240.w
	rts

***************************************************************************
* PROC: VBL
***************************************************************************
vbl:
	addq.l	#1,$466.w
	rte

hbl:
	rte

qtimerb:
	bclr	#0,$FFFFFA0F.w
	rte





bload:
	link	a6,#0
	movem.l	d5-d7,-(sp)	Save registers D5 -> D7	
	pea	databuf(pc)	Set disk transfer address
	move	#$1A,-(sp)
	trap	#1
	addq	#6,sp
	move	12(a6),-(sp)
	move.l	8(a6),-(sp)
	move	#$4E,-(sp)
	trap	#1		Search file
	addq	#8,sp
	tst	d0
	sne	d1
	bne.s	bloadend
	move	12(a6),-(sp)
	move.l	8(a6),-(sp)	File name pointer
	move	#$3D,-(sp)
	trap	#1		Open file
	addq	#8,sp	
	tst	d0
	smi	d1
	bmi.s	bloadend
	move	d0,d7
	lea	databuf(pc),a0
	move.l	26(a0),d5	File length
	move.l	d5,-(sp)
	move	#$48,-(sp)
	trap	#1		Reserves memory
	addq	#6,sp
	tst.l	d0
	smi	d1
	bmi.s	bloadend
	move.l	d0,d6
	move.l	d0,-(sp)
	move.l	d5,-(sp)
	move	d7,-(sp)
	move	#$3F,-(sp)
	trap	#1		Read file
	lea	12(sp),sp
	cmp.l	d0,d5
	sne	d1
	bne.s	bloadend
	move	d7,-(sp)
	move	#$3E,-(sp)
	trap	#1		Close file
	addq	#4,sp
	tst	d0
	smi	d1
	move.l	d6,a0
	move.l	d5,d0
bloadend:	movem.l	(sp)+,d5-d7	Restore registers D5 -> D7
	unlk	a6
	rts
databuf	ds.b	44

instvid:	bsr	wsync
	move.b	#2,$FFFF820A.w
	clr.b	$FFFF8260.w
	rts

wsync:	move.l	$466.w,d0
wsync1:	cmp.l	$466.w,d0
	beq.s	wsync1
	rts

inikey:	lea	key1(pc),a0
inikey2:	move.b	(a0)+,d0
	bmi.s	inikey1
	bsr	wacia
	bra.s	inikey2
inikey1:	rts

wacia:	btst	#1,$FFFFFC00.w
	beq.s	wacia
	move.b	d0,$FFFFFC02.w
	rts

restkey:	lea	key2(pc),a0
restkey2:	move.b	(a0)+,d0
	bmi.s	restkey1
	bsr	wacia
	bra.s	restkey2
restkey1:	rts

key1	dc.b	$12,$1A,$FF
key2	dc.b	$14,$8,$FF

sav:	bsr	savideo
	bsr	savmfp
	rts

install:	bsr	instvid
	or	#$700,sr
	bsr	inikey
	bsr	instmfp
	and	#$FBFF,sr
	rts

rest:	or	#$700,sr
	bsr	restkey
	bsr	restmfp
	bsr	psgoff
	and	#$FBFF,sr
	bsr	restvideo
	rts

psgoff:	moveq	#13,d7
	lea	$FFFF8800.w,a0
clspsg:	move.b	d7,(a0)
	clr.b	2(a0)
	dbf	d7,clspsg
	move.b	#7,(a0)
	st	2(a0)
	rts	

instmfp:
	clr.b	$FFFFFA07.w
	clr.b	$FFFFFA09.w
	lea	hbl(pc),a0
	move.l	a0,$68.w
	lea	vbl(pc),a0
	move.l	a0,$70.w
	clr.b	$FFFFFA1B.w
	or.b	#%00000001,$FFFFFA07.w	allow TIMER B
	or.b	#%00000001,$FFFFFA13.w	allow TIMER B
	lea	qtimerb(pc),a0
	move.l	a0,$120.w
	rts

savmfp:	lea	mfp(pc),a0
	lea	$FFFFFA00.w,a1
	movep.l	$07(a1),d0
	move.l	d0,(a0)+
	movep.l	$0F(a1),d0
	move.l	d0,(a0)+
	movep.l	$17(a1),d0
	move.l	d0,(a0)+
	movep	$1F(a1),d0
	move	d0,(a0)+
	lea	$100.w,a1
	moveq	#15,d0
savmfp1:	move.l	(a1)+,(a0)+
	dbf	d0,savmfp1
	lea	savbl(pc),a0
	move.l	$70.w,(a0)
	lea	savhbl(pc),a0
	move.l	$68.w,(a0)
	rts
mfp:	ds.w	38
savbl:	ds.l	1
savhbl:	ds.l	1
restmfp:	lea	mfp(pc),a0
	lea	$FFFFFA00.w,a1
	move.l	(a0)+,d0
	movep.l	d0,$07(a1)
	move.l	(a0)+,d0
	movep.l	d0,$0F(a1)
	move.l	(a0)+,d0
	movep.l	d0,$17(a1)
	move	(a0)+,d0
	movep	d0,$1F(a1)
	lea	$100.w,a1
	moveq	#15,d0
restmfp1:	move.l	(a0)+,(a1)+
	dbf	d0,restmfp1
	move.l	savbl(pc),$70.w
	move.l	savhbl(pc),$68.w
	rts

savideo:	lea	$FFFF8200.w,a0
	movep	1(a0),d0
	lea	oldbase(pc),a1
	move	d0,(a1)
	lea	oldsync(pc),a1
	move.b	10(a0),(a1)
	lea	oldcol(pc),a1
	movem.l	$40(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	oldres(pc),a1
	move.b	$60(a0),(a1)
	rts
oldbase	ds.w	1
oldcol	ds.w	16
oldsync	ds.b	1
oldres	ds.b	1
restvideo:bsr	wsync
	lea	$FFFF8200.w,a0
	lea	oldsync(pc),a1
	move.b	(a1),10(a0)
	lea	oldcol(pc),a1
	movem.l	(a1),d0-d7
	movem.l	d0-d7,$40(a0)
	lea	oldres(pc),a1
	move.b	(a1),$60(a0)
	lea	oldbase(pc),a1
	moveq	#0,d0
	move	(a1),d0
	movep	d0,1(a0)
	lsl.l	#8,d0
	move.l	d0,$44E.w
	rts

***************************************************************************
* PROC: GETDRV
***************************************************************************
getdrv:
	move	#$19,-(sp)		Get current drive
	trap	#1
	addq	#2,sp
	lea	drive(pc),a0
	add.b	#'A',d0
	move.b	d0,(a0)
	rts

drive		ds.b	1

	even

***************************************************************************
* PROC: WDRVMOT
***************************************************************************
wdrvmot:
	move.b	drive(pc),d0
	cmp.b	#'C',d0
	bpl.s	wdrvmot_e
	move	#$80,$8606.w		status register
wdrvmot1:
	moveq	#64,d0
wdrvmot2:
	dbf	d0,wdrvmot2		delay
	move	$8604.w,d0		status
	btst	#7,d0			motor running ?
	bne.s	wdrvmot1		yes
	move	sr,-(sp)
	move	#$2700,sr
	move.b	#14,$8800.w		register 14
	move.b	$8800.w,d0		actual value
	or.b	#%00000111,d0		unselect drives
	move.b	d0,$8802.w
	move	(sp)+,sr
wdrvmot_e:
	rts

	even

