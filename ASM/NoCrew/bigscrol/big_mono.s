; BIG-scroller mono
;
; Copyright 1999 Tomas Berndtsson 
;                NoBrain / NoCrew
;                tomas@nocrew.org
;
; Released under the terms of GPL. Read the file COPYING.

	pea	txt(pc)
	move.w	#9,-(sp)
	trap	#1

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	$44e.w,a3
	lea	scr(pc),a5
	move.l	a5,$45e.w	

dl
	move.w	#$25,(sp)
	trap	#14

	move.l	a5,a4

	moveq	#16-1,d5
rl
	move.l	(a3),d1
	lea	80(a3),a3
	moveq	#32-1,d6
ll
	roxl.l	d1
	scs.b	d0
	ext.w	d0	
	moveq	#25-1,d7
cl	move.w	d0,(a4)
	lea	80(a4),a4
	dbra	d7,cl
	lea	-(80*25-2)(a4),a4
	dbra	d6,ll
	lea	80*25-32*2(a4),a4
	dbra	d5,rl
	
	moveq	#16-1,d5
srl
	lea	-27*2(a3),a3
	move.w	(a3),d7
	roxl.w	d7
	moveq	#14-2,d6
sll
	roxl.w	-(a3)
	dbra	d6,sll
	roxl.w	80-27*2(a3)
	dbra	d5,srl

	bra.s	dl
	
txt	dc.b	'NoCrew Rules!!!!!!'
	;dc.b	'Out of memory!!!!!'
	;dc.b	'NoCrew!!!!!!!!!!!!'

	bss
;	ds.w	1
scr	ds.w	100000

	