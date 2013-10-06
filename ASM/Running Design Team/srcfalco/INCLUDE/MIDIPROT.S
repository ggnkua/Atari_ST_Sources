
; Running Midiplay Edition
; (c) 1998 by RDT

; Protokoll-Routinen

; Routinen werden eingebunden, falls
; die Konstante midiplay ungleich Null gesetzt ist.

; Projektstart: 10.4.98


;**************************************
;* midi_handler
;**************************************

; wird als unterroutine (mit rts beenden) der interupt-routine
; des ikbd_handlers aufgerufen!

; zur verfuegung: d0-d2/a0-a2

ikbd_midi_ctl	equ	$fffffc04
ikbd_midi_dat	equ	$fffffc06

ikbd_midi_handler

		btst	#7,ikbd_midi_ctl.w		; war es ein midi-interrupt?
		beq.s	imh_out				; wenn nein -> dann rausspringen

		tst.w	midi_start			; darf der midi-irq ueberhaupt schon empfangen werden?
		beq.s	imh_no_midi_allowed		; nein -> abfangen

 		lea	mirqe_buffer,a0			; empfangsbuffer
		lea	mirqe_pos,a1			; position im empfangsbuffer
		move.w	(a1),d0				; freie position im buffer holen
		move.b	ikbd_midi_dat.w,(a0,d0.w)	; byte reinschreiben
		addq.b	#1,d0				; position um eins erhoehen
							; '.b' wegen buffergroesse 256 (sicherheit)
		move.w	d0,(a1)				; ... und zurueckschreiben
		cmp.b	2(a0),d0			; alle bytes des befehls empfangen?
		bne.s	imh_notcmdend			; nein -> dann ueberspringen
		clr.w	mirqe_pos			; buffer wieder freischalten
		bsr	midicommand2engine		; auf midikommando reagieren

imh_notcmdend

	; mastergeraet -> kein autom. senden von midibytes

		tst.w	midi_dat+midi_mode		; mastergeraet, wenn positiv
		bpl.s	imh_out				; ja -> dann raus

	; dieser falcon ist im slave-modus
	; autom. wieder ein byte ueber midi senden

		bsr.s	mirq_send_one_byte
imh_out
		rts


imh_no_midi_allowed
		move.b	ikbd_midi_dat.w,d0
		rts

;**************************************
;* midicommand2engine
;**************************************

; ueber midi wurde vollstaendig ein kommando
; uebertragen -> in engine uebernehmen

; zur verfuegung: d0-d2/a1-a2

; a0 = mirqe_buffer

midicommand2engine

	; schritt 1:
	; kontrollieren, ob eine aktion durchgefuehrt werden muss

		lea	mc2e_routs,a1
		moveq	#0,d0
		move.b	(a0),d0		; kommando holen
		move.l	(a1,d0.w*4),d0	; zgh. routine holen
		beq.s	mc2e_no_rout	; nullzeiger -> ueberspringen

		movea.l	d0,a1		; zeiger in adressregister
		move.l	a0,-(sp)
		jsr	(a1)		; routine ausfuehren
		movea.l	(sp)+,a0

mc2e_no_rout

	; schritt 2:
	; ttl verringern und kommando weiterschicken,
	; voraussetzung: kommando existiert noch -> ttl nicht negativ

		tst.b	1(a0)		; ex. befehl noch?
		bmi	mc2e_out	; nein (negativ) -> raus

	; kommando existiert noch -> ttl verringern ...

		subq.b	#1,1(a0)
		beq	mc2e_out
		bmi	mc2e_out	; sicherheitshalber

	; ... und absenden

	; a0 = zu sendende bytes

		bsr	mp_send_data

mc2e_out
		rts


;**************************************
;* mirq_send_one_byte
;**************************************

; benutzte register: d0-d2/a0-a2
; alle anderen muessen gerettet werden

mirq_send_one_byte

		lea	mirqs_data,a0			; datenpointer
		move.w	mirqs_posread(a0),d0		; head und tail vergleichen
		cmp.w	mirqs_possave(a0),d0		; sind sie gleich
		bne.s	mirqs_dataok			; nein -> dann einfach senden

	; in der schlange sind keine daten mehr zum senden
	; vorhanden -> spielerposition zum uebertragen
	; reinschreiben

	; solange noch kein level initialisiert wurde (midi_level_flag)
	; nur dummy bytes senden...

		tst.w	midi_dat+midi_level_flag
		bne.s	mirqs_verb_ok
		movem.l	d0/a0,-(sp)
		bsr	mp_send_2
		movem.l	(sp)+,d0/a0
		bra.s	mirqs_dataok
		
