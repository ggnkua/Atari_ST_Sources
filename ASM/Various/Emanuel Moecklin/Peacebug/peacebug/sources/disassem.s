*-------------------------------------------------------------------------------
* DisassemLength: berechnet die LÑnge eines Opcodes
* ---> A3.l = Befehlsadresse
* <--- D0.l = BefehlslÑnge
* flag.ne = Fehler
*
* Disassembler:
* ---> A2.l = Stringadresse, Disassembly ist nicht nullterminiert!
* ---> A3.l = Befehlsadresse
* <--- A2.l = Zeiger auf Stringende
* flag.ne = Fehler
*-------------------------------------------------------------------------------
* DisassemblyArray:
*	dc.l		Zeiger auf Befehl
*	dc.w		LÑnge des Befehls
*	dc.w		DisassemblyFlags, Befehlstyp
*	dc.b		DiassemblyFlag, Diassembly gÅltig?
* DisassemblyFlags:
* Bit 15 = Sprungbefehl
* DisassemblyFlag wird gesetzt
*
* Interne Register:
* A0 = Zeiger auf Befehl+x (Ñndert sich je nach LÑnge (x) des Befehls)
* A1 = Befehlstabelle
* A2 = Zeiger auf String
* A3 = Zeiger auf Befehlsanfang (darf nicht verÑndert werden!)
* D0 = Befehlsopcode (darf nicht verÑndet werden!)
*-------------------------------------------------------------------------------

		.EXPORT		Disassembler,DisassemLength			; Routinen
		.EXPORT		DisassemblyLength,DisassemblyFlags	; <--- Variablen
		.EXPORT		DisassemCPU,OnlyWord				; ---> Variablen

		.INCLUDE	'EQU.S'

*-------------------------------------------------------------------------------

		.BSS
VB:
DisassemblyLength:	ds.w	1			; LÑnge des Befehls
DisassemblyFlags:	ds.w	1			; diverse Flags
DisassemblyFlag:	ds.b	1			; Disassemble gÅltig?

OnlyWord:			ds.b	1			; Befehl darf nur 2 Bytes lang sein
DisassemCPU:		ds.b	1			; Disassemblieren fÅr CPU ...
		.EVEN

*-------------------

DisassemblyString:	ds.b	80			; Dummystring fÅr die Lengthroutine

StringAdresse: 		ds.l	1
PcAnFlag:			ds.b	1
PcFlag:				ds.b	1

AttentionFlag:	 	ds.b	1			; -?-
QuotationFlag:	 	ds.b	1			; ???
		.EVEN

*-------------------------------------------------------------------------------

		.TEXT
DisassemLength:	move.l		a2,-(sp)
				lea			DisassemblyString,a2
				bsr.s		Disassembler
				move.l		(sp)+,a2
				moveq		#0,d0
				move.w		DisassemblyLength,d0		; BefehlslÑnge
				tst.b		DisassemblyFlag				; Flag
				rts

*-------------------------------------------------------------------------------

Disassembler:	movem.l		d0-a1/a3-a6,-(SP)
				lea			VB,a4

				CMPA.L		ProgrammStart,A3		; PC innerhalb des Debuggers?
				BLO.S		NOT_WITHIN
				CMPA.L		ProgrammEnde,A3
				BHS.S		NOT_WITHIN
				MOVE.B		#'*',(A2)+

NOT_WITHIN:		clr.w		DisassemblyFlags-VB(a4)	; DisassemblyFlags-VB(a4) lîschen
				MOVE.L		A2,StringAdresse-VB(a4)	; Stringadresse saven

				PEA			DIS_FAIL
				JSR			TestBusOn
				move.w		(a3),d0					; Opcode holen
				JSR			TestBusOff
				ADDQ.W		#4,SP

				MOVE.W		D0,D1					; 4 oberste Opcodebits * 2
				MOVEQ		#12,D2
				LSR.W		D2,D1
				ADD.W		D1,D1
				LEA			Befehlstabelle,A1
				ADDA.W		(A1,D1.w),A1			; Tabellenadresse
				MOVE.W		(A1)+,D7				; Anzahl Befehle
				LEA			2(A3),A0				; Befehlszeiger+2

				MOVEQ		#16,D3

*---------------

SUCHEN:			MOVE.W		D0,D1
				AND.W		(A1),D1
				CMP.W		(A1),D1
				BNE			NEXT_BEFEHL				; 1 maskieren
				MOVE.W		D0,D1
				AND.W		2(A1),D1
				BNE			NEXT_BEFEHL				; 0 maskieren

				MOVE.B	    DisassemCPU-VB(a4),D2	; richtige CPU?
				AND.B		7(A1),D2
				BEQ			NEXT_BEFEHL

*---------------

CONT_BEFEHL:	move.w		d7,-(sp)				; Anzahl Befehle sichern
				SF			AttentionFlag-VB(a4)	; AttentionFlag=FALSE
				SF			QuotationFlag-VB(a4)	; QuotationFlag=FALSE
				ST			DisassemblyFlag-VB(a4)	; DisassemblyFlag=TRUE

				LEA			8(A1),A5
				MOVEQ		#7,D6					; Befehl kopieren
				MOVEA.L		StringAdresse-VB(a4),A2
COPY:			MOVE.B		(A5)+,(A2)+
				DBRA		D6,COPY

				moveq		#DISSTRING_DISTANZ-1,d1	; Spaces einfÅgen
.spaces:		move.b		#32,(a2)+
				dbra		d1,.spaces

				MOVEQ		#0,D1					; Disassemblerroutine aufrufen
				MOVE.B		6(A1),D1
				ADD.W		D1,D1
				LEA			2(A3),A0
				MOVE.W		DISASSEMBLER_TABELLE(PC,D1.w),D1
				JSR			DISASSEMBLER_TABELLE(PC,D1.w)
				move.w		(sp)+,d7

				TST.B		DisassemblyFlag-VB(a4)	; Disassembly gÅltig?
				BEQ.S		.DIS_WAS_WRONG

				TST.B		OnlyWord-VB(a4)			; Befehl nur 2 Bytes lang?
				BEQ.S		.BEFEHL_OK
				MOVE.L		A0,D1
				SUB.L		A3,D1
				SUBQ.W		#2,D1
				seq			DisassemblyFlag-VB(a4)
				bne.s		.DIS_WAS_WRONG

.BEFEHL_OK:		TST.B		QuotationFlag-VB(a4)	; QuotationFlag?
				BEQ.S		.NO_QUOTE
				MOVE.B		#32,(A2)+				; ???
				BSR			WRITE_QUOTE
.NO_QUOTE:		TST.B	    AttentionFlag-VB(a4)	; AttentionFlag?
				BEQ			ENDE_DISASSEM			; Nein? ---> Ende
				MOVE.B		#32,(A2)+
				MOVE.B		#'',(A2)+				; -?-
				MOVE.B		#'?',(A2)+
				MOVE.B		#'',(A2)+
				BRA			ENDE_DISASSEM

.DIS_WAS_WRONG:	MOVE.L		A2,D1
				SUB.L		StringAdresse-VB(a4),D1
				MOVEQ		#32,D2
				BRA.S		LOESCHEN_ENTER
LOESCHEN:		MOVE.B		D2,-(A2)
LOESCHEN_ENTER:	DBRA		D1,LOESCHEN

NEXT_BEFEHL:	LEA			16(A1),A1
				DBRA		D7,SUCHEN				; weitersuchen
				BRA			DISASSEM_FAIL

*-------------------------------------------------------------------------------

DISASSEMBLER_TABELLE:
	dc.w DISASSEMBLER_0-DISASSEMBLER_TABELLE,DISASSEMBLER_1-DISASSEMBLER_TABELLE,DISASSEMBLER_2-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_3-DISASSEMBLER_TABELLE,DISASSEMBLER_4-DISASSEMBLER_TABELLE,DISASSEMBLER_5-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_6-DISASSEMBLER_TABELLE,DISASSEMBLER_7-DISASSEMBLER_TABELLE,DISASSEMBLER_8-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_9-DISASSEMBLER_TABELLE,DISASSEMBLER_10-DISASSEMBLER_TABELLE,DISASSEMBLER_11-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_12-DISASSEMBLER_TABELLE,DISASSEMBLER_13-DISASSEMBLER_TABELLE,DISASSEMBLER_14-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_15-DISASSEMBLER_TABELLE,DISASSEMBLER_16-DISASSEMBLER_TABELLE,DISASSEMBLER_17-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_18-DISASSEMBLER_TABELLE,DISASSEMBLER_19-DISASSEMBLER_TABELLE,DISASSEMBLER_20-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_21-DISASSEMBLER_TABELLE,DISASSEMBLER_22-DISASSEMBLER_TABELLE,DISASSEMBLER_23-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_24-DISASSEMBLER_TABELLE,DISASSEMBLER_25-DISASSEMBLER_TABELLE,DISASSEMBLER_26-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_27-DISASSEMBLER_TABELLE,DISASSEMBLER_28-DISASSEMBLER_TABELLE,DISASSEMBLER_29-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_30-DISASSEMBLER_TABELLE,DISASSEMBLER_31-DISASSEMBLER_TABELLE,DISASSEMBLER_32-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_33-DISASSEMBLER_TABELLE,DISASSEMBLER_34-DISASSEMBLER_TABELLE,DISASSEMBLER_35-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_36-DISASSEMBLER_TABELLE,DISASSEMBLER_37-DISASSEMBLER_TABELLE,DISASSEMBLER_38-DISASSEMBLER_TABELLE
	dc.w FailDis-DISASSEMBLER_TABELLE,DISASSEMBLER_40-DISASSEMBLER_TABELLE,DISASSEMBLER_41-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_42-DISASSEMBLER_TABELLE,DISASSEMBLER_43-DISASSEMBLER_TABELLE,DISASSEMBLER_44-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_45-DISASSEMBLER_TABELLE,DISASSEMBLER_46-DISASSEMBLER_TABELLE,DISASSEMBLER_47-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_48-DISASSEMBLER_TABELLE,DISASSEMBLER_49-DISASSEMBLER_TABELLE,DISASSEMBLER_50-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_51-DISASSEMBLER_TABELLE,DISASSEMBLER_52-DISASSEMBLER_TABELLE,DISASSEMBLER_53-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_54-DISASSEMBLER_TABELLE,DISASSEMBLER_55-DISASSEMBLER_TABELLE,DISASSEMBLER_56-DISASSEMBLER_TABELLE
	dc.w DISASSEMBLER_57-DISASSEMBLER_TABELLE,DISASSEMBLER_58-DISASSEMBLER_TABELLE,DISASSEMBLER_59-DISASSEMBLER_TABELLE

*-------------------------------------------------------------------------------

* Exception (Bus-, Adresserror)
DIS_FAIL:		BSR			WRITE_QUOTE					; ???
				MOVEQ		#DISSTRING_DISTANZ+4,D3
				MOVEQ		#32,D7
