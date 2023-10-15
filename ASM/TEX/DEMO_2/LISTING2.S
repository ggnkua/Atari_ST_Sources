; Listing 1: Weg mit dem rechten und dem linken Rand
; fÅr K-SEKA ab 1.5 in Farbe; Programm von Gunther und Andreas

screen = $70000
 
x:
	clr.l	-(sp)		; auf Supervisormodus schalten
	move.w	#$20,-(sp)	;
	trap	#1		;
	move.l	d0,savereg	; alten Stack sichern
	lea	screen,a7	; neuen Stack vor Bildschirm setzen

	move.l	#moff,-(sp)	; schalte Maus aus
	clr.w	-(sp)		;
	move.w	#25,-(sp)	;
	trap	#14		;
	addq.l	#8,sp		;
	line_a $a		; mouse off

	move.l	$44e.w,oldscreen ; alte Bildschirmadresse merken
	move.b	$ffff8260,d0	; alte Aufloesung merken
	and.w	#3,d0		;
	move.w	d0,oldres	;

	move.w	#0,-(sp)	; neue Bildschirmadresse setzen
	move.l	#screen,-(sp)	; und geringe Aufloesung einstellen
	move.l	#screen,-(sp)	;
	move.w	#5,-(sp)	;
	trap	14		;
	lea	12(sp),sp	;

	bsr	prepare		; bildschirm aufbauen

	move.b	$ffff820a.w,oldsync
	move.b	#$02,$ffff820a.w 	; Extrawurst fuer Rechner mit 60Hz

	movem.l	$ffff8240.w,d0-d7	; alte Palette retten
	movem.l	d0-d7,oldpal		;
	movem.l	pal(pc),d0-d7		; und neue Palette setzen
	movem.l	d0-d7,$ffff8240.w	;

	bsr	hblon			; rechten und linken Rand weg !

	move.w	#7,-(sp)		; warte auf den staunenden
	trap	#1			; Freak
	addq.l	#2,sp			;

	bsr	hbloff			; wieder zurueck zum Shiraz-Modus

	movem.l	oldpal(pc),d0-d7	; alte Palette herstellen
	movem.l	d0-d7,$ffff8240.w	;
	move.b	oldsync(pc),$ffff820a.w	; alte Bildfrequenz
	move.w	oldres(pc),-(sp)	; alte Aufloesung
	move.l	oldscreen(pc),-(sp)	; und Bildschirmadresse
	move.l	oldscreen(pc),-(sp)	;
	move.w	#5,-(sp)		;
	trap	14			;
	lea	12(sp),sp		;

	move.l	#mon,-(sp)		; Mausimpulse wieder erlauben
	clr.w	-(sp)			;
	move.w	#25,-(sp)		;
	trap	#14			;
	addq.l	#8,sp			;
	line_a	$9			; Maus wieder sichtbar
	move.l	savereg,-(sp)		; wieder in den User-Modus
	move.w	#$20,-(sp)		;
	trap	#1			;
	addq.l	#6,sp			;

;	illegal				; Rueckkehr in den SEKA
	clr.w	-(sp)			; zurueck nach GEM etc.
	trap	#1			;

;------------------------------------
savereg:	dc.l 0
oldscreen:	dc.l 0
oldres:		dc.w 0
oldpal:		blk.l 8,0
oldsync:	dc.b 0
even
mon:		dc.b $08
moff:		dc.b $12
;------------------------------------
prepare:
	lea	screen,a0		; Bildschirm adressieren
	moveq	#0,d1			; sorge fuer definierten Inhalt
	move.w	#11500-1,d0		; screenlÑnge, wenn Rand Åber
clsloop:				; 200 Zeilen offen wÑre
	move.l	d1,(a0)+		;
	dbf	d0,clsloop		;

	move.l	#34*160+24+4+screen,a6	; hier beginnen die Kaesten
	moveq	#0,d4			; Zeilenzaehler auf Null
kgloop:
	lea	kasten(pc),a0		; DATA's des Kastens
	move.w	#16-1,d7		; 16 Zeilen ist er hoch
gzloop:
	move.l	a6,a1			; hole Basisadresse
	add.w	#230,a6			; naechste Zeile schon mal adr.

	movem.l	(a0)+,d0-d1		; hole eine Zeile des Kastens
	moveq	#28-1,d6		; Anzahl KÑstchen je Zeile
gsloop:
	movem.l	d0-d1,(a1)		; Zeile des Kastens anzeigen
	addq.l	#8,a1			; adressiere naechsten Kasten
	dbf	d6,gsloop		; das ganze 25 Mal
	addq.w	#6,a1			; ueberfluessige 3 Planes
	addq.w	#1,d4			; erhoehe Zeilenzaehler
	cmp.w	#150,d4			; 150 Zeilen mit Muster fÅllen
	beq.s	kgende			; wenn erreicht
	dbf	d7,gzloop		; ansonsten naechste Kastenzeile
	bra.s	kgloop			; wenn Kasten fertig, neuen adr.
kgende:
	rts				; die Kaesten sind gemalt

pal:
	dc.w $0000,$0076,$0210,$0650,$0320,$0760,$0540,$0430
	dc.w $0527,$0111,$0222,$0333,$0444,$0555,$0666,$0777
