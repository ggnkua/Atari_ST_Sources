** Siner PRG for use within 1-PLANE-O-MANIA by TYG
**
** CODE : Neil/TYG  IDEA : Bruno/GBP  26/10/93
** Siner PRG for use within 1-PLANE-O-MANIA by TYG
**
** CODE : Neil/TYG  IDEA : Bruno/GBP  26/10/93

      	MOVE.W    #99,D3			; 100 Loop 
LOOP	MOVE.W    (A1)+,D0
      	MOVE.W    (A2)+,D1
      	ROR.W     D1,D0 
      	MOVE.W    D0,(A0) 
      	ADDA.W    #160,A0			; Increase screen adr 
      	DBF       D3,LOOP
      	RTS 
