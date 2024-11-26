* Standard program header
* by James Ingram, July 1993


	move.l	4(a7),a5
	move.l	#stack,a7

	move.l	$c(a5),a0
	add.l	$14(a5),a0
	add.l	$1c(a5),a0
	lea	$100(a0),a0
	pea	(a0)
	pea	(a5)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7

