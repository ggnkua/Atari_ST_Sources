error_clavier: 
	btst	#5,$fffffc00.w		vide le buffer clavier
	beq.s	noerror
	
	tst.b	$fffffc02.w
	bra.s	error_clavier
noerror:

	btst	#0,$fffffc00.w
	beq.s	vidbuff
	
	tst.b	$fffffc02.w
	bra.s	error_clavier
vidbuff:

	rts