
			rsreset
KOCOMPRESSSCREEN	rs.w	1
KOEXPANDSCREEN		rs.w	1
KORUNMODE		rs.w	1
KORUNMODESWITCH		rs.w	1
KOJUMP			rs.w	1
KOFORWARD		rs.w	1
KOBACKWARD		rs.w	1
KOLEFT			rs.w	1
KORIGHT			rs.w	1
KOALTERNATE		rs.w	1
KOTERMINAL		rs.w	1
KOCOMPRESSEXPANDX	rs.w	1
KOCOMPRESSEXPANDY	rs.w	1
KOSWITCHTOHIGHERRES	rs.w	1
KOSWITCHTOLOWERRES	rs.w	1
KOFULLRESOLUTION	rs.w	1
KOLOWRESOLUTION		rs.w	1
KOACTION		rs.w	1
KOHALF3DWINDOW		rs.w	1
KOCOMPRESSMAP		rs.w	1
KOEXPANDMAP		rs.w	1
KOMAPONOFF		rs.w	1
KOMAPSWITCH		rs.w	1
KOMAPCONTENTSWITCH	rs.w	1
KOCOMPRESSLAPTOP	rs.w	1
KOEXPANDLAPTOP		rs.w	1
KOCOMPRESSEXPANDLAPTOPX	rs.w	1
KOCOMPRESSEXPANDLAPTOPY	rs.w	1
KOLAPTOPONOFF		rs.w	1
KOLAPTOPINPUTMODE	rs.w	1
KOA2SWITCH		rs.w	1

KOSCREENSHOT		rs.w	1

KOAUDIOSWITCH		rs.w	1
KOAUDIOMONOSTEREOSWITCH	rs.w	1
KOAUDIOSURROUNDSWITCH	rs.w	1

KOFRAMESPERSECONDSWITCH	rs.w	1

KOSELECTWEAPON0		rs.w	1
KOSELECTWEAPON1		rs.w	1
KOSELECTWEAPON2		rs.w	1
KOSELECTWEAPON3		rs.w	1
KOSELECTWEAPON4		rs.w	1
KOSELECTWEAPON5		rs.w	1
KOSELECTWEAPON6		rs.w	1
KOSELECTWEAPON7		rs.w	1
KOSELECTWEAPON8		rs.w	1
KOSELECTWEAPON9		rs.w	1

KOITEMSELECTPREVIOUS	rs.w	1
KOITEMSELECTNEXT	rs.w	1
KOITEMACTIVATE		rs.w	1



		text


; ---------------------------------------------------------
; eigenen keyboard-irq einrichten
installKeyboardIrq

		lea	ltKeyIrqStart,a0
		bsr	logString

		; tabelle loeschen

		lea	keytable,a0
		move.w	#128-1,d0
ikiClearLoop	clr.b	(a0)+
		dbra	d0,ikiClearLoop

		; interrupt einrichten

		move.w	#34,-(sp)		; kbdvbase
		trap	#14			; xbios
		addq.l	#2,sp
		movea.l	d0,a0
		move.l	a0,kbdvbasePtr
		move.l	-4(a0),oldIkbdkey
		move.l	#keyboardIrq,-4(a0)

		move.l	kbdvbasePtr,d0
		bsr	binToHex
		lea	ltKeyKbdvbaseAddressM,a1
		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		lea	ltKeyKbdvbaseAddress,a0
		bsr	logString

		lea	ltKeyIrqEnd,a0
		bsr	logString

		rts


; ---------------------------------------------------------
; urspruenglichen keyboard-irq wiederherstellen
restoreKeyboardIrq

		lea	ltKeyIrqReset,a0
		bsr	logString

		movea.l	kbdvbasePtr,a0
		move.l	oldIkbdkey,-4(a0)

		rts


; ---------------------------------------------------------
; interrupt-routine fuer tastaturevents
; d0.b = scancode (bit 7 = 1 -> taste losgelassen)
keyboardIrq
		movem.l	d0-a6,-(sp)
		andi.w	#$00ff,d0		; benoetigen spaeter d0.w-zugriffe
		lea	keytable,a0
		tst.b	d0
		bmi.s	kiReleased
kiPressed
		move.b	#1,(a0,d0.w)
		bra.s	kiOut
kiReleased		
		andi.b	#%01111111,d0
		clr.b	(a0,d0.w)
kiOut

		movea.l	screen_1,a0
		adda.l	#100*1280,a0
		move.l	a0,-(sp)
		move.l	d0,-(sp)
		bsr	paintHex
		addq.l	#8,sp

		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; 23.01.00/vk
; liest ein zeichen ueber gemdos aus dem tastaturbuffer.
; rueckgabe: d0.w = asciicode (0 = kein zeichen verfuegbar)
;            d1.w = scancode (0 = kein zeichen verfuegbar)
;            d2.w = 1 (zeichen in d0 und/oder d1 vorhanden), 0 (kein zeichen vorhanden)
; rettet alle register.
getCharGemdos
		movem.l	a0-a2,-(sp)

		move.w	#11,-(sp)		; cconis (console input state)
		trap	#1
		addq.l	#2,sp

		tst.l	d0
		beq.s	gcgNoChar		; kein zeichen verfuegbar

		move.w	#8,-(sp)		; cnecin (no echo console input)
		trap	#1
		addq.l	#2,sp

		move.l	d0,d1			; scan/ascii nach d1
		swap	d1			; und scan ins untere wort bringen
		moveq	#1,d2			; flag fuer erfolg setzen
		bra.s	gcgOut
gcgNoChar
		moveq	#0,d2			; flag fuer nicht verfuegbar setzen
gcgOut
		movem.l	(sp)+,a0-a2
		rts




		data

; keyboard overlay (kann waehrend des spiels angepasst werden)
keyoverlay	dc.w	$3e,$3f,$1d,$30
		dc.w	$1e,$48,$50,$4b
		dc.w	$4d,$38,$3c,$1d
		dc.w	$38,$2f,$2e,$3c
		dc.w	$3d,$39,$23,$43
		dc.w	$44

		dc.w	$0f,$32,$2c				; map

		dc.w	$40,$41,$1d,$38
		dc.w	$26,$31,$25

		dc.w	$14

		dc.w	$10,$11,$12

		dc.w	$21

		dc.w	$2,$3,$4,$5,$6,$7,$8,$9,$a,$b		; waffenauswahl

		dc.w	$1f,$20,$1c				; items


		bss

; original vektor fuer tastaturinterrupts
oldIkbdkey	ds.l	1
kbdvbasePtr	ds.l	1

; tabelle mit dem aktuellen zustand der tastatur
keytable	ds.b	128
