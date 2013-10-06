


		text


; ---------------------------------------------------------
; 13.02.00/vk
; fuegt die komplette linie in alle beteiligten strahlen ein.
; c3pcurrentflags ist (nach voraussetzung) geloescht bzw. wird
; erst in dieser prozedur korrekt gesetzt sein.
; die arrays
;   a2YLineH1Array
;   a2YLineH2Array
;   a2DistanceArray
;   a2XIndArray
;   a2YIndArray
; muessen gesetzt sein.
; a0 = zeiger auf aktuelle a2line
c3pa2cInsertLine

		lea	c3pCurrent,a1

		tst.w	A2LINEBACKSIDEFLAG(a0)
		beq.s	c3pa2cilFrontside

c3pa2cilBackside
		movea.l	A2LINEDATAPTR(a0),a3
		move.l	3*4(a3),d0
		btst	#13,d0					; flag fuer textur auf rueckseite testen
		bne.s	c3pa2cilFrontside			; ja -> dann wie von vorne betrachten (wird dadurch spiegelverkehrt)

		movea.l	A2LINEDATAPTR(a0),a3
		move.l	3*4(a3),d0
		btst	#10,d0					; flag fuer boden testen
		beq.s	c3pa2cilbNoFloor

		bsr	c3pa2cilBackFloor			; boden bis hoehe texturoberkante eintragen
		bra.s	c3pa2cilOut
c3pa2cilbNoFloor

		movea.l	A2LINEDATAPTR(a0),a3
		move.l	3*4(a3),d0
		btst	#11,d0					; flag fuer decke testen
		beq.s	c3pa2cilOut

		bsr	c3pa2cilBackCeiling			; decke ab hoehe texturunterkante eintragen
		bra.s	c3pa2cilOut


c3pa2cilFrontside

		bsr.s	c3pa2cilTextur				; normale textur von h1 bis h2 eintragen

		movea.l	A2LINEDATAPTR(a0),a3
		move.l	3*4(a3),d0
		btst	#10,d0					; flag fuer boden testen
		beq.s	c3pa2cilfNoFloor

		bsr	c3pa2cilTexturFloor			; boden unterhalb einer textur eintragen
c3pa2cilfNoFloor

		movea.l	A2LINEDATAPTR(a0),a3
		move.l	3*4(a3),d0
		btst	#11,d0					; flag fuer decke testen
		beq.s	c3pa2cilfNoCeiling

		btst	#12,d0					; flag fuer himmel testen
		bne.s	c3pa2cilfcSky

		bsr	c3pa2cilTexturCeiling
		bra.s	c3pa2cilfNoCeiling
c3pa2cilfcSky
		bsr	c3pa2cilTexturCeilingSky

c3pa2cilfNoCeiling


c3pa2cilOut
		rts


; ---------------------------------------------------------
; 09.03.2000/vk
c3pa2cilRegisterInit		
		move.w	A2LINENBRAYSDBRA(a0),d1		; soviele strahlen sind einzutragen
		move.w	A2LINERAYINDEX1(a0),d0		; dies ist der index des ersten strahls

		lea	a2YLineH1Array,a2
		lea	a2YLineH2Array,a3
		lea	a2DistanceArray,a4
		lea	a2XIndArray,a5
		lea	a2YIndArray,a6

		fmove.x	c3pa2ZoomMultiplicator,fp2	; multiplikator fuer errechnung des zoomfaktors

		rts


; ---------------------------------------------------------
; 08.03.2000/vk
; wandtextur von h1 bis h2 eintragen (standardfall).
; a0 = aktuelle linie
; a1 = c3pcurrent
c3pa2cilTextur
		movea.l	A2LINEDATAPTR(a0),a2
		move.w	2*4(a2),d0			; lineflag_1[31..16]
		andi.w	#$000f,d0			; texturnummer ist in bits [19..16]
		move.w	d0,C3PCURRENTTEXT(a1)		; und texturnummer eintragen

		bsr.s	c3pa2cilRegisterInit

c3pa2cilTLoop
		move.w	(a2)+,d5			; h1 (ist evtl. neg. als flag, aber erst muessen alle werte geholt werden)
		move.w	(a3)+,d6			; h2
		fmove.x	(a4)+,fp0			; entfernung (distance)
		move.w	(a5)+,C3PCURRENTXIND(a1)	; xind
		move.w	(a6)+,C3PCURRENTYIND(a1)	; yind

		tst.w	d5				; darf strahl eingetragen werden?
		bmi.s	c3pa2cilTSkip			; nein -> dann ueberspringen und ab zum naechsten

		fmove.x	fp0,C3PCURRENTDISTANCEX(a1)

		fmove.x	fp2,fp3
		fmul.x	fp0,fp3
		fmove.l	fp3,C3PCURRENTZOOM(a1)

		movem.l	d0-d1/a0-a6,-(sp)
		bsr	c3pa2MakeVEntry			; parameter d0/d5-d6/a1
		movem.l	(sp)+,d0-d1/a0-a6

		add.w	A2LINERAYOFFSET(a0),d0
