VgetMonitor:
	move.w	#$59,-(a7)
	trap	#14
	lea	2(a7),a7
	
VgetRGB:
	move.l	a0,-(a7)
	move.w	d0,-(a7)
	move.w	d1,-(a7)
	move.w	#$5e,-(a7)
	trap	#14
	lea	10(a7),a7
	
VgetSize:
	move.w	d0,-(a7)
	move.w	#$5b,-(a7)
	trap	#14
	lea	4(a7),a7
	
VsetScreen:
	move.w	d0,-(a7)
	move.w	#3,-(a7)
	move.w	#-1,-(a7)
	move.w	#-1,-(a7)
	move.w	#$05,-(a7)
	trap	#14
	lea	14(a7),a7
	
	