	EXPORT	_cls

****************************************************************************
****************************************************************************
* CLEAR MEMORY AREA by Megar
****************************************************************************
****************************************************************************

;entr‚es: en d1: la longueur … effacer en octets
;         en d0: l'adresse de d‚but
_cls:
	movem.l	a0-a6/d1-d7,-(sp)
	moveq	#0,d7
	move.l	d0,a0
	btst	#0,d0	;adresse paire ?
	beq.s	.adrok
	move.b	d7,(a0)+
	subq.l	#1,d1
.adrok:
	divu	#13*4*4,d1
	move.l	d1,d0
	swap	d0
	tst.w	d0		;{}
	beq.s	.norest
	move.w	d0,d2
	lsr.w	#1,d0
	beq.s	.norest	
	subq.w	#1,d0
.rest:
	move.w	d7,(a0)+
	dbra	d0,.rest
.norest:
	tst.w	d1
	beq.s	.end_cls
	move.l	d7,d6
	move.l	d6,d5
	move.l	d5,d4
	move.l	d4,d3
	move.l	d3,d2
	move.l	d2,d0
	movea.l	d0,a1
	movea.l	a1,a2
	movea.l	a2,a3
	movea.l	a3,a4
	movea.l	a4,a5
	movea.l	a5,a6
	subq.w	#1,d1
.do_ef:
	movem.l	d0/d2-d7/a1-a6,(a0)
	movem.l	d0/d2-d7/a1-a6,52(a0)
	movem.l	d0/d2-d7/a1-a6,104(a0)
	movem.l	d0/d2-d7/a1-a6,156(a0)
	lea.l	208(a0),a0
	dbra	d1,.do_ef
	btst	#0,d2	;reste impair ?
	beq.s	.end_cls
	move.b	d7,(a0)+
.end_cls:
	movem.l	(sp)+,d1-d7/a0-a6
	rts

