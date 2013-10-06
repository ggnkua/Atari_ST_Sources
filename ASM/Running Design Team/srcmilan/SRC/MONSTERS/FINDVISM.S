
FVMSECTORSMAX		equ	64		; gleichzeitig sichtbare/berechenbare sektoren



		text


; ---------------------------------------------------------
; 12.06.00/vk
; bestimmt die sichtbaren gegner und traegt deren pointer in
; ein temp. array ein.
findVisibleMonsters

		lea	fvmSectors,a0				; zwischenspeicher/array fuer sichtbare sektoren holen (wird jetzt gefuellt)

		movea.l	levelPtr,a6
		movea.l	playerDataPtr,a4
		move.w	PDCURRENTSECTOR(a4),d0
		move.w	d0,(a0)+				; der aktuelle sektor ist natuerlich auch sichtbar
		movea.l	LEVSECSTART(a6,d0.w*4),a3
		adda.l	a6,a3					; relativen pointer zu absolutem machen
		adda.w	#SECEXTLINES,a3

		moveq	#0,d7
fvmFindSecLoop	addq.w	#1,d7					; counter auf tatsaechliche anzahl anpassen
		cmpi.w	#FVMSECTORSMAX,d7			; arraygrenze ueberschritten?
		bgt.s	fvmFindOut				; ja -> dann keine weiteren sektoren mehr eintragen
		move.w	(a3)+,(a0)+				; sektor eintragen
		bpl.s	fvmFindSecLoop
fvmFindOut	subq.w	#1,d7					; fuer dbra

		lea	fvmSectors,a0

		movea.l	LEVMONSTERS(a6),a1
		adda.l	a6,a1
		movea.l	MONDAT(a1),a1
		adda.l	a6,a1

		movea.l	monBufferPtr,a4

		moveq	#0,d5
fvmLoop
		move.l	(a1)+,d0				; naechster pointer auf ein monster
		bmi.s	fvmEndOfArray				; ende schon erreicht?

		movea.l	d0,a2					; aus relativem pointer wieder ...
		adda.l	a6,a2					; ... einen absoluten machen ...
		move.w	MONSEC(a2),d1				; ... und den aktuellen sektor des gegner holen

		movea.l	a0,a3					; anfang von array fvmsectors
		move.w	d7,d6					; inkl. arraygrosse (schon fuer dbra angepasst)
fvmFindLoop	cmp.w	(a3)+,d1
		beq.s	fvmMonVisible
		dbra	d6,fvmFindLoop
		bra.s	fvmLoop
fvmMonVisible
		move.l	a2,(a4)+				; (absoluten) gegnerpointer eintragen
		addq.w	#1,d5
		bra.s	fvmLoop

fvmEndOfArray
		subq.w	#1,d5
		move.w	d5,monBufferNb

		rts




		data




		bss

fvmSectors	ds.w	FVMSECTORSMAX

