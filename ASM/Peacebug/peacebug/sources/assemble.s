*-------------------------------------------------------------------------------
* Assembler:
* ---> A1.l = Adresse, an die assembliert wird
* ---> A2.l = Stringadresse
* ---> D0.w = StringlÑnge
* flag.mi = io., flag.eq = Syntaxfehler, flag.gt = Bus-/Addresserror
*-------------------------------------------------------------------------------
* AssemblyFlag wird dem Resultat entsprechend gesetzt
* RelozierFlag:	-1 fÅr Wordoffset
*				 1 fÅr Byteoffset
*				 2 fÅr Longoffset (68020/30/40)
* Die Adresse wird in RelozierAdresse zwischengespeichert und ist immer long
* Der Offset berechnet sich wie folgt: Adresse-Befehlsadresse-2
* Der Offset muss also noch getestet und der Befehl auscodiert werden

* Interne Register:
* D0 = StringlÑnge
* A0 = Zeiger auf AssemblyCode+2 (Erweiterungsworte etc.)
* A1 = aktueller Befehlsrecord (darf nicht verÑndert werden)
* A2 = Zeiger auf String
* A5 = Converttabelle (darf nicht verÑndert werden)
*-------------------------------------------------------------------------------

		.EXPORT		Assembler

		.INCLUDE	'EQU.S'

*-------------------------------------------------------------------------------

		.BSS
VB:
AssemblyLength:		ds.w	1			; LÑnge des Befehls
AssemblyCode:		ds.b	22			; Opcode des Befehls
AssemblyFlag:		ds.b	1			; Assembly gÅltig?
		.EVEN

RelozierAdresse:	ds.l	1			; Adresse des Opcodes
RelozierFlag:		ds.b	1			; muss noch reloziert werden?
		.EVEN

GeteaRecord:
GeteaLength:		ds.w	1
GeteaCode:			ds.b	12
SaveEA:				ds.l	2

BaseDis:			ds.l	1			; Base Displacment
OuterDis:			ds.l	1			; Outer Displacement
BaseRegister:		ds.w	1			; -1 = PC, 8-15 = A0-A7
IndexRegister:		ds.w	1			; 0-15 = D0-A7
BaseLength:			ds.w	1			; 0, 1, 2 oder 4
IndexLength:		ds.w	1			; 0, 2 oder 4
OuterLength:		ds.w	1			; 0, 2 oder 4
IndexScaling:		ds.w	1			; 0, 2, 4, oder 8
ZapFlag:			ds.b	1			; Base Register gezappt?
PreindexFlag:		ds.b	1			; Preindexed?
MemoryFlag:			ds.b	1			; Memory Indirect?
		.EVEN

*-------------------------------------------------------------------------------

		.TEXT
Assembler:		MOVEM.L		D1-A1/A3-A6,-(SP)
				lea			VB,a4
				move.l		a1,RelozierAdresse-VB(a4)

				JSR			KillSpace				; Spaces entfernen
				BMI			ASSEMBLE_FAIL

				CMPI.B		#'[',(A2)				; Programmname? (z.B. [PEACEBUG])
				BNE.S		NO_PROGRAMM
				MOVE.W		D0,D1					; Programmname entfernen
				LEA			1(A2),A1
SEARCH_PROGRAMM:CMPI.B		#32,(A1)
				BEQ.S		NO_PROGRAMM
				CMPI.B		#']',(A1)+
				DBEQ		D1,SEARCH_PROGRAMM
				BNE.S		NO_PROGRAMM
				MOVE.W		D1,D0
				MOVEA.L		A1,A2
				JSR			KillSpace				; Spaces entfernen
				BMI			ASSEMBLE_FAIL

NO_PROGRAMM:	MOVE.W		D0,D1					; Label entfernen
				MOVEA.L		A2,A1
SEARCH_LABEL:	CMPI.B		#32,(A1)
				BEQ.S		NO_LABEL
				CMPI.B		#':',(A1)+
				DBEQ		D1,SEARCH_LABEL
				BNE.S		NO_LABEL
				MOVE.W		D1,D0
				MOVEA.L		A1,A2
				JSR			KillSpace				; Spaces entfernen
				BMI			ASSEMBLE_FAIL

NO_LABEL:		CMPI.B		#'*',(A2)				; * entfernen
				BNE.S		NO_STERN
				SUBQ.W		#1,D0
				ADDQ.W		#1,A2
				JSR			KillSpace				; Spaces entfernen
				BMI			ASSEMBLE_FAIL

*---------------

NO_STERN:		LEA			Befehlstabelle,A0		; Mainloop
				LEA			Convert,A5
				MOVEQ		#0,D4
				MOVEQ		#15,D1
ASSEMBLE_1:		MOVE.W		D1,D2
				ADD.W		D2,D2
				LEA			10(A0),A1				; Anzahl Befehle(2)+Anfang Record(8)=erster String(10)
				ADDA.W		(A0,D2.w),A1			; A1 = Erster Befehlsrecord
				MOVE.W		-10(A1),D2
ASSEMBLE_2:		MOVEA.L		A2,A3
				MOVEA.L		A1,A6
				MOVEQ		#7,D3
ASSEMBLE_3:		CMPI.B		#32,(A6)
				BEQ.S		BEFEHL_GEFUNDEN

				MOVE.B		(A3)+,D4
				MOVE.B		(A5,D4.w),D4
				CMP.B		(A6)+,D4
				DBNE		D3,ASSEMBLE_3
				BEQ.S		BEFEHL_GEFUNDEN
NEXT_ATTEMPT:	LEA			16(A1),A1
				DBRA		D2,ASSEMBLE_2
				DBRA		D1,ASSEMBLE_1
				BRA			ASSEMBLE_FAIL

*---------------

BEFEHL_GEFUNDEN:MOVE.B		#$F0,D4
				AND.B		-4(A1),D4
				CMP.B		#$F0,D4
				BEQ.S		ITS_THIS_ONE
				TST.B		(A3)
				BEQ.S		ITS_THIS_ONE
				CMPI.B		#32,(A3)
				BNE.S		NEXT_ATTEMPT
ITS_THIS_ONE:	MOVE.B		DisassemCPU,D4
				AND.B		-1(A1),D4
				BEQ.S		NEXT_ATTEMPT

				MOVEM.L		d0-a6,-(SP)
				LEA			AssemblyCode-VB(a4),A0
				ADD.L		A2,D0
				SUB.L		A3,D0
				MOVEA.L		A3,A2
				LEA			-8(A1),A1
				MOVE.W		(A1),(A0)+
				MOVEQ		#0,D1
				MOVE.B		6(A1),D1
				ADD.W		D1,D1
				MOVE.W		ASSEMBLER_TABELLE(PC,D1.w),D1
				ST			AssemblyFlag-VB(a4)
				SF			RelozierFlag-VB(a4)
				JSR			ASSEMBLER_TABELLE(PC,D1.w)
				SUBA.L		#AssemblyCode,A0
				MOVE.W		A0,AssemblyLength-VB(a4)
				MOVEM.L		(SP)+,d0-a6
				TST.B		AssemblyFlag-VB(a4)
				BEQ.S		NEXT_ATTEMPT

				pea			MemoryFail
				jsr			TestBusOn
				lea			AssemblyCode-VB(a4),a0		; Befehl kopieren
				move.l		RelozierAdresse-VB(a4),a1
				move.w		AssemblyLength-VB(a4),d7
				subq.w		#1,d7
.loop:			move.b		(a0)+,(a1)+
				dbra		d7,.loop
				jsr			TestBusOff
				addq.w		#4,sp
				moveq		#-1,d1
				MOVEM.L		(SP)+,D1-A1/A3-A6
				RTS
MemoryFail:		moveq		#1,d1
				MOVEM.L		(SP)+,D1-A1/A3-A6
				rts

*---------------

ASSEMBLE_FAIL:	moveq		#0,d1
				MOVEM.L		(SP)+,D1-A1/A3-A6
				RTS

*-------------------------------------------------------------------------------

ASSEMBLER_TABELLE:
	DC.W ASSEMBLER_0-ASSEMBLER_TABELLE,ASSEMBLER_1-ASSEMBLER_TABELLE,ASSEMBLER_2-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_3-ASSEMBLER_TABELLE,ASSEMBLER_4-ASSEMBLER_TABELLE,ASSEMBLER_5-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_6-ASSEMBLER_TABELLE,ASSEMBLER_7-ASSEMBLER_TABELLE,ASSEMBLER_8-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_9-ASSEMBLER_TABELLE,ASSEMBLER_10-ASSEMBLER_TABELLE,ASSEMBLER_11-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_12-ASSEMBLER_TABELLE,ASSEMBLER_13-ASSEMBLER_TABELLE,ASSEMBLER_14-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_15-ASSEMBLER_TABELLE,ASSEMBLER_16-ASSEMBLER_TABELLE,ASSEMBLER_17-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_18-ASSEMBLER_TABELLE,ASSEMBLER_19-ASSEMBLER_TABELLE,ASSEMBLER_20-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_21-ASSEMBLER_TABELLE,ASSEMBLER_22-ASSEMBLER_TABELLE,ASSEMBLER_23-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_24-ASSEMBLER_TABELLE,ASSEMBLER_25-ASSEMBLER_TABELLE,ASSEMBLER_26-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_27-ASSEMBLER_TABELLE,ASSEMBLER_28-ASSEMBLER_TABELLE,ASSEMBLER_29-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_30-ASSEMBLER_TABELLE,ASSEMBLER_31-ASSEMBLER_TABELLE,ASSEMBLER_32-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_33-ASSEMBLER_TABELLE,ASSEMBLER_34-ASSEMBLER_TABELLE,ASSEMBLER_35-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_36-ASSEMBLER_TABELLE,ASSEMBLER_37-ASSEMBLER_TABELLE,ASSEMBLER_38-ASSEMBLER_TABELLE
	DC.W FAIL_ASS-ASSEMBLER_TABELLE,ASSEMBLER_40-ASSEMBLER_TABELLE,ASSEMBLER_41-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_42-ASSEMBLER_TABELLE,ASSEMBLER_43-ASSEMBLER_TABELLE,ASSEMBLER_44-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_45-ASSEMBLER_TABELLE,ASSEMBLER_46-ASSEMBLER_TABELLE,ASSEMBLER_47-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_48-ASSEMBLER_TABELLE,ASSEMBLER_49-ASSEMBLER_TABELLE,ASSEMBLER_50-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_51-ASSEMBLER_TABELLE,ASSEMBLER_52-ASSEMBLER_TABELLE,ASSEMBLER_53-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_54-ASSEMBLER_TABELLE,ASSEMBLER_55-ASSEMBLER_TABELLE,ASSEMBLER_56-ASSEMBLER_TABELLE
	DC.W ASSEMBLER_57-ASSEMBLER_TABELLE,ASSEMBLER_58-ASSEMBLER_TABELLE,ASSEMBLER_59-ASSEMBLER_TABELLE

