	include	includes\start_up.s

	bsr.s	set_ints
	clr	-(sp)
	lea	__size,a0
	move.l	(a0),-(sp)
	move	#$31,-(sp)
	trap	#1
	
* process interrupt
*
*  called by centronics busy (crossed as strobe) being low
*
handle_int
	movem.l	d3-7/a3-5,-(sp)
	move	sr,-(sp)
	or	#$700,sr
	lea	buffer(pc),a5
	move	0(a5),d6	* last read
	move	2(a5),d7	* last written
	bsr	read_from_port	* read the byte
	move.b	d0,4(a5,d7)	* write byte into buffer
	addq	#1,d7	* increment last written pointer 
	move	d7,2(a5)
	bsr.s	set_strobe_high	* strobe emulates busy
	addq	#1,d7
	cmp	d6,d7	* check if the 2 pointers are the same
	beq.s	.leave_high
	bsr	set_strobe_low	* strobe emulates busy
.leave_high
	move	(sp)+,sr
	movem.l	(sp)+,d3-7/a3-5
	rte
*	rts

	data
strobe_flag	dc.w	0

	text

* set up interrupts
*  
set_ints
	clr.l	-(sp)	* get into supervisor mode
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)	* store user stack pointer
	move	#$20,-(sp)	* and get set to return to user mode

	sub.l	a0,a0	* clear a0

	lea	byteready(pc),a1	* set vector for bconstat
	move.l	a1,$51e(a0)

	lea	readbyte(pc),a1	* set vector for bconin
	move.l	a1,$53e(a0)

	pea	handle_int(pc)	* centronics busy handler
	clr	-(sp)	* MFP interrupt
	move	#13,-(sp)	* Jenabint
	trap	#14
	addq.l	#8,sp
	bsr.s	set_strobe_low
	lea	buffer(pc),a0	* reset buffer pointers
	clr.l	(a0)
	trap	#1
	addq.l	#6,sp
	rts

set_strobe_high
	lea	strobe_flag(pc),a0
	moveq	#1,d0
	move	d0,(a0)
	moveq.l	#$20,d2
	movem.l	d0-2,-(sp)
	move	sr,-(sp)
	or	#$700,sr
	move	#$0e,d1
	move.l	d2,-(sp)
	bsr.s	the_bits
	move.l	(sp)+,d2
	or.l	d2,d0
	moveq.l	#$8e,d1
	bsr.s	the_bits
	move	(sp)+,sr
	movem.l	(sp)+,d0-2
	rts
the_bits
	movem.l	d1-2/a0,-(sp)
	lea	$FFFF8800.w,a0
	move.l	d1,d2
	and.b	#$0f,d1
	move.b	d1,(a0)
	asl.b	#1,d2
	bcc.s	.read
	move.b	d0,2(a0)
.read
	clr.l	d0
	move.b	(a0),d0
	movem.l	(sp)+,d1-2/a0
	rts
set_strobe_low
	lea	strobe_flag(pc),a0
	clr	(a0)
	moveq.l	#$df,d2
	movem.l	d0-2,-(sp)
	move	sr,-(sp)
	or	#$700,sr
	move	#$0e,d1
	move.l	d2,-(sp)
	bsr.s	the_bits
	move.l	(sp)+,d2
	and.l	d2,d0
	moveq.l	#$8e,d1
	bsr.s	the_bits
	move	(sp)+,sr
	movem.l	(sp)+,d0-2
	rts

read_from_port
	moveq.l	#7,d1
	bsr.s	the_bits
	and.b	#$7f,d0
	moveq.l	#$87,d1
	bsr.s	the_bits
.loop
	bsr.s	.check_busy
	tst	d0
	bne.s	.loop
	moveq.l	#15,d1
	bsr.s	the_bits
.exit
	rts
.check_busy
	lea	$fffffa01.w,a0
	moveq.l	#-1,d0
	btst	#0,(a0)
	beq.s	.exit
	clr.l	d0
	bra.s	.exit
	
* handle read request
*
readbyte
	movem.l	d3-7/a3-5,-(sp)
	lea	buffer(pc),a0
	clr.l	d1
	move	0(a0),d1	* last read
	move	2(a0),d0	* last written
	cmp	d0,d1
	beq.s	.nothing	* nothing to read
	clr	d0
	addq	#1,d1		* update the tast read position
	move	d1,0(a0)
	move.b	4(a0,d1.l),d0	* read a byte from the buffer
	lea	strobe_flag(pc),a0
	tst	(a0)
	beq.s	.exit
	bsr.s	set_strobe_low
	bra.s	.exit
.nothing			* return -1 as error condition
	moveq.l	#-1,d0
.exit
	movem.l	(sp)+,d3-7/a3-5
	rts


* handle byte-ready request
*
byteready
	movem.l	d3-7/a3-5,-(sp)
	lea	buffer(pc),a0
	move	0(a0),d0	* last read
	move	2(a0),d1	* last written
	cmp	d0,d1
	sne	d0
	ext	d0
	ext.l	d0
	movem.l	(sp)+,d3-7/a3-5
	rts

* the data buffer 64kB for ease of use :)
*
	bss
buffer
	ds.w	1		* last read
	ds.w	1		* last written
	ds.l	16384		* 64kbyte buffer
