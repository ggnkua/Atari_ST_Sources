		.globl _Install_SCSI
		.globl _my_scsi_cookie, _old_scsi_cookie
_Install_SCSI:	move.l	#0x53435349,d0
		bsr	find_cookie
		tst.l	a0
		bne.s	Install_SCSI2	|alter Cookie ...
		move.l	#0x53435349,d0
		move.l	#_my_scsi_cookie,d1
		bsr	insert_cookie
		moveq	#0,d0		|kein alter cookie
		rts
Install_SCSI2:	move.l	(a0),a0
		move.l	a0,d1
		lea	_old_scsi_cookie,a1
		move.w	4(sp),d0	|Groesse der Struktur
		subq	#1,d0
Install_SCSI3:	move.b	(a0)+,(a1)+	|alte Daten umkopieren
		dbra	d0,Install_SCSI3

		move.l	d1,a0		|wieder Zeiger auf aktive Struktur
		lea	_my_scsi_cookie,a1
		move.w	4(sp),d0	|Groesse der Struktur
		subq	#1,d0
Install_SCSI4:	move.b	(a1)+,(a0)+	|neue Daten eintragen
		dbra	d0,Install_SCSI4
		moveq	#1,d0		|1 = alter Cookie umkopiert
		rts	


|eigenen Cookie in das Cookie jar
|Parameter:  D0.l : Name des Cookies
|	     D1.l : Wert des Cookies
|	     D0.w : 0 - alles ok, Cookie wurde eingetragen
|		    <0 - Fehler aufgetreten, Cookie nicht eingetragen
insert_cookie:	movem.l D2-D4/A1,-(SP)
		move.l	0x5a0.w,D3	|Zeiger auf das Cookie Jar holen
		beq.s	insert_cookie_e |ist leer => Fehler
		movea.l D3,A1
		moveq	#0,D4		|Anzahl der Slots
insert_cookie_h:addq.w	#1,D4		|Slotanzahl erh”hen
		movem.l (A1)+,D2-D3	|Namen und Wert eines Cookies holen
		tst.l	D2		|leeren Cookie gefunden?
		bne.s	insert_cookie_h |Nein => weiter suchen
		cmp.l	D3,D4		|alle Slots belegt?
		beq.s	insert_cookie_e |Ja! => neue Liste anlegen
		movem.l D0-D4,-8(A1)	|neuen Cookie & Listenende einfgen
		moveq	#0,D0		|alles ok!
		bra.s	insert_cookie_x |und raus

insert_cookie_e:moveq	#-1,D0		|Fehler, Cookie nicht eingetragen
insert_cookie_x:movem.l (SP)+,D2-D4/A1
		rts

|Cookie suchen.
|Parameter:  D0.l : Name des Cookies
|	     A0.L : 0 - nicht gefunden
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
		rts
find_cookie_e:	sub.l	a0,a0
		rts