*-------------------------------------------------------------------------------

FAIL_ASS:		ADDQ.W		#4,SP
				MOVEM.L		(SP)+,d0-a6
				clr.b		AssemblyFlag-VB(a4)		; AssemblyFlag-VB(a4)=FALSE
				BRA			NEXT_ATTEMPT

*-------------------------------------------------------------------------------

ASSEMBLER_1:	BSR	    GET_IMMEDIATE
		CMP.L	    #$0F,D3
		BHI	    FAIL_ASS
		OR.W	    D3,AssemblyCode-VB(a4)
ASSEMBLER_0:	RTS

*-------------------------------------------------------------------------------

ASSEMBLER_2:	BSR	    GET_EA
		BSR	    CHECK_EA
		BRA	    CODIER_EA

*-------------------------------------------------------------------------------

ASSEMBLER_3:	BSR	    GET_EA
		BSR	    CHECK_EA
		MOVE.W	    GeteaCode-VB(a4),D7
		BSR	    KILL_KOMMA
		BEQ	    FAIL_ASS
		BSR	    GET_EA
		MOVEQ	    #$38,D2
		MOVEQ	    #$38,D3
		AND.W	    D7,D2
		AND.W	    GeteaCode-VB(a4),D3
		CMP.W	    D2,D3
		BNE	    FAIL_ASS
		TST.W	    D2
		BEQ.S	    NICHT_PRE
		BSET	    #3,AssemblyCode-VB+1(a4)
NICHT_PRE:	MOVE.W	    GeteaCode-VB(a4),D3
		BSR	    WRITE_REG_1
		MOVE.W	    D7,D3
		BRA	    WRITE_REG_2

*-------------------------------------------------------------------------------

ASSEMBLER_4:	BSR	    GET_DN
		BEQ.S	    DEST_DN
		MOVE.W	    D3,D2
		BSR	    WRITE_REG_1
		BSR	    KILL_KOMMA
		BTST	    #7,4(A1)
		BNE.S	    NOT_DN_DN
		BSR	    GET_DN
		BEQ.S	    NOT_DN_DN
		ANDI.W	    #$F1FF,AssemblyCode-VB(a4)
		BSR	    WRITE_REG_1
		MOVE.W	    D2,D3
		BRA	    WRITE_REG_2

NOT_DN_DN:	BSET	    #0,AssemblyCode-VB(a4)
		BSR	    GET_EA
		BSR	    CHECK_EA
		BRA	    CODIER_EA

DEST_DN:	BTST	    #7,4(A1)
		BNE	    FAIL_ASS
		BSR	    GET_EA
		BTST	    #6,4(A1)
		BNE.S	    DONT_WORRY
		MOVEQ	    #%111000,D2
		AND.W	    GeteaCode-VB(a4),D2
		SUBQ.W	    #8,D2
		BEQ	    FAIL_ASS
DONT_WORRY:	BSR	    CODIER_EA
		BSR	    KILL_KOMMA
		BSR	    GET_DN
		BEQ	    FAIL_ASS
		BRA	    WRITE_REG_1

*-------------------------------------------------------------------------------

ASSEMBLER_5:	BSR	    GET_EA
		BSR	    CHECK_EA
		BSR	    CODIER_EA
		BSR	    KILL_KOMMA
		BEQ	    FAIL_ASS
		BSR	    GET_EA
		MOVE.W	    GeteaCode-VB(a4),D3
		BSR	    WRITE_REG_1
		AND.W	    #$38,D3
		SUBQ.W	    #8,D3
		BNE	    FAIL_ASS
		RTS


*-------------------------------------------------------------------------------

ASSEMBLER_6:
		BSR	    GET_EA
		MOVE.W	    GeteaCode-VB(a4),D3
		CMP.W	    #$38,D3		  ; Abs.w
		BEQ.S	    ZAHL_IO
		CMP.W	    #$39,D3		  ; Abs.l
		BEQ.S	    ZAHL_IO
		CMPI.W	    #$3C,D3		  ; Immediate
		BNE	    FAIL_ASS
ZAHL_IO:	MOVE.W	    AssemblyCode-VB(a4),D2
		BSR	    CODIER_EA
		MOVE.W	    D2,AssemblyCode-VB(a4)
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		BRA	    CODIER_EA

*-------------------------------------------------------------------------------

ASSEMBLER_7:	BSR	    GET_IMMEDIATE
		TST.L	    D3
		BEQ	    FAIL_ASS
		CMP.L	    #8,D3
		BHI	    FAIL_ASS
		BNE.S	    NOT_AN_EIGHT
		MOVEQ	    #0,D3
NOT_AN_EIGHT:	BSR	    WRITE_REG_1
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		BRA	    CODIER_EA

*-------------------------------------------------------------------------------

ASSEMBLER_8:	LEA	    CC_CODES_1,A6
		BSR.S	    GET_CC
		OR.W	    D3,AssemblyCode-VB(a4)
		BSR	    GET_EA
		MOVE.W	    GeteaCode-VB(a4),D3
		MOVEQ	    #$38,D2
		AND.W	    D3,D2
		BNE	    FAIL_ASS
		BSR	    WRITE_REG_2
		BSR	    KILL_KOMMA
		JSR	    Interpreter
		BNE	    FAIL_ASS
		SUBQ.L	    #2,D3
		SUB.L	    RelozierAdresse-VB(a4),D3
		CMP.L	    #-32768,D3
		BLT	    FAIL_ASS
		CMP.L	    #32767,D3
		BGT	    FAIL_ASS
		MOVE.W	    D3,(A0)+
		RTS

*-------------------------------------------------------------------------------

GET_CC: 	SUBQ.W	    #2,D0
		MOVEQ	    #0,D4
		MOVE.B	    (A2)+,D4
		MOVE.B	    (A5,D4.w),D4
		LSL.W	    #8,D4
		MOVEQ	    #0,D3
		MOVE.B	    (A2)+,D3
		MOVE.B	    (A5,D3.w),D3
		BEQ.S	    SPACEN
		CMP.B	    #'A',D3
		BLO.S	    SPACEN
		CMP.B	    #'Z',D3
		BLS.S	    KEINE_NULL
SPACEN: 	MOVEQ	    #32,D3
		ADDQ.W	    #1,D0
		SUBQ.W	    #1,A2
KEINE_NULL:	OR.W	    D4,D3
*		 CMP.B	     #'O',D3		   ; ???????????????????????????
*		 BEQ.S	     WAR_NIX
		MOVEQ	    #18,D4
SUCH_CC:	CMP.W	    (A6)+,D3
		DBEQ	    D4,SUCH_CC
		BNE.S	    WAR_NIX
		MOVEQ	    #0,D3
		MOVE.W	    36(A6),D3
		LSL.W	    #8,D3
		RTS
WAR_NIX:	ADDQ.W	    #4,SP
		BRA	    FAIL_ASS

*---------------

CC_CODES_1:		DC.W 'T ','F ','HI','LS','CC','CS','NE','EQ','VC','VS'
			DC.W 'PL','MI','GE','LT','GT','LE','HS','LO','RA'
			DC.W 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,4,5,1
CC_CODES_2:		DC.W 'RA','SR','HI','LS','CC','CS','NE','EQ','VC','VS'
			DC.W 'PL','MI','GE','LT','GT','LE','HS','LO','RA'
			DC.W 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,4,5,0
CC_CODES_3:		DC.W 'T ','F ','HI','LS','CC','CS','NE','EQ','VC','VS'
			DC.W 'PL','MI','GE','LT','GT','LE','HS','LO','T '
			DC.W 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,4,5,0
			EVEN

*-------------------------------------------------------------------------------

ASSEMBLER_9:	LEA	    CC_CODES_2,A6
		BSR	    GET_CC
		OR.W	    D3,AssemblyCode-VB(a4)
		MOVEQ	    #1,D2
		SUBQ.W	    #1,D0
		CMPI.B	    #'.',(A2)+
		BNE.S	    NO_BRA_LENGTH
		SUBQ.W	    #1,D0
		MOVE.B	    (A2)+,D4
		MOVE.B	    (A5,D4.w),D4
		CMP.B	    #'B',D4
		BEQ.S	    CONT_BRANCH
		CMP.B	    #'S',D4
		BEQ.S	    CONT_BRANCH
		MOVEQ	    #0,D2
		CMP.B	    #'L',D4
		BEQ.S	    CONT_BRANCH
		MOVEQ	    #-1,D2
		CMP.B	    #'W',D4
		BEQ.S	    CONT_BRANCH
		BRA	    FAIL_ASS
NO_BRA_LENGTH:	SUBQ.W	    #1,A2
		ADDQ.W	    #1,D0
CONT_BRANCH:	JSR	    Interpreter
		BNE	    FAIL_ASS
		SUBQ.L	    #2,D3
		SUB.L	    RelozierAdresse-VB(a4),D3
		TST.L	    D2
		BEQ.S	    BRANCH_L
		BMI.S	    BRANCH_W
BRANCH_B:	CMP.L	    #-128,D3
		BLT.S	    BRANCH_W
		CMP.L	    #127,D3
		BGT.S	    BRANCH_W
		TST.L	    D3
		BEQ.S	    BRANCH_W
		CMP.L	    #-1,D3
		BNE.S	    NOT_LONG
		MOVEQ	    #%11100,D2
		AND.B	    DisassemCPU,D2
		BEQ.S	    NOT_LONG
		BRA.S	    BRANCH_L
NOT_LONG:	MOVE.B	    D3,AssemblyCode-VB+1(a4)
		RTS
BRANCH_W:	CMP.L	    #-32768,D3
		BLT.S	    BRANCH_L
		CMP.L	    #32767,D3
		BGT.S	    BRANCH_L
		CLR.B	    AssemblyCode-VB+1(a4)
		MOVE.W	    D3,(A0)+
		RTS
BRANCH_L:	MOVEQ	    #%11100,D2
		AND.B	    DisassemCPU,D2
		BEQ	    FAIL_ASS
		MOVE.B	    #$FF,AssemblyCode-VB+1(a4)
		MOVE.L	    D3,(A0)+
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_10:	LEA	    CC_CODES_3,A6
		BSR	    GET_CC
		OR.W	    D3,AssemblyCode-VB(a4)
		BSR	    GET_EA
		BSR	    CHECK_EA
		BRA	    CODIER_EA

*-------------------------------------------------------------------------------

ASSEMBLER_11:	BSR	    GET_IMMEDIATE
		MOVE.L	    D3,D2
		CMP.L	    #31,D2
		BHI	    FAIL_ASS
		MOVE.W	    D2,(A0)+
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		MOVEQ	    #%111000,D3
		AND.W	    GeteaCode-VB(a4),D3
		BEQ.S	    ITS_DN
		SUBQ.L	    #7,D2
		BGT	    FAIL_ASS
