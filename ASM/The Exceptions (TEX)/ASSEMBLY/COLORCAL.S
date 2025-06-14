* A color one-dimensional cellular automata program by Chris Long and
* John Balsley.  Program is old (this was the second program we wrote
* for the ST; the first was ye typical "hello" program), and can probably
* be speeded up and improved with a miniscule amount of thought and
* effort.  Designed to be used in low-res.

intin   equ     8
ptsin   equ     12

init    equ     $a000
setpix  equ     $a001
getpix  equ     $a002

	dc.w	init
	move.l	intin(a0),a3
	move.l	ptsin(a0),a4

	lea.l	frame1,a5
	move.b	#1,(a5)
	move.b	#1,201(a5)
	clr	cycles

nxtscr	lea.l	frame1,a5
	lea.l	frame2,a6
	adda.l	#1,a6

	move	cycles,(a4)
	move	#0,2(a4)
	clr	d5

nxtcll1	move.b	(a5)+,d5
	add.b	1(a5),d5

	cmpi	#15,d5
	blt	alive1

	move.b	#0,(a6)+
	move	#0,(a3)
	dc.w	$a001
	addq	#1,2(a4)
	cmpi	#200,2(a4)
	bne	nxtcll1
	jmp	out1

alive1	move.b	d5,(a6)+
	move	d5,(a3)
	dc.w	$a001
	addq	#1,2(a4)
	cmpi	#200,2(a4)
	bne	nxtcll1

out1	addq	#1,cycles
	lea.l	frame2,a5
	lea.l	frame1,a6
	adda.l	#1,a6

	move	cycles,(a4)
	move	#0,2(a4)
	clr	d5

nxtcll2	move.b	(a5)+,d5
	add.b	1(a5),d5

	cmpi	#15,d5
	blt	alive2

	move.b	#0,(a6)+
	move	#0,(a3)
	dc.w	$a001
	addq	#1,2(a4)
	cmpi	#200,2(a4)
	bne	nxtcll2
	jmp	out2

alive2	move.b	d5,(a6)+
	move	d5,(a3)
	dc.w	$a001
	addq	#1,2(a4)
	cmpi	#200,2(a4)
	bne	nxtcll2

out2	addq	#1,cycles
	cmpi	#320,cycles
	bne	nxtscr
	clr	cycles
	jmp	nxtscr

cycles	ds.w	1
frame1	ds.b	202
frame2	ds.b	202

	end
