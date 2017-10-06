*** Device Driver *********************************************************

	SECTION TEXT


** Open *******************************************************************

open	lea	variables(pc),a1

* Are we already in use?

	tst.w	moose_inuse(a1)
	bne	.eaccdn

* Set up our moose vector's variables

	clr.w	tail(a1)
	clr.w	head(a1)
	clr.w	inbuf(a1)

	clr.l	rsel(a1)		HR rsel is long
	clr.w	rptr(a1)
	clr.w	wptr(a1)
	clr.w	mused(a1)

	OPT	NOCHKIMM
	move.l	SYSVBI,a0
	move.w	SYSNVBI,d0
	OPT	CHKIMM
	addq.w	#4,a0			Skip VDI's VBI
	subq.w	#2,d0			-1 for dbra, -1 for above
	blt	.eaccdn
.loop	tst.l	(a0)+
	beq	.set_vbi
	dbra	d0,.loop
	bra	.eaccdn

.set_vbi
	move.l	#timer_handler,-(a0)
	move.l	a0,VBI_entry(a1)

	move.w	#-1,moose_inuse(a1)

	clr.w	dc_time(a1)

	moveq	#0,d0	
	rts


* Don't like this at all - we should allocate a new VBI list
* instead of returning an error. !!TODO!!

.eaccdn	moveq	#-36,d0
	rts


** Close ******************************************************************

close	tst.l	4(a7)			Is it a valid handle?
	beq	.eihndl

	lea	variables(pc),a1

	move.l	VBI_entry(a1),a0
	clr.l	(a0)

	clr.w	moose_inuse(a1)

	clr.w	dc_time(a1)

	moveq	#0,d0
	rts

.eihndl	moveq	#-1,d0
	rts


** Select *****************************************************************

select	move.w	12(a7),d0		Mode

	tst.w	d0
	beq	.ordonly

	cmpi.w	#1,d0
	beq	.owronly

.return0
	moveq	#0,d0
	rts

.return1
.owronly
	moveq	#1,d0			Always ready for writes :)
	rts

.ordonly
	lea	variables(pc),a0


* Is there data waiting to be read?

	tst.w	mused(a0)
	bne	.return1


* Are we already selected?

	tst.l	rsel(a0)
	bne	.collision


* Select the caller

	move.l	8(a7),rsel(a0)
	bra.s	.return0

.collision	moveq	#2,d0
	rts


** Unselect ***************************************************************

unselect
	lea	variables(pc),a0
	clr.l	rsel(a0)

.return	rts


** Read *******************************************************************

read	movem.l	d2-d5/a2-3,-(a7)

	lea	variables(pc),a3

	move.l	32(a7),a1			a1 = v:buf
	move.l	36(a7),d1			d1 = bytes to read

	moveq	#0,d2				d2 = bytes actually read

	lea	moose_buffer(pc),a2

	move.w	#MD_BUFFER_SIZE,d3

	moveq	#0,d4
	move.w	rptr(a3),d4

	move.w	mused(a3),d5

.loop	tst.w	d5
	beq	.return

	tst.l	d1
	beq	.return

	move.w	(a2,d4.w),(a1)+

	addq.w	#2,d4				Increment read pointer
	cmp.w	d4,d3				Wrapping if necessery
	bne.s	.done_wrap
	clr.w	d4
.done_wrap
	subq.l	#2,d1				Decrement bytes to read
	addq.l	#2,d2				Increment bytes read
	subq.w	#2,d5				Decrement bytes in buffer

	bra	.loop

.return	move.w	d4,rptr(a3)
	sub.w	d2,mused(a3)

	move.l	d2,d0				Return(d2) (bytes read)
	movem.l	(a7)+,d2-d5/a2-3
	rts


** Write ******************************************************************

* The Moose device can accept commands via write function. Each command
* must becontained within a single write and only one command may be
* written at once

write	movem.l	d2-d7/a2-6,-(a7)

	lea	variables(pc),a6

	move.l	52(a7),a0			a0 = v:buf
	move.l	56(a7),d0			d0 = bytes being written

	bsr	handle_commands

	movem.l	(a7)+,d2-7/a2-6
	rts


