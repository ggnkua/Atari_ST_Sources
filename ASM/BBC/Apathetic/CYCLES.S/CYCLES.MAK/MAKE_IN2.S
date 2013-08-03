	clr.w -(a7)
	pea in(pc)
	move.w #$3d,-(a7)
	trap #1
	addq.w #4,a7
	move.l d0,d5
	pea $70000
	pea $50000
	move.w d5,-(a7)
	move.w #$3f,-(a7)
	trap #1
	lea 12(a7),a7
	move.w d5,-(a7)
	move.w #$3e,-(a7)
	trap #1
	addq.w #4,a7

	lea $70000+34,a0
	move.l #32000/4,d1
loop	eor.l #'XXXX',(a0)+
	subq.l #1,d1
	bne.s loop

	clr.w -(a7)
	pea out(pc)
	move.w #$3c,-(a7)
	trap #1
	addq.w #4,a7
	move.l d0,d5
	pea $70000
	pea 32066
	move.w d5,-(a7)
	move.w #$40,-(a7)
	trap #1
	lea 12(a7),a7
	move.w d5,-(a7)
	move.w #$3e,-(a7)
	trap #1
	addq.w #4,a7

	illegal

in	dc.b "5x5.pi1",0
out	dc.b "7x7.inv",0