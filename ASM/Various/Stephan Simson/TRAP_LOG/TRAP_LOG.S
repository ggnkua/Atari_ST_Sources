;**************************************************
;*	TRAP_LOG.S - Stephan Simson		*
;*					*
;*	Versionen				*
;*	0.0	31.10.89: GEMDOS-Logger	*
;*	1.0	10.12.89:	AES/VDI-Logger	*
;*	1.1	23.01.90:	GEMDOS-Logger nur	*
;*			mit A0, D0	*
;*	2.0	27.03.90:	AUTO-Start, XBRA	*
;**************************************************

;**************************************************
;*	Zuweisungen			*
;**************************************************
;
;	Base-Page-Offset-Werte
;
TxtSgSiz	EQU	$00C	; Text-Segment-Grîûe
DatSgSiz	EQU	$014	; Daten-Segment-Grîûe
BssSgSiz	EQU	$01C	; BSS-Segment-Grîûe
BasPgSiz	EQU	$100	; Base-Page-Grîûe
;
;	Ascii-Zeichen
;
NUL	EQU	$00
LF	EQU	$0A
CR	EQU	$0D
BLANK	EQU	$20
;
;	Hardware-Adressen
;
MFP_PIO	EQU	$FFFA01	; MFP 68901: par. I/O
;
;	GEMDOS-Funktionen
;
CRAWCIN	EQU	$07	; rohe Zeicheneingabe
CCONWS	EQU	$09	; Stringausgabe
PTERM0	EQU	$00	; Programmende
PTERMRES	EQU	$31	; Programmende / res.
;
;	BIOS-Funktionen
;
SetExec	EQU	$05	; Exc.-Vektor setzen
Bconout	EQU	$03	; Ausgabe Zeichen
Bcostat	EQU	$08	; Test Status Ausgabe
;
;	Vektor-Nummern
;
IllAdVNr	EQU	$03	; illegale Adresse
TraceVNr	EQU	$09	; Trace
FLineVNr	EQU	$0B	; Line-F
T01VktNr	EQU	$21	; Trap-01 (GEMDOS)
T02VktNr	EQU	$22	; Trap-02 (AES / VDI)
;
;	Trap-Nummern
;
GEMDOS	EQU	$01	;
BIOS	EQU	$0D	;
;
;	GerÑte
;
PRN	EQU	0	; Centronics-Port
;
;	Bits
;
Unlink	EQU	0	; FLine:Unlink-Modus
Gesperrt	EQU	0	; Funktion gesperrt
Drucken	EQU	1	; carrier detect
Zeitlupe	EQU	2	; clear to send
Desktop	EQU	3	; Desktop installiert
BootTest	EQU	4	; Boot-Test gelaufen
SuperMod	EQU	5	; Supervisor-Modus
TraceMod	EQU	7	; Trace-Modus
;
;	Trap-2 Funktionen
;
AES_Code	EQU	$C8	; AES-Funktion
VDI_Code	EQU	$73	; VDI-Funktion
;	
;	Sonstige
;
StckSize	EQU	$100	; Stack-Grîûe: 256
Bereit	EQU	$FFFF	; GerÑte-Status

;**************************************************
;*	Programm				*
;**************************************************

	TEXT

ProgrBgn:
;
;	Berechnung: RAM-Bedarf und Stack-Pointer
;
	LEA.L	ProgrBgn-BasPgSiz(PC),SP
				; SP -> BP
	MOVE.L	DatSgSiz(SP),D7	; Data-Seg.
	ADD.L	BssSgSiz(SP),D7	; BSS-Seg.
	ADD.L	#BasPgSiz,D7	; Base-Page
	ADD.L	TxtSgSiz(SP),D7	; Text-Seg.
	ADD.L	#StckSize,D7	; Stack-Gr.
	OR.B	#$01,D7		; D7: RAM-
	ADDQ	#$01,D7		; Bedarf
	ADD.L	D7,SP		; SP okay
;
;	Test der existierenden Trap-01-Routinen
;
	MOVE.L	#-1,-(SP)		; hole
	MOVE.W	#T01VktNr,-(SP)	; alten
	MOVE.W	#SetExec,-(SP)	; Vektor
	TRAP	#BIOS		; nach D0
	ADDQ.L	#8,SP		;
	AND.L	#$00FFFFFF,D0	;
	MOVE.L	D0,A4		;
