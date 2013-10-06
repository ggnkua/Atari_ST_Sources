
;**************************************
;* calc_invisible_items
;**************************************

; geht das array mit den items durch, die
; aktuell nicht sichtbar sind und auf ihr
; "wiedererscheinen" warten.
; herabzaehlen des counters.
; evtl. sichtbarmachen durch midi-kommando.

calc_invisible_items

		lea	inv_items_flag,a0
		lea	inv_items_data,a1
		moveq	#inv_items_max-1,d7

cii_loop
		tst.b	(a0,d7.w)		; item vorhanden?
		beq.s	cii_skip		; nein -> ueberspringen
		move.w	vbl_time,d6		; vergangene zeit holen
		sub.w	d6,2(a1,d7.w*4)		; counter herabzaehlen
		bpl.s	cii_skip		; positiv -> ueberspringen
		clr.b	(a0,d7.w)		; flag loeschen
		move.b	(a1,d7.w*4),d0		; sektor und...
		move.b	1(a1,d7.w*4),d1		; ...item holen
		movem.l	d7/a0-a1,-(sp)
		bsr	mp_send_25all		; kommando an alle (auch an diesen rechner selbst) schicken
		movem.l	(sp)+,d7/a0-a1
cii_skip	dbra	d7,cii_loop		; naechstes item

		rts


;**************************************
;* add_invisible_item
;**************************************

; fuegt ein item dem array hinzu

; d0.b = sektor
; d1.b = item
; d2.w = counter

add_invisible_item

		lea	inv_items_flag,a0	; zeiger auf flags
		lea	inv_items_data,a1	; zeiger auf datas
		moveq	#inv_items_max-1,d7	; gesamtgroesse array
aii_loop
		tst.b	(a0,d7.w)		; item vorhanden in diesem slot?
		beq.s	aii_found_free		; nein -> dann hier eben eintragen
		dbra	d7,aii_loop		; naechster slot

		moveq	#inv_items_max-1,d7	; kein slot frei -> ersten slot hernehmen
		movem.l	d0-d2/a0-a1,-(sp)	; bisherigen gegenstand sichtbar machen
		move.b	(a1,d7.w*4),d0		; sektor und...
		move.b	1(a1,d7.w*4),d1		; ...item holen
		bsr	mp_send_25all		; kommando an alle (auch an diesen rechner selbst) schicken
		movem.l	(sp)+,d0-d2/a0-a1

aii_found_free
		move.b	#1,(a0,d7.w)
		move.b	d0,(a1,d7.w*4)
		move.b	d1,1(a1,d7.w*4)
		move.w	d2,2(a1,d7.w*4)

aii_out
		rts