CLEAR_1:		MOVE.B		D7,(A2)+					; Spaces
				DBRA		D3,CLEAR_1
				MOVEQ		#'-',D7						; ----
				MOVE.B		D7,(A2)+
				MOVE.B		D7,(A2)+
				MOVE.B		D7,(A2)+
				MOVE.B		D7,(A2)+
				MOVE.W		#2,DisassemblyLength-VB(a4)	; BefehlslÑnge=2
				CLR.W		DisassemblyFlags-VB(a4)		; DisassemblyFlags=0
				SF			DisassemblyFlag-VB(a4)		; DisassemblyFlag=FALSE
				SF			AttentionFlag-VB(a4)		; AttentionFlag=FALSE
				SF			QuotationFlag-VB(a4)		; QuotationFlag=FALSE
				bra.s		GetOut

*-------------------------------------------------------------------------------

* kein Befehl gefunden
DISASSEM_FAIL:	MOVEA.L		StringAdresse-VB(a4),A2
				SF			DisassemblyFlag-VB(a4)		; DisassemblyFlag-VB(a4)=FALSE
				BSR			WRITE_QUOTE					; ???
				MOVEQ		#DISSTRING_DISTANZ+4,D3
				MOVEQ		#32,D7
CLEAR_2:		MOVE.B		D7,(A2)+					; Spaces
				DBRA		D3,CLEAR_2
				MOVEQ		#0,D3
				MOVE.W		D0,D3
				BSR			WRITE_HEXZAHL				; Hexzahl
				LEA			2(A3),A0					; damit LÑnge=2

*-------------------------------------------------------------------------------

ENDE_DISASSEM:	suba.l		a3,a0
				move.w		a0,DisassemblyLength-VB(a4)	; BefehlslÑnge=a0-a3
GetOut:			movem.l		(sp)+,d0-a1/a3-a6
				tst.b		DisassemblyFlag-VB(a4)
				rts

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

DISASSEMBLER_0:	cmpi.b		#32,-(a2)					; ÅberflÅssige Spaces lîschen
				beq.s		DISASSEMBLER_0
				addq.w		#1,a2
				rts

*-------------------------------------------------------------------------------

DISASSEMBLER_1: MOVEQ	    #0,D3
		MOVE.W	    D0,D3
		AND.W	    #$0FFF,D3
		CMP.W	    #$0F,D3
		BHI	    FailDis
		BSR	    WRITE_IMMEDIATE
		MOVEQ	    #$0F,D3
		AND.W	    D0,D3
		MOVE.B	    #32,(A2)+
		MOVE.B	    #'[',(A2)+
		MOVE.B	    #32,(A2)+
		LEA	    LINEA_TABELLE,A5
		BRA.S	    LINEA_EINSTIEG
LINEA_SCHLEIFE: TST.B	    (A5)+
		BNE.S	    LINEA_SCHLEIFE
LINEA_EINSTIEG: DBRA	    D3,LINEA_SCHLEIFE
COPY_LINEA:	MOVE.B	    (A5)+,(A2)+
		BNE.S	    COPY_LINEA
		MOVE.B	    #32,-1(A2)
		MOVE.B	    #']',(A2)+
		RTS

*---------------

LINEA_TABELLE:			dc.B 'Init',0,'Putpixel',0,'Getpixel',0,'Line',0
				dc.B 'Hline',0,'Fillrec',0,'Fillpoly',0,'Bitblt',0
				dc.B 'Textblt',0,'Showm',0,'Hidem',0,'Transm',0
				dc.B 'Undraw',0,'Draw',0,'Copy',0,'Fill',0
			EVEN

*-------------------------------------------------------------------------------

DISASSEMBLER_2: BSR	    CHECK_ADRESSIERUNG
		TST.B	    DisassemblyFlag-VB(a4)
		beq.s		no_jsr
		MOVE.W	    D0,D1
		AND.W	    #$FFC0,D1
		CMP.W	    #$4EC0,D1
		BEQ.S	    ITS_JMP
		CMP.W	    #$4E80,D1
		BNE.S	    no_jsr
		BSET	    #7,DisassemblyFlags-VB(a4)
ITS_JMP:	MOVEQ	    #%111110,D2
		AND.W	    D0,D2
		CMP.B	    #%111000,D2
		BNE.S	    no_jsr
		MOVE.W	    -2(A0),D2
		BTST	    #0,D2
		SNE	    QuotationFlag-VB(a4)
no_jsr:		RTS

*-------------------------------------------------------------------------------

DISASSEMBLER_3: BSR	    GetRegister_1
		BTST	    #3,D0
		BEQ.S	    DATEN
		BSR	    WRITE_ARI_PRE
		MOVE.B	    #',',(A2)+
		BSR	    GetRegister_2
		BRA	    WRITE_ARI_PRE
DATEN:		BSR	    WriteDn
		MOVE.B	    #',',(A2)+
		BSR	    GetRegister_2
		BRA	    WriteDn

*-------------------------------------------------------------------------------

DISASSEMBLER_4: BTST	    #8,D0
		BEQ.S	    EADN
		BSR	    GetRegister_2
		BSR	    WriteDn
		MOVE.B	    #',',(A2)+
		BRA	    CHECK_ADRESSIERUNG
EADN:		BTST	    #6,4(A1)
		BNE.S	    AUCH_AN
		MOVE.W	    D0,D3
		AND.W	    #$38,D3
		CMP.W	    #8,D3
		BEQ	    FailDis
AUCH_AN:	BSR	    WRITE_EA
		MOVE.B	    #',',(A2)+
		BSR	    GetRegister_2
		BRA	    WriteDn

*-------------------------------------------------------------------------------

DISASSEMBLER_5: BSR	    CHECK_ADRESSIERUNG
		MOVE.B	    #',',(A2)+
		MOVE.W	    D0,D3
		BSR	    GetRegister_2
		BRA	    WriteAn

*-------------------------------------------------------------------------------

DISASSEMBLER_6: BSR	    WRITE_L_IMMEDIATE
		MOVE.B	    #',',(A2)+
		BRA	    CHECK_ADRESSIERUNG

*-------------------------------------------------------------------------------

DISASSEMBLER_7: MOVE.W	    D0,D3
		LSL.L	    #7,D3
		SWAP	    D3
		AND.L	    #7,D3
		BNE.S	    KEINE_ACHT
		MOVEQ	    #8,D3
KEINE_ACHT:	BSR	    WRITE_IMMEDIATE
		MOVE.B	    #',',(A2)+
		BRA	    CHECK_ADRESSIERUNG

*-------------------------------------------------------------------------------

DISASSEMBLER_8: BSR	    WRITE_CC
		BSR	    GetRegister_1
		BSR	    WriteDn
		MOVE.B	    #',',(A2)+
		MOVE.W	    (A0)+,D3
		LEA	    -2(A0,D3.w),A6
		MOVE.L	    A6,D3
		BSR	    WRITE_HEXZAHL_SYMB
		BTST	    #0,D3
		SNE	    QuotationFlag-VB(a4)
		RTS

*-------------------------------------------------------------------------------

DISASSEMBLER_9: MOVE.W	    D0,D3
		CLR.B	    D3
		CMP.W	    #$6100,D3
		BNE.S	    NO_BSR
		BSET	    #7,DisassemblyFlags-VB(a4)
NO_BSR: 	LEA	    -8(A2),A5
		BSR	    WRITE_CC_BCC
		MOVEQ	    #0,D3
		MOVE.B	    #'.',(A5)+
		MOVE.B	    #'B',(A5)+
		MOVE.B	    D0,D3
		BNE.S	    SHORT
		MOVE.B	    #'W',-1(A5)
		MOVE.W	    (A0)+,D3
		LEA	    -2(A0,D3.w),A6	; -2, weil A0 + 2
		MOVE.L	    A6,D3
		BRA.S	    NOW_TOGETHER
SHORT:		MOVE.B	    DisassemCPU-VB(a4),-(SP)
		ANDI.B	    #%11111100,(SP)+
		BEQ.S	    SHORT_2

		CMP.B	    #$FF,D0
		BNE.S	    SHORT_2
		MOVE.B	    #'L',-1(A5)
		MOVE.L	    (A0)+,D3
		LEA	    -4(A0,D3.l),A6	; -4, weil A0 + 4
		MOVE.L	    A6,D3
		BRA.S	    NOW_TOGETHER
SHORT_2:	EXT.W	    D3
		LEA	    (A0,D3.w),A6
		MOVE.L	    A6,D3
NOW_TOGETHER:	BSR	    WRITE_HEXZAHL_SYMB
		MOVE.L	    A6,D3
		BTST	    #0,D3
		SNE	    QuotationFlag-VB(a4)
		RTS

*-------------------------------------------------------------------------------

DISASSEMBLER_10:BSR	    WRITE_CC
		BRA	    CHECK_ADRESSIERUNG

*-------------------------------------------------------------------------------

DISASSEMBLER_11:MOVEQ	    #8,D2
		MOVEQ	    #%111000,D3
		AND.W	    D0,D3
		BNE.S	    ITS_NOT_DN
		MOVEQ	    #32,D2
ITS_NOT_DN:	MOVE.W	    (A0)+,D3
		DIVU	    D2,D3
		CLR.W	    D3
		SWAP	    D3
		BSR	    WRITE_IMMEDIATE
		MOVE.B	    #',',(A2)+
		BRA	    CHECK_ADRESSIERUNG

*-------------------------------------------------------------------------------

DISASSEMBLER_12:BSR	    CHECK_ADRESSIERUNG
		MOVE.B	    #',',(A2)+
		BSR	    GetRegister_2
		BRA	    WriteDn

*-------------------------------------------------------------------------------

DISASSEMBLER_13:BSR	    GetRegister_2
		BTST	    #5,D0
		BEQ.S	    IMMEDIATE_SHIFT
		BSR	    WriteDn
		BRA.S	    CONT_SHIFT
IMMEDIATE_SHIFT:TST.W	    D3
		BNE.S	    IST_KEINE_ACHT
		MOVEQ	    #8,D3
IST_KEINE_ACHT: BSR	    WRITE_IMMEDIATE
CONT_SHIFT:	MOVE.B	    #',',(A2)+
		BSR	    GetRegister_1
		BRA	    WriteDn

*-------------------------------------------------------------------------------

DISASSEMBLER_14:MOVEQ	    #0,D3
		MOVE.W	    (A0)+,D3
		BTST	    #6,D0
		BEQ.S	    ZIEL_CCR
		MOVE.B	    #'#',(A2)+
		BSR	    WORD_MINUS
		BSR	    WRITE_HEXZAHL
		MOVE.B	    #',',(A2)+
		BRA	    WRITE_SR
ZIEL_CCR:	AND.W	    #$FF,D3
		MOVE.B	    #'#',(A2)+
		BSR	    BYTE_MINUS
		BSR	    WRITE_HEXZAHL
		MOVE.B	    #',',(A2)+
		BRA	    WRITE_CCR

*-------------------------------------------------------------------------------

DISASSEMBLER_15:BSR	    GetRegister_1
		BSR	    WRITE_ARI_POST
		MOVE.B	    #',',(A2)+
		BSR	    GetRegister_2
		BRA	    WRITE_ARI_POST

*-------------------------------------------------------------------------------

DISASSEMBLER_16:lea			WriteDn(pc),a5		; a5 = Rx
				lea			WriteAn(pc),a6		; a6 = Ry
				move.w		#%11111000,d3
				and.w		d0,d3				; Opmode ausmaskieren
				cmpi.w		#%1000000,d3		; Data/Data?
				beq.s		.gleich
				cmpi.w		#%10001000,d3		; Data/Address?
				beq.s		.cont
				cmpi.w		#%1001000,d3		; Address/Address?
				bne			FailDis
				movea.l		a6,a5
