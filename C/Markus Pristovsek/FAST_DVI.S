;********************************************************************
;***	*Schnelle* Ausgabe von Zeichen im Hintergrund		*****
;********************************************************************

EXPORT	prn_byte, exstall, old_vec, CookieJar
IMPORT	shm_name, Fdelete, Cconws, Supexec, Fselect

	TEXT
; **********************************************
; ****	Sucht nach CookieJar (fÅr Dialoge)  ****
Cook:	DC.L	0
CookieJar:
	MOVE.L	D0,	Cook
	PEA	SearchCookie(PC)
	MOVE	#38,	-(A7)
	TRAP	#14
	ADDQ.L	#6,	A7
	MOVE.L	Cook,	D0
	RTS

SearchCookie:
	MOVE.L	$5A0,	D0
	BLE	NoCookie
	MOVE.L	D0,	A0
	MOVE.L	Cook,	D0
cl:	CMP.L	(A0),	D0
	BEQ	YesCookie
	TST.L	(A0)+
	BEQ	NoCookie
	ADDQ.L	#4,	A0
	BRA	cl
YesCookie:
	MOVE.L	4(A0),	Cook
	RTS
NoCookie:
	CLR.L	Cook
	RTS
;****	30.1.92    ****


; **** Programm durch Signal gekillt! */
exstall:
	TST.L	ptr
	BEQ	no_ex_
	LEA	ex_print(PC),A0
	BSR	Supexec
no_ex_:	
;	LEA	shm_name,A0	; TemporÑre Datei wird z.Zt. nicht gelîscht!
;	BSR	Fdelete
	LEA	killed,	A0
	BSR	Cconws
	CLR	-(A7)
	TRAP	#1
	RTS

ex_print:
	CLR.L	anzahl
	BCLR	#0,	$FA09.W	; Ausschalten
	BCLR	#0,	$FA15.W	; Maskieren
	MOVE.L	old_vec,$100.W
	CLR.L	old_vec
	RTS

/* Idee aus ST-Computer 5/92, sehr stark modifiziert */
prn_byte:
	MOVE.L	D0,	anzahl	; Anzahl
	BLE	no_print
	MOVE.L	A0,	ptr
	LEA	i_byte(PC),A0
	BSR	Supexec
no_print:RTS

;* Interrupt installieren *
i_byte:	LEA	xbra,	A0	; Xbra-Routine bauen
	MOVE.L	#'XBRA',(A0)+
	MOVE.L	#'DVIR',(A0)+
	MOVE.L	$100.W,	(A0)+	; alter Vektor
	MOVE.L	#$07C0700,(A0)+	; ORI #$0700,SR
	MOVE.W	#$4EB9,	(A0)+	; JSR out
	MOVE.L	#out,	(A0)+
	MOVE.W	#$4E73,	(A0)+	; RTE
	MOVE.L	#int,	$100.W

	BCLR	#0,	$FA03.W
	BCLR	#0,	$FA05.W
	BSET	#0,	$FA09.W	; Anschalten
	BSET	#0,	$FA15.W	; Maskieren
	MOVE.B	#$FE,	$FA11.W

	MOVE.B	#14,	$8800.W		; Strobe aus
	MOVE.B	$8800.W,D0
	BSET	#5,	D0
	MOVE.B	D0,	$8802.W


;* Ab hier Druck *
;* Byte ausgeben *
out:	SUBQ.L	#1,	anzahl	; Schon fertig?
	BMI	ende
	MOVEM.L	D0/A0,	-(A7)
;	BCLR	#0,	$FA15.W	; Demaskieren
	MOVE.B	#15,	$8800.W
	MOVE.L	ptr,	A0
	MOVE.B	(A0)+,	$8802.W
	MOVE.L	A0,	ptr

	MOVE	wait1,	D0
.time1:	NOP
	DBRA	D0,	.time1

	MOVE.B	#14,	$8800.W
	MOVE.B	$8800.W,D0
	BCLR	#5,	D0
	MOVE.B	D0,	$8802.W
	BSET	#5,	D0
	MOVE.W	D0,	A0

	MOVE	wait2,	D0
.time2:	NOP
	DBRA	D0,	.time2
	MOVE.W	A0,	D0
	MOVE.B	D0,	$8802.W

	MOVEM.L	(A7)+,	D0/A0
;	BSET	#0,	$FA15.W	; Maskieren
	MOVE.B	#$FE,	$FA11.W
	RTS

;* Beenden *
ende:	MOVE.L	old_vec,$100.W
	BCLR	#0,	$FA09.W	; Ausschalten
	BCLR	#0,	$FA15.W	; Demaskieren
	CLR.L	old_vec
	RTS



	DATA
	DC.B	'PATCH:'
wait1:	DC.W	0
wait2:	DC.W	0
killed:	DC.B	27,'H ',7,0

	BSS
anzahl:	DS.L	1
ptr:	DS.L	1

;* Die Interuptroutine */
xbra:	DS.L	2
old_vec:DS.L	1
int:	DS.L	3
