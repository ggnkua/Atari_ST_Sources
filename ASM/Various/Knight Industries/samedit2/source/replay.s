; replay routines
	SECTION	text
playSample
; does the machine have a DMA chip?
	move.b	#%00000011,d7
playCheck
	lea	sampleInfoTable,a0

	tst.w	sampleLoaded(a0)
	beq	.noPlay

	bsr	stopSampleReplay

	move.l	dmaSound,d1
	cmpi.l	#2,d1
	bge	dmaPlay
; yamaha playback
	bra	yamahaPlay
.noPlay
	rts
dmaPlay
	lea	sampleInfoTable,a3

	tst.w	sampleMode(a3)
	bne	dmaPlayD2D

	move.l	sampleAddress(a3),d4
	add.l	blockStart,d4
	move.l	d4,d5
	add.l	blockSize,d5

	super	#0
	move.b	d4,$ffff8907.w	; low
	move.b	d4,$ffff890d.w
	lsr.w	#8,d4
	move.b	d4,$ffff8905.w	; mid
	move.b	d4,$ffff890b
	swap	d4
	move.b	d4,$ffff8903.w	; high
	move.b	d4,$ffff8909.w
	sub.l	#4,d5
	move.b	d5,$ffff8913.w	; low
	lsr.w	#8,d5
	move.b	d5,$ffff8911.w	; mid
	swap	d5
	move.b	d5,$ffff890f.w	; high
	move.b	DMARate,$ffff8921	; rate

	cmpi.w	#16,sampleResolution(a3)
	beq	check16Bit

beginReplay
	move.b	d7,$ffff8901
	super	d0

	rts
check16Bit
	move.l	dmaSound,d1
	andi.l	#4,d1
	beq	cantPlay16
	ori.b	#64,$ffff8921
	bra	beginReplay	
	
cantPlay16
	rsrc_gaddr	#5,#CANTPLAY16BIT
	form_alert	#1,addrout
	super	d0
	rts
	
playSampleOnce
	move.b	#%00000001,d7
	bra	playCheck

	rts
;-------------------------------------------------------------------------
yamahaPlay

	rts
;-------------------------------------------------------------------------
dmaPlayD2D
	cmpi.w	#16,sampleResolution(a3)
	bne	.not16
	super	#0
	move.l	dmaSound,d1
	andi.l	#4,d1
	beq	cantPlay16
	super	d0
.not16
	lea	optionsTable,a1
	move.w	optionD2DSize(a1),d0
	bgt.s	.do
; no D2D Buffer
	bra	cantAllocateD2D
.do
	ext.l	d0
	move.l	#1024,d1
	jsr	long_mul
; buffer size in d0
	move.l	blockSize,d1
	cmp.l	d0,d1
	bgt	.greaterThanBuffer
	move.l	d1,d0	; set buffer size 2 use
.greaterThanBuffer
	asr.l	#1,d0	; half d0
	move.l	d0,d2dPlaySize
	move.l	d1,d2dTotalSize
	move.l	D2DBuffer,d2dFirst
	move.l	D2DBuffer,d2dSecond
	add.l	d0,d2dSecond
;open file
	lea	samplePathname(a3),a4
	f_open	#0,a4
	move.w	d0,d2dHandle
; set pointer at start of sample data
	f_seek	#0,sampleHeaderSize(a3),d2dHandle
; read 1st half of buffer
	f_read	d2dFirst,d2dPlaySize,d2dHandle

d2dPlayNext	; d2dFirst = play address, d2dSecond = load address
	clr.w	d2dNext

	super	#0
	bclr	#3,$ffff8900
	bset	#2,$ffff8900
	bclr	#7,$ffff8901
	move.l	d2dFirst,d4
	move.l	d4,d5
	add.l	d2dPlaySize,d5
	move.b	d4,$ffff8907.w	; low
	move.b	d4,$ffff890d.w
	lsr.w	#8,d4
	move.b	d4,$ffff8905.w	; mid
	move.b	d4,$ffff890b
	swap	d4
	move.b	d4,$ffff8903.w	; high
	move.b	d4,$ffff8909.w
	sub.l	#4,d5
	move.b	d5,$ffff8913.w	; low
	lsr.w	#8,d5
	move.b	d5,$ffff8911.w	; mid
	swap	d5
	move.b	d5,$ffff890f.w	; high
	move.b	DMARate,$ffff8921	; rate
	move.l	d0,d5
	lea	sampleInfoTable,a3
	cmpi.w	#16,sampleResolution(a3)
	bne	.not16
	ori.b	#64,$ffff8921	
.not16
	move.l	d2dTotalSize,d0
	sub.l	d2dPlaySize,d0
	bmi	.noLoad
	move.l	d0,d2dTotalSize
	Xbtimer	#d2dTriggerNext,#1,#8,#0
	bset	#1,$ffff8901
	bset	#0,$ffff8901
	super	d5

	move.l	d2dTotalSize,d0
	cmp.l	d2dPlaySize,d0
	bgt	.load
	move.l	d0,d2dTotalSize
.load
	f_read	d2dSecond,d2dPlaySize,d2dHandle
	move.l	d2dSecond,d0
	move.l	d2dFirst,d1
	move.l	d1,d2dSecond
	move.l	d0,d2dFirst

	rts
.noLoad
	f_close	d2dHandle
	Xbtimer	#d2dTriggerNext,#0,#0,#0
	bclr.b	#5,$fffffa0f.w
	move.b	#0,$ffff8901
	super	d5
	rts
d2dTriggerNext
	move.w	#1,d2dNext
	bclr	#4,$ffff8901
	rte

;-------------------------------------------------------------------------
	SECTION	bss
	even
DMARate	ds.b	1
	even
d2dTotalSize	ds.l	1
d2dPlaySize	ds.l	1
d2dHandle	ds.w	1
d2dNext	ds.w	1
d2dFirst	ds.l	1
d2dSecond	ds.l	1