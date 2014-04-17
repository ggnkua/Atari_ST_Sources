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
*	Put in comment		9/4/90		D.Mui
*	Move lmul and ldiv to here	9/5/90	D.Mui

		.text

	.globl	_LBCOPY
	.globl  _LWCOPY
	.globl	_LSTCPY
	.globl	_LBWMOV
.if 0
	.globl	lmul
	.globl	ldiv
	.globl	_ldivr
.endif
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
 	movem.l	d2-d3,-(sp)		; Save d3 since we clobber it
	move.w	12(sp),d3		; d3 = source
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
	movem.l	(sp)+,d2-d3		; Restore d3
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
	movem.l	d2-d7/a2-a5,-(sp)

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

ret:	movem.l	(sp)+,d2-d7/a2-a5
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
*	LWCOPY( dest, source, size )
*		WORD	*dest;
*		WORD	*source;
*		WORD	size;
	
_LWCOPY:
	move.l	4(a7),a0		; Get address of destination.
	move.l	8(a7),a1		; Get address of source.
	move.w	12(a7),d0		; Get number of words to copy.
	beq	lwend			; get out if none
lop105:
	move.w	(a1)+,(a0)+		; Copy word.
	subq	#1,d0
	bne	lop105
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
*	LBCOPY( dest, source, size )
*		BYTE	*dest;
*		BYTE	*source;
*		WORD	size;

_LBCOPY:
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



.if 0
*
*
* ========================================================
* ==							
* ==    long multiply routine without floating point	==
* ==  call with:					==
* ==		two long values on stack		==
* ==  returns:						==
* ==		long value in d0 			==
* ==							==
* == warning:  no overflow checking or indication!!!!	==
* ==							
* ========================================================
*
*
lmul:
	move.l	(a7)+,a0
	move.l	d0, -(a7)
	move.l	d1, -(a7)
	move.l	a0, -(a7)
	link	a6,#-4
	clr.w	d2
	tst.l	8(a6)		;is first arg negative?
	bge	L2
	neg.l	8(a6)		;yes, negate it
	addq.w	#1,d2		;increment sign flag
L2:
	tst.l	12(a6)		;is second arg negative?
	bge	L3
	neg.l	12(a6)		;yes, make it positive
	addq.w	#1,d2		;increment sign flag
L3:
	move.w	10(a6),d0	;arg1.loword
	mulu.w	14(a6),d0	;arg2.loword
	move.l	d0,-4(a6)	;save in temp
	move.w	8(a6),d0	;arg1.hiword
	mulu.w	14(a6),d0	;arg2.loword
	move.w	12(a6),d1	;arg2.hiword
	mulu.w	10(a6),d1	;arg1.loword
	add.w	d1,d0		;form the sum of 2 lo-hi products
	add.w	-4(a6),d0	;add to temp hiword
	move.w	d0,-4(a6)	;store back in temp hiword
	move.l	-4(a6),d0	;long results
	btst	#0,d2		;test sign flag
	beq	L4
	neg.l	d0		;complement the results
L4:
	unlk	a6
	rts


*
*
* ========================================================
* ==							==
* ==			Long Divide			==
* ==							==
* ========================================================
*
ldiv:
	move.l	(a7)+,a0
	move.l	d1, -(a7)
	move.l	d0, -(a7)
	move.l	a0, -(a7)
	link	a6,#-2
	movem.l	d2-d7,-(sp)
	clr.w	d3
	clr.l	d5
	move.l	8(a6),d7
	move.l	12(a6),d6
	bne	La2
	move.l	#$80000000,_ldivr
	move.l	#$80000000,d0
	divs.w	#0,d0			; div by zero trap
	bra	La1
La2:
	bge	La3
	neg.l	d6
	addq.l	#1,d3
La3:
	tst.l	d7
	bge	La4
	neg.l	d7
	addq.l	#1,d3
La4:
	cmp.l	d7,d6
	bgt	La6
	bne	La7
	moveq.l	#1,d5
	clr.l	d7
	bra	La6
La7:
	cmp.l	#$10000,d7
	bge	La9
	divu.w	d6,d7
	move.w	d7,d5
	swap.w	d7
	ext.l	d7
	bra	La6
La9:
	moveq.l	#1,d4
La12:
	cmp.l	d6,d7
	bcs	La11
	asl.l	#1,d6
	asl.l	#1,d4
	bra	La12
La11:
	tst.l	d4
	beq	La6
	cmp.l	d6,d7
	bcs	La15
	or.l	d4,d5
	sub.l	d6,d7
La15:
	lsr.l	#1,d4
	lsr.l	#1,d6
	bra	La11
La6:
	cmp	#1,d3
	bne	La16
	neg.l	d7
	move.l	d7,_ldivr
	move.l	d5,d0
	neg.l	d0
	bra	La1
La16:
	move.l	d7,_ldivr
	move.l	d5,d0
La1:
	movem.l	(sp)+,d2-d7
	tst.l	d2
	unlk	a6
	move.l	_ldivr,d1
	rts


	.bss

_ldivr:		.ds.l	1

.endif

	.end

