	lea	img+34(pc),a0
	move.l	a0,a1
loop
	move.l	(a0)+,(a1)+
	addq.l	#4,a0
	cmp.l	#yop,a0
	ble.s	loop
	nop
img
	incbin	64KFONT4.pi1
yop
