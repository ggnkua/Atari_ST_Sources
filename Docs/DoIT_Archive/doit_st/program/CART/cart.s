/	module name  CART.S %W% of %G%
/
/		contains:
/			writecart 16 : write word to cartridge port.
/			writecart 8  : write byte to cartridge port.
/			readcart  16 : read word from cartridge port.
/			fillmem	     : fill shared memory with a pattern.
/
	.prvd


/---------------------------------------------------------------------
/		WRITECART16: WRITE 16 BIT DATA TO ADDRESS ON CART PORT
/---------------------------------------------------------------------
	.shri

	.globl writecart16_
writecart16_:
	link	a6, $0
	clr.l	d0
	move	10(a6), d0		/ fetch data to write
	addi.l	$0xFB0000, d0		/ add it to base addr of ROM 3
	movea.l d0, a0			/ generate addr1 (say)
	move.b	(a0), d0		/ read addr1 to latch data.
	clr.l	d0
	move	8(a6), d0		/ now take address to write data to
	addi.l	$0xFA0000, d0		/ add this to base addr of ROM 4
	movea.l d0, a0			/ call this addr2 (say).
	move	(a0), d0		/ read addr2 to write out data
	unlk	a6
	rts				/ as side-effect, same data will be
					/ returned!


/---------------------------------------------------------------------
/		READCART16: READ 16 BIT DATA FROM ADDRESS ON CART PORT
/---------------------------------------------------------------------
	.shri

	.globl readcart16_
readcart16_:
	link	a6, $0
	clr.l	d0
	move	8(a6), d0		/ fetch address to read from
	addi.l	$0xFA0000, d0		/ add it to base addr of ROM 4
	movea.l d0, a0			/ generate addr1 (say)
	move	(a0), d0		/ read addr1 to latch data.
	unlk	a6
	rts				/ as side-effect, same data will be
					/ returned!


/---------------------------------------------------------------------
/		WRITECART8: WRITE 8 BIT DATA TO ADDRESS ON CART PORT
/---------------------------------------------------------------------
	.shri
/
/	writecart8(addr, data)
/	int addr, data
/

	.globl writecart8_
writecart8_:
	link	a6, $0
	clr.l	d0
	move	8(a6), d0		/ fetch address
	and	$0xFFFE, d0		/ and with 0xFFFE to evenify
	move.l	d0, d1
	cmp.w	8(a6), d0
	beq	evn


odd:	/ this is write byte to odd address
	move.w	d0, 8(a6)
	addi.l	$0xFA0000, d1		/ generate real even address
	movea.l	d1, a0
	move.w	(a0), d0		/ fetch word
	andi.w	$0xFF00, d0		/ null odd byte of this word
	move.w	10(a6), d1
	andi.w	$0x00FF, d1		/ null even byte of data
	or.w	d1, d0			/ merge together
	move	d0, -(a7)
	move	8(a6), -(a7)		/ and write to even address
	jsr	writecart16_
	addq.l	$4, a7
	unlk	a6
	rts

evn:	/ even address continue here
	move.w	d0, 8(a6)
	addi.l	$0xFA0000, d1		/ generate real even address
	movea.l	d1, a0
	move.w	(a0), d0
	andi.w	$0x00FF, d0
	move.w	10(a6), d1
	asl.w	$8, d1
	andi.w	$0xFF00, d1
	or	d1, d0
	move	d0, -(a7)
	move	8(a6), -(a7)
	jsr	writecart16_
	addq.l	$4, a7
	unlk	a6
	rts



/----------------------------------------------------------------------
/		FILLMEM : FILL SHARED RAM WITH A PATTERN
/----------------------------------------------------------------------
	.shri

	.globl fillmem_

fillmem_:
	link	a6, $0
	move	8(a6), d1	/ this is the fill pattern (a 16 bit word)

	clr.l	d0		/ start filling from addr 0 offset from
				/ 0xFA0000
	
floop:	move	d1, -(a7)	/ push data (fill pattern) on stack
	move	d0, -(a7)	/ push address on stack
	jsr	writecart16_	/ write fill pattern
	move	(a7)+, d0
	move	(a7)+, d1	/ pop stack

	addq.l	$2, d0		/ increment address
	cmp	$0x1000, d0	/ is it the end of the 2K word memory
	bge	fdone
	bra	floop

fdone:
	unlk	a6
	rts

/-----------------------------------------------------------------------
/		RUN320:	TAKE TMS32010 OUT OF RESET MODE
/-----------------------------------------------------------------------

	.shri

	.globl run320q_

run320q_:
	link	a6, $0
	movea.l	$0xFA1000, a0	/ address of the control register
	move.w	(a0), d0	/ fetch contents of control register
	andi.w  $0x00FF, d0	/ mask off contents of 320 port 1
	ori.w	$0x0001, d0	/ force only reset to 1

	move.w	d0, -(a7)	/ push data to write in stack
	move.w  $0x1000, -(a7)	/ push address offset to write to in stack
	jsr	writecart16_
	addq.l	$4, a7		/ remove arguments from stack

	movea.l $0xFA0000, a0	/ read the control register again
	move.w	(a0),	d0	/ keep value in a0 (ie return it)

	unlk	a6
	rts

/-----------------------------------------------------------------------
/		STOP320: PUT TMS32010 IN RESET MODE
/-----------------------------------------------------------------------

	.shri

	.globl stop320_

stop320_:
	link	a6, $0
	movea.l	$0xFA1000, a0	/ address of the control register
	move.w	(a0), d0	/ fetch contents of control register
	andi.w  $0xFFFE, d0	/ force reset bit to 0.

	move.w	d0, -(a7)	/ push data to write in stack
	move.w  $0x1000, -(a7)	/ push address offset to write to in stack
	jsr	writecart16_
	addq.l	$4, a7		/ remove arguments from stack

	movea.l $0xFA0000, a0	/ read the control register again
	move.w	(a0),	d0	/ keep value in a0 (ie return it)

	unlk	a6
	rts



