	;-------------------------------------------------------;
	;														;
	; PIWOBIND.S											;
	; Binding der Grafikfunktionen							;
	; getres und setres fr turboc							;
	;														;
 	; Copyright 1991: Oliver Spornitz und Detlev Nolte		;
 	;														;
	;-------------------------------------------------------;
	; setres liefert als Funktionsergebnis :
	; 0 = alles ok
	; -1= Fehler in der Parameterliste
	; -2= Grafiktreiber nicht installiert
	; positiver Wert = Bildschirmspeicher ist nicht ausreichend
	;
	; getres liefert als Funktionsergebnis:
	; -2= Grafiktreiber nicht installiert
	; sonst die Gr”že des Bildschirmspeichers (LONG)
	;
	; _checkinstall liefert als Funktionsergebnis:
	; -2= Grafiktreiber nicht installiert
	;  0= Grafiktreiber installiert
	;
	;----------------------------------------------------------
	

_getres		=1					; FN Nummer von getres
_setres		=2					; FN Nummer von setres
piwo		=3					; Trap fr Grafiktreiber
		
		xdef 	getres			; long cdecl getres( GPB *resbuffer ) 
		xdef 	setres			; long cdecl setres( GPB *resbuffer, int mode )
		xref 	_checkinstall	; long _checkinstall( void )
		xdef	toff,ton
		
getres:	movem.l	d3-d7/a2-a6,-(sp)

		pea	_checkinstall
		move.w	#$26,-(sp)
		trap	#14
		addq.l	#6,sp

		tst.l	d0
		bne		g_exit				; nein -> raus

		move.l	4+10*4(sp),-(sp)	; Parameter GPB kopieren
		move.w	#_getres,-(sp)		; und Treiber aufrufen
		trap	#piwo
		addq.l	#6,sp
g_exit:	movem.l	(sp)+,d3-d7/a2-a6
		rts

setres:	movem.l	d3-d7/a2-a6,-(sp)
		jsr		toff

		pea		_checkinstall
		move.w	#$26,-(sp)
		trap	#14
		addq.l	#6,sp

		tst.l	d0
		bne		s_exit				; nein -> raus

		move.w	8+10*4(sp),-(sp)	; Parameter mode kopieren
		move.l	6+10*4(sp),-(sp)	; Parameter GPB kopieren
		move.w	#2,-(sp)			; und Treiber aufrufen
		trap	#piwo
		addq.l	#8,sp
s_exit:
		move.l	d0,-(sp)
		jsr		ton
		move.l	(sp)+,d0
		movem.l	(sp)+,d3-d7/a2-a6
		rts

toff:	;schaltet den Tastaturprozessor ab
		pea		offstring
		move.w	#1,-(sp)
		move.w	#$19,-(sp)
		trap	#14
		addq.l	#8,sp
		rts

ton:	;schaltet den Tastaturprozessor wieder an
		pea		onstring
		move.w	#1,-(sp)
		move.w	#$19,-(sp)
		trap	#14
		addq.l	#8,sp
		rts




onstring:	dc.b	$11,0
offstring:	dc.b	$13,0
						