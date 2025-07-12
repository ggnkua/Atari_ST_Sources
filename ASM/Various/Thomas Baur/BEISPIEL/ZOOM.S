*********************************************************
*                                                       *
*                                                       *
*         R E A L T I M E    M A G N I F I E R          *
*                                                       *
*                                                       *
*             Written by Alexander Beller               *
*                                                       *
*             Implemented by Thomas Baur                *
*                                                       *
*              Last Update: 11:04:1989                  *
*                                                       *
*                                                       *
*********************************************************

GEMDOS:	equ	1	* Trap des GEMDOS
BIOS:	equ	13	* Trap des BIOS
XBIOS:	equ	14	* Trap des XBIOS

P_LINE:	equ	$09	* GEMDOS-Funktionen
K_PROC:	equ	$31
M_SHRINK:	equ	$4A

G_PHYSB:	equ	$02	* XBIOS-Funktionen
G_RES:	equ	$04
S_SCREEN:	equ	$05
S_CURS:	equ	$15
G_KBDVB:	equ	$22
G_SUPER:	equ	$26

REPEAT:	equ	4	* Wiederholfrequenz
			* Bildaufbau im VBL

*********************************************************

P_START:
	move.l	4(a7),a6
	lea	U_STACK,a7	* Eigener Stack wird
			* initialisiert
	pea	(U_STACK-BSS_START)+(T_END-P_START)+256
	pea	(a6)
	clr.w	-(a7)
	move.w	#M_SHRINK,-(a7)	* Nicht benutzter
	trap	#GEMDOS	* Speicher wird 
	lea	12(a7),a7	* zurueckgegeben

*********************************************************

	clr.w	-(a7)
	move.w	#S_CURS,-(a7)	* Cursor ausschalten
	trap	#XBIOS
	addq.l	#6,a7
	pea	MESSAGE(pc)	* Copyright
	bsr	CONOUT	* ausgeben

*********************************************************

	move.w	#G_KBDVB,-(a7)	* Vektoradressen
	trap	#XBIOS	* holen
	addq.l	#2,a7
	move.l	d0,a0
	lea	KBDVBASE(pc),a1
	move.l	a0,(a1)+	* Adresse sichern
	move.l	16(a0),a2	* aktueller Mausvektor
	cmpi.l	#$02101968,-4(a2)	* Magic-Number
	beq	EXIT	* Lupe schon installiert

*********************************************************

	move.l	a2,(a1)+	* Alten Vektor sichern
	move.l	#NEW_MOUSE,16(a0)	* neuen eintragen
	move.w	#G_PHYSB,-(a7)	* phys. Bildschirmadresse
	trap	#XBIOS	* holen
	addq.l	#2,a7
	move.l	d0,PHYSBASE
	move.l	#FLIP_1+255,d0	* Basisadresse von Bild 1/2
	clr.b	d0	* auf Byte-Boundary
	move.l	d0,F_BASE1	* Adr. Bild 1
	add.l	d0,F_BASE2	* Adr. Bild 2
	bsr	APP_INIT	* Application anmelden
	bsr	GRAF_MKSTATE	* Mausposition holen
	bsr	CREATE_TABLE	* Tabellen erstellen
	pea	INSTAL(pc)	* Supervisor
	move.w	#G_SUPER,-(a7)
	trap	#XBIOS
	addq.l	#6,a7
	bsr	PAUSE	* Augenblick warten
	clr.w	-(a7)
	pea	(BSS_END-BSS_START)+(T_END-P_START)+256
	move.w	#K_PROC,-(a7)
	trap	#GEMDOS

*********************************************************

EXIT:
	bsr	PAUSE	* Pause einlegen
	clr.w	-(a7)
	trap	#GEMDOS	* und Ende

*********************************************************
*                                                       *
*             X B I O S - Trap                          *
*                                                       *
*********************************************************

NEW_XBIOS:
	lea	6(a7),a0	* Zeiger auf Super
			* visorparameter
	move.w	(a0),d0	* Funktionsnummer vom
			* SSP holen
	btst	#5,(a7)	* Aufruf vom Supervisor?
	bne.b	SVR_CALL	* Ja...
	move.l	usp,a0	* Nein, Zeiger auf USER
	move.w	(a0),d0	* Fktnr vom USP holen

