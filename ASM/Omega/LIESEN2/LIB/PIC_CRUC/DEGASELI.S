***************************************
**	DEGAS ELITE PC? UNCRUNCHER
**	THIS ROUT IS DEASSEMBLED BY LIESEN OF OMEGA
***************************************
**		-FULLY PC-RELATIVE
**		-WORKS BOTH IN USER AND SUPER MODE
**		-CAN UNCRUNCH PC1,PC2,PC3
***************************************
**	IN:	A0=ADDRESS TO CRUNSHED PICTURE
**	IN:	A1=ADDR TO THE AREA WHERE THE PICTURE IMAGE
**		   WILL BE STORED (MOST LIKLY TO BE THE SCREEN)
**	OUT:	D0= 0=ALL OK  -1=SOMETHING'S WRONG (NOT PC? FILE)
***************************************
**	ABOUT:		THE 34 FIRST BYTES IN THE PC? IS IDENTICAL
**			TO THE 34 FIRST BYTES OF THE PI? TYPE
**			EXCEPT FOR BYTE NULL WITCH IS -$80 ON PC?
**			AND 0 ON PI?
**			+2 IS PAL
**			+1 IS RESOLUTION
***************************************

DEGASELITE:	MOVEM.L	A0-A6/D1-D7,-(A7)
		CMPI.B	#$80,(A0)		; DECRUNCH A PC1 PICTURE
		BNE.S	NOELITE
		MOVE.L	A0,A6			; SAVE START

		LEA	34(A0),A0		; SET ALL FLAGS TO START
		MOVEQ	#0,D0
		MOVEQ	#0,D1
		MOVEQ	#0,D2
		MOVEQ	#1,D3

NEXTLINE:	MOVE.B	(A0)+,D4		; D4=NUMBER OF CRUNCHED
		BMI.S	CRUNCHED		;   /UNCRUCHED BYTES

**********************************************
**		UNCRUNCHED (METHOD POSETIV)
**********************************************
		EXT.W	D4
		ADD.W	D4,D2			; ADD TIMES ON BYTE COUNT
GETNEXT:	MOVE.B	(A0)+,(A1)
		LEA	0(A1,D3.W),A1
		EORI.W	#6,D3
		DBF	D4,GETNEXT
		BRA.S	JOINUP

**********************************************
**		CRUNCHED (METHOD NEGATIV)
**********************************************
CRUNCHED:	NEG.B	D4
		EXT.W	D4
		ADD.W	D4,D2			; ADD TIMES ON BYTE COUNT
		MOVE.B	(A0)+,D5
WRITESAME:	MOVE.B	D5,(A1)
		LEA	0(A1,D3.W),A1
		EORI.W	#6,D3
		DBF	D4,WRITESAME

****************************
JOINUP:		ADDQ.W	#1,D2			; INC BYTE COUNT BY 1
		CMP.W	#40,D2			; 40 BYTES DONE ??
		BNE.S	ENDYET			; NO

		CLR.W	D2			; CLEAR BYTE COUNT
		LEA	-158(A1),A1
		ADDQ.W	#1,D1			; INC X*40 COUNT WITH 1
		CMP.W	#4,D1			; IS X*40 COUNT=4 (160)
		BNE.S	ENDYET			; NO

		CLR.W	D1			; CLEAR X*40 BYTES COUNT
		LEA	158(A1),A1
		ADDQ.W	#1,D0
ENDYET:		CMP.W	#200,D0			; ALL 200 LINES DONE ?
		BNE.S	NEXTLINE		; NO

		ADDQ.L	#2,A6			; SET PALETTE
		MOVE.L	A6,-(A7)
		MOVE.W	#6,-(A7)
		TRAP	#14
		ADDQ.L	#6,A7
		MOVEQ	#0,D0
		BRA.S	RETURNTOCALLER

**********************************************
**		ERROR (NOT A PC? FILE)
**********************************************
NOELITE:	MOVEQ	#-1,D0

**********************************************
**		RETURN HOME
***********************************************
RETURNTOCALLER:	MOVEM.L	(A7)+,A0-A6/D1-D7
		RTS
