

		text


; ---------------------------------------------------------
; 30.07.00/vk
; waehlt aus der liste der verfuegbaren gegenstaende
; den vorherigen aus. schreibt direkt in pdcurrentitem.
; rettet alle register
itemSelectPrevious
		movem.l	d0-d1/a0-a1,-(sp)

		movea.l	playerDataPtr,a0
		move.w	PDCURRENTITEM(a0),d0

		lea	playerThings,a1
		move.w	d0,d1
		mulu.w	#PTHGBYTES,d1
		adda.l	d1,a1

ispLoop
		subq.w	#1,d0
		bmi.s	ispNotFound
		suba.w	#PTHGBYTES,a1
		tst.w	PTHGFLAG(a1)
		beq.s	ispLoop
		move.w	d0,PDCURRENTITEM(a0)
ispNotFound
		movem.l	(sp)+,d0-d1/a0-a1
		rts


; ---------------------------------------------------------
; 30.07.00/vk
; waehlt aus der liste der verfuegbaren gegenstaende
; den naechsten aus. schreibt direkt in pdcurrentitem.
; rettet alle register
itemSelectNext
		movem.l	d0-d1/a0-a1,-(sp)

		movea.l	playerDataPtr,a0
		move.w	PDCURRENTITEM(a0),d0

		lea	playerThings,a1
		move.w	d0,d1
		mulu.w	#PTHGBYTES,d1
		adda.l	d1,a1

isnLoop
		addq.w	#1,d0
		cmpi.w	#THINGSMAX,d0
		bge.s	isnNotFound
		adda.w	#PTHGBYTES,a1
		tst.w	PTHGFLAG(a1)
		beq.s	isnLoop
		move.w	d0,PDCURRENTITEM(a0)
isnNotFound
		movem.l	(sp)+,d0-d1/a0-a1
		rts


; ---------------------------------------------------------
; 30.07.00/vk
; je nach aktuellem zustand wird der aktuelle gegenstand
; aktiviert oder deaktiviert.
; rettet alle register
itemChangeActivationFlag
		movem.l	d0-a6,-(sp)

		bsr	recalcCurrentItem		; berechnet ggf. pdcurrentitem neu, d. h. pdcurrentitem zeigt auf den tatsaechlich korrekten gegenstand

		movea.l	playerDataPtr,a0
		move.w	PDCURRENTITEM(a0),d0
		bmi.s	icafNonSelected

		lea	things,a0
		movea.l	(a0,d0.w*4),a0

		lea	playerThings,a1
		mulu.w	#PTHGBYTES,d0
		adda.l	d0,a1

		tst.w	PTHGFLAG(a1)			; gegenstand ueberhaupt vorhanden (muss eigentlich der fall sein)
		beq.s	icafOut				; nein -> dann raus

		tst.w	PTHGACTFLAG(a1)			; gerade aktiviert?
		beq.s	icafSetActive			; nein -> dann jetzt aktivieren

icafSetDeactive
		move.l	THGDEACTIONROUT(a0),d0
		beq.s	icafOut
		bra.s	icafSetNow

icafSetActive
		move.l	THGACTIONROUT(a0),d0		; kann gegenstand ueberhaupt aktiviert werden?
		beq.s	icafOut				; nein -> dann raus
icafSetNow
		movea.l	d0,a0
		jsr	(a0)
		bra.s	icafOut

icafNonSelected
		lea	nonSelectedTxt,a0
		bsr	installMessage

icafOut
		movem.l	(sp)+,d0-a6
		rts




		data

		IFEQ LANGUAGE
nonSelectedTxt	dc.b	"NO ITEM SELECTED",0
		ELSE
nonSelectedTxt	dc.b	"KEINEN GEGENSTAND SELEKTIERT, KEINE (DE-)AKTIVIERUNG M™GLICH",0
		ENDC
		even

