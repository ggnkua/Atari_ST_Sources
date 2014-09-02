
*	DMA test using Drake's test jig
*	Sept 21, 88: don't select floppy
*	Feb 2, 86  edit for madmac
*	Oct 24, 86 test until at topram or $f0000, check 3 bits of status
*	Do DMA throughout memory

scrsel	equ	$118		;write to sector count reg.
hdrcmd	equ	8		;talk to hard disk controller, dma dir=read
hdwcmd	equ	$108		;talk to hard disk controller, dma dir=write
wcmd	equ	$10
rcmd	equ	$8

	.text

dmatst:	movea.l	#dmamsg,a5
	bsr	dsptst
	rts	; RWS : 09APR92 : NO ACSI ON SPARROW.
.if 0
	move.w	#$80,dmactl	;select floppy controller
	nop
	move.w	dskctl,d0	;read status to clear possible irq

	move.b	#$e,psgsel	;port A
	move.b	#$27,psgwr	;set dstrobe to put latch in hi imped.

*	Fill buffer
	move.l	dmatbl,a3
	move.l	a3,a4
	adda.l	#$200,a4
	move.l	a3,ddbuf.w
dmafill:
	move.w	a3,d0
	move.w	d0,(a3)+
	cmpa.l	a3,a4
	bne.s	dmafill

*	Write 1 sector and read back
	move.w	#1,dsect	;# of sectors
	move.b	#wcmd,dcmd	;command
	bsr	dmaxfer
	tst.b	erflg0
	bne	dmafal
	
*	Read 1 sector
	addi.l	#$800,ddbuf	;add 2k to get read buffer
	move.b	#rcmd,dcmd
	bsr	dmaxfer
	tst.b	erflg0
	bne	dmafal
	bsr	cmpbuf
	btst	#7,erflg0
	bne	dmafal

	clr.b	dmamem		;init index to dma memory table

*	Perform DMA's through range of memory. $1000-80000	
dmalp:	clr.l	d0
	move.b	dmamem,d0	;get index
	lea	dmatbl,a2
	move.l	0(a2,d0),a3	;get dma write buffer 
	cmp.l	topram.w,a3
	bge.s	dmapas
	move.l	a3,ddbuf.w	;move to cmd block
	move.l	a3,a4
	adda.l	#$800,a4	;end of dma block (4 sectors)	

*	Fill dma buffer. Data=address low word
dmabuf:	move.w	a3,d0
	move.w	d0,(a3)+
	cmpa.l	a3,a4
	bne.s	dmabuf

*	Write 4 sectors
	move.w	#4,dsect	;# of sectors
	move.b	#wcmd,dcmd	;command
	bsr	dmaxfer
	tst.b	erflg0
	bne.s	dmafal
	
*	Read 4 sectors
	add.l	#$800,ddbuf.l	;read buffer=write buffer+2k
	move.b	#rcmd,dcmd
	bsr	dmaxfer
	tst.b	erflg0
	bne.s	dmafal
	bsr	cmpbuf
	btst	#7,erflg0
	bne.s	dmafal

	addi.b	#4,dmamem
	cmpi.b	#dmatbe,dmamem
	bne	dmalp

*	-------------
*	End of test

*	Passed test
dmapas:	movea.l	#pasmsg,a5

dmaend:	bsr	dsppf
	rts

*	Failed test
dmafal:	move.w	#red,palette

	movea.l	#falmsg,a5
	bra.s	dmaend


*********************************	
*	Perform DMA transfer
*	parameters passed in the dma control block:
*          # of sectors, address of buffer, direction (read, write)
*	Exit: 	erflg0=0 if no errors
*		bit 0=time-out, bit 1=count error
dmaxfer:
	clr.b	erflg0
	move.b	ddbuf+3,dmalow		;buffer address to memory control
	move.b	ddbuf+2,dmamid
	move.b	ddbuf+1,dmahigh	

	move.w	dsect,d0		;get sector count
	subq	#1,d0			;-1
	lsl.b	#6,d0			;shift to bits 6 & 7
	or.b	dcmd,d0			;or-in command bits

