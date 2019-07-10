*
* Missing function from gemfast 1.3 library
* 
	.globl _vr_trnfm
	.even
	.text
_vr_trnfm:
	link	a6,#0
	move.l	14(a6),-(sp)	* destination -> cntrl[9-10]
	move.l	10(a6),-(sp)	* source -> cntrl[7-8]
	move.w	 8(a6),-(sp)	* handle -> cntrl[6]
	clr.l	-(sp)		* cntrl[4-5] |
	clr.l	-(sp)		* cntrl[3-2] | only cntrl 3 matters
	clr.w	-(sp)		* cntrl[1] <- 0
	move.w	#110,-(sp)	* cntrl[0] - function number
*  construct on stack a parameter block
*	subq.l	#8,sp		* no ptsout, intout, ptsin, intin
*	subq.l	#8,sp
*	pea	16(sp)		* an address of cntrl
	pea	0(sp)		* an address of cntrl
	moveq	#115,d0		* vdi call
	move.l	sp,d1		* here goes parameter block
	trap	#2		* do it
	unlk	a6
	rts
