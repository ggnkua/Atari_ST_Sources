		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; BufferlÑnge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; DateilÑnge
		move.l	20(sp),a3		; fÅr RÅckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#6,d1			; BufferlÑnge < 6
		blt.s	raus			; Raus!

		lea.l	magic1(pc),a4	; magic nach a4 laden
		moveq	#5,d3			; schleifenzÑhler
		move.l	a1,a5
loop:
		cmp.b	(a4)+,(a5)+		; vergleichen
		bne.s	weiter			; stimmt nicht -> weiter
		dbf		d3,loop			; schliefenende
		bra.s	ja
weiter:
		lea.l	magic2(pc),a4
		moveq	#5,d3
loop2:
		cmp.b	(a4)+,(a1)+
		bne.s	raus
		dbf		d3,loop2
		
ja:
		moveq	#2,d0			; erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4),(a3)		; eintragen
		
raus:	rts
*********
ext:	dc.b	"GIF",0
magic1:	dc.b	"GIF87a"
magic2:	dc.b	"GIF89a"
; GIF: Graphics Interchange-Format