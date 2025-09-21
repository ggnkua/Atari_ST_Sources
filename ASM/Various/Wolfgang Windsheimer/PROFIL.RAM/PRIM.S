*	*	*	*	*	*	*	*	*
*								*
*	32-bit-Primzahlensuche					*
*	geeignet z.B. fr den DR-Assembler			*
*	ohne Unterprogrammbibliotheken zu verwenden		*
*								*
*	*	*	*	*	*	*	*	*

	gemdos	 = 1
	bios	 = 13

	conout	 = 2
	conin	 = 7
	printlin = 9
	setblk	 = $4a

	p_init	 = $90020	; Funktionsnummern des Ausfhrungs-
	p_start	 = $90021	; profils
	p_stop	 = $90022
	p_addr	 = $90023
	tp_start = $90025

	totcnt	 = 0		; Profildatenstruktur
	startad	 = 4
	scale	 = 8
	entries	 = 10

	.data
prim_m	dc.b	'            ',0,0
pr1	dc.b	27,'E',27,'Y',$21,$2c
	dc.b	'*** Primzahlsuche bis 4.2E9     27.9.1987 ***'
	dc.b	27,'Y',$22,$2c
	dc.b	'*** Spaghetti - Fan - Club Nrnberg  V1.2 ***'
	dc.b	27,'Y',$24,$28,'von Zahl: ',27,'e',0
in_1	dc.b	27,'Y',$24,$32,27,'K',0
pr2	dc.b	27,'Y',$26,$28,'bis Zahl: ',0
in_2	dc.b	27,'Y',$26,$32,27,'K',0
s_stepm	dc.b	27,'Y',$28,$28,'mit Einzelschrittprofil? [JjYy]',0
in_e	dc.b	27,'f',13,10,10,0
all_m1	dc.b	13,10,10,' Das waren alle ',0,'       '
all_m2	dc.b	' Primzahlen im angegebenen Bereich.',13,10,0


	.text
entry:	move.l	4(a7),A5	; base page address
	move.l	12(a5),D0	; Code
	add.l	20(a5),D0	; Daten
	add.l	28(a5),D0	; BSS
	addi.l	#$300,D0	; $100 base page + $200 Stack
	lea	0(A5,D0.l),A7	; Stackpointer ber den RAM-Bereich
	move.l	D0,-(A7)	; setzen
	move.l	a5,-(A7)
	clr.w	-(A7)		; junk word
	move	#setblk,-(A7)	; RAM freigeben
	trap	#1
	adda.w	#12,A7

	link	A6,#-12		; Variablen anlegen

	move.w	#1,-(A7)	; 2KB 1:1 Profilbereich
	pea	entry(PC)	; vom Beginn an
	move.l	#p_init,-(A7)	; Initialisierung Ausfhrungsprofil
	trap	#bios
	adda.w	#10,A7

error0:	lea	in_1,A3
	pea	pr1-in_1(A3)
	move.w	#printlin,-(A7)
	trap	#gemdos		; Aufforderung zur Eingabe der
	addq.l	#6,A7		; unteren Grenze

numlp1	bsr	getnum		; Zahl einlesen
	bmi	sexit
	bne	numlp1
	move.l	D3,-8(A6)	; und merken

	adda.w	#in_2-in_1,A3
	pea	pr2-in_2(A3)
	move.w	#printlin,-(A7)
	trap	#gemdos		; Aufforderung zur Eingabe der
	addq.l	#6,A7		; oberen Grenze

numlp2	bsr	getnum		; Zahl einlesen
	bmi	sexit
	bne	numlp2
	move.l	D3,-4(A6)	; und merken

	move.l	-8(A6),D3	; zu untersuchende Zahl (32 bit)
	bset	#0,D3		; ungerade machen
	clr.l	-12(A6)		; Primzahlz„hler initialisieren

	adda.w	#prim_m-in_2,A3	; Meldung fr Primzahlen

	move.l	#p_start,-(A7)	; Startcode fr Ausfhrungsprofil

	pea	s_stepm-prim_m(A3) ; Meldung: Einzelschritt oder
	move.w	#printlin,-(A7)	; normal statistisch?
	trap	#gemdos
	addq.l	#6,A7

	bsr	query		; anfragen:
	bne.s	was_no		; ja oder nein geantwortet?

	addq.l	#tp_start-p_start,(A7) ; wenn ja, dann Einzelschritt

