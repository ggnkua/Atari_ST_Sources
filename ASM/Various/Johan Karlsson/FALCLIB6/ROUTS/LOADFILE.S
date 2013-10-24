*
*	Laddar in en fil och packar eventuellt upp den (ice 2.40).
*	a5.l=adr. till nollavslutat filnamn
*	a6.l=dest
*	d7.l=fill„ngd
*	


	include	gem.s
	include	ice.s


@loadfile
	move	#0,-(sp)
	move.l	a5,-(sp)
	@gemdos	$3d,8
	move	d0,d6

	move.l	a6,-(sp)
	move.l	d7,-(sp)
	move	d6,-(sp)
	@gemdos	$3f,12

	move	d6,-(sp)
	@gemdos	$3e,4
	
	move.l	a6,a0
	bsr	@icedecrunch

	rts

