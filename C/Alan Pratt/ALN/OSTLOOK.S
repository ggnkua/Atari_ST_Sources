******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:45 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	ostlook.s,v $
* Revision 1.1  88/08/23  14:20:45  apratt
* Initial revision
* 
*
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/ostlook.s,v $
* =======================================================================
*
*************************************************************************
; ostlook: implement ost_lookup in assembly code for aln

.globl	_ost_index, _ost

T_GLOBAL_BIT	equ	5	; bit 5 of HIGH BYTE of attribute word

_ost_lookup::
	move.l	4(sp),a0	; a0->symbol to find
	move.w	_ost_index,d1	; d1 = next index (last+1)
	move.l	_ost,a1		; a1->current ost
	clr.w	d0		; d0=current index

	movem.l	d3/d4,-(sp)	; save regs used locally
	move.l	(a0),d2
	move.l	4(a0),d3
	move.w	#14,a2		; constant for add in nomatch
	moveq.l	#5,d4		; constant for btst in loop
	bra.s	.loop		; jump into the middle

.nomatch:
	add.l	a2,a1		; [8] temp += 14
	addq.w	#1,d0		; [4] index++
.loop:
	cmp.w	d0,d1		; [4]
	bcs.s	.miss		; [8/10] no (more) symbols -- miss.
	moveq.l	#$28,d4		; [4]
	and.b	8(a1),d4	; [12] d4 = (type & (T_GLOBAL | T_EXTERN))
	beq.s	.nomatch	; [8/10]  = 0: this is a local.
	cmp.l	(a1),d2		; [14]
	bne.s	.nomatch	; [8/10]
	cmp.l	4(a1),d3	; [18]
	bne.s	.nomatch	; [10: end case is not interesting]
	; we got a match!
	movem.l	(sp)+,d3/d4	; restore regs
	rts			; index is already in d0

.miss:	move.w	#-1,d0
	movem.l	(sp)+,d3/d4	; restore regs
	rts			; no match