ITS_DN: 	BSR	    CHECK_EA
		BRA	    CODIER_EA

*-------------------------------------------------------------------------------

ASSEMBLER_12:	BSR	    GET_EA
		BSR	    CHECK_EA
		BSR	    CODIER_EA
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		MOVEQ	    #%111000,D2
		MOVEQ	    #%111111,D3
		AND.W	    GeteaCode-VB(a4),D3
		AND.W	    D3,D2
		BNE	    FAIL_ASS
		BRA	    WRITE_REG_1

*-------------------------------------------------------------------------------

ASSEMBLER_13:	BSR	    GET_DN
		BNE.S	    DATEN_SINDS
		BSR	    GET_IMMEDIATE
		TST.L	    D3
		BEQ	    FAIL_ASS
		CMP.L	    #8,D3
		BHI	    FAIL_ASS
		BNE.S	    NO_DATEN
		MOVEQ	    #0,D3
		BRA.S	    NO_DATEN
DATEN_SINDS:	BSET	    #5,AssemblyCode-VB+1(a4)
NO_DATEN:	BSR	    WRITE_REG_1
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		BRA	    CODIER_EA

*-------------------------------------------------------------------------------

ASSEMBLER_14:	BSR	    GET_EA
		BSR	    CHECK_EA
		BSR	    CODIER_EA
		BSR	    KILL_KOMMA
		MOVE.L	    A0,-(SP)
		JSR	    GetRegister
		MOVEA.L     (SP)+,A0
		TST.L	    D3
		BEQ	    FAIL_ASS
		CMP.W	    #28,D2
		BEQ.S	    ITS_SR
		CMP.W	    #29,D2
		BNE	    FAIL_ASS
		ANDI.W	    #$FF,-2(A0)
		RTS
ITS_SR: 	BSET	    #6,AssemblyCode-VB-1(a4)
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_15:	BSR	    GET_EA
		BSR	    CHECK_EA
		MOVE.W	    GeteaCode-VB(a4),D3
		BSR	    WRITE_REG_2
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		MOVE.W	    GeteaCode-VB(a4),D3
		BRA	    WRITE_REG_1

*-------------------------------------------------------------------------------

ASSEMBLER_16:	bsr			GET_EA
				bsr			CHECK_EA
				bsr			KILL_KOMMA
				move.w		GeteaCode-VB(a4),d2
				bsr			GET_EA
				bsr			CHECK_EA
				move.w		GeteaCode-VB(a4),d3
		
				moveq		#%111000,d4
				and.w		d2,d4
				moveq		#%111000,d5
				and.w		d3,d5
		
				cmp.w		d4,d5
				beq.s		.gleich
				bset		#7,AssemblyCode-VB+1(a4)
				tst.w		d4
				beq.s		.cont
				exg			d2,d3
				bra.s		.cont
.gleich:		bset		#6,AssemblyCode-VB+1(a4)
				tst.w		d4
				beq.s		.source_dn
.cont:			bset		#3,AssemblyCode-VB+1(a4)
.source_dn:		bsr			WRITE_REG_2
				move.w		d2,d3
				bra			WRITE_REG_1

*-------------------------------------------------------------------------------

ASSEMBLER_17:	BSR	    GET_IMMEDIATE
		CMP.L	    #$0F,D3
		BHI	    FAIL_ASS
		OR.W	    D3,AssemblyCode-VB(a4)
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_18:	BSR	    GET_EA
		BSR	    CHECK_EA
		MOVE.W	    GeteaCode-VB(a4),D3
		BRA	    WRITE_REG_2

*-------------------------------------------------------------------------------

ASSEMBLER_19:	BSR		GET_EA
				BSR		CHECK_EA
				MOVEQ	    #%111,D3
				AND.W	    GeteaCode-VB(a4),D3
				BSR	    WRITE_REG_2
				BSR	    KILL_KOMMA
				BSR	    GET_IMMEDIATE
				BTST	    #3,AssemblyCode-VB+1(a4)
				BNE.S	    LONG_LINK
				BSR	    CHECK_LENGTH_EA
				SUBQ.W	    #4,D2
				BEQ	    FAIL_ASS
				MOVE.W	    D3,(A0)+
				RTS
LONG_LINK:		MOVE.L	    D3,(A0)+
				RTS


*-------------------------------------------------------------------------------

ASSEMBLER_20:	BSR	    GET_IMMEDIATE
		BSR	    CHECK_LENGTH_EA
		SUBQ.W	    #4,D2
		BEQ	    FAIL_ASS
		MOVE.W	    D3,(A0)+
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_21:	BSR	    GET_EA
		BSR	    CODIER_EA
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		MOVE.W	    GeteaCode-VB(a4),D3
		BRA	    WRITE_REG_1

*-------------------------------------------------------------------------------

ASSEMBLER_22:	BTST	    #2,AssemblyCode-VB(a4)
		BEQ.S	    ZUERST_REGS
		BSR	    GET_EA
		BSR	    CHECK_EA
		BSR	    KILL_KOMMA
		BSR.S	    GET_REGISTER
		BEQ	    FAIL_ASS
		BRA	    CODIER_EA
ZUERST_REGS:	BSR.S	    GET_REGISTER
		BEQ	    FAIL_ASS
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		BSR	    CODIER_EA
		MOVEQ	    #$38,D3
		AND.W	    GeteaCode-VB(a4),D3
		CMP.W	    #32,D3
		BNE.S	    NICHT_SPIEGELN
		MOVE.W	    AssemblyCode-VB+2(a4),D3
		MOVEQ	    #15,D2
SPIEGLEIN:	ADD.W	    D3,D3
		ROXR.W	    #1,D1
		DBRA	    D2,SPIEGLEIN
		MOVE.W	    D1,AssemblyCode-VB+2(a4)
NICHT_SPIEGELN: RTS

GET_REGISTER:	MOVEQ	    #0,D7
NEUER_ANFANG:	MOVEQ	    #0,D6
		JSR	    KillSpace
		BMI.S	    ENDE_REGISTER
		CMPI.B	    #',',(A2)
		BEQ.S	    ENDE_REGISTER
		BSR	    GET_RN
		BEQ.S	    FAIL_REGISTER
		BSET	    D3,D7
BINDESTRICH:	JSR	    KillSpace
		BMI.S	    ENDE_REGISTER
		CMPI.B	    #'-',(A2)
		BNE.S	    BACK_SLASH
		SUBQ.W	    #1,D0
		ADDQ.W	    #1,A2
		MOVE.W	    D3,D6
		BSR	    GET_RN
		BEQ.S	    FAIL_REGISTER
		CMP.W	    D3,D6
		BLO.S	    SET_SCHLEIFE
		EXG	    D3,D6
SET_SCHLEIFE:	BSET	    D6,D7
		ADDQ.W	    #1,D6
		CMP.W	    D6,D3
		BHS.S	    SET_SCHLEIFE
		BRA.S	    BINDESTRICH
BACK_SLASH:	BSET	    D3,D7
		CMPI.B	    #'/',(A2)
		BNE.S	    ENDE_REGISTER
		SUBQ.W	    #1,D0
		ADDQ.W	    #1,A2
		BSET	    D3,D7
		BRA.S	    NEUER_ANFANG
ENDE_REGISTER:	MOVE.W	    D7,(A0)+
		TST.B	    AssemblyFlag-VB(a4)
		RTS
FAIL_REGISTER:	SF	    AssemblyFlag-VB(a4)
		BRA.S	    ENDE_REGISTER

*-------------------------------------------------------------------------------

ASSEMBLER_23:	BSR	    GET_EA
		BSR	    CHECK_EA
		BSR	    KILL_KOMMA
		MOVEQ	    #$38,D2
		MOVE.W	    GeteaCode-VB(a4),D3
		AND.W	    D3,D2
		BNE.S	    AN_RELATIV
		BSET	    #7,AssemblyCode-VB+1(a4)
		BSR	    WRITE_REG_1
		BRA.S	    NOT_AN_RELATIV
AN_RELATIV:	BSR	    WRITE_REG_2
		MOVE.W	    GeteaCode-VB+2(a4),(A0)+
NOT_AN_RELATIV: BSR	    GET_EA
		BSR	    CHECK_EA
		MOVEQ	    #$38,D2
		MOVE.W	    GeteaCode-VB(a4),D3
		AND.W	    D3,D2
		BNE.S	    AN_RELATIV_2
		BTST	    #7,AssemblyCode-VB+1(a4)
		BNE	    FAIL_ASS
		BRA	    WRITE_REG_1
AN_RELATIV_2:	BTST	    #7,AssemblyCode-VB+1(a4)
		BEQ	    FAIL_ASS
		MOVE.W	    GeteaCode-VB+2(a4),(A0)+
		BRA	    WRITE_REG_2

*-------------------------------------------------------------------------------

ASSEMBLER_24:	BSR	    GET_IMMEDIATE
		BSR	    CHECK_LENGTH_EA
		SUBQ.W	    #1,D2
		BNE	    FAIL_ASS
		MOVE.B	    D3,AssemblyCode-VB+1(a4)
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		MOVE.W	    GeteaCode-VB(a4),D3
		BRA	    WRITE_REG_1

*-------------------------------------------------------------------------------

ASSEMBLER_25:	BSR.S	    TEST_USP
		BNE.S	    SOURCE_USP
		BSR	    GET_EA
		BSR	    CHECK_EA
		MOVEQ	    #%111,D3
		AND.W	    GeteaCode-VB(a4),D3
		BSR	    WRITE_REG_2
		BSR	    KILL_KOMMA
		BSR.S	    TEST_USP
		BEQ	    FAIL_ASS
		RTS
SOURCE_USP:	BSET	    #3,AssemblyCode-VB+1(a4)
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		MOVEQ	    #%111,D3
		AND.W	    GeteaCode-VB(a4),D3
		BRA	    WRITE_REG_2

TEST_USP:	MOVEM.L     D0/A2,-(SP)
		MOVE.L	    A0,-(SP)
		JSR	    GetRegister
		MOVEA.L     (SP)+,A0
		TST.L	    D3
		BEQ.S	    NO_USP
		CMP.W	    #20,D2
		BNE.S	    NO_USP
		ADDQ.W	    #8,SP
		MOVEQ	    #-1,D3
		RTS
NO_USP: 	MOVEM.L     (SP)+,D0/A2
		MOVEQ	    #0,D3
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_26:	BTST	    #2,AssemblyCode-VB(a4)
		BEQ.S	    ITS_FROM
		BSR	    GET_EA
		BSR	    CHECK_EA
		BSR	    CODIER_EA
		BSR	    KILL_KOMMA
		BTST	    #1,AssemblyCode-VB(a4)
		SEQ	    D7
		BSR.S	    CHECK_SR_CCR
		BEQ	    FAIL_ASS
		RTS
