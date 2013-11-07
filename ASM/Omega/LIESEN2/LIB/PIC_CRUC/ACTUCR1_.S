A:
******************************************************
******************************************************
**	UNCRUNCHER V. 1.1
******************************************************
**	UPDATE VERSION:
*		V1.1	-FULLY RELOCATEABLE
*			-CAN BE CALLED FROM GFA BASIC WITH INLINE AND RCALL
*			-SAVES THE PAL WHEREEVER YOU WANT IT TO BE STORED
*			-WORKS IN USER MODE (AND SUPER)
*			-NO TRAPS
******************************************************
*	IN:	A0=SORCE AREA ADDR (32KB)
*		A1=DEST AREA ADDR (32KB)
*		A2=WORK AREA ADDR (32KB) COULD BE SAME AS DEST
*		A3=ADDR WHERE THE PALETE WILL BE SAVED (32 BYTES)
*		   (UNCRUNCHER DOES NOT ENTER SUPERVISOR....)
******************************************************
UN:		MOVEM.L	D0-D7/A0-A6,-(A7)
		LEA	USORCE(PC),A6
		MOVE.L	A0,(A6)
		LEA	UDEST(PC),A6
		MOVE.L	A1,(A6)
		LEA	USCREEN(PC),A6
		MOVE.L	A2,(A6)
		LEA	UPALADDR(PC),A6
		MOVE.L	A3,(A6)


		BSR.L	BYTE_UNCRUNCH
		MOVE.L	A0,D7

		LEA	LOWCONTAIN(PC),A6
		BTST	#0,(A6)
		BEQ.S	NOT_BITSPLIT
		BSR.S	BIT_UNSPLIT
NOT_BITSPLIT:	LEA	LOWCONTAIN(PC),A6
		BTST	#4,(A6)
		BEQ.S	NOT_SMART
		BSR.S	UNSMART
NOT_SMART:
		MOVEM.L	(A7)+,D0-D7/A0-A6
		RTS
****************************************************
***		SCREEN FORM 'SMART' REMOVE
****************************************************
UNSMART:	MOVE.L	USCREEN(PC),A1
		MOVE.L	UDEST(PC),A0
		MOVE.W	#0,CCR
		MOVE.W	#3999,D5
MANYMANY:	MOVEQ	#0,D0
		MOVE.W	D0,D1
		MOVE.W	D1,D2
		MOVE.W	D2,D3
		MOVEQ	#1,D6
TWO:		MOVEQ	#7,D7
		MOVE.L	(A1)+,D4
EIGHT:
		ROXL.L	#1,D4
		ROXL.W	#1,D0
		ROXL.L	#1,D4
		ROXL.W	#1,D1
		ROXL.L	#1,D4
		ROXL.W	#1,D2
		ROXL.L	#1,D4
		ROXL.W	#1,D3
		DBF	D7,EIGHT
		DBF	D6,TWO
		MOVE.W	D0,(A0)+
		MOVE.W	D1,(A0)+
		MOVE.W	D2,(A0)+
		MOVE.W	D3,(A0)+
		DBF	D5,MANYMANY
		RTS
***************************************************
**		BIT UNSPLIT
***************************************************
BIT_UNSPLIT:	MOVE.L	USCREEN(PC),A1
		MOVE.L	UDEST(PC),A0
		MOVE.W	#$F9F,D0
BIT_UNSPLIT1:	MOVE.W	(A1),(A0)+
		MOVE.W	$1F40(A1),(A0)+
		MOVE.W	$3E80(A1),(A0)+
		MOVE.W	$5DC0(A1),(A0)+
		ADDQ.L	#2,A1
		DBF	D0,BIT_UNSPLIT1
		RTS
****************************************************
**		BYTE UNCRUNCH
****************************************************
BYTE_UNCRUNCH:	MOVE.L	USORCE(PC),A0
		MOVE.L	USCREEN(PC),A1
		MOVE.B	(A0)+,D7			; VERSION
		LEA	LOWCONTAIN(PC),A6
		MOVE.B	(A0)+,(A6)			; CONTAIN LOW BYTE
		MOVEM.L	(A0),D0-D7			; PAL
		MOVE.L	UPALADDR(PC),A6
		MOVEM.L	D0-D7,(A6)
		ADD.L	#32,A0
		MOVE.B	(A0)+,D7			; CONTAIN MID BYTE
		MOVE.B	(A0)+,D7			; CONTAIN HIGH BYTE
		MOVE.W	(A0)+,D0			; END MARK WORD
		MOVE.W	(A0)+,D1			; REPEAT WORD
		MOVE.W	(A0)+,D2			; FF REPEAT WORD
		MOVE.W	(A0)+,D3			; NULL REPEAT WORD

UNCRUNCH_MORE:
		MOVE.B	(A0)+,D6
		MOVE.B	D6,D7
		LSL.W	#8,D7
		MOVE.B	(A0)+,D7
		CMP.W	D7,D1
		BEQ.S	REPEATWORDS
		CMP.W	D7,D3
		BEQ.S	NULLWORDS
		CMP.W	D7,D2
		BEQ.S	FFWORDS
		CMP.W	D7,D0
		BEQ.S	ENDCRUNCH
		SUBQ.L	#1,A0
		MOVE.B	D6,(A1)+
		BRA.S	UNCRUNCH_MORE


REPEATWORDS:	MOVE.B	(A0)+,D7
		BRA.S	MANY
NULLWORDS:	MOVEQ	#0,D7
		BRA.S	MANY
FFWORDS:	MOVE.B	#$FF,D7
MANY:		MOVE.B	(A0)+,D6
		LSL.W	#8,D6
		MOVE.B	(A0)+,D6

DO_MANY:	MOVE.B	D7,(A1)+
		DBF	D6,DO_MANY
		BRA.S	UNCRUNCH_MORE
ENDCRUNCH:	RTS

****************************************************
**		DATA
****************************************************
UDEST:		DC.L	0
USORCE:		DC.L 	0
USCREEN:	DC.L 	0
UPALADDR:	DC.L	0
LOWCONTAIN:	DC.B	0
		EVEN
B:

