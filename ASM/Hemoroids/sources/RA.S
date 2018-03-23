	pea	demo
	move.w	#38,-(sp)
	trap	#14
	lea	6(sp),sp
	clr.w	-(sp)
	trap	#1

demo
	clr.w	-(sp)
	pea	-1.l
	pea	-1.l
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	movem.l	couls,d0-d7
	movem.l	d0-d7,$ffff8240.w
	lea	picture,a1
	lea	232*40(a1),a2
	lea	232*40(a2),a3
	lea	232*40(a3),a4
	lea	$1f8000,a0
	move.w	#20*200-1,d0
yop	move.w	(a1)+,(a0)+
	move.w	(a2)+,(a0)+
	move.w	(a3)+,(a0)+
	move.w	(a4)+,(a0)+
	dbra	d0,yop

	move.w	#7,-(sp)
	trap	#1
	lea	2(sp),sp
	rts

couls	dc.w	$0ACE/2,$0CCC/2
	dc.w	$0404/2,$0426/2
	dc.w	$0246/2,$024A/2
	dc.w	$026A/2,$046C/2
	dc.w	$028C/2,$068E/2
	dc.w	$04AE/2,$06CE/2
	dc.w	$0A8E/2,$0EEE/2
	dc.w	$08AC/2,$0AAA/2
picture	incbin	a:logo.raw