ITS_FROM:	BTST	    #1,AssemblyCode-VB(a4)
		SNE	    D7
		BSR.S	    CHECK_SR_CCR
		BEQ	    FAIL_ASS
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		BRA	    CODIER_EA

CHECK_SR_CCR:	MOVE.L	    A0,-(SP)
		JSR	    GetRegister
		MOVEA.L     (SP)+,A0
		TST.L	    D3
		BEQ.S	    CCR_SR_FAIL
		ADD.B	    D7,D2
		CMP.B	    #28,D2
		BNE.S	    CCR_SR_FAIL
		MOVEQ	    #-1,D3
		RTS
CCR_SR_FAIL:	MOVEQ	    #0,D3
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_27:	BSR	    GET_EA
		MOVEQ	    #$38,D3
		AND.W	    GeteaCode-VB(a4),D3
		SUBQ.W	    #8,D3
		BNE.S	    KEINE_ANS
		MOVEQ	    #$30,D3
		AND.B	    4(A1),D3
		BEQ	    FAIL_ASS
KEINE_ANS:	BSR	    CODIER_EA
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		LEA	    AssemblyCode-VB(a4),A3
		MOVE.W	    (A3),-(SP)
		ANDI.W	    #$F000,(A3)
		BSR	    CODIER_EA
		MOVEQ	    #%111111,D3
		AND.W	    GeteaCode-VB(a4),D3
		LSL.W	    #3,D3
		MOVEQ	    #$38,D2
		AND.W	    D3,D2
		LSL.W	    #6,D2
		AND.W	    #$01C0,D3
		ANDI.W	    #$F000,(A3)
		OR.W	    D2,(A3)
		OR.W	    D3,(A3)
		MOVEQ	    #$3F,D3
		AND.W	    (SP)+,D3
		OR.W	    D3,(A3)
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_28:	BSR	    GET_IMMEDIATE
		CMP.L	    #7,D3
		BHI	    FAIL_ASS
		OR.W	    D3,AssemblyCode-VB(a4)
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_29:	ADDQ.W	    #2,A0
		MOVEQ	    #0,D2
		MOVE.W	    #%111100000000,D3
		AND.W	    AssemblyCode-VB(a4),D3
		CMP.W	    #$0F00,D3
		BNE.S	    NO_BFINS_2
		BSR	    GET_DN
		BEQ	    FAIL_ASS
		MOVEQ	    #12,D4
		LSL.W	    D4,D3
		OR.W	    D3,D2
		BSR	    KILL_KOMMA
NO_BFINS_2:	BSR	    GET_EA
		BSR	    CHECK_EA
		BSR	    CODIER_EA
		JSR	    KillSpace
		BMI	    FAIL_ASS
		SUBQ.W	    #1,D0
		CMPI.B	    #'{',(A2)+
		BNE	    FAIL_ASS
		BSR	    GET_EA
		MOVEQ	    #0,D3
		MOVE.W	    GeteaCode-VB+2(a4),D3
		CMPI.W	    #$38,GeteaCode-VB(a4)
		BEQ.S	    ABS_OFFSET
		MOVE.L	    GeteaCode-VB+2(a4),D3
		CMPI.W	    #$39,GeteaCode-VB(a4)
		BEQ.S	    ABS_OFFSET
		MOVEQ	    #%111000,D3
		AND.W	    GeteaCode-VB(a4),D3
		BNE	    FAIL_ASS
		MOVEQ	    #%111,D3
		AND.W	    GeteaCode-VB(a4),D3
		BSET	    #11,D2
		BRA.S	    PUT_OFFSET

ABS_OFFSET:	CMP.L	    #31,D3
		BHI	    FAIL_ASS
PUT_OFFSET:	LSL.W	    #6,D3
		OR.W	    D3,D2
		BSR	    KILL_DOPPELPT
		BSR	    GET_EA
		MOVEQ	    #0,D3
		MOVE.W	    GeteaCode-VB+2(a4),D3
		CMPI.W	    #$38,GeteaCode-VB(a4)
		BEQ.S	    ABS_WIDTH
		MOVE.L	    GeteaCode-VB+2(a4),D3
		CMPI.W	    #$39,GeteaCode-VB(a4)
		BEQ.S	    ABS_WIDTH
		MOVEQ	    #%111000,D3
		AND.W	    GeteaCode-VB(a4),D3
		BNE	    FAIL_ASS
		MOVEQ	    #%111,D3
		AND.W	    GeteaCode-VB(a4),D3
		BSET	    #5,D2
		BRA.S	    PUT_WIDTH
ABS_WIDTH:	TST.L	    D3
		BEQ	    FAIL_ASS
		CMP.L	    #32,D3
		BHI	    FAIL_ASS
		BNE.S	    PUT_WIDTH
		MOVEQ	    #0,D3
PUT_WIDTH:	OR.W	    D3,D2
		BSR	    KILL_KLAMMER_3
		BTST	    #0,AssemblyCode-VB(a4)
		BEQ.S	    NO_SECOND_2
		MOVEQ	    #%110,D3
		AND.B	    AssemblyCode-VB(a4),D3
		SUBQ.W	    #%110,D3
		BEQ.S	    NO_SECOND_2
		BSR	    KILL_KOMMA
		BSR	    GET_DN
		BEQ	    FAIL_ASS
		MOVEQ	    #12,D4
		LSL.W	    D4,D3
		OR.W	    D3,D2
NO_SECOND_2:	MOVE.W	    D2,AssemblyCode-VB+2(a4)
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_30:	BSR	    GET_IMMEDIATE
		CMP.L	    #$FF,D3
		BHI	    FAIL_ASS
		MOVE.W	    D3,(A0)+
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA

		BRA	    CODIER_EA

*-------------------------------------------------------------------------------

ASSEMBLER_31:	BSR	    GET_DN
		BEQ	    FAIL_ASS
		MOVE.W	    D3,D2
		BSR	    KILL_KOMMA
		BSR	    GET_DN
		BEQ	    FAIL_ASS
		LSL.W	    #6,D3
		OR.W	    D3,D2
		MOVE.W	    D2,(A0)+
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		BRA	    CODIER_EA

*-------------------------------------------------------------------------------

ASSEMBLER_32:	BSR	    GET_DN		  ; Dc1:Dc2
		BEQ	    FAIL_ASS
		MOVE.W	    D3,D1
		BSR	    KILL_DOPPELPT
		BSR	    GET_DN
		BEQ	    FAIL_ASS
		MOVE.W	    D3,D2
		BSR	    KILL_KOMMA

		MOVEQ	    #6,D4		  ; Du1:Du2
		BSR	    GET_DN
		BEQ	    FAIL_ASS
		LSL.W	    D4,D3
		OR.W	    D3,D1
		BSR	    KILL_DOPPELPT
		BSR	    GET_DN
		BEQ	    FAIL_ASS
		LSL.W	    D4,D3
		OR.W	    D3,D2
		BSR	    KILL_KOMMA

		MOVEQ	    #12,D4		  ; (Rn1):(Rn2)
		BSR	    KILL_KLAMMER_0
		BSR	    GET_RN
		BEQ	    FAIL_ASS
		LSL.W	    D4,D3
		OR.W	    D3,D1
		BSR	    KILL_KLAMMER_1
		BSR	    KILL_DOPPELPT
		BSR	    KILL_KLAMMER_0
		BSR	    GET_RN
		BEQ	    FAIL_ASS
		LSL.W	    D4,D3
		OR.W	    D3,D2
		BSR	    KILL_KLAMMER_1

		MOVE.W	    D1,(A0)+
		MOVE.W	    D2,(A0)+
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_33:	BSR	    GET_EA
		BSR	    CHECK_EA
		BSR	    KILL_KOMMA
		BSR	    GET_RN
		BEQ	    FAIL_ASS
		MOVEQ	    #12,D4
		LSL.W	    D4,D3
		BTST	    #7,4(A1)
		BEQ.S	    NO_CHK2
		BSET	    #11,D3
NO_CHK2:	MOVE.W	    D3,(A0)+
		BRA	    CODIER_EA

*-------------------------------------------------------------------------------

ASSEMBLER_34:	BSR	    GET_EA
		BSR	    CHECK_EA
		BSR	    KILL_KOMMA
		BSR	    GET_DN
		BEQ	    FAIL_ASS
		MOVE.W	    D3,D2
		MOVEQ	    #12,D4
		LSL.W	    D4,D2
		OR.W	    D3,D2
		JSR	    KillSpace
		BMI.S	    END_MULDIV
		SUBQ.W	    #1,D0
		CMPI.B	    #':',(A2)+
		BNE.S	    END_MULDIV
		BSR	    GET_DN
		BEQ.S	    END_MULDIV
		MOVEQ	    #12,D4
		LSL.W	    D4,D3
		OR.B	    D2,D3
		MOVE.W	    D3,D2
		BTST	    #7,4(A1)
		BNE.S	    END_MULDIV
		BSET	    #10,D2
END_MULDIV:	MOVE.W	    D2,(A0)+
		CMPI.B	    #'S',11(A1)
		BNE	    CODIER_EA
		BSET	    #3,-2(A0)
		BRA	    CODIER_EA

*-------------------------------------------------------------------------------

ASSEMBLER_35:	BSR	    GET_RN
		BEQ.S	    RC_FIRST
		BSET	    #0,AssemblyCode-VB+1(a4)
		MOVEQ	    #12,D4
		LSL.W	    D4,D3
		MOVE.W	    D3,D2
		BSR	    KILL_KOMMA
		BSR.S	    GET_RC
		BRA.S	    END_MOVEC
RC_FIRST:	BSR.S	    GET_RC
		MOVE.W	    D3,D2
		BSR	    KILL_KOMMA
		BSR	    GET_RN
		BEQ	    FAIL_ASS
		MOVEQ	    #12,D4
		LSL.W	    D4,D3
END_MOVEC:	OR.W	    D3,D2
		MOVE.W	    D2,(A0)+
		RTS


GET_RC: 	MOVEM.L     D1-D2/D4-A1/A3/A5-A6,-(SP)
		JSR	    GetRegister
		TST.L	    D3
		BEQ.S	    FAIL_RC
		SUB.W	    #16,D2
		BMI.S	    FAIL_RC
		ADD.W	    D2,D2
		ADD.W	    D2,D2
		MOVE.W	    MOVEC_TABLE(PC,D2.w),D3
		BMI.S	    FAIL_RC
		MOVE.W	    MOVEC_TABLE+2(PC,D2.w),D2
		AND.B	    DisassemCPU,D2
		BEQ.S	    FAIL_RC
		MOVEM.L     (SP)+,D1-D2/D4-A1/A3/A5-A6
		RTS
