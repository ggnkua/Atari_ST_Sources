* -------------------------------------------------- *
*
*		XFORMDO.LIB Version 1.2
*
*	   geschrieben von Michael Maier 1991
*
* -------------------------------------------------- *

* -------------------------------------------------- *
* Modul: RESC.Q
* Version: 1.0
* Datum: 14.9.1991
* -------------------------------------------------- *

	PATH	include 	kann geÑndert werden!

**************************************************************************
*
* Include-Anweisungen
*
**************************************************************************
	include types.i 	Global Typen
	include gem.i		GEM-Strukturen und Konstanten
	include xobjects.i	neue Objekttypen
	include rscobj.i	Objektnummer der Resource-Datei
	include xform.i 	Offsets fÅr relative Adressierung

**************************************************************************
*
* Schalter setzen:
*
**************************************************************************
	SECTION TEXT

**************************************************************************
*
* Resourcen îffnen und Konstanten berechnen
* -----------------------------------------
*
* BOOLEAN open_res(BYTE *rscname)
* rscname:	Zeiger auf Resource-Datei	A0.l
* ret	 :	TRUE	alles ok		D0.w
*		FALSE	Fehler
*
**************************************************************************
	LOCAL
	GLOBL	open_res
open_res:
	movem.l #CREGS,-(SP)		Register rettem
	IFD	DR
	move.l	60(SP),A0		 Adresse Åber Stack!
	ENDIF
	
	lea	basis,A6		Basisregister

	move.l	#rsrc_load,D0		Resource-Datei laden
	move.l	A0,gl_addrin(A6)	Adresse des Dateinamens
	bsr	aes			rsrc_load
	beq	.error			Fehler -> Abbruch

	clr.w	gl_intin(A6)		R_TREE
	move.w	#USERIMG,gl_intin+2(A6) USERIMG
	move.w	#1,gl_contrl+8(A6)
	move.l	#rsrc_gaddr,D0		AES-Funktion
	bsr	aes			GEM aufrufen
	move.l	gl_addrout(A6),A4	Adresse

	move.l	#graf_handle,D0 	phys. Handle besorgen
	bsr	aes
	move.w	D0,D2			Handle merken

	clr.w	gl_gr_res(A6)			 Flag lîschen

	move.l	A4,D0			Zeiger auf Grafikobjekte
	add.l	#RBLOFF*ob_size,D0	berechnen
	move.l	D0,gl_bitoff(A6)	runder Schalter aus
	move.l	A4,D0
	add.l	#RBLON*ob_size,D0
	move.l	D0,gl_biton(A6) 	runder Schalter ein

	lea	gl_intout(A6),A5	Werte holen
	move.l	2(A5),gl_gr_cw(A6)	Hîhe und Breite merken
	move.l	6(A5),gl_gr_bw(A6)	Boxwerte merken

	move.w	2(A5),D0		Breite mal 2
	add.w	D0,D0
	cmp.w	4(A5),D0		 = Hîhe?
	bne.s	.nogr_res		 nein -> nicht hochauflîsend
	move.w	#TRUE,gl_gr_res(A6)	 ja -> FLAG setzen

	move.l	A4,D0			Zeiger auf Grafikobjekte
	add.l	#RBHOFF*ob_size,D0	berechnen
	move.l	D0,gl_bitoff(A6)	runder Schalter aus
	move.l	A4,D0
	add.l	#RBHON*ob_size,D0
	move.l	D0,gl_biton(A6) 	runder Schalter ein

.nogr_res:

	move.l	gl_bitoff(A6),A0	Zeiger auf BITBLKs ermitteln
	move.l	ob_spec(A0),gl_bitoff(A6)
	move.l	gl_biton(A6),A0
	move.l	ob_spec(A0),gl_biton(A6)

	moveq.l #9,D0			work_in vorbereiten...
	lea	gl_intin(A6),A0
.loop:
	move.w	#$0001,(A0)+		Wert eintragen
	dbra	D0,.loop		10 an der Zahl
	move.w	#$0002,(A0)		letzter ist 2

	move.l	#$00640000,gl_contrl(A6)	virt. Workstation îffnen
	move.l	#$0006000B,gl_contrl+4(A6)	Contrl-Werte...
	move.w	#$002D,gl_contrl+8(A6) 
	move.w	D2,gl_contrl+12(A6)		phys. Handle
	bsr	vdi				V_OPNVWK

	moveq.l #FALSE,D0			Annahme: ging schief!
	move.w	gl_contrl+12(A6),gl_vhandle(A6) Handler merken
	beq.s	.error				=0? ja -> Fehler

