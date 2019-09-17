	move.l	a7,a5
	move.l	4(a5),a5
	move.l	a5,a6
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$500,d0

	move.l	d0,d1
	add.l	a5,d1
	and.l	#-2,d1
	move.l	d1,a7
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move	#$4a,-(sp)
	trap	#1
	add.l	#12,sp
