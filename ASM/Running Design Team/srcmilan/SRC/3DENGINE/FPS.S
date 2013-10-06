
FPSDECIMALPOSFACTOR	equ	1000
FPSDECIMALPOS		equ	3		; FPSDECIMALPOSFACTOR = 10 ^ FPSDECIMALPOS
FPSNUMERALSTODRAW	equ	4
FPSNUMERALSDRAWFROM	equ	0


		text


; ---------------------------------------------------------
; 21.05.00/vk
; zeigt die berechneten bilder pro sekunde im logischen
; screen an
calcVblTimes

		bsr	getVSyncCounter		; aktuellen vsync-counter nach d0
		lea	fpsLast,a0
		move.l	(a0),d1			; vsync-counter vom letzten durchlauf holen
		move.l	d0,(a0)			; aktuellen vsync-counter wieder abspeichern
		sub.l	d1,d0			; differenz bilden, kann evtl. 0 sein

	; da sich der vsync-counter auf 50 hz bildschirme bezieht, bedeutet eine differenz von
	; 50 auch eine zeitspanne von 1 sek.

		move.w	d0,vblTime		; vbltime: anzahl vbls fuer letzten durchlauf (auf 50 vbls/sek. bezogen)
		mulu.w	#20,d0
		move.w	d0,vblTime1000		; vbltime1000: anzahl vbls fuer letzten durchlauf (auf 1000 vbls/sek. bezogen)

		divu.w	#20,d0			; die 1000 vbls/sek. wieder auf 20 vbls/sek. beziehen
		tst.w	d0			; dies entspricht der "normalen" wiederholfrequenz von 50 vbls
		bne.s	cvtVbl20Ok		; ergebnis null? 
		moveq	#1,d0			; ja -> dann fest auf 1 setzen (darf nicht null sein)
cvtVbl20Ok	move.w	d0,vblTime20

		rts


; ---------------------------------------------------------
; 21.05.00/vk
; gibt in d0 den aktuellen vsync-counter zurueck
getVSyncCounter
		move.l	$466.l,d0
		rts


; ---------------------------------------------------------
; 21.05.00/vk
; berechnet die fps kennzahl und zeichnet diese auf den
; logischen screen.
drawFramesPerSecond

		move.l	#1000*FPSDECIMALPOSFACTOR,d0
		divu.w	vblTime1000,d0

		lea	b2aAsciiArray,a0
		bsr	bin2Ascii16			; d0 in ascii ziffern umwandeln

		moveq	#4,d0
		lea	dfpsAsciiArray,a1

dfpsConvertLoop	move.w	d0,d2
		addq.w	#1,d2
		cmpi.w	#FPSDECIMALPOS,d2
		bne.s	dfpsclNoPoint
		move.b	#".",(a1)+
dfpsclNoPoint	move.b	(a0)+,(a1)+
		dbra	d0,dfpsConvertLoop
		
		moveq	#FPSNUMERALSTODRAW,d0
		lea	dfpsAsciiArray+FPSNUMERALSDRAWFROM,a0
		movea.l	screen3d,a1
		move.w	lineoffset,d1
		add.w	d1,d1
		addq.w	#4,d1
		adda.w	d1,a1
		bsr	fpsDrawNumerals

		rts


; ---------------------------------------------------------
; 21.05.00/vk
; d0 = anzahl ziffern
; a0 = ascii array
; a1 = screen position
fpsDrawNumerals
		subq.w	#1,d0
fpsdnLoop
		move.b	(a0)+,d1
		cmpi.b	#".",d1
		beq.s	fpsdnIsPoint

		cmpi.b	#"0",d1
		blt.s	fpsdnLeaveSpace
		beq.s	fpsdnIsZero

		cmpi.b	#"9",d1
		bgt.s	fpsdnLeaveSpace

		subi.b	#"1",d1
		andi.w	#$00ff,d1
		bra.s	fpsdnDrawNow

fpsdnIsZero	move.w	#9,d1
		bra.s	fpsdnDrawNow

fpsdnIsPoint	move.w	#10,d1

fpsdnDrawNow
		movea.l	a1,a2
		moveq	#6,d2
		lea	fpsBitmap,a3
		mulu.w	#14,d1
		adda.l	d1,a3
fpsdndnLoop
		movem.w	(a3),d1/d3-d7/a4
		movem.w	d1/d3-d7/a4,(a2)

		adda.w	#77*2,a3
		adda.w	lineoffset,a2

		dbra	d2,fpsdndnLoop

fpsdnLeaveSpace
		adda.w	#16,a1
		dbra	d0,fpsdnLoop

		rts


; ---------------------------------------------------------
; 21.05.00/vk
; falls das flag fpsmode zur anzeige der fps gesetzt ist,
; wird die fps kennzahl berechnet und gezeichnet.
; aufruf direkt aus main() heraus.
drawFramesPerSecondIfRequired

		tst.w	fpsMode
		beq.s	dfpsirOut

		bsr	drawFramesPerSecond
dfpsirOut
		rts




		data

fpsBitmap	incbin	"include\fps\fps.rbf"

fpsMode		dc.w	0				; 0 = ausgeschaltet, 1 = sichtbar




		bss

dfpsAsciiArray	ds.b	16

fpsLast		ds.l	1