FAIL_RC:	MOVEM.L     (SP)+,D1-D2/D4-A1/A3/A5-A6
		ADDQ.W	    #4,SP
		BRA	    FAIL_ASS

*---------------

MOVEC_TABLE:		DC.W $0807,%10000	  ; 16 SRP
			DC.W -1,0		  ; 17
			DC.W $0804,%11100	  ; 18 ISP
			DC.W $0803,%11100	  ; 19 MSP
			DC.W $0800,%11110	  ; 20 USP
			DC.W -1,0		  ; 21
			DC.W -1,0		  ; 22
			DC.W $00,%11110 	  ; 23 SFC
			DC.W $01,%11110 	  ; 24 DFC
			DC.W $0801,%11110	  ; 25 VBR
			DC.W $0802,%1100	  ; 26 CAAR
			DC.W $02,%11100 	  ; 27 CACR
			DC.W -1,0		  ; 28
			DC.W -1,0		  ; 29
			DC.W $0805,%10000	  ; 30 MMUSR
			DC.W -1,0		  ; 31
			DC.W -1,0		  ; 32
			DC.W -1,0		  ; 33
			DC.W $04,%10000 	  ; 34 ITT0
			DC.W $05,%10000 	  ; 35 ITT1
			DC.W $06,%10000 	  ; 36 DTT0
			DC.W $07,%10000 	  ; 37 DTT1
			DC.W $0806,%10000	  ; 38 URP
			DC.W $0805,%10000	  ; 39 PSR
			DC.W $03,%10000 	  ; 40 TC

*-------------------------------------------------------------------------------

ASSEMBLER_36:	BSR	    GET_RN
		BEQ.S	    MOVES_EA
		MOVEQ	    #12,D4
		LSL.W	    D4,D3
		BSET	    #11,D3
		MOVE.W	    D3,(A0)+
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		BRA	    CODIER_EA
MOVES_EA:	BSR	    GET_EA
		BSR	    CHECK_EA
		BSR	    KILL_KOMMA
		BSR	    GET_RN
		BEQ	    FAIL_ASS
		MOVEQ	    #12,D4
		LSL.W	    D4,D3
		MOVE.W	    D3,(A0)+
		BRA	    CODIER_EA

*-------------------------------------------------------------------------------

ASSEMBLER_37:	BSR	    GET_EA
		BSR	    CHECK_EA
		MOVEQ	    #%111,D3
		AND.W	    GeteaCode-VB(a4),D3
		MOVEQ	    #%111000,D2
		AND.W	    GeteaCode-VB(a4),D2
		BEQ.S	    PACK_DN
		BSET	    #3,D3
PACK_DN:	OR.W	    D3,AssemblyCode-VB(a4)
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		MOVEQ	    #%111000,D3
		AND.W	    GeteaCode-VB(a4),D3
		CMP.W	    D2,D3
		BNE	    FAIL_ASS
		MOVEQ	    #%111,D3
		AND.W	    GeteaCode-VB(a4),D3
		MOVEQ	    #9,D4
		LSL.W	    D4,D3
		OR.W	    D3,AssemblyCode-VB(a4)
		BSR	    KILL_KOMMA
		BSR	    GET_IMMEDIATE
		BSR	    CHECK_LENGTH_EA
		CMP.W	    #4,D2
		BEQ	    FAIL_ASS
		MOVE.W	    D3,(A0)+
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_38:	LEA	    CC_CODES_3,A6
		BSR	    GET_CC
		ANDI.W	    #$FFF8,AssemblyCode-VB(a4)
		MOVEQ	    #%100,D4
		MOVE.W	    D3,D5
		BSR	    GET_LENGTH_EA
		BEQ.S	    ENDE_TRAPCC
		CMP.W	    #1,D2
		BEQ	    FAIL_ASS
		CMP.W	    #2,D2
		BEQ.S	    TRAPCC_W
		BSR	    GET_IMMEDIATE
		MOVE.L	    D3,(A0)+
		MOVEQ	    #%11,D4
		BRA.S	    ENDE_TRAPCC
TRAPCC_W:	BSR	    GET_IMMEDIATE
		BSR	    CHECK_LENGTH_EA
		CMP.W	    #4,D2
		BEQ	    FAIL_ASS
		MOVE.W	    D3,(A0)+
		MOVEQ	    #%10,D4
ENDE_TRAPCC:	OR.W	    D4,D5
		OR.W	    D5,AssemblyCode-VB(a4)
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_40:	BTST	    #5,AssemblyCode-VB+1(a4)
		BNE	    MOVE16_POST
		JSR	    KillSpace
		BMI	    FAIL_ASS
		CMPI.B	    #'(',(A2)
		BNE.S	    MOVE16_ABS
		BSR	    GET_EA
		BSR	    CHECK_EA
		MOVEQ	    #%111,D3
		AND.W	    GeteaCode-VB(a4),D3
		OR.W	    D3,AssemblyCode-VB(a4)
		BSR	    CHECK_MOVE16
		BEQ.S	    DONT_SET
		BSET	    #4,AssemblyCode-VB+1(a4)
DONT_SET:	BSR	    KILL_KOMMA
		JSR	    Interpreter
		BNE	    FAIL_ASS
		MOVE.L	    D3,(A0)+
		RTS
MOVE16_ABS:	BSET	    #3,AssemblyCode-VB+1(a4)
		JSR	    Interpreter
		BNE	    FAIL_ASS
		MOVE.L	    D3,(A0)+
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		MOVEQ	    #%111,D3
		AND.W	    GeteaCode-VB(a4),D3
		OR.W	    D3,AssemblyCode-VB(a4)
		BSR.S	    CHECK_MOVE16
		BEQ		RTS
		BSET	    #4,AssemblyCode-VB+1(a4)
RTS:	RTS
MOVE16_POST:	BSR	    GET_EA
		BSR.S	    CHECK_MOVE16
		BNE	    FAIL_ASS
		MOVEQ	    #%111,D3
		AND.W	    GeteaCode-VB(a4),D3
		OR.W	    D3,AssemblyCode-VB(a4)
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR.S	    CHECK_MOVE16
		BNE	    FAIL_ASS
		MOVEQ	    #%111,D3
		AND.W	    GeteaCode-VB(a4),D3
		BSET	    #3,D3
		MOVEQ	    #12,D4
		LSL.W	    D4,D3
		MOVE.W	    D3,(A0)+
		RTS

CHECK_MOVE16:	MOVEQ	    #%111000,D3
		AND.W	    GeteaCode-VB(a4),D3
		CMP.W	    #%11000,D3
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_41:	JSR	    KillSpace
		BMI	    FAIL_ASS
		MOVEQ	    #0,D3
		SUBQ.W	    #1,D0
		MOVE.B	    (A2)+,D2
		MOVE.B	    (A5,D2.w),D2
		SUBQ.W	    #1,D0
		MOVE.B	    (A2)+,D3
		MOVE.B	    (A5,D3.w),D3
		CMP.B	    #'C',D3
		BNE	    FAIL_ASS
		MOVEQ	    #%0,D3
		CMP.B	    #'N',D2
		BEQ.S	    CACHE_FERTIG
		MOVEQ	    #%1,D3
		CMP.B	    #'D',D2
		BEQ.S	    CACHE_FERTIG
		MOVEQ	    #%10,D3
		CMP.B	    #'I',D2
		BEQ.S	    CACHE_FERTIG
		MOVEQ	    #%11,D3
		CMP.B	    #'B',D2
		BNE	    FAIL_ASS
CACHE_FERTIG:	LSL.W	    #6,D3
		OR.W	    D3,AssemblyCode-VB(a4)
		MOVEQ	    #%11000,D3
		AND.W	    AssemblyCode-VB(a4),D3
		CMP.W	    #%11000,D3
		BEQ	    RTS
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		MOVEQ	    #%111,D3
		AND.W	    GeteaCode-VB(a4),D3
		OR.W	    D3,AssemblyCode-VB(a4)
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_42:	CMPI.B	    #'F',13(A1)
		BEQ.S	    FLUSHD
		BSR.S	    GET_MRN
		BMI.S	    PMOVE_READ
		BSET	    #9,D3
		MOVE.W	    D3,(A0)+
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		BRA	    CODIER_EA

PMOVE_READ:	BSR	    GET_EA
		BSR	    CHECK_EA
		BSR	    KILL_KOMMA
		BSR.S	    GET_MRN
		BMI	    FAIL_ASS
		MOVE.W	    D3,(A0)+
		BRA	    CODIER_EA

FLUSHD: 	BSR	    GET_EA
		BSR	    CHECK_EA
		BSR	    KILL_KOMMA
		BSR.S	    GET_MRN
		BMI	    FAIL_ASS
		CMP.W	    #30,D2
		BEQ	    FAIL_ASS
		BSET	    #8,D3
		MOVE.W	    D3,(A0)+
		BRA	    CODIER_EA

GET_MRN:	MOVE.L	    A0,-(SP)
		JSR	    GetRegister
		MOVEA.L     (SP)+,A0
		TST.L	    D3
		BEQ.S	    MRN_FAIL
		MOVE.W	    #%100100000000000,D3  ; SRP
		CMP.W	    #16,D2
		BEQ.S	    MRN_IO
		MOVE.W	    #%110000000000000,D3  ; MMUSR/PSR
		CMP.W	    #30,D2
		BEQ.S	    MRN_IO
		CMP.W	    #39,D2
		BEQ.S	    MRN_IO
		MOVE.W	    #%100110000000000,D3  ; CRP
		CMP.W	    #31,D2
		BEQ.S	    MRN_IO
		MOVE.W	    #%100000000000,D3	  ; TT0
		CMP.W	    #32,D2
		BEQ.S	    MRN_IO
		MOVE.W	    #%110000000000,D3	  ; TT1
		CMP.W	    #33,D2
		BEQ.S	    MRN_IO
		MOVE.W	    #%100000000000000,D3  ; TC
		CMP.W	    #40,D2
		BEQ.S	    MRN_IO
MRN_FAIL:	MOVEQ	    #-1,D3
MRN_IO: 	TST.W	    D3
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_43:
		CMPI.B	    #'A',14(A1)
		BEQ.S	    FLUSH_ALL
		BSR.S	    GET_FC
		OR.W	    #%11000000000000,D3
		BSR	    KILL_KOMMA
		MOVE.W	    D3,D2
		BSR	    GET_IMMEDIATE
		CMP.L	    #7,D3
		BHI	    FAIL_ASS
		LSL.W	    #5,D3
		OR.W	    D3,D2
		MOVE.W	    D2,(A0)+
		JSR			KillSpace
		BMI.S	    END_PFLUSH
		CMPI.B	    #',',(A2)
		BNE.S	    END_PFLUSH
		SUBQ.W	    #1,D0
		ADDQ.W	    #1,A2
		BSR	    GET_EA
		BSR	    CHECK_EA
		BSET	    #3,-2(A0)
		BRA	    CODIER_EA