.noerror:

	move.l	gl_intout(A6),gl_max_w(A6)	Rasterbreite und -hîhe
	move.l	#$00660000,gl_contrl(A6)	Contrl-Werte...
	move.l	#$00060001,gl_contrl+4(A6)	Anzahl der
	move.w	#$002D,gl_contrl+8(A6)		Farbebenen
	move.w	#$0001,gl_intin(A6)		ermitteln
	bsr	vdi
	move.w	gl_intout+8(A6),gl_planes(A6)	Anzahl der Ebenen merken

	move.l	gl_biton(A6),A0 	Grafikblock transformieren
	move.w	bi_wb(A0),D0		runder Schalter ein
	move.w	bi_hl(A0),D1
	move.l	bi_pdata(A0),A1
	bsr	vdi_trans
	move.l	gl_bitoff(A6),A0	Grafikblock transformieren
	move.w	bi_wb(A0),D0		runder Schalter aus
	move.w	bi_hl(A0),D1
	move.l	bi_pdata(A0),A1
	bsr	vdi_trans

	pea	-1			Tastenumwandlungs-
	pea	-1			tabelle
	pea	-1			ermitteln
	move.w	#$10,-(SP)		Keytbl
	trap	#XBIOS
	move.l	D0,gl_keytab(A6)	Tabelle merken
	lea	$E(SP),SP		Stack restaurieren

	moveq.l #TRUE,D0		alles ok!

.error:

	movem.l (SP)+,#CREGS		Register holen
	rts

**************************************************************************
*
* Resourcen schlieûen
* -------------------
*
* VOID clse_res(VOID)
*
**************************************************************************
	LOCAL
	GLOBL	clse_res
clse_res:
	movem.l #CREGS,-(SP)		Register retten

	lea	contrl,A0		Contrl-Werte...
	move.l	#$00650000,(A0)+
	clr.l	(A0)+
	clr.w	(A0)+
	move.w	vhandle,2(A0)		GerÑtenummer
	bsr	vdi			V_CLSVWK

	move.l	#rsrc_free,D0		Resourcen freigen
	bsr	aes

	movem.l (SP)+,#CREGS		Register vom Stack
	rts

**************************************************************************
*
* IMAGE bzw. ICONS um die HÑlfte verkleinern
* ------------------------------------------
* (Anmerkung: letzte Zeile der Grafik wird immer Åbernommen!)
*
* IN	A1.l	Zeiger auf ICON bzw. IMAGE
*	D0.w	Typ: G_ICON oder G_IMAGE
*
**************************************************************************
	LOCAL
halfsize:
	movem.l D0-D4/A2-A5,-(SP)	Register retten
	moveq	#0,D3			Offsetregister auf 0!

	cmpi.w	#G_ICON,D0		ICON?
	bne	.g_image		nein -> Image

	move.w	ib_hicon(A1),D1 	Anzahl der Pixelzeilen
	cmp.w	#4,D1			mindestens 4 Zeilen!
	blt	.ende			nein -> Abbruch

	moveq.l #0,D4			D4 lîschen

	btst	#0,D1			Ungerade Zahl?
	bne.s	.jaweiter		ja -> weiter
	moveq	#1,D4			nein -> merken

.jaweiter:
	move.l	ib_pmask(A1),A2 	Ziel 1
	move.l	ib_pdata(A1),A4 	Ziel 2
	move.w	ib_wicon(A1),D0 	Breite
	lsr.w	#4,D0			Breite / 16 = Worte/Zeile
	move.w	D0,D3			Wert kopieren
	add.l	D3,D3			Wert * 2 = BytelÑnge
	btst	#0,D0			1. Bit gesetzt?
	beq.s	.cplong 		nein -> Kopieren mit LONG

	add.l	D3,A2			nÑchste Zeile = Ziel
	move.l	A2,A3			Quellzeile berechnen
	add.l	D3,A3

	add.l	D3,A4			Daten nicht vergessen
	move.l	A4,A5
	add.l	D3,A5

	subq.w	#3,D1
	lsr.w	#1,D1			Hîhe durch 2
	subq.w	#1,D0