.gleich:		movea.l		a5,a6
.cont:			bsr.s		GetRegister_2		; Rx
				jsr			(a5)
				bsr.s		GetRegister_1		; Ry
				move.b		#',',(a2)+
				jmp			(a6)

*-------------------------------------------------------------------------------

DISASSEMBLER_17:MOVEQ	    #%1111,D3
		AND.W	    D0,D3
		BRA	    WRITE_IMMEDIATE

*-------------------------------------------------------------------------------

DISASSEMBLER_18:BSR.S	    GetRegister_1
		BRA	    WriteAn

*-------------------------------------------------------------------------------

DISASSEMBLER_19:BSR.S	    GetRegister_1
		BSR	    WriteAn
		BTST	    #3,D0
		BEQ.S	    WORD_LINK
		MOVE.L	    (A0)+,D3
		MOVE.B	    #',',(A2)+
		MOVE.B	    #'#',(A2)+
		BSR	    LONG_MINUS
		BRA	    WRITE_HEXZAHL
WORD_LINK:	MOVEQ	    #0,D3
		MOVE.W	    (A0)+,D3
		MOVE.B	    #',',(A2)+
		MOVE.B	    #'#',(A2)+
		BSR	    WORD_MINUS
		BRA	    WRITE_HEXZAHL

*-------------------------------------------------------------------------------

DISASSEMBLER_20:MOVEQ	    #0,D3
		MOVE.W	    (A0)+,D3
		BRA	    WRITE_IMMEDIATE

*-------------------------------------------------------------------------------

DISASSEMBLER_21:BSR	    WRITE_EA
		MOVE.B	    #',',(A2)+
		BSR.S	    GetRegister_2
		BRA	    WriteAn

GetRegister_1: MOVEQ	    #7,D3
		AND.W	    D0,D3
		RTS
GetRegister_2: MOVE.W	    D0,D3
		MOVEQ	    #9,D7
		LSR.W	    D7,D3
		AND.L	    #7,D3
		RTS

*-------------------------------------------------------------------------------

DISASSEMBLER_22:BTST	    #10,D0
		BEQ.S	    ZUERST_REGISTER
		MOVE.W	    (A0)+,-(SP)
		BSR	    CHECK_ADRESSIERUNG
		MOVE.B	    #',',(A2)+
		MOVE.W	    (SP)+,D4
		MOVEQ	    #15,D7
		BRA.S	    WRITE_REGISTER
ZUERST_REGISTER:MOVE.W	    (A0)+,D4
		MOVE.W	    D0,D3
		AND.W	    #$38,D3
		CMP.W	    #32,D3
		BNE.S	    KEIN_SPIEGELN
		MOVEQ	    #15,D7
		MOVE.W	    D4,D3
SPIEGELN:	ADD.W	    D3,D3
		ROXR.W	    #1,D4
		DBRA	    D7,SPIEGELN
KEIN_SPIEGELN:	MOVEQ	    #15,D7
		BSR.S	    WRITE_REGISTER
		MOVE.B	    #',',(A2)+
		BRA	    CHECK_ADRESSIERUNG

WRITE_REGISTER: MOVE.W	    D4,D6
		MOVE.W	    D7,D5
		BNE.S	    OK_SHIFT
		LSR.W	    #1,D6
		MOVEQ	    #1,D5
OK_SHIFT:	SUBQ.W	    #1,D5
		LSL.W	    D5,D6
		AND.W	    #$E000,D6
		MOVE.W	    D6,D5
		ADD.W	    D5,D5
		BEQ.S	    ABBRUCH
		BTST	    #14,D5
		BEQ.S	    ANFANG
		BTST	    #15,D5
		BEQ.S	    BACKSLASH
		TST.W	    D7
		BEQ.S	    LAST_ONE
		BTST	    #15,D6
		BNE.S	    ABBRUCH
LAST_ONE:	MOVE.B	    #'-',(A2)+
		BSR.S	    WRITE_ANDN
		BRA.S	    ABBRUCH
BACKSLASH:	MOVE.B	    #'/',(A2)+
		BRA.S	    ABBRUCH
ANFANG: 	BSR.S	    WRITE_ANDN
ABBRUCH:	DBRA	    D7,WRITE_REGISTER
		CMPI.B	    #'/',-1(A2)
		BNE.S	    NO_BACKSLASH
		MOVE.B	    #32,-(A2)
NO_BACKSLASH:	RTS

WRITE_ANDN:	MOVEQ	    #15,D3
		SUB.W	    D7,D3
		CMP.W	    #7,D3
		BLS.S	    DN_OK
		SUBQ.W	    #8,D3
		BRA	    WriteAn
DN_OK:		BRA	    WriteDn

*-------------------------------------------------------------------------------

DISASSEMBLER_23:BTST	    #7,D0
		BEQ.S	    ZUERST_SPEICHER
		BSR	    GetRegister_2
		BSR	    WriteDn
		MOVE.B	    #',',(A2)+
		BSR	    GetRegister_1
		BRA	    WriteAriDist
ZUERST_SPEICHER:BSR	    GetRegister_1
		BSR	    WriteAriDist
		MOVE.B	    #',',(A2)+
		BSR	    GetRegister_2
		BRA	    WriteDn

*-------------------------------------------------------------------------------

DISASSEMBLER_24:MOVEQ	    #0,D3
		MOVE.W	    #$FF,D3
		AND.W	    D0,D3
		BSR	    WRITE_IMMEDIATE
		MOVE.B	    #',',(A2)+
		BSR	    GetRegister_2
		BRA	    WriteDn

*-------------------------------------------------------------------------------

DISASSEMBLER_25:BSR	    GetRegister_1
		BTST	    #3,D0
		BEQ.S	    SOURCE_AN
		BSR	    WRITE_USP
		MOVE.B	    #',',(A2)+
		BRA	    WriteAn
SOURCE_AN:	BSR	    WriteAn
		MOVE.B	    #',',(A2)+
		BRA	    WRITE_USP

*-------------------------------------------------------------------------------

DISASSEMBLER_26:BTST	    #10,D0
		BNE.S	    SOURCE_EA
		BSR.S	    WRITE_SRCCR
		MOVE.B	    #',',(A2)+
		BRA	    CHECK_ADRESSIERUNG
SOURCE_EA:	BSR	    CHECK_ADRESSIERUNG
		MOVE.B	    #',',(A2)+

		BTST	    #9,D0
WRITE_SRCCR:	MOVE.W	    D0,D3
		AND.W	    #$0600,D3
		BEQ	    WRITE_SR
		CMP.W	    #$0600,D3
		BEQ	    WRITE_SR
		BRA	    WRITE_CCR

*-------------------------------------------------------------------------------

DISASSEMBLER_27:MOVE.B	    4(A1),D3
		AND.B	    #$F0,D3
		BNE.S	    KEIN_BYTE
		MOVEQ	    #$38,D3
		AND.W	    D0,D3
		CMP.W	    #8,D3
		BEQ	    FailDis
KEIN_BYTE:	BSR	    WRITE_EA
		MOVE.B	    #',',(A2)+
		MOVE.L	    D0,-(SP)
		LSR.W	    #3,D0
		AND.W	    #%111111000,D0
		MOVE.W	    D0,D3
		LSR.W	    #6,D3
		OR.W	    D3,D0
		BSR	    CHECK_ADRESSIERUNG
		MOVE.L	    (SP)+,D0
		RTS

*-------------------------------------------------------------------------------

DISASSEMBLER_28:MOVEQ	    #%111,D3
		AND.W	    D0,D3
		BRA	    WRITE_IMMEDIATE

*-------------------------------------------------------------------------------

DISASSEMBLER_29:MOVE.W	    (A0)+,D7
		MOVE.W	    #%111100000000,D3
		AND.W	    D0,D3
		CMP.W	    #$0F00,D3
		BNE.S	    NO_BFINS_1
		BSR.S	    WRITE_DATEN
		MOVE.B	    #',',(A2)+
		BRA.S	    WRITE_FIELD
NO_BFINS_1:	BSR.S	    WRITE_FIELD
		BTST	    #8,D0
		BEQ.S	    NO_SECOND_1
		MOVE.B	    #',',(A2)+
		BRA.S	    WRITE_DATEN
NO_SECOND_1:	RTS

WRITE_FIELD:	BSR	    CHECK_ADRESSIERUNG
		MOVE.W	    D7,D2
		MOVE.B	    #'{',(A2)+
		MOVE.W	    #%111111000000,D3
		AND.W	    D2,D3
		LSR.W	    #6,D3
		BSR.S	    WRITE_BITFIELD
		MOVE.B	    #':',(A2)+
		MOVEQ	    #%111111,D3
		AND.W	    D2,D3
		BNE.S	    NO_ZERO_WIDTH
		MOVEQ	    #32,D3
		BSR	    WRITE_HEXZAHL
		MOVE.B	    #'}',(A2)+
		RTS
NO_ZERO_WIDTH:	BSR.S	    WRITE_BITFIELD
		MOVE.B	    #'}',(A2)+
		RTS

WRITE_DATEN:	MOVEQ	    #12,D2
		MOVE.W	    D7,D4
		LSR.W	    D2,D4
		MOVEQ	    #%11111,D3
		AND.W	    D4,D3
		CMP.W	    #7,D3
		BHI	    FailDis
		BRA	    WriteDn

WRITE_BITFIELD: BTST	    #5,D3
		BNE.S	    DATEN_BITFIELD
		AND.W	    #%11111,D3
		BRA	    WRITE_HEXZAHL
DATEN_BITFIELD: AND.W	    #%11111,D3
		CMP.W	    #7,D3
		BHI	    FailDis
		BRA	    WriteDn

*-------------------------------------------------------------------------------

DISASSEMBLER_30:MOVEQ	    #0,D3
		MOVE.W	    (A0)+,D3
		AND.W	    #$FF,D3
		BSR	    WRITE_IMMEDIATE
		MOVE.B	    #',',(A2)+
		BRA	    CHECK_ADRESSIERUNG

*-------------------------------------------------------------------------------

DISASSEMBLER_31:MOVEQ	    #%111,D3
		MOVE.W	    (A0)+,D7
		AND.W	    D7,D3
		BSR	    WriteDn
		MOVE.B	    #',',(A2)+
		LSR.W	    #6,D7
		MOVEQ	    #%111,D3
		AND.W	    D7,D3
		BSR	    WriteDn
		MOVE.B	    #',',(A2)+
		BRA	    CHECK_ADRESSIERUNG

*-------------------------------------------------------------------------------

