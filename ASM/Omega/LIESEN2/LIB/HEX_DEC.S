**********************************************
**	HEX -> DEC CONVERTER
**	D0=HEXTAL IN (0-$9FFFF)
**	D0=DEC TAL OUT (0-655359) (BCD SYSTEM!!)
**********************************************
HEX_TO_DEC:	MOVEM.L	D1/D6-D7,-(A7)
		MOVEQ	#0,D7
		MOVEQ	#32,D6
NEXTTAL:	DIVU	#10,D0
		MOVE.L	D0,D1
		SWAP	D1
		OR.W	D1,D7
		ROR.L	#4,D7
		SUBQ.W	#4,D6
		AND.L	#$FFFF,D0
		BNE.S	NEXTTAL
		ROR.L	D6,D7
		MOVE.L	D7,D0
		MOVEM.L	(A7)+,D1/D6-D7
		RTS
