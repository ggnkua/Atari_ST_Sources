
animate_shoot

	; -------------------
	; hauptanimation

		bsr	as_animation

	; -------------------
	; muss neue animation 
	; gestartet werden?

		movea.l	play_dat_ptr,a6
		tst.w	pd_hat_gesch(a6)		; hat spieler einen
		beq	as_out				; schuss abgegeben?

	; -------------------
	; keine schussanimation, 
	; falls mit fuss geschlagen ...

		tst.w	pd_mun_type(a6)
		beq	as_out

	; -------------------
	; jetzt einen freien 
	; animationsplatz suchen ...

		bsr	as_find_free_animation		; d0.w hat wert 0..3

	; -------------------
	; flag fuer schussbeginn 
	; setzen ...

		move.w	#1,pd_as_flag(a6,d0.w*2)
		clr.w	pd_as_pos(a6,d0.w*2)

	; -------------------
	; aktuelle position 
	; zwischenspeichern ...

		lea	as_thing,a5
		movea.l	(a5,d0.w*4),a5
		movem.l	pd_sx(a6),d1-d2
		movem.l	d1-d2,(a5)
		move.l	pd_alpha(a6),16(a5)

	; -------------------
	; anfangs- und endhoehe 
	; berechnen und setzen ...

		movea.l	big_sector_ptr,a0
		movea.l	lev_init_data(a0),a0
		move.w	pd_mun_type(a6),d1
		movea.l	init_as0(a0,d1.w*4),a0
		move.w	ias_hoehe(a0),d7

		move.l	pd_sh(a6),d1
		lsr.w	#2,d1
		move.w	d7,d6
		lsr.w	#1,d6
		sub.w	d6,d1
		move.b	d1,11(a5)		; h1
		add.b	d7,d1
		move.b	d1,15(a5)		; h2

as_out
		rts

;---

; a6: play_dat_ptr

as_find_free_animation

		moveq	#3,d0
asffa_loop	tst.w	pd_as_flag(a6,d0.w*2)
		beq.s	asffa_found
		dbra	d0,asffa_loop

	; alle animationspl„tze belegt, also den ersten (in diesem
	; fall von hinten) belegen

		moveq	#3,d0
		rts

asffa_found
		rts


;**************************************
;* as_animation
;**************************************

as_animation

		lea	as_thing,a4
		movea.l	play_dat_ptr,a6
		moveq	#3,d0
asa_loop	bsr	asa_one_animation
		dbra	d0,asa_loop

		rts

;---

; d0: animation (0..3)
; a4: as_thing
; a6: play_dat_ptr

asa_one_animation

		movea.l	play_dat_ptr,a6
		tst.w	pd_as_flag(a6,d0.w*2)		; animation vorhanden ?
		beq	asaoa_out			; wenn keine, dann raus

		movea.l	(a4,d0.w*4),a5

		cmpi.w	#1,pd_as_flag(a6,d0.w*2)	; wenn erstmaliger aufruf, dann
		bne.s	asaoa_not_first			; in eine sonderroutine verzweigen ...

		bsr	asaoa_first_time

		tst.w	asaoa_out_flag
		beq.s	asaoa_not_first

		rts

asaoa_not_first

	; animationsphase setzen, dabei die aktuelle
	; position beruecksichtigen und danach erst heraufzaehlen
	; bzw. abbrechen ...

		move.w	#1,pd_as_send_flag(a6,d0.w*2)	; flag setzen, damit
							; der dsp die daten erhaelt ...
		tst.w	pd_as_count(a6,d0.w*2)
		bne.s	asaoa_no_count_vorbei

	; animationsphase genau dann setzen, wenn
	; pd_as_count auf null steht ...

		movea.l	big_sector_ptr,a0
		movea.l	lev_init_data(a0),a0
		move.w	pd_mun_type(a6),d1
		movea.l	init_as0(a0,d1.w*4),a0
		move.w	pd_as_pos(a6,d0.w*2),d1
		lea	ias_phasen(a0,d1.w*8),a0
		move.w	iasp_textnb(a0),8(a5)		; text_nb
		move.l	iasp_lineflag3(a0),16(a5)	; lineflag3		
				
asaoa_no_count_vorbei

	; und jetzt pd_as_count heraufzaehlen ...

		movea.l	big_sector_ptr,a0
		movea.l	lev_init_data(a0),a0
		move.w	pd_mun_type(a6),d1
		movea.l	init_as0(a0,d1.w*4),a0

		move.w	pd_as_count(a6,d0.w*2),d1
		add.w	vbl_time,d1
		cmp.w	ias_vbl(a0),d1
		blt.s	as_no_phase_change

	; animationsphase muss geaendert werden ...

		moveq	#0,d1

		move.w	pd_as_pos(a6,d0.w*2),d2
		addq.w	#1,d2
		cmp.w	ias_anzahl(a0),d2
		blt.s	as_no_phase_end

	; animation ist zu ende ...

		moveq	#0,d2
		clr.w	pd_as_flag(a6,d0.w*2)
		clr.w	pd_as_send_flag(a6,d0.w*2)

as_no_phase_end
		move.w	d2,pd_as_pos(a6,d0.w*2)

as_no_phase_change		

		move.w	d1,pd_as_count(a6,d0.w*2)

asaoa_out
		rts

;---

asaoa_out_flag	dc.w	0

;---

asaoa_first_time

		clr.w	asaoa_out_flag
		addq.w	#1,pd_as_flag(a6,d0.w*2)	; damit kennzeichnung second_time ...

	; jetzt die tatsaechlichen koordinaten der animation feststellen

		lea	sinus_256_tab,a3
		move.l	16(a5),d2		; pd_alpha
		move.w	(a3,d2.w*2),d6		; sinus
		addi.w	#$40,d2
		andi.w	#$ff,d2
		move.w	(a3,d2.w*2),d7		; cosinus
		move.l	min_entf,d5		; laenge schuss (absolut)

		lea	shoot_length,a0
		move.w	pd_mun_type(a6),d4
		cmp.l	(a0,d4.w*4),d5
		blt.s	asaoaft_ok

		move.w	#1,asaoa_out_flag
		clr.w	pd_as_flag(a6,d0.w*2)
		rts		

asaoaft_ok
		movea.l	big_sector_ptr,a0
		movea.l	lev_infos(a0),a0
		move.w	li_dsp_genau(a0),d4
		lsl.w	#2,d4			; vier pixel vor der wand 
		sub.w	d4,d5
		muls	d5,d6
		muls	d5,d7
		moveq	#14,d5
		asr.l	d5,d6
		asr.l	d5,d7
		movem.l	(a5),d1-d2		; ausgangskoordinaten holen
		add.l	d6,d2
		add.l	d7,d1
		movem.l	d1-d2,(a5)

		rts


;---------------

shoot_length	dc.l	shoot_length_0
		dc.l	32768*8
		dc.l	32768*8	
		dc.l	32768*8	
		dc.l	32768*8	