was_no	trap	#bios		; Ausfhrungsprofil starten
	addq.l	#4,A7

*	*	*	*	*	*	*	*	*
*	Ab diesem Programmschritt wirkt das Ausfhrungsprofil.	*
*	*	*	*	*	*	*	*	*

	pea	in_e-prim_m(A3)
	move.w	#printlin,-(A7)
	trap	#gemdos		; Zeilenvorschub, Cursor aus
	addq.l	#6,A7
	move.b	#6,13(A3)	; anzeigen: soeben Zeilenvorscub

prim0	moveq	#1,D2		; Teiler fr Untersuchung (16 bit)

prim1	addq.w	#2,D2		; n„chster ungerader Teiler
	bcs.s	isprim		; falls >= 65536, dann D3 auch Primzahl

	move.l	D3,D0
	moveq	#0,D1
	swap	D3		; obere 16 Bits nach unten
	cmp.w	D2,D3		; wenn obere 16 Bits < Teiler,
	bcs.s	is16b		; dann nur einmal dividieren
*				; (Quotient nur 16 bit breit)

	move.w	D3,D1		; nur obere 16 Bits
	divu	D2,D1		; obere 16 Bits dividieren
	move.l	D1,D0		; Rest in oberen 16 Bits
	swap	D1		; wird obere 16 Bits des Quotienten

is16b	swap	D3		; nun die unteren 16 Bits
	move.w	D3,D0		; zusammen mit Rest von letzter Div.
	divu	D2,D0		; dividieren
	move.w	D0,D1		; Quotient in D1 (32 bit)
	swap	D0		; Rest in D0 (16 bit)

	cmp.l	D2,D1		; falls Quotient < Teiler
	bcs.s	isprim		; dann Primzahl gefunden
*				; („hnlich Quadratwurzelkriterium)
	tst.w	D0
	bne.s	prim1		; nicht aufgegangen: n„chster Teiler

p_cont	addq.l	#2,D3		; aufgegangen: keine Primzahl,
	bcs.s	all_ps		; n„chste ungerade Zahl versuchen,
	cmp.l	-4(A6),D3	; wenn n„chste Zahl > obere Grenze
	bcs.s	prim0		; oder šberlauf, dann Ende
	bra.s	all_ps

isprim	addq.l	#1,-12(A6)	; Primzahl gefunden: mitz„hlen

	lea	10(A3),A0
	move.l	D3,D1
	bsr	ltoa		; Zahl aus D3 dezimal umwandeln

	subq.b	#1,13(A3)
	bne.s	nonl		; nach jeder 6. Zahl Zeilenvorschub
	move.w	#$0d0a,10(A3)
	move.b	#6,13(A3)	; neue 6 Zahlen in n„chster Zeile
	bra.s	nl
nonl	move.w	#'  ',10(A3)

nl	move.l	A3,-(A7)
	move.w	#printlin,-(A7)
	trap	#gemdos		; Zahl ausgeben
	addq.l	#6,A7

	bra.s	p_cont		; mit n„chster Zahl fortsetzen

all_ps	pea	all_m1-prim_m(A3)
	move.w	#printlin,-(A7)
	trap	#gemdos		; Meldung ber Anzahl 1. Teil
	addq.l	#6,A7

	lea	all_m2-prim_m(A3),A0
	move.l	-12(A6),D1	; Anzahl der Primzahlen
	bsr	ltoa		; dezimal umwandeln

	move.l	A0,(A7)		; von Anfang der Ziffernfolge
	move.w	#printlin,-(A7)
	trap	#gemdos		; 2. Teil der Meldung ausgeben
	addq.l	#6,A7

	move.l	#p_stop,-(A7)
	trap	#bios		; Ausfhrungsprofil anhalten

*	*	*	*	*	*	*	*	*
*	Dieser Programmschritt wird vom Ausfhrungsprofil nicht	*
*	mehr erfat.						*
*	*	*	*	*	*	*	*	*

	move.l	#p_addr,(A7)
	trap	#bios		; Adresse der Profildatenstruktur
	addq.l	#4,A7		; holen

	tst.l	D0
	bmi.s	notadr		; wenn gltige Adresse,
	move.l	D0,A0		; Profiladressen relativ zu Programm-
	subi.l	#entry,startad(A0) ; anfang machen (Assemblerlisting!)