DISASSEMBLER_32:MOVE.W	    (A0)+,D6
		MOVE.W	    (A0)+,D7
		MOVEQ	    #%111,D3
		AND.W	    D6,D3
		BSR	    WriteDn
		MOVE.B	    #':',(A2)+
		MOVEQ	    #%111,D3
		AND.W	    D7,D3
		BSR	    WriteDn
		MOVE.B	    #',',(A2)+
		MOVE.W	    D6,D3
		LSR.L	    #6,D3
		AND.W	    #%111,D3
		BSR	    WriteDn
		MOVE.B	    #':',(A2)+
		MOVE.W	    D7,D3
		LSR.L	    #6,D3
		AND.W	    #%111,D3
		BSR	    WriteDn
		MOVE.B	    #',',(A2)+
		MOVE.B	    #'(',(A2)+
		MOVE.W	    D6,D3
		BSR	    WRITE_RN
		MOVE.B	    #')',(A2)+
		MOVE.B	    #':',(A2)+
		MOVE.B	    #'(',(A2)+
		MOVE.W	    D7,D3
		BSR	    WRITE_RN
		MOVE.B	    #')',(A2)+
		RTS

*-------------------------------------------------------------------------------

DISASSEMBLER_33:MOVE.W	    (A0)+,D7
		BTST	    #11,D7
		BEQ.S	    CMP2
		BTST	    #7,4(A1)
		BEQ	    FailDis
		BRA.S	    CHK2
CMP2:		BTST	    #7,4(A1)
		BNE	    FailDis
CHK2:		BSR	    CHECK_ADRESSIERUNG
		MOVE.B	    #',',(A2)+
		MOVE.W	    D7,D3
		BRA	    WRITE_RN

*-------------------------------------------------------------------------------

DISASSEMBLER_34:move.w		(a0)+,d7
				btst		#6,4(a1)
				beq.s		.DIVS
				btst		#11,d7
				bne			FailDis
				bra.s		.DIVU
.DIVS:			btst		#11,d7
				beq			FailDis

.DIVU:			bsr			CHECK_ADRESSIERUNG
				move.b		#',',(a2)+
				btst		#10,d7			; Size Field
				beq.s		.BIT32
				btst		#7,4(a1)
				bne			FailDis			; kein DIVx.L

				bsr.s		.GET_BOTH		; 64/32
				cmp.w		d2,d3
				bne.s		.cont
				st			AttentionFlag
.cont:			bsr			WriteDn
				move.b		#':',(a2)+
				move.w		d2,d3
				bra			WriteDn

.BIT32:			bsr.s		.GET_BOTH		; 32/xx
				btst		#7,4(a1)
				bne.s		.DIVSL
				btst		#6,d0
				beq.s		.MULU
				cmp.w		d2,d3
				bne			FailDis
.MULU:			move.w		d2,d3
				bra			WriteDn
.DIVSL:			cmp.w		d2,d3			; DIVSL und DIVUL
				beq			FailDis
				bra.s		.cont

.GET_BOTH:		moveq		#%111,d3		; D3:D2
				and.w		d7,d3			; d3 = dr
				moveq		#12,d2
				lsr.w		d2,d7
				moveq		#%111,d2
				and.w		d7,d2			; d2 = dq
				rts

*-------------------------------------------------------------------------------

DISASSEMBLER_35:MOVE.W	    (A0),D3
		BTST	    #0,D0
		BEQ.S	    SOURCE_CONTROL
		BSR	    WRITE_RN
		MOVE.B	    #',',(A2)+
		BRA.S	    WRITE_CONTROL
SOURCE_CONTROL: BSR.S	    WRITE_CONTROL
		MOVE.B	    #',',(A2)+
		BRA	    WRITE_RN

WRITE_CONTROL:	MOVE.W	    (A0)+,D3
		MOVE.W	    D3,D2
		AND.W	    #$0FFF,D2
		CMP.W	    #7,D2
		BLS.S	    LOWER_CR
		SUB.W	    #$0800,D2
		BMI	    FailDis
		CMP.W	    #7,D2
		BHI	    FailDis
		LEA	    CR_TABLE_21,A5
		LEA	    CR_TABLE_22,A6
		BRA.S	    CHECK_CR
LOWER_CR:	LEA	    CR_TABLE_11,A5
		LEA	    CR_TABLE_12,A6
CHECK_CR:	MOVE.B	    DisassemCPU-VB(a4),D3
		AND.B	    (A6,D2.w),D3
		BEQ	    FailDis
		ADD.W	    D2,D2
		MOVE.W	    (A5,D2.w),D2
		JMP	    (A5,D2.w)

*---------------

CR_TABLE_11:			dc.W WRITE_SFC-CR_TABLE_11
				dc.W WRITE_DFC-CR_TABLE_11
				dc.W WRITE_CACR-CR_TABLE_11
				dc.W WRITE_TC-CR_TABLE_11
				dc.W WRITE_ITT0-CR_TABLE_11
				dc.W WRITE_ITT1-CR_TABLE_11
				dc.W WRITE_DTT0-CR_TABLE_11
				dc.W WRITE_DTT1-CR_TABLE_11
CR_TABLE_12:			dc.B %11110
				dc.B %11110
				dc.B %11100
				dc.B %10000
				dc.B %10000
				dc.B %10000
				dc.B %10000
				dc.B %10000

CR_TABLE_21:			dc.W WRITE_USP-CR_TABLE_21
				dc.W WRITE_VBR-CR_TABLE_21
				dc.W WRITE_CAAR-CR_TABLE_21
				dc.W WRITE_MSP-CR_TABLE_21
				dc.W WRITE_ISP-CR_TABLE_21
				dc.W WRITE_MMUSR-CR_TABLE_21
				dc.W WRITE_URP-CR_TABLE_21
				dc.W WRITE_SRP-CR_TABLE_21
CR_TABLE_22:			dc.B %11110
				dc.B %11110
				dc.B %1100
				dc.B %11100
				dc.B %11100
				dc.B %10000
				dc.B %10000
				dc.B %10000

*-------------------------------------------------------------------------------

DISASSEMBLER_36:MOVE.W	    (A0)+,D3
		BTST	    #11,D3
		BEQ.S	    FROM_EA
		BSR	    WRITE_RN
		MOVE.B	    #',',(A2)+
		BRA	    CHECK_ADRESSIERUNG
FROM_EA:	MOVE.W	    D3,D7
		BSR	    CHECK_ADRESSIERUNG
		MOVE.B	    #',',(A2)+
		MOVE.W	    D7,D3
		BRA	    WRITE_RN

*-------------------------------------------------------------------------------

DISASSEMBLER_37:LEA	    WriteDn,A6
		BTST	    #3,D0
		BEQ.S	    PACK_DATA
		LEA	    WRITE_ARI_PRE,A6
PACK_DATA:	MOVEQ	    #%111,D3
		AND.W	    D0,D3
		JSR	    (A6)
		MOVE.B	    #',',(A2)+
		MOVE.W	    D0,D3
		MOVEQ	    #9,D2
		LSR.W	    D2,D3
		AND.W	    #%111,D3
		JSR	    (A6)
		MOVE.B	    #',',(A2)+
		MOVEQ	    #0,D3
		MOVE.W	    (A0)+,D3
		BRA	    WRITE_IMMEDIATE

*-------------------------------------------------------------------------------

DISASSEMBLER_38:BSR	    WRITE_CC
		BTST	    #2,D0
		BNE.S	    NO_DATA
		CMP.W	    #2,D3
		BHI.S	    TWO_LONG
		SUBQ.W	    #1,A5
TWO_LONG:	MOVE.B	    #'.',(A5)+
		MOVE.B	    #'W',(A5)
		BTST	    #0,D0
		BEQ.S	    ONLY_ONE_WORD
		MOVE.B	    #'L',(A5)
		MOVE.L	    (A0)+,D3
		BRA	    WRITE_IMMEDIATE
ONLY_ONE_WORD:	MOVE.W	    (A0)+,D3
		BRA	    WRITE_IMMEDIATE
NO_DATA:	RTS

*-------------------------------------------------------------------------------

DISASSEMBLER_40:BTST	    #5,D0
		BNE.S	    POST_MOVE16
		BTST	    #3,D0
		BNE.S	    IMM_ARI
		BSR.S	    MOVE16_ARI
		MOVE.B	    #',',(A2)+
		BRA	    WriteAbsLong

IMM_ARI:	BSR	    WriteAbsLong
		MOVE.B	    #',',(A2)+
MOVE16_ARI:	BSR	    GetRegister_1
		BTST	    #4,D0
		BEQ	    WRITE_ARI_POST
		BRA	    WriteAri

POST_MOVE16:	BSR	    GetRegister_1
		BSR	    WRITE_ARI_POST
		MOVE.B	    #',',(A2)+
		MOVE.W	    #%1000111111111111,D3
		MOVE.W	    D3,D2
		AND.W	    (A0),D2
		CMP.W	    #$8000,D2
		BNE	    FailDis
		NOT.W	    D3
		AND.W	    (A0)+,D3
		MOVEQ	    #12,D2
		LSR.W	    D2,D3
		BRA	    WRITE_ARI_POST

*-------------------------------------------------------------------------------

DISASSEMBLER_41:MOVE.B	    #'N',(A2)
		MOVE.W	    D0,D3
		LSR.W	    #6,D3
		AND.W	    #%11,D3
		BEQ.S	    CACHE_IO
		MOVE.B	    #'D',(A2)
		SUBQ.W	    #1,D3
		BEQ.S	    CACHE_IO
		MOVE.B	    #'I',(A2)
		SUBQ.W	    #1,D3
		BEQ.S	    CACHE_IO
		MOVE.B	    #'B',(A2)
CACHE_IO:	ADDQ.W	    #1,A2
		MOVE.B	    #'C',(A2)+
		MOVEQ	    #%11000,D3
		AND.W	    D0,D3
		CMP.W	    #%11000,D3
		BEQ.S	    ALL_CACHE
		MOVE.B	    #',',(A2)+
		BSR	    GetRegister_1
		BRA	    WriteAri
ALL_CACHE:	RTS

*-------------------------------------------------------------------------------

DISASSEMBLER_42:MOVE.W	    (A0)+,D7
		TST.B	    D7
		BNE	    FailDis

		LSR.W	    #8,D7
		BTST	    #1,D7
		BEQ.S	    MEMORY_MMU
		BTST	    #0,D7
		BNE	    FailDis
		CMP.B	    #%1100010,D7
		BEQ.S	    MMUSR_MEMORY
		BSR.S	    WRITE_MMU
		MOVE.B	    #',',(A2)+
		BRA	    CHECK_ADRESSIERUNG

MEMORY_MMU:	CMP.B	    #%1100000,D7
		BEQ.S	    MEMORY_MMUSR
		BTST	    #0,D7
		BEQ.S	    NO_FD
		MOVE.B	    #'F',-6(A2)
		MOVE.B	    #'D',-5(A2)
NO_FD:		BSR	    CHECK_ADRESSIERUNG
		MOVE.B	    #',',(A2)+
WRITE_MMU:	MOVE.W	    D7,D3
		AND.B	    #%11100000,D3
		BEQ.S	    TT_REGISTERS
		CMP.B	    #%1000000,D3
		BNE	    FailDis
		BSR.S	    GET_MMU
		BEQ	    WRITE_TC
		SUBQ.W	    #2,D3
		BEQ	    WRITE_SRP
		SUBQ.W	    #1,D3
		BEQ	    WRITE_CRP
		BRA	    FailDis

TT_REGISTERS:	BSR.S	    GET_MMU
		SUBQ.W	    #2,D3
		BEQ	    WRITE_TT0
		SUBQ.W	    #1,D3
		BEQ	    WRITE_TT1
		BRA	    FailDis

