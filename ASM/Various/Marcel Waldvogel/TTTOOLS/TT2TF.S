*
* TT2TF (Thirty-Two To Twenty-Four)
*
* Zweck: Der Adressbus wird von 32 auf 24 Bits "beschnitten". Dadurch
*        laufen einige Programme auf dem TT, die die oberen 8 Bits
*        fuer eigene Zwecke reservieren (z.B. TEMPUS 2).
*
* Zum Assemblieren unter TC/MASM Stacksize auf 0 stellen.
*
* (c) 1990 Marcel Waldvogel
*

TWOLEVEL= 1			;Zweistufig?
; Braucht weniger Platz, ist dafuer (manchmal) unmerklich langsamer.

id	= 'TTTF'
cookie	= $5A0			;Adresse des Cookie-Pointers
ssize	= 2048			;Stackgroesse

	move.l	4(A7),A5	;Get Basepage
	lea	stack,A7	;Install stack

	pea	message
	move.w	#9,-(A7)	;Cconws()
	trap	#1
	addq.l	#6,A7

	clr.l	-(A7)
	move.w	#$20,-(A7)	;Super()
	trap	#1
	addq.l	#2,A7		;Nur 2!!
	move.l	D0,(A7)		;Schon wieder auf den Stack (kein "-"!!)

	suba.l	A3,A3		;Zeiger auf eigenes Cookie loeschen
	move.l	cookie.w,D0	;Existiert er?
	beq	dommu		;Nein, dann einfach installieren
	movea.l	D0,A0
	move.l	#id,D0		;Meine ID
cloop:	move.l	(A0),D1		;Noch ein Eintrag?
	beq	install		;Nein ->
	addq.l	#8,A0		;Zum naechsten Cookie
	cmp.l	D0,D1		;Mein Eintrag?
	bne	cloop		;Nein ->

				;Bereits installierten TT2TF aufrufen
callold:move.l	-(A0),D0	;Keine Bemerkung: Installation missglueckt
	lea	nullmsg,A0	;Defaultfehler (aendert CCR nicht)
	beq	msgterm		;Keine ->
	movea.l	D0,A3
	not.w	-2(A3)		;Zustand wechseln
;	jsr	(A3)		;Anspringen

	lea	oldmsg,A0	;Defaultmessage
	tst.w	-(A3)		;Alter Zustand?
	bmi	msgterm		;Ja ->
	lea	okmsg,A0	;Neuer Zustand (A24)
	bra	msgterm


install:move.l	cookie.w,A0	;Jetzt eintragen (Cookiejar sicher da!)
	moveq	#0,D0
ciloop:	addq.l	#1,D0
	tst.l	(A0)		;Ende?
	beq	endfnd
	addq.l	#8,A0
	bra	ciloop
endfnd:	cmp.l	4(A0),D0	;Noch Platz?
	beq	dommu		;Nein ->
	move.l	4(A0),12(A0)	;Ja, einfuegen
	clr.l	8(A0)
	move.l	#id,(A0)+
	clr.l	(A0)		;"Noch nicht eingetragen"
	movea.l	A0,A3		;Adresse speichern


dommu:	move.l	#table,D0	;Tabelle erzeugen
	and.w	#$FFF0,D0	;Unterste Bits ausmaskieren
	move.l	D0,rootadr	;CPU Root Pointer fertig initialisieren
	movea.l	D0,A0

	IF	TWOLEVEL
	move.l	#16*32768,D1	;Offset zwischen zwei Seiten
	moveq	#$1,D0		;Adresse 0 | Page_descriptor
	moveq	#30,D2		;31 "1:1"-Eintraege
maketab:move.l	D0,(A0)+	;Eintragen
	add.l	D1,D0		;Offset zur naechsten Page
	dbf	D2,maketab
	move.l	A0,D1		;Hole aktuellen Zeiger
	addq.l	#6,D1		;+4: Naechste Adresse, +2: Table_Desc 4 Bytes
	move.l	D1,(A0)+

	move.l	#32768,D1	;Neuer Offset zwischen zwei Seiten
	moveq	#14,D2		;15 "1:1"-Eintraege
maket2:	move.l	D0,(A0)+
	add.l	D1,D0
	dbf	D2,maket2
	move.l	#$FFFF8041,(A0)	;1 Eintrag I/O-Bereich, mit Cache Inhibit

	ELSE

	move.l	#32768,D1	;Offset zwischen zwei Seiten
	moveq	#$1,D0		;Adresse 0 | Page_descriptor
	move.w	#510,D2		;511 "1:1"-Eintraege
maketab:move.l	D0,(A0)+	;Eintragen
	add.l	D1,D0		;Offset zur naechsten Page
	dbf	D2,maketab
	move.l	#$FFFF8041,(A0)	;1 Eintrag I/O-Bereich, mit Cache Inhibit
	ENDC

	move.l	A7,A6
	move.l	44.w,A4		;Alten Exc.-Vektor holen
	move.l	#newexc,44.w

	move	SR,D0		;Wird in setmmu wieder zurueckgesetzt
	ori	#$2700,SR
	lea	oldreg,A0
	bsr	getmmu

	bsr	dismmu		;MMU ausschalten

	lea	myreg,A0
	bsr	setmmu
	move.l	A4,44.w		;Wieder zurueck

	move.l	A3,D0		;In Cookie-Jar eingetragen?
	beq	cfull		;Nein, war voll ->
	move.l	#swapper,(A3)	;Ja, eintragen