*	Send read/write command
*	Note: do not toggle bit 8 of dmactl or chip will get reset!!!
	lea	dmactl,a0
	lea	dskctl,a1

	cmpi.b	#rcmd,dcmd		;read or write?
	bne.s	dmawr

*	Read
	move.w	#$190,(a0)
	move.w	#$090,(a0)		;toggle w/r bit to reset, set SCR bit
	nop
	move.w	dsect,(a1)		;sector count to dma chip
	nop
	move.w	#$88,(a0)		;select controller
	nop
	move.w	(a1),d1			;read=reset hdint
	move.w	d0,(a1)			;send command
	nop
	move.w	#$008,(a0)		;configure for dma read
	bra.s	dmawt

*	Write
dmawr:	move.w	#$090,(a0)
	move.w	#$190,(a0)		;toggle w/r bit to reset, set SCR bit
	nop
	move.w	dsect,(a1)		;sector count to dma chip
	nop
	move.w	#$188,(a0)		;select controller
	nop
	move.w	(a1),d1			;read=reset hdint
	move.w	d0,(a1)			;send command
	nop
	move.w	#$108,(a0)		;configure for dma write

*	Wait for completion
dmawt:	move.w	#500,d2
xferpol:
	subq	#1,d2
	beq	dtime
	btst	#5,gpip+mfp
	bne.s	xferpol			;wait for completion

*	Check transfer count
	clr.l	d0
	move.w	dsect,d0		;get # of sectors
	mulu	#512,d0			;compute total count
	add.l	ddbuf.w,d0		;add start address
	clr.l	tmpdma
	move.b	dmalow,tmpdma+3
	move.b	dmamid,tmpdma+2
	move.b	dmahigh,tmpdma+1
	cmp.l	tmpdma.l,d0
	beq.s	dmastat
	bset	#1,erflg0		;count did not match expected value
	movea.l	#dcnter,a5
	bsr	dspmsg

*	Test DMA controller status
dmastat:
	move.w	(a0),d0		;get status
	andi	#7,d0
	cmpi	#1,d0
	beq.s	xferts
	bset	#2,erflg0
	lea	dnoresp,a5
	bsr	dspmsg

*	Reset peripheral and return
xferts:	move.w	#$88,(a0)		;select controller
	nop
	move.w	(a1),d1			;read=reset hdint
	rts

*	Transfer timed-out
dtime: 	bset	#0,erflg0
	movea.l	#dtimout,a5
	bsr	dspmsg
	bra.s	xferts


*************************************************
*	Compare read buffer to write buffer	*	
*
cmpbuf:	move.l	ddbuf.w,a0	;read buffer
	move.l	a0,a1
	suba.l	#$800,a1	;write buffer
	moveq	#0,d0
	move.w	dsect,d0
	mulu	#512,d0		;compute end of buffer
	movea.l	a0,a2	
	adda.l	d0,a2
cmbf1:	cmp.b	(a0)+,(a1)+	;compare data 
	bne.s	cmbf2
	cmpa.l	a0,a2
	bne.s	cmbf1
	rts

cmbf2:	bset	#7,erflg0
	movea.l	#ddataer,a5
	bsr	dspmsg
	rts
.endif
	.data
	.even
.if 0
dmatbl:	dc.l	$1000,$1800,$2000,$4000,$8000,$18000,$20000,$40000
	dc.l	$50000,$60000,$70000,$80000,$90000,$a0000,$b0000,$c0000
	dc.l	$d0000,$e0000,$f0000
dmatbe	equ	*-dmatbl
			
dtimout: dc.b	'D0 DMA time-out',cr,lf,eot
dcnter:	dc.b	'D1 DMA count error',cr,lf,eot
ddataer: dc.b	'D2 DMA data mismatch',cr,lf,eot
dnoresp: dc.b	'D3 DMA not responding',cr,lf,eot
.endif
dmamsg:	dc.b	'DMA Port Test NOT INSTALLED',cr,lf,eot