.loop1:
	move.w	D0,D2			Anzahl Worte/Zeilen
.loop2:
	move.w	(A3)+,(A2)+		WORD kopieren
	move.w	(A5)+,(A4)+
	dbra	D2,.loop2
	add.l	D3,A3			nur jede zweite Zeile
	add.l	D3,A5
	dbra	D1,.loop1

	btst	#0,D4			Muû um die l. Zeile erweitert
	beq	.endeicon		werden?

	sub.l	D3,A3			Grafik wird um die
	sub.l	D3,A5			letzte Zeile erweitert
.loopx1:
	move.w	(A3)+,(A2)+		Daten und Maske
	move.w	(A5)+,(A4)+		kopieren
	dbra	D0,.loopx1

	bra	.endeicon

.cplong:
	lsr.w	#1,D0			Anzahl der Langworte/Zeile

	add.l	D3,A2			nÑchste Zeile = Ziel
	move.l	A2,A3			Quellzeile berechnen
	add.l	D3,A3
	add.l	D3,A4			Daten nicht vergessen
	move.l	A4,A5
	add.l	D3,A5

	subq.w	#3,D1
	lsr.w	#1,D1			Hîhe durch 2
	subq.w	#1,D0
.loop3:
	move.w	D0,D2			Anzahl
.loop4:
	move.l	(A3)+,(A2)+		LONGWORD kopieren
	move.l	(A5)+,(A4)+
	dbra	D2,.loop4
	add.l	D3,A3			nur jede zweite Zeile
	add.l	D3,A5
	dbra	D1,.loop3

	btst	#0,D4			Muû um die l. Zeile erweitert
	beq	.endeicon		werden?

	sub.l	D3,A3			Grafik wird um die
	sub.l	D3,A5			letzte Zeile erweitert

.loopx2:

	move.l	(A3)+,(A2)+		Daten und Maske
	move.l	(A5)+,(A4)+		kopieren
	dbra	D0,.loopx2

.endeicon:
	move.w	ib_hicon(A1),D0 	Hîhenangaben um die HÑlfte
	lsr.w	#1,D0			verringern
	add.w	D4,D0
	move.w	D0,ib_hicon(A1)
	move.w	ib_ytext(A1),D0
	lsr.w	#1,D0
	add.w	D4,D0
	move.w	D0,ib_ytext(A1)
	bra	.ende

.g_image:
	move.w	bi_hl(A1),D1		Anzahl der Pixelzeilen
	cmp.w	#4,D1			mindestens 4 Zeilen!
	blt.s	.ende			nein -> Abbruch

	move.l	bi_pdata(A1),A2 	Ziel 1
	move.w	bi_wb(A1),D0		Breite
	move.w	D0,D3			Wert kopieren
	lsr.w	#1,D0			Wert / 2 = Worte/Zeile
	btst	#0,D0			1. Bit gesetzt?
	beq.s	.cplong1		nein -> Kopieren mit LONG

	add.l	D3,A2			nÑchste Zeile = Ziel
	move.l	A2,A3			Quellzeile berechnen
	add.l	D3,A3

	lsr.w	#1,D1			Hîhe durch 2
	subq.w	#1,D1			Hîhe - 1
	subq.w	#1,D0
.loop5:
	move.w	D0,D2			Anzahl Worte/Zeilen
.loop6:
	move.w	(A3)+,(A2)+		WORD kopieren
	dbra	D2,.loop6
	add.l	D3,A3			nur jede zweite Zeile
	dbra	D1,.loop5

	bra	.endeimage

.cplong1:
	lsr.w	#1,D0			Anzahl der Langworte/Zeile

	add.l	D3,A2			nÑchste Zeile = Ziel
	move.l	A2,A3			Quellzeile berechnen
	add.l	D3,A3

	lsr.w	#1,D1			Hîhe durch 2
	subq.w	#1,D1			Hîhe - 1
	subq.w	#1,D0
.loop7:
	move.w	D0,D2			Anzahl
.loop8:
	move.l	(A3)+,(A2)+		LONGWORD kopieren
	dbra	D2,.loop8
	add.l	D3,A3			nur jede zweite Zeile
	dbra	D1,.loop7

.endeimage:
	move.w	bi_hl(A1),D0		Hîhenangaben um die HÑlfte
	lsr.w	#1,D0			verringern
	move.w	D0,bi_hl(A1)

