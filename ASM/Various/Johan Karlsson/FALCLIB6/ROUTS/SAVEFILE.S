*
* SAVEFILE.S
*
*	@savefile
*
*	Saves data as a file.
*
* In	a5.l=adr. till nollavslutat filnamn
*	a6.l=source
*	d7.l=fill„ngd
*	

	include	gem.s


@savefile
	move	#0,-(sp)	create file
	move.l	a5,-(sp)
	@gemdos	$3c,8
	move	d0,d6

	move.l	a6,-(sp)	write
	move.l	d7,-(sp)
	move	d6,-(sp)
	@gemdos	$40,12

	move	d6,-(sp)	close
	@gemdos	$3e,4
	
	rts

