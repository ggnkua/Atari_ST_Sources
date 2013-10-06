
MAXSHCHANGE	equ	48			; 24*2
MAXSHFALL	equ	32
PLAYERPIXHEIGHT	equ	52

JUMPTIME1000	equ	640			; dauer eines sprungs in msek.
JUMPHEIGHT	equ	26

TWCSHSSH	equ	0
TWCSHSLAST	equ	2
TWCSHSGRENZE	equ	4
TWCSHSFLAG	equ	6


TESTPOS		equ	0


		text


; ---------------------------------------------------------
; (neu berechnete) spielerposition ueberpruefen/korrigieren
testPosition
		movea.l	playerDataPtr,a6		; spielerdaten
		tst.w	PDHEALTH(a6)			; schon gestorben?
		bmi.s	tpSkip				; ja -> dann nur wandkontakt/sh

		clr.w	testOnlyIf			; unterroutinen berechnen sidesteps

		bsr	testThingContact
		bsr	testDoorContact
;		bsr	testMonterContact
;		bsr	testTrainContact
tpSkip		bsr	testWallContact

		rts


; ---------------------------------------------------------
; testThingContact: testet die neu berechnete
; spielerposition in bezug auf gegenstaende
testThingContact
		move.w	#1,posIsAllowed

		movea.l	playerDataPtr,a6		; spielerdaten
		movea.l	levelPtr,a2			; levelpointer
		move.w	PDCURRENTSECTOR(a6),d0
		movea.l	LEVSECSTART(a2,d0.w*4),a3
		adda.l	a2,a3				; a3 = (absoluter) pointer auf sektor
		move.l	SECTHINGS(a3),d0		; pointer auf gegenstaende des sektors
		beq	ttcOut				; keine gegenstaende vorhanden -> raus
		movea.l	d0,a5
		adda.l	a2,a5				; a5 = (absoluter) pointer auf gegenstandspointer

ttcLoop

	; a2 = levelPtr
	; a5 = pointer auf gegenstandspointer
	; a6 = playerDataPtr

		move.l	(a5)+,d1			; naechster gegenstandspointer
		beq.s	ttcLoop				; nicht gueltig -> naechster
		bmi	ttcOut				; ende erreicht -> raus

		movea.l	d1,a0				; pointer auf gegenstand
		adda.l	a2,a0				; a0 = (absoluter) pointer auf gegenstand
		tst.w	THINGTYPE(a0)			; gegenstand statisch (type=0)?
		bne.s	ttcLoop				; nein -> zum naechsten

		move.l	THINGLINE(a0),d0		; tx
		move.l	THINGLINE+4(a0),d1		; ty
		moveq	#0,d2
		move.w	THINGBREITE(a0),d2		; breite

		sub.l	PDTESTSX(a6),d0
		bpl.s	ttcDxPos
		neg.l	d0
ttcDxPos	cmp.l	d2,d0
		bgt.s	ttcLoop

		sub.l	PDTESTSY(a6),d1
		bpl.s	ttcDyPos
		neg.l	d1
ttcDyPos	cmp.l	d2,d1
		bgt.s	ttcLoop

	; spieler befindet sich innerhalb eines gegenstands

		tst.w	testOnlyIf			; soll nur getestet werden, ob innerhalb
		beq.s	ttcCalcSide			; nein -> dann zur berechnen des sidesteps weiter

		clr.w	posIsAllowed			; position auf nicht erlaubt setzen
		bra	ttcOut				; und raus

ttcCalcSide

	; jetzt bestimmen, welche seite "durchlaufen" wurde

		move.l	THINGLINE(a0),d0		; tx
		move.l	THINGLINE+4(a0),d1		; ty

		lea	whichSideMem,a0
		move.l	d0,d3
		move.l	d1,d4
		sub.l	d2,d3
		sub.l	d2,d4
		add.l	d2,d0
		add.l	d2,d1
		move.l	d3,SFPOINT0(a0)
		move.l	d4,SFPOINT0+4(a0)
		move.l	d3,SFPOINT1(a0)
		move.l	d1,SFPOINT1+4(a0)
		move.l	d0,SFPOINT2(a0)
		move.l	d1,SFPOINT2+4(a0)
		move.l	d0,SFPOINT3(a0)
		move.l	d4,SFPOINT3+4(a0)
		move.l	d3,SFPOINT4(a0)
		move.l	d4,SFPOINT4+4(a0)

		move.w	#$40,SFPOINT0+8(a0)
		move.w	#$00,SFPOINT1+8(a0)
		move.w	#$c0,SFPOINT2+8(a0)
		move.w	#$80,SFPOINT3+8(a0)

		bsr	testWhichSide		; registerrettung nicht notwendig
		tst.w	d0			; wurde seite korrekt berechnet?
		bmi.s	ttcError		; nein -> aenderung nicht zulaessig

		lea	sinus512TabX,a2
		move.w	mwAlpha,d1		; vorherige laufrichtung
		add.w	d7,d7			; von 256 (vollwinkel) auf 512 (d7 ist der winkel der durchstossenen seite)
		sub.w	d7,d1
		addi.w	#$80,d1
		andi.w	#$1ff,d1
		add.w	d1,d1
		fmove.x	(a2,d1.w*8),fp0		; cosinus
		fmul.w	mwStep,fp0
		move.w	d7,d1			; winkel fuer makeWalk
		fmove.w	fp0,d0			; schrittweite fuer makeWalk
		bsr	makeWalk
		bra.s	ttcOut

ttcError
		movea.l	playerDataPtr,a6
		move.l	PDSX(a6),PDTESTSX(a6)
		move.l	PDSY(a6),PDTESTSY(a6)
ttcOut
		clr.w	testOnlyIf
		rts


