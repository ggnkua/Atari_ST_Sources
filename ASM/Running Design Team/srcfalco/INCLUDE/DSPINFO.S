;**************************************
;* dsp_info_auswerten
;**************************************

dsp_info_ausw

		lea	shooted_mon,a0		; pointer auf zurueckgelieferte dsp-daten
		moveq	#23,d3			; bit 23 festsetzen

	ifeq midiplay

	; (1) standard-gegner

		move.w	mon_buf1_anz,d7		; anzahl standard-gegner holen
		bmi	dia_standard_out	; negativ -> keine vorhanden -> ueberspringen
		movea.l	mon_buf1_ptr,a1		; pointer auf gegner-pointer
dia_std_loop
		movea.l	(a1)+,a2		; a2 = pointer monster
		move.l	(a0)+,d1		; d1 = dsp_info
		btst	d3,d1			; wurde gegner getroffen?
		beq.s	dia_std_no_hit		; nein -> ueberspringen
		movem.l	d3/d7/a0-a1,-(sp)
		bsr	mon_is_hit		; routine fuer einzelnen gegner
		movem.l	(sp)+,d3/d7/a0-a1
dia_std_no_hit
		dbra	d7,dia_std_loop

dia_standard_out

	else

	; (2) midi-gegner

	; d3/a0 sind bereits initialisiert bzw. zeigen auf
	; die midi-daten

		move.w	mmon_buf1_anz,d7	; anzahl midi-gegner holen
		bmi	dia_midi_out		; negativ -> keine vorhanden -> ueberspringen
		movea.l	mmon_buf1_ptr,a1	; pointer auf midi-gegner
dia_midi_loop
		movea.l	(a1)+,a2		; a2 = pointer monster
		move.l	(a0)+,d1		; d1 = dsp_info
		btst	d3,d1			; wurde gegner getroffen?
		beq.s	dia_midi_skip		; nein -> ueberspringen
		movem.l	d3/d7/a0-a1,-(sp)
		bsr	mon_is_hit_midi
		movem.l	(sp)+,d3/d7/a0-a1
dia_midi_skip
		dbra	d7,dia_midi_loop
dia_midi_out

	endc

	; (3) speicherbereiche austauschen

	ifeq midiplay

		lea	mon_buf1_ptr,a2
		movem.l	(a2),a0-a1
		exg	a0,a1
		movem.l	a0-a1,(a2)

		lea	mon_buf1_anz,a2
		movem.w	(a2),d0-d1
		exg	d0,d1
		movem.w	d0-d1,(a2)

	else

		lea	mmon_buf1_ptr,a2
		movem.l	(a2),a0-a1
		exg	a0,a1
		movem.l	a0-a1,(a2)

		lea	mmon_buf1_anz,a2
		movem.w	(a2),d0-d1
		exg	d0,d1
		movem.w	d0-d1,(a2)

	endc

		rts


;**************************************
;* mon_is_hit
;**************************************

; routine zieht dem monster entsprechend
; dem munitionstyp ( -1 = staerke mun0 ) energie
; ab, spielt zugeh”rige samples ab und
; steuert die animationsphasen ...

; a2: pointer monster
; alle register frei ...


mon_is_hit

	; -----------------------------
	; (1) auf zivilisten ueberpruefen

		move.w	mon_zivilist(a2),d0	; ist gegner ein zivilist?
		bmi.s	mih_no_civilian		; nein -> teil ueberspringen

		tst.w	mon_a_died(a2)		; zivilist schon tot?
		bne.s	mih_no_civilian		; ja -> teil ueberspringen

		move.l	a2,-(sp)		; gegnerpointer retten
		lea	sm_civilian,a0		; meldung
		bsr	install_message		; ausgeben
		lea	civilian_staerke_tab,a0	; staerketabelle zivilisten
		move.w	(a0,d0.w*2),d1		; realen wert holen (d0 = mon_zivilist(a2))
		lsl.w	#8,d1			; auf oberes byte bringen
		jsr	pd_health_minimieren	; und dem spieler energie abziehen
		movea.l	(sp)+,a2		; gegnerpointer zurueckschreiben
mih_no_civilian

	; -----------------------------
	; (2) dem gegner energie abziehen

		move.w	mon_health(a2),d0	; gegnerenergie holen
		movea.l	play_dat_ptr,a6
		move.w	pd_mun_type(a6),d1	; munitionstyp
		lea	player_staerke_tab,a6
		sub.w	(a6,d1.w*2),d0		; energie abziehen
		bpl	mih_only_health		; noch positiv -> es bleibt beim energie abziehen

		tst.w	mon_a_died(a2)		; ist gegner bereits tot?
		bne	mih_out			; ja -> ueberspringen

		clr.w	mon_health(a2)		; flags setzen, damit gegner
		clr.w	mon_a_hit(a2)		; jetzt tatsaechlich stirbt
		move.w	#1,mon_a_died(a2)

	; -----------------------------
	; (3) liegengelassener gegenstand

		move.l	mon_thing_typ(a2),d0	; soll gegenstand liegengelassen werden?
		beq.s	mih_no_thing		; nein -> ueberspringen

		movem.l	mon_line(a2),d1-d2	; x-/y-koordinate
		moveq	#$60,d3
		add.l	d3,d1			; koordinate etwas
		add.l	d3,d2			; korrigieren ...
		move.b	mon_line+11(a2),d3	; hoehe

		movea.l	d0,a1			; a1 = gegenstand

		movem.l	d1-d2,thing_line(a1)
		move.b	d3,thing_line+11(a1)		; h1
		add.b	d3,thing_line+15(a1)		; h2
mih_no_thing

	; -----------------------------

		move.w	mon_died_snd(a2),d2	; sample fuer sterben
		bra.s	mih_play_snd		; und verzweigen

mih_only_health
		move.w	#1,mon_a_hit(a2)	; flag fuer getroffen setzen
		move.w	d0,mon_health(a2)	; gegnerenergie zurueckschreiben

		move.w	mon_hit_snd(a2),d2	; sample fuer getroffen
mih_play_snd
 		movem.l	mon_line(a2),d0-d1	; und abhaengig von der position
		bsr	init_sam_dist		; das sample abspielen

mih_out
		rts


;**************************************
;* mon_is_hit_midi
;**************************************

; analoge routine fuer midi-gegner

; a2 = pointer auf midi-gegner
; alle register frei

	ifne midiplay

mon_is_hit_midi

	; (1) animation/sound setzen

		tst.w	mon_a_died(a2)		; ist gegner schon tot?
		bne.s	mihm_out		; ja -> raus aus der routine

		move.w	#1,mon_a_hit(a2)	; flag fuer "getroffen" setzen

		move.w	mon_hit_snd(a2),d2	; sample fuer getroffen
 		movem.l	mon_line(a2),d0-d1	; und abhaengig von der position
		bsr	init_sam_dist		; das sample abspielen

	; (2) dem gegner energie abziehen

		move.b	mon_falcon+1(a2),d0
		jsr	mp_send_11
mihm_out
		rts

	endc

