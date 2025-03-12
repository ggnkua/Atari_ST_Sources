

	opt	o+

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	lea	bri,a1
loop1:
	lea	dest2,a3
	lea	fond,a2
	lea	16*2*3(a2),a2
	lea	2(a2),a2
	rept	16
	move.w	(a1),(a2)
	addq.l	#6,a2
	addq.l	#4,a1
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
	bra	ok1
zero:
	move.b	#0,(a3)+
ok1:
	lea	-16*3*2(a2),a2
	dbf	d1,loop3
	lea	2(a2),a2
	dbf	d2,loop4


	illegal

	section	data

dest2:
	ds.b	16*3*3*16
fin2:

bri:	incbin	"a:\colspr.tab"
	even

spr:	incbin	"a:\colspr.tab"
	even

	section	bss

fond:
	ds.b	2*3*16*3

	end