.ende:
	movem.l (SP)+,D0-D4/A2-A5	Register vom Stack
	rts

**************************************************************************
*
* Grafikblock transformieren
* --------------------------
* IN	A1.l	Zeiger auf Grafikblock
*	D0.w	Breite in Bytes
*	D1.w	Hîhe in Pixel
*
**************************************************************************
	LOCAL
vdi_trans:
	movem.l D0/D1/A4-A6,-(SP)	Register rettem

	link	A6,#-2*fd_size		lokale Varaibeln

	lea	fd_size(SP),A5		Ziel-MFDB
	move.l	SP,A4			Quell-MFDB

	move.l	A1,fd_addr(A5)		Adresse
	move.l	A1,fd_addr(A4)
	move.w	D0,D2			Breite
	lsl.w	#3,D2			Breite * 8
	move.w	D2,fd_w(A5)
	move.w	D2,fd_w(A4)		merken
	move.w	D1,fd_h(A5)		Hîhe
	move.w	D1,fd_h(A4)
	lsr.w	#1,D0			Breite in WORD
	move.w	D0,fd_wdwidth(A5)
	move.w	D0,fd_wdwidth(A4)	auch speichern
	move.w	#1,fd_stand(A4) 	Standard
	move.w	#0,fd_stand(A5) 	Ziel: GerÑteabhÑngig
	move.w	#1,fd_nplanes(A5)
	move.w	#1,fd_nplanes(A4)

	lea	contrl,A1		Contrl-Werte...
	move.l	#$006E0000,(A1)
	clr.l	4(A1)
	clr.w	8(A1)
	move.l	A4,14(A1)		Quelle
	move.l	A5,18(A1)		Ziel
	bsr	vdi			vr_trnfm

	unlk	A6			lokaler Bereich freigeben
	movem.l (SP)+,D0/D1/A4-A6	Register laden
	rts

**************************************************************************
*
* IMAGE bzw. ICONS transformieren
* -------------------------------
* IN	A0.l	Zeiger auf Objekt
*
**************************************************************************
	LOCAL
trans_gimage:
	movem.l D0/D1/A0/A1,-(SP)	Register retten

	move.w	ob_type(A0),D0		Welcher Typ?
	cmp.b	#31,D0			Typ = G_ICON
	bne.s	.image			nein -> G_IMAGE

	move.l	ob_spec(A0),A2		Zeiger auf ICONBLK
	move.l	ib_pmask(A2),A1 	Adresse
	move.w	ib_wicon(A2),D0 	Breite
	lsr.w	#3,D0			nach BYTE
	move.w	ib_hicon(A2),D1 	Hîhe
	bsr	vdi_trans
	move.l	ib_pdata(A2),A1
	bra	.maske

.image:
	move.l	ob_spec(A0),A2		Zeiger auf BITBLK
	move.l	bi_pdata(A2),A1 	Adresse
	move.w	bi_wb(A2),D0		Breite
	move.w	bi_hl(A2),D1		Hîhe
.maske:
	bsr	vdi_trans

	movem.l (SP)+,D0/D1/A1/A2	Register vom Stack
	rts

**************************************************************************
*
* Objekte fixieren
* ----------------
* VOID fix_objs(OBJECT *tree)
*
* IN	A0.l	Zeiger auf Baum
*
**************************************************************************
	LOCAL
	GLOBL	fix_objs
fix_objs:
	movem.l #CREGS,-(SP)		Register retten

	IFD	DR
	move.l	60(SP),A0		Parameter
	ENDIF

	lea	basis,A6		Basis
	move.l	A0,A5

.loop:
	lea	ob_size(A0),A0		nÑchstes Objekt
	move.w	ob_type(A0),D0		Typ untersuchen

	cmpi.w	#G_ICON,D0
	bne.s	.next1

	move.l	ob_spec(A0),A1		ICON
	tst.w	onoff			hochauflîsend?
	bne.s	.ja
	bsr	halfsize		nein -> Grîûe verkleinern

.ja:
	move.w	ib_ytext(A1),D0
	add.w	ib_htext(A1),D0
	move.w	D0,ob_height(A0)	neue Hîhe
	bsr	trans_gimage		an Bildschirm anpassen
	bra	.weiter