mirqs_verb_ok
		movem.l	d0/a0,-(sp)
		bsr	mp_send_10
		movem.l	(sp)+,d0/a0

mirqs_dataok

	; es sind bytes zum senden vorhanden,
	; also eines auf den weg schicken,
	; die schlange entspr. verkuerzen...

	; a0 = datenpointer
	; d0 = position

		lea	mirqs_buffer,a1		; sendebuffer
		move.b	(a1,d0.w),d1		; zu sendendes byte holen

		addq.w	#1,d0			; position erhoehen
		andi.w	#mirqs_bmask,d0		; maskieren (-> ueberlauf verhindern)
		move.w	d0,mirqs_posread(a0)	; und zurueckschreiben

mirqsa_wait	btst	#1,ikbd_midi_ctl.w	; midi acia status
		beq.s	mirqsa_wait		; wenn voll, dann noch warten
		move.b	d1,ikbd_midi_dat.w	; und das byte senden
		
mirqs_out
		rts


;**************************************
;* midi_irq_master
;**************************************

midi_irq_master

		movem.l	d0-a6,-(sp)

		tst.w	midi_dat+midi_mode
		beq.s	mv_no_midi		; weder master noch slave
		bmi.s	mv_no_midi		; slaves geben den takt nicht vor

		tst.w	midi_start
		beq.s	mv_no_midi
		jsr	mirq_send_one_byte
mv_no_midi

	ifne mididebug
	
		move.w	mirqe_pos,d0
		moveq	#3,d7
		movea.l	screen_2,a2
		adda.l	#640*5+544,a2
		jsr	paint_hex

		move.w	midi_dat+midi_connected,d0
		moveq	#3,d7
		movea.l	screen_2,a2
		adda.l	#640*15+544,a2
		jsr	paint_hex

		move.w	midi_start,d0
		moveq	#3,d7
		movea.l	screen_2,a2
		adda.l	#640*25+544,a2
		jsr	paint_hex

		move.w	midi_dat+midi_level_flag,d0
		moveq	#3,d7
		movea.l	screen_2,a2
		adda.l	#640*35+544,a2
		jsr	paint_hex

	endc
		
		movem.l	(sp)+,d0-a6

		rts


;**************************************
;* mp_send_2
;**************************************

; dummy bytes midi-schlange eintragen

; benutzte register: d0-d2/a0-a2
; alle anderen sind zu retten

mp_send_2

		lea	mirq2_raw,a0
		bsr	mp_send_data

		rts

;**************************************
;* mp_send_3
;**************************************

; spielernamen uebermitteln

; benutzte register: d0-d2/a0-a2
; alle anderen muessen gerettet werden

mp_send_3
		lea	mirq3_raw,a0
		lea	mplayers,a1
		lea	midi_dat,a2
		move.w	midi_pos(a2),d0
		move.b	midi_anzm1+1(a2),1(a0)			; ttl
		move.b	d0,m3_falcon(a0)			; falconnummer
		movea.l	(a1,d0.w*4),a1
		move.l	mon_midi_name(a1),m3_name(a0)		; name 0...3
		move.l	mon_midi_name+4(a1),m3_name+4(a0)	; name 4...7
		move.l	mon_midi_name+8(a1),m3_name+8(a0)	; name 8..11
		bsr	mp_send_data

		rts

;**************************************
;* mp_send_10
;**************************************

; spielerposition in die midi-schlange eintragen

; benutzte register: d0-d2/a0-a2
; alle anderen muessen gerettet werden

mp_send_10
		lea	mirq10_raw,a0
		movea.l	play_dat_ptr,a1
		move.b	pd_akt_sector+1(a1),m10_sector(a0)
		move.b	pd_sx+1(a1),m10_sx(a0)
		move.b	pd_sx+2(a1),m10_sx+1(a0)
		move.b	pd_sx+3(a1),m10_sx+2(a0)
		move.b	pd_sy+1(a1),m10_sy(a0)
		move.b	pd_sy+2(a1),m10_sy+1(a0)
		move.b	pd_sy+3(a1),m10_sy+2(a0)
		move.w	pd_sh+2(a1),d1
		tst.w	pd_health(a1)
		bpl.s	mps10_ok
		move.w	pd_sh_real+2(a1),d1
		addi.w	#$38,d1
mps10_ok	subi.w	#player_pix_hgt*2,d1
		lsr.w	#2,d1
		move.b	d1,m10_sh(a0)
		move.b	pd_alpha+3(a1),m10_salpha(a0)

		lea	midi_dat,a1
		move.b	midi_anzm1+1(a1),1(a0)			; ttl
		move.b	midi_pos+1(a1),m10_spieler(a0)		; welcher falcon
		move.b	midi_has_moved+1,m10_walk_flag(a0)	; mon_midi_walk

		bsr	mp_send_data

		rts

