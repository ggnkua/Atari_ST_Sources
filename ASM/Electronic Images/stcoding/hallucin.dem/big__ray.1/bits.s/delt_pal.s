framesize	EQU (264*96)+32

		LEA deltapal,A6
		LEA pal+(0*framesize),A0		; -> 1st frame
		LEA pal+(1*framesize),A1		; -> 2nd frame
		BSR dodelta
		LEA pal+(1*framesize),A0
		LEA pal+(2*framesize),A1		
		BSR dodelta
		LEA pal+(2*framesize),A0		
		LEA pal+(3*framesize),A1		
		BSR dodelta
		LEA pal+(3*framesize),A0		
		LEA pal+(4*framesize),A1		
		BSR dodelta
		LEA pal+(4*framesize),A0		
		LEA pal+(5*framesize),A1		
		BSR dodelta
		LEA pal+(5*framesize),A0		
		LEA pal+(6*framesize),A1		
		BSR dodelta
		LEA pal+(6*framesize),A0		
		LEA pal+(7*framesize),A1		
		BSR dodelta
		LEA pal+(7*framesize),A0		
		LEA pal+(0*framesize),A1		
		BSR dodelta
		SUB.L #deltapal,A6

		CLR -(SP)
		TRAP #1

dodelta		MOVEM.L D0-D7/A0-A5,-(SP)
		MOVE.W #framesize/4-1,d0
.lp		CMPM.L (A0)+,(A1)+
		BEQ.S .ok
		ADDQ.L #6,A6
.ok		DBF D0,.lp
		MOVEM.L (SP)+,D0-D7/A0-A5
		RTS
pal		incbin d:\hallucin.dem\BIG__RAY\ray.pal
		even
deltapal
