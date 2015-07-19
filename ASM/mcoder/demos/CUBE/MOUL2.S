;
; reformatte le source g‚n‚r‚ par EASY-RIDER
;
source=$90000
dest=$80000
long=372026

	lea	source,a4
	lea	source+long,a5
	lea	dest,a6
main:
	cmp.l	a5,a4
	bhs.L	fini

	move.b	(a4)+,d0
	cmp.b	#' ',d0
	beq.s	strip1
loop1:
	move.b	d0,(a6)+

	cmp.l	a5,a4
	bhs.s	fini

	move.b	(a4)+,d0
	cmp.b	#':',d0
	bne.s	loop1
	move.b	d0,(a6)+
strip1:
	move.b	#9,(a6)+
loop2:
	move.b	(a4),d1		;d1=premier caractŠre
	cmp.b	#' ',d1
	bne.s	strip2
	addq	#1,a4
	bra.s	loop2

loop3:	move.b	d0,(a6)+
	cmp.b	#10,d0
	beq.s	main
strip2:
	cmp.l	a5,a4
	bhs.s	fini

	move.b	(a4)+,d0
	cmp.b	#' ',d0
	bne.s	loop3

	move.b	(a4),d0
	cmp.b	#' ',d0
	beq.s	strip2
	cmp.b	#13,d0
	beq.s	strip2

	cmp.b	#'D',d1
	beq.s	okd

	cmp.b	#'.',-2(a6)
	bne.s	okd
	cmp.b	#'W',-1(a6)
	bne.s	okd
	subq	#2,a6
okd:

	moveq	#9,d0
loop4:	move.b	d0,(a6)+
	cmp.l	a5,a4
	bhs.s	fini

	move.b	(a4)+,d0
	cmp.b	#13,d0
	bne.s	loop4

	cmp.b	#' ',-1(a6)
	bne.s	skip1
	subq	#1,a6
skip1:
	move.b	d0,(a6)+
	move.b	(a4)+,(a6)+
	bra	main
fini:
	lea	dest,a0
	move.l	a6,a1
	illegal
