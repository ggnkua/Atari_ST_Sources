	move.l	4(sp),a5	
	move.l	#$200,-(sp)	
	move.l	a5,-(sp)	
	pea	$4a0000		
	trap	#1
	add.l	#$c,sp

	lea	$60000,a0
	lea	$10000,a1
	lea	$68000,a2
more	move.l	(a0)+,(a1)+
	cmp.l	a2,a0
	ble.s	more
	jmp	$10000
	