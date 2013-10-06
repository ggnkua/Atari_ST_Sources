
SWSARRAYNB	equ	30			; anzahl an strings, die zu aendern sind
SWSFITEMPSTRMAX	equ	1024			; laenge des temporaeren strings

		rsreset
SWSBASTART	rs.w	1
SWSBASTOP	rs.w	1
SWSBALENGTH	rs.w	1
SWSBABYTES	rs.w	1



		text


; ---------------------------------------------------------
; 04.08.00/vk
; setzt die aktuellen weaponbezeichnung in die textstrings ein.
; rettet alle register
setWeaponStrings
		movem.l	d0/a0-a4,-(sp)

		bsr.s	initWeaponStrings

		lea	swsArray,a3
		lea	swsSwapArray,a4
		lea	swsBackupArray,a2

		moveq	#SWSARRAYNB-1,d0
swsLoop		movea.l	(a3)+,a0
		movea.l	(a4)+,a1
		bsr.s	setSingleWeaponString
		adda.w	#SWSBABYTES,a2
		dbra	d0,swsLoop

		movem.l	(sp)+,d0/a0-a4
		rts


; ---------------------------------------------------------
; 05.08.00/vk
; todo
; initialisiert die zu einzusetzenden waffen-strings.
; rettet alle register
initWeaponStrings
		movem.l	d0-a6,-(sp)

		lea	swsSwapArray,a0
		moveq	#SWSARRAYNB-1,d0
iwsLoop		move.l	#testString,(a0)+
		dbra	d0,iwsLoop

		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; 05.08.00/vk
; tauscht die zeichenkette $(XXXXX[...]XXXXXX) durch eine
; andere aus. speichert die information ueber die ersetze
; position. falls zeichenkette $(XXX[..]XX) nicht mehr
; vorhanden ist, wird die abgespeicherte information
; verwendet.
; a0 = zeichenkette, in der die ersetzung vorgenommen wird
; a1 = zeichenkette, die eingesetzt wird
; a2 = swsbackuparray datenstruktur
; rettet alle register
setSingleWeaponString
		movem.l	d0-a6,-(sp)

		bsr.s	getWeaponTokenPos		; in: a0-a2, out: d0-d1
		bsr.s	setWeaponStringFromIndex	; in: a0-a1, d0-d1

		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; 05.08.00/vk
; gibt die position von anfang und ende im string zurueck,
; die ersetzt werden soll.
; a0 = zeichenkette (mit token)
; a1 = zeichenkette, die eingesetzt wird
; a2 = swsbackuparray datenstruktur
; rueckgabe: d0 = anfang
;            d1 = ende
; rettet alle register
getWeaponTokenPos
		movem.l	d2/a0-a1,-(sp)

		moveq	#-1,d0
gwtpStartLoop	addq.w	#1,d0
		move.b	(a0)+,d2
		beq.s	gwtpFoundEnd
		cmpi.b	#"$",d2
		bne.s	gwtpStartLoop
		move.b	(a0),d2
		cmpi.b	#"(",d2
		bne.s	gwtpStartLoop

		move.w	d0,d1
		addq.w	#1,d1
gwtpEndLoop	addq.w	#1,d1
		move.b	(a0)+,d2
		beq.s	gwtpFoundEnd
		cmpi.b	#")",d2
		bne.s	gwtpEndLoop

		moveq	#-1,d2
gwtpFindLoop	addq.w	#1,d2
		tst.b	(a1)+
		bne.s	gwtpFindLoop

		move.w	d2,SWSBALENGTH(a2)
		move.w	d0,SWSBASTART(a2)
		add.w	d0,d2
		move.w	d2,SWSBASTOP(a2)
		bra.s	gwtpOut

gwtpFoundEnd
		move.w	SWSBASTART(a2),d0
		move.w	SWSBASTOP(a2),d1

gwtpOut
		movem.l	(sp)+,d2/a0-a1
		rts


; ---------------------------------------------------------
; 05.08.00/vk
; d0 = index start
; d1 = index ende+1
; a0 = zeichenkette, in der die ersetzung vorgenommen wird
; a1 = zeichenkette, die eingesetzt wird
; rettet alle register
setWeaponStringFromIndex
		movem.l	d2/a0-a4,-(sp)

		lea	swsfiTempString,a3
		movea.l	a3,a4

		move.w	d0,d2
		beq.s	swsfiSkipPart1

		subq.w	#1,d2
		movea.l	a0,a2

swsfiP1Loop	move.b	(a2)+,(a3)+
		dbra	d2,swsfiP1Loop
swsfiSkipPart1

swsfiP2Loop	move.b	(a1)+,(a3)+
		bne.s	swsfiP2Loop		

		subq.l	#1,a3
		lea	(a0,d1.w),a2

swsfiP3Loop	move.b	(a2)+,(a3)+
		bne.s	swsfiP3Loop

		movea.l	a4,a3
swsfiCopyLoop	move.b	(a3)+,(a0)+
		bne.s	swsfiCopyLoop

		movem.l	(sp)+,d2/a0-a4
		rts








		data


; in diesen strings die ersetzungen vornehmen
swsArray	dc.l	thingsTxt020		; 10 mal waffe gefunden
		dc.l	thingsTxt021
		dc.l	thingsTxt022
		dc.l	thingsTxt023
		dc.l	thingsTxt020
		dc.l	thingsTxt095
		dc.l	thingsTxt096
		dc.l	thingsTxt097
		dc.l	thingsTxt098
		dc.l	thingsTxt099
		dc.l	thingsTxt100

		dc.l	thingsTxt005		; 10 mal munition gefunden (static)
		dc.l	thingsTxt006
		dc.l	thingsTxt007
		dc.l	thingsTxt008
		dc.l	thingsTxt083
		dc.l	thingsTxt084
		dc.l	thingsTxt085
		dc.l	thingsTxt086
		dc.l	thingsTxt087
		dc.l	thingsTxt088

		dc.l	thingsTxt030		; 10 mal munition gefunden (optional)
		dc.l	thingsTxt031
		dc.l	thingsTxt032
		dc.l	thingsTxt033
		dc.l	thingsTxt089
		dc.l	thingsTxt090
		dc.l	thingsTxt091
		dc.l	thingsTxt092
		dc.l	thingsTxt093
		dc.l	thingsTxt094

; diese strings sind einzusetzen
swsSwapArray	ds.l	SWSARRAYNB

; informationen ueber position der ersetzung speichern
swsBackupArray	ds.b	SWSBABYTES*SWSARRAYNB

; todo
testString	dc.b	"RUNNING",0
		even


		bss


swsfiTempString	ds.b	SWSFITEMPSTRMAX


