/
/ Reset the Aux rs232 port.  Usage:
/	char	*rs232_iorec = Iorec(0);	/* Do this first	*/
/
/	if (rs232_reset())
/	    Cauxout(0x11);			/* sent an XOFF		*/
/
/ This subroutine was written by Martin Minow, Arlington, MA
/ and is in the public domain.
/
/	.shrd				/ Public data
/	.globl	rs232_iorec_		/ -> aux io record. see below
	.shri				/ Public instructions
	.globl	rs232_reset_

rs232_reset_:
	move.l	d2,-(sp)		/ Save a scratch register
	clr.l	-(sp)			/ Super(0L) switches to super mode
	move.w	$0x20,-(sp)		/ Super opcode
	trap	$1			/ Call TOS
	addq.l	$6,sp			/ Clear stack
	move.l	d0,-(sp)		/ Save old stack for now.
/
/ If you don't already have the iorec as a readily-available global,
/ uncomment the following code (which is, of course, untested)
/
	clr.w	-(sp)			/ Aux port is device zero
	move.w	$14,-(sp)		/ Iorec
	trap	$14			/ Xbios(14)
	addq.l	$4,sp			/ Clear stack
/ End of "get iorec" code. We already have this information:
/	movea	rs232_iorec_,a0		/ a0 -> I/O record
	movea	d0,a0			/ a0 -> I/O record
	move	sr,-(sp)		/ Save cpu status
	ori	$0x700,sr		/ Disable interrupts
/	clr.l	6(a0)			/ Clear input  head, tail -- crashes!
	clr.l	20(a0)			/ Clear output head, tail
	clr.l	d2			/ Clear result
	or.b	30(a0),d2		/ Get old rcv xoff state
	clr.w	30(a0)			/ Cancel rcv, xmt xoff states
	move	(sp)+,sr		/ Enable interrupts
	move.w	$0x20,-(sp)		/ Super -- old_stack is still at (sp)
	trap	$1			/ Exit super mode
	addq	$6,sp			/ Clean junk from stack
	move.l	d2,d0			/ Get result
	move.l	(sp)+,d2		/ Restore d2	
	rts				/ Exit routine
