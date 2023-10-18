*****************************
* NEOchrome PICTURE SHOW
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
*	pea	show_NEOchrome(PC)
*	move.w	#38,-(SP)
*	trap	#14
*	lea	10(SP),SP

show_NEOchrome:
	move.b	$FFFF8260.w,sv_res
	clr.w	$FFFF8260.w		; niedrige Aufloesung
	move.b	$044F.w,$FFFF8201.w	; adr. log = adr. phys
	move.b	$0450.w,$FFFF8203.w


	move	#$2300,SR
	lea	palette_GEM(PC),A0
	movem.l $FFFF8240.w,D0-D7	; Farbreg. gespeichert
	movem.l D0-D7,(A0)
	
	move.l	8(SP),A0		; Adresse des Bildes in A0
	movem.l 4(A0),D0-D7		; NEO farbreg.
	movem.l D0-D7,$FFFF8240.w
	
	lea	$80(A0),A1
	move.l	$044E.w,A2
	move	#32000/8-1,D0
kopiert_daten:
	move.l	(A1)+,(A2)+
	move.l	(A1)+,(A2)+
	dbf	D0,kopiert_daten
	
	bsr	data_NEO
	
	move.l	$04CE.w,-(SP)
	lea	VBL_NEO(PC),A0
	move.l	A0,$04CE.w		; VBL installiert
	move.w	#7,-(SP)		; Das Bild erscheint genau
	trap	#1			; in diesem Moment ....
	addq.l	#2,SP
	move.l	(SP)+,$04CE.w		; VBL entfernt
	move.b	sv_res,$FFFF8260.w
	lea	palette_GEM(PC),A0	; Urspruengliche Palette
	move.l	A0,$045A.w		; wieder installiert
	rts				

VBL_NEO:
	lea	bss(PC),A1
	addq	#1,zaehler_vbl1-bss(A1)
	tst	neo_vbl-bss(A1)
	bpl.s	quit_vbl
	move	zaehler_vbl1-bss(A1),D0
	sub	zaehler_vbl2-bss(A1),D0
	cmp	vbl_anzahl-bss(A1),D0
	bcs.s	quit_vbl
	move	zaehler_vbl1-bss(A1),zaehler_vbl2-bss(A1)
	lea	$FFFF8240.w,A0
	add	erstes_farbreg-bss(A1),A0
	move	farbreg_anzahl-bss(A1),D0
	move	(A0),D1
	tst.b	neo_vbl-bss+1(A1)	; die Richtung
	bmi.s	rechts
	bra.s	links

schl_0	move	-(A0),2(A0)
links	dbf	D0,schl_0
	move	D1,(A0)
	rts

schl_1	move	2(A0),(A0)+
rechts	dbf	D0,schl_1
	move	D1,(A0)
quit_vbl:
	rts


data_NEO:
	lea	bss(PC),A1
	move	$32(A0),D0		; Bei D0 = 0 keine Animation,
	bpl.s	no_animation		; sonst VBL-Schnelligkeit.
	move	$30(A0),D1		; xxEL E=erstes Farbregister
	move	D1,D2			;      L=letztes Farbregister
	and	#$0F,D2
	lsr	#4,D1
	and	#$0F,D1
	move	D2,D3
	sub	D1,D3
	move	D3,farbreg_anzahl-bss(A1) ; E + farbreg_anzahl= L
	move.b	D0,D3
	ext	D3
	bpl	go_rechts		; Die Richtung
	neg	D3			; bei D3 < 0 links ( x <-- x)
	move	D1,D2
go_rechts:
	move	D3,vbl_anzahl-bss(A1)	; bei D3 > 0 rechts ( x --> x)
	lsl	#1,D2
	move	D2,erstes_farbreg-bss(A1) ; E wird gespeichert
no_animation:
	move	D0,neo_vbl-bss(A1)
	rts
	
sv_res		DS	1
palette_GEM: 	DS	16
bss:
zaehler_vbl1	DS	1
zaehler_vbl2	DS	1
vbl_anzahl	DS	1
erstes_farbreg	DS	1
farbreg_anzahl	DS	1
neo_vbl		DS	1
