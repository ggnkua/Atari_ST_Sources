			EXPORT get_oldest
			EXPORT search_cache
			EXPORT write_test, read_test
			EXPORT memcopy
;			EXPORT memfill
;			EXPORT memswap

			IMPORT cache_page, cache_age, cache_flags, age_count

;*********************************
;* LRU-Seite im Cache ermitteln: *
;*********************************
get_oldest:
			move.l	D3,-(SP)			; Register retten

			movea.l cache_age,A0		; Zeiger auf Age-Bytes
			lea		4(A0),A1			; Zeiger+4 merken
			move.l	A1,D0				; als Offset merken
			move.w	age_count,D3		; Anzahl der LRU-Age-LONGS
			subq.w	#1,D3				; minus 1 wegen DBRA
			moveq	#-1,D2				; maximales Alter setzen

loop3:		move.l	(A0)+,D1			; nÑchstes Age-Byte holen
			cmp.l	D1,D2				; aktuelles Alter < geringstes Alter
			bls.b	jump3				; nein !!
			move.l	D1,D2				; sonst Alter ersetzen
			move.l	A0,D0				; und Offset merken

jump3:		dbra	D3,loop3			; alle Age-Bytes prÅfen

			sub.l	A1,D0				; Index berechnen
			lsr.l	#2,D0				; durch 4 (wegen LONG)
			movem.l (SP)+,D3			; Register restaurieren
			rts

;********************************
;* Suchen einer Seite im Cache: *
;********************************
search_cache:
			movea.l	cache_page,A0		; Zeiger auf Cache-Seiten
			lea		2(A0),A1			; Zeiger+2 merken
loop5:		cmp.w	(A0)+,D0			; <vmempage> gefunden ?
			bne.b	loop5				; nein => weitersuchen
			move.l	A0,D0				; Index von <vmempage>
			sub.l	A1,D0				; in <cache_page> berechnen
			lsr.l	#1,D0
			rts

;********************************************
;* ZÑhlen der im Cache befindlichen Seiten: *
;********************************************
write_test:
			movea.l	cache_flags,A0		; Tabellenanfang
			adda.w	D0,A0				; + Offset
			clr.w	D0					; ZÑhler initialisieren
			subq.w	#1,D1				; - 1 wegen DBRA
loop4:		btst	#1,(A0)+			; Seite im Cache ?
			beq		jump1				; nein !!
			addq.w	#1,D0				; sonst zÑhlen
jump1:		dbra	D1,loop4
			rts

;**********************************************************
;* ZÑhlen der im Cache befindlichen und der neuen Seiten: *
;**********************************************************
read_test:
			movea.l	cache_flags,A0		; Tabellenanfang
			adda.w	D0,A0				; + Offset
			clr.w	D0					; ZÑhler initialisieren
			subq.w	#1,D1				; - 1 wegen DBRA
loop2:		move.b	(A0)+,D2
			btst	#1,D2				; Seite im Cache ?
			bne		jump5				; ja !!
			btst	#0,D2				; neue Seite ?
			bne		jump4				; nein !!
jump5:		addq.w	#1,D0				; sonst zÑhlen
jump4:		dbra	D1,loop2
			rts

.ifne 0

;***********************************
;* FÅllen eines Speicherbereiches: *
;***********************************
memfill:
			movem.l	D3-D7/A2-A6,-(SP)	; Register retten

			lsr.l	#8,d1				; Anzahl Bytes
			lsr.l	#2,d1				; geteilt durch 1024
			beq		mfjump1				; = 0, dann fertig

			move.w	d1,-(SP)			; ZÑhler auf Stack
			
			move.b	d0,d1				; FÅllwert (Byte)
			lsl.w	#8,d0				; in Long expandieren
			or.w	d1,d0
			move.w	d0,d1
			swap	d0
			move.w	d1,d0				; in Long expandieren

			move.l	d0,d1				; restliche Register initialisieren
			move.l	d0,d2
			move.l	d0,d3
			move.l	d0,d4
			move.l	d0,d5
			move.l	d0,d6
			move.l	d0,d7
			move.l	d0,a1
			move.l	d0,a2
			move.l	d0,a3
			move.l	d0,a4
			move.l	d0,a5
			move.l	d0,a6

			REPT 18
			movem.l	d0-d7/a1-a6,-(a0)	; 56 Bytes schreiben
			ENDM
			movem.l	d0-d3,-(a0)			; 16 Bytes schreiben
			
			subq.w	#1,(sp)				; ZÑhler verringern
			bne.b	mcloop1				; Ende erreicht ?

			addq.l	#2,SP				; Stack korrigieren
mfjump1:	movem.l	(SP)+,D3-D7/A2-A6	; Register restaurieren
			rts

.endif

;*****************************
;* Speicherbereich kopieren: *
;*****************************
memcopy:
			movem.l	D3-D7/A2-A6,-(SP)	; Register retten
			moveq	#10,d1
			lsr.l	d1,d0				; Anzahl in KByte
			move.w	d0,-(SP)			; ZÑhler auf Stack

mcloop1:
			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,(a0)	; und schreiben
			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,52(a0)	; und schreiben
			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,104(a0)	; und schreiben
			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,156(a0)	; und schreiben

			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,208(a0)	; und schreiben
			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,260(a0)	; und schreiben
			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,312(a0)	; und schreiben
			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,364(a0)	; und schreiben

			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,416(a0)	; und schreiben
			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,468(a0)	; und schreiben
			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,520(a0)	; und schreiben
			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,572(a0)	; und schreiben

			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,624(a0)	; und schreiben
			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,676(a0)	; und schreiben
			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,728(a0)	; und schreiben
			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,780(a0)	; und schreiben

			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,832(a0)	; und schreiben
			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,884(a0)	; und schreiben
			movem.l	(a1)+,d0-d7/a2-a6	; 52 Bytes holen
			movem.l	d0-d7/a2-a6,936(a0)	; und schreiben
			movem.l	(a1)+,d0-d7/a2		; 36 Bytes holen
			movem.l	d0-d7/a2,988(a0)	; und schreiben

			lea		1024(a0),a0			; Zeiger + 1024
			subq.w	#1,(sp)				; ZÑhler verringern
			bne		mcloop1				; Ende erreicht ?

			addq.l	#2,SP				; Stack korrigieren

			movem.l	(SP)+,D3-D7/A2-A6	; Register restaurieren
			rts

.ifne 0

;*********************************
;* Speicherbereiche vertauschen: *
;*********************************
memswap:
			movem.l	D3-D7/A2-A6,-(SP)	; Register retten
			moveq	#9,d1
			lsr.l	d1,d0				; Anzahl in 512 Byte-Blîcken
			subq.w	#1,d0				; - 1 wegen DBRA

msloop1:
			REPT 21
			movem.l	(a1)+,d1-d6			; 24 Bytes holen (A)
			movem.l	(a0)+,d7/a2-a6		; 24 Bytes holen (B)
			movem.l	d7/a2-a6,-24(a1)	; 24 Bytes schreiben (B)
			movem.l	d1-d6,-24(a0)		; 24 Bytes schreiben (A)
			ENDM

			move.l	(a1),d1				; noch 8 Bytes vertauschen
			move.l	(a1),d2
			move.l	(a0),(a1)+
			move.l	(a0),(a1)+
			move.l	d1,(a0)+
			move.l	d2,(a0)+

			dbra	d0,msloop1			; ZÑhler verringern

			movem.l	(SP)+,D3-D7/A2-A6	; Register restaurieren
			rts

.endif