.next1:
	cmpi.w	#G_IMAGE,D0		Vielleicht ein IMAGE?
	bne.s	.next2			nein

	move.l	ob_spec(A0),A1
	tst.w	onoff			hochauflîsend?
	bne.s	.ja2			ja -> weiter
	bsr	halfsize
.ja2:
	move.w	bi_hl(A1),ob_height(A0) neue Hîhe
	bsr	trans_gimage		an Bildschirm anpassen
	bra	.weiter

.next2:
	lsr.w	#8,D0			Erweiterung?
	cmpi.w	#HEADER,D0		Header?
	bne.s	.nextx1
	move.w	gl_gr_ch(A6),D0 	Hîhe
	lsr.w	#1,D0			durch 2
	sub.w	D0,ob_y(A0)		y-Position
	bra	.weiter

.nextx1:
	cmpi.w	#CHECKBOX,D0		ankreuzbare KÑstchen
	beq.s	.get_box		ja -> eintragen
	cmpi.w	#CHKHOTKEY,D0		
	bne	.nextx2 		nein -> weiter

.get_box:
	lea	checkblk,A1
	move.l	ob_spec(A0),ub_parm(A1) Wert kopieren
	move.w	#G_USERDEF,ob_type(A0)
	cmpi.w	#CHKHOTKEY,D0
	bne.s	.normal
	move.w	#G_CHK,ob_type(A0)
.normal:
	move.l	A1,ob_spec(A0)

	add.w	#1,ob_x(A0)
	add.w	#1,ob_y(A0)
	sub.w	#2,ob_width(A0)
	sub.w	#2,ob_height(A0)

	bra	.weiter

.nextx2:
	cmpi.w	#UNDERLINE,D0		Unterstreichen?
	bne.s	.nextx3

	lea	unlnblk,A1
	move.l	ob_spec(A0),D1		Attribute
	lsr.w	#6,D1
	lsr.w	#6,D1
	and.w	#$000F,D1		Farben
	move.l	ob_spec(A0),D0		Rahmendicke
	swap	D0			nach vorne
	lsl.w	#8,D0			in Byte zurÅck
	or.w	D0,D1			verschmelzen
	move.w	D1,ob_height(A0)	in Hîhe speichern
	move.w	#G_USERDEF,ob_type(A0)
	move.l	A1,ob_spec(A0)
	bra	.weiter

.nextx3:
	cmpi.w	#RADIO,D0		Runder Button?
	beq	.get_rb
	cmpi.w	#RBHOTKEY,D0
	bne	.nextx4
.get_rb:
	lea	rbuttblk,A1
	move.w	#G_USERDEF,ob_type(A0)	Normaler RB
	move.l	A1,ob_spec(A0)
	move.w	ob_y(A0),D1		Hîhe
	tst.w	gl_gr_res(A6)		Welche Auflîsung?
	beq	.dummy			kleinere -> nur um 1 Zeile
	addq.w	#1,D1			sonst -> um 2 Zeilen
.dummy:
	addq.w	#1,D1			In jedem Fall + 1
	move.w	D1,ob_y(A0)		neue Hîhe speichern
	cmp.w	#RBHOTKEY,D0
	bne	.weiter
	move.w	#G_RB,ob_type(A0)	Mit Tastatur
	bra	.weiter

.nextx4:
	cmpi.w	#HOTKEY,D0		HOTKEY?
	beq.s	.fixhotkey
	cmpi.w	#INDHOTKEY,D0
	bne	.nextx5

.fixhotkey:
	move.w	ob_next(A0),D1		Vaterobjekt untersuchen
	mulu	#ob_size,D1		Offset berechnen
	move.l	A5,A1			Zeiger auf Baum + Offset =
	add.l	D1,A1			Zeiger auf Objekt
	move.w	ob_type(A1),D1		Type untersuchen
	cmp.w	#G_BOXTEXT,D1		G_BOXTEXT?
	beq	.gety			Hîhe fÅr HOTKEY berechnen
	cmp.w	#G_FBOXTEXT,D1		G_FBOXTEXT?
	beq	.gety			ja -> neue y-Postion
	cmp.w	#G_BUTTON,D1		G_BUTTON?
	beq	.gety			ja -> neue y-Position
	cmp.w	#G_BOXCHAR,D1		G_BOXCHAR?
	bne	.nobox			nein -> kein Boxobjekt