SVR_CALL:
	cmpi.w	#G_PHYSB,d0	* Funktion GET_PHYSBASE?
	beq.b	F_PHYSBASE	* Ja
	cmpi.w	#S_SCREEN,d0	* SET_SCREEN?
	beq.b	F_SETSCREEN	* Ja

SYS_XBIOS:
	move.l	XBIOS_VEC(pc),-(a7)	* zum SYSTEM-TRAP springen
	rts

F_PHYSBASE:
	move.l	PHYSBASE(pc),d0	* Adresse auf Stack
	rte		* und Ende

F_SETSCREEN:
	move.l	6(a0),d0	* Soll Physbase gesetzt werden?
	bmi.b	SYS_XBIOS	* Nein...

	move.l	d0,PHYSBASE	* Neuen Zeiger sichern
	move.w	#-1,6(a0)	* Physbase Nicht umsetzen
	bra.b	SYS_XBIOS	* und weiter

*********************************************************
*                                                       *
*             V B L - Interrupt                         *
*                                                       *
*********************************************************

XBRA:
	.dc.b	'xbra'
	.dc.l	04031965
XBRA_VBL:
	.dc.l	NEW_VBL	* Adresse des eigenen

NEW_VBL:
	movem.l	d0-d2/a0-a2,-(a7)
	move.l	$45e,d0	* Screenzeiger gesetzt
	beq.b	NO_SCREENPTR	* Nee...

	clr.l	$45e	* Screenzeiger lîschen
	move.l	d0,PHYSBASE	* und neuen Bildvektor 
			* uebernehmen
NO_SCREENPTR:
	tst.w	$43e	* Floppy aktiv?
	bne.b	GO_SYSTEM	* nichts weiter

	bsr	GET_MODE	* Modus holen
	bsr.b	GET_RES	* Auflîsung holen
	lea	COUNTER(pc),a0	* Zaehleradresse
	subq.w	#1,(a0)	* Countdown?
	bpl.b	GO_SYSTEM	* Nein

	move.w	#REPEAT,(a0)	* Zaehler neuladen
	bsr.b	LUPE	* Bild aufbauen

GO_SYSTEM:
	movem.l	(a7)+,d0-d2/a0-a2	* Register laden
	move.l	VBL_VEC(pc),-(a7)	* Weiter mit SYS-VBL
	rts

*********************************************************

GET_RES:
	moveq	#3,d0	* Komplett neu
	and.b	$ffff8260,d0	* Aufloesung in d0
	cmp.w	RESOLUTION(pc),d0
	beq.b	CMP_MOUSE

	move.w	d0,RESOLUTION
	clr.b	MODE

CMP_MOUSE:
	lea	NEW_MOUSE(pc),a1	* Adresse der eigenen
			* Routine

	move.l	KBDVBASE(pc),a0	* Mausvektor gesetzt?
	move.l	16(a0),d0	* Aktuellen Vektor holen

	cmp.l	a1,d0	* Mit eig. Vektor vergl.
	beq.b	NO_CHANGE	* Ist noch der alte

	moveq	#23,d1
	btst	d1,d0
	beq.b	NO_CHANGE

	move.l	d0,KBDVBASE+4	* Vektor sichern
	move.l	a1,16(a0)	* eig. Vektor setzen

NO_CHANGE:
	rts

*********************************************************

LUPE:
	move.l	PHYSBASE(pc),a0	* Hintergrundbild
	move.l	F_BASE1(pc),a1	* Zielbild
	move.b	MODE(pc),d0	* Modus holen
	beq	QUICK	* Keine Vergroesserung

	movem.l	d3-d7/a3-a6,-(a7)	* register retten

	pea	LUPE_END(pc)	* Returnadresse auf Stack

	move.w	RESOLUTION(pc),d1	* Aufloesung holen
	beq	ZOOM_LOW	* Niedere

	subq.w	#1,d1	* Mittlere
	beq	ZOOM_MEDIUM

	subq.b	#1,d0	* Hohe Faktor 8
	beq	ZOOM_8

	subq.b	#1,d0	* Hohe Faktor 4
	beq	ZOOM_4

	bra	ZOOM_2	* High Faktor 2

LUPE_END:
	move.l	F_BASE1(pc),d1	* Bildadresse tauschen
	move.l	F_BASE2(pc),d0

	movem.l	d0-d1,F_BASE1

	movea.w	#$8200,a1	* Adresse setzen
	lsr.l	#8,d1
	movep.w	d1,1(a1)

	movem.l	(a7)+,d3-d7/a3-a6	* Register holen
	rts

