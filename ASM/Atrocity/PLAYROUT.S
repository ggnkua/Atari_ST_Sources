;Music by: Tao of ACF
;Ripped by: Sonix / Admirables
;init: - / play: +4 / clear: - 

begin	pea	0.w		;set supervisor
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
	moveq	#1,d0		;music number
	bsr.s	mus		;call it
scan	move	#37,-(sp)
	trap	#14
	addq	#2,sp
	move.l	#2000,d7		;little waiting...
nop	nop
	dbf	d7,nop
	move.w	#$700,$ffff8240.w	;RED color shows the used cpu
	bsr.s	mus+4		;+4 in every vbl!
	move.w	#$777,$ffff8240.w
	cmp.b	#57,$fffffc02.w	;get space
	bne	scan
exit	clr.l	$2700	<-----------;this must be done!
	moveq	#0,d0	<-----------;otherwise it will
	bsr.s	mus	<-----------;nuke you down!
	lea	$ffff8800.w,a0	;clear channels
	move.l	#$8000000,(a0)
	move.l	#$9000000,(a0)
	move.l	#$a000000,(a0)
	pea	$4c0000
	trap	#1		;then bye, bye...

mus	incbin	e:\totf\ridesky2.ACF