SuchXBRA:	CMP.L	#'XBRA',-12(A4)	; nach
	BNE	InstaLOG		; XBRA
	CMP.L	#'TLOG',-8(A4)	; Standard
	BEQ	StatAend		; vorgehen
	MOVE.L	-4(A4),A4		;
	BRA	SuchXBRA		;
;
;	Status Ñndern
;
StatAend:	BCHG	#Gesperrt,-14(A4)	; ge-
	BEQ	NichtAkt		; sperrt ?
	LEA	Meldung2(PC),A0	; Freigabe-
	BRA	ZeigStat		; oder
				;
NichtAkt:	LEA	Meldung3(PC),A0	; Sperr-
ZeigStat:	BSR	ZeigMeld		; Meldung
	MOVE.W	#PTERM0,-(SP)	; Programm
	TRAP	#GEMDOS		; beenden
;
;	Installation des Loggers fÅr Trap-01
;
InstaLOG:	PEA	Trp01LOG		; Routine
	MOVE.W	#T01VktNr,-(SP)	; fÅr
	MOVE.W	#SetExec,-(SP)	; Trap-01
	TRAP	#BIOS		; einbauen
	MOVE.L	D0,_Trp01OV	; 
	ADDQ.L	#8,SP		;

	LEA	Meldung1(PC),A0	; Install.
	BSR	ZeigMeld		; melden

	MOVE.W	#0,-(SP)		; Programm
	MOVE.L	D7,-(SP)		; beenden &
	MOVE.W	#PTERMRES,-(SP)	; resident
	TRAP	#GEMDOS		; halten
;
;	Meldung zeigen und Taste warten
;
;	Aufruf
;	<A0>:	Zeiger auf Meldungstext
;
ZeigMeld:	MOVE.L	A0,-(SP)		;
	MOVE.W	#CCONWS,-(SP)	; Meldung
	TRAP	#GEMDOS		; ausgeben
	ADD.L	#6,SP		;
	MOVE.W	#CRAWCIN,-(SP)	; warte auf
	TRAP	#GEMDOS		; Taste
	ADD.L	#2,SP		;
	RTS			;
;
;	Trap 01 TRAP_LOG.TOS
;
;	benutzte Register: A0, D0
;
StrngFlg:	DC.W	NUL		; Steuerung
Magic_01:	DC.B	'XBRA'		; Magic
Ident_01:	DC.B	'TLOG'		; Ident-Nr.
_Trp01OV:	DC.L	0		; Original

Trp01LOG:	BTST	#Desktop,StrngFlg	; ggf.
	BNE	Tr01LOG1		; Trap-02-
	BSR	TestBoot		; Logger
	BTST	#Desktop,StrngFlg	; auch noch
	BEQ	Tr01LOG1		; instal-
	BSR	InstTr02		; lieren
Tr01LOG1:	MOVE.L	SP,A0		; A0 = SP
	BTST	#SuperMod,(SP)	; alter
	BNE	Tr01LOG2		; Status 
	MOVE.L	USP,SP		; bestimmt,
	MOVE.L	SP,D0		; ob USP zu
	BRA	Tr01LOG3		; benutzen

Tr01LOG2:	MOVE.L	SP,D0		; ist oder
	ADDQ.L	#6,D0		; SSP
Tr01LOG3:	EXG	D0,A0		; rette den
	MOVE.L	D0,-(SP)		; alten SP
	BTST	#Gesperrt,StrngFlg	; ge-
	BNE	Tr01LOG4		; sperrt ?
	MOVE.L	A0,-(SP)		; 
	MOVE.W	#'G',D0		; 'G' fÅr
	BSR	AusgZchn		; GEMDOS,
	MOVE.L	(SP)+,A0		; dann Åber
	MOVE.W	(A0),D0		; A0 adres-
	MOVE.B	D0,-(SP)		; sierte
	ASR.B	#4,D0		; Nummer
	BSR	AusgHlbB		; ausgeben
	MOVE.B	(SP)+,D0		;
	BSR	AusgHlbB		;
	BSR	AusgLeer		;
Tr01LOG4:	MOVE.L	(SP),SP		; SP okay
Tr01LOG5:	MOVE.L	_Trp01OV,A0	; weiter
	JMP	(A0)		; wie sonst
