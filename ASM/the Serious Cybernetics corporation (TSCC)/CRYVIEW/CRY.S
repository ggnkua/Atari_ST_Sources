; CRY header structure

		rsreset
cry.width	rs.w	1
cry.height	rs.w	1
		rs.w	2
cry.pixels	rs.b	0
cry.header	=	__RS


********************************************
*  loadCRY(char[] * CRYFileName.l)
*
* Load in a 16bpp CRY image from disc.
* TgaFileName->name of the file
********************************************

		section	text
loadCRY		lea.l	.message(pc),a0	; Write message
		bsr.w	writeln

		movea.l	CRYFileName(pc),a0
		bsr.w	writeln

; Read file header

		clr.w	-(sp)		; Open file (read only)
		move.l	CRYFileName(pc),-(sp)
		move.w	#$3d,-(sp)	; Fopen()
		trap	#1
		addq.l	#8,sp

		tst.l	d0
		bpl.s	.ok1		; File not found?

		lea.l	.error1(pc),a0	; Output error message
		bra.w	error		; and exit

.ok1		move.w	d0,.fhnd

		pea.l	.header(pc)	; Attempt to read header
		pea.l	cry.header.w
		move.w	d0,-(sp)
		move.w	#$3f,-(sp)	; Fread()
		trap	#1
		lea.l	12(sp),sp

		cmpi.w	#cry.header,d0
		beq.s	.ok2		; File corrupt?

		lea.l	.error2(pc),a0
		bra.w	error

.ok2		lea.l	.loadimage(pc),a0
		bsr.w	writeln


		; Length of pixel data in bytes
		movem.w  .header+cry.width(pc),d0/d1
		mulu.w	d1,d0
		add.l	d0,d0
		move.l	d0,-(sp)
		
		move.w	#1,-(sp)	; Reserve fastram block
		addq.l	#1,d0		; for image data
		move.l	d0,-(sp)
		move.w	#$44,-(sp)	; Mxalloc()
		trap	#1
		addq.l	#8,sp
		
		tst.l	d0		; Error?
		bne.s	.ok3

		lea.l	.error3(pc),a0
		bra.w	error
		
.ok3		addq.l	#1,d0		; Even align block
		bclr.l	#0,d0
		move.l	d0,CRYImage
		
		move.l	(sp)+,d1
		

		move.l	d0,-(sp)	; Read image
		move.l	d1,-(sp)
		move.w	.fhnd(pc),-(sp)
		move.w	#$3f,-(sp)	; Fread()
		trap	#1
		lea.l	12(sp),sp

		tst.l	d0
		bne.s	.ok4		; File corrupt?

		lea.l	.error2(pc),a0
		bra.w	error

.ok4    	lea.l	ok(pc),a0
		bsr.w	writeln

		move.w	.fhnd(pc),-(sp)
		move.w	#$3e,-(sp)	; Fclose()
		trap	#1
		addq.l	#4,sp


		lea.l	.cryDimensions(pc),a0
		move.w	.header+cry.width(pc),d0
		bsr.w	binToBCD
		move.l	d1,(a0)+
		move.w	.header+cry.height(pc),d0
		bsr.w	binToBCD
		move.l	d1,3(a0)

		lea.l	.crySize(pc),a0
		bsr.w	writeln

; Fit image maintaining its original aspect ratio

		lea.l	.rescale(pc),a0
		bsr.w	writeln
		
		movea.l	CRYImage(pc),a0		; &Src
		movem.l	physBaseCr(pc),a1/a2	; &DstCr, &DstY
		movea.w	.header+cry.width(pc),a3
		move.w	.header+cry.height(pc),d0
		bsr.w	fitImage

		lea.l	hitakey(pc),a0
		bsr.w	writeln
		bra.w	waitkey


.fhnd		ds.w	1
.header		ds.b	cry.header	; Space for the header

		section	data
.message	dc.b	27,'p 16bpp CRY viewer  ¾ by ray//.tSCc. 2005 '
		dc.b	13,10,27,'qLoading: ',0
.loadimage	dc.b	13,10,'Reading image: ',0
.crySize	dc.b	'Size: '
.cryDimensions	dc.b	'0000 x 0000 px.',13,10,0
.rescale	dc.b	'Rescaling: ',0
.error1		dc.b	13,10,'Bad filename. ',0
.error2		dc.b	13,10,'File is corrupt. ',0
.error3		dc.b	13,10,'Failed to allocate block.',0
ok		dc.b	'ok.',13,10,0
		even


		section	bss
