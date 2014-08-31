*
* misceallaneous assembler routines
* author     : Jan Kriesten
* last change: 12.04.1993
*

*** Globale Variablen:

*** Globale Funktionen:

*** Systemadressen:

_P_COOKIES		EQU		$05a0.w
_SYSBASE		EQU		$04f2.w
_HZ_200			EQU		$04ba.w
_DRVBITS		EQU		$04c2.w

;--------------------------------------------------------------------------
; getcookie:	Funktion zum Suchen nach einem bestimmten Cookie im
;				Cookie Jar.
;
;	->	d0:	- 32 Bit Wert des zu suchenden Cookies;
;		a0: - Zeiger auf Variable fr den gefundenen Wert des Cookies
;	<-	d0:	- TRUE wenn Cookie gefunden, sonst FALSE
getcookie:
		xdef		getcookie			; Funktion exportieren
		movem.l		a2/a3/d3, -(sp)		; Register retten
		
		movea.l		a0, a3				; Variablen retten
		move.l		d0, d3				;
		
		; Cookie Jar Adresse holen:		
		pea			.cookies(pc)		; Adresse der Funktion auf den Stack
		move.w		#$26, -(sp)			; Opcode fr Supexec (XBIOS 38)
		trap		#14					; XBIOS-Trap
		addq.l		#6, sp				; Stack restaurieren
		
		tst.l		d0					; ist berhaupt ein Cookie Jar vorhanden?
		beq.b		.end				; wenn nicht, dann zurck
		
		movea.l		d0, a0				; Adresse speichern
		moveq		#0, d0				; erstmal auf FALSE setzen
		
.loop:
		move.l		(a0)+, d1			; Wert des Cookies holen
		beq.b		.end				; Ende des Cookie Jars erreicht?
		
		cmp.l		d1, d3				; Cookie gefunden?
		beq.b		.found				; 
		
		addq.l		#4, a0				; n„chster Cookie
		bra.b		.loop				; Schleife
		
.found:
		move.l		(a0), (a3)			; Wert des Cookies holen
		moveq.l		#1, d0				; TRUE setzen
		
.end:
		movem.l		(sp)+, a2/a3/d3		;	Register restaurieren
		rts
		
.cookies:
		move.l		(_P_COOKIES), d0	; Zeiger auf den Cookie Jar
		rts								;

***-----------------------------------------------------------------------------
*** Funktionsname:	get_tos
***		->	nichts
***		<-	nichts
***
*** Die Funktion holt die TOS-Version ber den _sysbase-Vektor des Betriebs-
*** systems.
***
get_tos:
		xdef		get_tos				; Funktion exportieren
		
		pea			.get_tos(pc)		; aufzurufende Funktion
		move.w		#38, -(sp)			; Supexec (XBIOS 38)
		trap		#14					; XBIOS-Trap
		addq.l		#6, sp				; Stack aufr„umen
		
		rts								; und zurck

.get_tos:
		movea.l		(_SYSBASE), a0		; (_sysbase-Vektor)->OSHEADER-Struktur
		move.w		2(a0), d0			; TOS-Version sichern
		rts								; und zurck

***-----------------------------------------------------------------------------
*** Funktionsname:	has_drive_u
***		->	nichts
***		<-	TRUE wenn U: existiert, sonst FALSE
***
*** Die Funktion sieht unter der Adresse _DRVBITS nach, ob ein
*** Laufwerk U: existiert
***
has_drive_u:
		xdef		has_drive_u			; Funktion exportieren
		
		pea			.get_drvs(pc)		; aufzurufende Funktion
		move.w		#38, -(sp)			; Supexec (XBIOS 38)
		trap		#14					; XBIOS-Trap
		addq.l		#6, sp				; Stack aufr„umen
		
		btst.l		#20, d0				;
		sne			d0					; Laufwerk U: vorhanden?
		ext.w		d0					; 
		rts								;
		
.get_drvs:
		movea.l		#_DRVBITS, a0		; drvbits-Adresse
		move.l		(a0), d0			; und Inhalt zurckgeben
		rts								;

***-----------------------------------------------------------------------------
*** Funktionsname:	Calc200Hz, Get200Hz
***		->	nichts bzw. in d0 die einzustellende Zeit;
***		<-	d0:	Bisherige Anzahl der 200Hz-Interrupts bzw.
***				die Timerzahl, wann die Zeit verstrichen sein wird
***
*** Die Funktion holt die Anzahl der 200Hz-Interrupts aus der
*** Adresse $4ba (_hz_200-Vektor).
***
Calc200Hz:
		xdef		Calc200Hz			; Funktion exportieren
		
		add.l		d0, d0				; timer * 2
		move.l		d0, .len			; d0 retten
		
		bsr.b		Get200Hz			; 200Hz-Z„hler auslesen
		
		add.l		.len(pc), d0
		rts
		
.len:	dc.l	0
		
Get200Hz:
		xdef		Get200Hz			; Funktion exportieren
		
		pea			.get_timer(pc)		; Adresse der Funktion auf den Stack
		move.w		#$26, -(sp)			; Opcode fr Supexec (XBIOS 38)
		trap		#14					; XBIOS-Trap
		addq.l		#6, sp				; Stack restaurieren
		
		rts
		
.get_timer:
		move.l		(_HZ_200), d0		; Anzahl der Interrupts holen
		rts

*****************************************************************************

		.DATA
		.EVEN

*****************************************************************************

		.BSS
		.EVEN


		.END

