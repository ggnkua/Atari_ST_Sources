*
* GETPAR.S	(include right after releasem.s)
*
*	Gets all parameters sent to the program.
*	Must be directly after releasem.
*
* Out	a0.l=address where the parameters are.
*



@getparameters	pea	$81(a6)
		move.l	(a7)+,a0
		