; ---------------------------------------------------------
; testDoorContact: testet die neu berechnete
; spielerposition in bezug auf tueren
testDoorContact
		move.w	#1,posIsAllowed

		movea.l	playerDataPtr,a6		; spielerdaten
		movea.l	levelPtr,a2			; levelpointer
		move.w	PDCURRENTSECTOR(a6),d0
		movea.l	LEVSECSTART(a2,d0.w*4),a3
		adda.l	a2,a3				; a3 = (absoluter) pointer auf sektor
		move.l	SECDOORS(a3),d0			; pointer auf tueren des sektors
		beq	tdcOut				; keine tueren vorhanden -> raus
		movea.l	d0,a5
		adda.l	a2,a5				; a5 = (absoluter) pointer auf tuerpointer

tdcLoop

	; a2 = levelPtr
	; a5 = pointer auf tuerpointer
	; a6 = playerDataPtr

		move.l	(a5)+,d1			; naechster tuerpointer
		beq.s	tdcLoop				; nicht gueltig -> naechster
		bmi	tdcOut				; ende erreicht -> raus

		movea.l	d1,a0				; pointer auf tuer
		adda.l	a2,a0				; a0 = (absoluter) pointer auf tuer

		clr.w	DOORUNDER(a0)			; flag loeschen -> spieler steht nicht unter der tuer

		lea	interPtr,a4
		lea	DOORSEC(a0),a1
		move.l	a1,(a4)+			; ersten eckpunkt pointer eintragen
		lea	SFPOINT1(a1),a1
		move.l	a1,(a4)+
		lea	SFPOINT1(a1),a1
		move.l	a1,(a4)+
		lea	SFPOINT1(a1),a1
		move.l	a1,(a4)
		lea	PDTESTSX(a6),a1
		movem.l	a0/a2/a5-a6,-(sp)
		bsr	testIfInsideOneSquare		; teste ein viereck
		movem.l	(sp)+,a0/a2/a5-a6
		tst.w	d0				; negativer rueckkehrcode?
		bmi.s	tdcLoop				; ja -> dann nicht unter-/innerhalb der tuer und ab zur naechsten tuer

	; spieler befindet sich unter-/innerhalb des tuerbereiches

		move.w	#1,DOORUNDER(a0)

	; ist die tuer gerade geschlossen, so dass die spielerposition auch unmoeglich ist?

		move.w	DOORLINE+10(a0),d0		; aktuelles h1
		sub.w	DOORH1(a0),d0
		cmpi.w	#PLAYERPIXHEIGHT,d0
		bgt.s	tdcOut
;		moveq	#0,d0
;		move.b	door_line+11(a0),d0
;		sub.w	door_h1(a0),d0
;		cmpi.w	#$18,d0
;		bgt.s	test_d_sec_pre_out

	; spieler befindet unerlaubt sich in einem tuerbereich

		tst.w	testOnlyIf			; soll nur getestet werden, ob innerhalb
		beq.s	tdcCalcSide			; nein -> dann zur berechnen des sidesteps weiter

		clr.w	posIsAllowed			; position auf nicht erlaubt setzen
		bra	tdcOut				; und raus

tdcCalcSide
		lea	sinus512TabX,a2
		move.w	mwAlpha,d0
		move.w	DOORANGLE(a0),d1
		add.w	d1,d1				; auf bereich [0..511] erweitern
		sub.w	d1,d0
		addi.w	#$80,d0
		andi.w	#$1ff,d0
		add.w	d0,d0
		fmove.x	(a2,d0.w*8),fp0			; cosinus
		fmul.w	mwStep,fp0
		fmove.w	fp0,d0
		bsr	makeWalk

tdcOut
		clr.w	testOnlyIf
		rts


; ---------------------------------------------------------
; spielerposition (normale laufbereiche) testen
testWallContact

	; der sichtbare sektor wird als bereits besucht gekennzeichnet

		movea.l	levelPtr,a6
		movea.l	LEVINITDATA(a6),a5
		adda.l	a6,a5
		movea.l	INITVISSECPTR(a5),a5
		adda.l	a6,a5
		movea.l	playerDataPtr,a4
		move.w	PDCURRENTSECTOR(a4),d0		; aktueller sektor
		bset	#0,(a5,d0.w)			; aktuellen sektor als bereits besucht kennzeichnen

	; muss in diesem sektor eine aktion ausgefuehrt werden?
	; benutze immernoch a4/a6 und d0 !!!

		movem.l	d0/a4/a6,-(sp)			; zwischenspeichern

		movea.l	LEVSECSTART(a6,d0.w*4),a0
		adda.l	a6,a0				; a0 = pointer sektor
		move.l	SECAKTION(a0),d1
		beq.s	twcNoAction

		bra.s	twcNoAction			; todo

		movea.l	d1,a0
		adda.l	a6,a0
		move.w	AKTIONTYPE(a0),d1
		beq.s	twcNoAction
		tst.w	AKTIONONCEFLAG(a0)
		beq.s	twcActionNow

	; aktion soll nur einmalig ausgefuehrt werden!
	; ist diese aktion bereits einmal ausgefuehrt worden?

		tst.w	AKTIONFLAG(a0)
		bne.s	twcNoAction

twcActionNow

	; aktion wird nun ausgefuehrt - dazu wird ein virtueller
	; gegenstand erzeugt ...

		move.w	#1,AKTIONFLAG(a0)
		lea	temporaryThing,a1
		move.w	d1,THINGTYPE(a1)
		move.l	PDSX(a4),THINGLINE(a1)
		move.l	PDSY(a4),THINGLINE+4(a1)

	; optionales argument nun kopieren (128 bytes)

		lea	AKTIONOPTARG(a0),a2
		lea	THINGACTION(a1),a0
		moveq	#15,d2
twcanCopyLoop	move.l	(a2)+,(a0)+
		move.l	(a2)+,(a0)+
		dbra	d2,twcanCopyLoop

	; und nun die aktion ausfuehren ...

		movea.l	a1,a0

	; a0 = pointer gegenstand
	; d1 = THINGTYPE(a0)

		lea	things,a1
		movea.l	(a1,d1.w*4),a1		; a1 = pointer auf aktuellen gegenstand
		move.l	THGROUT(a1),d1
		beq.s	twcNoAction
		movea.l	d1,a2
		jsr	(a2)		