c3pa2cilTSkip
		dbra	d1,c3pa2cilTLoop

		rts


; ---------------------------------------------------------
; 09.03.2000/vk
; boden unterhalb der textur (vorderseite) eintragen.
; a0 = aktuelle linie
; a1 = c3pcurrent
c3pa2cilTexturFloor
		movea.l	A2LINEDATAPTR(a0),a2
		moveq	#0,d0
		move.b	1(a2),d0
		move.w	d0,C3PCURRENTTEXT(a1)
		move.b	#%00000001,C3PCURRENTFLAGS(a1)	; nur flag fuer boden setzen, alle anderen loeschen

		bsr	c3pa2cilRegisterInit

c3pa2ciltfLoop
		move.w	(a2)+,d6			; h1 (ist evtl. neg. als flag, aber erst muessen alle werte geholt werden)
		fmove.x	(a4)+,fp0			; entfernung (distance)
		fmove.x	fp0,C3PCURRENTDISTANCEX(a1)

		tst.w	d6				; darf strahl eingetragen werden?
		bmi.s	c3pa2ciltfSkip			; nein -> dann ueberspringen und ab zum naechsten
		beq.s	c3pa2ciltfSkip

		moveq	#0,d5
		subq.w	#1,d6

		movem.l	d0-d1/a0-a6,-(sp)
		bsr	c3pa2MakeVEntry			; d0/d5-d6/a1
		movem.l	(sp)+,d0-d1/a0-a6

		add.w	A2LINERAYOFFSET(a0),d0
c3pa2ciltfSkip
		dbra	d1,c3pa2ciltfLoop

		rts


; ---------------------------------------------------------
; 09.03.2000/vk
; a0 = aktuelle linie
; a1 = c3pcurrent
c3pa2cilTexturCeiling
		movea.l	A2LINEDATAPTR(a0),a2
		moveq	#0,d0
		move.b	1(a2),d0
		move.w	d0,C3PCURRENTTEXT(a1)
		move.b	#%00000001,C3PCURRENTFLAGS(a1)	; nur flag fuer boden setzen, alle anderen loeschen

		bsr	c3pa2cilRegisterInit

c3pa2ciltcLoop
		move.w	(a2)+,d6			; h1 (ist evtl. neg. als flag, aber erst muessen alle werte geholt werden)
		move.w	(a3)+,d5			; h2
		fmove.x	(a4)+,fp0			; entfernung (distance)
		fmove.x	fp0,C3PCURRENTDISTANCEX(a1)

		tst.w	d6				; darf strahl eingetragen werden?
		bmi.s	c3pa2ciltcSkip			; nein -> dann ueberspringen und ab zum naechsten

		move.w	c3pHeightForDbra,d6
		cmp.w	d6,d5
		bge.s	c3pa2ciltcSkip

		addq.w	#1,d5

		movem.l	d0-d1/a0-a6,-(sp)
		bsr	c3pa2MakeVEntry			; d0/d5-d6/a1
		movem.l	(sp)+,d0-d1/a0-a6

		add.w	A2LINERAYOFFSET(a0),d0
c3pa2ciltcSkip
		dbra	d1,c3pa2ciltcLoop
		rts


; ---------------------------------------------------------
; 08.03.2000/vk
; a0 = aktuelle linie
; a1 = c3pcurrent
c3pa2cilTexturCeilingSky
		lea	c3p,a5
		move.w	C3PSKYTEXT(a5),C3PCURRENTTEXT(a1)
		move.l	C3PSKYZOOM(a5),C3PCURRENTZOOM(a1)
		move.w	C3PSKYXYOFFSET(a5),C3PCURRENTXYOFFSET(a1)
		clr.w	C3PCURRENTFLAGS(a1)

		move.w	$468.w,d3			; auf vbl counter zugreifen
		lsr.w	#2,d3
		movea.l	playerDataPtr,a6
		add.w	PDALPHA(a6),d3			; d3 = konstante zum berechnen von xind fuer skytextur

		lea	c3p,a5
		fmove.x	C3PSKYZOOMX(a5),fp4
		move.w	C3PSKYMASK(a5),d2
		
		bsr	c3pa2cilRegisterInit

