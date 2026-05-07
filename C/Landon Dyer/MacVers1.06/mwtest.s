*+
*
*  Test for for Mark Williams C compatibility
*
*-
	.globl	bogus0,bogus1,bogus2
	.globl	extern0,extern1,extern2
	.globl	globl0,globl1,globl2


	nop
	nop
	nop


	dc.l	extern0
	dc.l	globl0
	bsr	extern0
	bsr	globl0
globl0:	nop
	lea	extern0(pc),a0
	lea	globl0(pc),a0
	dc.l	extern1
	dc.l	globl1

	bsr	extern1
	bsr	globl1
globl1:	nop
	lea	extern1(pc),a1
	lea	globl1(pc),a1

	dc.l	extern2
	dc.l	globl2
	bsr	extern2
	bsr	globl2
globl2:	nop
	lea	extern2(pc),a2
	lea	globl2(pc),a2
