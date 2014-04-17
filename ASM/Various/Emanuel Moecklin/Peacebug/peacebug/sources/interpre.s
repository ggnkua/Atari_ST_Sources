*-------------------------------------------------------------------------------
* Interpreter: Berechnet den Wert eines Terms. Verarbeitet werden folgende
*			   Operatoren: + - * / | & ^ < > + - ~ p ( ). KillSpace am Schluss.
* ---> D0.w = Stringl„nge
* ---> A2.l = Stringadresse
* <--- D0.w = Stringl„nge
* <--- A2.l = Stringende
* <--- D3.l = berechneter Wert
* <--- flag.eq = gltig, flag.ne = ungltig, ZahlUngltig
*
* CalcNumber: Berechnet den Wert einer Zahl. Es sind vier Zahlensysteme
*			  zugelassen (. $ % o), auch Strings werden verarbeitet (" ').
* ---> D0.w = Stringl„nge
* ---> A2.l = Stringadresse
* <--- D0.w = Stringl„nge
* <--- A2.l = Stringende
* <--- D3.l = berechnete Zahl
* <--- flag.eq = gltig, flag.ne = ungltig, ZahlUngltig
* Ueberlauf wird bei šberlauf gesetzt, NoNumber wenn nichts vorhanden ist.
*
* GetFirstValue: Schaut, ob ein Wert vorhanden ist: Wert.
* ---> D3.l = berechneter Wert sofern vorhanden
* ---> flag.eq = alles io., flag.mi = keine Zahl, flag.gt = Fehler
*
* GetNextValue: Schaut, ob ein Wert vorhanden ist: ,Wert.
*				Ein vorhandenes Komma wird immer entfernt.
* ---> D3.l = berechneter Wert sofern vorhanden
* ---> No_number, tst.b No_number
* ---> flag.eq = alles io., flag.mi = keine Zahl, flag.gt = Fehler
*
* GetTerm: Analysiert einen Ausdruck {,Term} und erzeugt einen String.
*		   Erkannt werden: '|"String'|", Term[.b|.w|.a|.l].
* ---> d0.w = L„nge des zu analysierenden Ausdrucks
* ---> a2.l = Adresse des zu analysierenden Ausdrucks
* <--- a3.l = Hierhin wird der erzeugte String geschrieben (Nullterminiert)
* <--- tst.l d7 = L„nge des erzeugten Strings oder -1 im Fehlerfall
*
* GetTerm_2: Analysiert einen Ausdruck [Term]{,Term} und erzeugt einen String.
*			 Erkannt werden: '|"String'|", Term[.b|.w|.a|.l].
* ---> d0.w = L„nge des zu analysierenden Ausdrucks
* ---> d1.w = maximale L„nge einer Zahl, 0 wenn inaktiv
* ---> a2.l = Adresse des zu analysierenden Ausdrucks
* <--- a3.l = Hierhin wird der erzeugte String geschrieben (Nullterminiert)
* <--- tst.l d7 = L„nge des erzeugten Strings oder -1 im Fehlerfall
*
* GetString: Holt sich einen String. Muss mit " oder ' eingeschlossen sein.
* ---> d0.w = L„nge des zu analysierenden Ausdrucks
* ---> a2.l = Adresse des zu analysierenden Ausdrucks
* ---> a3.l = Hierhin wird der erzeugte String geschrieben, Ende des Strings
* <--- flag.eq = gefunden, flag.ne = nichts gefunden
*
* ExtractString: Holt sich einen String. Der String kann mit " oder ' eingeschlossen
*				 sein, sonst wird bis zu einem Space, Komma oder > gesucht.
* ---> d0.w = L„nge des zu analysierenden Ausdrucks
* ---> a2.l = Adresse des zu analysierenden Ausdrucks
* ---> a3.l = Hierhin wird der erzeugte String geschrieben. Nullterminiert.
*
* GetLength: Prft ob ein .b|.w|.a|.l vorhanden ist.
* ---> d0.w = Stringl„nge
* ---> a2.l = Stringadresse
* <--- tst.l d3: -1 = Fehler, 0 = no length, 1 = .b, 2 = .w, 3 = .a, 4 = .l
*
* ExpandPath: Isoliert einen Pfad und prft ihn auf Existenz. Falls es den Pfad
*			  nicht gibt, wird der aktuelle Pfad zurckgegeben.
* ---> d0.w = Stringl„nge
* ---> a2.l = Stringadresse
* <--- a3.l = *Buffer, nullterminiert.
*
* ExpandFile: Isoliert ein File und expandiert den Pfad, falls er nicht schon
*			  explizit angegeben ist. Wenn das File nicht existiert, wird das
*			  explizit angegebene bernommen. Aus test.prg wird z.B. c:\ordner\test.prg.
* ---> d0.w = Stringl„nge
* ---> a2.l = Stringadresse
* <--- a3.l = *FILE_NAME, nullterminiert.
*
* KillSpace: Spaces am Anfang des Strings l”schen.
* flag.mi = Ende des Strings, String leer
*
* CutSpace: Spaces am Ende des Strings l”schen.
* flag.mi = Ende des Strings, String leer
*-------------------------------------------------------------------------------

		.EXPORT		Interpreter,CalcNumber,GetFirstValue,GetNextValue
		.EXPORT		GetTerm,GetTerm_2,GetString,GetLength,ExpandPath,ExpandFile,ExtractString
		.EXPORT		ZahlUngueltig,Ueberlauf,KlammerFehler,Division,NoNumber,Buffer
		.EXPORT		KillSpace,CutSpace

		.INCLUDE	'EQU.S'

*-------------------------------------------------------------------------------

		.BSS
Buffer:				ds.b	MENUE_LENGTH+2

ZahlUngueltig:		ds.b	1
Ueberlauf:			ds.b	1					; wenn ZahlUngltig gesetzt, dann
KlammerFehler:		ds.b	1					; gibt eines dieser 3 Flags an,
Division:			ds.b	1					; Division durch Null
NoNumber:			ds.b	1					; was fr ein Fehler aufgetreten ist
		.EVEN

*-------------------------------------------------------------------------------

		.TEXT
Interpreter:	movem.l		d1-d2/d4-a1/a3-a6,-(SP)
				sf			KlammerFehler
				sf			Division
				sf			Ueberlauf
				bsr			KillSpace
				smi			NoNumber
				smi			ZahlUngueltig
				bmi.s		.ende

				move.l		a2,-(sp)			; Stringadresse
				clr.w		-(sp)				; Priorit„t
				move.w		d0,-(sp)			; Stringl„nge
				bsr.s		CALCULATE			; berechnen
				cmp.w		(sp)+,d0			; NoNumber?
				addq.w		#6,sp
				bne.s		.ende
				tst.b		ZahlUngueltig
				sne			NoNumber

.ende:			movem.l		(sp)+,d1-d2/d4-a1/a3-a6
				tst.b		ZahlUngueltig
				rts

*-------------------------------------------------------------------------------

* ---> 4(SP) = Stringl„nge, 6(SP) = Priorit„t, 8(SP) = Stringadresse
* <--- D3 = Wert
CALCULATE:		MOVEQ		#0,D3				; Wert=0
				MOVE.W		4(SP),D0			; Stringl„nge
				MOVE.W		6(SP),D1			; Priorit„t
				MOVEA.L		8(SP),A2			; String

				bsr			KillSpace			; String leer?
				BMI			FAIL_CALCULATE

*---------------								; einwertige Operatoren

				LEA			Convert,A0
				MOVEQ		#0,D2
				MOVE.B		(A2),D2
				MOVE.B		(A0,D2.w),D2
				CMPI.B		#'(',D2				; Klammer (
				BEQ			KLAMMER_AUF
				CMPI.B		#'+',D2				; Plus +
				BEQ			VORZEICHEN_PLUS
				CMPI.B		#'-',D2				; Minus -
				BEQ			ZWEIERKOMPLEMENT
				CMPI.B		#'~',D2				; Einerkomplement ~
				BEQ			EINERKOMPLEMENT
				CMPI.B		#'P',D2				; Pointer p
				BEQ			POINTER
				CMP.B		#'^',D2				; Register ^
				BEQ			REGISTER_REFERENZ

				CMP.B		#'.',D2				; Symbol?
				BNE.S		NO_REFERENCE
				MOVEM.L		D0/A2,-(SP)
				SUBQ.W		#1,D0
				ADDQ.W		#1,A2
				bsr			KillSpace
				BMI.S		KEIN_SYMBOL
				jsr			SEARCH_VALUES
				BEQ.S		KEIN_SYMBOL
				ADDQ.W		#8,SP
				BRA.S		CONTINUE
KEIN_SYMBOL:	MOVEM.L		(SP)+,D0/A2

NO_REFERENCE:	BSR			CalcNumber			; Zahl berechnen
				BNE			FAIL_CALCULATE
				bsr			KillSpace
				bmi			END_CALCULATE

*---------------								; zweiwertige Operatoren

CONTINUE:		TST.B		ZahlUngueltig
				BNE			FAIL_CALCULATE
				bsr			KillSpace
				BMI			END_CALCULATE
				lea			Convert,a0
				MOVE.B		(A2),D2
				CMP.B		#'*',D2				; Multiplikation *
				BEQ			MULTIPLIKATION
				CMP.B		#'+',D2				; Addition +
				BEQ			ADDITION
				CMP.B		#'/',D2				; Division /
				BEQ			DIVIDIEREN
				CMP.B		#'-',D2				; Subtraktion -
				BEQ			SUBTRAKTION
				CMP.B		#'&',D2				; Anden &
				BEQ.S		ANDEN
				CMP.B		#'|',D2				; Odern |
				BEQ.S		ODERN
				CMP.B		#'^',D2				; Eoren ^
				BEQ.S		EOREN
*				CMP.B		#'>',D2				; Shift Right >
*				BEQ.S		SHIFT_RIGHT
				CMP.B		#'<',D2				; Shift Left <
				BEQ.S		SHIFT_LEFT
				CMP.B		#'%',D2				; Modulo %
				BEQ.S		MODULO
				BRA			END_CALCULATE

*---------------								Zweiwertige Operationen

ODERN:			MOVE.W		PRIORITAETEN+8,D2
				BSR			GO_NEXT_2
				OR.L		D2,D3
				BRA.S		CONTINUE

ANDEN:			MOVE.W		PRIORITAETEN+10,D2
				BSR			GO_NEXT_2
				AND.L		D2,D3
				BRA			CONTINUE

EOREN:			MOVE.W		PRIORITAETEN+12,D2
				BSR			GO_NEXT_2
				EOR.L		D2,D3
				BRA			CONTINUE

*SHIFT_RIGHT:	MOVE.W		PRIORITAETEN+14,D2
*				BSR			GO_NEXT_2
*				LSR.L		D2,D3
*				BRA			CONTINUE

SHIFT_LEFT:		MOVE.W		PRIORITAETEN+14,D2
				BSR			GO_NEXT_2
				tst.l		d2
				bpl.s		.positiv
				neg.l		d2
				LSR.L		D2,D3
				BRA			CONTINUE
.positiv:		LSL.L		D2,D3
				BRA			CONTINUE

MODULO: 		MOVE.W		PRIORITAETEN+20,D2
				BSR.S		GO_NEXT_2
				move.l		d1,-(sp)
				BSR			LongDivs
				MOVE.L		d1,D3
				move.l		(sp)+,d1
				BRA			CONTINUE

ADDITION:		MOVE.W		PRIORITAETEN,D2
				BSR.S		GO_NEXT_2
				ADD.L		D2,D3
				BRA			CONTINUE

SUBTRAKTION:	MOVE.W		PRIORITAETEN+2,D2
				BSR.S		GO_NEXT_2
				SUB.L		D2,D3
				BRA			CONTINUE

MULTIPLIKATION:	MOVE.W		PRIORITAETEN+4,D2
				BSR.S		GO_NEXT_2
				BSR			LongMuls
				TST.B		Ueberlauf
				BNE			FAIL_CALCULATE
				BRA			CONTINUE

DIVIDIEREN:		MOVE.W		PRIORITAETEN+6,D2
				BSR.S		GO_NEXT_2
				tst.b		ZahlUngueltig
				bne			FAIL_CALCULATE
				move.l		d1,-(sp)
				BSR			LongDivs
				move.l		(sp)+,d1
				tst.b		Division
				bne			FAIL_CALCULATE
				BRA			CONTINUE

*---------------

GO_NEXT_2:		CMP.W		D2,D1
				BHS.S		PRIORITAET_HOEHER
				ADDQ.W		#1,A2
				SUBQ.W		#1,D0
				MOVE.L		D3,-(SP)
				MOVE.W		D1,-(SP)
				MOVE.L		A2,-(SP)
				MOVE.W		D2,-(SP)
				MOVE.W		D0,-(SP)
				BSR			CALCULATE
				MOVE.L		D3,D2
				ADDQ.W		#8,SP
				MOVE.W		(SP)+,D1
				MOVE.L		(SP)+,D3
				RTS
PRIORITAET_HOEHER:
				ADDQ.W		#4,SP
				BRA			END_CALCULATE

*---------------								Einwertige Operationen

EINERKOMPLEMENT:MOVE.W		PRIORITAETEN+16,D2
				BSR			GO_NEXT
				NOT.L		D3
				BRA			CONTINUE

VORZEICHEN_PLUS:MOVE.W		PRIORITAETEN+18,D2
				BSR			GO_NEXT
				BRA			CONTINUE

ZWEIERKOMPLEMENT:MOVE.W		PRIORITAETEN+18,D2
				BSR			GO_NEXT
				NEG.L		D3
				BRA			CONTINUE

POINTER:		pea			POINTER_MISS(pc)
				jsr			TestBusOn
				MOVEQ		#0,D2
				MOVE.B		1(A2),D2
				MOVE.B		(A0,D2.w),D2
				CMP.B		#'B',D2
				BEQ.S		BYTE_POINTER
				CMP.B		#'W',D2
				BEQ.S		WORD_POINTER
				CMP.B		#'L',D2
				BNE.S		DEFAULT_POINTER
				ADDQ.W		#1,A2
				SUBQ.W		#1,D0
DEFAULT_POINTER:MOVE.W		PRIORITAETEN+22,D2
				BSR.S		GO_NEXT
				MOVEA.L		D3,A0
				MOVE.L		(A0),D3
				jsr			TestBusOff
				addq.w		#4,sp
				BRA			CONTINUE
WORD_POINTER:	ADDQ.W		#1,A2
				SUBQ.W		#1,D0
				BMI			END_CALCULATE
				MOVE.W		PRIORITAETEN+22,D2
				BSR.S		GO_NEXT
				MOVEA.L		D3,A0
				MOVEQ		#0,D3
				MOVE.W		(A0),D3
				jsr			TestBusOff
				addq.w		#4,sp
				BRA			CONTINUE
BYTE_POINTER:	ADDQ.W		#1,A2
				SUBQ.W		#1,D0
				BMI			END_CALCULATE
				MOVE.W		PRIORITAETEN+22,D2
				BSR.S		GO_NEXT
				MOVEA.L		D3,A0
				MOVEQ		#0,D3
				MOVE.B		(A0),D3
				jsr			TestBusOff
				addq.w		#4,sp
				BRA			CONTINUE
POINTER_MISS:	moveq		#0,d3				; bei Address-/Buserror
				bra			CONTINUE

*---------------

GO_NEXT:		ADDQ.W		#1,A2
				SUBQ.W		#1,D0
				MOVE.W		D1,-(SP)
				MOVE.L		A2,-(SP)
				MOVE.W		D2,-(SP)
				MOVE.W		D0,-(SP)
				BSR			CALCULATE
				ADDQ.W		#8,SP
				MOVE.W		(SP)+,D1
				RTS

*---------------

REGISTER_REFERENZ:
				SUBQ.W		#1,D0
				ADDQ.W		#1,A2
				jsr			GetRegister
				SUBQ.W		#1,D3						; Registerbreite
				bne.s		.not_1_byte
				MOVEQ		#0,D3
				MOVE.B		(A0),D3						; Byte
				BRA			CONTINUE
.not_1_byte:	SUBQ.W		#1,D3
				bne.s		.not_2_byte
				MOVEQ		#0,D3
				MOVE.W		(A0),D3						; Word
				BRA			CONTINUE
.not_2_byte:	SUBQ.W		#2,D3
				bne.s		.not_4_byte
				MOVE.L		(A0),D3						; Long
				BRA			CONTINUE
.not_4_byte:	addq.w		#1,d0
				subq.w		#1,a2
				bra			FAIL_CALCULATE

*------------

KLAMMER_AUF:	addq.w		#1,a2
				movea.l		a2,a3
				subq.w		#1,d0
				BMI.S		FAIL_KLAMMER
				MOVE.W		D0,D2
				MOVEQ		#1,D3
SUCH_KLAMMER:	CMPI.B		#'(',(A2)
				BNE.S		NOT_OPEN
				ADDQ.W		#1,D3
NOT_OPEN:		CMPI.B		#')',(A2)
				BNE.S		NOT_CLOSE
				SUBQ.W		#1,D3
				BEQ.S		BRACKET_FOUND
NOT_CLOSE:		ADDQ.W		#1,A2
				DBRA		D0,SUCH_KLAMMER
				BRA.S		FAIL_KLAMMER
BRACKET_FOUND:	MOVEM.L		D0-D1/A2,-(SP)
				SUB.W		D0,D2
				SUBQ.W		#1,D2
				PEA			(A3)
				MOVE.W		PRIORITAETEN+24,-(SP)
				MOVE.W		D2,-(SP)
				BSR			CALCULATE
				ADDQ.W		#8,SP
				MOVEM.L		(SP)+,D0-D1/A2
				ADDQ.W		#1,A2
				SUBQ.W		#1,D0
				BMI.S		END_CALCULATE
				BRA			CONTINUE

*---------------

FAIL_KLAMMER:	move.l		a3,a2
				st			KlammerFehler
FAIL_CALCULATE:	st			ZahlUngueltig
END_CALCULATE:	rts

*-------------------------------------------------------------------------------

ASCII_NUMBER:	MOVEQ		#4,D1				; maximal 4 Zeichen + Stringende
ASCIISCHLEIFE:	ADDQ.W		#1,A2
				SUBQ.W		#1,D0
				bsr			KillSpace			; String leer?
				BMI			ENDE_CALCULATE
				CMPI.B		#"'",(A2)			; Stringende?
				BEQ.S		ASCII_ENDE
				CMPI.B		#'"',(A2)
				BEQ.S		ASCII_ENDE
				LSL.L		#8,D3
				MOVE.B		(A2),D3
				DBRA		D1,ASCIISCHLEIFE
				ADDQ.W		#1,A2
				st			Ueberlauf
				BRA			ENDE_CALCULATE
ASCII_ENDE:		ADDQ.W		#1,A2
				SUBQ.W		#1,D0
				sf 			ZahlUngueltig
				BRA			ENDE_CALCULATE

*---------------

CalcNumber:		sf			Ueberlauf
				st			ZahlUngueltig
				MOVEM.L		D1-D2/D4-A1/A3-A6,-(SP)
				MOVEQ		#0,D3				; Wert=0
				MOVEQ		#0,D1				; Konvertierregister
				LEA	 		Convert,A1

				bsr			KillSpace			; String leer?
				BMI			ENDE_CALCULATE

				CMPI.B		#"'",(A2)			; String?
				BEQ.S		ASCII_NUMBER
				CMPI.B		#'"',(A2)
				BEQ.S		ASCII_NUMBER

				MOVEQ		#0,D2				; Zahlenbasis bestimmen
				MOVE.W		ZAHLEN_BASIS,D2
				CMPI.B		#'$',(A2)			; $
				BNE.S		OHNE_DOLLAR
				MOVEQ		#16,D2
				BRA.S		GOT_BASE
OHNE_DOLLAR:	CMPI.B		#'.',(A2)			; .
				BNE.S		OHNE_PUNKT
				MOVEQ		#10,D2
				BRA.S		GOT_BASE
OHNE_PUNKT:		CMPI.B		#'%',(A2)			; %
				BNE.S		OHNE_PROZENT
				MOVEQ		#2,D2
				BRA.S		GOT_BASE
OHNE_PROZENT:	CMPI.B		#'o',(A2)			; o
				BNE.S		C_SCHLEIFE
				MOVEQ		#8,D2
GOT_BASE:		ADDQ.W		#1,A2
				SUBQ.W		#1,D0

C_SCHLEIFE:		MOVE.B		(A2),D1				; Grossbuchstaben
				MOVE.B		(A1,D1.w),D1
				SUB.B		#$30,D1
				CMP.B		#9,D1
				BLS.S		ZAHL
				SUB.B		#17,D1
				BMI.S		ENDE_CALCULATE
				CMP.B		#25,D1
				BHI.S		ENDE_CALCULATE
				ADD.B		#10,D1
ZAHL:			CMP.B		D2,D1				; Zahl>=Zahlenbasis
				BHS.S		ENDE_CALCULATE
				BSR			LongMulu
				move.b		Ueberlauf,ZahlUngueltig
				BNE.S		ENDE_CALCULATE
				ADD.L		D1,D3
				ADDQ.W		#1,A2
				DBRA		D0,C_SCHLEIFE

ENDE_CALCULATE:	MOVEM.L		(SP)+,D1-D2/D4-A1/A3-A6
				TST.B		ZahlUngueltig
				RTS

*-------------------------------------------------------------------------------

GetFirstValue:	jsr			Interpreter
				beq.s		default
				tst.b		NoNumber
				bne.s		default
				move.b		#1,NoNumber
default:		tst.b		NoNumber
				rts

*-------------------------------------------------------------------------------

GetNextValue:	bsr			KillSpace
				smi			ZahlUngueltig
				smi			NoNumber
				bmi.s		default
				cmpi.b		#',',(a2)
				sne			ZahlUngueltig
				sne			NoNumber
				bne.s		default
				subq.w		#1,d0
				addq.w		#1,a2
				bra.s		GetFirstValue

*-------------------------------------------------------------------------------

GetTerm_2:		lea			Buffer,a3
				movem.l		d1-d6/a0/a1/a3-a6,-(sp)
				bra.s		get_entry

*-------------------------------------------------------------------------------

GetTerm:		lea			Buffer,a3
				movem.l		d1-d6/a0/a1/a3-a6,-(sp)
				moveq		#0,d1			; max. Numberl„nge nicht vorgegeben
get_loop:		bsr			KillSpace
				cmpi.b		#',',(a2)
				bne.s		get_ende
				addq.w		#1,a2
				subq.w		#1,d0
get_entry:		bsr			KillSpace
				bmi.s		get_ende
				bsr.s		GetString
				beq.s		get_loop
				bsr.s		GetNumber
				bgt.s		get_fehler
				beq.s		get_loop
get_ende:		move.l		a3,d7
				clr.b		(a3)			; Stringende
				movem.l		(sp)+,d1-d6/a0/a1/a3-a6
				sub.l		a3,d7			; d7 = L„nge des Strings
				bgt.s		.no_error
				st			NoNumber
.no_error:		rts
get_fehler:		movem.l		(sp)+,d1-d6/a0/a1/a3-a6
				moveq		#-1,d7
				rts

*-------------------------------------------------------------------------------

GetString:		cmpi.b		#"'",(a2)
				beq.s		.its_a_string
				cmpi.b		#'"',(a2)
				bne.s		.no_string
.its_a_string:	addq.w		#1,a2
				subq.w		#1,d0
				bmi.s		.no_string
.loop:			cmpi.b		#'''',(a2)
				beq.s		.io
				cmpi.b		#'"',(a2)
				beq.s		.io
				move.b		(a2)+,(a3)+
				dbra		d0,.loop
				tst.w		d0
				rts
.io:			addq.w		#1,a2
				subq.w		#1,d0
				sf			-(sp)
				bra.s		.ende
.no_string:		st			-(sp)
.ende:			tst.b		(sp)+
				rts

*-------------------------------------------------------------------------------

* eq = alles io, mi = fertig, gt = Fehler
* ---> D1.w = maximale L„nge einer Zahl, 0 wenn inaktiv
GetNumber:		movem.l		d1-a1/a5-a6,-(SP)
				jsr			Interpreter
				bne.s		.fehler_1
				move.l		d3,d4
				bsr			GetLength
				bmi.s		.fehler_2
				beq.s		.default
				subq.w		#1,d3
				move.w		d3,d2			; d2 = L„nge (0.b,1.w,2.a,3.l)
				bra.s		.no_byte

.default:		moveq		#3,d2			; long
			 	cmpi.l		#$ffff,d4
				bhi.s		.no_word
				moveq		#1,d2			; word
.no_word:		cmp.l		#$ff,d4
				bhi.s		.no_byte
				moveq		#0,d2			; byte

.no_byte:		tst.w		d1
				beq.s		.length_io
				move.w		d1,d2
				subq.w		#1,d2
.length_io: 	lea			1(a3,d2.w),a3
				movea.l		a3,a6
.loop:			move.b		d4,-(a3)
				lsr.l		#8,d4
				dbra		d2,.loop
				movea.l		a6,a3
				moveq		#0,d7				; alles io
				movem.l		(sp)+,d1-a1/a5-a6
				rts

.fehler_1:		tst.b		NoNumber
				bne.s		.NotANumber
.fehler_2:		moveq		#1,d7
				movem.l		(sp)+,d1-a1/a5-a6
				rts
.NotANumber:	moveq		#-1,d7
				movem.l		(sp)+,d1-a1/a5-a6
				rts

*-------------------------------------------------------------------------------

ExtractString:	movem.l		d1-a1/a3-a6,-(sp)
				movem.l		d0/a2/a3,-(sp)
				jsr			GetString		; String mit " oder '
				bmi.s		.no_hochkomma
				lea			12(sp),sp
				bra.s		.getout

.no_hochkomma:	movem.l		(sp)+,d0/a2/a3	; String ohne "|'
				bsr			KillSpace
				bpl.s		.copy

				move.b		DRIVE,(a3)+		; aktueller Pfad = Drive:.
				move.b		#':',(a3)+
				move.b		#'.',(a3)+
				bra.s		.getout

.copy:			cmpi.b		#',',(a2)		; , ?
				beq.s		.getout
				cmpi.b		#'>',(a2)		; > ?
				beq.s		.getout
				cmpi.b		#32,(a2)
				beq.s		.getout
				move.b		(a2)+,(a3)+		; kopieren
				dbra		d0,.copy
.getout:		clr.b		(a3)

.ende:			movem.l		(sp)+,d1-a1/a3-a6
				rts

*-------------------------------------------------------------------------------

* <--- tst.l d3: -1 = Fehler, 0 = no length, 1 = .b, 2 = .w, 3 = .a, 4 = .l
GetLength:		movem.l		d0-d2/d4-a6,-(sp)
				cmpi.b		#'.',(a2)+
				bne.s		.no_length
				subq.w		#1,d0
				bsr			KillSpace
				bmi.s		.fail_length

				lea			Convert,a0		; Zeichen umwandeln
				moveq		#0,d1
				move.b		(a2)+,d1
				subq.w		#1,d0
				move.b		(a0,d1.w),d1

				moveq		#1,d3
				cmpi.b		#'B',d1
				beq.s		.io				; byte
				moveq		#2,d3
				cmpi.b		#'W',d1
				beq.s		.io				; word
				moveq		#3,d3
				cmpi.b		#'A',d1
				beq.s		.io				; address
				moveq		#4,d3
				cmpi.b		#'L',d1
				beq.s		.io				; long

.fail_length:	moveq		#-1,d3			; Fehler
				bra.s		.ende
.no_length:		moveq		#0,d3			; no length
				bra.s		.ende
.io:			move.l		d0,(sp)
				move.l		a2,36(sp)
				tst.l		d3
.ende:			movem.l		(sp)+,d0-d2/d4-a6
				rts

*-------------------------------------------------------------------------------

ExpandPath:		movem.l		d1-a1/a4-a6,-(sp)
				lea			Buffer,a3
				bsr			ExtractString
				
				movem.l		d0/a2,-(sp)
				lea			Buffer,a2
				jsr			DSETPATH
				lea			DRIVE,a0
				lea			Buffer,a1
.copy:			move.b		(a0)+,(a1)+		; Pfad kopierem
				bne.s		.copy
				jsr			RESTORE_PATH
				movem.l		(sp)+,d0/a2

				movem.l		(sp)+,d1-a1/a4-a6
				lea			Buffer,a3
				rts

*-------------------------------------------------------------------------------

ExpandFile:		movem.l		d1-a1/a4-a6,-(sp)
				lea			Buffer,a3
				bsr			ExtractString

* Nun wird der vollst„ndige Pfad des Files ermittelt
				movem.l		d0/a2,-(sp)
				lea			Buffer,a2		; hinterstes \ suchen
				cmpi.b		#':',1(a2)
				bne.s		.no_drive
				addq.w		#2,a2
.no_drive:		movea.l		a2,a1
				moveq		#0,d0
				moveq		#0,d1			; Position des letzten \
.extract_file:	addq.w		#1,d0
				tst.b		(a1)
				beq.s		.ende_extract
				cmpi.b		#'\',(a1)+		; kein \ ?
				bne.s		.extract_file
				move.w		d0,d1			; Position merken
				bra.s		.extract_file
.ende_extract:	lea			(a2,d1.w),a1
				move.b		(a1),-(sp)
				clr.b		(a1)			; Pfad isolieren
				lea			Buffer,a2
				jsr			DSETPATH		; Pfad setzen
				beq.s		.path_io
				jsr			RESTORE_PATH
				jsr			DSETPATH
.path_io:		move.b		(sp)+,(a1)
				movea.l		a1,a4			; a2 = Filename

				move.w		#255,d0
				lea			DRIVE,a0
				lea			FILE_NAME,a1
.copy_1:		move.b		(a0)+,(a1)+		; Pfad kopierem
				dbeq		d0,.copy_1
				subq.w		#1,a1

				movea.l		a4,a0			; a0 = Filename
				jsr			FSFIRST			; File vorhanden?
				bne.s		.not_found
				jsr			FGETDTA			; ja ---> Filename holen
				moveq		#0,d1
				lea			30(a0),a4		; Name
.not_found:		jsr			RESTORE_PATH	; Pfad restaurieren
				lea			Convert,a2
				moveq		#13,d0			; maximal 14 Zeichen
.copy_2:		move.b		(a4)+,d1		; File kopieren
				move.b		(a2,d1.w),(a1)+
				dbeq		d0,.copy_2
				clr.b		(a1)
				movem.l		(sp)+,d0/a2
				movem.l		(sp)+,d1-a1/a4-a6
				lea			FILE_NAME,a3
				rts

*-------------------------------------------------------------------------------

CutSpace:		tst.w		d0
				bmi.s		.no_space
				move.l		a2,-(sp)
				lea			1(a2,d0.w),a2
.loop:			cmpi.b		#32,-(a2)
.cont:			dbne		d0,.loop
				movea.l		(sp)+,a2
.no_space:		tst.w		d0
				rts

*-------------------------------------------------------------------------------

KillSpace:		tst.w		d0
				bmi.s		.no_space
.loop:			cmpi.b		#32,(a2)
				bne.s		.no_space
				addq.w		#1,a2
				dbra		d0,.loop
.no_space:		tst.w		d0
				rts