notadr	move.w	#conin,-(A7)	; exit-Bremse
	trap	#1

sexit	unlk	A6
	clr.w	(A7)		* back to gemdos
	trap    #1

*	*	*	*	*	*	*	*	*
*	Zahlen dezimal einlesen 				*
*	A3    -> Adresse der Bildschirm-Initialisierungssequenz	*
*	D3    <- 32 bit-Zahl					*
*	D0    0: CR, neg.: sonst. Steuerz., pos.: Nicht-Ziffer	*
*	*	*	*	*	*	*	*	*

getnum	move.l	A3,-(A7)
	move.w	#printlin,-(A7)	; Cursor zurcksetzen fr n„chste
	trap	#gemdos		; Eingabe
	addq.l	#6,A7

	moveq	#0,D3		; dorthin kommt die Zahl
	bra.s	getnbeg

getnlp	move.w	D1,-(A7)
	move.w	#conout,-(A7)	; Echo von letztem Zeichen
	trap	#gemdos
	addq.l	#4,A7

getnbeg	move.w	#conin,-(A7)
	trap	#gemdos		; ein Zeichen von der Tastatur
	addq.l	#2,A7

	cmpi.w	#8,D0		; <BS>?
	beq.s	getnum
	cmpi.w	#13,D0		; <CR>?
	beq.s	gexit0		; mit D0=0 zurck
	cmpi.w	#$20,D0		; sonstiges Steuerzeichen
	bcs.s	gexitN		; mit D0<0 zurck

	move.w	D0,D1		; fr sp„tere Ausgabe
	subi.w	#$30,D0		; Dezimalziffern -> 0 .. 9
	cmpi.w	#9,D0		; Dezimalziffer?
	bhi.s	numend

	move.l	D3,D2
	swap	D2
	mulu	#10,D2		; obere 16 Bits	* 10
	swap	D2

	tst.w	D2		; wenn šberlauf,
	bne.s	getnum		; dann Beginn von vorne

	move.w	D0,D2		; nur noch obere 16 Bits + neue Ziffer
	mulu	#10,D3
	add.l	D2,D3		; alle Bits * 10 + neue Ziffer
	bcc.s	getnlp		; n„chste Ziffer
	bra.s	getnum

numend	moveq	#1,D0		; mit D0>0 zurck
	rts

gexit0	clr.w	D0
	rts
gexitN	moveq	#-1,D0
	rts

*	*	*	*	*	*	*	*	*
*	32-Bit-Zahl in dezimale Ziffernfolge umwandeln		*
*	A0 	-> Adress ein Byte oberhalb des Zielstrings	*
*		   (Ausgabe rechtsbndig)			*
*	D1	-> umzuwandelnde Zahl				*
*	A0	<- Anfangsadresse der umgewandelten Zahl im	*
*		   Zielstring					*
*	*	*	*	*	*	*	*	*
	
ltoa	swap	D1		; obere 16 bit jetzt unten
divlp	clr.l	D0
	move.w	D1,D0		; obere 16 bit
	beq.s	b16
	divu	#10,D0
	move.w	D0,D1		; Quotient nach oben, Rest oben in D0
b16	swap	D1
	move.w	D1,D0		; Rest von oben + untere 16 bit
	divu	#10,D0
	move.w	D0,D1		; Quotient nach unten
	swap	D0		; Rest (16 bit)
	addi.w	#48,D0		; zugeh”rige Dezimalziffer
	move.b	D0,-(A0)	; von rechts nach links in String
	swap	D1		; obere 16 bit wieder unten + CCR
	bne.s	divlp		; solange, bis Zahl vollst. behandelt
	rts

*	*	*	*	*	*	*	*	*
*	Ja-Nein-Anfrage						*
*	Z=1	<- ja						*
*	Z=0	<- nein						*
*	*	*	*	*	*	*	*	*

query	move.w	#conin,-(A7)
	trap	#gemdos		; ein Zeichen von der Tastatur
	addq.l	#2,A7

	andi.b	#$df,D0		; Klein- -> Grobuchstaben
	cmpi.b	#'J',D0
	beq.s	queryes
	cmpi.b	#'Y',D0
queryes	rts			; Z=0 fr Ja zurckgeben

	.end
