*****************************
* SPECTRUM PICTURE SHOW
* by Mutter Fr‚d‚ric
* (c) 90 ..................
* GruB von Sabine an Michael & Sacha
*
* 1) Bild entpacken
* 2) VBL installieren, das ein Bild auf 50 oder 60 HZ anzeigt
* 
* - Quellencode fuer Devpac oder Turboass
* - Funktioniert fur alle ST
* - Executable position-independant code! (kein relocation-table)
* - Aufruf im Supervisormodus

* Dieses Programm wird folgendermassen aufgerufen:
*	pea	picture(PC)		; Adresse des Bildes
*	pea	show_SPeCtrum(PC)
*	move.w	#38,-(SP)
*	trap	#14
*	lea	10(SP),SP

linien	=	199			; und nicht 200 !

show_SPeCtrum:
	move.b	$FFFF8260.w,sv_res
	clr.w	$FFFF8260.w		; niedrige Aufloesung
	move.b	$044F.w,$FFFF8201.w	; adr. log = adr. phys
	move.b	$0450.w,$FFFF8203.w


	move	#$2300,SR
	lea	palette_GEM(PC),A0
	movem.l $FFFF8240.w,D0-D7	; Farbreg. gespeichert
	movem.l D0-D7,(A0)
	lea	register_null(PC),A0	; Farbreg wird zu 0
	movem.l (A0),D0-D7		; ( auf dem Bildschirm nicht
	movem.l D0-D7,$FFFF8240.w	;  sichtbare Entpackung)

	move.l	8(SP),A0		; Adresse des Bildes in A0
	cmp	#"SP",(A0)
	bne	show_SPU
	
* Das ist ein  .SPC Bild
	pea	palette_SPU(PC)		; Entpackungspuffer
	move.l	4(A0),D0		; Datenlaenge
	pea	12(A0,D0.w)		; Zeiger auf kompr. Farbpalette
	move.l	$044E.w,-(SP)		; Bildschirmadresse
	pea	12(A0)			; Datenbeginn
	bsr	entpackt_SPC
	lea	16(SP),SP
	bra	show_picture

* Das ist ein  .SPU Bild
show_SPU
	move.l	$044E.w,A1
	move	#32000/8-1,D0
kopiert_daten:
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	dbf	D0,kopiert_daten
	
	lea	palette_SPU(PC),A1
	move	#$000,D2		; Farben 00 und 15 schwarz
	move	#linien*3-1,D0
kopiert_farben:
	addq.l	#2,A0
	move	D2,(A1)+
	move	#6,D1
kop_schleife:
	move.l	(A0)+,(A1)+		; Farben 01-14
	dbf	D1,kop_schleife
	addq.l	#2,A0
	move	D2,(A1)+		; Farben 00 und 15
	dbf	D0,kopiert_farben
	
show_picture:
	btst	#1,$FFFF820A.w		; Bildschirm: 50 oder 60 Hz?
	beq.s	Hz_60
	lea	aendert_frequenz(PC),A0	; fuer 50 Hz
	sub.w	#2,-(A0)
	lea     aendert_lea(PC),A0
	sub.w	#2,-(A0)

Hz_60	move.l	$04CE.w,-(SP)
	lea	VBL_SPU(PC),A0
	move.l	A0,$04CE.w		; VBL installiert
	move.w	#7,-(SP)		; Das Bild erscheint genau
	trap	#1			; in diesem Moment ....
	addq.l	#2,SP
	move.l	(SP)+,$04CE.w		; VBL entfernt
	move.b	sv_res,$FFFF8260.w
	lea	palette_GEM(PC),A0	; Urspruengliche Palette
	move.l	A0,$045A.w		; wieder installiert
	rts				


********************************
entpackt_SPC:
	lea	4(SP),A6		; Zeiger auf SP-Daten
	movea.l (A6),A0			; Ausgangspunkt:    Bild
	movea.l 4(A6),A1		; Bestimmungspunkt: Bildschirm 
	move.w	#1,D1
	move.w	#7,D7
	lea	32000(A1),A2		; A2 = Plane 0
	lea	8(A2),A3		; A3 = Plane 4

************************
* Entpacken von Daten
* nach DEGAS (.PC?)
*
************************
dec_picture:
	lea	-160*199(A2),A1
schl_2	move.b	(A0)+,D6
	ext.w	D6
	bmi.s	schl_4
