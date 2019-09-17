********************************************************************************
*
* Name     : SAMPLAY.S
* Title    : Play RAW sample using Yamaha sound chip
* Author   : Kevin Preece
* Assembler: DevPac 3
*
*--- DESCRIPTION ---------------------------------------------------------------
*
* To play a RAW sample using the YM2149 sound chip.  RAW samples are those that
* comprise unsigned byte integers (0-255).
*
* Samples obtained from samplers that save signed data can be played, if the
* sample data is first processed by adding 128 to each value before passing it
* into this routine.
*
* The calling routine is responsible for removing any headers that the sample
* data may have.
*
********************************************************************************

PlaySample	pea	init(pc)		our init routine
		move.w	#38,-(sp)		execute in super mode
		trap	#14
		addq.l	#6,sp
		move.l	#jungle,adsta	start address of sample data
		move.l	#jung_end,adend	end address of sample data
		move.w	#30,speed		sample speed (kHz)
		bsr.s	st		play sample
		pea	deinit(pc)	address of cleanup routine
		move.w	#38,-(sp)		must run in super mode
		trap	#14
		addq.l	#6,sp
		clr.w	-(sp)		all done!
		trap	#1

init		move.l	#$1a0005,-(sp)	disable MK68901 interrupt 5 (200Hz clock?)
		trap	#14
		addq.l	#4,sp
		move.w	#0,$452.w		disable vblanks interrupts
		move.w	#1,$43e.w		lock out floppy drives
		rts

deinit		move.l	#$1b0005,-(sp)	re-enable MFP interrupt 5
		trap	#14
		addq.l	#4,sp
		move.w	#1,$452.w		re-enable vblank
		move.w	#0,$43e.w		release floppy lock
		rts

st		move.w	speed,d0		how fast is replay speed
		cmp.w	#3,d0		< 2kHz
		blt.s	noplay		- cant play it
		subq.w	#3,d0		adjust so that it is a zero based index
		add.w	d0,d0		... that inexes an array of words
		cmp.w	#26,d0		is replay speed > 19kHz?
		bgt.s	fastplay		yes - its too fast to play on interrupt

*
* The sample rate is slow enough (<20kHz) to be replayed using interrupts.  Set up interrupt
* routine using XBTIMER.
*
		pea	playsample(pc)	this is interrupt routine that will play the sample
		move.l	adsta,sampleaddr+2	set start address of sample
		move.w	slist(pc,d0.w),-(sp)    data to be placed in timer data register
		move.w	#1,-(sp)		data to be placed in timers control register
		move.w	#0,-(sp)		use timer 0 (whis is available for applications use)
		move.w	#31,-(sp)
		trap	#14
		lea	12(sp),sp
noplay		rts

*
* This table holds the timer data values for replay speeds from 3kHz upwards in 1kHz steps.
*
slist		dc.w	205,154,123,102,88,77,68,61,56,51,47,44,41,38
		dc.w	36,34,32,31,29,28,27,26,25,24,23,22,21,20

*
* Routine for playing samples that are too fast to be played by interrupt.  What we must do instead
* is set up an interrupt, the sevice routine of which simply resets a flag.  We enter a tight polling
* loop watching for this flag to be reset.  When it is we update the sound hardware with the next
* byte of the sample.
*
fastplay		cmp.w	#54,d0		is speed > 30kHz
		bgt.s	noplay		yes - its too fast for us
		pea	fastsample(pc)	interrupt service routine
		move.w	slist(pc,d0.w),-(sp)	get data for timer data register
		pea	1.w		data for timer control register
		move.w	#31,-(sp)		set up timer
		trap	#14
		lea	12(sp),sp
		pea	fast(pc)		this is sample play routine
		move.w	#38,-(sp)		which must run in super mode
		trap	#14
		addq.l	#6,sp
		rts

fast		move.l	adsta,a0		get start address
		lea	lconv(pc),a1	?
		move.l	adend,a3		get samples end address
		lea	flag(pc),a4	this is flag that interrupt service routine sets
		moveq	#0,d2