twcNoAction
		movem.l	(sp)+,d0/a4/a6


		ifne TESTPOS			; todo


	; timelimit - benutzt werden immernoch a4/a6 und d0

		movea.l	lev_timelimit(a6),a5
		tst.w	timelimit_flag(a5)
		beq.s	tmi_no_timelimit
		bmi.s	tmi_no_timelimit

		cmp.w	timelimit_sec(a5),d0
		bne.s	tmi_no_timelimit

	; timelimit wird aktiviert

		move.b	#1,pd_time_flag(a4)

		move.w	#-1,timelimit_flag(a5)
		move.l	timelimit_vbl(a5),pd_time_limit(a4)
		move.b	#$ff,pd_time_limit1+1(a4)
		move.b	#$ff,pd_time_limit2+1(a4)
		move.b	#$ff,pd_time_limit3+1(a4)
		move.b	#$ff,pd_time_limit4+1(a4)

		lea	sm_timelimit,a0
		bsr	install_message

		moveq	#2,d0
		bsr	set_colortable

tmi_no_timelimit

		ifne ivan_debug
		move.l	#$0004050a,ivan_code
		endc


		endc




		movea.l	playerDataPtr,a6
		tst.w	PDHEALTH(a6)
		bpl.s	twcPlayerAlive

	; spieler ist gestorben, hoehe absenken bzw. tiefer lassen

		movea.l	PDCURRENTSFPTR(a6),a0
		move.w	#$38,d1
		move.w	SFSH(a0),d0
		bpl.s	twcDeadOk
		neg.w	d1
twcDeadOk	sub.w	d1,d0
		move.w	d0,shFound
		bra	twcPositionOk

twcPlayerAlive

	; jetzt koennen wir die position austesten

		movea.l	levelPtr,a2
		move.w	PDCURRENTSECTOR(a6),d0
		movea.l	LEVSECSTART(a2,d0.w*4),a0
		adda.l	a2,a0				; teste zuerst alle (normalen) sector fields des aktuellen
		movea.l	SECSECT(a0),a0			; sektors. haben wir gueltige position, dann raus
		adda.l	a2,a0
		bsr	testIfInside
		tst.w	insideOk			; testen
		beq	twcPositionOk			; ja -> dann weiter

		movea.l	levelPtr,a2
		move.w	PDCURRENTSECTOR(a6),d0
		movea.l	LEVSECSTART(a2,d0.w*4),a0
		adda.l	a2,a0
		move.l	SECOSECT(a0),a0
		adda.l	a2,a0
		bsr	testIfInside
		tst.w	insideOk
		bmi.s	twcNoSectorChange

	; spieler hat den sektor gewechselt

		move.w	SFOTHERSEC(a0),PDCURRENTSECTOR(a6)	; neuen sektor eintragen
		bra.s	twcPositionOk

twcNoSectorChange

	; spieler befindet sich ein keinem zulaessigen sector field und hat auch den sektor nicht
	; gewechselt -> bewegung "an der wand lang"

		bsr	calcSideStep

	; ist der sidestep ueberhaupt erlaubt bgzl. der tueren?

		move.w	#1,testOnlyIf
; todo		bsr	testDoorContact

; todo		tst.w	testOnlyIf
; todo		bne.s	twcAgainNotIn

	; side step wurde berechnet und durchgefuehrt. teste, ob diese neue position nun wiederum
	; zulaessig ist oder nicht

		movea.l	levelPtr,a2
		move.w	PDCURRENTSECTOR(a6),d0
		movea.l	LEVSECSTART(a2,d0.w*4),a0
		adda.l	a2,a0
		movea.l	SECSECT(a0),a0
		adda.l	a2,a0
		bsr	testIfInside
		tst.w	insideOk			; position zulaessig?
		beq.s	twcPositionOk			; ja -> dann raus

		movea.l	levelPtr,a2
		move.w	PDCURRENTSECTOR(a6),d0
		movea.l	LEVSECSTART(a2,d0.w*4),a0
		adda.l	a2,a0
		movea.l	SECOSECT(a0),a0
		adda.l	a2,a0
		bsr	testIfInside
		tst.w	insideOk
		bmi.s	twcAgainNotIn

	; waehrend des side steps wurde ein sektorwechsel
	; durchgefuehrt. neuen sektor eintragen und dann -> raus

		move.w	SFOTHERSEC(a0),PDCURRENTSECTOR(a6)
		bra.s	twcPositionOk

twcAgainNotIn

	; side step wurde berechnet, die position
	; ist aber nicht zulaessig

		movea.l	PDCURRENTSFPTR(a6),a0		; vorheriges sf nehmen
		move.w	SFSH(a0),shFound

		bra.s	twcMisc


twcPositionOk

	; die neu berechnete position ist zulaessig egal ob sie eine normale bewegung ist, ein side
	; step oder ueber sektorgrenzen hinausging

	; die neu berechnete spielerposition ist zulaessig (bzw. spieler ist gestorben)

		move.l	PDPROVISSFPTR(a6),PDCURRENTSFPTR(a6)

		move.l	PDTESTSX(a6),PDSX(a6)		; spielerposition kann uebernommen werden
		move.l	PDTESTSY(a6),PDSY(a6)

twcMisc
;		bsr	twcNeedThing
		bsr	twcCalcSh
		bsr	twcCalcShSound

twcOut
		rts


;----------------------------------------------------------
; hoehe der spielfigur berechnen
; a6 = play_dat_ptr
twcCalcSh
		move.w	shFound,d7
		bpl.s	twcshShPos
		neg.w	d7
twcshShPos	move.w	d7,PDSHREAL(a6)			; hoehe des bodens, spieler kann evtl. springen

		tst.w	PDJUMPFLAG(a6)
		beq.s	twcshNoJump

	; spieler befindet sich gerade in einem sprung

		move.w	PDJUMPSTARTSH(a6),d5
		cmp.w	d7,d5				; vergleich mit tatsaechlicher bodenhoehe
		bge.s	twcshSameSh			; gleiche oder tiefere bodenhoehe -> normal weiter

	; im sprung ist der spieler (z. b.) eine treppenstufe nach unten gegangen

		clr.w	PDJUMPFLAG(a6)			; in diesem fall mit dem springen aufhoeren

		move.w	PDSH(a6),d4
		cmp.w	PDSHREAL(a6),d4
		bgt.s	twcshSameSh
		bra.s	twcshNoJump