MEMORY_MMUSR:	BSR	    CHECK_ADRESSIERUNG
		MOVE.B	    #',',(A2)+
		BRA	    WRITE_MMUSR

MMUSR_MEMORY:	BSR	    WRITE_MMUSR
		MOVE.B	    #',',(A2)+
		BSR	    CHECK_ADRESSIERUNG

GET_MMU:	MOVEQ	    #%11100,D3
		AND.W	    D7,D3
		LSR.W	    #2,D3
		RTS

*-------------------------------------------------------------------------------

DISASSEMBLER_43:move.b		(a0),d3
				cmp.b		#%00100100,d3
				beq.s		PFLUSHA
				cmp.b		#%00110000,d3
				beq.s		PFLUSH_FC
				cmp.b		#%00111000,d3
				bne			FailDis

PFLUSH_FC_EA:	bsr.s		PFLUSH_FC
				move.b		#',',(a2)+
				bra			CHECK_ADRESSIERUNG

PFLUSHA:		tst.b		1(a0)
				bne			FailDis
				addq.w		#2,a0
				move.b		#'A',-DISSTRING_DISTANZ-2(a2)
				rts

PFLUSH_FC:		move.w		(a0)+,d7
				bsr.s		FC_WRITE		; FC schreiben
				move.b		#',',(a2)+
				moveq		#0,d3
				move.b		-1(a0),d3		; Maske schreiben
				lsr.w		#5,d3
				bra			WRITE_IMMEDIATE

*-------------------------------------------------------------------------------

DISASSEMBLER_44:bsr			GetRegister_1
				bra			WriteAri

*-------------------------------------------------------------------------------

DISASSEMBLER_45:bsr.s	    TestRW
				move.w		d7,d3
				and.w		#%1111110111100000,d3
				cmp.w		#%0010000000000000,d3
				bne			FailDis
				bsr.s		FC_WRITE
				move.b	    #',',(a2)+
				bra			CHECK_ADRESSIERUNG

FC_WRITE:		moveq		#%11111,D3
				and.w		d7,d3			; FC ausmaskieren
				beq			WRITE_SFC
				cmp.w		#1,d3
				beq			WRITE_DFC
				moveq		#%11000,D7
				and.w		d3,d7			; Bit 3/4 ausmaskieren
				lsr.w		#3,d7
				and.w		#%111,d3		; Bit 0/1/2 ausmaskieren
				subq.w		#1,d7
				beq			WriteDn			; Datenregister DDD
				subq.w		#1,d7
				beq			WRITE_IMMEDIATE
				BRA			FailDis

TestRW:			move.w		(a0)+,d7
				cmpi.b		#'W',-DISSTRING_DISTANZ-3(a2)
				beq.s		ITS_A_W
				btst		#9,d7
				beq.s		FAIL_RW
				rts
ITS_A_W:		btst		#9,d7
				bne.s		FAIL_RW
				rts
FAIL_RW:		addq.w		#4,sp
				bra.s		FailDis

*-------------------------------------------------------------------------------

DISASSEMBLER_46:MOVE.W	    #$E000,D3
		AND.W	    (A0),D3
		CMP.W	    #$8000,D3
		BNE.S	    FailDis
		BSR.S	    TestRW
		BSR.S	    FC_WRITE
		MOVE.B	    #',',(A2)+
		BSR.S	    CHECK_ADRESSIERUNG
		MOVE.B	    #',',(A2)+
		MOVE.W	    -(A0),D7
		MOVEQ	    #%11100,D3
		AND.B	    (A0),D3
		BNE.S	    LEVEL_GT_ZERO
		AND.W	    #$01E0,D7
		BNE.S	    FailDis
		BRA	    WRITE_IMMEDIATE
LEVEL_GT_ZERO:	LSR.W	    #2,D3
		ADDQ.W	    #2,A0
		BTST	    #8,D7
		BEQ	    WRITE_IMMEDIATE
		BSR	    WRITE_IMMEDIATE
		MOVE.B	    #',',(A2)+
		LSR.W	    #5,D7
		MOVEQ	    #%111,D3
		AND.W	    D7,D3
		BRA	    WriteAn

*-------------------------------------------------------------------------------

DISASSEMBLER_47:BSR	    GetRegister_1
		BRA	    WriteAri

*-------------------------------------------------------------------------------

CHECK_ADRESSIERUNG:
		MOVE.W	    4(A1),D2
		MOVEQ	    #$38,D3
		AND.W	    D0,D3
		LSR.W	    #3,D3
		CMP.W	    #7,D3
		BEQ.S	    OHNE_REGISTER
		MOVE.B	    CHECK_1(PC,D3.w),D3
		BTST	    D3,D2
		BEQ.S	    FailDis
		BRA	    WRITE_EA
OHNE_REGISTER:	MOVEQ	    #7,D3
		AND.W	    D0,D3
		MOVE.B	    CHECK_2(PC,D3.w),D3
		BTST	    D3,D2
		BNE	    WRITE_EA
FailDis:	SF	    DisassemblyFlag-VB(a4)
		RTS

*---------------

CHECK_1:			dc.B 11,10,9,8,7,6,5
CHECK_2:			dc.B 4,3,2,1,0,15,15,15
			EVEN

*-------------------------------------------------------------------------------

WRITE_QUOTE:	MOVE.B	    #'?',(A2)+
		MOVE.B	    #'?',(A2)+
		MOVE.B	    #'?',(A2)+
		RTS

WRITE_CCR:	MOVE.B	    #'C',(A2)+		; 00-40
WRITE_CR:	MOVE.B	    #'C',(A2)+
WRITE_R:	MOVE.B	    #'R',(A2)+
		RTS

WRITE_SR:	MOVE.B	    #'S',(A2)+		; 00-40
		BRA.S	    WRITE_R

WRITE_SFC:	MOVE.B	    #'S',(A2)+		; 10-40
		BRA.S	    WRITE_FC

WRITE_DFC:	MOVE.B	    #'D',(A2)+		; 10-40
WRITE_FC:	MOVE.B	    #'F',(A2)+
WRITE_C:	MOVE.B	    #'C',(A2)+
		RTS

WRITE_USP:	MOVE.B	    #'U',(A2)+		; 10-40
		BRA.S	    WRITE_SP

WRITE_VBR:	MOVE.B	    #'V',(A2)+		; 10-40
		MOVE.B	    #'B',(A2)+
		BRA.S	    WRITE_R

WRITE_CACR:	MOVE.B	    #'C',(A2)+		; 20-40
		MOVE.B	    #'A',(A2)+
		BRA.S	    WRITE_CR

WRITE_CAAR:	BSR.S	    WRITE_CACR
		MOVE.B	    #'A',-2(A2)
		RTS

WRITE_MSP:	MOVE.B	    #'M',(A2)+		; 20-40
		BRA.S	    WRITE_SP

WRITE_ISP:	MOVE.B	    #'I',(A2)+		; 20-40
WRITE_SP:	MOVE.B	    #'S',(A2)+
WRITE_P:	MOVE.B	    #'P',(A2)+
		RTS

WRITE_TC:	MOVE.B	    #'T',(A2)+		; 30/40
		BRA.S	    WRITE_C

WRITE_MMUSR:	MOVE.B	    #'M',(A2)+		; 30/40
		MOVE.B	    #'M',(A2)+
		MOVE.B	    #'U',(A2)+
		BRA.S	    WRITE_SR

WRITE_SRP:	MOVE.B	    #'S',(A2)+		; 30/40
		BRA.S	    WRITE_RP

WRITE_TT0:	BSR.S	    WRITE_TT		; 30
WRITE_NULL:	MOVE.B	    #'0',(A2)+
		RTS

WRITE_TT1:	BSR.S	    WRITE_TT		; 30
WRITE_EINS:	MOVE.B	    #'1',(A2)+
		RTS

WRITE_CRP:	MOVE.B	    #'C',(A2)+		; 30
		BRA.S	    WRITE_RP

WRITE_URP:	MOVE.B	    #'U',(A2)+		; 40
WRITE_RP:	MOVE.B	    #'R',(A2)+
		BRA.S	    WRITE_P

WRITE_ITT0:	BSR.S	    WRITE_ITT		; 40
		BRA.S	    WRITE_NULL

WRITE_ITT1:	BSR.S	    WRITE_ITT		; 40
		BRA.S	    WRITE_EINS

WRITE_ITT:	MOVE.B	    #'I',(A2)+
WRITE_TT:	MOVE.B	    #'T',(A2)+
		MOVE.B	    #'T',(A2)+
		RTS

WRITE_DTT0:	BSR.S	    WRITE_DTT		; 40
		BRA.S	    WRITE_NULL

WRITE_DTT1:	BSR.S	    WRITE_DTT		; 40
		BRA.S	    WRITE_EINS

WRITE_DTT:	MOVE.B	    #'D',(A2)+
		BRA.S	    WRITE_TT

*-------------------------------------------------------------------------------

WRITE_RN:	LSR.W	    #8,D3
		LSR.W	    #4,D3
		CMP.W	    #8,D3
		BLO.S	    WriteDn
		SUBQ.W	    #8,D3
		BRA.S	    WriteAn

*-------------------------------------------------------------------------------

WriteDn:	MOVE.B	    #'D',(A2)+
		ADD.B	    #48,D3
		MOVE.B	    D3,(A2)+
		RTS

*-------------------------------------------------------------------------------

WriteAn:	MOVE.B	    #'A',(A2)+
		ADD.B	    #48,D3
		MOVE.B	    D3,(A2)+
		RTS

*-------------------------------------------------------------------------------

WriteAri:	MOVE.B	    #'(',(A2)+
		BSR.S	    WriteAn
		MOVE.B	    #')',(A2)+
		RTS

*-------------------------------------------------------------------------------

WRITE_ARI_POST: BSR.S	    WriteAri
		MOVE.B	    #'+',(A2)+
		RTS

*-------------------------------------------------------------------------------

WRITE_ARI_PRE:	MOVE.B	    #'-',(A2)+
		BRA.S	    WriteAri

*-------------------------------------------------------------------------------

WRITE_OFFSET:
			TST.B		PcAnFlag-VB(a4)
			BEQ			WRITE_HEXZAHL
			EXT.L		D3
			ADD.L		A3,D3		; bei PC-Relativ kommt die
			ADDQ.L		#2,D3		; Adresse, nicht der Offset
			BRA			WRITE_HEXZAHL_SYMB

*-------------------------------------------------------------------------------

WriteAriDist:
		MOVE.B	    #'(',(A2)+
		MOVE.W	    D3,-(SP)
		MOVEQ	    #0,D3
		MOVE.W	    (A0)+,D3
		TST.B	    PcAnFlag-VB(a4)
		BNE.S	    NO_PC_1
		BSR	    WORD_MINUS
NO_PC_1:BSR.S	    WRITE_OFFSET
		MOVE.W	    (SP)+,D3
		MOVE.B	    #',',(A2)+
		BSR	    WRITE_PC_AN
		MOVE.B	    #')',(A2)+
		RTS

*-------------------------------------------------------------------------------