*********************************************************

ZOOM_8:
	moveq	#40,d2	* Aus Groesse Fenster
	moveq	#25,d3	* Zeiger berechnen
	move.w	#559,d4
	move.w	#349,d5
	bsr	CALC_SCRPTR
	adda.w	d0,a0	* Offsets bilden
	adda.w	d1,a0	* auf Hintergrund

	lea	BUFFER_8,a2	* Zeiger auf Tabelle
	move.w	#255*8,d5	* Maske fuer Tabindex
	moveq	#49,d7	* 50 Zeilen

ZOOM_81:
	moveq	#4,d6	* 5 Words pro Zeile
ZOOM_82:
	move.l	(a0),d0	* Hole Daten
	addq.l	#2,a0	* Immer 2 Bytes
	rol.l	d2,d0	* auf Wortgrenze
	swap	d0	* Bytes nach unten holen
	move.w	d0,d1	* Ergebnis sichern

	lsr.w	#5,d0	* Byte rshiften
	and.w	d5,d0	* Index maskierem
	move.l	0(a2,d0.w),(a1)+	* Langwort 1 holen
	move.l	4(a2,d0.w),(a1)+	* Langwort 2 holen

	lsl.w	#3,d1	* Byte 2*8 -> Index
	and.w	d5,d1	* Index maskieren
	move.l	0(a2,d1.w),(a1)+	* Langwort 1 holen
	move.l	4(a2,d1.w),(a1)+	* Langwort 2 holen
	dbra	d6,ZOOM_82	* Naechstes Wort

	lea	70(a0),a0	* Zeiger auf nÑchste Zeilen
	lea	7*80(a1),a1
	dbra	d7,ZOOM_81

*********************************************************

	move.l	F_BASE1(pc),a0	* Zieladresse
	moveq	#49,d7	* 100 Abschnitte

FILL_10:
	moveq	#1,d6	* 2*40 Zeilen
FILL_11:
	movem.l	(a0)+,d0-d5/a3-a6	* 40 Bytes kopieren
	movem.l	d0-d5/a3-a6,40(a0)
	movem.l	d0-d5/a3-a6,40+80(a0)
	movem.l	d0-d5/a3-a6,40+160(a0)
	movem.l	d0-d5/a3-a6,40+240(a0)
	movem.l	d0-d5/a3-a6,40+320(a0)
	movem.l	d0-d5/a3-a6,40+400(a0)
	movem.l	d0-d5/a3-a6,40+480(a0)
	dbra	d6,FILL_11

	lea	7*80(a0),a0	* Zeiger auf naechste
			* Zeile
	dbra	d7,FILL_10	* und weiter...

	rts

*********************************************************

ZOOM_4:
	moveq	#80,d2	* Aus Groesse Fenster
	moveq	#50,d3	* Zeiger berechnen
	move.w	#479,d4
	move.w	#299,d5
	bsr	CALC_SCRPTR
	adda.w	d0,a0	* Offsets bilden
	adda.w	d1,a0	* auf Hintergrund
	lea	BUFFER_4,a2	* Zeiger auf Tabelle
	move.w	#255*4,d1	* Maske fuer Tabindex
	moveq	#99,d7	* 50 Zeilen
	moveq	#6,d5

ZOOM_41:
	moveq	#9,d6	* 10 Words pro Zeile
ZOOM_42:
	move.l	(a0),d0	* Hole Daten
	addq.l	#2,a0	* Immer 2 Bytes
	rol.l	d2,d0	* auf Wortgrenze
	swap	d0	* Bytes nach unten holen
	move.w	d0,d3	* Ergebnis sichern

	ror.w	d5,d3	* mal4-> Index
	and.w	d1,d3	* Index maskierem
	move.l	0(a2,d3.w),(a1)+	* Langwort 1 holen

	add.w	d0,d0
	add.w	d0,d0
	and.w	d1,d0
	move.l	0(a2,d0.w),(a1)+	* Langwort 1 holen

	dbra	d6,ZOOM_42	* Naechstes Wort

	lea	60(a0),a0	* Zeiger auf nÑchste Zeilen
	lea	240(a1),a1

	dbra	d7,ZOOM_41
 
