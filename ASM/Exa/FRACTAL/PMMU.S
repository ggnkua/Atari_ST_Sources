vsync	macro
	clr.L	$466.w
	tst.l	$466.w
	beq.s	*-4
	endm


	clr.l	-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	$fffffa06.w,-(sp)
	move.l	$70.w,-(sp)
	clr.l	$fffffa06.w
	move.l	#it,$70.w

	;pmmu_off

	move.w	#$3111,d0
	bset	#8,d0
	movec	d0,cacr


loop
	vsync

	move.l	#$ff,$fffff9800.w


	lea	$fffff8208.w,a0
	move.l	$44e.w,a1
	move	#2000,d7
loop2
	rept	10
	move.w	(a0),(a1)+
	endr
	dbf	d7,loop2


	move.l	#-1,$fffff9800.w
	cmp.b	#$39,$fffffc02.w
	bne	loop

	movec	cacr,d0
	bset	#8,d0
	movec	d0,cacr


	;pmmu_on

	move.w	#$2700,sr
	move.l	(sp)+,$70.w
	move.l	(sp)+,$fffffa06.w
	move	#8000,d0
	dbf	d0,*
	move.w	#$2300,sr

	clr.l	-(sp)
	trap	#1

it
	addq.l	#$1,$466.w
	rte	

null	dc.l	0