END_PFLUSH:	RTS
FLUSH_ALL:	MOVE.W	    #%10010000000000,(A0)+
		RTS

GET_FC: MOVEM.L     D0/A2,-(SP)
		MOVE.L	    A0,-(SP)
		JSR	    	GetRegister
		MOVEA.L     (SP)+,A0
		TST.L	    D3
		BEQ.S	    BITS_XXX
		MOVEQ	    #%1000,D3
		OR.W	    D2,D3
		SUBQ.W	    #7,D2		  ; D0-D7
		BLE.S	    FC_PFLUSH
		MOVEQ	    #0,D3
		SUB.W	    #16,D2		  ; SFC,23
		BEQ.S	    FC_PFLUSH
		MOVEQ	    #1,D3
		SUBQ.W	    #1,D2		  ; DFC,24
		BEQ.S	    FC_PFLUSH
BITS_XXX:	MOVEM.L     (SP)+,D0/A2

				jsr			KillSpace
				bmi.s		FAIL_FC
				cmpi.b		#'#',(a2)
				bne.s		.kein_immediate
				addq.w		#1,a2
				subq.w		#1,d0
.kein_immediate:jsr			Interpreter
				bne.s		FAIL_FC

.cont:			cmpi.l		#7,d3
				bhi.s		FAIL_FC
				ori.w		#%10000,d3
				rts
FC_PFLUSH:		addq.w		#8,sp
				rts
FAIL_FC:		addq.w		#4,sp
				bra			FAIL_ASS

*-------------------------------------------------------------------------------

ASSEMBLER_44:	BSR	    GET_EA
		BSR	    CHECK_EA
		MOVEQ	    #%111,D3
		AND.W	    GeteaCode-VB(a4),D3
		OR.W	    D3,AssemblyCode-VB(a4)
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_45:	BSR.S	    GET_FC
		BSET	    #13,D3
		BSR.S	    GET_RW
		MOVE.W	    D3,(A0)+
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		BRA	    CODIER_EA

GET_RW: 	CMPI.B	    #'W',13(A1)
		BEQ.S	    ONLY_WRITE
		BSET	    #9,D3
ONLY_WRITE:	RTS

*-------------------------------------------------------------------------------

ASSEMBLER_46:	BSR	    GET_FC
		BSET	    #15,D3
		BSR.S	    GET_RW
		MOVE.W	    D3,D2
		BSR	    KILL_KOMMA
		BSR	    GET_EA
		BSR	    CHECK_EA
		BSR	    KILL_KOMMA
		BSR	    GET_IMMEDIATE
		CMP.L	    #7,D3
		BHI	    FAIL_ASS
		MOVEQ	    #10,D4
		LSL.W	    D4,D3
		OR.W	    D3,D2
		TST.L	    D3
		BEQ.S	    NO_AN
		BSR	    KILL_KOMMA
		BSR	    GET_AN
		BEQ.S	    NO_AN
		LSL.W	    #5,D3
		OR.W	    D3,D2
NO_AN:		MOVE.W	    D2,(A0)+
		BRA	    CODIER_EA

*-------------------------------------------------------------------------------

ASSEMBLER_47:	MOVEQ	    #0,D3
		BSR.S	    GET_RW
		LSR.W	    #4,D3
		BSR	    GET_EA
		BSR.S	    CHECK_EA
		MOVEQ	    #%111,D2
		AND.W	    GeteaCode-VB(a4),D2
		OR.W	    D2,D3
		OR.W	    D3,AssemblyCode-VB(a4)
		RTS

*-------------------------------------------------------------------------------

WRITE_REG_2:	MOVE.L	    D3,-(SP)
		AND.W	    #7,D3
		OR.W	    D3,AssemblyCode-VB(a4)
		MOVE.L	    (SP)+,D3
		RTS

*-------------------------------------------------------------------------------

WRITE_REG_1:	MOVEM.L     D2-D3,-(SP)
		AND.W	    #7,D3
		MOVEQ	    #9,D2
		LSL.W	    D2,D3
		OR.W	    D3,AssemblyCode-VB(a4)
		MOVEM.L     (SP)+,D2-D3
		RTS


ASSEMBLER_48:

*-------------------------------------------------------------------------------

ASSEMBLER_49:

*-------------------------------------------------------------------------------

ASSEMBLER_50:

*-------------------------------------------------------------------------------

ASSEMBLER_51:

*-------------------------------------------------------------------------------

ASSEMBLER_52:	BRA	    FAIL_ASS

*-------------------------------------------------------------------------------

ASSEMBLER_53:	CLR.W	    (A0)+
		RTS

*-------------------------------------------------------------------------------

ASSEMBLER_54:

*-------------------------------------------------------------------------------

ASSEMBLER_55:

*-------------------------------------------------------------------------------

ASSEMBLER_56:

*-------------------------------------------------------------------------------

ASSEMBLER_57:

*-------------------------------------------------------------------------------

ASSEMBLER_58:

*-------------------------------------------------------------------------------

ASSEMBLER_59:	BRA	    FAIL_ASS

CHECK_EA:	MOVEM.L     d0-a6,-(SP)
		MOVE.W	    4(A1),D2
		MOVEQ	    #$38,D3
		AND.W	    GeteaCode-VB(a4),D3
		LSR.W	    #3,D3
		CMP.W	    #7,D3
		BEQ.S	    OHNE_REG
		MOVE.B	    CHECK_3(PC,D3.w),D3
		BTST	    D3,D2
		BEQ.S	    FALSCH_ASS
		BRA.S	    OK_ASS
OHNE_REG:	MOVEQ	    #7,D3
		AND.W	    GeteaCode-VB(a4),D3
		MOVE.B	    CHECK_4(PC,D3.w),D3
		BTST	    D3,D2
		BEQ.S	    FALSCH_ASS
OK_ASS: 	MOVEM.L     (SP)+,d0-a6
		RTS
FALSCH_ASS:	CLR.B	    AssemblyFlag-VB(a4)
		MOVEM.L     (SP)+,d0-a6
		ADDQ.W	    #4,SP
		RTS

*---------------

CHECK_3:		DC.B 11,10,9,8,7,6,5
CHECK_4:		DC.B 4,3,2,1,0,15,15,15
			EVEN

*-------------------------------------------------------------------------------

CODIER_EA:	MOVEM.L     D0-D7/A1-A3/A5-A6,-(SP)
		LEA	    GeteaCode-VB(a4),A6
		MOVE.W	    GeteaLength-VB(a4),D3
		MOVE.W	    AssemblyCode-VB(a4),D2
		OR.W	    (A6)+,D2
		MOVE.W	    D2,AssemblyCode-VB(a4)
		SUBQ.W	    #3,D3
		BMI.S	    DAS_REICHT
COPY_EA:	MOVE.B	    (A6)+,(A0)+
		DBRA	    D3,COPY_EA
DAS_REICHT:	MOVEM.L     (SP)+,D0-D7/A1-A3/A5-A6
		RTS

*-------------------------------------------------------------------------------

* <--- GeteaRecord
GET_EA: 		movem.l		d1-a1/a3/a5-a6,-(sp)
				sf			RelozierFlag-VB(a4)
				lea			GeteaCode-VB(a4),a6

				jsr			KillSpace
				bmi.s		EA_FAIL
				movem.l		d0/a2,SaveEA-VB(a4)
				bsr			CLEAR_ASS

				moveq		#0,d4
				move.b		(a2)+,d4
				move.b		(a5,d4.w),d4
				cmpi.b		#'(',d4
				beq			INDIRECT
				cmpi.b		#'-',d4
				beq.s		ADRESSEN_PREDEKREMENT
				cmpi.b		#'#',d4
				beq			IMMEDIATE
				movem.l		SaveEA-VB(a4),d0/a2			; D0-D7/A0-A7
				bsr			GET_RN
				beq			ABSOLUT
				move.w		d3,(a6)+
				bra.s		EA_OK

EA_FAIL:		sf			AssemblyFlag-VB(a4)
				movem.l		(sp)+,d1-a1/a3/a5-a6
				addq.w		#4,sp
				rts

EA_OK:			moveq		#-4,d3
		AND.B	    DisassemCPU,D3
		BNE.S	    EA_IS_IO
		MOVEQ	    #%111111,D3
		AND.W	    GeteaCode-VB(a4),D3
		CMP.W	    #$3B,D3		  ; (d8,PC,Xn)?
		BEQ.S	    TEST_FORMAT
		AND.W	    #%111000,D3
		CMP.W	    #$30,D3		  ; (d8,An,Xn)?
		BNE.S	    EA_IS_IO
TEST_FORMAT:	MOVE.W	    #%11100000000,D3
		AND.W	    GeteaCode-VB+2(a4),D3
		BEQ.S	    EA_IS_IO
		SF	    AssemblyFlag-VB(a4)
EA_IS_IO:	SUBA.L	    #GeteaCode,A6
		MOVE.W	    A6,GeteaLength-VB(a4)
		MOVEM.L     (SP)+,D1-A1/A3/A5-A6
		RTS

*---------------

ADRESSEN_PREDEKREMENT:				  ; -(An)
		JSR	    KillSpace
		BMI.S	    EA_FAIL
		SUBQ.W	    #1,D0
		CMPI.B	    #'(',(A2)+
		BNE.S	    ABSOLUT
		JSR	    KillSpace
		BMI.S	    EA_FAIL
		BSR	    GET_AN
		BEQ.S	    EA_FAIL
		BSR	    KILL_KLAMMER_1
		SUBQ.W	    #8,D3
		OR.W	    #$20,D3
		MOVE.W	    D3,(A6)+
		BRA.S	    EA_OK

*---------------

ABSOLUT:	MOVEM.L     SaveEA-VB(a4),D0/A2	  ; ABS.w, ABS.l
		JSR	    Interpreter
		BNE	    EA_FAIL
		BSR	    GET_LENGTH_EA
		BNE.S	    WITH_LENGTH_4
		MOVEQ	    #4,D2
WITH_LENGTH_4:	CMP.W	    #1,D2
		BNE.S	    NO_BYTE_2
		MOVEQ	    #2,D2
NO_BYTE_2:	SUBQ.W	    #4,D2
		BEQ.S	    ABS_LONG
		MOVE.W	    #$38,(A6)+
		MOVE.W	    D3,(A6)+
		BRA	    EA_OK
ABS_LONG:	MOVE.W	    #$39,(A6)+
		MOVE.L	    D3,(A6)+
		BRA	    EA_OK

*---------------

IMMEDIATE:
		JSR	    Interpreter 	  ; #Immediate
		BNE	    EA_FAIL
		MOVE.W	    #$3C,(A6)+
		MOVEQ	    #$3F,D1
		AND.B	    4(A1),D1
		LSR.B	    #4,D1
		BEQ.S	    LENGTH_B
		CMP.B	    #2,D1
		BNE.S	    LENGTH_W
		MOVE.L	    D3,(A6)+
		BRA	    EA_OK