*********************************************************

	move.l	F_BASE1(pc),a0	* Zieladresse
	moveq	#99,d7	* 100 Abschnitte

FILL_2:
	movem.l	(a0)+,d0-d5/a3-a6	* 40 Bytes kopieren
	movem.l	d0-d5/a3-a6,40(a0)
	movem.l	d0-d5/a3-a6,40+80(a0)
	movem.l	d0-d5/a3-a6,40+160(a0)

	movem.l	(a0)+,d0-d5/a3-a6
	movem.l	d0-d5/a3-a6,40(a0)
	movem.l	d0-d5/a3-a6,40+80(a0)
	movem.l	d0-d5/a3-a6,40+160(a0)

	lea	3*80(a0),a0	* Zeiger auf naechste
			* Zeile
	dbra	d7,FILL_2	* und weiter...

	rts

*********************************************************

ZOOM_2:
	move.w	#160,d2	* Hohe Aufloesung
	moveq	#100,d3	* Aus Groesse Fenster
	move.w	#319,d4
	move.w	#199,d5
	bsr	CALC_SCRPTR

	adda.w	d0,a0	* Offsets bilden
	adda.w	d1,a0	* auf Hintergrund

	lea	BUFFER_2,a3
	lea	80(a1),a2	* Zeiger auf Tabelle

	move.w	#$1FE,d1	* Maske fuer Tabindex
	move.w	#199,d7
	moveq	#7,d5

ZOOM_21:
	moveq	#19,d6	* 20 Words pro Zeile
	move.w	(a0)+,d0	* erstes Wort holen 
ZOOM_22:
	swap	d0
	move.w	(a0)+,d0	* Hole Daten
	move.l	d0,d4
	lsl.l	d2,d4	* auf Wortgrenze
	swap	d4	* Bytes nach unten holen

	move.w	d4,d3	* Ergebnis sichern
	lsr.w	d5,d3	* mal4-> Index
	and.w	d1,d3	* Index maskierem
	move.w	0(a3,d3.w),d3	* Langwort 1 holen
	move.w	d3,(a1)+
	move.w	d3,(a2)+

	add.w	d4,d4
	and.w	d1,d4
	move.w	0(a3,d4.w),d4	* Langwort 1 holen
	move.w	d4,(a1)+
	move.w	d4,(a2)+

	dbra	d6,ZOOM_22	* Naechstes Wort

	lea	40-2(a0),a0	* Zeiger auf nÑchste Zeilen
	lea	80(a1),a1
	lea	80(a2),a2

	dbra	d7,ZOOM_21

	rts

*********************************************************

ZOOM_MEDIUM:
	move.w	#160,d2	* Hohe Aufloesung
	moveq	#50,d3	* Aus Groesse Fenster
	move.w	#639-2*160,d4
	moveq	#199-2*50,d5
	bsr	CALC_SCRPTR

	add.w	d1,d1
	add.w	d0,d0
	add.w	d0,d1
	adda.w	d1,a0	* Offsets bilden

	lea	BUFFER_2,a3
	lea	160(a1),a2	* Zeiger auf Tabelle

	move.w	#$1FE,d1	* Maske fuer Tabindex
	moveq	#99,d7
	moveq	#7,d5

ME2_10:
	moveq	#19,d6	* 20 Words pro Zeile
ME2_20:
	moveq	#1,d0
ME2_21:
	move.w	(a0)+,d4
	swap	d4
	move.w	2(a0),d4	* Hole Daten

	lsl.l	d2,d4	* auf Wortgrenze
	swap	d4	* Bytes nach unten holen

	move.w	d4,d3	* Ergebnis sichern
	lsr.w	d5,d3	* mal4-> Index
	and.w	d1,d3	* Index maskierem
	move.l	0(a3,d3.w),d3	* Langwort 1 holen
	move.w	d3,(a1)+
	move.w	d3,(a2)+

	add.w	d4,d4
	and.w	d1,d4
	move.l	0(a3,d4.w),d4	* Langwort 1 holen
	move.w	d4,2(a1)
	move.w	d4,2(a2)

	dbra	d0,ME2_21	* Naechstes Wort

	addq.l	#4,a1
	addq.l	#4,a2

	dbra	d6,ME2_20

	lea	80(a0),a0	* Zeiger auf nÑchste Zeilen
	lea	160(a1),a1
	lea	160(a2),a2

	dbra	d7,ME2_10

	rts

*********************************************************

