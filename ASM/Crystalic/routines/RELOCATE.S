RELOCATE:	
	MOVE.L  #PROG,A0  
	MOVE.L  2(A0),D0  
	ADD.L   6(A0),D0  
	ADD.L   14(A0),D0 

	ADD.L   #$1C,A0   
	MOVE.L  A0,A1     
	MOVE.L  A1,A2     
	MOVE.L  #PROG,d1
	ADD.W	#$1c,D1   

	ADD.L   D0,A1     
	MOVE.L  (A1)+,D0  
	ADD.L   D0,A2     
	ADD.L   D1,(A2)   
	CLR.L   D0        
RELO:	
	MOVE.B  (A1)+,D0  
	BEQ     RELEND    
	CMP.B   #1,D0     
	BEQ     RELOJUMP      
	ADD.L   D0,A2     
	ADD.L   D1,(A2)   
	BRA     RELO      
RELOJUMP:	
	ADD.L   #254,A2   
	BRA     RELO      
RELEND:
	RTS
********************************