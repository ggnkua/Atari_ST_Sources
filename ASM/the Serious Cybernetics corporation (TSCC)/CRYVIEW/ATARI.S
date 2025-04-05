*******************************
*  void writeln(char[] * a0.l)
*
* Output a string to stdout
*******************************

		section	text
writeln		pea.l	(a0)
		move.w	#9,-(sp)	; Writeln()
		trap	#1
		addq.l	#6,sp
		rts

*******************************
*  void waitkey()
*
* Wait for a keypress
*******************************

waitkey		move.w	#8,-(sp)
		trap	#1
		addq.l	#2,sp
		rts

*******************************
*  void flush()
*
* Read all data waiting in the ACIA buffer
*******************************

flush		lea.l	$fffffc00.w,a0
.flush		btst.b	#0,(a0)		; Any Data waiting?
		beq.s   .break
		tst.b	2(a0)		; Read the data
		bra.s	.flush

.break		rts


*********************************
*  void sendIKBD(d0.b cmd)
*
* Send a command to the IKBD via the
* ACIA interface
*********************************

sendIKBD	bsr.s	flush
		move.b	d0,2(a0)
		rts

*******************************
*  d1.l binToBCD(d0.w value)
*
* Convert the given value into a 4 digit BCD string
*******************************

binToBCD	moveq.l	#0,d1
		moveq.l	#0,d2

		neg.l	d0
		beq.s	.null		; Number==0?
		neg.l	d0		; Initialize X flag

.leftalign	addx.w	d0,d0		; Remove leading zeros
		bcc.s	.leftalign		

.bcdloop	abcd.b	d2,d2		; Least significant digits
		abcd.b	d1,d1		; Most significant digits

		add.w	d0,d0		; Number <<= 1 == 0 ?
		bne.s	.bcdloop

.null		unpk	d1,d1,#'00'
		swap.w	d1
		unpk	d2,d1,#'00'
		rts

*******************************
*  void init()
*
* Release unneeded memory, reserve screen pages and
* prepare commandline
*******************************

init		move.l	(sp)+,.ret	; Save return address

		movea.l	sp,a5
		movea.l	4(a5),a5	; Address to basepage

		move.l	$c(a5),d0	; TEXT
		add.l	$14(a5),d0	; DATA
		add.l	$1c(a5),d0	; BSS
		addi.l	#$200,d0	; Stack

		move.l	d0,d1
		add.l	a5,d1
		bclr.l	#0,d1		; Even address
		movea.l	d1,sp		; New Stackspace

		move.l	d0,-(sp)
		pea.l	(a5)
		pea.l	$4a0000		; MShrink()
		trap	#1
		lea.l	12(sp),sp

		lea.l	$80(a5),a5	; Command line
		moveq.l	#0,d0
		move.b	(a5)+,d0	; Number of chars
		clr.b	(a5,d0.l)	; Null terminate
		move.l	a5,CRYFileName


		clr.w	-(sp)		; Allocate screen pages
		pea.l	PHYSX*PHYSY*2+8	; in ST RAM
		move.w	#$44,-(sp)	; Mxalloc()
		trap	#1
		addq.l	#8,sp

		tst.l	d0		; Error?
		bne.s	.ok

		lea.l	.error(pc),a0
		bra.w	error

.ok		addq.l	#8,d0		; Align to an 8 byte boundary
		andi.b 	#-8,d0

		move.l	d0,physBaseCr	; Clear screens
		move.l	d0,a0
		addi.l	#PHYSX*PHYSY,d0
		move.l	d0,physBaseY

		move.l	#2*PHYSX*PHYSY/16-1,d0
.cls
	rept	4
		clr.l	(a0)+
	endr
		subq.l	#1,d0
		bpl.s	.cls


		lea.l	yPal,a0		; Init grey ramp to emulate
		lea.l	2*2*256(a0),a1
		movea.l	a1,a2

		moveq.l	#-1,d1
				
		move.w	#256-1,d0
