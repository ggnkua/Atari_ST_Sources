		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; BufferlÑnge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; DateilÑnge
		move.l	20(sp),a3		; fÅr RÅckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#80,d1			; BufferlÑnge < 80
		blt.s	raus			; Raus!

		lea.l	magic(pc),a4	; magic nach a4 laden
		move.b	(a4),d3			; 1te byte nach d3
		move.l	a1,a5			; adresse a1 nach a5 kopieren
		
		move.l	#79,d4			; schleifenzÑhler
loop:
		move.b	(a5),d5			; byte (a5) nach d5
		cmp.b	d3,d5			; vergleiche
		addq	#1,a5			; a5 +1
		beq.s	weiter			; gefunden? dann weiter:
		dbf		d4,loop			; schleifenende
		bra.s	raus			; noch nicht gefunden -> raus
weiter:
		addq	#1,a4			; a4 +1
		move.l	#8,d3			; schleifenzÑhler
loop2:
		cmp.b	(a4)+,(a5)+		; vergleichen
		bne.s	raus			; nicht gleich -> raus
		dbf		d3,loop2		; schleifenende
		
		moveq	#2,d0			; erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4)+,(a3)+		; eintragen
		move.l	(a4),(a3)
		
raus:	rts
*********
ext:	dc.b	"IBG IMQ",0
magic:	dc.b	"SFDU_LABEL"
; IBG: NASA PDS File-Format