.gety:

	move.w	ob_height(A1),D1	Hîhe der Box
	sub.w	gl_gr_ch(A6),D1 	Box - Hîhe eines Zeichens
	lsr.w	#1,D1			(Box - Hîhe)/2 = neuer Offset!
	move.w	D1,ob_y(A0)		rel. Offset speichern

.nobox:

	lea	hotkeyblk,A1 
	move.w	ob_spec(A0),D1
	lsr.w	#8,D1
	move.w	#G_HOTKEY,ob_type(A0)	neuer Typ
	cmp.w	#INDHOTKEY,D0
	bne	.fix2
	move.w	#G_IND,ob_type(A0)
.fix2:
	move.l	ob_spec(A0),ub_parm(A1) 
	move.l	A1,ob_spec(A0)
	move.w	ob_y(A0),D0		Y-Wert korrigieren
	add.w	ob_height(A0),D0
	subq.w	#1,D0
	move.w	D0,ob_y(A0)

	cmp.w	#'a',D1 		; Zeichen
	blt	.noshift		;
	cmp.w	#'z',D1 		;
	ble	.sub			; "a-z"

	lea	.umliste(PC),A1 	; Test auf ÑîÅ
	moveq	#2,D0			; 3 Zeichen
.loopsh:
	cmp.b	(A1),D1 		; gefunden?
	beq	.shift			; ja -> Zeichen holen
	addq	#2,A1			; nein -> nÑchstes Paar
	dbra	D0,.loopsh		; nur 3 mal
	bra	.noshift		;
.shift:
	move.b	1(A1),D1		; Letter
	bra	.noshift		; und zurÅck

.umliste:	dc.b	"ÑéîôÅö"	; Tabelle

.sub:	sub.b	#32,D1			; "a-z"

.noshift:

	move.w	D1,ob_height(A0)	Buchstabe in ob_height

	bra	.weiter

.nextx5:
	cmp.w	#FLYDIAL,D0		Fly-Objekt?
	bne	.weiter

	lea	flyblk,A1		USERBLK
	move.l	ob_spec(A0),ub_parm(A1) eintragen
	move.l	A1,ob_spec(A0)
	move.w	#G_FLY,ob_type(A0)	neuer Typ
	move.w	 ob_width(A5),D0
	sub.w	gl_gr_bw(A6),D0
	add.w	#2,D0			 + 2
	move.w	D0,ob_x(A0)		X - Koordinate berechnen
	move.w	gl_gr_bw(A6),ob_width(A0)	Breite
	move.w	gl_gr_bh(A6),ob_height(A0)	Hîhe
	move.w	#-3,ob_y(A0)		y - Koordinate

.weiter:
	cmp.w	#TXTDEFAULT,D0		AbhÑngiges Objekt?
	bne	.last			nein -> Letztes Objekt?
	move.w	ob_flags(A0),D0 	INDDEFAULT setzen
	or.w	#INDDEFAULT,D0
	move.w	D0,ob_flags(A0) 	Status speichern

.last:

	move.w	ob_flags(A0),D0 	Letztes Objekt?
	and.w	#LASTOB,D0
	bne.s	.ende			ja -> ende
	bra	.loop			nein -> weiter untersuchen
.ende:
	movem.l (SP)+,#CREGS
	rts

**************************************************************************
*
* Grafikverkleinerung einschalten
* -------------------------------
* VOID half_on(VOID)
*
**************************************************************************
	LOCAL
	GLOBL	half_on
half_on:
	move.w	gr_res,D0		 Åberhaupt nîtig?
	move.w	D0,onoff
	rts

**************************************************************************
*
* Grafikverkleinerung ausschalten
* -------------------------------
* VOID half_off(VOID)
*
**************************************************************************
	LOCAL
	GLOBL	half_off
half_off:
	move.w	#$0001,onoff		ausschalten
	rts

**************************************************************************
*
* eigene AES-Schnittstelle
*
**************************************************************************
	LOCAL
	GLOBL	aes
aes:   
	movem.l D1-D7/A0-A6,-(SP)	; Register retten
	lea	contrl,A0		; Contrl-Array lîschen
	clr.l	(A0)			;
	clr.l	4(A0)			;
	movep.l D0,1(A0)		; Contrl-Werte
	lea	aes_pb,A0		;
	move.l	A0,D1			; PB
	move.w	#$C8,D0 		; AES
	trap	#2			; GEM
	move.w	intout,D0		;
	movem.l (SP)+,D1-D7/A0-A6	; Register wieder laden
	rts				; und zurÅck

**************************************************************************
*
* eigene VDI-Schnittstelle
*
**************************************************************************
	LOCAL
	GLOBL	vdi
vdi:	
	movem.l D0-D7/A0-A6,-(SP)	; Register retten
	lea	vdi_pb,A0		; Parameter-Block
	move.l	A0,D1			;
	move.w	#$0073,D0		;
	trap	#2			;
	movem.l (SP)+,D0-D7/A0-A6	; Register vom Stack
	rts				;

**************************************************************************
*
* AES-Parameterblock
*
**************************************************************************

	IFD	ASS
	GLOBL	BASE6
BASE6:
	ENDIF

	  DATA
	  IFD	TCDR1
	  GLOBL     aes_pb
	  ENDIF
	 
aes_pb:   dc.l	    control

	  IFD	TCDR1

	  dc.l	    0		wird im Hauptprogramm eingetragen

	  ELSE

	  dc.l	    global

	  ENDIF

	  dc.l	    intin
	  dc.l	    intout
	  dc.l	    addrin
	  dc.l	    addrout

**************************************************************************
*
* VDI-Parameterblock
*
**************************************************************************
	LOCAL
vdi_pb:   dc.l	    contrl
	  dc.l	    intin
	  dc.l	    ptsin
	  dc.l	    intout
	  dc.l	    ptsout

**************************************************************************
*
* USERBLK-Strukturen
*
**************************************************************************
	GLOBL	checkblk,hotkeyblk
checkblk:	dc.l	draw_box,0
unlnblk:	dc.l	draw_unln,0
hotkeyblk:	dc.l	draw_unln,0
rbuttblk:	dc.l	draw_rbut,0
flyblk: 	dc.l	draw_fly,0
onoff:		dc.w	1	; Verkleinerung ein(/aus)

	BSS

	GLOBL	basis,vhandle,gr_cw,gr_ch
	GLOBL	gr_bw,gr_bh,max_w,max_h,gr_res,planes
	GLOBL	aktivkom

basis:
vhandle:     ds.w    1	     VDI-Handle
gr_cw:	     ds.w    1		   Zeichenbreite
gr_ch:	     ds.w    1		   Zeichenhîhe
gr_bw:	     ds.w    1		   Boxbreite
gr_bh:	     ds.w    1		   Boxhîhe
max_w:	     ds.w    1		   max. Rasterbreite
max_h:	     ds.w    1		   max. Rasterhîhe
gr_res:      ds.w    1	     TRUE = X:Y = 1:1
planes:      ds.w    1	     Anzahl der Ebenen

biton:	     ds.l    1		   Zeiger auf Bitblk fÅr
bitoff:      ds.l    1	     runde Buttons...

undobuff:    ds.b    256     Undobuffer
keytab:      ds.l    1	     Adresse auf Umwandlungstabellen
moflags:     ds.w    1	     Mausmeldung
dinfo:	     ds.l    1		   Zeiger auf DINFO-Struktur

	IFD	TCDR1

contrl:      ds.w     15
control:     EQU      contrl
intin:	     ds.w     15
intout:      ds.w     45
ptsout:      ds.w     12
addrin:      ds.l     2
addrout:     ds.l     1
ptsin:	     ds.w     30

	ENDIF
	
	IFD	ASS
	GLOBL contrl,control,global,intin,intout,ptsout,addrin,addrout,ptsin
contrl:      ds.w     15
control      EQU      contrl
global	     ds.w     15
intin:	     ds.w     128
intout:      ds.w     45
ptsout:      ds.w     128
addrin:      ds.l     2
addrout:     ds.l     1
ptsin:	     ds.w     128
	ENDIF

default:     ds.w    1	     Defaultobjekt abhÑngig vom
inddefault:  ds.w    1	     Textobjekt
aktivkom:    ds.w    1	     Aktivierungskombination

objptr:      ds.l    1	     Zeiger auf Objekt
obj:	     ds.w    1	     Objektnummer
index:	     ds.w    1	     Index

;
; AES-Infos
;
appl_init	    EQU $0A000100
appl_exit	    EQU $13000100
graf_handle	    EQU $4D000500
rsrc_load	    EQU $6E000101
rsrc_free	    EQU $6F000100
rsrc_gaddr	    EQU $70020100

;
; Ende
;
	  END
