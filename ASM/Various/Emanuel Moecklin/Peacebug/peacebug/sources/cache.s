*-------------------------------------------------------------------------------
* CACHE_INIT: l”scht oder addiert eine Anzahl Cacherecords
* ---> 4(SP).w = Anzahl Cacheeintr„ge Cache 2 oder 0 (no change)
* ---> 6(SP).w = Anzahl Cacheeintr„ge Cache 1 oder 0 (no change)
* <--- 4(SP).l = 0 = Fehler bei Malloc, != 0 = alles io
*
* CACHE_UP: Cache einen Eintrag nach "oben" setzen. SAVE_IT wird gesetzt.
*
* CACHE_DOWN: Cache einen Eintrag nach "unten" setzen. SAVE_IT wird gesetzt.
*
* CACHE_NEXT: Cache um einen Eintrag weiter setzen. SAVE_IT wird NICHT gesetzt.
*
* CACHE_WEG: Cache auf den ersten Eintrag setzen. SAVE_IT wird gesetzt.
*
* CACHE_GET: Aktuellen Cacheeintrag holen (nach SAVE_IT kopieren).
*
* CACHE_PUT: Aktuellen Cacheeintrag schreiben (von SAVE_IT kopieren).
*
* CACHE_TEST: Testet ob der aktuelle Cache auf den nullten Eintrag zeigt.
* <--- d3.l = Nummer des aktuellen Eintrags
* <--- flag.eq = nullter Eintrag, flag.ne = nicht nullter Eintrag
*-------------------------------------------------------------------------------

		.EXPORT		CACHE_INIT,CACHE_UP,CACHE_DOWN
		.EXPORT		CACHE_GET,CACHE_PUT,CACHE_NEXT,CACHE_TEST,CACHE_WEG
		.EXPORT		CACHE_ZAEHLER_1,CACHE_ZAEHLER_2,CACHE_FLAG

		.INCLUDE	'EQU.S'

*-------------------------------------------------------------------------------

CACHE_ZAEHLER_1:	ds.w	1
CACHE_ZAEHLER_2:	ds.w	1
CACHE_FLAG:			ds.b	1					; 0 = Cache 1, -1 = Cache 2
		.EVEN

*-------------------------------------------------------------------------------

CACHE_INIT:		movem.l		d0-a6,-(sp)
				move.w		CACHE_LENGTH,d7		; Anzahl Bytes je Eintrag

				lea			66(sp),a0
				lea			CACHE_LAENGE_1,a1
				bsr.s		.INIT_CACHE
				beq.s		.CACHE_FAIL
				lea			64(sp),a0
				lea			CACHE_LAENGE_2,a1
				bsr.s		.INIT_CACHE
				beq.s		.CACHE_FAIL
				moveq		#-1,d0
				move.l		d0,64(sp)			; Rckgabewert -1
				bra.s		.ende
.CACHE_FAIL:	clr.l		64(sp)				; Rckgabewert 0
.ende:			movem.l		(sp)+,d0-a6
				rts

*---------------

.INIT_CACHE:	moveq		#0,d1
				move.w		(a0),d1
				beq.s		.CACHE_UNCHANGE
				moveq		#0,d2
				move.w		(a1),d2
				sub.l		d2,d1
				ble.s		.CACHE_SUB

				move.w		d1,d2
				mulu		d7,d2
				move.l		d2,-(sp)
				jsr			MALLOC
				beq.s		.CACHE_ERROR

				movea.l		d0,a2
				lea			-8(a2,d7.w),a2		; First Record
				movea.l		a2,a3
				movea.l		a3,a5
				subq.w		#1,d1
				bra.s		.INIT_EINSTIEG
.INIT_LOOP:		lea			(a3,d7.w),a5
				move.l		a5,(a3)				; NEXT in n
				move.l		a3,4(a5)			; PREVIOUS in n+1
				adda.w		d7,a3
.INIT_EINSTIEG:	dbra		d1,.INIT_LOOP

				tst.w		(a1)
				beq.s		.NEW_CACHE
				movea.l		-4(a1),a3			; Cachepointer
				movea.l		(a3),a6				; Next Record
				move.l		a2,(a3)
				move.l		a3,4(a2)
				move.l		a6,(a5)
				move.l		a5,4(a6)
				bra.s		.CACHE_OK

*---------------

.NEW_CACHE:		move.l		a2,-4(a1)			; Cachepointer eintragen
				move.l		a2,(a5)				; Kreis schliessen
				move.l		a5,4(a2)
				bra.s		.CACHE_OK

.CACHE_SUB:		movea.l		-4(a1),a2			; Cachepointer
				movea.l		(a2),a2				; Next_record
				neg.w		d1
				bra.s		.NEW_ENTRY
.NEW_LOOP:		movea.l		4(a2),a3			; Previous Record
				movea.l		(a2),a2				; Next Record
				move.l		a2,(a3)
				move.l		a3,4(a2)