ZOOM_LOW:
	moveq	#80,d2	* Hohe Aufloesung
	moveq	#50,d3	* Aus Groesse Fenster
	move.w	#319-2*80,d4
	moveq	#199-2*50,d5
	bsr	CALC_SCRPTR

	add.w	d1,d1
	lsl.w	#2,d0
	add.w	d0,d1
	adda.w	d1,a0	* Offsets bilden

	lea	BUFFER_2,a3
	lea	160(a1),a2	* Zeiger auf Tabelle

	move.w	#$1FE,d1	* Maske fuer Tabindex
	moveq	#99,d7
	moveq	#7,d5

LO2_10:
	moveq	#9,d6	* 10 Words pro Zeile
LO2_20:
	moveq	#3,d0
LO2_21:
	move.w	(a0)+,d4
	swap	d4
	move.w	6(a0),d4	* Hole Daten

	lsl.l	d2,d4	* auf Wortgrenze
	swap	d4	* Bytes nach unten holen

	move.w	d4,d3	* Ergebnis sichern
	lsr.w	d5,d3	* mal4-> Index
	and.w	d1,d3	* Index maskierem
	move.l	0(a3,d3.w),d3	* Langwort 1 holen
	move.w	d3,(a1)+
	move.w	d3,(a2)+

	add.w	d4,d4
	and.w	d1,d4
	move.l	0(a3,d4.w),d4	* Langwort 1 holen
	move.w	d4,6(a1)
	move.w	d4,6(a2)

	dbra	d0,LO2_21	* Naechstes Wort

	addq.l	#8,a1
	addq.l	#8,a2

	dbra	d6,LO2_20

	lea	80(a0),a0	* Zeiger auf nÑchste Zeilen
	lea	160(a1),a1
	lea	160(a2),a2

	dbra	d7,LO2_10

	rts

*********************************************************

QUICK:
	movea.w	#$8200,a1	* Hardwareadresse
	move.l	a0,d0	* Hintergrundbild
	lsr.l	#8,d0
	movep.w	d0,1(A1)	* Bildadresse setzen

	rts

*********************************************************

CALC_SCRPTR:
	movem.w	MOUSE_POS(pc),d0-d1	* Mausposition holen

	sub.w	d2,d0	* Linke Lupenkante
	bpl.b	CHECK_1	* OK...
	moveq	#0,d0
CHECK_1:
	sub.w	d3,d1	* Obere Lupenkante
	bpl.b	CHECK_2	* OK...
	moveq	#0,d1
CHECK_2:
	cmp.w	d4,d0	* Rechte Lupenkante
	bls.b	CHECK_3	* OK...
	move.w	d4,d0
CHECK_3:
	cmp.w	d5,d1	* Untere Pixelkante
	bls.b	CHECK_4	* OK...
	move.w	d5,d1
CHECK_4:
	moveq	#15,d2	* Offset in Punkten
	and.w	d0,d2	* auf naechste Wortgrenze
	lsr.w	#4,d0	* Offset in Bytes
	add.w	d0,d0
	mulu	#80,d1	* Bytes pro Zeile
	rts

*********************************************************
*                                                       *
*             T A S T E N A B F R A G E                 *
*                                                       *
*********************************************************

GET_MODE:
	move.l	SHIFT_ADDR(pc),a0	* Shiftstatus
	moveq	#%01101011,d0	* Maske
	and.b	(a0),d0

	cmpi.b	#%1011,d0	* SHFT SHFT ALT?
	bne.b	MODE_END	* No...

	tas.b	KEY_FLAG	* War gedrueckt?
	bne.b	MODE_RTS	* Ja...

	move.b	MODE(pc),d0	* Modus wechseln
	subq.b	#1,d0
	bpl.b	SET_MODE

	move.w	RESOLUTION(pc),d1	* Aufloesung
	move.b	MAXMODE(pc,d1.w),d0	* Maxwert

SET_MODE:
	move.b	d0,MODE	* Neuen Modus setzen
	rts

MODE_END:
	clr.b	KEY_FLAG	* Flag loeschen
MODE_RTS:
	rts
MAXMODE:
	.dc.b	1	* Niedrige Aufloesung
	.dc.b	1	* Mittlere Aufloesung
	.dc.b	3	* Hohe Aufloesung
	.dc.b	0	* -

*********************************************************