twcshSameSh

	; gleiche bodenhoehe wie beim absprung - also einfach den sprung normal durchlaufen
	; - oder - im sprung ging der spieler eine treppenstufe herunten

	; sprungdauer: falcon (50 vbl/sec -> 32 vbl), milan (640 msek.)

		moveq	#0,d0
		move.w	PDJUMPPOS(a6),d0
		add.w	vblTime1000,d0
		cmpi.w	#JUMPTIME1000,d0
		bgt.s	twcshJumpEnd

		move.w	d0,PDJUMPPOS(a6)
		lea	sinus512TabX,a4
		lsl.l	#8,d0			; * 256
		divu.w	#JUMPTIME1000,d0
		add.w	d0,d0
		fmove.x	(a4,d0.w*8),fp6
		fmul.w	#JUMPHEIGHT*2,fp6
		fmove.w	fp6,d6
		add.w	d5,d6

	; d6 ist jetzt die neue hoehe. nun noch vergleichen, ob der spieler nicht an
	; die decke gestossen ist ...

		move.l	PDCURRENTSFPTR(a6),d5
		beq.s	twcshNoCeiling
		movea.l	d5,a0
		move.w	SFSH(a0),d5
		subi.l	#PLAYERPIXHEIGHT*2,d5
		add.w	SFHEIGHT(a0),d5
		cmp.w	d5,d6
		blt.s	twcshNoCeiling

	; spieler ist an die decke gestossen

twcshJumpEnd
		clr.w	PDJUMPFLAG(a6)
		move.w	PDJUMPSTARTSH(a6),PDSH(a6)
		bra.s	twcshOut

twcshNoCeiling
		move.w	d6,PDSH(a6)
		bra.s	twcshOut


twcshNoJump
		move.w	PDSH(a6),d3
		cmp.w	d3,d7				; d7 = PDSHREAL(a6)
		bgt.s	twcshHigher

	; spieler faellt herunter

		move.w	d3,d4
		sub.w	d7,d3
		cmpi.w	#MAXSHCHANGE*2,d3
		bgt.s	twcshChangeTooBig

		add.w	d4,d7
		lsr.w	#1,d7
		move.w	d7,PDSH(a6)
		bra.s	twcshOut

twcshChangeTooBig
		subi.w	#MAXSHCHANGE,d4
		move.w	d4,PDSH(a6)
		bra.s	twcshOut

twcshHigher

	; spieler macht einen schritt nach oben

		add.w	d3,d7
		lsr.w	#1,d7
		move.w	d7,PDSH(a6)

twcshOut
		rts


; ---------------------------------------------------------
; soundausgaben bei hoehenaenderung
; a6 = playerDataPtr
twcCalcShSound
		lea	twcshsData,a0
		move.w	TWCSHSSH(a0),d0
		move.w	PDSH(a6),d1
		move.w	d1,TWCSHSSH(a0)
		sub.w	d0,d1
		bpl.s	twcshsDifOk
		neg.w	d1			; d1 = neue differenz
twcshsDifOk	cmp.w	TWCSHSGRENZE(a0),d1
		bgt.s	twcshsSetFlag
		tst.w	TWCSHSFLAG(a0)
		bne.s	twcshsPlayIt
		move.w	d1,TWCSHSLAST(a0)
		bra.s	twcshsOut
twcshsPlayIt
		move.w	PDJUMPPOS(a6),d0
		cmpi.w	#24,d0
		blt.s	twcshsClearFlag

		move.w	#SNDJUMP,d0
		moveq	#0,d1
; todo		bsr	initSam

twcshsClearFlag
		clr.w	TWCSHSFLAG(a0)
		bra.s	twcshsOut

twcshsSetFlag
		move.w	#1,TWCSHSFLAG(a0)
		move.w	d1,TWCSHSLAST(a0)
twcshsOut
		rts


; ---------------------------------------------------------
; algorithmus: ccw
; a1-a3 = pointer p1-p3 (bleiben unveraendert)
; benutzt: d0-d3, resultat in d0
ccw
		move.l	(a2),d0			; schneller als movem.x auf 68040
		move.l	4(a2),d1
		move.l	(a3),d2
		move.l	4(a3),d3
		sub.l	d0,d2			; dx2
		sub.l	d1,d3			; dy2
		sub.l	(a1),d0			; dx1
		sub.l	4(a1),d1		; dy1

	; dx/dy auf alle faelle kleiner als 16bit -> muls.w anwendbar

		muls.w	d0,d3
		muls.w	d1,d2

		cmp.l	d2,d3
		bmi.s	ccwSmaller
		beq.s	ccwSame
ccwGreater
		moveq	#1,d0
		rts
ccwSmaller
		moveq	#-1,d0
		rts
ccwSame
		move.l	(a3),d2
		move.l	4(a3),d3
		sub.l	(a2),d2
		sub.l	4(a2),d3

		muls.w	d0,d2
		bmi.s	ccwSmaller
		muls.w	d1,d3
		bmi.s	ccwSmaller

		muls.w	d0,d0				; todo: algorithmus verkehrt (reg. d2/d3)
		muls.w	d1,d1
		muls.w	d2,d2
		muls.w	d3,d3
		add.l	d0,d1
		add.l	d2,d3
		cmp.l	d3,d2
		blt.s	ccwGreater
		moveq	#0,d0
		rts


; ---------------------------------------------------------
; algorithmus: intersect
; (a0) = pointer p1, 4(a0) = pointer p2, testPoints = pointer p3, testPoints+4 = pointer p4
; benutzt: d0-d3/d6/a0-a4, keine aenderung von a0
; rueckgabe: nbOfIntersect.w wird um eins erhoeht, falls schnitt vorhanden
intersect
		lea	testPoints,a4
		movea.l	(a0),a1
		movea.l	4(a0),a2
		movea.l	a4,a3
		bsr.s	ccw
		move.w	d0,d6
		addq.l	#8,a3
		bsr.s	ccw
		muls.w	d6,d0
		bmi.s	isctPartII
		rts