;
;	Installation Trap-02-Logger
;
InstTr02:	BSR	RettOrgV		; erst die
	LEA	IllAdLOG(PC),A0	; Original-
	MOVE.L	A0,4*IllAdVNr	; vektoren
	LEA	TraceLOG(PC),A0	; sichern,
	MOVE.L	A0,4*TraceVNr	; dann die
	LEA	FLineLOG(PC),A0	; Logger-
	MOVE.L	A0,4*FLineVNr	; Routinen
	LEA	Trp02LOG(PC),A0	; ein-
	MOVE.L	A0,4*T02VktNr	; binden
	RTS			;
;
;	Rettung der Original-Vektoren
;
RettOrgV:	MOVE.L	4*IllAdVNr,_IllAdOV	;
	MOVE.L	4*TraceVNr,_TraceOV	;
	MOVE.L	4*FLineVNr,_FLineOV	;
	MOVE.L	4*T02VktNr,_Trp02OV	;
	RTS			;
;
;	Test, ob das Boot schon schwimmt
;
TestBoot:	BSET	#BootTest,StrngFlg	; Merker f.
	BNE	TstBoot2		; TestBoot
	MOVE.L	4*FLineVNr,-(SP)	; wenn
	OR.L	#$FF000000,(SP)	; FLine- &
	MOVE.L	4*TraceVNr,D0	; Trace-
	OR.L	#$FF000000,D0	; Vektor
	CMP.L	(SP)+,D0		; ungleich,
	BEQ	TstBoot1		; dann
	BSET	#Desktop,StrngFlg	; lÑuft
	RTS			; Desktop

TstBoot1:	BSR	RettOrgV		; Vektoren
	RTS			; retten

TstBoot2:	MOVE.L	4*FLineVNr,D0	; Desktop
	CMP.L	_FLineOV,D0	; lÑuft,
	BEQ	TstBoot9		; wenn
	MOVE.L	4*T02VktNr,D0	; Vektoren
	CMP.L	_Trp02OV,D0	; fÅr FLine
	BEQ	TstBoot9		; & Trap-02
	BSET	#Desktop,StrngFlg	; geÑndert
TstBoot9:	RTS			;
;
;	Trap 02 TRAP_LOG.TOS
;
;	geÑnderte Register: keine
;
Magic_02:	DC.B	'XBRA'		; Magic
Ident_02:	DC.B	'TLOG'		; Ident-Nr.
_Trp02OV:	DC.L	0		; Original

Trp02LOG:	BTST	#Gesperrt,StrngFlg	; ge-
	BNE	Tr02LOG6		; sperrt ?
	MOVEM.L	D0-D2/A0-A2,-(SP)	; rette
	MOVE.L	D1,-(SP)		; Register
	CMP.W	#AES_Code,D0	; AES-
	BEQ	Trp02AES		; Aufruf ?
	CMP.W	#VDI_Code,D0	; VDI-
	BEQ	Trp02VDI		; Aufruf ?
	ADDQ.L	#4,SP		; wer kommt
	BRA	Tr02LOG5		; hierhin ?

Trp02VDI:	MOVE.W	#'V',D0		; 'V' / 'A'
	BRA	Tr02LOG4		; fÅr

Trp02AES:	MOVE.W	#'A',D0		; VDI / AES
Tr02LOG4:	BSR	AusgZchn		; ausgeben
	MOVE.L	(SP)+,A0		; zeigt auf
	MOVE.L	(A0),A0		; Zeiger,
	MOVE.W	(A0),D0		; der zeigt
	BSR	AusgByte		; auf Nr.
	BSR	AusgLeer		;
Tr02LOG5:	MOVEM.L	(SP)+,D0-D2/A0-A2	; Reg. okay
Tr02LOG6:	MOVE.L	_Trp02OV,-(SP)	; weiter,
	RTS			; wie sonst
;
;	illegale Adresse
;
_IllAdOV:	DC.L	NUL		; Original