;**************************************
;* mp_send_11
;**************************************

; spieler wurde getroffen

; d0 = welcher spieler wurde getroffen

; benutzte register: d0-d2/a0-a2
; alle anderen sind zu retten

mp_send_11
		lea	mirq11_raw,a0
		lea	midi_dat,a1
		move.b	midi_anzm1+1(a1),1(a0)			; ttl (standard an alle)
		move.b	midi_pos+1(a1),m11_wer(a0)		; wer hat getroffen
		move.b	d0,m11_wen(a0)				; wer wurde getroffen
		movea.l	play_dat_ptr,a1
		move.w	pd_mun_type(a1),d1
		lea	player_staerke_tab,a2
		move.b	1(a2,d1.w*2),m11_energy_loss(a0)
		bsr	mp_send_data

		rts

;**************************************
;* mp_send_12
;**************************************

; spieler stirbt

; benutzte register: d0-d2/a0-a2
; alle anderen sind zu retten

mp_send_12
		lea	mirq12_raw,a0
		lea	midi_dat,a1
		move.b	midi_anzm1+1(a1),1(a0)			; ttl (standard an alle)
		move.b	midi_pos+1(a1),m12_wer(a0)		; wer stirbt
		bsr	mp_send_data

		rts


;**************************************
;* mp_send_13
;**************************************

; spieler schiesst

; benutzte register: d0-d2/a0-a2
; alle anderen sind zu retten

mp_send_13
		lea	mirq13_raw,a0
		lea	midi_dat,a1
		move.b	midi_anzm1+1(a1),1(a0)			; ttl (standard an alle)
		move.b	midi_pos+1(a1),m13_wer(a0)		; wer schiesst
		bsr	mp_send_data

		rts


;**************************************
;* mp_send_20
;**************************************

; tuer oeffnen

; d0 = sector
; d1 = door (die wievielte tuer ist es denn...?)

; benutzte register: d0-d2/a0-a2
; alle anderen sind zu retten

mp_send_20
		lea	mirq20_raw,a0
		move.b	midi_dat+midi_anzm1+1,1(a0)	; ttl (standard an alle)
		move.b	d0,m20_sector(a0)
		move.b	d1,m20_door(a0)
		bsr	mp_send_data

		rts


;**************************************
;* mp_send_21
;**************************************

; tuer schliessen

; d0 = sector
; d1 = door (die wievielte tuer ist es denn...?)

; benutzte register: d0-d2/a0-a2
; alle anderen sind zu retten

mp_send_21
		lea	mirq21_raw,a0
		move.b	midi_dat+midi_anzm1+1,1(a0)	; ttl (standard an alle)
		move.b	d0,m21_sector(a0)
		move.b	d1,m21_door(a0)
		bsr	mp_send_data

		rts


;**************************************
;* mp_send_24
;**************************************

; item verschwindet

; d0.b = sector
; d1.b = item (das wievielte item ist es denn...?)

; benutzte register: d0-d2/a0-a2
; alle anderen sind zu retten

mp_send_24
		lea	mirq24_raw,a0
		move.b	midi_dat+midi_anzm1+1,1(a0)	; ttl (standard an alle)
		move.b	d0,m24_sector(a0)
		move.b	d1,m24_item(a0)
		bsr	mp_send_data

		rts


;**************************************
;* mp_send_25
;**************************************

; item erscheint wieder

; d0.b = sector
; d1.b = item (das wievielte item ist es denn...?)

; benutzte register: d0-d2/a0-a2
; alle anderen sind zu retten

mp_send_25
		lea	mirq25_raw,a0
		move.b	midi_dat+midi_anzm1+1,1(a0)	; ttl (standard an alle)
		move.b	d0,m25_sector(a0)
		move.b	d1,m25_item(a0)
		bsr	mp_send_data

		rts


;**************************************
;* mp_send_25all
;**************************************

; item erscheint wieder
; kommando wird an alle falcons verschickt, auch
; an diesen rechner selbst

; d0.b = sector
; d1.b = item (das wievielte item ist es denn...?)

; benutzte register: d0-d2/a0-a2
; alle anderen sind zu retten

mp_send_25all
		lea	mirq25_raw,a0
		move.b	midi_dat+midi_anz+1,1(a0)	; ttl (einmal komplett herum)
		move.b	d0,m25_sector(a0)
		move.b	d1,m25_item(a0)
		bsr	mp_send_data

		rts