CONOUT:
	movem.l	a0-a2/d0-d2,-(a7)	* Register retten
	move.l	28(a7),-(a7)	* Textadresse
	move.w	#P_LINE,-(a7)
	trap	#GEMDOS
	addq.l	#6,a7
	movem.l	(a7)+,a0-a2/d0-d2
	move.l	(a7)+,(a7)	* Returnadresse setzen
	rts

*********************************************************

	.dc.l	$02101968	* Magic Number
NEW_MOUSE:
	movem.l	d0-d3/a0-a1,-(a7)	* Register retten
	move.b	(a0)+,d0	* Mauspaket?
	cmpi.b	#$f8,d0
	bcs.b	END_MOUSE	* Nein...
	cmpi.b	#$fc,d0
	bcc.b	END_MOUSE

	move.w	#319,d2	* Mausgrenzen je Auflîsung
	move.w	#199,d3
	move.w	RESOLUTION(pc),d0	* Aufloesung
	beq.b	CHK_MOUSE	* War niedere

	move.w	#639,d2
	subq.w	#1,d0

	beq.b	CHK_MOUSE	* War mittlere
	move.w	#399,d3	* War hohe

CHK_MOUSE:
	move.b	(a0)+,d0	* Hole relative Bewegung
	move.b	(a0)+,d1

	lea	MOUSE_POS(pc),a1	* Addiere Mausbewegung
	ext.w	d0	* prÅfe auf Bildschirmgrenzen
	ext.w	d1

	add.w	(a1),d0	* xpos+=rx
	bpl.b	MS_1
	moveq	#0,d0	* xpos nie <0

MS_1:
	cmp.w	d2,d0	* Abfrage anders
	bls.b	MS_2
	move.w	d2,d0	* xpos nie > xmax
MS_2:
	add.w	2(a1),d1	* ypos+=ry
	bpl.b	MS_3
	moveq	#0,d1	* ypos nie <0
MS_3:
	cmp.w	d3,d1	* Abfrage anders
	bls.b	MS_4
	move.w	d3,d1	* ypos nie > ymax
MS_4:
	move.w	d0,(a1)+	* Neue Pos sichern
	move.w	d1,(a1)+
END_MOUSE:
	movem.l	(a7)+,d0-d3/a0-a1	* Register laden
	move.l	KBDVBASE+4(pc),-(a7)
	rts

*********************************************************

CREATE_TABLE:
	lea	BUFFER_2,a0	* Tabelle fuer Faktor 2
	moveq	#0,d0
MAKE_20:
	move.b	d0,d1
	moveq	#7,d7	* 8 Bits pro Byte
	clr.w	d2
MAKE_21:
	move.b	d1,d3	* Aus Byte Word machen
	add.b	d1,d1
	addx.w	d2,d2
	add.b	d3,d3
	addx.w	d2,d2
	dbra	d7,MAKE_21

	move.w	d2,(a0)+
	addq.b	#1,d0
	bne.b	MAKE_20

*********************************************************

	lea	BUFFER_4,a0	* Tabelle Faktor 4

	moveq	#-16,d4	* Maske Nibble links
	moveq	#15,d5	* Nibble rechts
	moveq	#0,d0	* Startbyte
MAKE_40:
	move.b	d0,d1	* Aktuelles Byte in d1
	moveq	#3,d7	* 4 mal 2 Bytes
MAKE_41:
	add.b	d1,d1	* Mache aus 2 Bits ein Byte
	scs	d2
	and.b	d4,d2
	add.b	d1,d1
	scs	d3
	and.b	d5,d3
	or.b	d2,d3
	move.b	d3,(a0)+
	dbra	d7,MAKE_41

	addq.b	#1,d0
	bne.b	MAKE_40

*********************************************************

	lea	BUFFER_8,a0	* Tabelle Faktor 8
	moveq	#0,d0	* Startbyte

MAKE_80:
	move.b	d0,d1	* Akt Byte in d1
	moveq	#7,d2	* 8 Bits pro Byte
MAKE_81:
	add.b	d1,d1	* aus Bit Byte machen
	scs	(a0)+
	dbra	d2,MAKE_81

	addq.b	#1,d0	* fuer alle 256 Bytes
	bne.b	MAKE_80

	rts

*********************************************************

