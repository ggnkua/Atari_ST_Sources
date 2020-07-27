******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:44 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	bmove.s,v $
* Revision 1.1  88/08/23  14:20:44  apratt
* Initial revision
* 
*
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/bmove.s,v $
* =======================================================================
*
*************************************************************************
	.title	"bmove.s - block move/copy for C"
;
; USAGE:
;
; bmove(src,dest,nbytes)
; long src,dest,nbytes;
;

_bmove::
	move.l	$4(sp),a0
	move.l	$8(sp),a1
	move.l	$c(sp),d0

	; if bit 0 of src <> bit 0 of dest, we're hosed.

	btst.b	#0,$7(sp)
	sne	d1
	btst.b	#0,$b(sp)		
	sne	d2
	eor.b	d1,d2
	bne	.badnews

	; they're the same: if there's a leading byte, do it now.

	tst.b	d1
	beq.s	.noleader

	move.b	(a0)+,(a1)+
	subq.l	#1,d0

.noleader:
	; if less than four bytes to go, don't do longs
	cmp.l	#4,d0
	bcs.s	.nolong
	move.l	(a0)+,(a1)+
	subq.l	#4,d0
	bra.s	.noleader

.badnews:
.loop:
	move.b	(a0)+,(a1)+
.nolong:
	dbra	d0,.loop

	rts

	