LENGTH_B:	BSR	    CHECK_LENGTH_EA
		SUBQ.W	    #1,D2
		BNE	    EA_FAIL
		CLR.B	    (A6)+
		MOVE.B	    D3,(A6)+
		BRA	    EA_OK
LENGTH_W:	BSR	    CHECK_LENGTH_EA
		SUBQ.W	    #4,D2
		BEQ	    EA_FAIL
		MOVE.W	    D3,(A6)+
		BRA	    EA_OK

*---------------

INDIRECT:	JSR	    KillSpace		  ; (...)
		BMI	    EA_FAIL
		MOVEM.L     D0/A2,SaveEA-VB(a4)
		BSR	    GET_AN
		BEQ.S	    NOT_ARI
		SUBQ.W	    #8,D3
		JSR	    KillSpace
		BMI.S	    ARI
		CMPI.B	    #')',(A2)
		BNE.S	    NOT_ARI
		SUBQ.W	    #1,D0
		ADDQ.W	    #1,A2

*---------------

		JSR	    KillSpace
		BMI.S	    ARI
		CMPI.B	    #'+',(A2)
		BNE.S	    ARI
		SUBQ.W	    #1,D0		  ; (An)+
		ADDQ.W	    #1,A2
		OR.W	    #$18,D3
		MOVE.W	    D3,(A6)+
		BRA	    EA_OK
ARI:		OR.W	    #$10,D3		  ; (An)
		MOVE.W	    D3,(A6)+
		BRA	    EA_OK

*---------------

NOT_ARI:	BSR	    CLEAR_ASS
CONT_ARI:	CMPI.B	    #'[',(A2)
		SEQ	    MemoryFlag-VB(a4)
		BEQ.S	    MEMORY_INDIRECT

*---------------

WITH_BASEDIS:	BSR	    GET_BASEREG 	  ; (Basedis.X,PC/An,Index.X*S)
		BNE.S	    ONLY_BASEREG_1
		BSR	    GET_BASEDIS
		BEQ	    EA_FAIL
		BSR	    KILL_KOMMA
		BSR	    GET_BASEREG
		BEQ	    EA_FAIL
ONLY_BASEREG_1: BSR	    KILL_KOMMA
		BSR	    GET_INDEX
		BSR	    KILL_KLAMMER_1
		BRA.S	    CREATE_EA

; ([Basedis.X,PC/An,Index.X*S],Outer.X), ([Basedis.X,PC/An],Index.X*S,Outer.X)
MEMORY_INDIRECT:SUBQ.W	    #1,D0
		ADDQ.W	    #1,A2
		JSR	    KillSpace
		BMI	    EA_FAIL
		BSR	    GET_BASEREG
		BNE.S	    ONLY_BASEREG_2
		BSR	    GET_BASEDIS
		BEQ	    EA_FAIL
		BSR	    KILL_KOMMA
		BSR	    GET_BASEREG
		BEQ	    EA_FAIL
ONLY_BASEREG_2: BSR	    KILL_KOMMA
		BSR	    GET_INDEX
		SNE	    PreindexFlag-VB(a4)
		BNE.S	    ITS_PREINDEX
		BSR	    KILL_KLAMMER_2
		BSR	    KILL_KOMMA
		BSR	    GET_INDEX
		SEQ	    PreindexFlag-VB(a4)
ITS_PREINDEX:	BSR	    KILL_KLAMMER_2
		BSR	    KILL_KOMMA
		BSR	    GET_OUTERDIS
		BSR	    KILL_KLAMMER_1

*---------------

CREATE_EA:
		TST.B	    RelozierFlag-VB(a4)	  ; zuerst Basedisplacement
		BEQ.S	    DONT_RELOCATE	  ; relozieren
		MOVE.L	    BaseDis-VB(a4),D3
		SUB.L	    RelozierAdresse-VB(a4),D3
		SUBQ.L	    #2,D3
		MOVEQ	    #1,D2
		CMP.L	    #127,D3
		BGT.S	    NO_BYTE_RELOC
		CMPI.L	    #-128,D3
		BGE.S	    LENGTH_RELOC
NO_BYTE_RELOC:	MOVEQ	    #2,D2
		CMP.L	    #32767,D3
		BGT.S	    NO_WORD_RELOC
		CMPI.L	    #-32768,D3
		BGE.S	    LENGTH_RELOC
NO_WORD_RELOC:	MOVEQ	    #4,D2
LENGTH_RELOC:	MOVE.W	    D2,BaseLength-VB(a4)
		MOVE.L	    D3,BaseDis-VB(a4)

DONT_RELOCATE:
		TST.B	    MemoryFlag-VB(a4)
		BNE.S	    NOT_ARI_DIS
		CMPI.W	    #2,BaseLength-VB(a4)
		BHI.S	    NOT_ARI_DIS
		TST.B	    ZapFlag-VB(a4)
		BNE.S	    NOT_ARI_DIS
		TST.W	    IndexLength-VB(a4)
		BNE.S	    NOT_ARI_DIS

		MOVE.W	    #$3A,(A6)		  ; (Basedis.X,PC)
		MOVE.W	    BaseRegister-VB(a4),D3
		BMI.S	    ITS_NOT_AN_1
		SUBQ.W	    #8,D3		  ; (Basedis.X,An)
		OR.W	    #%101000,D3
		MOVE.W	    D3,(A6)
ITS_NOT_AN_1:	ADDQ.W	    #2,A6
		MOVE.L	    BaseDis-VB(a4),D3
		MOVE.W	    D3,(A6)+
		BRA	    EA_OK

NOT_ARI_DIS:	MOVE.W	    #$3B,(A6)
		MOVE.W	    BaseRegister-VB(a4),D3
		BMI.S	    ITS_NOT_AN_2
		SUBQ.W	    #8,D3
		OR.W	    #%110000,D3
		MOVE.W	    D3,(A6)
ITS_NOT_AN_2:	ADDQ.W	    #2,A6
		MOVEQ	    #0,D3
		MOVE.W	    IndexRegister-VB(a4),D3
		MOVEQ	    #12,D2
		LSL.W	    D2,D3		  ; D/A Register
		CMPI.W	    #4,IndexLength-VB(a4)
		BNE.S	    NOT_LONG_INDEX
		BSET	    #11,D3		  ; W/L
NOT_LONG_INDEX: MOVE.W	    IndexScaling-VB(a4),D2
		MOVE.B	    INDEX_TABLE(PC,D2.w),D2
		LSL.W	    #8,D2
		ADD.W	    D2,D2
		OR.W	    D2,D3		  ; Scale
		TST.B	    MemoryFlag-VB(a4)
		BNE.S	    FULL_FORMAT
		TST.B	    ZapFlag-VB(a4)
		BNE.S	    FULL_FORMAT
		CMPI.W	    #1,BaseLength-VB(a4)
		BHI.S	    FULL_FORMAT
BRIEF_FORMAT:	MOVE.L	    BaseDis-VB(a4),D2
		AND.W	    #$FF,D2
		OR.W	    D2,D3
		MOVE.W	    D3,(A6)+
		BRA	    EA_OK

*---------------

DIS_TABLE:		DC.B 1,2,2,0,3
INDEX_TABLE:		DC.B 0,0,1,0,2,0,0,0,3

*---------------

FULL_FORMAT:	BSET	    #8,D3
		TST.B	    ZapFlag-VB(a4)
		BEQ.S	    DONT_ZAP
		BSET	    #7,D3
DONT_ZAP:	TST.W	    IndexLength-VB(a4)
		BNE.S	    WITH_INDEX
		BSET	    #6,D3
WITH_INDEX:	MOVE.W	    BaseLength-VB(a4),D2
		MOVE.B	    DIS_TABLE(PC,D2.w),D2
		LSL.W	    #4,D2
		OR.W	    D2,D3
		TST.B	    MemoryFlag-VB(a4)
		BEQ.S	    THATS_ALL
		TST.B	    PreindexFlag-VB(a4)
		BNE.S	    ITS_PREINDEXED
		BSET	    #2,D3
ITS_PREINDEXED: MOVE.W	    OuterLength-VB(a4),D2
		MOVE.B	    DIS_TABLE(PC,D2.w),D2
		OR.W	    D2,D3
THATS_ALL:	MOVE.W	    D3,(A6)+
		MOVE.L	    BaseDis-VB(a4),D3
		MOVE.W	    BaseLength-VB(a4),D2
		BEQ.S	    ITS_ZERO_BASE
		CMP.W	    #2,D2
		BHI.S	    ITS_LONG_BASE
		MOVE.W	    D3,(A6)+
		BRA.S	    ITS_ZERO_BASE
ITS_LONG_BASE:	MOVE.L	    D3,(A6)+
ITS_ZERO_BASE:	MOVE.L	    OuterDis-VB(a4),D3
		MOVE.W	    OuterLength-VB(a4),D2
		BEQ.S	    ITS_ZERO_OUTER
		CMP.W	    #2,D2
		BHI.S	    ITS_LONG_OUTER
		MOVE.W	    D3,(A6)+
		BRA.S	    ITS_ZERO_OUTER
ITS_LONG_OUTER: MOVE.L	    D3,(A6)+
ITS_ZERO_OUTER: BRA	    EA_OK

*-------------------------------------------------------------------------------

CLEAR_ASS:		movem.l		SaveEA-VB(a4),d0/a2
				lea			BaseDis-VB(a4),a0
				moveq		#4,d3
.clear:			clr.l		(a0)+
				dbra		d3,.clear
				rts

*-------------------------------------------------------------------------------

KILL_DOPPELPT:	MOVE.L	    D3,-(SP)
		MOVEQ	    #':',D3
		BRA.S	    KILLEN
KILL_KOMMA:	MOVE.L	    D3,-(SP)
		MOVEQ	    #',',D3
		BRA.S	    KILLEN
KILL_KLAMMER_0: MOVE.L	    D3,-(SP)
		MOVEQ	    #'(',D3
		BRA.S	    KILLEN
KILL_KLAMMER_1: MOVE.L	    D3,-(SP)
		MOVEQ	    #')',D3
		BRA.S	    KILLEN
KILL_KLAMMER_2: MOVE.L	    D3,-(SP)
		MOVEQ	    #']',D3
		BRA.S	    KILLEN
KILL_KLAMMER_3: MOVE.L	    D3,-(SP)
		MOVEQ	    #'}',D3
KILLEN: 	JSR	    KillSpace
		CMP.B	    (A2),D3
		BNE.S	    ENDE_KILLEN
		ADDQ.W	    #1,A2
		SUBQ.W	    #1,D0
