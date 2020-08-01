; STRTFIN.S: starting and finishing routines for ForST
; Copyright <c> John Redmond, 1989, 1990
; Public domain for non-commercial use.
;
init:	bsr	_decimal	;decimal arithmetic
	lea	dest,a0
	move.l	#1,(a0)		;console output
	bsr	clrbuffs	;and input
	lea	iostring,a0
	push	a0
	bsr	_string	 	;configure screen behaviour
	rts
;
setup:	move.l	4(a7),a5
	lea	index,a4	;get base address pointer
	move.l	$c(a5),d0	;code size
	move.l	d0,2(a4)
	move.l	$14(a5),d1	;data size
	move.l	d1,6(a4)
	add.l	d1,d0
	move.l	$1c(a5),d1	;bss size
	move.l	d1,10(a4)
	add.l	d1,d0
	add.l	#$100,d0	;size of base page
	andi.b	#$fe,d0		;align
	lea	(a5,d0.l),a7
	suba.l	heads(pc),a7
	move.l	d0,-(a7)	;length of block
	move.l	a5,-(a7)	;start of block
	clr.w	-(a7)
	move.w	#$4a,-(a7)	;setblock
	trap	#1
	add.l	#12,a7
	move.l	a7,a6
	suba.l	rstck(pc),a6
	lea	stack,a0
	move.l	a7,(a0)		;save system stack pointer
	lea	dstack,a0
	move.l	a6,(a0)		;and data stack pointer
	lea	origin,a0
	move.l	a4,(a0)		;formal origin of code
	move.l	a4,a5		;and base pointer
	bsr	headersup	;headers into place above stacks
	bra	cold
;
clrbuffs: bsr	clrin		;set up instack
	lea	bufflgs,a0
	clr.l	(a0)
	clr.l	4(a0)		;clear 8 byte flags
	lea	lstkptr,a0	;link ptrs
	move.l	a0,(a0)
	lea	lpstkptr,a0	;loop ptrs
	move.l	a0,(a0)		;clear system stacks
	lea	oldlen,a0
	clr.l	(a0)		;no previous keyboard input
	rts
;
headersup:
	move.l	2(a5),a1	;code size
	lea	cp,a0
	move.l	a1,(a0)		;cp offset
	lea	fence,a0
	move.l	a1,(a0)
	adda.l	a5,a1		;address of headers before move
;
	lea	stack,a0
	move.l	(a0),a0		;base of return stack
	move.l	a0,d0
	sub.l	a5,d0		;offset of stack base
	add.l	6(a5),d0	;add header size to point to top
;
	lea	hp,a2
	move.l	d0,(a2)		;headers to go to stack base
	move.l	6(a5),d0	;get length of header block (data)
	movem.l d0/a0/a1,-(a6)
	bsr	_cmove		;move all headers up
	bsr	_there
	lea	entry,a0
	pop	(a0)		;entry has a real address (not offset)
	rts
;
endup:	clr.w	-(a7)
	move.w	#$4c,-(a7)
	trap	#1		;p_term
;
