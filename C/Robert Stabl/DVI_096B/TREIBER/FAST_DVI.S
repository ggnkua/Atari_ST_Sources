/********************************************************************
****	*Schnelle* Ausgabe von Zeichen im Hintergrund		*****
********************************************************************/

EXPORT	prn_byte, anzahl, ptr, exstall, old_vec
IMPORT	shm_name, Fdelete, Cconws

	TEXT
; **** Programm durch Signal gekillt! */
exstall:
	TST.L	ptr
	BLE	no_print
	PEA	ex_print
	MOVE.W	#38,	-(A7)
	TRAP	#14
	ADDQ.L	#6,	A7
	LEA	shm_name,	A0			; Tempor„re Datei wird z.Zt. nicht gel”scht!
	BSR	Fdelete
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

	MOVE.L	A2,	-(A7)
	PEA	i_byte
	MOVE.W	#38,	-(A7)
	TRAP	#14
	ADDQ.L	#6,	A7
	MOVE.L	(A7)+,	A2
no_print:
	RTS

/* Interrupt installieren */
i_byte:	MOVE.L	ptr,	A0
	MOVE.L	$100.W,	old_vec
	MOVE.B	#14,	$FFFF8800.W	; Strobe aus
	BSET	#5,	$FFFF8802.W
	MOVE.L	#p_byte,$100
	BCLR	#0,	$FA03.W
	BSET	#0,	$FA09.W	; Anschalten
	BSET	#0,	$FA15.W	; Demaskieren
	MOVE.B	#$FE,	$FA11.W
	BSR	out
	MOVE.L	A0,	ptr
	RTS

	DC.L	'XBRA'
	DC.L	'DVIR'
old_vec:DC.L	0
/* Ab hier Druck */
p_byte:	ORI	#$0700,	SR
	SUBQ.L	#1,	anzahl
	BLE	ende
o_byte:	MOVEM.L	D0/A0,	-(A7)
	MOVE.L	ptr,	A0
	BSR	out
	MOVE.L	A0,	ptr
	MOVEM.L	(A7)+,	D0/A0
	MOVE.B	#$FE,	$FA11.W
	RTE

/* Beenden */
ende:	MOVE.L	old_vec,$100.W
	BCLR	#0,	$FA09.W	; Ausschalten
	BCLR	#0,	$FA15.W	; Maskieren
	CLR.L	old_vec
	RTE

/* Byte ausgeben */
out:	MOVE.B	#15,	$FFFF8800.W
	MOVE.B	(A0)+,	$FFFF8802.W
	MOVE.B	#14,	$FFFF8800.W
	BCLR	#5,	$FFFF8802.W
	MOVEQ	#16,	D0
time1:	DBRA	D0,	time1
	MOVE.B	#14,	$FFFF8800.W
	BSET	#5,	$FFFF8802.W
	RTS

	DATA
killed:	DC.B	27,'H ',7,0

	BSS
anzahl:	DS.L	1
ptr:	DS.L	1