schl_3	move.b	(A0)+,(A1)
	adda.w	D1,A1
	exg	D1,D7
	dbf	D6,schl_3
	
	bra.s	schl_6
schl_4	neg.w	D6
	addq.w	#1,D6
	move.b	(A0)+,D0
schl_5	move.b	D0,(A1)
	adda.w	D1,A1
	exg	D1,D7
	dbf	D6,schl_5
	
schl_6	cmpa.l	A2,A1
	bcs.s	schl_2
	addq.l	#2,A2 			; A2 = Plane n+1
	cmpa.l	A3,A2			; Plane 1 bis 4
	bcs.s	dec_picture

****************************
* Entpacken der Farbregister
* Farbreg. 00 immer schwarz
* Farbreg. von 01 bis 14 variieren
* Farbreg. 15 erscheint nicht auf dem Bildschirm,
*             ist aber von Spectrum zum Anzeigen der Mause freigehalten
****************************

	movea.l 08(A6),A0		; Komprimierte Palette
	movea.l 12(A6),A1		; Bestimmungspunkt
	move.w	#(linien*3)-1,D7

	moveq	#$0000,D0		; Farbreg. 0 schwarz
entpackt_palette:
	move.w	#13,D6			; Farbreg. von 01 bis 14 
	move.w	(A0)+,D1
	lsr.w	#1,D1
	move.w	D0,(A1)+
Farben:
	lsr.w	#1,D1
	bcc.s	Farbreg0
	move.w	(A0)+,(A1)+
	dbf	D6,Farben
	bra.s	naechste_palette
Farbreg0:
	move.w	D0,(A1)+
	dbf	D6,Farben
naechste_palette:
	move.w	D0,(A1)+
	dbf	D7,entpackt_palette
	rts


*************************************************
* Erklaerung zu VBL:
* 1) Zeigt Bild nicht an, wenn DMA-access an ist
* 2) synchronisiert sich am Ende der ersten Linie
* 3) Zeigt 199 Linien an
*************************************************
VBL_SPU:
	tst.w	$043E.w			; Drive on? no picture
	bne	ende_VBL
	move	SR,-(SP)
	ori	#$0700,SR
	lea	$FFFF8240.w,A4
	lea	$FFFF8209.w,A5
	lea	(A4),A0
	lea	(A4),A1
	lea	(A4),A2			; A0=A1=A2=A4= $FFFF8240 (Palette)
	lea	start_sync+2(PC),A6
aendert_lea:
	lea 	palette_SPU(PC),A3
	move.w	#linien-1,D7
	moveq	#0,D0
wait_linie1:
	tst.b	(A5)
	beq.s	wait_linie1
	move.b	(A5),D0
	adda.l	D0,A6
	jmp	(A6)
start_sync:
	REPT 81
	nop
	ENDR
	
	NOP				; das NOP wird fuer 50 Hz benutzt
schl_60Hz
	lea	(A4),A0
	lea	(A4),A1
	lea	(A4),A2
	move.l	(A3)+,(A0)+		; Palette Nr. 1
	move.l	(A3)+,(A0)+
	move.l	(A3)+,(A0)+
	move.l	(A3)+,(A0)+
	move.l	(A3)+,(A0)+
	move.l	(A3)+,(A0)+
	move.l	(A3)+,(A0)+
	move.l	(A3)+,(A0)+
	move.l	(A3)+,(A1)+		; Palette Nr. 2
	move.l	(A3)+,(A1)+
	move.l	(A3)+,(A1)+
	move.l	(A3)+,(A1)+
	move.l	(A3)+,(A1)+
	move.l	(A3)+,(A1)+
	move.l	(A3)+,(A1)+
	move.l	(A3)+,(A1)+
	move.l	(A3)+,(A2)+		; Palette Nr. 3
	move.l	(A3)+,(A2)+
	move.l	(A3)+,(A2)+
	move.l	(A3)+,(A2)+
	move.l	(A3)+,(A2)+
	move.l	(A3)+,(A2)+
	move.l	(A3)+,(A2)+
	move.l	(A3)+,(A2)+
	nop
	dbra	D7,schl_60Hz
aendert_frequenz:
	move	(SP)+,SR
ende_VBL:
	rts
sv_res		DS	1
palette_SPU:	DS.B	32*3*linien	; 1 Palette = 32 Bytes
palette_GEM: 	DS	16
register_null:	DS	16