IllAdLOG:	MOVE.L	A0,-(SP)		; A0 und D0
	MOVE.L	D0,-(SP)		; retten
	MOVE.L	10(SP),A0		; ill. Adr.
	CMP.B	#$F0,-3(A0)	; selbst
	BLT	IllAdAlt		; erzeugt ?
	MOVE.L	4*T02VktNr,D0	; Logger
	CMP.L	_Trp02OV,D0	; wieder
	BNE	IlAdLOG1		; einbin-
	LEA	Trp02LOG(PC),A0	; den, wenn
	MOVE.L	A0,4*T02VktNr	; Vektor
	BRA	IlAdLOG2		; verÑndert

IlAdLOG1:	MOVE.W	-3(A0),D0		; sonst
	AND.L	#$00000FFF,D0	; Merker
	ASR.W	#2,D0		; fÅr zuge-
	EXG.L	D0,A0		; hîrige
	ADD.L	#FLineTab,A0	; Routine
	CLR.B	(A0)		; lîschen
IlAdLOG2:	MOVE.L	(SP)+,D0		; A0, D0,
	MOVE.L	(SP)+,A0		; Stack und
	MOVE.L	2(SP),10(SP)	; RÅck-
	AND.L	#$FFFFFFFE,10(SP)	; sprung-
	ADD.L	#8,SP		; adresse
	RTE			; okay

IllAdAlt:	MOVE.L	(SP)+,D0		; D0 & A0
	MOVE.L	(SP)+,A0		; okay,
	MOVE.L	_IllAdOV,A0	; weiter
	JMP	(A0)		; wie sonst
;
;	FLine
;
_FLineOV:	DC.L	NUL		; Original

FLineLOG:	MOVE.L	A0,-(SP)		; A0 retten
	MOVE.L	6(SP),A0		; Opcode
	ADD.L	#1,A0		; testen
	BTST	#Unlink,(A0)	;
	BNE	FLinLOG1		;
	MOVE.L	D0,-(SP)		; D0 retten
	ADD.L	#1,A0		; Nummer d.
	MOVE.W	-2(A0),D0		; FLine-
	AND.L	#$00000FFF,D0	; Routine
	ASR.W	#2,D0		; bestimmen
	EXG.L	D0,A0		; und zuge-
	ADD.L	#FLineTab,A0	; hîrigen
	TST.B	(A0)		; Merker
	BEQ	FLinLOG0		; testen,
	MOVE.L	(SP),-(SP)	; ggf.
	MOVE.L	8(SP),4(SP)	; Adresse
	MOVE.W	12(SP),8(SP)	; merken &
	MOVE.L	14(SP),10(SP)	; und Trace
	MOVE.L	D0,14(SP)		; ver-
	BSET	#TraceMod,8(SP)	; anlassen
FLinLOG0:	MOVE.L	(SP)+,D0		; D0 und A0
FLinLOG1:	MOVE.L	(SP),A0		; okay
	MOVE.L	_FLineOV,(SP)	; weiter
	RTS			; wie sonst
;
;	Trace
;
_TraceOV:	DC.L	NUL		; Original

TraceLOG:	MOVE.L	A0,-(SP)		; A0 & D0
	MOVE.L	D0,-(SP)		; retten
	BTST	#SuperMod,8(SP)	; alter
	BEQ	TracLOG1		; Status
	MOVE.L	SP,A0		; bestimmt,
	ADD.L	#18,A0		; ob SSP
	BRA	TracLOG2		; oder USP

TracLOG1:	MOVE.L	USP,A0		; zu nutzen
TracLOG2:	MOVE.L	(A0),D0		; wenn Adr.
	CMP.L	14(SP),D0		; ungleich,
	BEQ	TraceEnd		; D0 & A0
	MOVE.L	(SP)+,D0		; vom Stack
	MOVE.L	(SP)+,A0		; holen,
	RTE			; tracen

TraceEnd:	BSET	#0,3(A0)		; Adresse,
	MOVE.L	(SP)+,D0		; D0, A0
	MOVE.L	(SP)+,A0		; und Stack
	MOVE.L	2(SP),6(SP)	; berichti-
	MOVE.W	(SP),4(SP)	; gen,
	BCLR	#TraceMod,4(SP)	; Trace
	ADD.L	#4,SP		; beenden
	RTE			;
;
;	Ausgabe Byte
;
AusgByte:	MOVE.W	D0,-(SP)		;
	ASR.B	#4,D0		; oberes
	BSR	AusgHlbB		; Halbbyte
	MOVE.W	(SP)+,D0		; unteres
	BSR	AusgHlbB		; Halbbyte
	RTS
