
		LEA deltagfx,A6
		LEA gfx+(0*160*264),A0		; -> 1st frame
		LEA gfx+(1*160*264),A1		; -> 2nd frame
		BSR dodelta
		LEA gfx+(1*160*264),A0
		LEA gfx+(2*160*264),A1		
		BSR dodelta
		LEA gfx+(2*160*264),A0		
		LEA gfx+(3*160*264),A1		
		BSR dodelta
		LEA gfx+(3*160*264),A0		
		LEA gfx+(4*160*264),A1		
		BSR dodelta
		LEA gfx+(4*160*264),A0		
		LEA gfx+(5*160*264),A1		
		BSR dodelta
		LEA gfx+(5*160*264),A0		
		LEA gfx+(6*160*264),A1		
		BSR dodelta
		LEA gfx+(6*160*264),A0		
		LEA gfx+(7*160*264),A1		
		BSR dodelta
		LEA gfx+(7*160*264),A0		
		LEA gfx+(0*160*264),A1		
		BSR dodelta
		SUB.L #deltagfx,A6

		CLR -(SP)
		TRAP #1

dodelta		MOVEM.L D0-D7/A0-A5,-(SP)
		MOVE.W #(160*264)/4-1,d0
.lp		CMPM.L (A0)+,(A1)+
		BEQ.S .ok
		ADDQ.L #6,A6
.ok		DBF D0,.lp
		MOVEM.L (SP)+,D0-D7/A0-A5
		RTS
gfx		incbin d:\hallucin.dem\BIG__RAY\ray.gfx
		even
deltagfx