WRITE_INDEX:	MOVE.B	    #',',(A2)+
		MOVE.L	    D3,-(SP)
		MOVE.L	    D2,D3
		MOVEQ	    #12,D1
		LSR.W	    D1,D3
		CMP.W	    #7,D3
		BHI.S	    ADRESS_REG
		BSR	    WriteDn
		BRA.S	    DATEN_REG
ADRESS_REG:	SUBQ.W	    #8,D3
		BSR.S	    WriteAn
DATEN_REG:	MOVE.B	    #'.',(A2)+
		MOVE.B	    #'L',(A2)+
		BTST	    #11,D2
		BNE.S	    LONG_OFFSET
		MOVE.B	    #'W',-1(A2)
LONG_OFFSET:	MOVE.B	    DisassemCPU-VB(a4),-(SP)
		ANDI.B	    #%11111100,(SP)+
		BEQ.S	    WRITE_NO_SCALE
		MOVE.W	    #%11000000000,D1
		AND.W	    D2,D1
		MOVEQ	    #9,D4
		LSR.W	    D4,D1
		BEQ.S	    WRITE_NO_SCALE
		MOVEQ	    #1,D4
		LSL.W	    D1,D4
		ADD.B	    #'0',D4
		MOVE.B	    #'*',(A2)+
		MOVE.B	    D4,(A2)+
WRITE_NO_SCALE: MOVE.L	    (SP)+,D3
		RTS

WRITE_OUTER:	MOVE.L	    D3,-(SP)
		MOVEQ	    #%11,D1
		AND.W	    D2,D1
		BEQ.S	    FORMAT_ERROR
		SUBQ.W	    #1,D1
		BEQ.S	    NULL_OUTER
		MOVE.B	    #',',(A2)+
		SUBQ.W	    #1,D1
		BEQ.S	    WORD_OUTER
		MOVE.L	    (A0)+,D3
		BSR	    LONG_MINUS
		BSR	    WRITE_HEXZAHL
		BRA.S	    NULL_OUTER
WORD_OUTER:	MOVEQ	    #0,D3
		MOVE.W	    (A0)+,D3
		BSR	    WORD_MINUS
		BSR	    WRITE_HEXZAHL
NULL_OUTER:	MOVE.L	    (SP)+,D3
		RTS

WRITE_BASE:	MOVE.L	    D3,-(SP)
		MOVEQ	    #%110000,D1
		AND.W	    D2,D1
		LSR.W	    #4,D1
		BEQ.S	    FORMAT_ERROR
		SUBQ.W	    #1,D1
		BEQ.S	    NULL_BASE
		SUBQ.W	    #1,D1
		BEQ.S	    WORD_BASE
		MOVE.L	    (A0)+,D3
		TST.B	    PcAnFlag-VB(a4)
		BNE.S	    PC_BASE
		BSR	    LONG_MINUS
		BRA.S	    LONG_BASE
WORD_BASE:	MOVEQ	    #0,D3
		MOVE.W	    (A0)+,D3
		TST.B	    PcAnFlag-VB(a4)
		BNE.S	    PC_BASE
		BSR	    WORD_MINUS
		BRA.S	    LONG_BASE
PC_BASE:	EXT.L	    D3
		ADD.L	    A3,D3		; bei PC-Relativ kommt die
		ADDQ.L	    #2,D3		; Adresse, nicht der Offset
LONG_BASE:	BSR	    WRITE_HEXZAHL
		MOVE.B	    #',',(A2)+
NULL_BASE:	MOVE.L	    (SP)+,D3
		RTS
FORMAT_ERROR:	MOVE.L	    (SP)+,D3
		SF	    DisassemblyFlag-VB(a4)
		RTS

*-------------------------------------------------------------------------------

WriteAriDiIn: MOVE.B	    #'(',(A2)+
		MOVEQ	    #0,D2
		MOVE.W	    (A0)+,D2
		MOVE.B	    DisassemCPU-VB(a4),-(SP)
		ANDI.B	    #%11111100,(SP)+
		BEQ.S	    FORMAT_68000
		BTST	    #8,D2
		BEQ.S	    FORMAT_68000	; Brief Format Extension Word

		MOVEQ	    #%111,D1		; Full Format Extension Word
		AND.W	    D2,D1
		BEQ.S	    NO_INDIRECTION
		MOVE.B	    #'[',(A2)+
		BSR.S	    WRITE_BASE		; Base Displacement
		BTST	    #7,D2
		BEQ.S	    ITS_BASE_REG
		MOVE.B	    #'Z',(A2)+
ITS_BASE_REG:	BSR	    WRITE_PC_AN 	; Base Register
		BTST	    #2,D2
		BEQ.S	    PRE_INDEXED
		MOVE.B	    #']',(A2)+
		BTST	    #6,D2
		BEQ.S	    INDEX_IO
		ST	    AttentionFlag-VB(a4)
		BRA.S	    CONT_DIS
INDEX_IO:	BSR	    WRITE_INDEX 	; Index + Skalierung
		BRA.S	    CONT_DIS
PRE_INDEXED:	BTST	    #6,D2
		BNE.S	    NO_INDEX_2
		BSR	    WRITE_INDEX 	; Index + Skalierung
NO_INDEX_2:	MOVE.B	    #']',(A2)+
CONT_DIS:	BSR	    WRITE_OUTER 	; Outer Displacement
		MOVE.B	    #')',(A2)+
		RTS


NO_INDIRECTION: BSR	    WRITE_BASE		; Base Displacement
		BTST	    #7,D2
		BEQ.S	    BASE_REGISTER
		MOVE.B	    #'Z',(A2)+
BASE_REGISTER:	BSR.S	    WRITE_PC_AN 	; Base Register
		BTST	    #6,D2
		BNE.S	    NO_INDEX_1
		BSR	    WRITE_INDEX 	; Index + Skalierung
NO_INDEX_1:	MOVE.B	    #')',(A2)+
		RTS


FORMAT_68000:	MOVE.L	    D3,-(SP)
		MOVEQ	    #0,D3
		MOVE.B	    D2,D3
		TST.B	    PcAnFlag-VB(a4)
		BNE.S	    NO_PC_2
		BSR	    BYTE_MINUS
NO_PC_2:	BSR	    WRITE_OFFSET	; Base Displacement
		MOVE.B	    #',',(A2)+
		MOVE.L	    (SP),D3
		BSR.S	    WRITE_PC_AN 	; Base Register
		BSR	    WRITE_INDEX 	; Index + Skalierung
		MOVE.B	    #')',(A2)+
		MOVE.L	    (SP)+,D3
		RTS

*-------------------------------------------------------------------------------

WRITE_PC_AN:	TST.B	    PcAnFlag-VB(a4)
		BEQ	    WriteAn
		MOVE.B	    #'P',(A2)+
		MOVE.B	    #'C',(A2)+
		RTS

*-------------------------------------------------------------------------------

WRITE_PC_DIST:	ST	    PcAnFlag-VB(a4)
		BSR	    WriteAriDist
		SF	    PcAnFlag-VB(a4)
		RTS

*-------------------------------------------------------------------------------

WRITE_PC_DIIN:	ST	    PcAnFlag-VB(a4)
		BSR	    WriteAriDiIn
		SF	    PcAnFlag-VB(a4)
		RTS

*-------------------------------------------------------------------------------

WriteAbsShort: MOVE.W	    (A0)+,D3
		EXT.L	    D3
		BSR	    LONG_MINUS
		BSR.S	    WRITE_HEXZAHL_SYMB
		MOVE.B	    #'.',(A2)+
		MOVE.B	    #'W',(A2)+
		RTS

*-------------------------------------------------------------------------------

WriteAbsLong:	MOVE.L	    (A0)+,D3
		BSR	    LONG_MINUS
		BRA.S	    WRITE_HEXZAHL_SYMB

*-------------------------------------------------------------------------------

WORD_LAENGE:	MOVE.W	(A0)+,D3
		MOVE.B	#'#',(A2)+
		BTST	#4,4(A1)
		BEQ.S	ONLY_A_BYTE
		BSR	    WORD_MINUS
		BRA.S	    WRITE_HEXZAHL
ONLY_A_BYTE:	AND.W	    #$FF,D3
		BSR	    BYTE_MINUS
		BRA.S	    WRITE_HEXZAHL
WRITE_L_IMMEDIATE:
		MOVEQ	    #0,D3
		BTST	    #5,4(A1)
		BEQ.S	    WORD_LAENGE
		MOVE.L	    (A0)+,D3
		MOVE.B	    #'#',(A2)+
		BSR	    LONG_MINUS
		BRA.S	    WRITE_HEXZAHL

WRITE_IMMEDIATE:MOVE.B	    #'#',(A2)+
		BRA.S	    WRITE_HEXZAHL

*-------------------------------------------------------------------------------

WRITE_HEXZAHL_SYMB:MOVEM.L  A0-A1,-(SP)
		JSR	    SEARCH_SYMBOL
		BEQ.S	    KEIN_SYMBOL_4
		MOVE.B	    #'.',(A2)+
WRITE_SYMBOL_4: MOVE.B	    (A0)+,(A2)+
		BNE.S	    WRITE_SYMBOL_4
		MOVE.B	    #32,-(A2)
		MOVEM.L     (SP)+,A0-A1
		RTS

KEIN_SYMBOL_4:
		MOVEM.L     (SP)+,A0-A1
WRITE_HEXZAHL:	MOVEM.L     D1-D3/D7,-(SP)
		SF	    PcFlag-VB(a4)
		CMP.L	    #9,D3
		BLS.S	    KEIN_HEX
		MOVE.B	    #'$',(A2)+
KEIN_HEX:	MOVE.L	    A2,-(SP)
		MOVEQ	    #7,D7
		MOVEQ	    #12,D1
W_HEXZAHL:	MOVE.L	    D3,D2
		LSL.L	    #4,D3
		SWAP	    D2
		LSR.W	    D1,D2
		BNE.S	    WRITE_IT
		TST.B	    PcFlag-VB(a4)
		BEQ.S	    NEXT_ONE
WRITE_IT:	MOVE.B	    HEX_TABELLE(PC,D2.w),(A2)+
		ST	    PcFlag-VB(a4)
NEXT_ONE:	DBRA	    D7,W_HEXZAHL
		CMPA.L	    (SP)+,A2
		BNE.S	    ENDE_HEXZAHL
		MOVE.B	    #'0',(A2)+
ENDE_HEXZAHL:	MOVEM.L     (SP)+,D1-D3/D7
		RTS

*---------------

HEX_TABELLE:			dc.B '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'

*-------------------------------------------------------------------------------

BYTE_MINUS:	TST.B	    D3
		BPL.S	    ITS_A_PLUS
		CMP.B	    #-9,D3
		BLT.S	    ITS_A_PLUS
		NEG.B	    D3
ITS_A_MINUS:	MOVE.B	    #'-',(A2)+
		RTS
WORD_MINUS:	TST.W	    D3
		BPL.S	    ITS_A_PLUS
		CMP.W	    #-9,D3
		BLT.S	    ITS_A_PLUS
		NEG.W	    D3
		BRA.S	    ITS_A_MINUS
LONG_MINUS:	TST.L	    D3
		BPL.S	    ITS_A_PLUS
		CMP.L	    #-9,D3
		BLT.S	    ITS_A_PLUS
		NEG.L	    D3
		BRA.S	    ITS_A_MINUS
