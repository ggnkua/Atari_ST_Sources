
;**************************************
;* find_visible_monsters
;**************************************

find_vis_monst

	; (1) eine tabelle mit allen sichtbaren sektoren generieren

		lea	fvm_secs,a0		; alle sichtbaren sektoren              
		movea.l	a0,a1			; adresse sichern

		movea.l	big_sector_ptr,a2	; leveladresse holen
		movea.l	play_dat_ptr,a4
		move.w	pd_akt_sector(a4),d0
		move.w	d0,(a0)+		; akt. sektor schon eintragen
		movea.l	lev_sec_start(a2,d0.w*4),a3
		lea	sec_ext_lines(a3),a3
		moveq	#-1,d7
fvm_fs_loop
		addq.w	#1,d7
		move.w	(a3)+,(a0)+		; sector eintragen
		bpl.s	fvm_fs_loop

		movea.l	a1,a0			; adresse zuruecksichern

		ifeq midiplay

	; (2) alle standard-gegner auf diese sektoren hin ueberpruefen

		movea.l	lev_monsters(a2),a1
		movea.l	mon_dat(a1),a1
		movea.l	mon_buf2_ptr,a4
		moveq	#-1,d5

fvm_std_loop
		move.l	(a1)+,d0		; naechster gegner
		bmi.s	fvm_std_out		; ende erreicht -> routine beenden
		movea.l	d0,a2			; ins adressregister
		move.w	mon_sec(a2),d1		; d1 = sektor des gegners
		movea.l	a0,a3			; a3 = liste mit sektoren
		move.w	d7,d6			; d6 = anzahl sektoren in liste (-1)
fvm_find_std_loop
		cmp.w	(a3)+,d1		; sektor vergleichen
		beq.s	fvm_std_mon_vis		; gegner sichtbar
		dbra	d6,fvm_find_std_loop	; alle sektoren in liste bearbeiten
		bra.s	fvm_std_loop		; und alle gegner abarbeiten

fvm_std_mon_vis
		move.l	a2,(a4)+		; standard-gegner eintragen
		addq.w	#1,d5
		bra.s	fvm_std_loop
fvm_std_out
		move.w	d5,mon_buf2_anz

		else

	; (3) alle midi-gegner auf diese sektoren hin ueberpruefen

		lea	midi_dat,a2
		tst.w	midi_connected(a2)	; besteht midi-verbindung?
		beq.s	fvm_midi_out		; nein -> routine ueberspringen

		move.w	midi_anzm1(a2),d3	; anzahl midi-gegner (-1)
		move.w	midi_pos(a2),d4
		moveq	#-1,d5
		movea.l	mmon_buf2_ptr,a4
		lea	mplayers,a1
		moveq	#1,d2
fvm_midi_loop

	; belegte register in der schleife:
	; d2,d5,d7,a0,a1,a2,a4

		movea.l	(a1)+,a2		; naechster gegner
		bsr	fvm_midi_update
		cmp.w	mon_falcon(a2),d4	; midi-gegner dieser falcon selbst?
		beq.s	fvm_midi_skip		; ja -> diesen gegner ueberspringen
		clr.w	mon_visible(a2)		; default auf nicht sichtbar setzen
		move.w	mon_sec(a2),d1
		movea.l	a0,a3
		move.w	d7,d6
fvm_find_midi_loop
		cmp.w	(a3)+,d1		; sektornummern gleich?
		beq.s	fvm_midi_mon_vis	; ja -> gegner sichtbar
		dbra	d6,fvm_find_midi_loop	; bis alle sichtb. sektoren durch
		bra.s	fvm_midi_skip		; gegner nicht sichtbar -> ab zum naechsten
fvm_midi_mon_vis
		move.l	a2,(a4)+		; midi-gegner eintragen
		add.w	d2,d5
		move.w	d2,mon_visible(a2)
fvm_midi_skip
		dbra	d3,fvm_midi_loop

		move.w	d5,mmon_buf2_anz
fvm_midi_out
		endc

		rts


;**************************************
;* fvm_midi_update
;**************************************

; a2 = zeiger midigegner
; achtung: aufpassen, welche register frei sind bzw. belegt

fvm_midi_update

		move.w	sr,-(sp)
		move.w	#$2300,sr
		movem.l	mon_midi_x(a2),d0-d1
		movem.l	d0-d1,mon_line(a2)
		move.w	mon_midi_sector(a2),mon_sec(a2)
		move.b	mon_midi_sh(a2),mon_line+11(a2)
		move.b	mon_midi_alpha(a2),mon_line+13(a2)

		tst.b	mon_midi_walk(a2)	; flag: 0 = bleibt stehen, 1 = laufen
		beq.s	fvmmuw_set_0		; wenn 0 -> dann immer loeschen
		tst.w	mon_a_walk(a2)		; spieler soll laufen, laeuft er schon?
		bne.s	fvmmuw_ok		; ja -> dann ueberspringen
		move.w	#1,mon_a_walk(a2)	; nein -> dann anfangsphase fordern
		bra.s	fvmmuw_ok		; und ueberspringen
fvmmuw_set_0	clr.w	mon_a_walk(a2)		; laufen anhalten
fvmmuw_ok

		tst.b	mon_midi_shoot(a2)	; flag: 0 = unveraendert, 1 = schussbeginn
		beq.s	fvmmus_ok		; wenn 0 -> dann ueberspringen
		clr.b	mon_midi_shoot(a2)	; flag loeschen
		move.w	#1,mon_a_shoot(a2)	; und anfang setzen
fvmmus_ok

		tst.b	mon_midi_hit(a2)	; flag: 0 = unveraendert, 1 = schussbeginn
		beq.s	fvmmuh_ok		; wenn 0 -> dann ueberspringen
		clr.b	mon_midi_hit(a2)	; flag loeschen
		move.w	#1,mon_a_hit(a2)	; und anfang setzen
fvmmuh_ok

		tst.b	mon_midi_die(a2)	; flag: 0 = unveraendert, 1 = schussbeginn
		beq.s	fvmmud_ok		; wenn 0 -> dann ueberspringen
		clr.b	mon_midi_die(a2)	; flag loeschen
		move.w	#1,mon_a_died(a2)	; und anfang setzen
fvmmud_ok

		move.w	(sp)+,sr

		rts
