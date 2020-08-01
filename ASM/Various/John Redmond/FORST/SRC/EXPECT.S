; EXPECT.S: Expect package for console input
; Copyright <C> John Redmond, 1990,
; Public domain for non-commercial use.
;
	section	text
	even
;
_expect: tst.l	(a6)
	beq.s	.exx
	movem.l	d2/a2-a3,-(a7)
	move.l	(a6),d1			;buffer address
        move.l  4(a6),d2
        move.l  #32,d0
        movem.l d0-d2,-(a6)
        bsr     _fill			;clear buffer
        push	#0			;#chars already in the buffer
        bsr.s	re_expect
        movem.l	(a7)+,d2/a2-a3
.exx:	rts
;
re_expect: movem.l a2/d2-d5,-(a7)
	pop	d2			;# chars already in buffer
	pop	d3			;max # chars
	pop	a2			;buffer address
	moveq.l	#0,d4			;# chars on right of cursor
	move.l	d2,d5			;# chars on left of cursor
	beq.s	.rel			;no chars in buffer
	push	a2
	push	d2
	bsr	_ctype			;type what is in the buffer
	sub.l	d2,d3			;chars to go
	add.l	d2,a2			;adjust pointer
.rel:	bsr	_ekey			;keystroke with edit
	tst.l	d1			;check flag
	bmi.s	.rel			;neg if char not acceptable
        cmp.b   #13,d0                  ;finished?
        beq.s     .rex
        bsr.s     kpchar
        tst.l	d3			;# chars to go
        bne.s	.rel
.rex:   lea     span,a1                 ;keep # significant chars
        move.l	d2,(a1)
        bsr	rtype
	bsr     _space
        movem.l	(a7)+,a2/d2-d5
        rts
;
_ekey:  				;expects ^buffer, #to go, #so far
	bsr	_xkey
        pop     d0			;the char
        cmp.w	#$0e08,d0		;backspace?
        beq	bspace
        cmp.w	#$011b,d0		;escape?
        beq	bspaces
	cmp.w	#$4b00,d0
	beq	goleft			;cursor left?
	cmp.w	#$4d00,d0
	beq	goright			;cursor right?
	cmp.w	#$7300,d0
	beq	farleft			;cursor left?
	cmp.w	#$7400,d0
	beq	farright		;cursor right?
        moveq.l	#0,d1			;flag for an OK char
        cmp.b	#13,d0			;return
        beq	.ekx
	cmp.b	#32,d0
	bge.s	.ekx
.ek8:	moveq.l	#-1,d1			;not an OK char
.ekx:	rts
;
kpchar:	tst.l	d3
	beq.s	.kcx			;no more room
	bsr.s	insertchar
        bsr.s	showchars
        addq.l  #1,d2			;char count
        subq.l  #1,d3			;# chars to go
        addq.l	#1,d5			;# chars on left of cursor
.kcx:   rts
;
insertchar: tst.l d4			;chars on right?
	beq.s	.ic5
	push	d0			;the char
	lea	1(a2),a0
	push	a2			;string start
	push	a0			;string dest
	push	d4			;# chars right
	bsr	_cmovegt
	pop	d0			;get the char back
.ic5:	move.b  d0,(a2)+		;char into buffer
.icx:	rts
;
showchars:
	push	d0
	bsr	_conout
	tst.l	d4
	beq.s	.scx
	bsr.s	showright
;	bsr	toright
.scx:	rts
;
showright: push	#27
	bsr	_conout
	push	#$6a
	bsr	_conout			;mark cursor position
	push	#27
	bsr	rtype
	bsr	_conout
	push	#$6b
	bsr	_conout			;restore cursor position
	rts
;
rtype:	push	a2	
	push	d4
	bsr	_ctype			;type string after char
	rts
;
bspace: tst.l   d5
        beq.s     .bsx			;cannot backspace
        bsr     _bspace
        subq.l  #1,d2			;# chars so far
        addq.l  #1,d3			;# chars to go
        subq.l	#1,d5			;# chars on left
        move.b	#32,-(a2)		;backup buffer pointer
        tst.l	d4			;#chars on right
        beq.s	.bsx
        move.l	a2,a0
        addq.l	#1,a0
        push	a0
        push	a2			;dest
        push	d4
        bsr	_cmove			;shuffle string left
        move.b	#32,(a2,d4.l)		;poke a space at the end
        addq.l	#1,d4			;include space at end
        bsr	showright
        subq.l	#1,d4			;forget the space
.bsx:   moveq.l	#-1,d1
	rts
;
bspaces: tst.l   d5
        beq     .bssx                   ;cannot backspace
        push	d4			;# chars on right
        bsr	_spaces			;clear on right
        push	d2			;# chars so far
        bsr     _bspaces                ;# times is on stack
        add.l   d5,d3                   ;restore # chars to go
        suba.l  d5,a2			;restore pointer
        clr.l	d2			;# chars so far
        clr.l   d4			;# chars on right
        clr.l	d5			;# chars on left
        push	a2
        push	d3
        push	#32
        bsr	_fill			;clear the buffer
.bssx:  moveq.l	#-1,d1
	rts
;
farleft: tst.l	d5			;# chars on left
	beq.s	.flx
	add.l	d5,d4			;# chars on right
	sub.l	d5,a2			;char pointer
.fll:	bsr	toleft
	subq.l	#1,d5
	bne.s	.fll
.flx:	moveq.l	#-1,d1
	rts
;
farright: tst.l	d4			;# chars on right
	beq.s	.frx
	add.l	d4,d5			;# chars on left
	add.l	d4,a2			;char pointer
.frl:	bsr	toright
	subq.l	#1,d4
	bne.s	.frl
.frx:	moveq.l	#-1,d1
	rts
;
toright: push	#27
	bsr	_conout
	push	#$43
	bsr	_conout			;cursor right
	rts
;
toleft:	push	#27
	bsr	_conout
	push	#$44
	bsr	_conout			;cursor left
	rts
;
goright: tst.l	d4			;# chars on right
	beq.s	.grx
	addq.l	#1,a2			;bump pointer
	subq.l	#1,d4			;# chars on right
	addq.l	#1,d5			;# chars on left
	bsr.s	toright
.grx:	moveq.l	#-1,d1
	rts
;
goleft: tst.l	d5
	beq.s	.glx
	subq.l	#1,a2			;pointer
	addq.l	#1,d4			;# chars on right
	subq.l	#1,d5			;#chars on left
	bsr.s	toleft
.glx:	moveq.l	#-1,d1
	rts
;