isctPartII
		movea.l	a3,a2			; a2 = a4 + 4
		movea.l	a4,a1
		movea.l	(a0),a3
		bsr.s	ccw
		move.w	d0,d6
		movea.l	4(a0),a3
		bsr.s	ccw
		muls.w	d6,d0
		bmi.s	isctPartIII
		rts
isctPartIII
		addq.w	#1,nbOfIntersect
		rts


; ---------------------------------------------------------
; algorithmus: intersectFourEdges
; interPtr: vier pointer auf vier koordinatenpaare
; benutzt: d0-d3/d6-d7/a0-a4
intersectFourEdges

		lea	testPoints,a2
		movea.l	playerDataPtr,a4

	; hilfslinie erstellen: horizontale linie nach rechts vom zu testenden standpunkt aus

		move.l	PDTESTSX(a4),d0
		move.l	PDTESTSY(a4),d1		
		move.l	d0,(a2)
		move.l	d1,4(a2)
		add.l	PDINTERDIST2(a4),d0
		move.l	d0,8(a2)
		move.l	d1,12(a2)
		
		lea	interPtr,a0
		move.l	(a0),16(a0)		; erste koordinate ist gleich der fuenften
		clr.w	nbOfIntersect

		movea.l	(a0),a1			; ersten koordinatenpointer holen
		move.l	(a1),d2			; x1
		move.l	4(a1),d3		; y1
		sub.l	(a2),d2			; d2 = dx
		bpl.s	ifeDxOk
		neg.l	d2
ifeDxOk		sub.l	d1,d3			; d3 = dy
		bpl.s	ifeDyOk
		neg.l	d3
ifeDyOk		cmp.l	PDINTERDIST1(a4),d2
		bgt.s	ifeOut
		cmp.l	PDINTERDIST1(a4),d3
		bgt.s	ifeOut

		moveq	#3,d7
ifeLoop		bsr	intersect		; register d6 wird in intersect benutzt
		addq.l	#4,a0
		dbra	d7,ifeLoop
ifeOut
		rts


; ---------------------------------------------------------
; berechnen, ob sich der spieler innerhalb eines der ab a0 angegebenen sector fields befindet oder nicht.
; PDPROVISSFPTR(a6) erhaelt einen pointer auf das evtl. gueltige sector field.
; a0 = pointer auf sector field-struktur
; a6 = playerDataPtr (darf nicht geaendert werden)
; verwendete register: d0-d5/d7/a1-a3
testIfInside
		move.l	a0,d7			; nullpointer?
		beq	tiiNotPossible		; ja -> raus

		move.w	(a0)+,d7		; schleifenzaehler
		bmi	tiiNotPossible		; anzahl null (=negativ) -> raus

		move.l	PDTESTSX(a6),d4		; neue, zu testende koordinaten
		move.l	PDTESTSY(a6),d5
		lea	PDTESTSX(a6),a1		; pointer auf zu testende koordinaten

tiiLoop
	; nicht veraendert werden duerfen: d4-d5/a0-a1/a6

		cmp.l	SFMINX(a0),d4
		blt.s	tiiNotInThis
		cmp.l	SFMAXX(a0),d4
		bgt.s	tiiNotInThis
		cmp.l	SFMINY(a0),d5
		blt.s	tiiNotInThis
		cmp.l	SFMAXY(a0),d5
		bgt.s	tiiNotInThis		

		move.w	SFFLAGS(a0),d2		; flags fuer aktuelles sector field
		btst	#0,d2			; ist sector field ein rechteck?
		bne.s	tii2dOk			; ja -> sind im x/y-koordinatensystem innerhalb

tiiNoRectangle
		lea	interPtr,a4
		movea.l	a0,a2
		move.l	a2,(a4)+		; ersten eckpunkt pointer eintragen
		lea	SFPOINT1(a2),a2
		move.l	a2,(a4)+
		lea	SFPOINT1(a2),a2
		move.l	a2,(a4)+
		lea	SFPOINT1(a2),a2
		move.l	a2,(a4)
		bsr.s	testIfInsideOneSquare	; teste ein viereck
		tst.w	d0
		bmi.s	tiiNotInThis

tii2dOk

	; spieler kann sector field nur betreten, wenn oben genug hoehe vorhanden ist

		move.w	SFSH(a0),d2
		move.w	d2,shFound
		bpl.s	tiiHeightOk
		neg.w	d2
tiiHeightOk	move.w	d2,d3
		sub.w	#MAXSHCHANGE,d2
		move.w	PDSH(a6),d0
		cmp.w	d0,d2
		bgt.s	tiiNotInThis
		move.w	SFHEIGHT(a0),d1
		subi.w	#PLAYERPIXHEIGHT*2,d1
		add.w	d1,d3
		cmp.w	d0,d3
		blt.s	tiiNotInThis
		bra.s	tiiPossible

tiiNotInThis
		lea	SFBYTES(a0),a0		; sf_pointer um eines erhoehen
		dbra	d7,tiiLoop
tiiNotPossible
		clr.l	PDPROVISSFPTR(a6)	; vorlaeufiges sector field existiert nicht
		move.w	#-1,insideOk
		bra.s	tiiOut

tiiPossible

	; spielerposition ist in diesem sector field erlaubt ...

		move.l	a0,PDPROVISSFPTR(a6)	; pointer auf vorlaeufiges sector field merken
		clr.w	insideOk
tiiOut
		rts


; ---------------------------------------------------------
; testet, ob die koordinaten bei (a1) innerhalb des durch
; interPtr angegebenen vierecks sich befinden oder nicht
; a1 = pointer auf zu testende koordinaten
; interPtr = 4 pointer auf die eckpunkte/koordinaten
; benutzte/veraenderte register: d0-d3/d6/a2-a3/a5
; rueckgabe: d0: 0 = punkt (a1) innerhalb, -1 = sonst
testIfInsideOneSquare
		moveq	#3,d6
		lea	interPtr,a5
		move.l	(a5),16(a5)		; erster eckpunkt = fuenfter eckpunkt