;
;	Ausgabe Halb-Byte (nibble)
;
AusgHlbB:	AND.W	#$000F,D0		; unterstes
	LEA	HexAscTb(PC),A0	; Halbbyte
	MOVE.B	(A0,D0),D0	; zeigt auf
	BRA	AusgZchn		; Zeichen
;
;	Neue Zeile
;
NeueZeil:	MOVE.W	#CR,D0		; Zeilen-
	BSR	AusgZchn		; anfang
	MOVE.W	#LF,D0		; nÑchste
	BRA	AusgZchn		; Zeile
;
;	Ausgabe Leerzeichen
;
AusgLeer:	MOVE.W	#BLANK,D0		; ' ' !
;
;	Ausgabe Zeichen
;
;	enthalten sind Start/Stop und Zeitlupe
;
;	Aufruf
;	<D0>:	Zeichen
;
AusgZchn:	MOVEM.L	D1-D2/A1-A2,-(SP)	; Register
	MOVE.W	D0,-(SP)		; retten
	BTST	#Zeitlupe,MFP_PIO	; Tee
	BEQ	AusgZch1		; trinken,
	MOVE.L	#150,D0		; wenn ge-
	BSR	Wartzeit		; schlossen
AusgZch1:	BSR	TstDruck		; zurÅck,
	BNE	AusgZch3		; wenn
	ADD.L	#2,SP		; geîffnet
	BRA	AusgZch4		;
	
AusgZch3:	MOVE.W	#PRN,-(SP)	; Status
	MOVE.W	#Bcostat,-(SP)	; des
	TRAP	#BIOS		; Druckers
	ADDQ.L	#4,SP		; ermitteln

	CMP.W	#Bereit,D0	; wenn
	BNE	AusgZch1		; bereit,
	MOVE.W	#PRN,-(SP)	; dann
	MOVE.W	#Bconout,-(SP)	; Zeichen
	TRAP	#BIOS		; ausgeben
	ADDQ.L	#6,SP		;
AusgZch4:	MOVEM.L	(SP)+,D1-D2/A1-A2	; Register
	RTS			; holen
;
;	Wartezeit
;
;	Aufruf
;	<D0>:	Anzahl der Wartezyklen,
;		leider ein Software-Timer
;
Wartzeit:	MOVE.L	#10,D1		;
Wartzei1:	DBRA	D1,Wartzei1	;
	DBRA	D0,Wartzeit	;
	RTS			; genug
;
;	Test Schalter 'Drucken'
;
;	RÅcksprung
;	<Z>:	1 - Druck
;		0 - kein Druck
;
TstDruck:	MOVE.L	D1,-(SP)		; D1 retten
	MOVE.B	MFP_PIO,D1	; Wenn
	MOVE.B	StrngFlg,D0	; Schalter
	EOR.B	D1,D0		; betÑtigt,
	BTST	#Drucken,D0	; dann Flag
	BEQ	TstDrck2		; Ñndern &
	BCHG	#Drucken,StrngFlg	; ggf.
	BNE	TstDrck1		; Zeilen-
	BSR	NeueZeil		; vorschub
TstDrck1:	MOVE.L	#1000,D0		; Ent-
	BSR	Wartzeit		; prellen
TstDrck2:	MOVE.L	(SP)+,D1		; D1 okay
	BTST	#Drucken,StrngFlg	; Test
	RTS			;
;
;	Konstanten
;
HexAscTb:	DC.B	'0123456789ABCDEF'	; Hex-Ascii
;
;	Variablen
;
FLineTab:				; Merker
REPT	$1000/4			; fÅr
	DC.B	$FF		; Trace
ENDM				;
;
;	Texte
;
Meldung1:	DC.B	'TRAP_LOG.PRG installiert'
	DC.B	CR,LF,LF
	DC.B	'Stephan Simson 27.03.90'
	DC.B	CR,LF,NUL

Meldung2:	DC.B	'TRAP_LOG.PRG wieder aktiv'
	DC.B	CR,LF,NUL

Meldung3:	DC.B	'TRAP_LOG.PRG deaktiviert'
	DC.B	CR,LF,NUL

END