CRYFileName	ds.l	1	; Pointer to file name
CRYImage	ds.l	1	; Block address of CRY image
		even



********************************************
*  void error(char[] a0.l * ErrorMsg)
*
* Write error message, wait for a key and exit.
********************************************

		section	text
error		bsr.w	writeln		; Write error message and exit
		lea.l	hitakey(pc),a0
		bsr.w	writeln
		bsr.w	waitkey

		addq.l	#4,sp		; Kill return address
		bra.w	exit

hitakey		dc.b	'Hit a key.',13,10,0
		even
	

********************************************
*  void fitImage(a0.l *Src, a1.l *DstCr, a2.l *DstY, a3.l width, d0.w height)
*	
* Rescale the source image (16bpp CRY) to fit window and
* transform result into two physical 8bpp halfpictures.
********************************************


fitImage	movem.l	a1-a2,-(sp)

		lea.l	.width(pc),a4	; Assumed destination dimensions
		move.l	#PHYSX,(a4)+
		move.l	#PHYSY/2,(a4)+
		
		cmp.w	a3,d0		; Choose the greater aspect dimension
		bls.s	.choose_width	; to fit image
		
.choose_height	move.l	#(PHYSY/2)<<8,d6; (PHYSY/2)/height, 24.8 fixed
		moveq.l	#0,d7
		move.l	d0,d7
		divu.l	d7,d6
		move.l	a3,d7
		mulu.l	d7,d6		; Rescaled width = width*(PHYSY/2)/height
		lsr.l	#8,d6
		move.l	d6,-8(a4)
				
		bra.s	.cont
		
.choose_width	cmp.w	a3,d0
		bls.s	.choose_height

		move.l	#PHYSX<<8,d6	; PHYSX/width, 24.8 fixed
		move.l	a3,d7
		divu.l	d7,d6
		moveq.l	#0,d7
		move.w	d0,d7
		mulu.l	d7,d6		; Rescaled height = height*PHYSX/width
		lsr.l	#8,d6
		move.l	d6,-4(a4)

.cont		swap.w	d0		; dy = height/dstheight, 16.16 fixed
		clr.w	d0
		divu.l	-(a4),d0
		moveq.l	#0,d4		; y = 0

		move.l	a3,d6
		swap.w	d6		; dx = width/dstwidth, 16.16 fixed
		divu.l	-(a4),d6
		
		lea.l	$7fff.w,a6	; ~0.5, 16.16 fixed
		
		move.l	.height(pc),d3
		subq.w	#1,d3

.yloop		move.l	d4,d5		; &Src[(int)y * width]
		add.l	a6,d5
		swap.w	d5
		move.w	a3,d1		; width
		mulu.w	d1,d5
		lea.l	(a0,d5.l*2),a4

		moveq.l	#0,d7		; x = 0
		move.l	.width(pc),d1
		lsr.w	d1
		bcs.s	.odd_width	; Odd width?
		subq.w	#1,d1
		
.xloop		move.l	d7,d2		; &Src[(int)y * width + (int)x]
		add.l	a6,d2
		swap.w	d2
		move.w	(a4,d2.w*2),d2
		move.b	d2,PHYSX(a2)	; Store Y value
		move.b	d2,(a2)+

		lsr.w	#8,d2		; Extract Cr value
		bne.s	.cr0  		; Replace Cr value 0x00 (black)
		moveq.l	#1,d2
.cr0		
	ifnd	ANTIALIAS_CR		; Add pixel lattice to decrease
		clr.b	PHYSX(a1)	; the flicker a bit if the Cr layer
	else				; is left unantialiased
		move.b	d2,PHYSX(a1)	
	endc
		move.b	d2,(a1)+
		add.l	d6,d7		; x += dx
		
.odd_width	move.l	d7,d2		; &Src[(int)y * width + (int)x]
		add.l	a6,d2
		swap.w	d2
		move.w	(a4,d2.w*2),d2
		move.b	d2,PHYSX(a2)
		move.b	d2,(a2)+

		lsr.w	#8,d2
		bne.s	.cr1
		moveq.l	#1,d2
