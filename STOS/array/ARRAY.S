*****************************************************************
*	This program places a value in a number of 	  	*
*	elements.					  	*
*								*
*	Input is;	D0 = Number elements in array to put 	*
*			     the value in.			*
* 			D1 = The va;ue to place in the array 	*
*			A0 = Address of array			*
*								*
*	Output;		D3 = >0 then error with the number in 	*
*			     D0					*		
*								*
*	The Number in D0 = the number of elements to place the 	*
*	the value in so if you want to place the value 42 in 	*
*	elements of an array from 4 to 8 then the program will 	*
*	look like this :-)					*
*								*
*	10 DIM A(10)						*
*	20 pa=varptr(A(4))					*
*	30 dreg(0)=5:dreg(1)=42:areg(0)=pa			*
*	40 call 10 						*
*	50 e=dreg(3)						*
*	60 if e>0 then print "Error"				*
*	70 for n=1 to 10:print A(N),:next n			*
*								*
*	Note this program works the bases that you have the 	*
*	program in bank 10: if in a different bank then change	*
*	the bank number to the correct number. :->		*
*								*
*	the output will be :0 0 0 42 42 42 42 42 0 0		*
*								*
*	Thank You And Good Night				*
*				The Phantom			*
*								*
*****************************************************************

start:	tst.l	D0
	BEQ.s	error
	subq.l	#1,D0
	
.loop:
	move.l	D1,(A0)+
	DBRA	D0,.loop
	
exit:	rts

error:	move.l	#1,D3
	BRA 	exit