ITS_A_PLUS:	RTS

*-------------------------------------------------------------------------------

* Achtung: rettet keine Register!
WRITE_EA:	MOVE.W	    D0,D3
		AND.W	    #$3F,D3
		MOVE.W	    D3,D2
		AND.W	    #7,D3
		LSR.W	    #3,D2
		ADD.W	    D2,D2
		MOVE.W	    EA_TABELLE(PC,D2.w),D2
		JMP	    EA_TABELLE(PC,D2.w)
NEXT_SPRUNG:	ADD.W	    D3,D3
		MOVE.W	    EA_TABELLE_2(PC,D3.w),D3
		JMP	    EA_TABELLE_2(PC,D3.w)

*---------------

EA_TABELLE:			dc.W WriteDn-EA_TABELLE,WriteAn-EA_TABELLE,WriteAri-EA_TABELLE,WRITE_ARI_POST-EA_TABELLE,WRITE_ARI_PRE-EA_TABELLE
				dc.W WriteAriDist-EA_TABELLE,WriteAriDiIn-EA_TABELLE,NEXT_SPRUNG-EA_TABELLE
EA_TABELLE_2:			dc.W WriteAbsShort-EA_TABELLE_2,WriteAbsLong-EA_TABELLE_2,WRITE_PC_DIST-EA_TABELLE_2,WRITE_PC_DIIN-EA_TABELLE_2
				dc.W WRITE_L_IMMEDIATE-EA_TABELLE_2,FAIL_ADRESS-EA_TABELLE_2,FAIL_ADRESS-EA_TABELLE_2,FAIL_ADRESS-EA_TABELLE_2

*---------------

FAIL_ADRESS:	SF	    DisassemblyFlag-VB(a4)
		RTS

*-------------------------------------------------------------------------------

WRITE_CC_BCC:	MOVE.L	    #'RASR',CONDITION_CODE_1
		BRA.S	    CONT_CC
WRITE_CC:	MOVE.L	    #'T F ',CONDITION_CODE_1
CONT_CC:	BSR.S	    SEARCH_BACK
		MOVE.W	    D0,D3
		LSR.W	    #8,D3
		AND.W	    #15,D3
		ADD.W	    D3,D3
		MOVE.B	    CONDITION_CODE_1(PC,D3.w),(A5)+
		MOVE.B	    CONDITION_CODE_1+1(PC,D3.w),(A5)+
		RTS

*---------------

CONDITION_CODE_1:dc.B 'T ','F ','HI','LS','CC','CS','NE','EQ','VC','VS'
				dc.B 'PL','MI','GE','LT','GT','LE'

*-------------------------------------------------------------------------------

* <--- A5.l = erstes Space nach dem Befehl
SEARCH_BACK:	MOVEA.L     A2,A5
S_SPACE:	CMPI.B	    #32,-(A5)
		BEQ.S	    S_SPACE
		ADDQ.W	    #1,A5
		RTS


DISASSEMBLER_48:MOVE.W	    (A0)+,D3
		MOVEQ	    #%1111111,D2
		AND.W	    D3,D2
		CMP.B	    5(A1),D2
		BNE	    FailDis
		MOVE.W	    #%1010000000000000,D2
		AND.W	    D3,D2
		BNE	    FailDis
		BSR.S	    SEARCH_BACK
		MOVE.B	    #'.',(A5)+
		BTST	    #14,D3
		BEQ.S	    REG_TO_REG

*-------------- Fxxxxx.<fmt> <ea>,FPn

		MOVE.W	    #%1110000000000,D2
		AND.W	    D3,D2
		ROL.W	    #6,D2
		MOVE.B	    FMT_1(PC,D2.w),(A5)+
		BMI	    FailDis
		MOVEQ	    #%111000,D1
		AND.W	    D0,D1
		BNE.S	    NOT_F_DN_1
		MOVE.B	    FMT_2(PC,D2.w),D2
		BEQ	    FailDis
NOT_F_DN_1:	CMP.B	    #%1000,D1
		BEQ	    FailDis
		MOVE.W	    D3,-(SP)
		BSR	    WRITE_EA
		MOVE.W	    (SP)+,D3
		TST.B	    4(A1)
		BGT	    rts
		MOVE.B	    #',',(A2)+
		BRA	    WRITE_FP2
rts:	rts

*---------------

FMT_1:				dc.B 'L','S','X','P','W','D','B',-1
FMT_2:				dc.B -1,-1,0,0,-1,0,-1,0

*-------------- Fxxxxx.X FPm,FPn

REG_TO_REG:	MOVE.B	    #'X',(A5)+
		BSR	    WRITE_FP1
		TST.B	    4(A1)
		BMI.S	    ITS_DYADIC
		BGT	    rts
		MOVE.W	    #%1110000000000,D1
		AND.W	    D3,D1
		LSR.W	    #3,D1
		MOVE.W	    #%1110000000,D2
		AND.W	    D3,D2
		CMP.W	    D1,D2
		BEQ.S	    SAME_FP
ITS_DYADIC:	MOVE.B	    #',',(A2)+
		BSR	    WRITE_FP2
SAME_FP:	MOVEQ	    #%111111,D2
		AND.W	    D0,D2
		SNE	    AttentionFlag-VB(a4)
		RTS

*-------------------------------------------------------------------------------

DISASSEMBLER_49:CMP.W	    #$F280,D0
		BNE.S	    NOT_FNOP
		TST.W	    (A0)
		BEQ	    FailDis
NOT_FNOP:	MOVE.W	    D0,D3
		BSR.S	    WRITE_FCC
		MOVE.B	    #'.',-1(A5)
		BTST	    #6,D0
		BNE.S	    LONG_FBCC
		MOVE.B	    #'W',(A5)+
		MOVE.W	    (A0)+,D3
		LEA	    -2(A0,D3.w),A5
		BRA.S	    CONT_FBCC
LONG_FBCC:	MOVE.B	    #'L',(A5)+
		MOVE.L	    (A0)+,D3
		LEA	    -4(A0,D3.l),A5
CONT_FBCC:	MOVE.L	    A5,D3
		BSR	    WRITE_HEXZAHL_SYMB
		BTST	    #0,D3
		SNE	    QuotationFlag-VB(a4)
		BTST	    #5,D0
		SNE	    AttentionFlag-VB(a4)
		RTS

*-------------------------------------------------------------------------------

WRITE_FCC:	BSR	    SEARCH_BACK
		AND.W	    #%11111,D3
		LEA	    CONDITION_CODE_2,A6
		BRA.S	    CC_EINSTIEG
CC_LOOP_1:	TST.B	    (A6)+
		BNE.S	    CC_LOOP_1
CC_EINSTIEG:	DBRA	    D3,CC_LOOP_1
CC_LOOP_2:	MOVE.B	    (A6)+,(A5)+
		BNE.S	    CC_LOOP_2
		RTS

*---------------

CONDITION_CODE_2:dc.B 'F',0,'EQ',0,'OGT',0,'OGE',0,'OLT',0,'OLE',0
				dc.B 'OGL',0,'OR',0,'UN',0,'UEQ',0,'UGT',0,'UGE',0
				dc.B 'ULT',0,'ULE',0,'NE',0,'T',0,'SF',0,'SEQ',0,'GT',0
				dc.B 'GE',0,'LT',0,'LE',0,'GL',0,'GLE',0,'NGLE',0,'NGL'
				dc.B 0,'NLE',0,'NLT',0,'NGE',0,'NGT',0,'SNE',0,'ST',0
			EVEN

*-------------------------------------------------------------------------------

DISASSEMBLER_50:MOVE.W	    (A0)+,D3
		MOVEQ	    #%11111,D2
		AND.W	    D3,D2
		SUB.W	    D3,D2
		SNE	    AttentionFlag-VB(a4)
		BSR	    WRITE_FCC
		MOVE.B	    #32,-(A5)
		BSR	    GetRegister_1
		BSR	    WriteDn
		MOVE.B	    #',',(A2)+
		MOVE.W	    (A0)+,D3
		LEA	    -2(A0,D3.w),A5
		MOVE.L	    A5,D3
		BSR	    WRITE_HEXZAHL_SYMB
		BTST	    #0,D3
		SNE	    QuotationFlag
		RTS

*-------------------------------------------------------------------------------

DISASSEMBLER_51:MOVE.W	    (A0)+,D3
		MOVE.W	    #%1110000000000000,D2
		AND.W	    D3,D2
		CMP.W	    #%110000000000000,D2
		BNE	    FailDis
		BSR	    SEARCH_BACK
		MOVE.B	    #'.',(A5)+
		MOVE.W	    #%1110000000000,D2
		AND.W	    D3,D2
		ROL.W	    #6,D2
		MOVE.B	    FMT_3(PC,D2.w),(A5)+
		MOVEQ	    #%111000,D1
		AND.W	    D0,D1
		BNE.S	    NOT_F_DN_2
		LEA	    FMT_2,A5
		TST.B	    (A5,D2.w)
		BEQ	    FailDis
NOT_F_DN_2:	CMP.B	    #%1000,D1
		BEQ	    FailDis
		MOVEM.L     D2-D3,-(SP)
		BSR	    WRITE_FP2
		MOVE.B	    #',',(A2)+
		BSR	    WRITE_EA
		MOVEM.L     (SP)+,D2-D3
		MOVE.B	    FMT_4(PC,D2.w),D1
		BEQ.S	    NO_KFACTOR
		BMI.S	    STATIC_KFACTOR
		MOVE.B	    #'{',(A2)+
		MOVEQ	    #%1111,D2
		AND.W	    D3,D2
		AND.W	    #%1110000,D3
		LSR.W	    #4,D3
		BSR	    WriteDn
		MOVE.B	    #'}',(A2)+
		TST.W	    D2
		SNE	    AttentionFlag-VB(a4)
		RTS
STATIC_KFACTOR: MOVE.B	    #'{',(A2)+
		AND.L	    #%1111111,D3
		BSR	    WRITE_IMMEDIATE
		MOVE.B	    #'}',(A2)+
		RTS

NO_KFACTOR:	AND.W	    #%1111111,D3
		SNE	    AttentionFlag-VB(a4)
		RTS

*---------------

FMT_3:				dc.B 'L','S','X','P','W','D','B','P'
FMT_4:				dc.B 0,0,0,-1,0,0,0,1

*-------------------------------------------------------------------------------

DISASSEMBLER_52:MOVE.W	    (A0),D3
		AND.W	    #%1111110000000000,D3
		CMP.W	    #%101110000000000,D3
		BNE	    FailDis
		BSR	    SEARCH_BACK
		MOVE.B	    #'.',(A5)+
		MOVE.B	    #'X',(A5)+
		MOVEQ	    #%1111111,D3
		AND.W	    (A0),D3
		BSR	    WRITE_IMMEDIATE
		MOVE.B	    #',',(A2)+
		MOVE.W	    (A0),D3
		BSR	    WRITE_FP2
		MOVEQ	    #%1111111,D3
		AND.W	    (A0)+,D3
		CMP.W	    #$3F,D3
		SHI	    AttentionFlag-VB(a4)
		BHI.S	    END_CONST
		LEA	    KONSTANT_TABLE,A5
		BRA.S	    CONST_EINSTIEG
