
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	pea	$3f8000
	pea	$3f8000
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	lea	pic+34,a0
	lea	$3f8000,a1
	move.w	#32000/8-1,d0
c:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,c
	
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,-(sp)
	
	move.l	#-1,50*160+2*8+$3f8000
	move.l	#-1,50*160+2*8+$3f8000+4
	
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	moveq	#0,d0
	lea	$3f8000,a1
	bsr	gogo
	illegal
	moveq	#4,d0
	bsr	gogo
	
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.w	#1,-(sp)
	pea	$3f8000
	pea	$3f8000
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	clr.w	-(sp)
	trap	#1

	include	"f:\chipmon.2_0\hex\depatm.s"
	
	
pic:	incbin	"f:\chipmon.2_0\soundpa2.pi1"
	even
	
		
	