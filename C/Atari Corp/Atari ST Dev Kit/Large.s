***********************************************************************************
***										***
***										***
***				LARGE.S						***
***	Copyright 1986 by Atari Corp.  "all rights reserved"		
***
***										***
*******************************************************************************
*
*	10/26/84		Dan Oliver	author
*	1/31/85	- 03/21/85	Lowell Webster
*	05/10/85		Jim Eisenstein
*	03/04/86		John Feagans	cleanup for developers
*
*	Subroutines used by IBM PC GEM APPLICATIONS.
*
*
	.text
*
	.globl	_LSTRLEN
	.globl	_LBCOPY
	.globl	_LWFILL
	.globl	_LBDSKIP
	.globl	_LWCOPY
	.globl	_LBFILL
	.globl	_LSTCPY
	.globl	_LBWMOV

*
*	copy from src to dest until and including a null in the
*	source string, return the length not including the null.
*	len = LSTCPY(src,dst)
*		BYTE	*src,dst;
*
_LSTCPY:
	move.l	8(a7),a0	* source
	move.l	4(a7),a1	* destination
	clr.l	d0
lst1:
	addq.b	#1,d0
	move.b	(a0)+,(a1)+	* get and store a byte
	bne	lst1		* test for 0
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
	move.l	8(a7),a0	* source
	move.l	4(a7),a1	* destination
	clr.l	d0
	clr.l	d1
lbw1:
	move.b	(a0)+,d1	* get a byte
	beq	lbw2		; quit if null       **jde*10-may-85
	move.w	d1,(a1)+	* store a word
	addq.b	#1,d0		; count a character
	bra	lbw1		* test for 0
lbw2:
	rts
	


*
* ================================================
* ==	Word fill foreward at given address	==
*
* IN:	Address to start storing.
*	Number of words to store.
*	Word to store.
*
*OUT:	Word stored number of times given at given address.
*
* ==						==
* ================================================
*
*
_LWFILL:
*
	move.l	4(a7),a0		* Get starting address off stack.
	move.w	10(a7),d1		* Get value of word to store.
	move.w	8(a7),d0		* Get number of words to store.
	beq	lwfend			* get out if 0
*
lop103
	move.w	d1,(a0)+		* Store given word.
	subq	#1,d0			* Decrement word counter.
	bne	lop103
*
lwfend:
	rts
*
* ================================================
* ==	Unpack Byte memory into Word Memory	==
*
* IN:	Address of Word memory (destination).
*	Address of Byte memory (source).
*	Number of bytes to unpack.
*
*OUT:	Unpacked data.
*
* ==						==
* ================================================
*
*
_LBDSKIP:
*
	move.l	4(a7),a0		* Get destination address.
	move.l	8(a7),a1		* Get source address.
	move.w	12(a7),d0		* Get number of bytes to unpack.
*
	clr.w	d1
lop104
	move.b	(a1)+,d1		* Get byte.
	move.w	d1,(a0)+		* Storw byte as word.
	subq	#1,d0			* Decrement byte counter.
	bne	lop104
*
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
	move.l	4(a7),a0		* Get address of destination.
	move.l	8(a7),a1		* Get address of source.
	move.w	12(a7),d0		* Get number of words to copy.
	beq	lwend			* get out if none
*
lop105
	move.w	(a1)+,(a0)+		* Copy word.
	subq	#1,d0
	bne	lop105
*
lwend:
	rts
*
*
*
* ================================================
* ==	Fill block with given byte		==
*
* IN:	Address of destination block.
*	Number of bytes to store.
*	Byte to store.
*
*OUT:	Filled block with given byte.
*
* ==						==
* ================================================
*
*
_LBFILL:
*
	move.l	4(a7),a0		* Get address of destination.
	move.w	8(a7),d0		* Get number of bytes to store.
	move.w	10(a7),d1		* Get byte to store.
	beq	lbend			* get out if 0
*
lop106
	move.w	d1,(a0)+		* Store given byte.
	subq	#1,d0			* Decrement byte counter.
	bne	lop106
*
lbend:
	rts

*
*
* ================================================
* ==		Get length of string		==
*
* IN: Address of first character in sting shall be on the stack just below
*	the return address.
*
*     The string will terminate with a zero.
*
*     String will always have at least a zero.
*
*OUT: Length will be returned in D0.
*
*     D0 will equal the number of characters in string.
*	EX:
*	    T 	= 1
*	    THE = 3
* ==						==
* ================================================
*
*	move.l	#strg,-(a7)      Push string's address on stack before call.
*
_LSTRLEN:
*
	move.l	4(a7),a0		* Get string's address off stack.
	clr	d0			* Initialize character counter.
*
lop100
	addq	#1,d0			* Increment character counter.
	cmpi.b	#0,(a0)+		* Find first zero,
	bne	lop100			*  loop until zero found.
*
	subq	#1,d0			* Adjust character counter, always one too many.
*
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
	movem.l	4(a7),a0-a1	* A0 = Destination   A1 = Source.
	clr.l	d0
	move.w	12(a7),d0	* D0 = Number of bytes to moves.
	beq	lbcend		* get out if 0
*
* Move from source starting at top or bottom?
*
	cmp.l	a0,a1		* If A1 < A0 then start from bottom of source
	blt	backward	*		  and go backward.
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
ent100	subq.w	#1,d0
	bpl	lop102
lbcend:
	rts
*
	.end
