; The STE test rout...

Ste_Test	MOVE.L 8.W,-(SP)		; save bus error vect
		BSR Do_Test			; do the test
		MOVE.L (SP)+,8.W		; restore bus error vect 
		RTS
Do_Test		LEA ste_flag(PC),A4
		SF (A4)				; assume ST
		LEA .stfound(PC),A0
		MOVE.L A0,8.W
		LEA stacksave(PC),A0
		MOVE.L SP,(A0)
		CLR.B $FFFF8900.W		; causes bus error on STs!
		ST (A4)				; or fall to STE!
		RTS
.stfound	MOVE.L stacksave(PC),SP		; bus error
		RTS			
stacksave	DC.L 0
