*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/large.s,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:28:54 $	$Locker: kbad $
* =======================================================================
*  $Log:	large.s,v $
* Revision 2.2  89/04/26  18:28:54  mui
* TT
* 
* Revision 2.1  89/02/22  05:30:57  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:35:49  lozben
* Initial revision
* 
***************************************************************************
***									***
***									***
***				LARGE.S					***
***									***
***									***
***************************************************************************
*
*	10/26/84	Dan Oliver
*	1/31/85	- 03/21/85	Lowell Webster
*	05/10/85		Jim Eisenstein
*	Take out LBFILL, LWFILL, LBDSKIP	 03/09/1988	D.Mui		
*	Subroutines used by CRYSTAL.
*	Take out LSTRLEN	3/15/88		D.Mui
*	Use MAC to assemble	6/28/90		D.Mui
* assemble with MAS 900801 kbad

	.text
*
	.globl	_LBCOPY
	.globl  _LWCOPY
	.globl	_LSTCPY
	.globl	_LBWMOV
	.globl _expand_data
	.globl	_reverse

saddr	equ $08	; -> a4
daddr	equ $0c	; -> a5
mask	equ $10
splanes	equ $14	; -> d4.w
dplanes	equ $16	; -> d5.w
w	equ $18
h	equ $1a

_reverse:
 	move.l	d3,-(sp)		; Save d3 since we clobber it
	move.w	8(sp),d3		; d3 = source
	clr.w	d1			; target bit position
	clr.w	d0			; target
	move.w	#15,d2			; source bit position
dobit:
	btst	d2,d3
	beq	nextbit
	bset	d1,d0
nextbit:
	addq	#1,d1			; Update target bit position
	dbra	d2,dobit		; Dbra updates source bit position
	move.l	(sp)+,d3		; Restore d3
	rts

* void expand_data(saddr, daddr, mask, splanes, dplanes, w, h)
* BYTE *saddr, *daddr, *mask;
* WORD splanes, dplanes, w, h;
*
* Expand a color icon at 'saddr' with 'splanes' of data
* to 'daddr' with 'dplanes' of data.
*
* In pixel-packed modes, the mask must be set to 0
* and the data must be ORed in to preserve the colors.
* Also, data outside the mask must be set to 0.
*
* stack offsets after link:
_expand_data:
	link	a6,#0
	movem.l	d4-d7/a4-a5,-(sp)

	movem.w	splanes(a6),d4-d7
	asr.w	#3,d6		; plane_size = w/8 * h
	muls.w	d6,d7
	move.w	d7,d6
	asr.w	#1,d7		; (plane size in words...)
	subq.w	#1,d7		; (...as dbra count)

	move.l	saddr(a6),a4
	move.l	daddr(a6),a5
	move.l	a4,a0		; copy source into first splanes of dest
	move.l	a5,a1
	move.w	d4,d0		; splanes
	subq	#1,d0		; dbra count
cpplp:	move.w	d7,d1		; dbra # of words per plane
cplp:	move.w	(a0)+,(a1)+
	dbra	d1,cplp
	dbra	d0,cpplp

	move.l	a1,a2		; save pointer to 1st extra dest plane
	moveq	#-1,d2		; fill 1st extra dest plane with $ffff
	move.w	d7,d1		; dbra # of words per plane
fflp:	move.w	d2,(a1)+
	dbra	d1,fflp

	move.l	a4,a0		; AND all source planes to 1st extra dest plane
	move.w	d4,d0		; splanes
	subq	#1,d0		; (dbra count)
aplp:	move.l	a2,a1		; -> 1st extra dest plane
	move.w	d7,d1		; dbra # of words per plane
alp:	move.w	(a0)+,d2
	and.w	d2,(a1)+
	dbra	d1,alp
	dbra	d0,aplp

	move.w	d5,d0		; copy 1st extra dest plane to rest of dest
	sub.w	d4,d0		; (dplanes-splanes-1, dbra count)
	subq.w	#2,d0
	blt.b	amask
c2plp:	move.l	a2,a0		; 1st extra dest plane
	move.w	d7,d1
