


		text


; ---------------------------------------------------------
; 03.08.00/vk
; animation von gegenstaenden und schaltern, auch
; von liegengelassenen gegenstaenden.
animateItems

		bsr	aiCurrentSector
		bsr	aiExtendedSectors
		bsr	aiLeftItems

		rts


; ---------------------------------------------------------
; 03.08.00/vk
; animation der gegenstaende und schalter des aktuellen
; sektors.
aiCurrentSector
		movea.l	playerDataPtr,a4
		move.w	PDCURRENTSECTOR(a4),d0
		movea.l	levelPtr,a6
		movea.l	LEVSECSTART(a6,d0.w*4),a0
		adda.l	a6,a0				; a0 = aktueller sektor

		bsr	aiSectorItems			; in: a0/a6
		bsr	aiSectorSwitches		; in: a0/a6

		rts


; ---------------------------------------------------------
; 03.08.00/vk
; animation der gegenstaende und schalter des aktuellen
; sektors.
aiExtendedSectors
		movea.l	playerDataPtr,a4
		move.w	PDCURRENTSECTOR(a4),d0
		movea.l	levelPtr,a6
		movea.l	LEVSECSTART(a6,d0.w*4),a1
		adda.l	a6,a1				; a1 = aktueller sektor
		adda.w	#SECEXTLINES,a1			; array der anderen sichtbaren sektoren
aiesLoop
		move.w	(a1)+,d0			; naechster sektor
		bmi.s	aiesOut				; ende erreicht -> raus

		movea.l	LEVSECSTART(a6,d0.w*4),a0
		adda.l	a6,a0
		bsr	aiSectorItems			; in: a0/a6
		bsr	aiSectorSwitches		; in: a0/a6
		bra.s	aiesLoop
aiesOut
		rts


; ---------------------------------------------------------
; 03.08.00/vk
; animation der liegengelassenen gegenstaende.
aiLeftItems
		movea.l	levelPtr,a6

		move.w	monBufferNb,d7
		bmi.s	ailiOut
		lea	monBuffer,a1
ailiLoop
		movea.l	(a1)+,a2			; naechste gegneradresse
		tst.w	MONADIED(a2)			; gegner noch am leben?
		beq.s	ailiSkip			; ja -> gegner uebergehen
		move.l	MONTHINGTYPE(a2),d1		; existiert ein liegengelassener gegenstand?
		beq.s	ailiSkip			; nein -> ueberspringen
		lea	(a6,d1.l),a2
		tst.l	THINGANIMATION(a2)		; existiert dafuer ein animation?
		beq.s	ailiSkip
		tst.w	THINGTYPE(a2)			; schon aufgenommen?
		bmi.s	ailiSkip

		bsr	aiSingleItemAnimation
ailiSkip
		dbra	d7,ailiLoop

ailiOut
		rts


; ---------------------------------------------------------
; 03.08.00/vk
; gegenstande des sektor animieren.
; a0 = sector
; a6 = level
; rettet alle register
aiSectorItems
		movem.l	d1-d2/a1-a2,-(sp)
		move.l	SECTHINGS(a0),d1
		beq.s	aisiOut

		lea	(a6,d1.l),a1
aisiLoop
		move.l	(a1)+,d2
		beq.s	aisiSkip
		bmi.s	aisiOut
		lea	(a6,d2.l),a2
		tst.l	THINGANIMATION(a2)
		beq.s	aisiSkip
		tst.w	THINGTYPE(a2)
		bmi.s	aisiSkip

		bsr	aiSingleItemAnimation		; in: a2/a6
aisiSkip
		bra.s	aisiLoop
aisiOut
		movem.l	(sp)+,d1-d2/a1-a2
		rts


; ---------------------------------------------------------
; 03.08.00/vk
; schalter des sektor animieren.
; a0 = sector
; a6 = level
; rettet alle register
aiSectorSwitches

		movem.l	d1-d2/a1-a2,-(sp)
		move.l	SECSWITCHES(a0),d1
		beq.s	aissOut

		lea	(a6,d1.l),a1
aissLoop
		move.l	(a1)+,d2
		beq.s	aissSkip
		bmi.s	aissOut
		lea	(a6,d2.l),a2
		tst.l	SWITCHANIMATION(a2)
		beq.s	aissSkip
		tst.w	SWITCHNBACTIONS(a2)
		bne.s	aissSkip

		bsr	aiSingleSwitchAnimation
aissSkip
		bra.s	aissLoop
aissOut
		movem.l	(sp)+,d1-d2/a1-a2
		rts


; ---------------------------------------------------------
; 03.08.00/vk
; animiert einen gegenstand.
; thinganimation muss vorhanden sein.
; a2 = gegenstand
; a6 = level
; rettet alle register
aiSingleItemAnimation
		movem.l	d2-d3/a1,-(sp)

		move.l	THINGANIMATION(a2),d2
		lea	(a6,d2.l),a1

		move.w	ANIMATIONCOUNT(a1),d3
		add.w	vblTime1000,d3
		move.w	d3,ANIMATIONCOUNT(a1)

		move.w	ANIMATIONSPEED(a1),d2
		mulu.w	#20,d2					; todo
		cmp.w	d2,d3
		blt.s	aisiaOut

		clr.w	ANIMATIONCOUNT(a1)
		move.w	ANIMATIONPOS(a1),d2
		addq.w	#1,d2
		cmp.w	ANIMATIONNB(a1),d2
		blt.s	aisiaNoBegin
		moveq	#0,d2
aisiaNoBegin	move.w	d2,ANIMATIONPOS(a1)

		move.l	ANIMATIONDATA(a1),d3
		lea	(a6,d3.l),a1
		move.w	2(a1,d2.w*4),THINGLINE+18(a2)
		move.b	1(a1,d2.w*4),THINGLINE+9(a2)
aisiaOut
		movem.l	(sp)+,d2-d3/a1
		rts


; ---------------------------------------------------------
; 04.08.00/vk
; animiert einen schalter.
; switchanimation muss vorhanden sein.
; a2 = schalter
; a6 = level
; rettet alle register
aiSingleSwitchAnimation
		movem.l	d2-d3/a1,-(sp)

		move.l	SWITCHANIMATION(a2),d2
		lea	(a6,d2.l),a1

		move.w	ANIMATIONCOUNT(a1),d3
		add.w	vblTime1000,d3
		move.w	d3,ANIMATIONCOUNT(a1)

		move.w	ANIMATIONSPEED(a1),d2
		mulu.w	#20,d2					; todo
		cmp.w	d2,d3
		blt.s	aissaOut

		clr.w	ANIMATIONCOUNT(a1)
		move.w	ANIMATIONPOS(a1),d2
		addq.w	#1,d2
		cmp.w	ANIMATIONNB(a1),d2
		blt.s	aissaNoBegin
		moveq	#0,d2
aissaNoBegin	move.w	d2,ANIMATIONPOS(a1)

		move.l	ANIMATIONDATA(a1),d3
		lea	(a6,d3.l),a1
		move.w	2(a1,d2.w*4),SWITCHLINE+8+18(a2)
		move.b	1(a1,d2.w*4),SWITCHLINE+8+9(a2)
aissaOut
		movem.l	(sp)+,d2-d3/a1
		rts
