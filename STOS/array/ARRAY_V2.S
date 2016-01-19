*****************************************************************
*	This program places a value in a number of 	  	*
*	elements.					  	*
*								*
*	Input is;	D0 = Number elements in array to put 	*
*								*
* 			A1 = The address of the destiontion 	*
*			     Array.				*
*			A0 = Address soucre array		*
*								*
*	Output;		D3 = >0 then error with the number in 	*
*			     D0					*		
*								*
*								*
*	Thank You And Good Night				*
*				The Phantom			*
*								*
*****************************************************************

start:	tst.l	D0
	BEQ.s	error
	subq.l	#1,D0
	
.loop:
	move.l	(A0)+,(A1)+
	DBRA	D0,.loop
	
exit:	rts

error:	move.l	#1,D3
	BRA 	exit