c2lp:	move.w	(a0)+,(a1)+
	dbra	d1,c2lp
	dbra	d0,c2plp

amask:	move.l	mask(a6),a4	; now AND mask to all planes
	subq	#1,d5		; dbra count of dplanes
	cmp.w	#15,d5
	beq.b	pixpac		; (unless pixel packed...)
mplp:	move.l	a4,a0		; -> mask
	move.w	d7,d1		; dbra # of words per plane
mlp:	move.w	(a0)+,d0
	and.w	d0,(a5)+
	dbra	d1,mlp
	dbra	d5,mplp
	bra.b	ret

* If pixel-packed, the outside of the mask must be made all 1's,
* since later in trans_check() all 1's become 0's (black in pixel packed).
pixpac:	move.l	a4,a0
	move.w	d7,d1		; dbra # of words per plane
plp:	move.w	(a0)+,d0
	not.w	d0
	or.w	d0,(a5)+
	dbra	d1,plp
	dbra	d5,pixpac

ret:	movem.l	(sp)+,d4-d7/a4-a5
	unlk	 a6
	rts

*
*	copy from src to dest until and including a null in the
*	source string, return the length not including the null.
*	len = LSTCPY(src,dst)
*		BYTE	*src,dst;
*
_LSTCPY:
	move.l	8(a7),a0	; source
	move.l	4(a7),a1	; destination
	clr.l	d0
lst1:
	addq.b	#1,d0
	move.b	(a0)+,(a1)+	; get and store a byte
	bne	lst1		; test for 0
	subq	#1,d0
	rts
*
*
*	expand from bytes to words until a null, return
*	number of bytes moved (don't transfer null)
*
*	len = LBWMOV(dst,src)
*		BYTE	*dst,src;
*
_LBWMOV:
	move.l	8(a7),a0	; source
	move.l	4(a7),a1	; destination
	clr.l	d0
	clr.l	d1
lbw1:
	move.b	(a0)+,d1	; get a byte
	beq	lbw2		; quit if null       **jde*10-may-85
	move.w	d1,(a1)+	; store a word
	addq.b	#1,d0		; count a character
	bra	lbw1		; test for 0
lbw2:
	rts
	
*
*
*
* ================================================
* ==		Copy block of words		==
*
* IN:	Address of destination block.
*	Address of source block.
*	Number of words to copy.
*
*OUT:	Source block duplicated at Destination.
*
* ==						==
* ================================================
*
*
_LWCOPY:
*
	move.l	4(a7),a0		; Get address of destination.
	move.l	8(a7),a1		; Get address of source.
	move.w	12(a7),d0		; Get number of words to copy.
	beq	lwend			; get out if none
*
lop105:
	move.w	(a1)+,(a0)+		; Copy word.
	subq	#1,d0
	bne	lop105
*
lwend:
	rts

*
*
* ================================================
* ==						==
* ==		Move block of memory		==
* ==						==
*	Moves one block of memory to a new location.  Used mainly to move
*	a square of screen data to a new position on the screen.  Considers
*	if the new block overlaps the old.
*
* IN:	Destination address		LONG.
*	Source address			LONG.
*	Number of bytes to move		WORD.
*
*OUT:	No value returned.
*
*	Screen will show duplication of selected area in new choosen location.
*
*
_LBCOPY:
*
	movem.l	4(a7),a0-a1	; A0 = Destination   A1 = Source.
	clr.l	d0
	move.w	12(a7),d0	; D0 = Number of bytes to moves.
	beq	lbcend		; get out if 0
*
* Move from source starting at top or bottom?
*
	cmp.l	a0,a1		; If A1 < A0 then start from bottom of source
	blt	backward	; and go backward.
*
* Start at beginning of source and move to end of source.
*
lop101:
	move.b	(a1)+,(a0)+
	subq.w	#1,d0
	bne	lop101
	rts
*
* Start at end of source and move backward to begnning of source.
*
backward:
*
	add.l	d0,a1
	add.l	d0,a0
	subq.w	#1,d0
*
lop102:
	move.b	-(a1),-(a0)
ent100:	subq.w	#1,d0
	bpl	lop102
lbcend:
	rts
*
	.end
