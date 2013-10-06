

		text


; ---------------------------------------------------------
; 06.02.00/vk
; aktiviert den algorithmus a2.
; globales flag ist c3pmode.
; speichergroesse:  bytes = anzahl strahlen * max. strahleintraege * strahleintraggroesse
;                           + 4 * anzahl strahlen         (pointer auf jeden strahl)
;                           + 2 * anzahl strahlen         (anzahl eintraege fuer jeden strahl)
;                           + 3 * 4                       (3 pointer auf die einzelnen bereiche)
; rueckgabe: d0 =  0 (erfolgreich)
;                  1 (bereits aktiviert)
;                 -1 (kein speicher mehr frei)
a2Install
		tst.w	c3pMode					; schon aktiviert?
		beq.s	a2InstallOk				; nein -> dann weiter
		moveq	#1,d0					; rueckgabewert setzen
		bra.s	a2InstallOut				; und raus
a2InstallOk

	; vertikaler ray buffer

		move.w	#%11,d0					; egal, tt-ram bevorzugt
		move.w	#C3PMAXX,d1
		move.w	d1,d2
		mulu.w	#A2RAYBUFFERVMAX*A2RAYBUFFERVBYTES,d1
		mulu.w	#6,d2
		add.l	d2,d1
		addi.l	#3*4,d1
		bsr	allocateMemory				; (d0/d1) speicher fuer vertikalen strahlenbuffer holen

		tst.l	d0
		beq.s	a2InstallMemoryVNoMemory
		bra.s	a2InstallMemoryVOk

a2InstallMemoryVNoMemory
		lea	a2InstallErrorMessage,a0
		bsr	installMessage
		moveq	#-1,d0
		bra.s	a2InstallOut

a2InstallMemoryVOk
		move.l	d0,a2RayBufferVPtr

		bsr	a2RebuildRayBufferDataStructures	; interne datenstrukturen fuer ray buffer aufbauen

		lea	a2InstallMessage,a0
		bsr	installMessage

		move.w	#1,c3pMode
		moveq	#0,d0
a2InstallOut
		rts


; ---------------------------------------------------------
; 06.02.00/vk
; deaktiviert den algorithmus a2.
; globales flag ist c3pmode.
a2Deinstall
		tst.w	c3pMode					; flag fuer aktiven a2-algorithmus
		beq.s	a2DeinstallOut				; nicht aktiviert -> dann verzweigen und raus

		movea.l	a2RayBufferVPtr,a0
		bsr	freeMemory				; allokierten speicher wieder freigeben

		lea	a2DeinstallMessage,a0
		bsr	installMessage

		clr.w	c3pMode
a2DeinstallOut
		rts


; ---------------------------------------------------------
; 06.01.00/vk
; interne datenstrukturen im allokierten speicherblock aufbauen,
; sowohl fuer vertikalen als auch horizontalen ray buffer.
a2RebuildRayBufferDataStructures

		bsr.s	a2rrbdsVertical			; fuer vertikalen
;		bsr.s	a2rrbdsHorizontal		; fuer horizontalen

		rts


; ---------------------------------------------------------
; 06.01.00/vk
; interne datenstrukturen im allokierten speicherblock aufbauen
; fuer vertikalen ray buffer.
a2rrbdsVertical

		movea.l	a2RayBufferVPtr,a0
		move.w	#C3PMAXX,d0
		move.w	#A2RAYBUFFERVBYTES*A2RAYBUFFERVMAX,d1
		bsr.s	a2rrbdsNow

		rts


; ---------------------------------------------------------
; 06.01.00/vk
; interne datenstruktur fuer ray buffer aufbauen.
; d0 = anzahl strahlen
; d1 = benoetigte bytes pro strahl
; a0 = allokierter speicherbereich
a2rrbdsNow

;        0.l	pointer auf eigentlichen ray buffer speicherblock
;        4.l	pointer auf array mit pointern auf einzelne ray buffer strahlen
;        8.l	pointer auf array mit anzahl an eintraegen fuer einzelne ray buffer strahlen
;       12.l    (array1) array mit pointern auf einzelne ray buffer strahlen
;        x.l    (array2) array mit anzahl an eintraegen fuer einzelne ray buffer strahlen
;        x.l	(array3) ray buffer speicherblock

	; groessenberechnung von array1 (in d6) und array2 (in d7)

		move.w	d0,d6
		lsl.w	#2,d6
		ext.l	d6

		move.w	d0,d7
		add.w	d7,d7
		ext.l	d7

	; erzeugen der ersten drei pointer auf die arrays

		lea	12(a0),a1
		move.l	a1,A2RAYBUFFERPTR(a0)

		adda.l	d6,a1
		move.l	a1,A2RAYBUFFERNBPTR(a0)

		adda.l	d7,a1
		move.l	a1,A2RAYBUFFER(a0)

	; array1 erzeugen

		movea.l	A2RAYBUFFERPTR(a0),a1
		movea.l	A2RAYBUFFER(a0),a2
		ext.l	d1
		move.w	d0,d7
		subq.w	#1,d7
a2rrbdsnA1Loop
		move.l	a2,(a1)+
		adda.l	d1,a2
		dbra	d7,a2rrbdsnA1Loop

	; array2 loeschen

		movea.l	A2RAYBUFFERNBPTR(a0),a1
		move.w	d0,d7
		subq.w	#1,d7
a2rrbdsnA2Loop
		clr.w	(a1)+
		dbra	d7,a2rrbdsnA2Loop

		rts






		data

			ifeq LANGUAGE
a2InstallMessage	dc.b	"Algorithm A-2 activated",0
a2InstallErrorMessage	dc.b	"Error initializing algorithm A-2",0
a2DeinstallMessage	dc.b	"Algorithm A-2 deactivated",0
			else
a2InstallMessage	dc.b	"Algorithmus A-2 aktiviert",0
a2InstallErrorMessage	dc.b	"Initialisierungsfehler von A-2",0
a2DeinstallMessage	dc.b	"Algorithmus A-2 deaktiviert",0
			endc


		bss