tiiosLoop
		move.l	(a5),a2			; pointer erster eckpunkt
		move.l	4(a5),a3		; pointer zweiter eckpunkt
		bsr.s	ccwClockwiseOrSame	; unterroutine (veraendert register d0-d3)
		tst.w	d0			; im uhrzeigersinn oder auf gleicher linie?
		bmi.s	tiiosOutside		; nein -> dann sicher ausserhalb
		addq.l	#4,a5			; pointer erhoehen
		dbra	d6,tiiosLoop		; restliche linien durchlaufen

tiiosInside	moveq	#0,d0
		rts

tiiosOutside	moveq	#-1,d0
		rts


; ---------------------------------------------------------
; testet, ob die linien (p1/p2) und (p2/p3) im uhrzeigersinn
; verlaufen bzw. auf gleicher verbindungslinie liegen
; a1-a3 = pointer p3/p1/p2 (achtung: reihenfolge, pointer bleiben unveraendert)
; benutzte/veraenderte register: d0-d3
; rueckgabe: d0: 0 = im uhrzeigersinn/gleiche linie, -1 = sonst
ccwClockwiseOrSame

		move.l	(a3),d0
		move.l	4(a3),d1
		move.l	(a1),d2
		move.l	4(a1),d3
		sub.l	d0,d2			; dx2
		sub.l	d1,d3			; dy2
		sub.l	(a2),d0			; dx1
		sub.l	4(a2),d1		; dy1

	; dx/dy auf alle faelle kleiner als 16bit -> muls.w anwendbar

		muls.w	d0,d3			; d3 = dx1 * dy2
		muls.w	d1,d2			; d2 = dx2 * dy1

		cmp.l	d2,d3
		ble.s	ccwcosTrue

		moveq	#-1,d0
		rts

ccwcosTrue	moveq	#0,d0
		rts


; ---------------------------------------------------------
; berechnung der richtung (bewegung an der wand entlang)
; und der neuen evtl. moeglichen spielerposition
; a6 = playerDataPtr
calcSideStep
		bsr.s	cssWhichLine
		tst.w	d0
		bmi.s	cssOut

		movea.l	PDCURRENTSFPTR(a6),a0
		mulu.w	#SFPOINT1,d0
		adda.l	d0,a0

		move.w	SFPOINT1-2(a0),d1	; bereich 0..255
		add.w	d1,d1
		move.w	mwAlpha,d0		; letzte gegangene richtung
		sub.w	d1,d0
		addi.w	#$80,d0
		andi.w	#$1ff,d0
		add.w	d0,d0
		lea	sinus512TabX,a2
		fmove.x	(a2,d0.w*8),fp0		; cosinus
		fmul.w	mwStep,fp0
		fmove.w	fp0,d0			; mwStep

		bsr	makeWalk
cssOut
		rts


; ---------------------------------------------------------
; hole das zuletzt gueltige sector field und berechne,
; welche seite des vierecks durchgangen wurden
; a6 = playerDataPtr
; rueckgabe: d0: -1 (fehler), 0..3 (seitennummer)
;            d7: winkelangabe der durchstossenen seite (im falle der gueltigkeit)
cssWhichLine
		move.l	PDCURRENTSFPTR(a6),d0
		beq.s	csswlError

		movea.l	d0,a0
		bsr.s	testWhichSide
		bra.s	csswlOut
csswlError
		moveq	#-1,d0
csswlOut
		rts


; ---------------------------------------------------------
; berechne, welche seite des vierecks (sf in a0) durchgangen wurde
; a0 = sector field struktur
; a6 = playerDataPtr
; benutzte/veraenderte register: d0-d7/a0-a3
; rueckgabe: d0: -1 (fehler), 0..3 (seitennummer)
;            d7: winkelangabe der durchstossenen seite (im falle der gueltigkeit)
testWhichSide
		lea	testPoints,a1
		move.l	PDSX(a6),(a1)
		move.l	PDSY(a6),4(a1)
		move.l	PDTESTSX(a6),8(a1)
		move.l	PDTESTSY(a6),12(a1)

		moveq	#0,d6			; flag, ob bereits eine durchstossene seite gefunden

		moveq	#3,d5
twsLoop
		lea	testPoints,a1
		lea	8(a1),a2
		movea.l	a0,a3
		bsr	ccw
		move.w	d0,d4
		lea	SFPOINT1(a3),a3
		bsr	ccw
		muls.w	d4,d0
		beq.s	twsPart1Ok
		bpl.s	twsSkip
twsPart1Ok
		movea.l	a1,a3
		movea.l	a0,a1
		lea	SFPOINT1(a1),a2
		bsr	ccw
		move.w	d0,d4
		addq.l	#8,a3
		bsr	ccw
		muls.w	d4,d0
		beq.s	twsPart2Ok
		bpl.s	twsSkip
twsPart2Ok
		move.l	8(a0),d7		; high word enthaelt winkelangabe
		move.w	#3,d7
		sub.w	d5,d7			; d7 = seitennummer
		addq.w	#1,d6
twsSkip
		lea	SFPOINT1(a0),a0
		dbra	d5,twsLoop

		cmpi.w	#1,d6
		bne.s	twsError
		move.w	d7,d0
		swap	d7
		rts

twsError
		moveq	#-1,d0
		rts








		data

; twcCalcShSound
twcshsData	dc.w	0
		dc.w	0
		dc.w	8
		dc.w	0



		bss

shFound		ds.w	1			; gefundener hoehenwert
insideOk	ds.w	1			; fuer testIfInside()
nbOfIntersect	ds.w	1			; ex. schnitt_anz
testPoints	ds.l	4			; zwei paar testkoordinaten (eine linie)
interPtr	ds.l	5
testOnlyIf	ds.w	1			; flag, ob die unterroutinen nur berechnen sollen, ob die position erlaubt ist
posIsAllowed	ds.w	1			; rueckgabeflag, s. o.
whichSideMem	ds.b	64			; zwischenspeicher fuer temporaeres sectorfield























		ifne TESTPOS

;**************************************
; test_trains_con
;**************************************