CONST_LOOP:	TST.B	    (A5)+
		BNE.S	    CONST_LOOP
CONST_EINSTIEG: DBRA	    D3,CONST_LOOP
		MOVE.B	    #32,(A2)+
		MOVE.B	    #';',(A2)+
		TST.B	    (A5)
		SEQ	    AttentionFlag-VB(a4)
		BEQ.S	    END_CONST
		MOVE.B	    #32,(A2)+
COPY_CONST:	MOVE.B	    (A5)+,(A2)+
		BNE.S	    COPY_CONST
		MOVE.B	    #32,-1(A2)
END_CONST:	RTS

*---------------

KONSTANT_TABLE: dc.B 'pi',0,0,0,0,0,0,0,0,0,0,0
				dc.B 'Log10(2)',0,'e',0,'Log2(e)',0,'Log10(e)',0
				dc.B '0.0',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
				dc.B 0,0,0,0,0,0,0,0,0,0,0
				dc.B 'ln(2)',0,'ln(10)',0,'10e0',0,'10e1',0
				dc.B '10e2',0,'10e4',0,'10e8',0,'10e16',0,'10e32',0
				dc.B '10e64',0,'10e128',0,'10e256',0,'10e512',0
				dc.B '10e1024',0,'10e2048',0,'10e4096',0
			EVEN

*-------------------------------------------------------------------------------

DISASSEMBLER_53:TST.W	    (A0)+
		BNE	    FailDis
		RTS

*-------------------------------------------------------------------------------

DISASSEMBLER_54:MOVE.W	    (A0)+,D3
		MOVEQ	    #%11111,D2
		AND.W	    D3,D2
		SUB.W	    D3,D2
		SNE	    AttentionFlag-VB(a4)
		BSR	    WRITE_FCC
		MOVE.B	    #32,-(A5)
		BRA	    CHECK_ADRESSIERUNG

*-------------------------------------------------------------------------------

DISASSEMBLER_55:MOVE.W	    (A0)+,D3
		MOVEQ	    #%11111,D2
		AND.W	    D3,D2
		SUB.W	    D3,D2
		SNE	    AttentionFlag-VB(a4)
		BSR	    WRITE_FCC
		MOVEQ	    #%111,D2
		AND.W	    D0,D2
		CMP.B	    #%100,D2
		BEQ	    rts
		CMP.B	    #%10,D2
		BEQ.S	    FTRAPCC_WORD
		CMP.B	    #%11,D2
		BNE	    FailDis
		MOVE.B	    #'.',-1(A5)
		MOVE.B	    #'L',(A5)
		MOVE.L	    (A0)+,D3
		BRA	    WRITE_IMMEDIATE
FTRAPCC_WORD:	MOVE.B	    #'.',-1(A5)
		MOVE.B	    #'W',(A5)
		MOVEQ	    #0,D3
		MOVE.W	    (A0)+,D3
		BRA	    WRITE_IMMEDIATE

*-------------------------------------------------------------------------------

DISASSEMBLER_56:MOVE.W	    (A0)+,D3
		MOVE.W	    #%1010000001111000,D2
		AND.W	    D3,D2
		CMP.W	    #%110000,D2
		BNE	    FailDis
		BSR	    SEARCH_BACK
		MOVE.B	    #'.',(A5)+
		BTST	    #14,D3
		BEQ.S	    REG_2_REG

*-------------- FSINCOS.<fmt> <ea>,FPn

		MOVE.W	    #%1110000000000,D2
		AND.W	    D3,D2
		ROL.W	    #6,D2
		LEA	    FMT_1,A6
		MOVE.B	    (A6,D2.w),(A5)+
		BMI	    FailDis
		MOVEQ	    #%111000,D1
		AND.W	    D0,D1
		BNE.S	    NOT_F_DN_3
		LEA	    FMT_2,A6
		MOVE.B	    (A6,D2.w),D2
		BEQ	    FailDis
NOT_F_DN_3:	CMP.B	    #%1000,D1
		BEQ	    FailDis
		MOVE.W	    D3,-(SP)
		BSR	    WRITE_EA
		MOVE.W	    (SP)+,D3
		BRA.S	    CONT_SINCOS

*-------------- FSINCOS.X FPm,FPn

REG_2_REG:	MOVE.B	    #'X',(A5)+
		BSR	    WRITE_FP1
		MOVEQ	    #%111111,D2
		AND.W	    D0,D2
		SNE	    AttentionFlag-VB(a4)

CONT_SINCOS:	MOVE.B	    #',',(A2)+
		MOVEQ	    #%111,D2
		AND.W	    D3,D2
		BSR	    WRITE_FP
		MOVE.B	    #':',(A2)+
		LSR.W	    #7,D3
		MOVEQ	    #%111,D2
		AND.W	    D3,D2
		BRA	    WRITE_FP

*-------------------------------------------------------------------------------

DISASSEMBLER_57:BSR	    SEARCH_BACK 	; reg->mem
		MOVE.B	    #'.',(A5)+
		MOVE.B	    #'X',(A5)+
		MOVE.W	    (A0)+,D3
		MOVE.W	    #%1110011100000000,D2
		AND.W	    D3,D2
		CMP.W	    #%1110000000000000,D2
		BNE	    FailDis
		MOVE.W	    D3,-(SP)
		BSR.S	    FMOVEM_LIST
		MOVE.W	    (SP)+,D3
		MOVE.B	    #',',(A2)+
		BRA	    CHECK_ADRESSIERUNG

*-------------------------------------------------------------------------------

DISASSEMBLER_58:BSR	    SEARCH_BACK 	; mem->reg
		MOVE.B	    #'.',(A5)+
		MOVE.B	    #'X',(A5)+
		MOVE.W	    (A0)+,D3
		MOVE.W	    #%1110011100000000,D2
		AND.W	    D3,D2
		CMP.W	    #%1100000000000000,D2
		BNE	    FailDis
		MOVE.W	    D3,-(SP)
		BSR	    CHECK_ADRESSIERUNG
		MOVE.W	    (SP)+,D3
		MOVE.B	    #',',(A2)+
*		 BRA.S	     FMOVEM_LIST

*---------------

FMOVEM_LIST:	MOVE.W	    #$0F,D2
		AND.W	    D3,D2
		BTST	    #11,D3
		BEQ.S	    STATIC_LIST

		MOVE.W	    #%10001111,D2
		AND.W	    D3,D2
		SNE	    AttentionFlag-VB(a4)
		AND.W	    #%1110000,D3
		LSR.W	    #4,D3
		BRA	    WriteDn

STATIC_LIST:	AND.W	    #$FF,D3
		MOVEQ	    #7,D1
SEARCH_BEGIN:	BTST	    D1,D3
		DBNE	    D1,SEARCH_BEGIN
		BEQ.S	    END_FREG
		MOVEQ	    #7,D2
		SUB.W	    D1,D2
		BSR	    WRITE_FP
		MOVE.W	    D1,D2
LENGTH_LOOP:	BTST	    D1,D3
		DBEQ	    D1,LENGTH_LOOP
		SUB.W	    D1,D2
		SUBQ.W	    #1,D2
		BEQ.S	    EINER_ZYKLUS
ENDE_ZYKLUS:	MOVE.B	    #'-',(A2)+
		MOVEQ	    #6,D2
		SUB.W	    D1,D2
		BSR	    WRITE_FP
EINER_ZYKLUS:	MOVE.B	    #'/',(A2)+
		TST.W	    D1
		BPL.S	    SEARCH_BEGIN
END_FREG:	CMPI.B	    #'/',-1(A2)
		BNE.S	    NO_SLASH_2
		MOVE.B	    #32,-(A2)
NO_SLASH_2:	RTS

*-------------------------------------------------------------------------------

DISASSEMBLER_59:BSR	    SEARCH_BACK
		MOVE.B	    #'.',(A5)+
		MOVE.B	    #'L',(A5)+
		MOVE.W	    (A0)+,D3
		MOVE.W	    #%1100001111111111,D2
		AND.W	    D3,D2
		CMP.W	    #%1000000000000000,D2
		BNE	    FailDis
		BTST	    #13,D3
		BNE.S	    REG_TO_MEMORY_2

		MOVE.W	    D3,-(SP)
		BSR	    WRITE_EA
		MOVE.W	    (SP)+,D3
		MOVE.B	    #',',(A2)+
		BRA.S	    WRITE_LIST

REG_TO_MEMORY_2:MOVE.W	    D3,-(SP)
		BSR.S	    WRITE_LIST
		MOVE.W	    (SP)+,D3
		MOVE.B	    #',',(A2)+
		BRA	    CHECK_ADRESSIERUNG

*---------------

WRITE_LIST:	MOVEQ	    #0,D2
		ROL.W	    #4,D3
		BCC.S	    NO_FPCR
		LEA			FPCR_,A5
		BSR.S	    WRITE_REG
		ADDQ.W	    #1,D2
NO_FPCR:ROL.W	    #1,D3
		BCC.S	    NO_FPSR
		LEA			FPSR_,A5
		BSR.S	    WRITE_REG
		ADDQ.W	    #1,D2
NO_FPSR:	ROL.W	    #1,D3
		BCC.S	    NO_FPIAR
		LEA	    FPIAR_,A5
		BSR.S	    WRITE_REG
		ADDQ.W	    #1,D2
NO_FPIAR:	AND.W	    #%111,D3
		CMPI.B	    #'/',-1(A2)
		BNE.S	    NO_SLASH_1
		MOVE.B	    #32,-(A2)
NO_SLASH_1:	MOVEQ	    #%111000,D1
		AND.W	    D0,D1
		SUBQ.W	    #1,D2		; nur ein Register?
		BEQ.S	    DONT_TEST_FMOVE
		MOVE.B	    4(A1),D2		; fmove?
		BMI	    FailDis
		TST.W	    D1			; Dn?
		BEQ	    FailDis
DONT_TEST_FMOVE:SUBQ.W	    #8,D1		; An?
		BNE.S	    END_WRITE_LIST
		SUBQ.W	    #1,D3		; %001?
		BNE	    FailDis
END_WRITE_LIST: RTS

WRITE_REG:	MOVE.B	    (A5)+,(A2)+
		BNE.S	    WRITE_REG
		MOVE.B	    #'/',-1(A2)
		RTS

*---------------

FPCR_:				dc.B 'FPCR',0
FPSR_:				dc.B 'FPSR',0
FPIAR_:				dc.B 'FPIAR',0
			EVEN

*------------------------------------------------------------------- ------------

WRITE_FP1:	MOVE.W	    #%1110000000000,D2
		AND.W	    D3,D2
		ROL.W	    #6,D2
		BRA.S	    WRITE_FP

*-------------------------------------------------------------------------------

WRITE_FP2:	MOVE.W	    #%1110000000,D2
		AND.W	    D3,D2
		LSR.W	    #7,D2
*		 BRA.S	     WRITE_FP

*-------------------------------------------------------------------------------

WRITE_FP:
		MOVE.B	    #'F',(A2)+
		MOVE.B	    #'P',(A2)+
		MOVE.B	    D2,(A2)
		ADDI.B	    #48,(A2)+
		RTS
