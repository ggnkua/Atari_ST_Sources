*  prn.s - physical printer						*

*
*  external declarations
*
	.xdef	_prnavail
*	.xdef	_prnchr

*
*  global declarations
*
*	.xref	_prnout
	.xref	_prninit


****************************************************************************
* prninit -
*	initialize printer parallel port
*
_prninit:
	movem.l	d0-d1/a0-a2,-(sp)

*  steal bus error interrupt vector

	move.l	8,savbus
	move.l	#buserr,8	

* test for presence of printer

	move.l	#$fc6000,a0
	clr	d1		* clear bus error indicator
	move.w	d1,_prnavail	* clear printer available flag
	move.b	#$8c,$11(a0)	* if no printer port, cause a bus error
	tst	d1		* bus error ?
	bne	prnxit		*    no printer

*  it's there, init it

	move.w	#$ff,_prnavail	* else flag printer present
	move.b	#$80,1(a0)	* reg b, dir = out
	move.b	#$0b,$61(a0)	* acr (int on ca1-ack up edge, pulse mode)
	move.b	#$ff,$19(a0)	* ddra all out

prnxit:	
	move.l	savbus,8	*  restore bus error vector

	movem.l	(sp)+,d0-d1/a0-a2
	rts

****************************************************************************
*  buserr -
*	bus error interrupt routine for printer initialization
*	trashes d1 for running routine to analyze
*

buserr:
	add.l	#8,sp		* get the junk out of the stack
	add.l	#2,2(sp)	* fix up return address
	move.b	#$ff,d1		* bus error indicator
	rte

****************************************************************************
**  xprnout -
**	polled (blech) printer output
**
*_xprnout:
*	movea.l	#$fc6000,a0
*	move.b	_prnchr,d0
*	move.b	d0,9(a0)
*
** now wait for ack strobe 
*
*lpwt:	btst.b	#1,$69(a0)
*	beq	lpwt
*
*	rts
*
****************************************************************************

	.data
savbus:	.dc.l
	.end
