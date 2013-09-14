/ declare exception routine...
/ This routine is called as the first action in a routine that is to
/ be called from a 68000 exception -- It saves all of the unsafe registers
/ and causes the routine to exit through code that restores the registers
/ and exits with an RTE.
/
/ Called with no parameters.
/
/ Returns the old frame pointer (a6) in d0 so that the calling routine can
/ access the supervisor stack.  The offsets into the stack for most
/ exceptions are:
/	   Low Address 	+-------------------------------+
/		    0.L	| Old A0 contents (high)	|
/		       	+-------------------------------+
/			| Old A0 contents (low)		|
/			+-------------------------------+
/		    4.W	| Old status register		|
/			+-------------------------------+
/		    6.L	| Exception PC (high)		|
/			+-------------------------------+
/		    	| Exception PC (low)		|
/			+-------------------------------+
/
/ For a Bus or Address Error, the exception frame is as follows:
/
/	   Low Address 	+-------------------------------+
/		    0.L	| Old A0 contents (high)	|
/		       	+-------------------------------+
/			| Old A0 contents (low)		|
/			+-------------------------------+
/		    4.W	| Exception description *	|
/		    6.L	+-------------------------------+
/			| Access Address (high)		|
/			+-------------------------------+
/		   10.L	| Access address (low)		|
/			+-------------------------------+
/			| Instruction register		|
/			+-------------------------------+
/		   14.W	| Old status register		|
/			+-------------------------------+
/		   16.L	| Exception PC (high)		|
/			+-------------------------------+
/		    	| Exception PC (low)		|
/			+-------------------------------+
/ * Bit 4: R/W, Bit 3: Instruction/Other, Bits 0-2: Function code
/
/ Recovery from an address error or bus error should not attempt to
/ resume processing directly without some patchup...  On these errors,
/ the value of the exception PC is within 10 words of the offending
/ instruction, but it is not always possible to tell just where.
/
	.prvi
	.globl	setrte_
	.globl	retrte

setrte_:
	move.l	a1,-(sp)	/ save the munged registers on the stack
	move.l	a0,-(sp)	/ ...
	movea.l	a7,a1		/ save the current sp
	suba.l	$28,a7		/ extend the stack for 6 saved registers+ra
	movea.l	a7,a0		/ and get this as well...
1:
	move	(a1)+,(a0)+	/ we are now shifting the stack down 24 words
	cmpa.l	a1,a6		/ have we copied the entire frame?
	bgt	1b		/ if not, continue looping.

	move.l	(a6),(a0)	/ copy the final (link) word...
	movea.l	a6,a0		/ save the value of the link
	move.l	(sp)+,(a6)	/ copy up saved A0
	move.l	(sp)+,-(a6)	/ now the saved A1
	move.l	a2,-(a6)	/ now save A2
	move.l	d0,-(a6)	/ save D0
	move.l	d1,-(a6)	/ save D1
	move.l	d2,-(a6)	/ save D2
	move.l	$retrte,-(a6)	/ put the RTE return address in
	subq	$4,a6		/ adjust the link...
	move.l	a6,d0		/ put the old link address into d0
	rts			/ return to caller...
retrte:
	move.l	(sp)+,d2	/ Restore garbaged registers
	move.l	(sp)+,d1	/
	move.l	(sp)+,d0	/
	movea.l	(sp)+,a2	/
	movea.l	(sp)+,a1	/
	movea.l	(sp)+,a0	/ Done restoring registers
	rte			/ and the whole point of this mess...