fastloop		tst.b	(a4)		has interrupt occured yet?
		beq.s	fastloop		no - wait some more
		sf	(a4)		reset flag
		move.b	(a0)+,d2		get next sample byte
		and.w	#$fc,d2		filter out any noise in the lowest two bits
		move.w	0(a1,d2.w),d0
		move.w	2(a1,d2.w),d1
		move.b	#9,$ffff8800.w
		move.b	d0,$ffff8802.w
		move.b	#10,$ffff8800.w
		move.b	d1,$ffff8802.w
		cmp.l	a3,a0		are we done yet?
		blt.s	fastloop		nope - go back for more
		move.l	#$1a000d,-(sp)	disable MFP interrupt 13
		trap	#14
		addq.l	#4,sp
		move.b	#0,$fffffa07.w
		move.b	#8,$ffff8800.w
		move.b	#0,$ffff8802.w
		move.b	#9,$ffff8800.w
		move.b	#0,$ffff8802.w
		move.b	#10,$ffff8800.w
		move.b	#0,$ffff8802.w
		rts

fastsample	st	flag		signal that interrupt has occurred
		bclr	#5,$fffffa0f.w	clear the MFP interrupt 
		rte

playsample	or.w	#$700,sr		Turn off all interrupts
		movem.l	d0-d2/a0-a2,-(sp)	Save registers
		clr.w	d0		Keep bottom word clean
		lea	sampleaddr+2(pc),a2
		move.l	adend,a1
sampleaddr	move.b	playsample,d0	Self modified address!
		and.w	#$fc,d0
		addq.l	#1,(a2)		Increment to point to next byte
		move.w	lconv(pc,d0.w),d1
		move.w	lconv+2(pc,d0.w),d2
		sub.l	a0,a0
		move.b	#9,$ffff8800.w	B
		move.b	d1,$ffff8802.w	B
		move.b	#10,$ffff8800.w	C
		move.b	d2,$ffff8802.w	C
		cmp.l	(a2),a1		Have we finished?
		beq.s	weredon		yes - tidy up
		movem.l	(sp)+,d0-d2/a0-a2
		bclr	#5,$fffffa0f.w
		rte
				
* Whole sample has been played, so shut off the sound

weredon		move.l	$4a2.w,-(sp)
		sub.l	#46,$4a2.w
		move.l	#$1a000d,-(sp)
		trap	#14
		addq.l	#4,sp
		move.l	(sp)+,$4a2.w
		move.b	#0,$fffffa07.w
		move.b	#8,$ffff8800.w
		move.b	#0,$ffff8802.w
		move.b	#9,$ffff8800.w
		move.b	#0,$ffff8802.w
		move.b	#10,$ffff8800.w
		move.b	#0,$ffff8802.w
		movem.l	(sp)+,d0-d2/a0-a2
		bclr	#5,$fffffa0f.w
		rte

*
* A log to linear conversion table
*
lconv		dc.w	0,0,2,0
		dc.w	2,1,2,2
		dc.w	3,2,4,1
		dc.w	4,2,5,2
		dc.w	6,0,6,2
		dc.w	6,3,6,4
		dc.w	7,2,7,4
		dc.w	7,5,8,2
		dc.w	8,3,8,4
		dc.w	8,5,9,2
		dc.w	9,3,9,4
		dc.w	9,5,9,6
		dc.w	9,7,$A,3
		dc.w	$A,4,$A,5
		dc.w	$A,6,$A,7
		dc.w	$B,0,$B,1
		dc.w	$B,2,$B,4
		dc.w	$B,5,$B,6
		dc.w	$B,7,$B,8
		dc.w	$B,8,$B,9
		dc.w	$B,9,$C,0
		dc.w	$C,1,$C,2
		dc.w	$C,3,$C,4
		dc.w	$C,5,$C,6
		dc.w	$C,8,$C,8
		dc.w	$C,9,$C,9
		dc.w	$C,9,$C,$A
		dc.w	$D,0,$D,2
		dc.w	$D,3,$D,4
		dc.w	$D,5,$D,6
		dc.w	$D,7,$D,8
		dc.w	$D,8,$D,9

adsta		dc.l	$20000
adend		dc.l	$77000
speed		dc.w	11
flag		dc.w	0

jungle		incbin	jungle.sam	put your sample here!
jung_end		end