cfull:	pea	okmsg
	move.w	#9,-(A7)	;Cconws()
	trap	#1
	addq.l	#6,A7

resi:	move.w	#$20,-(A7)	;Super(), altes A7 schon vorher auf dem Stack
	trap	#1
	addq.l	#6,A7

				;Der Stack wird mit freigegeben!
	movea.w	#256-ssize,A0	;Groesse der Basepage - Stack
	adda.l	12(A5),A0	;   "    des TEXT-Segmentes
	adda.l	20(A5),A0	;   "     "  DATA-Segmentes
	adda.l	28(A5),A0	;   "     "  BSS-Segmentes

	clr.w	-(a7)		;Alles ok
	move.l	A0,-(a7)	;Belegter Speicher
	move.w	#$31,-(a7)	;Ptermres()
	trap	#1
	illegal



newexc:	move.l	A4,44.w		;Wieder zurueck
	move.l	A6,A7
	lea	mmumsg,A0

msgterm:move.l	A0,-(A7)
	move.w	#9,-(A7)	;Cconws()
	trap	#1
	addq.l	#6,A7

	move.w	#$20,-(A7)	;Super(), altes A7 schon vorher auf dem Stack
	trap	#1
	addq.l	#6,A7

	clr.w	-(A7)		;Pterm0()
	trap	#1
	illegal


setmmu:
;	pmove	(A0),TT0	;Evt. Line-F-Exception generieren
	dc.l	$F0100800	;Von Hand, der Assembler macht Fehler
	addq.l	#4,A0
;	pmove	transp1,TT1	;Evt. Line-F-Exception generieren
	dc.l	$F0100C00
	addq.l	#4,A0

	pmove	(A0),CRP	;CPU Root Pointer setzen
	addq.l	#8,A0

	pmove	(A0),TC		;Translation Control setzen
	move	D0,SR
	rts


getmmu:
;	pmove	TT0,(A0)	;Hole TT0
	dc.l	$F0100A00	;Der Assembler will nicht...
	addq.l	#4,A0		;Zum naechsten Platz

;	pmove	TT1,(A0)	;Hole TT0
	dc.l	$F0100E00	;Der Assembler will nicht...
	addq.l	#4,A0		;Zum naechsten Platz

	pmove	CRP,(A0)	;Hole CRP
	addq.l	#8,A0		;Zum naechsten Platz
	pmove	TC,(A0)		;Hole TC
	rts


dismmu:	lea	null2l,A0	;Sicher kein E[nabled]-Bit gesetzt...
;	pmove	(A0),TT0	;Evt. Line-F-Exception generieren
	dc.l	$F0100800	;Von Hand, der Assembler macht Fehler
;	pmove	transp1,TT1	;Evt. Line-F-Exception generieren
	dc.l	$F0100C00

	pmove	(A0),TC		;Translation Control zuerst setzen!
	rts


config:	dc.w	0		;Zustandsflag
swapper:move	SR,D0		;Statusregister wird in setmmu zurueckgesetzt
	ori	#$2700,SR	;Interrupts weg

	bsr	dismmu		;MMU ausschalten
	lea	myreg,A0	;Default-MMU-Konfiguration

	tst.w	config		;Alter/neuer Zustand?
	bpl	setmmu		;Neuen Zustand, ja ->

	lea	oldreg,A0
	bra	setmmu		;bsr + rts =: bra


	DATA

message:dc.b	13,10,"TT2TF - Thirty-Two To Twenty-Four"
	dc.b	13,10,"(c) 1990 Marcel Waldvogel",0
nullmsg:dc.b	13,10,27,'p',"ERROR: Resident TT2TF badly installed,"
	dc.b	13,10,       "       MMU or 68030 was missing!",27,'q',7,13,10,0
mmumsg:	dc.b	13,10,27,'p',"ERROR: MMU or 68030 missing!",27,'q',7,13,10,0
oldmsg:	dc.b	13,10,"Old MMU settings restored",13,10,0
okmsg:	dc.b	13,10,"24 Bit Address Bus installed",13,10,0
	even

null2l:	dc.l	0,0	;Zum disablen der MMU-Register

myreg:
transp0:dc.l	0	;No transparent translation
transp1:dc.l	0	;No transparent translation
root:	dc.w	$8000,$0002	;Unlimited, 4-Byte
rootadr:dc.l	0
	IF	TWOLEVEL
tctrl:	dc.l	$80F85400
;		     ^^^^ 1. Stufe: 5 Bits, 2. Stufe: 4 Bits
;		    ^ die obersten 8 Bits werden ignoriert
;		   ^ Page Size: 32 KB (15 Bits)
;		  ^ No Supervisor Root Pointer, No Function Code Lookup
;		 ^ Enable

	ELSE

tctrl:	dc.l	$80F89000
;		     ^^^^ 1. Stufe: 5 Bits, 2. Stufe: 4 Bits
;		    ^ die obersten 8 Bits werden ignoriert
;		   ^ Page Size: 32 KB (15 Bits)
;		  ^ No Supervisor Root Pointer, No Function Code Lookup
;		 ^ Enable
	ENDC


	BSS

oldreg:	ds.l	5		;Platz zum Auslesen der MMU-Register

	even
	ds.b	16		;Platz, falls Tabelle sonst nicht aligned
	IF	TWOLEVEL
table:	ds.l	32+16
	ELSE
table:	ds.l	512
	ENDC

	even
	ds.b	ssize		;Platz fuer den Stack
stack:
