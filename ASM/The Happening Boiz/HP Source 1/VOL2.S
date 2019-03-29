**********************************************
* THE HAPPENING BOIZ PRESENT THE VOLUME      *
* READ EXTENSION!!                           *
*ENTER WITH A5 POINTING TO MEMORY WHERE YOU  *
*WANT THE 3 VOLUMES RETURNED TO (3 BYTES!)   *
*EG AREG(5)=START(3)
*AFTER CALLING ROUTINE THE FIRST 3 BYTES IN  *
*MEMORY BANK 3 WILL BE THE 3 CHANNEL VOLUMES *
**********************************************


CHANGE	MOVEQ.W #0,D0
	MOVEQ.W #0,D1
	MOVEQ.W #0,D2
	MOVE.B #8,$FFFF8800.W  	
	MOVE.B $FFFF8800.W,D0
	MOVE.B #9,$FFFF8800.W   
	MOVE.B $FFFF8800.W,D1
	MOVE.B #10,$FFFF8800.W  
	MOVE.B $FFFF8800.W,D2
	BTST #4,D0              
	BEQ .L1
	MOVE.B #10,D0           
.L1	BTST #4,D1    		
       	BEQ .L2
	MOVE.B #10,D1
.L2	BTST #4,D2		
	BEQ .L3
	MOVE.B #10,D2
.L3 	MOVE.B	D0,0(A5)
	MOVE.B	D1,1(A5)
	MOVE.B	D2,2(A5)
	RTS
	