kasten:
	dc.w $0001,$0000,$FFFF,$FFFF,$7FFD,$7FFC,$8003,$FFFF
	dc.w $4005,$7FFC,$8003,$FFFF,$5FF5,$7FFC,$8003,$FFFF
	dc.w $5015,$701C,$8FE3,$FFFF,$57D5,$701C,$8FE3,$FFFF
	dc.w $5455,$739C,$8FE3,$FFFF,$5555,$739C,$8FE3,$FFFF
	dc.w $5455,$739C,$8FE3,$FFFF,$57D5,$701C,$8FE3,$FFFF
	dc.w $5015,$701C,$8FE3,$FFFF,$5FF5,$7FFC,$8003,$FFFF
	dc.w $4005,$7FFC,$8003,$FFFF,$7FFD,$7FFC,$8003,$FFFF
	dc.w $0001,$0000,$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF
;------------------------------------
hblon:
	move.l	$120.w,oldtb		; Timer B Vektor retten
	move.l	$70.w,old4		; VBL-Vektor retten
	move.l	$70.w,new4b+2		; und verketten
	move.b	$fffffa07.w,old07	; MFP retten
	move.b	$fffffa09.w,old09	;
	move.b	$fffffa0f.w,old0f	;
	move.b	$fffffa11.w,old11	;
	move.b	$fffffa1b.w,old1b
	and.b	#$df,$fffa09		; Timer C wuerde Flackern verursachen
	and.b	#$fe,$fffa07		; noch kein Timer B
	move.l	#newtb,$120.w		; setze Timer B Vektor
	move.l	#new4,$70.w		; und VBL Vektor
	or.b	#1,$fffffa07.w		; nun darf der Timer B starten
	or.b	#1,$fffffa13.w		;
	rts

hbloff:
	move.w	sr,-(sp)		; sichere Statusregister
	move.w	#$2700,sr		; alle Interrups aus
	move.b	old07(pc),$fffffa07.w	; MFP-Parameter ruecksetzen
	move.b	old09(pc),$fffffa09.w	;
	move.b	old0f(pc),$fffffa0f.w	;
	move.b	old11(pc),$fffffa11.w	;
	move.b	old1b(pc),$fffffa1b.w	;
	move.l	oldtb,$120.w		; Timer B Vektor ruecksetzen
	move.l	old4,$70.w		; VBL-Vektor ruecksetzen
	move.w	(sp)+,sr		; altes Statusregister wieder setzen
	rts

old4:  dc.l 0
oldtb: dc.l 0
old07: dc.b 0
old09: dc.b 0
old0f: dc.b 0
old11: dc.b 0
old1b: dc.b 0
even

new4:
	clr.b	$fffffa1b.w		; Timer B halt
	move.b	#32-1,$fffffa21.w 	; Startzeile Timer B setzen
	move.b	#8,$fffffa1b.w		; Timer B als Zeilenzaehler
new4b:
	jmp	$000000			; alten VBL mit ausfuehren

newtb:
	clr.b	$fffffa1b.w		; Timer B stoppen
	movem.l	d0-d7/a0-a6,-(sp)	; Arbeitsregister retten
	move.w	#$fa21,a2		; Timer B Datenregister
	move.b	#200,(a2)		; auf 200 setzen
	move.b	#8,$fffffa1b.w		; Timer B zaehlt wieder Zeilen
	move.w	#$2700,sr		; alle Interrupts unterbinden

	move.w	#$8209,a0		; Bildschirmadresszaehler adr.
	move.w	#$8260,a6		; Aufloesungsregister adressieren
;	move.w	#$8240,a3		; frei, um Kontrollfarben zu setzen

	moveq	#0,d0
	moveq	#0,d1
	moveq	#16,d2
	moveq	#2,d3
	moveq	#0,d4

	move.b	(a2),d7			; hole aktuelle Bildausgabeadresse
wait:					; auf Ende der Zeile warten
	cmp.b	(a2),d7			; (via Timer B Zaehler)
	beq	wait			;

waitloop:
	move.b	(a0),d0			; unser kleiner Synkronisations-
	beq.s	waitloop		; trick ...
	sub	d0,d2			;
	lsl.w	d2,d1			;

anfang:
	blk.w	30,$4e71		; $4e71 = nop (30 mal)
	moveq	#16,d0			; verbrate etwas Zeit
delayloop1:				;
	nop				;
	dbf	d0,delayloop1		;

	lea	$ff820a,a0		; Register fuer Bildfrequenz
	move.w	#150,d0			; 150 Zeilen darstellen
zeilenloop2:
	nop				; Zeitschleife fuer neue Zeile
	nop				;
	nop				;
	nop				;
	nop				;
	moveq	#18,d1			;
delayloop2:
	nop				; Zeitschleife fuer rechten Rand
	dbf	d1,delayloop2		;
	nop				;
	nop				;
	nop				;

	move.b	d4,(a0)			; 60/50 Hz fuer rechten rand
	move.b	d3,(a0)			;
;
; ab hier endlich etwas Neues !
;
	blk.w	13,$4e71		; lasse rechts etwas offen

	move.b	d3,(a6)			; 70 Hz (Farbmonitor verzeih !)
	nop				; Erik's Gedenknop
	move.b	d4,(a6)			; wieder 50 Hz

	blk.w	13,$4e71		; warte auf linken Rand

	move.b	d3,(a6)			; schon wieder 70 Hz (fuer links)
	move.b	d4,(a6)			; zurueck ehe der Monitor es merkt

	dbf	d0,zeilenloop2

	movem.l	(sp)+,d0-d7/a0-a6	; zertruemmerte Register ruecksetzen
	bclr	#0,$fffffa0f.w		; Timer B ist beendet
	rte				;
