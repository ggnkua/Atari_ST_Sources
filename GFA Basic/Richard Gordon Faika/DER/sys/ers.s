		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#6,d1			; Bufferl„nge < 6
		blt.s	raus			; Raus!

		lea.l	magic(pc),a4	; magic nach a4 laden
		moveq	#5,d3			; schleifenz„hler
loop:
		cmp.b	(a4)+,(a1)+		; vergleichen
		bne.s	raus			; stimmt nicht -> raus
		dbf		d3,loop			; schliefenende
		
		moveq	#1,d0			; vielleicht erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4),(a3)		; eintragen
		
		lea.l	ext(pc),a4		; extension nach a4 laden
		cmp.l	(a4)+,(a2)+		; stimmt berein?
		bne.s	raus			; nein -> raus
		
		moveq	#2,d0			; ja, erkannt
		
raus:	rts
*********
ext:	dc.b	"ERS",0
magic:	dc.b	"Raster"
; ERS: ER Mapper-Files