INSTAL:
	moveq	#3,d0	* Aufloesung sichern
	and.b	$FFFF8260,d0
	move.w	d0,RESOLUTION

	move.l	$70,VBL_VEC	* Neuer VBL
	move.l	#NEW_VBL,$70

	move.l	$B8,XBIOS_VEC	* Neues XBIOS
	move.l	#NEW_XBIOS,$B8

	move.l	$4F2,d0	* Pointer auf SysBase

	beq.b	UNDEF	* Einsetzen

	move.l	d0,a0
	move.l	36(a0),a1	* Adresse Kbdshft

	cmpi.w	#$0102,2(a0)	* TOS aelter 1.2?
	bcc.b	TOS_12

UNDEF:
	move.w	#$E1B,a1	* RAM Adresse setzen

TOS_12:
	move.l	a1,SHIFT_ADDR	* Adresse sichern

	rts

*********************************************************

GRAF_MKSTATE:
	lea	CTRL_ARRAY,a0

	move.w	#79,(a0)+
	clr.w	(a0)+
	move.w	#5,(a0)+
	clr.l	(a0)

	subq.l	#6,a0

	move.l	#AES_DATA,d1
	move.w	#$C8,d0	* graf_mkstate
	trap	#2

	move.l	AES_DATA+12(pc),a0	* int_out
	move.l	2(a0),MOUSE_POS	* MAUS X,Y

	rts

*********************************************************

APP_INIT:
	moveq	#10,d0
	bsr	AES_CALL
	rts

*********************************************************

APP_EXIT:
	moveq	#19,d0
	bsr	AES_CALL
	rts

*********************************************************

AES_CALL:
	lea	CTRL_ARRAY,a0
	move.w	d0,(a0)+
	clr.w	(a0)+
	move.w	#1,(a0)+
	clr.l	(a0)

	subq.l	#6,a0
	move.l	#AES_DATA,d1
	move.w	#$C8,d0
	trap	#2
	rts

*********************************************************

PAUSE:
	moveq	#30,d0	* Warteschleife
WAITLOOP:
	dbra	d1,WAITLOOP
	dbra	d0,WAITLOOP

	rts

************************************
*                                  *
*             D A T A              *
*                                  *
************************************

KBDVBASE:	.dc.l	-1	* Vektortabelle
	.dc.l	-1	* Alter Vektor

MOUSE_POS:	.dc.w	639	* Initialdaten
	.dc.w	399	* Mausposition

F_BASE1:	.dc.l	-1	* Basisadresse
F_BASE2:	.dc.l	32000	* Bild 1 u. 2
PHYSBASE:	.dc.l	-1	* Phys. Bild

XBIOS_VEC:	.dc.l	-1	* XBIOS-Adresse
VBL_VEC:	.dc.l	-1	* VBL_Adresse
SHIFT_ADR:	.dc.l	-1	* Tastaturstatus

RESOLUTION:	.dc.w	-1	* Auflîsung
COUNTER:	.dc.w	REPEAT	* Countdown

AES_DATA:	.dc.l	CTRL_ARR
	.dc.l	AES_GLOBAL
	.dc.l	INT_IN
	.dc.l	INT_OUT
	.dc.l	ADDR_IN
	.dc.l	ADDR_OUT

AES_GLOBAL:	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.l	$02101968
	.ds.l	5

MODE:	.dc.b	0	* Flag
KEY_FLAG:	.dc.b	0	* Tastendruck

MESSAGE:	.dc.b	$1b,'E',10
	.dc.b	' R E A L T I M E   M A G N I F I E R',10,10,10,13
	.dc.b	' (C) Imagic Graphic ',0
	.ds.w	0
T_END:

*********************************************************
*                                                       *
*             bss                                       *
*                                                       *
*********************************************************

	.bss

BSS_START:

BUFFER_2:	.ds.b	256*2
BUFFER_4:	.ds.b	256*4	* Tabellen
BUFFER_8:	.ds.b	256*8

CTRL_ARR:	.ds.w	10
INT_IN:	.ds.w	128
INT_OUT:	.ds.w	128
ADDR_IN:	.ds.w	128
ADDR_OUT:	.ds.w	128

FLIP_1:	.ds.b	32256	* Bildspeicher 1
FLIP_2:	.ds.b	32000	* Bildspeicher 2

BSS_END:	.ds.b	0	* Ende residenter Teil

	.ds.b	2048	* Programm-Stack
U_STACK:	.ds.b	0

*********************************************************

	.end