test_trains_con

		movea.l	play_dat_ptr,a6
		tst.w	pd_health(a6)
		bmi	test_trn_no_con

		clr.w	pd_train_hit(a6)

		movea.l	big_sector_ptr,a0
		movea.l	lev_trains(a0),a0
		movea.l	trn_move(a0),a1
		movea.l	trn_data(a0),a0

		move.w	max_trains,d7
		beq	test_trn_no_con
		subq.w	#1,d7
tt_loop
		move.w	trains_visible,d5
		move.w	max_trains,d6
		subq.w	#1,d6
		sub.w	d7,d6
		btst	d6,d5
		beq.s	train_not_hit

		movem.l	d7-a1,-(sp)
		bsr.s	test_train_now
		movem.l	(sp)+,d7-a1

		tst.w	inside_ok
		bne.s	train_not_hit

		movea.l	play_dat_ptr,a6
		move.w	#1,pd_train_hit(a6)
		movea.l	(a1),a2
		move.w	6(a1),d1		; akt. streckenabschnitt
		lsl.w	#5,d1
		adda.w	d1,a2
		tst.w	mdat_type(a2)
;		beq.s	train_hit_line

train_hit_circle

		movem.l	d0-a6,-(sp)
		move.w	#100*256,d1
		jsr	pd_health_minimieren
		movem.l	(sp)+,d0-a6
		bra.s	train_not_hit

train_hit_line

		move.w	mdat_rvec_alpha(a2),direction
		move.w	mdat_akt_gesch(a2),d0
		asr.w	#1,d0
		muls	vbl_time,d0
		move.w	d0,step

		bsr	make_walk

train_not_hit

		lea	td_data_length(a0),a0
		lea	tm_data_length(a1),a1

		dbra	d7,tt_loop


test_trn_no_con
		tst.w	test_only_if
		beq.s	test_trn_out

		clr.w	test_only_if

test_trn_out

                rts

;---------------

test_train_now

		lea	inter_ptr,a1

		move.l	a0,-(sp)
		lea	28*4(a0),a0
		move.l	a0,(a1)+
		addq.l	#8,a0
		move.l	a0,(a1)+
		addq.l	#8,a0
		move.l	a0,(a1)+
		addq.l	#8,a0
		move.l	a0,(a1)
		movea.l	a0,a1

		bsr	intersect_fouredge

		move.l	(sp)+,a0

		moveq	#1,d0
		move.w	d0,inside_ok
		cmp.w	schnitt_anz,d0
		bne.s	ttn_out

ttn_in_viereck

	; spieler befindet sich innerhalb des zug-viereckes
	; -> dritte dimension (hoehe) jetzt noch ueberpruefen ...

	; a0 = trn_data

		moveq	#0,d0
		moveq	#0,d1
		move.b	8*4+11(a0),d0		; h1
		move.b	8*4+15(a0),d1		; h2
		lsl.w	#2,d0
		lsl.w	#2,d1
		movea.l	play_dat_ptr,a6
		move.l	pd_sh(a6),d2
		cmp.l	d0,d2			; keine beruehrung, wenn
		blt.s	ttn_out			; spielerhoehe unterhalb des zuges ...
		subi.l	#player_pix_hgt*2,d2
		cmp.l	d1,d2
		bgt.s	ttn_out

		clr.w	inside_ok		; flag fuer kollision setzen

ttn_out
		rts



;**************************************
;* test_door_con
;**************************************


test_doors_con

		movea.l	play_dat_ptr,a4
		tst.w	pd_health(a4)
		bmi	test_d_sec_pre_out

		movea.l	big_sector_ptr,a2
		move.w	pd_akt_sector(a4),d0
		movea.l	lev_sec_start(a2,d0.w*4),a3
		move.l	sec_doors(a3),d0
		beq	test_d_sec_pre_out

		movea.l	d0,a5
		bsr.s	test_doors_sec

		rts

;---------------

test_doors_sec
		move.l	(a5)+,d1
		beq.s	test_doors_sec
		bmi	test_d_sec_pre_out

		movea.l	d1,a0
		clr.w	door_under(a0)

		lea	door_sec(a0),a1
		lea	inter_ptr,a0
		move.l	a1,(a0)+
		lea	12(a1),a1
		move.l	a1,(a0)+
		lea	12(a1),a1
		move.l	a1,(a0)+
		lea	12(a1),a1
		move.l	a1,(a0)+

		bsr	intersect_fouredge

		cmpi.w	#1,schnitt_anz
		bne.s	test_doors_sec

		moveq	#0,d0
		movea.l	-4(a5),a0		; tuerpointer nochmals holen
		move.w	#1,door_under(a0)
		move.b	door_line+11(a0),d0
		sub.w	door_h1(a0),d0
		cmpi.w	#$18,d0
		bgt.s	test_d_sec_pre_out

	; spieler befindet unerlaubt sich in einem tuerbereich

		tst.w	test_only_if
		bne.s	test_doors_out

		lea	sinus_256_tab,a2
		move.w	direction,d0
		sub.w	door_angle(a0),d0
		addi.w	#$40,d0
		andi.w	#$ff,d0
		move.w	(a2,d0.w*2),d2		; cosinus

		muls	step,d2
		moveq	#14,d1
		asr.l	d1,d2

		move.w	d2,step
		move.w	door_angle(a0),direction
		bsr	make_walk

		bra.s	test_doors_out


test_d_sec_pre_out

		tst.w	test_only_if
		beq.s	test_doors_out

		clr.w	test_only_if

test_doors_out
		rts


;**************************************
;* test_monst_con
;**************************************


test_monst_con

		movea.l	play_dat_ptr,a4
		tst.w	pd_health(a4)
		bmi	tmc_out

		movea.l	mon_buf2_ptr,a5
		move.w	mon_buf2_anz,d7
		bmi	tmc_out

tmc_loop
		move.l	(a5)+,a0

	; nur testen, wenn gegner noch nicht gestorben ist ...

		tst.w	mon_a_died(a0)
		bne	tmc_ok

		movem.l	mon_line(a0),d0-d1		; mx/my

		sub.l	sx_test,d0
		bpl.s	tmc_xdif_pos
		neg.l	d0