;**************************************
;* mp_send_data
;**************************************

; uebertraegt das bei a0 liegende kommando in den
; midi-sendebuffer -> frei zur uebertragung

; benutzte register: d0-d2/a0-a2
; alle anderen sind zu retten

;    a0 = zu sendender buffer
; 2(a0) = befehlslaenge

mp_send_data
		moveq	#0,d0
		move.b	2(a0),d0		; befehlslaenge holen
		subq.w	#1,d0			; -1 fuer dbra

		lea	mirqs_buffer,a1
		lea	mirqs_data,a2
		move.w	#mirqs_bmask,d1

		move.w	sr,-(sp)	
		move.w	#$2300,sr

		move.w	mirqs_possave(a2),d2
mpsd_loop	move.b	(a0)+,(a1,d2.w)
		addq.w	#1,d2
		and.w	d1,d2
		dbra	d0,mpsd_loop
		move.w	d2,mirqs_possave(a2)

		move.w	(sp)+,sr

		rts


;**************************************

mirq0_raw	dc.b	0		; 0 = anzahl falcons zaehlen
		dc.b	0		; ttl
		dc.b	4		; anzahl zu sendender bytes
		dc.b	0		; anzahl falcons
		even

mirq1_raw	dc.b	1		; 1 = verbindungskontrolle
		dc.b	0		; ttl
		dc.b	4		; anzahl zu sendender bytes
		dc.b	0		; anzahl falcons im token-ring
		even

mirq2_raw	dc.b	2		; 2 = dummy befehl
		dc.b	1		; ttl: lebt nur eine uebertragung
		dc.b	3		; anzahl zu sendender bytes
		even

mirq3_raw	dc.b	3		; 3 = spielername folgt
		dc.b	0		; ttl
		dc.b	16		; anzahl bytes
		dc.b	0		; von welchem falcon?
		dc.b	0,0,0,0,0,0	; 12 bytes fuer spielername
		dc.b	0,0,0,0,0,0	; -> inkl. nullbyte
		even

mirq4_raw	dc.b	4		; select mode
		dc.b	0		; ttl
		dc.b	4		; anzahl bytes
		dc.b	0		; mode
		even

mirq5_raw	dc.b	5		; select mode
		dc.b	0		; ttl
		dc.b	4		; anzahl bytes
		dc.b	0		; episode
		even

mirq10_raw	dc.b	10		; 10 = spielerposition folgt
		dc.b	0		; ttl
		dc.b	14		; anzahl zu sendender bytes
		dc.b	0		; falconnummer (send. geraet)
		dc.b	0		; sector
		dc.b	0,0,0		; sx
		dc.b	0,0,0		; sy
		dc.b	0		; sh
		dc.b	0		; salpha
		dc.b	0		; mon_midi_walk
		even

mirq11_raw	dc.b	11		; 11 = spieler wurde getroffen
		dc.b	0		; ttl
		dc.b	6		; anzahl zu sendender bytes
		dc.b	0		; wer
		dc.b	0		; wen
		dc.b	0		; energy_loss
		even

mirq12_raw	dc.b	12		; 12 = spieler stirbt
		dc.b	0		; ttl
		dc.b	4		; anzahl bytes
		dc.b	0		; wer
		even

mirq13_raw	dc.b	13		; 13 = spieler schiesst
		dc.b	0		; ttl
		dc.b	4		; anzahl bytes
		dc.b	0		; wer
		even

mirq20_raw	dc.b	20		; 20 = tuer oeffnen
		dc.b	0		; ttl
		dc.b	5		; anzahl bytes
		dc.b	0		; sector
		dc.b	0		; door
		even

mirq21_raw	dc.b	21		; 21 = tuer schliessen
		dc.b	0		; ttl
		dc.b	5		; anzahl bytes
		dc.b	0		; sector
		dc.b	0		; door
		even

mirq22_raw	dc.b	22		; 22 = lift hoch
		dc.b	0		; ttl
		dc.b	4		; anzahl bytes
		dc.b	0		; sector
		even

mirq23_raw	dc.b	23		; 23 = lift runter
		dc.b	0		; ttl
		dc.b	4		; anzahl bytes
		dc.b	0		; sector
		even

mirq24_raw	dc.b	24		; 24 = item verschwindet
		dc.b	0		; ttl
		dc.b	5		; anzahl bytes
		dc.b	0		; sector
		dc.b	0		; item
		even

mirq25_raw	dc.b	25		; 25 = item erscheint
		dc.b	0		; ttl
		dc.b	5		; anzahl bytes
		dc.b	0		; sector
		dc.b	0		; item
		even



