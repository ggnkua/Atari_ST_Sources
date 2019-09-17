;Flashing Colour Bootsector Code (Obviously not colour on mono ST's!!!)
;(C)1993 Glenn Edwards

;Example file for use with The Bootsector Companion


	OPT	O+

start	MOVEM.L	D0-D4/A0-A3,-(SP)	;Save registers

	BSR.S	wvsync	
	MOVE.B	#0,$FFFF8260.W		;Low Res

	MOVE.W	#1000,D3		;Set loop counter
	MOVEQ.W	#0,D4			;Quick clear colour counter
loop	BSR.S	wvsync
	MOVE.W	D4,$FFFF8240.W		;Set colour 0 to D6
	ADDQ.W	#1,D4			;Inc colour counter
	CMP.W	#$777,D4		;Colour counter <= #$777?
	BLE.S	next			;If yes, branch to "next"
	MOVEQ.W	#0,D4			;Quick clear colour counter
next	DBRA	D3,loop			;Dec D7 and goto loop

	MOVE.W	#$777,$FFFF8240.W	;Reset colour to white	

	MOVEM.L	(SP)+,D0-D4/A0-A3	;Restore registers
	RTS				;Return control back to OS
	
wvsync	MOVE.W	#37,-(SP)
	TRAP	#14			;Wait for vsync
	ADDQ.L	#2,SP
	RTS
