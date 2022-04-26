NEWVBL:
	CLR.B 	$FFFFFA1B.W	
	MOVE.B 	#1,$FFFFFA21.W	
	MOVE.B 	#8,$FFFFFA1B.W	
	RTE			
NEWHBL:
	CLR.B	$FFFFFA1B.W
	BCLR 	#0,$FFFFFA0F.W	
	RTE			
********************************