c3pa2ciltcsLoop
		move.w	(a2)+,d6			; h1 (ist evtl. neg. als flag, aber erst muessen alle werte geholt werden)
		move.w	(a3)+,d5			; h2
		fmove.x	(a4)+,fp0			; entfernung (distance)

		tst.w	d6				; darf strahl eingetragen werden?
		bmi.s	c3pa2ciltcsSkip			; nein -> dann ueberspringen und ab zum naechsten

		move.w	c3pHeightForDbra,d6
		cmp.w	d6,d5
		bge.s	c3pa2ciltcsSkip

		addq.w	#1,d5

		fmove.x	fp0,C3PCURRENTDISTANCEX(a1)

		move.w	d3,d4
		add.w	d0,d4
		fmove.w	d4,fp3
		fmul.x	fp4,fp3
		fmove.w	fp3,d4
		and.w	d2,d4
		move.w	d4,C3PCURRENTXIND(a1)

		move.w	d5,d4
		sub.w	c3pHeightHalf,d4
		move.w	d4,C3PCURRENTYIND(a1)

		movem.l	d0-d3/a0-a6,-(sp)
		bsr	c3pa2MakeVEntry			; parameter d0/d5-d6/a1
		movem.l	(sp)+,d0-d3/a0-a6

		add.w	A2LINERAYOFFSET(a0),d0
c3pa2ciltcsSkip
		dbra	d1,c3pa2ciltcsLoop

		rts


; ---------------------------------------------------------
; 08.03.2000/vk
; a0 = aktuelle linie
; a1 = c3pcurrent
c3pa2cilBackFloor
		movea.l	A2LINEDATAPTR(a0),a2
		move.w	2*4(a2),d0
		lsr.w	#4,d0
		andi.w	#$000f,d0		
		move.w	d0,C3PCURRENTTEXT(a1)
		move.b	#%00000001,C3PCURRENTFLAGS(a1)	; nur flag fuer boden setzen, alle anderen loeschen

		bsr	c3pa2cilRegisterInit

c3pa2cilbfLoop
		move.w	(a2)+,d5			; h1 (ist evtl. neg. als flag, aber erst muessen alle werte geholt werden)
		move.w	(a3)+,d6			; h2
		fmove.x	(a4)+,fp0			; entfernung (distance)

		tst.w	d5				; darf strahl eingetragen werden?
		bmi.s	c3pa2cilbfSkip			; nein -> dann ueberspringen und ab zum naechsten

		moveq	#0,d5

		fmove.x	fp0,C3PCURRENTDISTANCEX(a1)

		movem.l	d0-d1/a0-a6,-(sp)
		bsr	c3pa2MakeVEntry			; d0/d5-d6/a1
		movem.l	(sp)+,d0-d1/a0-a6

		add.w	A2LINERAYOFFSET(a0),d0
c3pa2cilbfSkip
		dbra	d1,c3pa2cilbfLoop
		rts


; ---------------------------------------------------------
; 08.03.2000/vk
; a0 = aktuelle linie
; a1 = c3pcurrent
c3pa2cilBackCeiling
		movea.l	A2LINEDATAPTR(a0),a2
		move.w	2*4(a2),d0
		lsr.w	#4,d0
		andi.w	#$000f,d0		
		move.w	d0,C3PCURRENTTEXT(a1)
		move.b	#%00000001,C3PCURRENTFLAGS(a1)	; nur flag fuer boden setzen, alle anderen loeschen

		move.w	c3pHeightForDbra,d2

		bsr	c3pa2cilRegisterInit

c3pa2cilbcLoop
		move.w	(a2)+,d5			; h1 (ist evtl. neg. als flag, aber erst muessen alle werte geholt werden)
		fmove.x	(a4)+,fp0			; entfernung (distance)

		tst.w	d5				; darf strahl eingetragen werden?
		bmi.s	c3pa2cilbcSkip			; nein -> dann ueberspringen und ab zum naechsten

		move.w	d2,d6

		fmove.x	fp0,C3PCURRENTDISTANCEX(a1)

		movem.l	d0-d2/a0-a6,-(sp)
		bsr	c3pa2MakeVEntry			; d0/d5-d6/a1
		movem.l	(sp)+,d0-d2/a0-a6

		add.w	A2LINERAYOFFSET(a0),d0
c3pa2cilbcSkip
		dbra	d1,c3pa2cilbcLoop
		rts