ENDE_KILLEN:	JSR	    KillSpace
		MOVE.L	    (SP)+,D3
		RTS

*-------------------------------------------------------------------------------

* <--- D3.l = 0-7 (Datenregister D0-D7)
* tst.b flag.eq = Fehler, flag.ne = alles io
GET_DN: 	MOVE.L	    D2,-(SP)
		MOVEM.L     D0/A2,-(SP)
		BSR.S	    GET_RN
		BEQ.S	    RN_FAIL
		CMP.L	    #7,D3
		BHI.S	    RN_FAIL
		BRA.S	    RN_OK

* <--- D3.l = 8-15 (Adressregister A0-A7)
* tst.b flag.eq = Fehler, flag.ne = alles io
GET_AN: 	MOVE.L	    D2,-(SP)
		MOVEM.L     D0/A2,-(SP)
		BSR.S	    GET_RN
		BEQ.S	    RN_FAIL
		CMP.L	    #7,D3
		BLS.S	    RN_FAIL
		BRA.S	    RN_OK

* <--- D3.l = 0-16 (D0-D7/A0-A7)
* tst.b flag.eq = Fehler, flag.ne = alles io
GET_RN: 	MOVE.L	    D2,-(SP)
		MOVEM.L     D0/A2,-(SP)
		MOVE.L	    A0,-(SP)
		JSR	    GetRegister
		MOVEA.L     (SP)+,A0
		TST.L	    D3
		BEQ.S	    RN_FAIL
		MOVEQ	    #15,D3
		CMP.L	    #22,D2
		BEQ.S	    RN_OK
		MOVE.L	    D2,D3
		BMI.S	    RN_FAIL
		CMP.L	    #15,D3
		BHI.S	    RN_FAIL
RN_OK:		ADDQ.W	    #8,SP
		MOVE.L	    (SP)+,D2
		ST	    -(SP)
		TST.B	    (SP)+
		RTS
RN_FAIL:	MOVEM.L     (SP)+,D0/A2
		MOVE.L	    (SP)+,D2
		sf			-(sp)
		tst.b		(sp)+
		RTS

*-------------------------------------------------------------------------------

* <--- tst.b flag.eq = kein Baseregister
* <--- ZapFlag-VB(a4).ne = Zap Register sonst 0
* <--- BaseRegister-VB(a4)
GET_BASEREG:	MOVEM.L     D0/A2,-(SP)
		JSR	    KillSpace
		BMI.S	    NO_BASE
		MOVEQ	    #0,D3
		MOVE.B	    (A2),D3
		MOVE.B	    (A5,D3.w),D3
		CMP.B	    #'Z',D3
		SEQ	    ZapFlag-VB(a4)
		BNE.S	    NOT_ZAP
		ADDQ.W	    #1,A2
		SUBQ.W	    #1,D0
		JSR	    KillSpace
		BMI.S	    NO_BASE
NOT_ZAP:	BSR	    GET_AN
		BEQ.S	    NO_BASE_AN
		MOVE.W	    D3,BaseRegister-VB(a4)
		ADDQ.W	    #8,SP
		MOVEQ	    #-1,D3
		RTS
NO_BASE_AN:	MOVE.L	    A0,-(SP)
		JSR	    GetRegister
		MOVEA.L     (SP)+,A0
		TST.L	    D3
		BEQ.S	    NO_BASE
		CMP.W	    #17,D2
		BNE.S	    NO_BASE
		ST	    RelozierFlag-VB(a4)
		ADDQ.W	    #8,SP
		MOVEQ	    #-1,D3
		MOVE.W	    D3,BaseRegister-VB(a4)
		RTS
NO_BASE:	SF	    ZapFlag-VB(a4)
		MOVEM.L     (SP)+,D0/A2
		MOVEQ	    #0,D3
		RTS

*-------------------------------------------------------------------------------

* <--- tst.b flag.eq = Fehler sonst io
* <--- BaseLength-VB(a4), BaseDis-VB(a4)
GET_BASEDIS:	MOVEM.L     D0/A2,-(SP)
		TST.W	    BaseLength-VB(a4)
		BNE.S	    LENGTH_OK_1
		JSR	    Interpreter
		BNE.S	    BASEDIS_FAIL
		MOVE.L	    D3,BaseDis-VB(a4)
		BSR	    GET_LENGTH_EA
		CMP.W	    #2,D2
		BHS.S	    WITH_LENGTH_1
		BSR.S	    CHECK_LENGTH_EA
WITH_LENGTH_1:	MOVE.W	    D2,BaseLength-VB(a4)
		BSR.S	    CHECK_LENGTH_EA
		CMP.W	    BaseLength-VB(a4),D2
		BLS.S	    LENGTH_OK_1
		MOVE.W	    D2,BaseLength-VB(a4)
LENGTH_OK_1:	ADDQ.W	    #8,SP
		MOVEQ	    #-1,D3
		RTS
BASEDIS_FAIL:	MOVEM.L     (SP)+,D0/A2
		MOVEQ	    #0,D3
		RTS

*-------------------------------------------------------------------------------

* <--- tst.b flag.eq = Fehler sonst io
* <--- OuterLength-VB(a4), OuterDis-VB(a4)
GET_OUTERDIS:	MOVEM.L     D0/A2,-(SP)
		JSR	    Interpreter
		BNE.S	    OUTERDIS_FAIL
		MOVE.L	    D3,OuterDis-VB(a4)
		BSR	    GET_LENGTH_EA
		CMP.W	    #2,D2
		BHS.S	    WITH_LENGTH_3
		BSR.S	    CHECK_LENGTH_EA
		CMP.W	    #2,D2
		BHS.S	    WITH_LENGTH_3
		MOVEQ	    #2,D2
WITH_LENGTH_3:	MOVE.W	    D2,OuterLength-VB(a4)
		BSR.S	    CHECK_LENGTH_EA
		CMP.W	    OuterLength-VB(a4),D2
		BLS.S	    LENGTH_OK_3
		MOVE.W	    D2,OuterLength-VB(a4)
LENGTH_OK_3:	ADDQ.W	    #8,SP
		MOVEQ	    #-1,D3
		RTS
OUTERDIS_FAIL:	MOVEM.L     (SP)+,D0/A2
		MOVEQ	    #0,D3
		RTS

*-------------------------------------------------------------------------------

* ---> D3.l = Zahl
* <--- D2.l = 1 : Byte
*	      2 : Word
*	      4 : Long
CHECK_LENGTH_EA:MOVEQ	    #1,D2
		CMP.L	    #$FF,D3
		BLS.S	    WITH_LENGTH
		CMP.L	    #127,D3
		BGT.S	    NOT_BYTE
		CMPI.L	    #-128,D3
		BGE.S	    WITH_LENGTH
NOT_BYTE:	MOVEQ	    #2,D2
		CMP.L	    #$FFFF,D3
		BLS.S	    WITH_LENGTH
		CMP.L	    #32767,D3
		BGT.S	    NOT_WORD
		CMPI.L	    #-32768,D3
		BGE.S	    WITH_LENGTH
NOT_WORD:	MOVEQ	    #4,D2
WITH_LENGTH:	RTS

*-------------------------------------------------------------------------------

* <--- tst.b flag.eq = kein Index
* <--- IndexRegister-VB(a4), IndexLength-VB(a4), IndexScaling-VB(a4)
GET_INDEX:	MOVEM.L     D0/A2,-(SP)
		JSR	    KillSpace
		BMI.S	    NO_INDEX
		BSR	    GET_RN
		BEQ.S	    NO_INDEX
		MOVE.W	    D3,IndexRegister-VB(a4)
		BSR.S	    GET_LENGTH_EA
		BNE.S	    WITH_LENGTH_2
BYTE_IS_WRONG:	MOVEQ	    #2,D2
WITH_LENGTH_2:	CMP.W	    #1,D2
		BEQ.S	    BYTE_IS_WRONG
		MOVE.W	    D2,IndexLength-VB(a4)
		JSR	    KillSpace
		BMI.S	    NO_SCALING
		CMPI.B	    #'*',(A2)
		BNE.S	    NO_SCALING
		ADDQ.W	    #1,A2
		SUBQ.W	    #1,D0
		JSR	    KillSpace
		BMI.S	    NO_SCALING
		MOVE.B	    (A2),D3
		SUB.B	    #'0',D3
		BLE.S	    NO_SCALING
		CMP.B	    #8,D3
		BHI.S	    NO_SCALING
		BEQ.S	    ITS_SCALING
		BTST	    D3,#%10110
		BEQ.S	    NO_SCALING
ITS_SCALING:	ADDQ.W	    #1,A2
		SUBQ.W	    #1,D0
		MOVE.W	    D3,IndexScaling-VB(a4)
NO_SCALING:	ADDQ.W	    #8,SP
		MOVEQ	    #-1,D3
		RTS
NO_INDEX:	MOVEM.L     (SP)+,D0/A2
		MOVEQ	    #0,D3
		RTS

*-------------------------------------------------------------------------------

* <--- tst.l D2 = 0 : keine LÑnge
*		= 1 : .b
*		= 2 : .w
*		= 4 : .l
GET_LENGTH_EA:	MOVEM.L     D0/A2,-(SP)
		JSR	    KillSpace
		BMI.S	    NO_LENGTH_EA
		CMPI.B	    #'.',(A2)+
		BNE.S	    NO_LENGTH_EA
		SUBQ.W	    #1,D0
		JSR	    KillSpace
		BMI.S	    NO_LENGTH_EA
		SUBQ.W	    #1,D0
		MOVEQ	    #0,D1
		MOVE.B	    (A2)+,D1
		MOVE.B	    (A5,D1.w),D1
		MOVEQ	    #1,D2
		CMP.B	    #'B',D1
		BEQ.S	    END_LENGTH_EA
		MOVEQ	    #2,D2
		CMP.B	    #'W',D1
		BEQ.S	    END_LENGTH_EA
		MOVEQ	    #4,D2
		CMP.B	    #'L',D1
		BEQ.S	    END_LENGTH_EA
NO_LENGTH_EA:	MOVEQ	    #0,D2
		MOVEM.L     (SP),D0/A2
END_LENGTH_EA:	ADDQ.W	    #8,SP
		TST.L	    D2
		RTS

*-------------------------------------------------------------------------------

* <--- tst.b flag.eq = Fehler
* <--- D3.l = Zahl
GET_IMMEDIATE:	JSR	    KillSpace
		BMI.S	    NO_IMMEDIATE
		CMPI.B	    #'#',(A2)
		BNE.S	    KEIN_IMMEDIATE
		ADDQ.W	    #1,A2
		SUBQ.W	    #1,D0
KEIN_IMMEDIATE: JSR	    Interpreter
		BEQ	    RTS
NO_IMMEDIATE:	ADDQ.W	    #4,SP
		BRA	    FAIL_ASS