.gryRamp	move.w	d0,-(a1)
		clr.w	(a0)+		; Clear underflow ranfe (black)
		move.w	#$ff,(a2)+	; Clear overflow range (white)
		dbra	d0,.gryRamp

		move.l	.ret(pc),-(sp)
		rts

.ret		ds.l	1

		section	data
.error		dc.b	'Could not allocate screens.',13,10,0
		even




*******************************
*  void interrupt vbl()
*
* Manage the interlacing and scrolling
*******************************

physBaseCr	ds.l	1		; Half images (Cr-Y)
physBaseY	ds.l	1

vblY		movem.l d0-d1/a0-a1,-(sp)	; Display Y halfpicture


		lea.l	yPal+2*256,a0	; Init grey color ramp
		adda.w	gamma(pc),a0	; add gamma value
		lea.l	$ffff8600.w,a1

		moveq.l	#256/2-1,d0
.yPal		move.l	-(a0),-(a1)
		dbra	d0,.yPal

		bset.b	#4,$ffff8262.w	; Set DAC to grey rendering mode

		tst.b	gryScale	; Greyscale mode?
		bne.s	.break		; yes, so shut down the interlacing

		move.l	physBaseCr(pc),d0
		move.b	d0,d1
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w
		move.b	d1,$ffff820d.w

		move.l	#vblCr,$70.w

.break		bsr.w	adjGamma	; Adjust gamma
		movem.l (sp)+,d0-d1/a0-a1
		rte

; Show C-R picture

vblCr		movem.l d0-d1/a0-a1,-(sp)

		move.l	physBaseY(pc),d0	; Display Cr halfpicture
		move.b	d0,d1
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w
		move.b	d1,$ffff820d.w

		lea.l	$ffff8600.w,a0	; Init Cr color table
		lea.l	crPal+$200(pc),a1

		moveq.l	#256/2-1,d0
.crPal	 	move.l	-(a1),-(a0)
		dbra	d0,.crPal

		bclr.b	#4,$ffff8262.w	; Set DAC to color rendering mode
		move.l	#vblY,$70.w
		
		bsr.w	adjGamma
		movem.l (sp)+,d0-d1/a0-a1
		rte

gryScale	dc.b	0	; Grayscale mode flag
		even

********************************************
*  void adjGamma()
*
* Adjust gamma value during vbl
********************************************

gamma		dc.w	$200		; Default gamma value
kbHit		ds.b	1
		even

adjGamma	move.b	$fffffc02.w,d0
		move.b	d0,kbHit
		
		cmpi.b	#102,d0		; Greyscale mode toggled? ('*' pressed ?)
		bne.s	.no_grytoggle
		tas.s	.gryHeld	; toggle only once
		bne.s	.no_grytoggle
		not.b	gryScale
		
.no_grytoggle	cmpi.b	#102+128,d0	; Greyscale key released?
		bne.s	.not_released
		sf.b	.gryHeld

.not_released	cmpi.b	#78,d0		; Lighten? ('+' pressed?)
		bne.s	.dont_lighten
		
		move.w	#2*512,d1	; Upper limit
		move.w	gamma(pc),d0
		addq.w	#2,d0		; ++gamma > u_limit?
		cmp.w	d1,d0
		blo.s	.lower
		
		move.w	d1,d0
.lower		move.w	d0,gamma
		rts
		
.dont_lighten	cmpi.b	#74,d0		; Darken? ('-' pressed?)
		bne.s	.dont_darken
		subq.w	#2,gamma	; --gamma < 0?
		bpl.s	.dont_darken
		clr.w	gamma
.dont_darken	rts

.gryHeld	dc.b	0		; Greyscale key semaphore
		even

		section	data
crPal		incbin	'cry.pal'

		section	bss
yPal		ds.w	256		; Black range
		ds.w	256		; Grey color ramp
		ds.w	256		; White range