** Seek *******************************************************************

lseek	moveq	#0,d0				Always at start of file
	rts


** Ioctl ******************************************************************

ioctl	move.w	8(a7),d0			Mode

	cmpi.w	#$4601,d0			FIONREAD
	beq	.fionread

	cmpi.w	#$4602,d0			FIONWRITE
	beq	.fionwrite

	cmpi.w	#$4605,d0			FIOEXCEPT
	beq	.fioexcept

	moveq	#-1,d0				Nothing else is allowed
	rts	

.fionread
	lea	variables(pc),a1

* Calculate the number of bytes ready to read from the moose buffer

	moveq	#0,d0
	move.w	inbuf(a1),d0

.write	move.l	10(a7),a0
	move.l	d0,(a0)	

	moveq	#0,d0
	rts

.fionwrite
.fioexcept
	moveq	#0,d0
	bra.s	.write


** Datime *****************************************************************

datime	moveq	#-36,d0			Not much point, really :)
	rts


*** Internal Write Routine ***************************************** A6 ***

* Write data to the md buffer. All packets MUST be <=16 bytes in length.

* This whole weird system of writing data is designed to be extensible.

*  in: a0 = v:data - the first word of which is a dbra counter for the
*           number of words to write

int_write
	tst.w	moose_inuse(a6)			If not in use: do nothing
	beq	.return
	movem.l	d0/d7/a0-a1,-(a7)


* Get the point in the buffer where we place the data

	moveq	#0,d7
	move.w	tail(a6),d7

	lea	md_buffer(pc),a1
	add.l	d7,a1

	move.w	(a0)+,d0
.loop

* Copy data into the buffer

	move.w	(a0)+,(a1)+
	dbra	d0,.loop


* Point the tail to the next slot along

	add.w	#16,d7

	cmpi.w	#MD_BUFFER_SIZE,d7
	bne	.done_wrap
	moveq	#0,d7
.done_wrap
	move.w	d7,tail(a6)

	add.w	#16,inbuf(a6)

	movem.l	(a7)+,d0/d7/a0-a1
.return	rts


*** Generic Write Routine ****************************************** A6 ***

* Write data to the listening process. All packets MUST be of even length.

* This whole weird system of writing data is designed to be extensible.

*  in: a0 = v:data - the first word of which is a dbra counter for the
*           number of words to write

gen_write
	tst.w	moose_inuse(a6)			If not in use: do nothing
	beq	.return
	movem.l	d0/d7/a0-a1,-(a7)

* Get the point in the buffer where we place the data

	moveq	#0,d7
	move.w	wptr(a6),d7

	lea	moose_buffer(pc),a1
	add.l	d7,a1

	move.w	(a0)+,d0
.loop

* Copy over a word of moose data into the buffer

	move.w	(a0)+,(a1)+


* Point the moose_tail to the next slot along

	addq.w	#2,mused(a6)

	addq.w	#2,d7

	cmpi.w	#MD_BUFFER_SIZE,d7
	bne	.done_wrap
	moveq	#0,d7
.done_wrap
	move.w	d7,wptr(a6)

	dbra	d0,.loop


* Wake up a listener, if applicable

	tst.l	rsel(a6)
	beq	.retm			HR jump to the movem

	move.l	kerinfo(a6),a0
	move.l	96(a0),a0			a0 = v:wakeselect

	movem.l	d1-d2/a2,-(a7)
	move.l	rsel(a6),-(a7)
	jsr	(a0)
	addq.w	#4,a7
	movem.l	(a7)+,d1-d2/a2

	clr.l	rsel(a6)
.retm
	movem.l	d0/d7/a0-a1,-(a7)
.return	rts


*** DATA Section **********************************************************

	SECTION DATA
	even

* The device structure:


dinfo	dc.l	devdrv
	dc.w	0,0
	dc.l	0
	dc.l	0,0,0,0

devdrv	dc.l	open
	dc.l	write
	dc.l	read
	dc.l	lseek
	dc.l	ioctl
	dc.l	datime
	dc.l	close
	dc.l	select
	dc.l	unselect
	dc.l	0,0,0


***************************************************************************