.cr1		move.b	d2,PHYSX(a1)
	ifnd	ANTIALIAS_CR
		clr.b	(a1)+
	else
		move.b	d2,(a1)+
	endc
		add.l	d6,d7		; x += dx
		dbra	d1,.xloop

		lea.l	2*PHYSX(a1),a1	; Skip one row
		suba.l	.width(pc),a1
		lea.l	2*PHYSX(a2),a2
		suba.l	.width(pc),a2

		add.l	d0,d4		; y += dy
		dbra	d3,.yloop

		lea.l	ok(pc),a0
		bsr.w	writeln

		lea.l	.antialias,a0	; Apply funky antialias filter on Y
		bsr.w	writeln		; image

	rept	ANTIALIAS_PASSES
		movem.l	(sp),a0/a1
		bsr.w	antialiasImage
	endr

		lea.l	ok(pc),a0
		bsr.w	writeln
		
		movea.l	(sp)+,a0	; Blit results
		movea.l	a0,a1
		bsr.w	c2p
		movea.l	(sp)+,a0
		movea.l	a0,a1
		bra.w	c2p

.width		ds.l	1		; Physical destination dimensions
.height		ds.l	1

		section	data
.antialias	dc.b	'Antialiasing: ',0
		even


********************************************
*  void antialiasImage(a0.l *SrcCr, a1.l *SrcY)
*
* Apply a simple anti aliasing filter on the source image to smoothen
* artifacts. Note: not at all optimized, but still fast on the TT ;).
********************************************

		section	text
antialiasImage	
	ifd	ANTIALIAS_CR
		lea.l	PHYSX+1(a0),a0	; &SrcCr[PHYSX+1]
	endc
	ifd	ANTIALIAS_Y
		lea.l	PHYSX+1(a1),a1	; &SrcY[PHYSX+1]
	endc

		
		move.w	#PHYSY-3,d0	; Dismiss topmost and bottommost scanline
.yloop		move.w	#PHYSX-3,d1
.xloop		
	ifd	ANTIALIAS_CR
		moveq.l	#0,d3		; Apply a 3*3 tap low pass FIR
		moveq.l	#0,d2
		move.b	(a0),d2
		unpk	d2,d2,#0	; Upack Cr field from --CR into -C-R format
		lsl.w	#3,d2
		move.b	+1(a0),d3
		unpk	d3,d3,#0
		add.w	d3,d2
		move.b	-1(a0),d3
		unpk	d3,d3,#0
		add.w	d3,d2
		move.b	+PHYSX(a0),d3
		unpk	d3,d3,#0
		add.w	d3,d2
		move.b	-PHYSX(a0),d3
		unpk	d3,d3,#0
		add.w	d3,d2
		move.b	+PHYSX+1(a0),d3
		unpk	d3,d3,#0
		add.w	d3,d2
		move.b	+PHYSX-1(a0),d3
		unpk	d3,d3,#0
		add.w	d3,d2
		move.b	-PHYSX+1(a0),d3
		unpk	d3,d3,#0
		add.w	d3,d2
		move.b	-PHYSX-1(a0),d3
		unpk	d3,d3,#0
		add.w	d3,d2

		lsr.w	#4,d2		; /= 16
		pack	d2,d2,#0
		move.b	d2,(a0)+
	endc
	ifd	ANTIALIAS_Y
		moveq.l	#0,d3
		moveq.l	#0,d2
		move.b	(a1),d2
		lsl.w	#3,d2
		move.b	+1(a1),d3
		add.w	d3,d2
		move.b	-1(a1),d3
		add.w	d3,d2
		move.b	+PHYSX(a1),d3
		add.w	d3,d2
		move.b	-PHYSX(a1),d3
		add.w	d3,d2
		move.b	+PHYSX+1(a1),d3
		add.w	d3,d2
		move.b	+PHYSX-1(a1),d3
		add.w	d3,d2
		move.b	-PHYSX+1(a1),d3
		add.w	d3,d2
		move.b	-PHYSX-1(a1),d3
		add.w	d3,d2

		lsr.w	#4,d2		; /= 16
		move.b	d2,(a1)+
	endc
		dbra	d1,.xloop
	
	ifd	ANTIALIAS_CR	
		addq.l	#2,a0		; Skip 2 columns
	endc
	ifd	ANTIALIAS_Y	
		addq.l	#2,a1
	endc

		dbra	d0,.yloop
		rts