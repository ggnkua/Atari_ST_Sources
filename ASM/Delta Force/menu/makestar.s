; erzeugt Zufallstabelle mit x und y Werten

anzahl=320

s:		lea	startab(pc),a6
		moveq	#0,d7			; Z„hler
starloop0:	bsr	random
		and.w	#$3ff,d0
		sub.w	#$200,d0
		move.w	d0,d5			; x
		bsr	random
		and.w	#$3ff,d0
		sub.w	#$200,d0
		move.w	d0,d6			; y

		move.w	d7,d4
		subq.w	#1,d4			; Z„hlwert
		bmi.s	nixcheckstars		; abchecken auf
		lea	startab(pc),a5		; gleiche Koordinaten
checkkoord:	cmp.w	(a5)+,d5
		bne.s	ungleich
		cmp.w	(a5)+,d6
		beq.s	starloop0		; beide gleich->nochmal
ungleich:	dbra	d4,checkkoord
nixcheckstars:	move.w	d5,(a6)+		; Koord. speichern
		move.w	d6,(a6)+		
		addq.w	#1,d7			; Z„hler erh”hen
		cmp.w	#anzahl,d7
		bne.s	starloop0
		rts	
		

random:		movem.l	d1-d3/a0-a3,-(a7)
		move.w	#17,-(a7)
		trap	#14
		addq.l	#2,a7
		movem.l	(a7)+,d1-d3/a0-a3
		rts

startab:	blk.l	anzahl