tmc_xdif_pos
		move.l	#$80,d2
		cmp.l	d2,d0
		bgt	tmc_ok

		sub.l	sy_test,d1
		bpl.s	tmc_ydif_pos
		neg.l	d1
tmc_ydif_pos
		cmp.l	d2,d1
		bgt	tmc_ok

	; spieler befindet sich zu nahe am gegner ...

		tst.w	test_only_if
		bne	tmc_out

	; jetzt bestimmen, welche seite "durchlaufen" wurden ...

		lea	which_side_mem,a1
		movem.l	mon_line(a0),d0-d1

		move.l	d0,d3
		move.l	d1,d4
		sub.l	d2,d3
		sub.l	d2,d4
		movem.l	d3-d4,(a1)
		movem.l	d3-d4,48(a1)
		move.l	#$40,8(a1)

		move.l	d0,d3
		move.l	d1,d4
		sub.l	d2,d3
		add.l	d2,d4
		movem.l	d3-d4,12(a1)
		clr.l	20(a1)

		move.l	d0,d3
		move.l	d1,d4
		add.l	d2,d3
		add.l	d2,d4
		movem.l	d3-d4,24(a1)
		move.l	#$c0,32(a1)

		move.l	d0,d3
		move.l	d1,d4
		add.l	d2,d3
		sub.l	d2,d4
		movem.l	d3-d4,36(a1)
		move.l	#$80,44(a1)

		movea.l	a1,a0
		bsr	test_which_side

		lea	sinus_256_tab,a2
		move.w	direction,d1		; vorherige laufrichtung
		sub.w	d0,d1
		addi.w	#$40,d1
		andi.w	#$ff,d1
		move.w	(a2,d1.w*2),d2		; cosinus

		muls	step,d2
		moveq	#14,d1
		asr.l	d1,d2
		move.w	d2,step
		move.w	d0,direction

		bsr	make_walk
		bra.s	tmc_out

tmc_ok
		dbra	d7,tmc_loop

tmc_pre_out
		tst.w	test_only_if
		beq.s	tmc_out
		clr.w	test_only_if

tmc_out
		rts





;**************************************
;* tmics_height
;**************************************

; spielerhoehe nicht automatisch festsetzen, sondern
; durch tastatureingaben -> zum debuggen

; a6 = play_dat_ptr

tmics_height
		lea	keytable,a0
		tst.b	$1b(a0)			; hoeher
		beq.s	tmicsh_no_1b
		move.w	vbl_time,d0
		lsl.w	#2,d0
		ext.l	d0
		add.l	d0,pd_sh(a6)
tmicsh_no_1b

		tst.b	$28(a0)			; tiefer
		beq.s	tmicsh_no_28
		move.w	vbl_time,d0
		lsl.w	#2,d0
		ext.l	d0
		sub.l	d0,pd_sh(a6)
tmicsh_no_28

		rts


;-----------------------

; a6: play_dat_ptr

tmi_need_thing
		movem.l	a0/a6,-(sp)

		tst.w	pd_health(a6)
		bmi.s	tmint_out

	; brauchen wir in diesem sf einen bestimmen gegenstand ?

		moveq	#0,d7
                move.b  sf_need_thing(A0),D7
                beq	tmint_no_besitz

	; der gegenstand muss nur im besitz sein

		tst.w	pd_jump_flag(a6)
		beq.s	tmint_you_can
		cmpi.b	#7,d7
		bne.s	tmint_no_besitz
tmint_you_can	movea.l	pd_things_ptr(a6),a5
		tst.w	-4(a5,d7.w*4)
		beq.s	tmint_reduce_energy

tmint_no_besitz

	; muss in diesem sf ein gegenstand aktiviert sein ?

		moveq	#0,d7
		move.b	sf_need_act(a0),d7
		beq.s	tmint_no_activ

		tst.w	pd_jump_flag(a6)
		beq.s	tmint_you_can2
		cmpi.b	#7,d7
		bne.s	tmint_no_activ
tmint_you_can2	lea	pl_leiste_act,a5
		tst.w	-2(a5,d7.w*2)
		beq	tmint_reduce_energy		

tmint_no_activ

		move.w	sf_energy(a0),d7
		beq.s	tmint_no_bodenplatte
		bmi.s	tmint_no_bodenplatte

		movem.l	d0-a6,-(sp)
		move.w	vbl_time,d0
		mulu	#25,d0
		sub.w	d0,d7
		bpl.s	tmint_b_ok
		moveq	#0,d7
tmint_b_ok	move.w	d7,sf_energy(a0)
		jsr	th_add_health
tmint_b_out	movem.l	(sp)+,d0-a6

tmint_no_bodenplatte

tmint_out
		movem.l	(sp)+,a0/a6
		rts

tmint_reduce_energy

	; spieler wird jetzt energie gemaess sf_staerke abgezogen!

		move.w	sf_need_staerke(a0),d6
		lea	sf_staerke_tab,a1
		move.w	(a1,d6.w*2),d1
		bmi	tmintre_sofort
		mulu	vbl_time,d1
		bra.s	tmintre_ok

tmintre_sofort
		move.w	#100*256,d1

tmintre_ok
		move.w	#1,pdhm_sound_flag		; keinen sound ...
		bsr	pd_health_minimieren

		movea.l	play_dat_ptr,a6
		tst.w	pd_health(a6)
		bmi.s	tmint_out

		tst.w	pd_invul(a6)
		bne.s	tmint_out

;		lea	pl_leiste_act,a5
;		move.w	#th_invul-1,d0
;		tst.w	(a5,d0.w*2)
;		bne.s	tmint_out

		lea	need_things_ptr,a5
		movea.l	-4(a5,d7.w*4),a0
		bsr	install_message

		movem.l	a0-a2,-(sp)
		move.w	#snd_need_thing,d0
		moveq	#0,d1
		bsr	init_sam_nd
		movem.l	(sp)+,a0-a2

		bra.s	tmint_out





;---------------

test_only_if	dc.w	0

		endc