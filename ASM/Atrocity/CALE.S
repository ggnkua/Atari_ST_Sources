	pea	0.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move.w	#20,d0
	move.l	$ffff8284.w,a0
	move.l	$ffff8286.w,a1
	add	d0,a0
	add	d0,a1
	
	