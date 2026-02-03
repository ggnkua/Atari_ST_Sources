		.globl _GetSCSICookie
_GetSCSICookie:	move.l	#0x53435349,d0

|Cookie suchen.
|Parameter:  D0.l : Name des Cookies
|	     D0.L : 0 - nicht gefunden
|		   !=0 - Zeiger auf Datenbereich dieses Cookies im cookiejar
find_cookie:	move.l	0x5a0.w,D1	|Zeiger auf das Cookie Jar holen
		beq.s	find_cookie_e	|ist leer => Fehler
		movea.l D1,A0
find_cookie_h:	movem.l (A0)+,D1-D2	|Namen und Wert eines Cookies holen
		tst.l	D1		|leeren Cookie gefunden?
		beq.s	find_cookie_e	|=> Ende, nichts gefunden
		cmp.l	d1,d0		|gefunden?
		bne.s	find_cookie_h	|Nein 
		subq.l	#4,a0
		move.l	(a0),d0
		rts
find_cookie_e:	clr.l	d0
		rts

