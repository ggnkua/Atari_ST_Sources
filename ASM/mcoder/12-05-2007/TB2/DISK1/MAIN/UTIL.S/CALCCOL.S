

	opt	o+

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	lea	bri,a1
	lea	dest1,a4
	move.w	#240-1,d5
	
loop1:
	lea	fond,a2
	lea	dest1,a3
	moveq	#0,d0
.loopeff:
	move.b	d0,(a2)+
	cmp.l	a3,a2
	bne.s	.loopeff

	lea	dest2,a3
	lea	fond,a2
	lea	16*2*3(a2),a2
	lea	2(a2),a2
	rept	16
	move.w	(a1),(a2)
	addq.l	#6,a2
	addq.l	#2,a1
	endr

	lea	fond,a2
	move.w	#(3*16*2)-1,d2
loop4:
	lea	spr,a0
	move.w	#15,d1
loop3:
	moveq	#0,d7
*	move.w	#15,d0
loop2:
	rept	16
	move.w	(a2),d6
	and.w	(a0)+,d6
	or.w	d6,d7
	move.w	2(a2),d6
	and.w	(a0)+,d6
	or.w	d6,d7
	lea	3*2(a2),a2
*	addq.w	#1,$ffff8240.w
	endr
*	dbf	d0,loop2
	tst.w	d7
	beq.s	zero
	move.b	#1,(a3)+
	bra.s	ok1
zero:
	move.b	#0,(a3)+
ok1:
	lea	-16*3*2(a2),a2
	dbf	d1,loop3
	lea	2(a2),a2
	dbf	d2,loop4

	lea	dest2,a3
	move.w	#287,d0
loop5:
	moveq	#0,d1

st	set	7
	rept	7
	moveq	#0,d2
	move.b	(a3)+,d2
	lsl.w	#st,d2
	or.w	d2,d1
st	set	st-1
	endr
	moveq	#0,d2
	move.b	(a3)+,d2
	or.w	d2,d1

	move.b	d1,(a4)+

	addq.w	#1,$ffff8240.w
	dbf	d0,loop5

	dbf	d5,loop1


	illegal

	section	data

dest2:
	ds.b	16*3*3*16
fin2:

bri:	incbin	"a:\col.ter"
	even

spr:	incbin	"a:\decmsk.ter"
	even

	section	bss

fond:
	ds.b	2*3*16*3


dest1:	ds.b	288*20*12
fin1

	end