.NEW_ENTRY:		dbra		d1,.NEW_LOOP

.CACHE_OK:		move.w		(a0),(a1)
.CACHE_UNCHANGE:moveq		#-1,d0
				rts
.CACHE_ERROR:	moveq		#0,d0
				rts

*-------------------------------------------------------------------------------

CACHE_TEST:		movem.l		a0-a1,-(sp)
				bsr.s		CACHE_VAR
				moveq		#0,d3
				move.w		(a1),d3
				movem.l		(sp)+,a0-a1
				rts

*-------------------------------------------------------------------------------

* CACHE_VAR: aktuellen Cache bestimmen
* <--- a0 = *CACHE_POINTER_x	Zeiger auf aktuellen Eintrag
* <--- a1 = *CACHE_ZAEHLER_x	aktueller Eintrag (0...)
CACHE_VAR:		tst.b		CACHE_FLAG			; Cache 1 oder Cache 2?
				beq.s		.cache_1
				lea			CACHE_POINTER_2,a0
				lea			CACHE_ZAEHLER_2,a1
				rts
.cache_1:		lea			CACHE_POINTER_1,a0
				lea			CACHE_ZAEHLER_1,a1
				rts

*-------------------------------------------------------------------------------

CACHE_WEG:		movem.l		d0/a0-a1,-(sp)
				bsr			CACHE_PUT			; von SAVE_IT kopieren
				bsr.s		CACHE_VAR
				move.w		(a1),d0				; aktuelle Eintragsnummer
				clr.w		(a1)				; Eintrag 0 wird aktuell
				movea.l		(a0),a1				; Zeiger auf Eintrag
				bra.s		.entry
.loop:			movea.l		(a1),a1				; n„chster Eintrag
.entry:			dbra		d0,.loop
				move.l		a1,(a0)				; aktuellen Eintrag schreiben
				bsr.s		CACHE_GET			; nach SAVE_IT kopieren
				jsr			PRINT_REGISTER
				movem.l		(sp)+,d0/a0-a1
				rts

*-------------------------------------------------------------------------------

CACHE_UP:		movem.l		d0/a0-a1,-(sp)
				bsr			CACHE_PUT			; von SAVE_IT kopieren
				bsr			CACHE_VAR
				move.w		(a1),d0				; Eintragsnummer
				addq.w		#1,d0				; erh”hen
				cmp.w		4(a0),d0			; CACHE_LAENGE_1 (Interfave)
				bhs.s		.ende				; letzter Eintrag?
				move.w		d0,(a1)				; nein, dann schreiben
				movea.l		(a0),a1				; und vorherigen Eintrag
				move.l		4(a1),(a0)			; setzen
				st			OPCODE
				bsr.s		CACHE_GET			; nach SAVE_IT kopieren
				jsr			PRINT_REGISTER
.ende:			movem.l		(sp)+,d0/a0-a1
				rts

*-------------------------------------------------------------------------------

CACHE_DOWN:		movem.l		d0/a0-a1,-(sp)
				bsr.s		CACHE_PUT			; von SAVE_IT kopieren
				bsr			CACHE_VAR
				tst.w		(a1)				; Eintragsnummer testen
				beq.s		.ende
				subq.w		#1,(a1)				; um eins erniedrigen
				movea.l		(a0),a1				; und n„chsten Eintrag
				move.l		(a1),(a0)			; setzen
				st			OPCODE
				bsr.s		CACHE_GET			; nach SAVE_IT kopieren
				jsr			PRINT_REGISTER
.ende:			movem.l		(sp)+,d0/a0-a1
				rts

*-------------------------------------------------------------------------------

CACHE_GET:		movem.l		d0/a0-a1,-(sp)
				bsr			CACHE_VAR
				move.l		(a0),a0
				lea			-CACHE_LAENGE+8(a0),a0
				lea			SAVE_IT,a1
				move.w		#CACHE_LAENGE-9,d0
.loop:			move.b		(a0)+,(a1)+
				dbra		d0,.loop
				jsr			GET_SP
				jsr			SET_PC
				movem.l		(sp)+,d0/a0-a1
				rts

*-------------------------------------------------------------------------------

CACHE_PUT:		movem.l		d0/a0-a1,-(sp)
				bsr			CACHE_VAR
				movea.l		(a0),a0
				lea			-CACHE_LAENGE+8(a0),a0
				lea			SAVE_IT,a1
				move.w		#CACHE_LAENGE-9,d0
.loop:			move.b		(a1)+,(a0)+
				dbra		d0,.loop
				movem.l		(sp)+,d0/a0-a1
				rts

*-------------------------------------------------------------------------------

CACHE_NEXT:		movem.l		a0-a1,-(sp)
				bsr			CACHE_VAR
				movea.l		(a0),a1				; n„chsten Eintrag setzen
				move.l		(a1),(a0)
				movem.l		(sp)+,a0-a1
				rts
